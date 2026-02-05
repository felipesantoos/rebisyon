import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tag-input"
export default class extends Controller {
  connect() {
    // Basic tag input - just handles comma-separated input
    // Future: could add autocomplete, tag chips, etc.
  }
  
  // Could add methods for:
  // - Autocomplete suggestions
  // - Tag chip visualization
  // - Tag removal
}
