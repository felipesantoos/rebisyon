import { Controller } from "@hotwired/stimulus"

// Manages add/remove/reorder of fields in the note type form
export default class extends Controller {
  static targets = ["container", "template", "field"]

  addField() {
    const content = this.templateTarget.innerHTML
    const index = this.fieldTargets.length
    const html = content.replace(/NEW_INDEX/g, index)
    this.containerTarget.insertAdjacentHTML("beforeend", html)
    this.updateOrdinals()
  }

  removeField(event) {
    const field = event.target.closest("[data-fields-editor-target='field']")
    if (this.fieldTargets.length <= 1) return

    field.remove()
    this.updateOrdinals()
  }

  moveUp(event) {
    const field = event.target.closest("[data-fields-editor-target='field']")
    const prev = field.previousElementSibling
    if (prev && prev.dataset.fieldsEditorTarget === "field") {
      this.containerTarget.insertBefore(field, prev)
      this.updateOrdinals()
    }
  }

  moveDown(event) {
    const field = event.target.closest("[data-fields-editor-target='field']")
    const next = field.nextElementSibling
    if (next && next.dataset.fieldsEditorTarget === "field") {
      this.containerTarget.insertBefore(next, field)
      this.updateOrdinals()
    }
  }

  updateOrdinals() {
    this.fieldTargets.forEach((field, index) => {
      const ordInput = field.querySelector("[data-ordinal]")
      if (ordInput) {
        ordInput.value = index
      }
    })
  }
}
