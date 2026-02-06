import { Controller } from "@hotwired/stimulus"

// Rich text toolbar for note field editing
export default class extends Controller {
  static targets = ["textarea"]

  bold() {
    this.wrapSelection("<b>", "</b>")
  }

  italic() {
    this.wrapSelection("<i>", "</i>")
  }

  underline() {
    this.wrapSelection("<u>", "</u>")
  }

  cloze() {
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const text = textarea.value

    // Find highest existing cloze number
    const matches = text.match(/\{\{c(\d+)::/g) || []
    const maxNum = matches.reduce((max, m) => {
      const num = parseInt(m.match(/\d+/)[0], 10)
      return Math.max(max, num)
    }, 0)

    const clozeNum = maxNum + 1
    const selected = text.substring(start, end) || "..."

    const replacement = `{{c${clozeNum}::${selected}}}`
    textarea.value = text.substring(0, start) + replacement + text.substring(end)
    textarea.focus()
    textarea.selectionStart = start
    textarea.selectionEnd = start + replacement.length
  }

  attach() {
    // Trigger file upload
    const fileInput = document.createElement("input")
    fileInput.type = "file"
    fileInput.accept = "image/*,audio/*,video/*"
    fileInput.addEventListener("change", () => {
      if (fileInput.files.length > 0) {
        console.log("Attach:", fileInput.files[0].name)
      }
    })
    fileInput.click()
  }

  wrapSelection(before, after) {
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const text = textarea.value
    const selected = text.substring(start, end)

    textarea.value = text.substring(0, start) + before + selected + after + text.substring(end)
    textarea.focus()
    textarea.selectionStart = start + before.length
    textarea.selectionEnd = start + before.length + selected.length
  }
}
