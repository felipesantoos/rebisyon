import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="media-upload"
export default class extends Controller {
  static values = {
    fieldName: String
  }

  static targets = ["fileInput", "dropZone", "textarea", "mediaPreview"]

  connect() {
    // Controller is ready
  }

  // Triggers file input click
  triggerFileInput() {
    this.fileInputTarget.click()
  }

  // Handles file selection from input
  handleFileSelect(event) {
    const files = Array.from(event.target.files)
    files.forEach(file => this.uploadFile(file))
  }

  // Handles drag over
  handleDragOver(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropZoneTarget.classList.add("border-blue-500", "bg-blue-50")
  }

  // Handles drag leave
  handleDragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropZoneTarget.classList.remove("border-blue-500", "bg-blue-50")
  }

  // Handles file drop
  handleDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropZoneTarget.classList.remove("border-blue-500", "bg-blue-50")

    const files = Array.from(event.dataTransfer.files)
    files.forEach(file => this.uploadFile(file))
  }

  // Uploads a file to the server
  async uploadFile(file) {
    // Validate file size (100MB max)
    const maxSize = 100 * 1024 * 1024
    if (file.size > maxSize) {
      alert(`File size exceeds 100MB limit. File: ${file.name}`)
      return
    }

    // Validate file type
    const allowedTypes = [
      "image/jpeg", "image/png", "image/gif", "image/webp",
      "audio/mpeg", "audio/ogg", "audio/wav",
      "video/mp4", "video/webm"
    ]

    if (!allowedTypes.includes(file.type)) {
      alert(`File type not supported: ${file.type}. File: ${file.name}`)
      return
    }

    // Show loading state
    const loadingDiv = this.createLoadingPreview(file.name)
    this.mediaPreviewTarget.appendChild(loadingDiv)

    // Create form data
    const formData = new FormData()
    formData.append("file", file)

    try {
      const response = await fetch("/media", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: formData
      })

      if (!response.ok) {
        const error = await response.json()
        throw new Error(error.error || "Upload failed")
      }

      const data = await response.json()

      // Remove loading, add media preview
      loadingDiv.remove()
      this.addMediaPreview(data, file)

      // Insert media reference into textarea
      this.insertMediaReference(data)
    } catch (error) {
      console.error("Upload error:", error)
      loadingDiv.remove()
      alert(`Upload failed: ${error.message}`)
    }
  }

  // Creates a loading preview
  createLoadingPreview(filename) {
    const div = document.createElement("div")
    div.className = "flex items-center space-x-2 p-2 bg-gray-100 rounded"
    div.innerHTML = `
      <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
      <span class="text-sm text-gray-600">Uploading ${filename}...</span>
    `
    return div
  }

  // Adds media preview to the UI
  addMediaPreview(mediaData, file) {
    const div = document.createElement("div")
    div.className = "flex items-center space-x-2 p-2 bg-gray-50 rounded border border-gray-200"
    div.dataset.mediaId = mediaData.id

    if (mediaData.mime_type.startsWith("image/")) {
      div.innerHTML = `
        <img src="${mediaData.url}" alt="${mediaData.filename}" class="h-12 w-12 object-cover rounded">
        <span class="flex-1 text-sm text-gray-700">${mediaData.filename}</span>
        <button type="button" class="text-red-600 hover:text-red-700 text-sm" data-action="click->media-upload#removeMedia">
          Remove
        </button>
      `
    } else {
      div.innerHTML = `
        <div class="h-12 w-12 bg-gray-200 rounded flex items-center justify-center">
          <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3"/>
          </svg>
        </div>
        <span class="flex-1 text-sm text-gray-700">${mediaData.filename}</span>
        <button type="button" class="text-red-600 hover:text-red-700 text-sm" data-action="click->media-upload#removeMedia">
          Remove
        </button>
      `
    }

    this.mediaPreviewTarget.appendChild(div)
  }

  // Inserts media reference into textarea
  insertMediaReference(mediaData) {
    const textarea = this.textareaTarget
    const cursorPos = textarea.selectionStart
    const textBefore = textarea.value.substring(0, cursorPos)
    const textAfter = textarea.value.substring(cursorPos)

    // Insert media reference: <img src="filename.jpg"> or [sound:filename.mp3]
    let mediaRef
    if (mediaData.mime_type.startsWith("image/")) {
      mediaRef = `<img src="${mediaData.filename}">`
    } else if (mediaData.mime_type.startsWith("audio/")) {
      mediaRef = `[sound:${mediaData.filename}]`
    } else if (mediaData.mime_type.startsWith("video/")) {
      mediaRef = `<video src="${mediaData.filename}"></video>`
    } else {
      mediaRef = mediaData.filename
    }

    textarea.value = textBefore + mediaRef + textAfter
    textarea.dispatchEvent(new Event("input", { bubbles: true }))
    
    // Set cursor position after inserted text
    const newPos = cursorPos + mediaRef.length
    textarea.setSelectionRange(newPos, newPos)
    textarea.focus()
  }

  // Removes media preview
  removeMedia(event) {
    const mediaDiv = event.target.closest("[data-media-id]")
    if (mediaDiv) {
      mediaDiv.remove()
    }
  }
}
