import { Controller } from "@hotwired/stimulus"

// Writes the controller element's source value to the clipboard and swaps
// the button's clipboard icon for a checkmark for ~1.2s. The source comes
// from a Stimulus String value so we never have to extract text out of
// the highlighted HTML (Rouge wraps tokens in spans).
export default class extends Controller {
  static targets = ["copyIcon", "checkIcon"]
  static values  = { source: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceValue)
    } catch (err) {
      console.error("[site--copy] clipboard write failed", err)
      return
    }
    if (!this.hasCopyIconTarget || !this.hasCheckIconTarget) return
    this.copyIconTarget.classList.add("hidden")
    this.copyIconTarget.classList.remove("inline-flex")
    this.checkIconTarget.classList.remove("hidden")
    this.checkIconTarget.classList.add("inline-flex")
    clearTimeout(this._resetTimer)
    this._resetTimer = setTimeout(() => {
      this.copyIconTarget.classList.remove("hidden")
      this.copyIconTarget.classList.add("inline-flex")
      this.checkIconTarget.classList.add("hidden")
      this.checkIconTarget.classList.remove("inline-flex")
    }, 1200)
  }

  disconnect() {
    clearTimeout(this._resetTimer)
  }
}
