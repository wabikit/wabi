import { Controller } from "@hotwired/stimulus"

// Collapsed-only flyout for SidebarMenuCollapsible. When the sidebar is collapsed
// (desktop), hovering/focusing the icon floats the submenu (the same <ul>) next to
// it via position:fixed, escaping the rail's overflow clipping. Expanded mode is
// untouched — the native <details> still expands inline.
export default class extends Controller {
  static values = { closeDelay: { type: Number, default: 150 } }

  connect() {
    this.trigger = this.element.querySelector(":scope > summary")
    this.panel   = this.element.querySelector(":scope > ul")
    if (!this.trigger || !this.panel) return

    this._open   = () => this.open()
    this._sched  = () => this.scheduleClose()
    this._cancel = () => this.cancelClose()
    this._onEscape = (e) => { if (e.key === "Escape") this.close() }

    this.trigger.addEventListener("mouseenter", this._open)
    this.trigger.addEventListener("mouseleave", this._sched)
    this.trigger.addEventListener("focusin",    this._open)
    this.trigger.addEventListener("focusout",   this._sched)
    this.panel.addEventListener("mouseenter", this._cancel)
    this.panel.addEventListener("mouseleave", this._sched)
    this.panel.addEventListener("focusout",   this._sched)
  }

  disconnect() {
    clearTimeout(this._timer)
    document.removeEventListener("keydown", this._onEscape)
    if (!this.trigger || !this.panel) return
    this.trigger.removeEventListener("mouseenter", this._open)
    this.trigger.removeEventListener("mouseleave", this._sched)
    this.trigger.removeEventListener("focusin",    this._open)
    this.trigger.removeEventListener("focusout",   this._sched)
    this.panel.removeEventListener("mouseenter", this._cancel)
    this.panel.removeEventListener("mouseleave", this._sched)
    this.panel.removeEventListener("focusout",   this._sched)
  }

  isActive() {
    return window.matchMedia("(min-width: 1024px)").matches &&
           this.element.closest('[data-controller~="wabi--sidebar"]')?.dataset.state === "collapsed"
  }

  open() {
    if (!this.isActive()) return
    this.cancelClose()
    this.panel.dataset.flyout = "open"
    this.#position()
    document.addEventListener("keydown", this._onEscape)
  }

  scheduleClose() {
    if (this.panel?.dataset.flyout !== "open") return
    this._timer = setTimeout(() => this.close(), this.closeDelayValue)
  }

  cancelClose() { clearTimeout(this._timer) }

  close() {
    clearTimeout(this._timer)
    if (!this.panel) return
    this.panel.dataset.flyout = "closed"
    this.panel.style.top = ""
    this.panel.style.left = ""
    document.removeEventListener("keydown", this._onEscape)
  }

  #position() {
    const r = this.trigger.getBoundingClientRect()
    const w = this.panel.offsetWidth || 192
    const gap = 8
    const flipLeft = r.right + gap + w > window.innerWidth
    this.panel.style.top  = `${Math.round(r.top)}px`
    this.panel.style.left = flipLeft ? `${Math.round(r.left - w - gap)}px` : `${Math.round(r.right + gap)}px`
  }
}
