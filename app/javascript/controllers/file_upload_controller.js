import { Controller } from "@hotwired/stimulus"

// Drag-drop file upload zone with preview
export default class extends Controller {
  static targets = ["dropZone", "input", "fileInfo", "fileName", "fileSize", "progress"]

  triggerInput() {
    if (this.hasInputTarget) this.inputTarget.click()
  }

  handleFile() {
    const file = this.inputTarget.files[0]
    if (file) this.showFileInfo(file)
  }

  dragOver(event) {
    event.preventDefault()
    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.classList.add("border-blue-400", "bg-blue-50")
    }
  }

  dragLeave() {
    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.classList.remove("border-blue-400", "bg-blue-50")
    }
  }

  drop(event) {
    event.preventDefault()
    this.dragLeave()
    const file = event.dataTransfer.files[0]
    if (file) this.showFileInfo(file)
  }

  showFileInfo(file) {
    if (this.hasFileInfoTarget) {
      this.fileInfoTarget.classList.remove("hidden")
    }
    if (this.hasFileNameTarget) {
      this.fileNameTarget.textContent = file.name
    }
    if (this.hasFileSizeTarget) {
      const sizeMB = (file.size / (1024 * 1024)).toFixed(1)
      this.fileSizeTarget.textContent = `${sizeMB} MB`
    }
  }

  removeFile() {
    if (this.hasInputTarget) this.inputTarget.value = ""
    if (this.hasFileInfoTarget) this.fileInfoTarget.classList.add("hidden")
  }
}
