import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]
  static values = { rating: { type: Number, default: 0 } }

  connect() {
    this.render()
  }

  select(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.ratingValue = value
    this.inputTarget.value = value
    this.render()
  }

  hover(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.highlight(value)
  }

  reset() {
    this.render()
  }

  highlight(count) {
    this.starTargets.forEach((star, index) => {
      star.classList.toggle("text-yellow-400", index < count)
      star.classList.toggle("text-gray-300", index >= count)
    })
  }

  render() {
    this.highlight(this.ratingValue)
  }
}
