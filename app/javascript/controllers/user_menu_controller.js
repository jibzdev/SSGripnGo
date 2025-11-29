import { Controller } from "@hotwired/stimulus"

const HIDDEN_CLASSES = ["hidden", "scale-95", "opacity-0"]

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.boundOutsideClick = this.handleOutsideClick.bind(this)
    this.boundEscape = this.handleEscape.bind(this)
    this.boundCache = this.close.bind(this)
    this.boundCloseAll = this.handleCloseAll.bind(this)
    document.addEventListener("turbo:before-cache", this.boundCache)
    window.addEventListener("user-menu:close-all", this.boundCloseAll)
    this.close()
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.boundCache)
    window.removeEventListener("user-menu:close-all", this.boundCloseAll)
    this.removeDocumentListeners()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.dispatchCloseAll()
    const panel = this.panelTarget
    panel.classList.remove("hidden")
    requestAnimationFrame(() => {
      panel.classList.remove("scale-95")
      panel.classList.remove("opacity-0")
    })
    this.addDocumentListeners()
  }

  close() {
    HIDDEN_CLASSES.forEach(cls => this.panelTarget.classList.add(cls))
    this.removeDocumentListeners()
  }

  isOpen() {
    return !this.panelTarget.classList.contains("hidden")
  }

  addDocumentListeners() {
    if (this.listening) return
    document.addEventListener("click", this.boundOutsideClick)
    document.addEventListener("keydown", this.boundEscape)
    this.listening = true
  }

  removeDocumentListeners() {
    if (!this.listening) return
    document.removeEventListener("click", this.boundOutsideClick)
    document.removeEventListener("keydown", this.boundEscape)
    this.listening = false
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  dispatchCloseAll() {
    window.dispatchEvent(new CustomEvent("user-menu:close-all", {
      detail: { except: this.element }
    }))
  }

  handleCloseAll(event) {
    if (event.detail?.except === this.element) return
    this.close()
  }
}

