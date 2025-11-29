import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addressField", "detailsCard", "lockedNotice"]

  connect() {
    this.toggleDetails()
  }

  handleAddressInput() {
    this.toggleDetails()
  }

  toggleDetails() {
    if (this.addressComplete()) {
      this.showDetails()
    } else {
      this.hideDetails()
    }
  }

  addressComplete() {
    if (this.addressFieldTargets.length === 0) return false
    return this.addressFieldTargets.every((element) => element.value.trim().length > 0)
  }

  showDetails() {
    if (this.hasDetailsCardTarget) {
      this.detailsCardTarget.classList.remove("hidden")
    }
    if (this.hasLockedNoticeTarget) {
      this.lockedNoticeTarget.classList.add("hidden")
    }
  }

  hideDetails() {
    if (this.hasDetailsCardTarget) {
      this.detailsCardTarget.classList.add("hidden")
    }
    if (this.hasLockedNoticeTarget) {
      this.lockedNoticeTarget.classList.remove("hidden")
    }
  }
}

