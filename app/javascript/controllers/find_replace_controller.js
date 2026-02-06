import { Controller } from "@hotwired/stimulus"

// Find and replace functionality
export default class extends Controller {
  static targets = ["findInput", "replaceInput"]

  replace() {
    const find = this.hasFindInputTarget ? this.findInputTarget.value : ""
    const replace = this.hasReplaceInputTarget ? this.replaceInputTarget.value : ""
    console.log(`Find: "${find}", Replace: "${replace}"`)
  }
}
