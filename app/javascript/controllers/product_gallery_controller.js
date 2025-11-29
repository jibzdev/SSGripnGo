import { Controller } from "@hotwired/stimulus"

const ESCAPES = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': "&quot;",
  "'": "&#39;"
}

const escapeHtml = (value) =>
  String(value || "").replace(/[&<>"']/g, (char) => ESCAPES[char])

// Connects to data-controller="product-gallery"
export default class extends Controller {
  static targets = [
    "list",
    "emptyState",
    "heroInput",
    "inputs",
    "urlInput",
    "libraryModal",
    "libraryList",
    "libraryEmpty",
    "libraryUploadStatus"
  ]

  static values = {
    images: Array,
    fetchUrl: String,
    uploadUrl: String
  }

  connect() {
    this.images = Array.isArray(this.imagesValue)
      ? this.imagesValue.filter((url) => url && url.trim().length > 0)
      : []
    this.dragIndex = null
    this.csrfToken = document
      .querySelector("meta[name='csrf-token']")
      ?.getAttribute("content")
    this.render()
  }

  addFromUrl(event) {
    event.preventDefault()
    if (!this.hasUrlInputTarget) return
    const url = this.urlInputTarget.value.trim()
    if (!url) return
    this.addImage(url)
    this.urlInputTarget.value = ""
  }

  addImage(url, { prepend = false } = {}) {
    const sanitized = url?.trim()
    if (!sanitized) return

    const existingIndex = this.images.indexOf(sanitized)
    if (existingIndex >= 0) {
      this.images.splice(existingIndex, 1)
    }

    if (prepend) {
      this.images.unshift(sanitized)
    } else {
      this.images.push(sanitized)
    }

    this.render()
  }

  removeImage(event) {
    event.preventDefault()
    const index = Number(event.params.index)
    if (Number.isNaN(index)) return
    this.images.splice(index, 1)
    this.render()
  }

  setCover(event) {
    event.preventDefault()
    const index = Number(event.params.index)
    if (Number.isNaN(index) || index === 0) return
    const [image] = this.images.splice(index, 1)
    this.images.unshift(image)
    this.render()
  }

  moveUp(event) {
    event.preventDefault()
    const index = Number(event.params.index)
    if (Number.isNaN(index) || index <= 0) return
    ;[this.images[index - 1], this.images[index]] = [
      this.images[index],
      this.images[index - 1]
    ]
    this.render()
  }

  moveDown(event) {
    event.preventDefault()
    const index = Number(event.params.index)
    if (Number.isNaN(index) || index >= this.images.length - 1) return
    ;[this.images[index + 1], this.images[index]] = [
      this.images[index],
      this.images[index + 1]
    ]
    this.render()
  }

  dragStart(event) {
    this.dragIndex = Number(event.currentTarget.dataset.index)
    event.dataTransfer.effectAllowed = "move"
    event.currentTarget.classList.add("opacity-50")
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  drop(event) {
    event.preventDefault()
    const targetIndex = Number(event.currentTarget.dataset.index)
    if (Number.isNaN(targetIndex) || Number.isNaN(this.dragIndex)) return

    const [image] = this.images.splice(this.dragIndex, 1)
    this.images.splice(targetIndex, 0, image)
    this.dragIndex = null
    this.render()
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("opacity-50")
    this.dragIndex = null
  }

  openLibrary(event) {
    event.preventDefault()
    if (!this.hasLibraryModalTarget) return
    this.libraryModalTarget.classList.remove("hidden")
    this.libraryModalTarget.classList.add("flex")
    document.body.classList.add("overflow-hidden")
    this.loadLibrary()
  }

  closeLibrary(event) {
    event?.preventDefault()
    if (!this.hasLibraryModalTarget) return
    this.libraryModalTarget.classList.add("hidden")
    this.libraryModalTarget.classList.remove("flex")
    document.body.classList.remove("overflow-hidden")
  }

  stopLibraryPropagation(event) {
    event.stopPropagation()
  }

  async loadLibrary() {
    if (!this.fetchUrlValue || !this.hasLibraryListTarget) return

    this.libraryListTarget.innerHTML =
      '<p class="col-span-full text-sm text-ssgrip-silver-dark">Loading images…</p>'
    this.toggleLibraryEmpty(false)

    try {
      const response = await fetch(this.fetchUrlValue, {
        headers: { Accept: "application/json" }
      })
      if (!response.ok) throw new Error("Unable to load library")
      const images = await response.json()
      if (!Array.isArray(images) || images.length === 0) {
        this.libraryListTarget.innerHTML = ""
        this.toggleLibraryEmpty(true)
        return
      }
      this.libraryListTarget.innerHTML = images
        .map((image) => this.libraryCardTemplate(image))
        .join("")
    } catch (error) {
      this.libraryListTarget.innerHTML = `<p class="col-span-full text-sm text-red-400">${escapeHtml(error.message)}</p>`
    }
  }

  selectLibraryImage(event) {
    const url = event.currentTarget?.dataset?.url
    if (!url) return
    this.addImage(url)
    this.closeLibrary()
  }

  async uploadLibraryFile(event) {
    const file = event.target.files?.[0]
    if (!file || !this.uploadUrlValue || !this.csrfToken) return

    const formData = new FormData()
    formData.append("image", file)

    this.setLibraryStatus(`Uploading ${file.name}…`, "info")

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

      this.setLibraryStatus("Upload complete", "success")
      event.target.value = ""
      await this.loadLibrary()
    } catch (error) {
      this.setLibraryStatus(error.message, "error")
    }
  }

  setLibraryStatus(message, tone = "muted") {
    if (!this.hasLibraryUploadStatusTarget) return
    const toneClass =
      {
        success: "text-emerald-400",
        error: "text-red-400",
        info: "text-blue-300",
        muted: "text-ssgrip-silver-dark"
      }[tone] || "text-ssgrip-silver-dark"
    this.libraryUploadStatusTarget.className = `text-xs ${toneClass}`
    this.libraryUploadStatusTarget.textContent = message
  }

  toggleLibraryEmpty(visible) {
    if (!this.hasLibraryEmptyTarget) return
    this.libraryEmptyTarget.classList.toggle("hidden", !visible)
  }

  render() {
    if (!this.hasListTarget) return
    if (this.images.length === 0 && this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.remove("hidden")
    } else if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.add("hidden")
    }

    this.listTarget.innerHTML = this.images
      .map((url, index) => this.cardTemplate(url, index))
      .join("")

    this.syncInputs()
  }

  syncInputs() {
    if (this.hasHeroInputTarget) {
      this.heroInputTarget.value = this.images[0] || ""
    }

    if (!this.hasInputsTarget) return
    this.inputsTarget.innerHTML = ""
    this.images.slice(1).forEach((url) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "product[gallery_images][]"
      input.value = url
      this.inputsTarget.appendChild(input)
    })
  }

  cardTemplate(url, index) {
    const escapedUrl = escapeHtml(url)
    const upDisabled = index === 0
    const downDisabled = index === this.images.length - 1
    const actions = `
      <div class="flex items-center justify-between mt-3 text-xs text-ssgrip-silver">
        <div class="flex items-center gap-2">
          ${
            index === 0
              ? '<span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-white/10 text-white text-[11px] uppercase tracking-wider">Cover</span>'
              : `<button type="button" class="text-ssgrip-silver-dark hover:text-white transition-colors" data-action="product-gallery#setCover" data-product-gallery-index-param="${index}">Set as cover</button>`
          }
        </div>
        <div class="flex items-center gap-2">
          <button type="button" class="${upDisabled ? "opacity-40 cursor-not-allowed" : "hover:text-white transition-colors"}" data-action="product-gallery#moveUp" data-product-gallery-index-param="${index}" ${
      upDisabled ? "disabled" : ""
    }>↑</button>
          <button type="button" class="${downDisabled ? "opacity-40 cursor-not-allowed" : "hover:text-white transition-colors"}" data-action="product-gallery#moveDown" data-product-gallery-index-param="${index}" ${
      downDisabled ? "disabled" : ""
    }>↓</button>
          <button type="button" class="text-red-400 hover:text-red-300 transition-colors" data-action="product-gallery#removeImage" data-product-gallery-index-param="${index}">Remove</button>
        </div>
      </div>
    `

    return `
      <div class="rounded-xl border border-ssgrip-silver/10 bg-ssgrip-darker/30 p-3" draggable="true" data-index="${index}" data-action="dragstart->product-gallery#dragStart dragover->product-gallery#dragOver drop->product-gallery#drop dragend->product-gallery#dragEnd">
        <div class="aspect-square overflow-hidden rounded-lg bg-ssgrip-darkest/50 border border-ssgrip-silver/10">
          <img src="${escapedUrl}" alt="Product image ${index + 1}" class="w-full h-full object-cover">
        </div>
        ${actions}
      </div>
    `
  }

  libraryCardTemplate(image) {
    const url = escapeHtml(image.url)
    const filename = escapeHtml(image.filename || "image")
    const size = this.formatBytes(image.size)
    return `
      <button
        type="button"
        class="relative group rounded-xl overflow-hidden border border-white/10 bg-zinc-900 hover:border-emerald-400/50 transition focus:outline-none focus:ring-2 focus:ring-emerald-400"
        data-url="${url}"
        data-action="click->product-gallery#selectLibraryImage"
      >
        <img src="${url}" alt="${filename}" class="h-32 w-full object-cover">
        <div class="absolute inset-x-0 bottom-0 bg-black/70 px-2 py-1">
          <p class="text-xs text-white truncate">${filename}</p>
          <p class="text-[11px] text-zinc-300">${size}</p>
        </div>
      </button>
    `
  }

  formatBytes(bytes) {
    if (!bytes || Number(bytes) === 0) return "0 B"
    const units = ["B", "KB", "MB", "GB", "TB"]
    const exponent = Math.min(
      Math.floor(Math.log(bytes) / Math.log(1024)),
      units.length - 1
    )
    const value = bytes / Math.pow(1024, exponent)
    return `${value.toFixed(value >= 10 || exponent === 0 ? 0 : 1)} ${
      units[exponent]
    }`
  }
}

