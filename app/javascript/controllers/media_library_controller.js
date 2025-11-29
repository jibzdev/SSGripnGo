import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="media-library"
export default class extends Controller {
  static targets = [
    "input",
    "previewWrapper",
    "preview",
    "modal",
    "list",
    "emptyState",
    "uploadStatus"
  ]

  static values = {
    fetchUrl: String,
    uploadUrl: String
  }

  connect() {
    this.csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    this.updatePreview()
  }

  open(event) {
    event?.preventDefault()
    if (!this.hasModalTarget) return

    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    document.body.classList.add("overflow-hidden")
    this.loadImages()
  }

  close(event) {
    event?.preventDefault()
    if (!this.hasModalTarget) return

    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    document.body.classList.remove("overflow-hidden")
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  clear(event) {
    event?.preventDefault()
    if (!this.hasInputTarget) return
    this.inputTarget.value = ""
    this.updatePreview("")
  }

  async loadImages() {
    if (!this.fetchUrlValue || !this.hasListTarget) return

    this.listTarget.innerHTML = '<p class="col-span-full text-sm text-zinc-400">Loading images…</p>'
    this.toggleEmptyState(false)

    try {
      const response = await fetch(this.fetchUrlValue, {
        headers: { Accept: "application/json" }
      })
      if (!response.ok) throw new Error("Unable to load library")

      const images = await response.json()
      if (!Array.isArray(images) || images.length === 0) {
        this.listTarget.innerHTML = ""
        this.toggleEmptyState(true)
        return
      }

      this.listTarget.innerHTML = images.map((image) => this.cardTemplate(image)).join("")
    } catch (error) {
      this.listTarget.innerHTML = `<p class="col-span-full text-sm text-red-400">${error.message}</p>`
    }
  }

  select(event) {
    const url = event.currentTarget?.dataset?.url
    if (!url || !this.hasInputTarget) return

    this.inputTarget.value = url
    this.updatePreview(url)
    this.close(event)
  }

  updatePreview(value = this.hasInputTarget ? this.inputTarget.value : "") {
    if (!this.hasPreviewWrapperTarget || !this.hasPreviewTarget) return

    if (value && value.trim().length > 0) {
      this.previewWrapperTarget.classList.remove("hidden")
      this.previewTarget.src = value
    } else {
      this.previewWrapperTarget.classList.add("hidden")
      this.previewTarget.removeAttribute("src")
    }
  }

  async upload(event) {
    const file = event.target.files[0]
    if (!file || !this.uploadUrlValue) return

    const formData = new FormData()
    formData.append("image", file)

    this.setUploadStatus(`Uploading ${file.name}…`, "info")

    try {
      const response = await fetch(this.uploadUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrfToken
        },
        body: formData
      })

      if (!response.ok) {
        const error = await response.json().catch(() => ({}))
        throw new Error(error.error || "Upload failed")
      }

      this.setUploadStatus("Upload complete", "success")
      event.target.value = ""
      await this.loadImages()
    } catch (error) {
      this.setUploadStatus(error.message, "error")
    }
  }

  setUploadStatus(message, tone = "muted") {
    if (!this.hasUploadStatusTarget) return

    const toneClass = {
      success: "text-emerald-400",
      error: "text-red-400",
      info: "text-blue-300",
      muted: "text-zinc-400"
    }[tone] || "text-zinc-400"

    this.uploadStatusTarget.className = `text-xs ${toneClass}`
    this.uploadStatusTarget.textContent = message
  }

  toggleEmptyState(visible) {
    if (!this.hasEmptyStateTarget) return
    this.emptyStateTarget.classList.toggle("hidden", !visible)
  }

  cardTemplate(image) {
    const size = this.formatBytes(image.size)
    return `
      <button
        type="button"
        class="relative group rounded-xl overflow-hidden border border-white/10 bg-zinc-900 hover:border-emerald-400/50 transition focus:outline-none focus:ring-2 focus:ring-emerald-400"
        data-action="click->media-library#select"
        data-url="${image.url}"
      >
        <img src="${image.url}" alt="${image.filename}" class="h-32 w-full object-cover">
        <div class="absolute inset-x-0 bottom-0 bg-black/70 px-2 py-1">
          <p class="text-xs text-white truncate">${image.filename}</p>
          <p class="text-[11px] text-zinc-300">${size}</p>
        </div>
      </button>
    `
  }

  formatBytes(bytes) {
    if (!bytes || Number(bytes) === 0) return "0 B"
    const units = ["B", "KB", "MB", "GB"]
    const exponent = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1)
    const value = bytes / Math.pow(1024, exponent)
    return `${value.toFixed(value >= 10 || exponent === 0 ? 0 : 1)} ${units[exponent]}`
  }
}

