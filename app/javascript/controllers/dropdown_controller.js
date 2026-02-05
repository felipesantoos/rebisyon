import { Controller } from "@hotwired/stimulus"

// Handles dropdown menu toggling
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close on outside click
    this.boundClose = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this.boundClose)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
