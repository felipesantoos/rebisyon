import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="study"
export default class extends Controller {
  static values = {
    cardId: Number,
    deckId: Number,
    showAnswerUrl: String,
    answerUrl: String
  }

  static targets = ["showAnswerBtn", "ratingButtons", "answerForm", "cardId", "timeMs"]

  connect() {
    this.startTime = Date.now()
    this.rating = null
    
    // Add keyboard event listeners
    document.addEventListener("keydown", this.handleKeyDown.bind(this))
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeyDown.bind(this))
  }

  // Handles keyboard shortcuts
  handleKeyDown(event) {
    // Don't handle if user is typing in an input
    if (event.target.tagName === "INPUT" || event.target.tagName === "TEXTAREA") {
      return
    }

    switch (event.key) {
      case " ":
        // Space to show answer
        event.preventDefault()
        if (this.showAnswerBtnTarget && !this.showAnswerBtnTarget.classList.contains("hidden")) {
          this.showAnswer()
        }
        break
      case "1":
        event.preventDefault()
        this.setRating(1)
        this.submitAnswer()
        break
      case "2":
        event.preventDefault()
        this.setRating(2)
        this.submitAnswer()
        break
      case "3":
        event.preventDefault()
        this.setRating(3)
        this.submitAnswer()
        break
      case "4":
        event.preventDefault()
        this.setRating(4)
        this.submitAnswer()
        break
    }
  }

  // Shows the answer side of the card
  showAnswer() {
    if (!this.showAnswerUrlValue) return

    // Hide show answer button
    if (this.showAnswerBtnTarget) {
      this.showAnswerBtnTarget.classList.add("hidden")
    }

    // Show rating buttons
    if (this.ratingButtonsTarget) {
      this.ratingButtonsTarget.classList.remove("hidden")
    }

    // Record time taken to show answer
    this.answerShownAt = Date.now()

    // Make request to show answer (updates UI via Turbo Stream)
    fetch(this.showAnswerUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: new URLSearchParams({
        card_id: this.cardIdValue
      })
    })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
      })
      .catch(error => {
        console.error("Error showing answer:", error)
      })
  }

  // Sets the rating
  setRating(rating) {
    this.rating = rating
  }

  // Submits the answer
  submitAnswer(event) {
    if (event) {
      event.preventDefault()
    }

    if (!this.rating) {
      console.error("No rating set")
      return
    }

    // Calculate time taken
    const timeMs = this.answerShownAt 
      ? Date.now() - this.answerShownAt 
      : Date.now() - this.startTime

    // Update hidden fields
    if (this.cardIdTarget) {
      this.cardIdTarget.value = this.cardIdValue
    }
    if (this.timeMsTarget) {
      this.timeMsTarget.value = timeMs
    }

    // Submit form
    if (this.answerFormTarget) {
      // Create a hidden input for rating
      const ratingInput = document.createElement("input")
      ratingInput.type = "hidden"
      ratingInput.name = "rating"
      ratingInput.value = this.rating
      this.answerFormTarget.appendChild(ratingInput)

      // Submit via Turbo
      this.answerFormTarget.requestSubmit()
    }
  }
}
