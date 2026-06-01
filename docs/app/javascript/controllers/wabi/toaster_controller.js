import { Controller } from "@hotwired/stimulus"
import { computeStack } from "controllers/wabi/_shared/toast_stack"

// Group coordinator for a Toaster. Keeps the window.wabiToasters keyed registry
// (so JS callers can target a Toaster by id) AND coordinates the Sonner-style
// stack: it measures each toast and assigns translateY/scale via the wabi--toast
// outlet. Hovering/focusing the group expands the stack and pauses every timer.
// No Zag machine: the coordinator only reads the DOM and writes inline styles.
export default class extends Controller {
  static outlets = ["wabi--toast"]
  static values = {
    placement:    { type: String, default: "top_right" },
    visibleCount: { type: Number, default: 3 },
    gap:          { type: Number, default: 14 },
  }

  connect() {
    window.wabiToasters = window.wabiToasters || {}
    this.toasterId = this.element.id || "wabi-toaster"
    if (window.wabiToasters[this.toasterId] && window.wabiToasters[this.toasterId] !== this) {
      console.warn(`[wabi] Two Toasters share the id "${this.toasterId}". The second shadows the first in window.wabiToasters — give each Toaster a unique id:.`)
    }
    window.wabiToasters[this.toasterId] = this
    window.wabiToaster = this // deprecated alias -> most-recent toaster

    this.expanded = false
    this.onEnter = () => this.setExpanded(true)
    this.onLeave = () => this.setExpanded(false)
    this.element.addEventListener("pointerenter", this.onEnter)
    this.element.addEventListener("pointerleave", this.onLeave)
    this.element.addEventListener("focusin", this.onEnter)
    this.element.addEventListener("focusout", this.onLeave)

    this.scheduleRecompute()
  }

  disconnect() {
    this.element.removeEventListener("pointerenter", this.onEnter)
    this.element.removeEventListener("pointerleave", this.onLeave)
    this.element.removeEventListener("focusin", this.onEnter)
    this.element.removeEventListener("focusout", this.onLeave)
    if (window.wabiToasters && window.wabiToasters[this.toasterId] === this) {
      delete window.wabiToasters[this.toasterId]
    }
    if (window.wabiToaster === this) {
      window.wabiToaster = Object.values(window.wabiToasters || {})[0] || null
    }
  }

  // --- outlet lifecycle ---

  wabiToastOutletConnected(_outlet, element) {
    element.dataset.enterDir = this.placementValue.startsWith("top") ? "-1" : "1"
    this.enhance(element)
    this.scheduleRecompute()
  }

  wabiToastOutletDisconnected() {
    this.scheduleRecompute()
  }

  enhance(element) {
    const bottom = !this.placementValue.startsWith("top")
    element.style.position = "absolute"
    element.style.left = "0"
    element.style.right = "0"
    element.style.width = "100%"
    element.style.top = ""
    element.style.bottom = ""
    element.style[bottom ? "bottom" : "top"] = "0"
    element.style.transformOrigin = `${bottom ? "bottom" : "top"} center`
  }

  // --- group hover/focus -> expand + pause all ---

  setExpanded(value) {
    if (this.expanded === value) return
    this.expanded = value
    if (value) this.wabiToastOutlets.forEach((t) => t.hold())
    else this.wabiToastOutlets.forEach((t) => t.release())
    this.scheduleRecompute()
  }

  // --- stack recompute (batched: one layout read + write per frame) ---

  scheduleRecompute() {
    if (this.raf) return
    this.raf = requestAnimationFrame(() => {
      this.raf = null
      this.recompute()
    })
  }

  recompute() {
    const outlets = this.wabiToastOutlets
    if (!outlets.length) return
    // Front-first = reverse DOM order: the last-appended <li> is the newest
    // toast and sits at the front of the stack.
    const front = [...outlets].reverse()
    const heights = front.map((t) => t.measuredHeight())
    const layout = computeStack(heights, {
      expanded: this.expanded,
      visibleCount: this.visibleCountValue,
      gap: this.gapValue,
      placement: this.placementValue,
    })
    front.forEach((t, i) => t.position({ ...layout[i], expanded: this.expanded }))
  }
}
