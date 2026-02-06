import { Controller } from "@hotwired/stimulus"

// Manages deck tree: collapse/expand with localStorage, gear dropdown, keyboard nav
export default class extends Controller {
  static targets = ["row"]

  connect() {
    this.collapsed = this.loadCollapsedState()
    this.restoreCollapsedState()
  }

  toggleCollapse(event) {
    const deckId = event.currentTarget.dataset.deckId
    const arrow = event.currentTarget.querySelector("svg")

    if (this.collapsed.has(deckId)) {
      this.collapsed.delete(deckId)
      if (arrow) arrow.style.transform = "rotate(90deg)"
    } else {
      this.collapsed.add(deckId)
      if (arrow) arrow.style.transform = "rotate(0deg)"
    }

    this.updateChildVisibility(deckId)
    this.saveCollapsedState()
  }

  updateChildVisibility(parentId) {
    const isCollapsed = this.collapsed.has(parentId)
    let hide = isCollapsed

    this.rowTargets.forEach((row) => {
      const rowDeckId = row.dataset.deckId
      if (rowDeckId === parentId) return

      // Check if this row is a descendant by looking at subsequent rows
      const parentRow = this.rowTargets.find(r => r.dataset.deckId === parentId)
      if (!parentRow) return

      const parentDepth = parseInt(parentRow.dataset.depth, 10)
      const rowDepth = parseInt(row.dataset.depth, 10)
      const parentIndex = this.rowTargets.indexOf(parentRow)
      const rowIndex = this.rowTargets.indexOf(row)

      if (rowIndex > parentIndex && rowDepth > parentDepth) {
        // Check if any ancestor between parent and this row is collapsed
        let shouldHide = false
        for (let i = parentIndex; i < rowIndex; i++) {
          const checkRow = this.rowTargets[i]
          const checkDepth = parseInt(checkRow.dataset.depth, 10)
          if (checkDepth < rowDepth && this.collapsed.has(checkRow.dataset.deckId)) {
            shouldHide = true
            break
          }
        }
        row.classList.toggle("hidden", shouldHide)
      }
    })
  }

  restoreCollapsedState() {
    this.collapsed.forEach((deckId) => {
      this.updateChildVisibility(deckId)
      // Update arrow
      const btn = this.element.querySelector(`[data-deck-id="${deckId}"] svg`)
      if (btn) btn.style.transform = "rotate(0deg)"
    })
  }

  loadCollapsedState() {
    try {
      const stored = localStorage.getItem("deckTreeCollapsed")
      return stored ? new Set(JSON.parse(stored)) : new Set()
    } catch {
      return new Set()
    }
  }

  saveCollapsedState() {
    try {
      localStorage.setItem("deckTreeCollapsed", JSON.stringify([...this.collapsed]))
    } catch {
      // Ignore storage errors
    }
  }
}
