import { Controller } from "@hotwired/stimulus"

// Multi-row selection with click, Ctrl+click, Shift+click
export default class extends Controller {
  static targets = ["table", "row", "checkbox", "selectAll", "selectionCount"]

  connect() {
    this.lastSelectedIndex = -1
  }

  selectRow(event) {
    // Don't trigger on checkbox clicks (handled separately)
    if (event.target.type === "checkbox") return

    const row = event.currentTarget
    const index = parseInt(row.dataset.index, 10)

    if (event.shiftKey && this.lastSelectedIndex >= 0) {
      // Shift+click: select range
      const start = Math.min(this.lastSelectedIndex, index)
      const end = Math.max(this.lastSelectedIndex, index)
      this.rowTargets.forEach((r, i) => {
        if (i >= start && i <= end) {
          r.classList.add("selected")
          this.checkboxTargets[i].checked = true
        }
      })
    } else if (event.ctrlKey || event.metaKey) {
      // Ctrl+click: toggle single
      row.classList.toggle("selected")
      this.checkboxTargets[index].checked = row.classList.contains("selected")
    } else {
      // Normal click: select only this
      this.rowTargets.forEach((r, i) => {
        r.classList.remove("selected")
        this.checkboxTargets[i].checked = false
      })
      row.classList.add("selected")
      this.checkboxTargets[index].checked = true
    }

    this.lastSelectedIndex = index
    this.updateCount()
  }

  toggleRow(event) {
    event.stopPropagation()
    const checkbox = event.currentTarget
    const row = checkbox.closest("tr")
    row.classList.toggle("selected", checkbox.checked)
    this.updateCount()
  }

  toggleAll() {
    const checked = this.selectAllTarget.checked
    this.rowTargets.forEach((row, i) => {
      row.classList.toggle("selected", checked)
      this.checkboxTargets[i].checked = checked
    })
    this.updateCount()
  }

  updateCount() {
    const selected = this.rowTargets.filter(r => r.classList.contains("selected")).length
    const total = this.rowTargets.length
    if (this.hasSelectionCountTarget) {
      this.selectionCountTarget.textContent = `${selected} of ${total} selected`
    }
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = selected === total && total > 0
      this.selectAllTarget.indeterminate = selected > 0 && selected < total
    }
  }
}
