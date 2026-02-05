module ApplicationHelper
  # Generates a sortable column header link
  # @param name [String] Display name for the column
  # @param column [String] Database column to sort by
  # @param path [String, Symbol] Path helper method (default: :notes_path)
  # @return [String] HTML link for sortable column
  def sortable_column(name, column, path: :notes_path)
    direction = params[:direction] == "asc" ? "desc" : "asc"
    current_sort = params[:sort]
    link_class = "hover:text-gray-700"
    link_class += " font-semibold text-gray-900" if current_sort == column
    
    # Preserve existing filter parameters
    link_params = params.permit(:search, :deck_id, :note_type_id, :tag, :marked).merge(
      sort: column,
      direction: direction
    )
    
    link_to send(path, link_params), class: link_class do
      content = name.html_safe
      if current_sort == column
        content += " <span class='ml-1'>#{params[:direction] == 'asc' ? '↑' : '↓'}</span>".html_safe
      end
      content
    end
  end
end
