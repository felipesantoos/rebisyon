import { Controller } from "@hotwired/stimulus"

// Show/hide tab panels
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: { type: Number, default: 0 } }

  connect() {
    this.showTab(this.activeValue)
  }

  select(event) {
    const index = parseInt(event.currentTarget.dataset.tabIndex, 10)
    this.showTab(index)
  }

  showTab(index) {
    this.tabTargets.forEach((tab, i) => {
      if (i === index) {
        tab.classList.add("tab-active")
        tab.classList.remove("tab-inactive")
      } else {
        tab.classList.remove("tab-active")
        tab.classList.add("tab-inactive")
      }
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })

    this.activeValue = index
  }
}
