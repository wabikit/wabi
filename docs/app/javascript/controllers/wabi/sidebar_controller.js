import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]
  static values  = {
    defaultCollapsed: { type: Boolean, default: false },
    persistKey:       { type: String,  default: "wabi-sidebar" },
  }

  connect() {
    const stored = localStorage.getItem(this.persistKeyValue)
    const collapsed = stored === null ? this.defaultCollapsedValue : stored === "true"
    this.element.dataset.state = collapsed ? "collapsed" : "expanded"
    this.#syncGlobalState()
    this._onKeydown = (e) => {
      if (e.key === "Escape" && this.element.dataset.mobile === "open") this.closeMobile()
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "b") { e.preventDefault(); this.toggle() }
    }
    document.addEventListener("keydown", this._onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKeydown)
  }

  isDesktop() {
    return window.matchMedia("(min-width: 1024px)").matches
  }

  toggle() {
    if (this.isDesktop()) {
      const collapsed = this.element.dataset.state !== "collapsed"
      this.element.dataset.state = collapsed ? "collapsed" : "expanded"
      this.#syncGlobalState()
      localStorage.setItem(this.persistKeyValue, String(collapsed))
      this.dispatch("change", { detail: { state: this.element.dataset.state, mobile: this.element.dataset.mobile } })
    } else {
      this.element.dataset.mobile === "open" ? this.closeMobile() : this.openMobile()
    }
  }

  openMobile() {
    this._triggerEl = document.activeElement // remember opener to restore focus on close
    this.element.dataset.mobile = "open"
    this.#setInert(true)
    // hasPanelTarget guard: accessing this.panelTarget when absent throws in Stimulus.
    if (this.hasPanelTarget) this.panelTarget.focus()
    this.dispatch("change", { detail: { state: this.element.dataset.state, mobile: "open" } })
  }

  closeMobile() {
    this.element.dataset.mobile = "closed"
    this.#setInert(false)
    this._triggerEl?.focus() // return focus to the trigger (WCAG 2.4.3)
    this._triggerEl = null
    this.dispatch("change", { detail: { state: this.element.dataset.state, mobile: "closed" } })
  }

  // Mirror collapse state to <html> (like the theme controller mirrors data-mode)
  // so collapsed-only menu-button tooltips can gate on it even after their content
  // portals out to <body> (escaping the sidebar's own group/sidebar scope).
  #syncGlobalState() {
    document.documentElement.setAttribute("data-wabi-sidebar", this.element.dataset.state)
  }

  #setInert(on) {
    const skip = new Set([this.hasPanelTarget && this.panelTarget, this.hasBackdropTarget && this.backdropTarget].filter(Boolean))
    for (const child of this.element.children) {
      if (skip.has(child)) continue
      if (on) child.setAttribute("inert", "")
      else child.removeAttribute("inert")
    }
  }
}
