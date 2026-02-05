import { Controller } from "@hotwired/stimulus"

// Handles flash message dismissal
export default class extends Controller {
  connect() {
    // Auto-dismiss after 5 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.remove()
  }
}
