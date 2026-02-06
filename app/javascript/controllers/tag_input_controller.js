import { Controller } from "@hotwired/stimulus"

// Tag chips with autocomplete, add/remove, keyboard nav
export default class extends Controller {
  static targets = ["container", "input", "chip", "suggestions"]
  static values = { suggestions: { type: Array, default: [] } }

  connect() {
    this.selectedSuggestion = -1
  }

  focusInput() {
    if (this.hasInputTarget) this.inputTarget.focus()
  }

  handleKeydown(event) {
    switch (event.key) {
      case "Enter":
      case "Tab":
        event.preventDefault()
        if (this.selectedSuggestion >= 0) {
          this.selectSuggestion(this.selectedSuggestion)
        } else if (this.inputTarget.value.trim()) {
          this.addTag(this.inputTarget.value.trim())
        }
        break
      case "Backspace":
        if (this.inputTarget.value === "" && this.chipTargets.length > 0) {
          this.removeLastTag()
        }
        break
      case "ArrowDown":
        event.preventDefault()
        this.navigateSuggestions(1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.navigateSuggestions(-1)
        break
      case "Escape":
        this.hideSuggestions()
        break
    }
  }

  handleInput() {
    const query = this.inputTarget.value.trim().toLowerCase()
    if (query.length === 0) {
      this.hideSuggestions()
      return
    }

    const existing = this.chipTargets.map(c => c.textContent.trim().replace("×", "").trim())
    const matches = this.suggestionsValue.filter(tag =>
      tag.toLowerCase().includes(query) && !existing.includes(tag)
    ).slice(0, 8)

    if (matches.length > 0) {
      this.showSuggestions(matches)
    } else {
      this.hideSuggestions()
    }
  }

  showSuggestions(matches) {
    if (!this.hasSuggestionsTarget) return
    this.selectedSuggestion = -1
    this.suggestionsTarget.innerHTML = matches.map((tag, i) =>
      `<div class="px-3 py-1.5 text-sm cursor-pointer hover:bg-blue-50" data-index="${i}" data-action="click->tag-input#clickSuggestion">${tag}</div>`
    ).join("")
    this.suggestionsTarget.classList.remove("hidden")
  }

  hideSuggestions() {
    if (this.hasSuggestionsTarget) {
      this.suggestionsTarget.classList.add("hidden")
      this.selectedSuggestion = -1
    }
  }

  navigateSuggestions(direction) {
    if (!this.hasSuggestionsTarget) return
    const items = this.suggestionsTarget.children
    if (items.length === 0) return

    // Remove highlight
    if (this.selectedSuggestion >= 0 && items[this.selectedSuggestion]) {
      items[this.selectedSuggestion].classList.remove("bg-blue-100")
    }

    this.selectedSuggestion += direction
    if (this.selectedSuggestion < 0) this.selectedSuggestion = items.length - 1
    if (this.selectedSuggestion >= items.length) this.selectedSuggestion = 0

    items[this.selectedSuggestion].classList.add("bg-blue-100")
  }

  selectSuggestion(index) {
    const items = this.suggestionsTarget.children
    if (items[index]) {
      this.addTag(items[index].textContent.trim())
    }
  }

  clickSuggestion(event) {
    this.addTag(event.currentTarget.textContent.trim())
  }

  addTag(tag) {
    if (!tag) return
    const existing = this.chipTargets.map(c => c.textContent.trim().replace("×", "").trim())
    if (existing.includes(tag)) return

    const chipHtml = `<span class="tag-chip" data-tag-input-target="chip">
      ${tag}
      <button type="button" data-action="click->tag-input#removeTag" class="ml-1 text-gray-400 hover:text-gray-600">&times;</button>
      <input type="hidden" name="${this.getFieldName()}" value="${tag}">
    </span>`

    this.inputTarget.insertAdjacentHTML("beforebegin", chipHtml)
    this.inputTarget.value = ""
    this.inputTarget.placeholder = ""
    this.hideSuggestions()
  }

  removeTag(event) {
    const chip = event.currentTarget.closest("[data-tag-input-target='chip']")
    if (chip) chip.remove()
    if (this.chipTargets.length === 0 && this.hasInputTarget) {
      this.inputTarget.placeholder = "Add tags..."
    }
  }

  removeLastTag() {
    const lastChip = this.chipTargets[this.chipTargets.length - 1]
    if (lastChip) lastChip.remove()
    if (this.chipTargets.length === 0 && this.hasInputTarget) {
      this.inputTarget.placeholder = "Add tags..."
    }
  }

  getFieldName() {
    const hidden = this.element.querySelector("input[type='hidden']")
    return hidden ? hidden.name : "tags[]"
  }
}
