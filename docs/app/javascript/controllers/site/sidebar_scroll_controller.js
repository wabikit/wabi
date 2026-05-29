import { Controller } from "@hotwired/stimulus"

// Preserves the docs sidebar's scroll position across Turbo navigations.
// The sidebar is a fixed-height overflow-y-auto container, so its scrollTop
// resets to 0 on every page render. Save before navigation, restore on
// connect.
const STORAGE_KEY = "wabi:docs:sidebar:scrollTop"

export default class extends Controller {
  connect() {
    const saved = sessionStorage.getItem(STORAGE_KEY)
    if (saved != null) this.element.scrollTop = parseInt(saved, 10) || 0

    this.boundSave = this.save.bind(this)
    this.element.addEventListener("scroll", this.boundSave, { passive: true })
    // Also save before Turbo replaces the document.
    document.addEventListener("turbo:before-render", this.boundSave)
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.boundSave)
    document.removeEventListener("turbo:before-render", this.boundSave)
  }

  save() {
    sessionStorage.setItem(STORAGE_KEY, String(this.element.scrollTop))
  }
}
