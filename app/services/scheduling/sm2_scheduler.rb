# frozen_string_literal: true

module Scheduling
  # Implements the SM-2 spaced repetition algorithm
  #
  # SM-2 is the original algorithm used by SuperMemo 2.0 and Anki's default algorithm.
  # It uses ease factors, intervals, and learning steps to schedule card reviews.
  #
  # @example
  #   scheduler = Scheduling::Sm2Scheduler.new(card, deck)
  #   result = scheduler.answer_new(rating: 3) # rating: 1=Again, 2=Hard, 3=Good, 4=Easy
  #   card.update!(result)
  class Sm2Scheduler
    attr_reader :card, :deck

    # Rating constants
    RATING_AGAIN = 1
    RATING_HARD = 2
    RATING_GOOD = 3
    RATING_EASY = 4

    # Ease factor changes
    EASE_CHANGE_AGAIN = -200
    EASE_CHANGE_HARD = -150
    EASE_CHANGE_GOOD = 0
    EASE_CHANGE_EASY = 150
    MIN_EASE = 1300

    def initialize(card, deck)
      @card = card
      @deck = deck
    end

    # Processes answer for a new card (state: new)
    # @param rating [Integer] 1=Again, 2=Hard, 3=Good, 4=Easy
    # @return [Hash] Update attributes for the card
    def answer_new(rating:)
      options = deck_options

      case rating
      when RATING_AGAIN
        # Start learning steps
        step = first_learning_step(options)
        {
          state: :learn,
          due: current_timestamp + step_minutes_to_milliseconds(step),
          position: 0,
          reps: card.reps + 1
        }
      when RATING_HARD
        # Start learning steps
        step = first_learning_step(options)
        {
          state: :learn,
          due: current_timestamp + step_minutes_to_milliseconds(step),
          position: 0,
          reps: card.reps + 1
        }
      when RATING_GOOD
        # Graduate to review
        graduating_interval = options["graduating_interval_good"] || 1
        {
          state: :review,
          due: days_to_timestamp(graduating_interval),
          interval: graduating_interval,
          ease: initial_ease(options),
          reps: card.reps + 1,
          position: 0
        }
      when RATING_EASY
        # Graduate to review with easy interval
        easy_interval = options["easy_interval"] || 4
        {
          state: :review,
          due: days_to_timestamp(easy_interval),
          interval: easy_interval,
          ease: initial_ease(options) + EASE_CHANGE_EASY,
          reps: card.reps + 1,
          position: 0
        }
      else
        raise ArgumentError, "Invalid rating: #{rating}"
      end
    end

    # Processes answer for a learning card (state: learn)
    # @param rating [Integer] 1=Again, 2=Hard, 3=Good, 4=Easy
    # @return [Hash] Update attributes for the card
    def answer_learning(rating:)
      options = deck_options
      steps = learning_steps(options)
      current_position = card.position

      case rating
      when RATING_AGAIN
        # Return to step 0
        step = first_learning_step(options)
        {
          due: current_timestamp + step_minutes_to_milliseconds(step),
          position: 0,
          reps: card.reps + 1
        }
      when RATING_HARD
        # Stay on current step or go back one
        new_position = [current_position - 1, 0].max
        step = steps[new_position] || steps.last
        {
          due: current_timestamp + step_minutes_to_milliseconds(step),
          position: new_position,
          reps: card.reps + 1
        }
      when RATING_GOOD
        # Advance to next step
        new_position = current_position + 1
        if new_position >= steps.length
          # Graduate to review
          graduating_interval = options["graduating_interval_good"] || 1
          {
            state: :review,
            due: days_to_timestamp(graduating_interval),
            interval: graduating_interval,
            ease: initial_ease(options),
            reps: card.reps + 1,
            position: 0
          }
        else
          step = steps[new_position]
          {
            due: current_timestamp + step_minutes_to_milliseconds(step),
            position: new_position,
            reps: card.reps + 1
          }
        end
      when RATING_EASY
        # Graduate to review with easy interval
        easy_interval = options["easy_interval"] || 4
        {
          state: :review,
          due: days_to_timestamp(easy_interval),
          interval: easy_interval,
          ease: initial_ease(options) + EASE_CHANGE_EASY,
          reps: card.reps + 1,
          position: 0
        }
      else
        raise ArgumentError, "Invalid rating: #{rating}"
      end
    end

    # Processes answer for a review card (state: review)
    # @param rating [Integer] 1=Again, 2=Hard, 3=Good, 4=Easy
    # @return [Hash] Update attributes for the card
    def answer_review(rating:)
      options = deck_options
      current_interval = card.interval
      current_ease = card.ease

      case rating
      when RATING_AGAIN
        # Move to relearning
        lapses = card.lapses + 1
        relearn_steps = relearning_steps(options)
        step = relearn_steps.first || 10 # Default 10 minutes if no steps
        
        {
          state: :relearn,
          due: current_timestamp + step_minutes_to_milliseconds(step),
          interval: [current_interval * (options["lapse_multiplier"] || 0.0), 
                     (options["minimum_lapse_interval"] || 1)].max.to_i,
          ease: [current_ease + EASE_CHANGE_AGAIN, MIN_EASE].max,
          lapses: lapses,
          reps: card.reps + 1,
          position: 0
        }
      when RATING_HARD
        # Hard interval: current * 1.2 * modifier
        hard_interval = (current_interval * 1.2 * interval_modifier(options)).to_i
        hard_interval = [hard_interval, 1].max # Minimum 1 day
        new_interval = [hard_interval, current_interval + 1].max # Guarantee >= previous + 1
        
        {
          due: days_to_timestamp(new_interval),
          interval: [new_interval, maximum_interval(options)].min,
          ease: [current_ease + EASE_CHANGE_HARD, MIN_EASE].max,
          reps: card.reps + 1
        }
      when RATING_GOOD
        # Good interval: current * (ease/1000) * modifier
        good_interval = (current_interval * (current_ease / 1000.0) * interval_modifier(options)).to_i
        good_interval = [good_interval, 1].max # Minimum 1 day
        new_interval = [good_interval, current_interval + 1].max # Guarantee >= previous + 1
        
        # Apply fuzz factor for intervals >= 3 days
        if new_interval >= 3
          fuzz = apply_fuzz_factor(new_interval)
          new_interval = fuzz
        end
        
        {
          due: days_to_timestamp(new_interval),
          interval: [new_interval, maximum_interval(options)].min,
          ease: current_ease + EASE_CHANGE_GOOD, # No change
          reps: card.reps + 1
        }
      when RATING_EASY
        # Easy interval: current * (ease/1000) * easy_bonus * modifier
        easy_bonus = options["easy_bonus"] || 1.3
        easy_interval = (current_interval * (current_ease / 1000.0) * easy_bonus * interval_modifier(options)).to_i
        easy_interval = [easy_interval, 1].max # Minimum 1 day
        new_interval = [easy_interval, current_interval + 1].max # Guarantee >= previous + 1
        
        # Apply fuzz factor for intervals >= 3 days
        if new_interval >= 3
          fuzz = apply_fuzz_factor(new_interval)
          new_interval = fuzz
        end
        
        {
          due: days_to_timestamp(new_interval),
          interval: [new_interval, maximum_interval(options)].min,
          ease: current_ease + EASE_CHANGE_EASY,
          reps: card.reps + 1
        }
      else
        raise ArgumentError, "Invalid rating: #{rating}"
      end
    end

    # Processes answer for a relearning card (state: relearn)
    # @param rating [Integer] 1=Again, 2=Hard, 3=Good, 4=Easy
    # @return [Hash] Update attributes for the card
    def answer_relearning(rating:)
      options = deck_options
      relearn_steps = relearning_steps(options)
      current_position = card.position

      case rating
      when RATING_AGAIN
        # Return to step 0
        step = relearn_steps.first || 10
        {
          due: current_timestamp + step_minutes_to_milliseconds(step),
          position: 0,
          reps: card.reps + 1
        }
      when RATING_HARD
        # Stay on current step or go back one
        new_position = [current_position - 1, 0].max
        step = relearn_steps[new_position] || relearn_steps.last || 10
        {
          due: current_timestamp + step_minutes_to_milliseconds(step),
          position: new_position,
          reps: card.reps + 1
        }
      when RATING_GOOD
        # Advance to next step
        new_position = current_position + 1
        if new_position >= relearn_steps.length
          # Return to review state with the interval from before relearning
          {
            state: :review,
            due: days_to_timestamp(card.interval),
            reps: card.reps + 1,
            position: 0
          }
        else
          step = relearn_steps[new_position]
          {
            due: current_timestamp + step_minutes_to_milliseconds(step),
            position: new_position,
            reps: card.reps + 1
          }
        end
      when RATING_EASY
        # Return to review state immediately
        {
          state: :review,
          due: days_to_timestamp(card.interval),
          reps: card.reps + 1,
          position: 0
        }
      else
        raise ArgumentError, "Invalid rating: #{rating}"
      end
    end

    private

    # Gets deck options with defaults
    # @return [Hash]
    def deck_options
      options = deck.options_json || {}
      {
        "learn_steps" => options["learn_steps"] || [1, 10], # minutes
        "relearn_steps" => options["relearn_steps"] || [10], # minutes
        "graduating_interval_good" => options["graduating_interval_good"] || 1, # days
        "easy_interval" => options["easy_interval"] || 4, # days
        "initial_ease" => options["initial_ease"] || 2.5,
        "easy_bonus" => options["easy_bonus"] || 1.3,
        "hard_multiplier" => options["hard_multiplier"] || 1.2,
        "lapse_multiplier" => options["lapse_multiplier"] || 0.0,
        "interval_modifier" => options["interval_modifier"] || 1.0,
        "maximum_interval" => options["maximum_interval"] || 36_500, # days
        "minimum_lapse_interval" => options["minimum_lapse_interval"] || 1 # days
      }
    end

    # Gets learning steps from options
    # @return [Array<Integer>] Steps in minutes
    def learning_steps(options)
      steps = options["learn_steps"] || [1, 10]
      steps.is_a?(Array) ? steps : [1, 10]
    end

    # Gets first learning step
    # @return [Integer] Step in minutes
    def first_learning_step(options)
      steps = learning_steps(options)
      steps.first || 1
    end

    # Gets relearning steps from options
    # @return [Array<Integer>] Steps in minutes
    def relearning_steps(options)
      steps = options["relearn_steps"] || [10]
      steps.is_a?(Array) ? steps : [10]
    end

    # Gets initial ease factor
    # @return [Integer] Ease in permille (e.g., 2500 = 2.5)
    def initial_ease(options)
      ease = options["initial_ease"] || 2.5
      (ease * 1000).to_i
    end

    # Gets interval modifier
    # @return [Float]
    def interval_modifier(options)
      options["interval_modifier"] || 1.0
    end

    # Gets maximum interval
    # @return [Integer] Days
    def maximum_interval(options)
      options["maximum_interval"] || 36_500
    end

    # Applies fuzz factor to interval (~25% randomization)
    # @param interval [Integer] Days
    # @return [Integer] Days with fuzz
    def apply_fuzz_factor(interval)
      # Randomize by ±25%
      fuzz_range = (interval * 0.25).to_i
      fuzz = rand(-fuzz_range..fuzz_range)
      [interval + fuzz, 1].max
    end

    # Converts minutes to milliseconds timestamp
    # @param minutes [Integer, Float]
    # @return [Integer] Milliseconds since epoch
    def step_minutes_to_milliseconds(minutes)
      (minutes * 60 * 1000).to_i
    end

    # Converts days to milliseconds timestamp
    # @param days [Integer]
    # @return [Integer] Milliseconds since epoch
    def days_to_timestamp(days)
      current_timestamp + (days * 24 * 60 * 60 * 1000)
    end

    # Gets current timestamp in milliseconds
    # @return [Integer] Milliseconds since epoch
    def current_timestamp
      (Time.current.to_f * 1000).to_i
    end
  end
end
