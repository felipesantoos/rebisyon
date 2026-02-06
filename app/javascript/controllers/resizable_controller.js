import { Controller } from "@hotwired/stimulus"

// Drag-to-resize panels (horizontal and vertical)
export default class extends Controller {
  static targets = ["panel", "handle"]

  connect() {
    this.isResizing = false
    this.boundMouseMove = this.onMouseMove.bind(this)
    this.boundMouseUp = this.onMouseUp.bind(this)
  }

  startResize(event) {
    event.preventDefault()
    this.isResizing = true
    this.startX = event.clientX
    this.startY = event.clientY

    const panel = this.panelTargets[0]
    if (panel) {
      this.startWidth = panel.offsetWidth
      this.startHeight = panel.offsetHeight
      this.minSize = parseInt(panel.dataset.resizableMin || "100", 10)
      this.maxSize = parseInt(panel.dataset.resizableMax || "600", 10)
    }

    const handle = event.currentTarget
    this.isVertical = handle.classList.contains("resize-handle-h")

    document.addEventListener("mousemove", this.boundMouseMove)
    document.addEventListener("mouseup", this.boundMouseUp)
    document.body.style.cursor = this.isVertical ? "row-resize" : "col-resize"
    document.body.style.userSelect = "none"
  }

  onMouseMove(event) {
    if (!this.isResizing) return

    const panel = this.panelTargets[0]
    if (!panel) return

    if (this.isVertical) {
      const delta = event.clientY - this.startY
      const newHeight = Math.min(Math.max(this.startHeight + delta, this.minSize), this.maxSize)
      panel.style.height = `${newHeight}px`
    } else {
      const delta = event.clientX - this.startX
      const newWidth = Math.min(Math.max(this.startWidth + delta, this.minSize), this.maxSize)
      panel.style.width = `${newWidth}px`
    }
  }

  onMouseUp() {
    this.isResizing = false
    document.removeEventListener("mousemove", this.boundMouseMove)
    document.removeEventListener("mouseup", this.boundMouseUp)
    document.body.style.cursor = ""
    document.body.style.userSelect = ""
  }

  disconnect() {
    document.removeEventListener("mousemove", this.boundMouseMove)
    document.removeEventListener("mouseup", this.boundMouseUp)
  }
}
