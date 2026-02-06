import { Controller } from "@hotwired/stimulus"

// Live preview of front/back templates with field placeholder replacement
export default class extends Controller {
  static targets = ["frontTemplate", "backTemplate", "styling", "preview"]

  connect() {
    this.updatePreview()
  }

  updatePreview() {
    const front = this.hasFrontTemplateTarget ? this.frontTemplateTarget.value : ""
    const back = this.hasBackTemplateTarget ? this.backTemplateTarget.value : ""
    const styling = this.hasStylingTarget ? this.stylingTarget.value : ""

    const fields = this.getFieldValues()
    const renderedFront = this.renderTemplate(front, fields)
    const renderedBack = this.renderTemplate(back, fields).replace("{{FrontSide}}", renderedFront)

    if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = `
        <style>${this.escapeHtml(styling)}</style>
        <div class="preview-front">
          <h4 class="text-xs font-medium text-gray-500 mb-2">Front</h4>
          <div>${renderedFront}</div>
        </div>
        <hr class="my-3">
        <div class="preview-back">
          <h4 class="text-xs font-medium text-gray-500 mb-2">Back</h4>
          <div>${renderedBack}</div>
        </div>
      `
    }
  }

  renderTemplate(template, fields) {
    let result = template

    // Replace field placeholders {{FieldName}}
    for (const [name, value] of Object.entries(fields)) {
      const regex = new RegExp(`\\{\\{${this.escapeRegex(name)}\\}\\}`, "g")
      result = result.replace(regex, value || "")
    }

    // Process conditionals {{#Field}}...{{/Field}}
    for (const [name, value] of Object.entries(fields)) {
      const condRegex = new RegExp(
        `\\{\\{#${this.escapeRegex(name)}\\}\\}([\\s\\S]*?)\\{\\{/${this.escapeRegex(name)}\\}\\}`,
        "g"
      )
      result = result.replace(condRegex, value ? "$1" : "")
    }

    // Process negative conditionals {{^Field}}...{{/Field}}
    for (const [name, value] of Object.entries(fields)) {
      const negRegex = new RegExp(
        `\\{\\{\\^${this.escapeRegex(name)}\\}\\}([\\s\\S]*?)\\{\\{/${this.escapeRegex(name)}\\}\\}`,
        "g"
      )
      result = result.replace(negRegex, value ? "" : "$1")
    }

    return result
  }

  getFieldValues() {
    const fields = {}
    const fieldInputs = document.querySelectorAll("[data-template-field]")
    fieldInputs.forEach((input) => {
      fields[input.dataset.templateField] = input.value || `(${input.dataset.templateField})`
    })

    // If no field inputs found, use sample values from data attribute
    if (Object.keys(fields).length === 0 && this.element.dataset.sampleFields) {
      try {
        const sample = JSON.parse(this.element.dataset.sampleFields)
        for (const [name, value] of Object.entries(sample)) {
          fields[name] = value || `(${name})`
        }
      } catch (e) {
        // ignore parse errors
      }
    }

    return fields
  }

  escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
