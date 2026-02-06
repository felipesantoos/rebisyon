import { Controller } from "@hotwired/stimulus"

// Enhanced study controller with timer, keyboard shortcuts, progress updates
export default class extends Controller {
  static values = {
    cardId: Number,
    deckId: Number,
    showAnswerUrl: String,
    answerUrl: String
  }

  static targets = ["showAnswerBtn", "ratingButtons", "answerForm", "cardId", "timeMs", "front", "back", "timer"]

  connect() {
    this.startTime = Date.now()
    this.answerShown = false
    this.rating = null
    this.timerInterval = null

    this.boundKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)

    this.startTimer()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
    if (this.timerInterval) clearInterval(this.timerInterval)
  }

  startTimer() {
    if (this.hasTimerTarget) {
      this.timerInterval = setInterval(() => {
        const elapsed = Math.floor((Date.now() - this.startTime) / 1000)
        const mins = Math.floor(elapsed / 60)
        const secs = elapsed % 60
        this.timerTarget.textContent = `${mins}:${secs.toString().padStart(2, "0")}`
      }, 1000)
    }
  }

  handleKeydown(event) {
    if (event.target.tagName === "INPUT" || event.target.tagName === "TEXTAREA") return

    // Ctrl+Z for undo
    if (event.ctrlKey && event.key === "z") {
      event.preventDefault()
      this.undo()
      return
    }

    // E for edit
    if (event.key === "e" || event.key === "E") {
      event.preventDefault()
      return
    }

    switch (event.key) {
      case " ":
        event.preventDefault()
        if (!this.answerShown) {
          this.showAnswer()
        } else {
          // Space rates Good when answer is shown
          this.rate({ currentTarget: { dataset: { rating: "3" } } })
        }
        break
      case "1":
        if (this.answerShown) { event.preventDefault(); this.rate({ currentTarget: { dataset: { rating: "1" } } }) }
        break
      case "2":
        if (this.answerShown) { event.preventDefault(); this.rate({ currentTarget: { dataset: { rating: "2" } } }) }
        break
      case "3":
        if (this.answerShown) { event.preventDefault(); this.rate({ currentTarget: { dataset: { rating: "3" } } }) }
        break
      case "4":
        if (this.answerShown) { event.preventDefault(); this.rate({ currentTarget: { dataset: { rating: "4" } } }) }
        break
    }
  }

  showAnswer() {
    this.answerShown = true
    this.answerShownAt = Date.now()

    // Hide front, show back
    if (this.hasFrontTarget) this.frontTarget.classList.add("hidden")
    if (this.hasBackTarget) this.backTarget.classList.remove("hidden")

    // Toggle buttons
    if (this.hasShowAnswerBtnTarget) this.showAnswerBtnTarget.classList.add("hidden")
    if (this.hasRatingButtonsTarget) this.ratingButtonsTarget.classList.remove("hidden")

    // If we have a server-side show answer URL, fetch it
    if (this.showAnswerUrlValue && this.cardIdValue) {
      fetch(this.showAnswerUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "",
          "Accept": "text/vnd.turbo-stream.html"
        },
        body: new URLSearchParams({ card_id: this.cardIdValue })
      })
        .then(response => response.text())
        .then(html => { if (typeof Turbo !== "undefined") Turbo.renderStreamMessage(html) })
        .catch(error => console.error("Error showing answer:", error))
    }
  }

  rate(event) {
    const rating = parseInt(event.currentTarget.dataset.rating, 10)
    this.rating = rating

    const timeMs = this.answerShownAt
      ? Date.now() - this.answerShownAt
      : Date.now() - this.startTime

    // If we have a real form, submit it
    if (this.hasAnswerFormTarget) {
      if (this.hasCardIdTarget) this.cardIdTarget.value = this.cardIdValue
      if (this.hasTimeMsTarget) this.timeMsTarget.value = timeMs

      const ratingInput = document.createElement("input")
      ratingInput.type = "hidden"
      ratingInput.name = "rating"
      ratingInput.value = rating
      this.answerFormTarget.appendChild(ratingInput)
      this.answerFormTarget.requestSubmit()
    } else {
      // Mock mode: just reload
      window.location.reload()
    }
  }

  undo() {
    // In real mode, would POST to undo endpoint
    console.log("Undo triggered")
  }
}
