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

// Global teardown: stop any Stimulus Applications a test started, so controllers
// never leak across test files.
afterEach(() => stopAll())
