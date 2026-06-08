import { Controller } from "@hotwired/stimulus"

let panelUid = 0

export default class extends Controller {
  static targets = ["panel", "backdrop", "trigger"]
  static values  = {
    defaultCollapsed: { type: Boolean, default: false },
    persistKey:       { type: String,  default: "wabi-sidebar" },
  }

  connect() {
    const stored = localStorage.getItem(this.persistKeyValue)
    const collapsed = stored === null ? this.defaultCollapsedValue : stored === "true"
    this.element.dataset.state = collapsed ? "collapsed" : "expanded"
    this.#syncGlobalState()
    // Give the panel a stable id so triggers can point aria-controls at it.
    if (this.hasPanelTarget && !this.panelTarget.id) this.panelTarget.id = `wabi-sidebar-${++panelUid}`
    // On mobile the panel starts off-canvas (data-mobile=closed); mark it inert so its
    // contents are not keyboard-reachable until the user opens it.
    if (!this.isDesktop() && this.hasPanelTarget && this.element.dataset.mobile !== "open") {
      this.panelTarget.setAttribute("inert", "")
    }
    this.#syncTriggers()
    this._onKeydown = (e) => {
      if (e.key === "Escape" && this.element.dataset.mobile === "open") this.closeMobile()
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "b") {
        if (this.#isEditable(e.target)) return // don't steal Cmd/Ctrl+B from text fields (bold)
        e.preventDefault()
        this.toggle()
      }
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
      this.#syncTriggers()
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
    // Off-canvas panel is a modal on mobile: announce it as such to AT.
    if (this.hasPanelTarget) {
      this.panelTarget.setAttribute("role", "dialog")
      this.panelTarget.setAttribute("aria-modal", "true")
      this.panelTarget.focus() // hasPanelTarget guard: this.panelTarget throws when absent.
    }
    this.#syncTriggers()
    this.dispatch("change", { detail: { state: this.element.dataset.state, mobile: "open" } })
  }

  closeMobile() {
    this.element.dataset.mobile = "closed"
    this.#setInert(false)
    if (this.hasPanelTarget) {
      this.panelTarget.removeAttribute("role")
      this.panelTarget.removeAttribute("aria-modal")
    }
    this.#syncTriggers()
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

  // Reflect the current open/collapsed state onto every trigger button so AT
  // announces it. Desktop: expanded vs collapsed rail. Mobile: off-canvas open.
  #syncTriggers() {
    if (!this.hasTriggerTarget) return
    const expanded = this.isDesktop()
      ? this.element.dataset.state === "expanded"
      : this.element.dataset.mobile === "open"
    for (const t of this.triggerTargets) {
      t.setAttribute("aria-expanded", String(expanded))
      if (this.hasPanelTarget && this.panelTarget.id) t.setAttribute("aria-controls", this.panelTarget.id)
    }
  }

  #isEditable(el) {
    if (!el || !el.tagName) return false
    return el.isContentEditable ||
      el.tagName === "INPUT" || el.tagName === "TEXTAREA" || el.tagName === "SELECT"
  }

  #setInert(on) {
    const skip = new Set([this.hasPanelTarget && this.panelTarget, this.hasBackdropTarget && this.backdropTarget].filter(Boolean))
    for (const child of this.element.children) {
      if (skip.has(child)) continue
      if (on) child.setAttribute("inert", "")
      else child.removeAttribute("inert")
    }
    // On mobile, also inert the panel when it is off-canvas so its contents are
    // not keyboard-reachable while hidden (WCAG 2.1 — keyboard trap / focus management).
    if (!this.isDesktop() && this.hasPanelTarget) {
      if (on) this.panelTarget.removeAttribute("inert")  // panel is open → remove inert
      else this.panelTarget.setAttribute("inert", "")    // panel is closed → add inert
    }
  }
}
