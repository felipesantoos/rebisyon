import { Controller } from "@hotwired/stimulus"

// Open/close modal dialogs with Escape key and click-outside support
export default class extends Controller {
  static targets = ["dialog", "backdrop"]

  connect() {
    this.boundKeydown = this.handleKeydown.bind(this)
  }

  open() {
    this.dialogTarget.classList.remove("hidden")
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("hidden")
    }
    document.addEventListener("keydown", this.boundKeydown)
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.dialogTarget.classList.add("hidden")
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("hidden")
    }
    document.removeEventListener("keydown", this.boundKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
    document.body.classList.remove("overflow-hidden")
  }
}
