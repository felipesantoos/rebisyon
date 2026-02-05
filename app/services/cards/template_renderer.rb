# frozen_string_literal: true

require "erb"

module Cards
  # Renders card templates with field replacements, conditionals, and special fields
  #
  # Supports:
  # - Field replacements: {{FieldName}}
  # - Conditionals: {{#Field}}...{{/Field}}, {{^Field}}...{{/Field}}
  # - Cloze deletions: {{c1::text::hint}}
  # - Special fields: {{FrontSide}}, {{Tags}}, {{Deck}}, {{Type}}
  #
  # @example
  #   card = Card.find(1)
  #   renderer = Cards::TemplateRenderer.new(card)
  #   front = renderer.render_front
  #   back = renderer.render_back
  class TemplateRenderer
    attr_reader :card, :note, :note_type

    def initialize(card)
      @card = card
      @note = card.note
      @note_type = note.note_type
    end

    # Renders the front template
    # @return [String] Rendered HTML
    def render_front
      template = get_template("Front")
      render_template(template)
    end

    # Renders the back template
    # @return [String] Rendered HTML
    def render_back
      template = get_template("Back")
      render_template(template)
    end

    private

    # Gets a template by name
    # @param name [String] Template name (e.g., "Front", "Back")
    # @return [String] Template content
    def get_template(name)
      templates = note_type.templates
      templates[name] || templates[name.downcase] || ""
    end

    # Renders a template with all replacements
    # @param template [String] Template content
    # @return [String] Rendered HTML
    def render_template(template)
      result = template.dup

      # Replace special fields first
      result = replace_special_fields(result)

      # Replace field values
      result = replace_fields(result)

      # Process conditionals
      result = process_conditionals(result)

      # Process cloze deletions
      result = process_cloze(result)

      result
    end

    # Replaces special fields like {{FrontSide}}, {{Tags}}, {{Deck}}, {{Type}}
    # @param template [String]
    # @return [String]
    def replace_special_fields(template)
      result = template.dup

      # {{FrontSide}} - front template rendered
      result.gsub!(/\{\{FrontSide\}\}/) { render_front }

      # {{Tags}} - note tags
      result.gsub!(/\{\{Tags\}\}/) { note.tags.join(" ") }

      # {{Deck}} - deck name
      result.gsub!(/\{\{Deck\}\}/) { card.deck.name }

      # {{Type}} - note type name
      result.gsub!(/\{\{Type\}\}/) { note_type.name }

      result
    end

    # Replaces field placeholders with actual field values
    # @param template [String]
    # @return [String]
    def replace_fields(template)
      result = template.dup
      fields = note.fields_json || {}

      note_type.field_names.each do |field_name|
        value = fields[field_name.to_s] || fields[field_name.to_sym] || ""
        # Escape HTML for safety (will be enhanced with sanitization later)
        escaped_value = ERB::Util.html_escape(value)
        result.gsub!(/\{\{#{Regexp.escape(field_name)}\}\}/, escaped_value)
      end

      result
    end

    # Processes conditional blocks {{#Field}}...{{/Field}} and {{^Field}}...{{/Field}}
    # @param template [String]
    # @return [String]
    def process_conditionals(template)
      result = template.dup
      fields = note.fields_json || {}

      # Positive conditionals: {{#Field}}...{{/Field}}
      result.gsub!(/\{\{#(\w+)\}\}(.*?)\{\{\/\1\}\}/m) do |_match|
        field_name = Regexp.last_match(1)
        content = Regexp.last_match(2)
        field_value = fields[field_name.to_s] || fields[field_name.to_sym] || ""

        field_value.present? ? content : ""
      end

      # Negative conditionals: {{^Field}}...{{/Field}}
      result.gsub!(/\{\{\^(\w+)\}\}(.*?)\{\{\/\1\}\}/m) do |_match|
        field_name = Regexp.last_match(1)
        content = Regexp.last_match(2)
        field_value = fields[field_name.to_s] || fields[field_name.to_sym] || ""

        field_value.blank? ? content : ""
      end

      result
    end

    # Processes cloze deletions {{c1::text::hint}}
    # @param template [String]
    # @return [String]
    def process_cloze(template)
      result = template.dup

      # Match cloze deletions: {{c1::text::hint}} or {{c1::text}}
      result.gsub!(/\{\{c(\d+)::([^:}]+)(?::([^}]+))?\}\}/) do |_match|
        cloze_number = Regexp.last_match(1).to_i
        text = Regexp.last_match(2)
        hint = Regexp.last_match(3)

        # For now, just show the text (will be enhanced with cloze deletion UI later)
        if hint.present?
          "#{text} (#{hint})"
        else
          text
        end
      end

      result
    end
  end
end
