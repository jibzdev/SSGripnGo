import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "postcode",
    "status",
    "resultsWrapper",
    "results",
    "line1",
    "line2",
    "city",
    "region",
    "country"
  ]

  static values = {
    fetchUrl: String
  }

  lookup(event) {
    event.preventDefault()
    const postcode = this.postcodeTarget.value.trim()

    if (postcode === "") {
      this.setStatus("Enter a postcode to search.", "error")
      this.toggleResults(false)
      return
    }

    this.setStatus("Looking up addresses...", "info")
    this.toggleResults(false)
    this.resultsTarget.innerHTML = '<option value="">Choose an address</option>'

    const url = new URL(this.fetchUrlValue, window.location.origin)
    url.searchParams.set("postcode", postcode)

    fetch(url, { headers: { "Accept": "application/json" } })
      .then(async (response) => {
        const payload = await response.json().catch(() => ({}))
        if (!response.ok) throw new Error(payload.error || "No addresses found for that postcode.")
        return payload.addresses || []
      })
      .then((addresses) => {
        if (addresses.length === 0) {
          this.setStatus("No results for that postcode. Check the spelling or enter the address manually.", "error")
          return
        }

        addresses.forEach((address, index) => {
          const option = document.createElement("option")
          option.value = index
          option.textContent = this.labelFor(address)
          option.dataset.address = JSON.stringify(address)
          this.resultsTarget.appendChild(option)
        })

        this.setStatus(`Found ${addresses.length} address${addresses.length > 1 ? "es" : ""}. Choose one or edit the fields manually.`, "success")
        this.toggleResults(true)
      })
      .catch((error) => {
        console.error(error)
        this.setStatus(error.message || "Something went wrong while looking up that postcode.", "error")
      })
  }

  applyAddress(event) {
    const option = event.target.selectedOptions[0]
    if (!option || !option.dataset.address) return

    const address = JSON.parse(option.dataset.address)
    this.fillField(this.line1Target, address.line1)
    this.fillField(this.line2Target, address.line2)
    this.fillField(this.cityTarget, address.city)
    this.fillField(this.regionTarget, address.region)
    this.fillField(this.countryTarget, address.country || "United Kingdom")
  }

  // Helpers
  setStatus(message, tone = "info") {
    if (!this.hasStatusTarget) return
    const colors = {
      info: "text-ssgrip-silver-dark",
      error: "text-red-400",
      success: "text-green-400"
    }
    this.statusTarget.textContent = message
    this.statusTarget.className = `text-xs mt-2 ${colors[tone] || colors.info}`
  }

  toggleResults(show) {
    if (!this.hasResultsWrapperTarget) return
    this.resultsWrapperTarget.classList.toggle("hidden", !show)
  }

  fillField(target, value) {
    if (!target || value === undefined) return
    target.value = value || ""
    target.dispatchEvent(new Event("input", { bubbles: true }))
  }

  labelFor(address) {
    return [
      address.line1,
      address.line2,
      address.city,
      address.postal_code
    ].filter(Boolean).join(", ")
  }
}

