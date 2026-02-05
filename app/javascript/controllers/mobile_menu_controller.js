import { Controller } from "@hotwired/stimulus"

// Handles mobile sidebar menu toggling
export default class extends Controller {
  toggle() {
    // Toggle mobile sidebar visibility
    const sidebar = document.querySelector("aside")
    if (sidebar) {
      sidebar.classList.toggle("hidden")
      sidebar.classList.toggle("fixed")
      sidebar.classList.toggle("inset-0")
      sidebar.classList.toggle("z-50")
    }
  }
}
