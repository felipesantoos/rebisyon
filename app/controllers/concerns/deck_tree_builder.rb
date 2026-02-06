# frozen_string_literal: true

module DeckTreeBuilder
  extend ActiveSupport::Concern

  private

  # Builds a hierarchical deck tree from the user's root decks.
  # Loads all decks in a single query and builds the tree in memory
  # to avoid N+1 queries on children.
  # @param user [User]
  # @return [Array<Hash>]
  def build_deck_tree(user)
    decks = user.decks.where(deleted_at: nil).order(:name).to_a

    # Build a lookup of children by parent_id in memory
    children_by_parent = decks.group_by(&:parent_id)
    roots = children_by_parent[nil] || []

    # Preload card counts per deck in a single query
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

    roots.map { |deck| build_deck_node(deck, card_counts, children_by_parent, 0) }
  end

  # Recursively builds a deck node hash with counts rolled up from children.
  # Uses the in-memory children lookup instead of querying the database.
  # @param deck [Deck]
  # @param card_counts [Hash<Integer, Object>]
  # @param children_by_parent [Hash<Integer, Array<Deck>>]
  # @param depth [Integer]
  # @return [Hash]
  def build_deck_node(deck, card_counts, children_by_parent, depth)
    children = children_by_parent[deck.id] || []
    children_nodes = children.map { |child| build_deck_node(child, card_counts, children_by_parent, depth + 1) }

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
