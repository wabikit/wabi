import { Controller } from "@hotwired/stimulus"

// Writes the controller element's source value to the clipboard and gives
// the button a "Copied!" affordance for ~1.2s. Reads the source from a
// Stimulus String value so we never have to extract text out of the
// highlighted HTML (Rouge wraps tokens in spans).
export default class extends Controller {
  static targets = ["button"]
  static values  = { source: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceValue)
    } catch (err) {
      console.error("[site--copy] clipboard write failed", err)
      return
    }
    if (!this.hasButtonTarget) return
    const original = this.buttonTarget.textContent
    this.buttonTarget.textContent = "Copied!"
    clearTimeout(this._resetTimer)
    this._resetTimer = setTimeout(() => {
      this.buttonTarget.textContent = original
    }, 1200)
  }

  disconnect() {
    clearTimeout(this._resetTimer)
  }
}
