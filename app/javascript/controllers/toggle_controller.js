import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "label"]

  toggle() {
    const checkbox = this.checkboxTarget
    checkbox.checked = !checkbox.checked
    this.updateLabel()
  }

  updateLabel() {
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = this.checkboxTarget.checked ? "Enabled" : "Disabled"
    }
  }
}
