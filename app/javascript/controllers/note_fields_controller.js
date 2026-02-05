import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="note-fields"
export default class extends Controller {
  static values = {
    noteTypeId: Number
  }
  
  static targets = ["field"]
  
  connect() {
    // Controller is ready
    // Fields are rendered server-side for edit forms
  }
}
