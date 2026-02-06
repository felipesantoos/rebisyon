import { Controller } from "@hotwired/stimulus"

// Toggle collapsible sections open/closed
export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { open: { type: Boolean, default: true } }

  connect() {
    this.update()
  }

  toggle() {
    this.openValue = !this.openValue
    this.update()
  }

  update() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.toggle("hidden", !this.openValue)
    }
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = this.openValue ? "rotate(90deg)" : "rotate(0deg)"
    }
  }
}
