import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="note-type-selector"
export default class extends Controller {
  static targets = ["fieldsContainer"]
  
  connect() {
    // Controller is ready
  }
  
  updateFields(event) {
    const noteTypeId = event.target.value
    
    if (!noteTypeId) {
      this.clearFields()
      return
    }
    
    // For Phase 3: Reload the form page with the selected note type
    // This will cause the server to render the appropriate fields
    const currentUrl = new URL(window.location.href)
    currentUrl.searchParams.set("note_type_id", noteTypeId)
    
    // Reload the page with the new note type
    window.location.href = currentUrl.toString()
  }
  
  renderFields(fields) {
    const container = this.element.closest("form").querySelector("[data-controller='note-fields']")
    if (!container) return
    
    // Clear existing fields
    container.innerHTML = ""
    
    // Render new fields
    fields.forEach((fieldName, index) => {
      const fieldDiv = document.createElement("div")
      fieldDiv.className = "mb-4"
      
      const label = document.createElement("label")
      label.className = "block text-sm font-medium text-gray-700 mb-1"
      label.textContent = fieldName
      label.setAttribute("for", `note_${fieldName}`)
      
      const textarea = document.createElement("textarea")
      textarea.name = `note[${fieldName}]`
      textarea.id = `note_${fieldName}`
      textarea.rows = 4
      textarea.className = "w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
      textarea.setAttribute("data-note-fields-target", "field")
      
      fieldDiv.appendChild(label)
      fieldDiv.appendChild(textarea)
      container.appendChild(fieldDiv)
    })
  }
  
  clearFields() {
    const container = this.element.closest("form").querySelector("[data-controller='note-fields']")
    if (!container) return
    
    container.innerHTML = '<div class="text-sm text-gray-500 italic">Select a note type to see fields</div>'
  }
}
