# frozen_string_literal: true

module DeckTreeBuilder
  extend ActiveSupport::Concern

  private

  # Builds a hierarchical deck tree from the user's root decks.
  # Each node includes card counts computed via PostgreSQL functions.
  # @param user [User]
  # @return [Array<Hash>]
  def build_deck_tree(user)
    decks = user.decks.where(deleted_at: nil).includes(:children).order(:name)
    roots = decks.select(&:root?)

    # Preload card counts per deck using the database view
    card_counts = Card.joins(:deck)
                      .where(decks: { user_id: user.id })
                      .where(suspended: false, buried: false)
                      .group(:deck_id)
                      .select(
                        "deck_id",
                        "COUNT(*) FILTER (WHERE state = 'new') AS new_count",
                        "COUNT(*) FILTER (WHERE state IN ('learn', 'relearn')) AS learn_count",
                        "COUNT(*) FILTER (WHERE state = 'review' AND due <= #{Card.sanitize_sql_for_conditions(["?", (Time.current.to_f * 1000).to_i])}) AS due_count",
                        "COUNT(*) AS total_count"
                      ).index_by(&:deck_id)

    roots.map { |deck| build_deck_node(deck, card_counts, 0) }
  end

  # Recursively builds a deck node hash with counts rolled up from children.
  # @param deck [Deck]
  # @param card_counts [Hash<Integer, Object>]
  # @param depth [Integer]
  # @return [Hash]
  def build_deck_node(deck, card_counts, depth)
    children_nodes = deck.children.order(:name).map { |child| build_deck_node(child, card_counts, depth + 1) }

    counts = card_counts[deck.id]
    own_new   = counts&.new_count.to_i
    own_learn = counts&.learn_count.to_i
    own_due   = counts&.due_count.to_i
    own_total = counts&.total_count.to_i

    # Roll up children counts
    child_new   = children_nodes.sum { |c| c[:new_count] }
    child_learn = children_nodes.sum { |c| c[:learn_count] }
    child_due   = children_nodes.sum { |c| c[:due_count] }
    child_total = children_nodes.sum { |c| c[:total] }

    {
      id: deck.id,
      name: deck.name,
      full_name: deck.full_name,
      depth: depth,
      new_count: own_new + child_new,
      learn_count: own_learn + child_learn,
      due_count: own_due + child_due,
      total: own_total + child_total,
      children: children_nodes
    }
  end

  # Computes totals from a deck tree.
  # @param deck_tree [Array<Hash>]
  # @return [Hash]
  def compute_totals(deck_tree)
    {
      new_count: deck_tree.sum { |d| d[:new_count] },
      learn_count: deck_tree.sum { |d| d[:learn_count] },
      due_count: deck_tree.sum { |d| d[:due_count] }
    }
  end
end
