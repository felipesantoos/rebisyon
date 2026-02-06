import { Controller } from "@hotwired/stimulus"

// Full browser controller: selection, sorting, filtering, preview
export default class extends Controller {
  static targets = [
    "searchInput", "sidebarSearch", "tableContainer",
    "previewPanel", "previewContent", "previewFront", "previewBack",
    "cardToggle", "noteToggle"
  ]

  connect() {
    this.currentSort = { column: "sort_field", direction: "asc" }
    this.viewMode = "cards"
  }

  // Sort by column
  sort(event) {
    const column = event.currentTarget.dataset.column
    if (this.currentSort.column === column) {
      this.currentSort.direction = this.currentSort.direction === "asc" ? "desc" : "asc"
    } else {
      this.currentSort.column = column
      this.currentSort.direction = "asc"
    }
    // In mock mode, just toggle visual indicator
    const allTh = this.element.querySelectorAll("th[data-column]")
    allTh.forEach(th => th.classList.remove("text-blue-600"))
    event.currentTarget.classList.add("text-blue-600")
  }

  // Preview a card
  previewCard(event) {
    const row = event.currentTarget
    const front = row.dataset.front
    const back = row.dataset.back

    if (this.hasPreviewFrontTarget && front) {
      this.previewFrontTarget.innerHTML = front
    }
    if (this.hasPreviewBackTarget && back) {
      this.previewBackTarget.innerHTML = back
    }
  }

  // Toggle preview panel
  togglePreview() {
    if (this.hasPreviewPanelTarget) {
      this.previewPanelTarget.classList.toggle("hidden")
    }
  }

  // Filter handlers (mock - just update search bar)
  filterDeck(event) {
    event.preventDefault()
    const deck = event.currentTarget.dataset.deck
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = `deck:"${deck}"`
    }
  }

  filterTag(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = `tag:${tag}`
    }
  }

  filterNoteType(event) {
    event.preventDefault()
    const noteType = event.currentTarget.dataset.noteType
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = `note:"${noteType}"`
    }
  }

  filterSavedSearch(event) {
    event.preventDefault()
    const query = event.currentTarget.dataset.query
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = query
    }
  }

  search() {
    // In real mode, this would submit to the server
    console.log("Search:", this.searchInputTarget?.value)
  }

  // View mode toggles
  showCards() {
    this.viewMode = "cards"
    if (this.hasCardToggleTarget) {
      this.cardToggleTarget.classList.add("bg-white", "text-gray-900", "shadow-sm")
      this.cardToggleTarget.classList.remove("text-gray-600")
    }
    if (this.hasNoteToggleTarget) {
      this.noteToggleTarget.classList.remove("bg-white", "text-gray-900", "shadow-sm")
      this.noteToggleTarget.classList.add("text-gray-600")
    }
  }

  showNotes() {
    this.viewMode = "notes"
    if (this.hasNoteToggleTarget) {
      this.noteToggleTarget.classList.add("bg-white", "text-gray-900", "shadow-sm")
      this.noteToggleTarget.classList.remove("text-gray-600")
    }
    if (this.hasCardToggleTarget) {
      this.cardToggleTarget.classList.remove("bg-white", "text-gray-900", "shadow-sm")
      this.cardToggleTarget.classList.add("text-gray-600")
    }
  }
}
