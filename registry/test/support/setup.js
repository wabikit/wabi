import { afterEach } from "vitest"
import { stopAll } from "./mount.js"

// Popper-based overlays (popover, tooltip, select, dropdown_menu) start Zag's
// floating-ui positioning on open, which constructs a ResizeObserver. jsdom has
// none, so opening would throw an unhandled rejection. Polyfill a no-op: these
// tests assert wiring, not geometry, so the observer doing nothing is fine.
if (typeof globalThis.ResizeObserver !== "function") {
  globalThis.ResizeObserver = class {
    observe() {}
    unobserve() {}
    disconnect() {}
  }
}

// Zag's carousel machine uses IntersectionObserver to track which slides are
// in view. jsdom has none, so connecting would throw. Polyfill a no-op: these
// tests assert wiring, not visibility geometry.
if (typeof globalThis.IntersectionObserver !== "function") {
  globalThis.IntersectionObserver = class {
    constructor(callback) { this.callback = callback }
    observe() {}
    unobserve() {}
    disconnect() {}
  }
}

// Zag's carousel machine calls el.scrollTo() on the item-group when navigating
// pages. jsdom doesn't implement scrollTo on elements, so polyfill a no-op.
// Tests assert wiring (dispatch, aria attrs), not actual scroll geometry.
if (typeof Element.prototype.scrollTo !== "function") {
  Element.prototype.scrollTo = function () {}
}

// Zag's radio-group machine resolves its grouped inputs with
// `CSS.escape(rootId)` when syncing each input's checked state. jsdom exposes no
// `CSS` global, so without this the sync throws and selection never propagates
// to the items' data-state. Provide the spec's serialize-an-identifier
// algorithm (https://drafts.csswg.org/cssom/#serialize-an-identifier); these
// tests assert wiring, so a faithful escape is all that's needed.
if (typeof globalThis.CSS !== "object" || globalThis.CSS === null) globalThis.CSS = {}
if (typeof globalThis.CSS.escape !== "function") {
  globalThis.CSS.escape = (value) => {
    const str = String(value)
    let result = ""
    for (let i = 0; i < str.length; i++) {
      const c = str.charCodeAt(i)
      if (c === 0x0000) { result += "�"; continue }
      if ((c >= 0x0001 && c <= 0x001f) || c === 0x007f ||
          (i === 0 && c >= 0x0030 && c <= 0x0039) ||
          (i === 1 && c >= 0x0030 && c <= 0x0039 && str.charCodeAt(0) === 0x002d)) {
        result += "\\" + c.toString(16) + " "; continue
      }
      if (i === 0 && c === 0x002d && str.length === 1) { result += "\\" + str.charAt(i); continue }
      if (c >= 0x0080 || c === 0x002d || c === 0x005f ||
          (c >= 0x0030 && c <= 0x0039) || (c >= 0x0041 && c <= 0x005a) || (c >= 0x0061 && c <= 0x007a)) {
        result += str.charAt(i); continue
      }
      result += "\\" + str.charAt(i)
    }
    return result
  }
}

// jsdom's selector engine (nwsapi) can't compile the `:scope >` combinator and
// throws SYNTAX_ERR. Several controllers use `el.querySelectorAll(':scope > …')`
// to find/clean up their own direct-child hidden inputs (toggle_group, slider).
// Real browsers support :scope fine, so this is a jsdom-only gap. Polyfill it by
// temporarily tagging the host element and rewriting :scope → an attribute
// selector that nwsapi can compile. Transparent for selectors without :scope.
if (!Element.prototype.__wabiScopePatched) {
  let counter = 0
  for (const method of ["querySelector", "querySelectorAll"]) {
    const original = Element.prototype[method]
    Element.prototype[method] = function (selector) {
      if (typeof selector === "string" && selector.includes(":scope")) {
        const attr = `data-wabi-scope-${counter++}`
        this.setAttribute(attr, "")
        try {
          return original.call(this, selector.replace(/:scope/g, `[${attr}]`))
        } finally {
          this.removeAttribute(attr)
        }
      }
      return original.call(this, selector)
    }
  }
  Element.prototype.__wabiScopePatched = true
}

// jsdom gives every element zero layout (offsetWidth/offsetHeight = 0 and
// getClientRects() = []), so @zag-js/dom-query's visibility check
// (`offsetWidth > 0 || offsetHeight > 0 || getClientRects().length > 0`) treats
// EVERY node as hidden. For a modal dialog that means Zag's focus-trap finds zero
// tabbable nodes and throws "Your focus-trap needs to have at least one focusable
// element" — thrown asynchronously during the trap's teardown (which stacks across
// tests because focus-trap defers deactivation), surfacing as an uncaught error
// that fails the whole run. Report a non-zero client rect for connected elements
// so the visibility check passes and the trap resolves a focus node. These tests
// assert wiring, not geometry; getBoundingClientRect (used by floating-ui
// positioning) is left untouched.
if (!Element.prototype.__wabiRectsPatched) {
  const realGetClientRects = Element.prototype.getClientRects
  Element.prototype.getClientRects = function () {
    if (this.isConnected) {
      return [{ x: 0, y: 0, width: 1, height: 1, top: 0, left: 0, right: 1, bottom: 1 }]
    }
    return realGetClientRects ? realGetClientRects.call(this) : []
  }
  Element.prototype.__wabiRectsPatched = true
}

// Global teardown: stop any Stimulus Applications a test started, so controllers
// never leak across test files.
//
// Before stopping, flush pending rAFs. @zag-js/focus-trap defers trap activation
// to a rAF and keeps a module-level stack of active traps shared across the whole
// run. If a modal test ends with an activation still queued, stopAll() clears the
// DOM before that trap deactivates, leaving a half-activated trap on the shared
// stack. The NEXT test's trap deactivation then unpauses that stale trap, whose
// containers are gone, and getInitialFocusNode throws "needs at least one
// focusable element" — an async unhandled error that fails the whole CI run
// (jsdom only; real browsers deactivate promptly while the DOM is still present).
// Letting the rAF run first means every trap is fully on its stack and gets
// cleanly deactivated + popped (DOM still connected) when its app stops.
afterEach(async () => {
  await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)))
  stopAll()
})
