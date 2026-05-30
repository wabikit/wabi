import { Controller } from "@hotwired/stimulus"

// Self-contained toast lifecycle. No Zag machine -- vanilla setTimeout with
// pause-on-hover bookkeeping. Each toast manages its own dismissal timer; when
// Turbo Stream appends a new <li> to the Toaster, Stimulus auto-connects this
// controller on the new element and the countdown starts.
export default class extends Controller {
  static values = {
    durationMs: { type: Number, default: 5000 },
  }

  connect() {
    this.boundPause  = this.pause.bind(this)
    this.boundResume = this.resume.bind(this)
    this.element.addEventListener("mouseenter", this.boundPause)
    this.element.addEventListener("mouseleave", this.boundResume)
    this.element.addEventListener("focusin",    this.boundPause)
    this.element.addEventListener("focusout",   this.boundResume)

    // Enter animation: SSR sets data-state="open" (no-JS fallback: toast is
    // visible without JS). For JS, snap to "closed" synchronously before the
    // browser's first paint of this node (connect() fires in a MutationObserver
    // microtask, before layout/paint), then flip back to "open" on the next
    // animation frame so the CSS transition (translate-x + opacity) plays the
    // slide-in. The double-rAF ensures the "closed" state is committed to
    // style before the "open" flip is scheduled, which is necessary for the
    // transition to register on browsers that batch style recalcs.
    this.element.dataset.state = "closed"
    requestAnimationFrame(() => {
      requestAnimationFrame(() => { this.element.dataset.state = "open" })
    })

    this.start()
  }

  disconnect() {
    this.clearTimer()
    this.element.removeEventListener("mouseenter", this.boundPause)
    this.element.removeEventListener("mouseleave", this.boundResume)
    this.element.removeEventListener("focusin",    this.boundPause)
    this.element.removeEventListener("focusout",   this.boundResume)
  }

  start() {
    // durationMsValue <= 0 means "sticky" — render the toast without an
    // auto-dismiss timer. Useful for previews, manual-dismiss-only flows,
    // or when the app schedules dismissal externally.
    if (this.durationMsValue <= 0) {
      this.remainingMs = 0
      return
    }
    this.startedAt   = Date.now()
    this.remainingMs = this.durationMsValue
    this.timer       = setTimeout(() => this.dismiss(), this.remainingMs)
  }

  pause() {
    if (!this.timer) return
    this.clearTimer()
    this.remainingMs -= Date.now() - this.startedAt
    if (this.remainingMs < 0) this.remainingMs = 0
  }

  resume() {
    if (this.timer) return
    if (this.remainingMs <= 0) { this.dismiss(); return }
    this.startedAt = Date.now()
    this.timer     = setTimeout(() => this.dismiss(), this.remainingMs)
  }

  // Stimulus action: `data-action="click->wabi--toast#dismiss"` on the close
  // button animates the toast out before removing it from the DOM.
  dismiss() {
    this.element.dispatchEvent(new CustomEvent("wabi-toast:dismiss", { bubbles: true }))
    // Flip to closed state; CSS transition (transition-all duration-300)
    // animates translate-x + opacity. Listen for transitionend to remove.
    this.element.dataset.state = "closed"
    const handler = () => {
      this.element.removeEventListener("transitionend", handler)
      this.element.remove()
    }
    this.element.addEventListener("transitionend", handler)
    // Safety fallback: if transitionend doesn't fire (e.g. element is
    // display:none-ish, or prefers-reduced-motion), force-remove after 350ms.
    setTimeout(() => {
      if (this.element.isConnected) this.element.remove()
    }, 350)
  }

  clearTimer() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }
}
