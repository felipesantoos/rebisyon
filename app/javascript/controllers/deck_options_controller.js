import { Controller } from "@hotwired/stimulus"

// Deck options preset management
export default class extends Controller {
  static targets = ["presetSelect"]

  switchPreset() {
    console.log("Switching to preset:", this.presetSelectTarget.value)
  }

  addPreset() {
    const name = prompt("Preset name:")
    if (name) console.log("Add preset:", name)
  }

  clonePreset() {
    const name = prompt("Clone as:", this.presetSelectTarget.selectedOptions[0]?.text + " (copy)")
    if (name) console.log("Clone preset:", name)
  }

  renamePreset() {
    const name = prompt("New name:", this.presetSelectTarget.selectedOptions[0]?.text)
    if (name) console.log("Rename preset:", name)
  }

  removePreset() {
    if (confirm("Remove this preset?")) {
      console.log("Remove preset:", this.presetSelectTarget.value)
    }
  }

  save() {
    console.log("Saving deck options...")
  }

  revert() {
    if (confirm("Revert all changes?")) {
      window.location.reload()
    }
  }
}
