import { Controller } from "@hotwired/stimulus"

// Item controller for a single toast. The wabi--toaster coordinator owns the
// stack: it calls position() with this toast's resting translateY/scale, and
// hold()/release() to pause/resume the dismiss timer when the group is hovered.
// This controller owns its entrance/exit animation, its dismiss timer, and the
// swipe-to-dismiss gesture. No Zag machine -- vanilla timer + inline styles.
//
// Two independent pause sources gate the timer: groupHeld (group hover/focus)
// and the data-hidden attribute (collapsed beyond visibleCount). The timer only
// runs when BOTH are clear, so a toast hidden-then-revealed resumes correctly.
const SWIPE_THRESHOLD = 80 // px of horizontal drag before a swipe dismisses

export default class extends Controller {
  static values = {
    durationMs: { type: Number, default: 5000 },
  }

  connect() {
    this.rest = { y: 0, scale: 1, zIndex: 1 } // assigned by the coordinator
    this.entered = false
    this.groupHeld = false
    this.swiping = false
    this.remainingMs = null

    this.element.style.transitionProperty = "transform, opacity"
    this.element.style.willChange = "transform, opacity"

    this.boundDown = this.onPointerDown.bind(this)
    this.element.addEventListener("pointerdown", this.boundDown)

    // Entrance: snap to closed off-screen, then flip to open at the resting
    // transform on the next frame so the CSS transition plays. The double-rAF
    // commits the "closed" style before scheduling "open"; by the second frame
    // the coordinator's recompute has already written this.rest.
    this.element.dataset.state = "closed"
    this.applyTransform(this.entranceY(), this.rest.scale)
    requestAnimationFrame(() => requestAnimationFrame(() => {
      this.entered = true
      this.element.dataset.state = "open"
      this.applyRest()
      this.startTimer()
    }))
  }

  disconnect() {
    this.clearTimer()
    this.element.removeEventListener("pointerdown", this.boundDown)
    if (this.boundMove) this.element.removeEventListener("pointermove", this.boundMove)
    if (this.boundUp) {
      this.element.removeEventListener("pointerup", this.boundUp)
      this.element.removeEventListener("pointercancel", this.boundUp)
    }
    this.swiping = false
  }

  // --- coordinator API (called via the wabi--toaster outlet) ---

  position({ y, scale, zIndex, front, hidden, expanded }) {
    this.rest = { y, scale, zIndex }
    this.element.style.zIndex = String(zIndex)
    this.element.toggleAttribute("data-front", !!front)
    this.element.toggleAttribute("data-hidden", !!hidden)
    this.element.toggleAttribute("data-expanded", !!expanded)
    // Don't disturb opacity/transform/pointer-events while the user is swiping.
    if (!this.swiping) {
      this.element.style.opacity = hidden ? "0" : ""
      this.element.style.pointerEvents = hidden ? "none" : ""
      if (this.entered) this.applyRest()
    }
    // data-hidden is set above, so resumeTimer()/startTimer() see the right gate.
    if (hidden) this.pauseTimer()
    else if (this.entered) this.resumeTimer()
  }

  // Group-level pause (hover/focus on the toaster). Distinct from the hidden
  // gate (data-hidden) so the two pause sources can't clobber each other.
  hold() {
    this.groupHeld = true
    this.pauseTimer()
  }

  release() {
    this.groupHeld = false
    this.resumeTimer()
  }

  measuredHeight() { return this.element.offsetHeight }

  // --- timer ---

  startTimer() {
    this.clearTimer()
    if (this.durationMsValue <= 0) { this.remainingMs = 0; return }
    if (this.groupHeld || this.element.hasAttribute("data-hidden")) return
    this.startedAt = Date.now()
    this.remainingMs = this.durationMsValue
    this.timer = setTimeout(() => this.dismiss(), this.remainingMs)
  }

  pauseTimer() {
    if (!this.timer) return
    this.clearTimer()
    this.remainingMs -= Date.now() - this.startedAt
    if (this.remainingMs < 0) this.remainingMs = 0
  }

  resumeTimer() {
    if (this.timer || this.durationMsValue <= 0) return
    if (this.groupHeld || this.element.hasAttribute("data-hidden")) return
    if (this.remainingMs == null) { this.startTimer(); return }
    if (this.remainingMs <= 0) { this.dismiss(); return }
    this.startedAt = Date.now()
    this.timer = setTimeout(() => this.dismiss(), this.remainingMs)
  }

  clearTimer() {
    if (this.timer) { clearTimeout(this.timer); this.timer = null }
  }

  // --- dismissal (Stimulus action: click->wabi--toast#dismiss) ---

  dismiss(arg) {
    // arg is a DOM Event when fired from the close button. keepTransform is only
    // passed by the swipe path to preserve the horizontal fling-out transform.
    const keepTransform = !!(arg && arg.keepTransform)
    this.clearTimer()
    this.element.dispatchEvent(new CustomEvent("wabi-toast:dismiss", { bubbles: true }))
    this.element.dataset.state = "closed"
    this.element.style.opacity = "0"
    if (!keepTransform) this.applyTransform(this.entranceY(), this.rest.scale)
    const handler = () => {
      this.element.removeEventListener("transitionend", handler)
      this.element.remove()
    }
    this.element.addEventListener("transitionend", handler)
    // Safety: if transitionend never fires (reduced-motion / display issues).
    setTimeout(() => { if (this.element.isConnected) this.element.remove() }, 350)
  }

  // --- swipe-to-dismiss ---

  onPointerDown(event) {
    if (event.target.closest("button")) return // let the close button work
    this.swiping = true
    this.swipeStart = event.clientX
    this.swipeDx = 0
    try { this.element.setPointerCapture(event.pointerId) } catch (_) {}
    this.element.style.transitionProperty = "none"
    this.boundMove = this.onPointerMove.bind(this)
    this.boundUp = this.onPointerUp.bind(this)
    this.element.addEventListener("pointermove", this.boundMove)
    this.element.addEventListener("pointerup", this.boundUp)
    this.element.addEventListener("pointercancel", this.boundUp)
  }

  onPointerMove(event) {
    this.swipeDx = event.clientX - this.swipeStart
    this.element.style.transform = `translateX(${this.swipeDx}px)`
  }

  onPointerUp() {
    this.element.removeEventListener("pointermove", this.boundMove)
    this.element.removeEventListener("pointerup", this.boundUp)
    this.element.removeEventListener("pointercancel", this.boundUp)
    this.boundMove = null
    this.boundUp = null
    this.element.style.transitionProperty = "transform, opacity"
    this.swiping = false
    if (Math.abs(this.swipeDx) > SWIPE_THRESHOLD) {
      this.element.style.transform = `translateX(${Math.sign(this.swipeDx) * 400}px)`
      this.dismiss({ keepTransform: true })
    } else {
      this.applyRest() // snap back
    }
    this.swipeDx = 0
  }

  // --- transform helpers ---

  applyRest() { this.applyTransform(this.rest.y, this.rest.scale) }

  applyTransform(y, scale) {
    this.element.style.transform = `translateY(${y}px) scale(${scale})`
  }

  entranceY() {
    // Off-screen offset in the placement direction. enterDir is set by the
    // coordinator (-1 for top placements, +1 for bottom). Fallback +1.
    const h = this.element.offsetHeight || 80
    const dir = Number(this.element.dataset.enterDir || 1)
    return dir * (h + 24)
  }
}
