import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input"]
  
  connect() {
    // Controller is ready
  }
  
  submit(event) {
    // Form will submit normally
    // Future: could add debouncing, auto-submit on change, etc.
  }
}
