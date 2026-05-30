import { Controller } from "@hotwired/stimulus"

// Toaster container controller. Registers the Toaster element in the global
// window.wabiToasters keyed registry so JS code (e.g. direct imperative
// toast() calls) can target a specific Toaster instance by id.
//
// Usage: the component renders `data-controller="wabi--toaster"` on the <ol>.
// JS callers can look up any registered Toaster:
//
//   const toaster = window.wabiToasters["wabi-toaster"] // default id
//   const alerts  = window.wabiToasters["alerts"]       // named instance
//
// window.wabiToaster (no 's') is kept as a DEPRECATED backwards-compat alias
// pointing at the most-recently-connected Toaster, so existing app code that
// read the singleton keeps working without changes.
export default class extends Controller {
  connect() {
    window.wabiToasters = window.wabiToasters || {}
    const toasterId = this.element.id || "wabi-toaster"
    if (window.wabiToasters[toasterId] && window.wabiToasters[toasterId] !== this) {
      // Two Toasters share an id (commonly two default-id Toasters on one
      // page). The second shadows the first in the registry AND duplicates
      // the DOM id — give each Toaster a unique id: to avoid silent misroutes.
      console.warn(`[wabi] Two Toasters share the id "${toasterId}". The second shadows the first in window.wabiToasters — give each Toaster a unique id:.`)
    }
    window.wabiToasters[toasterId] = this
    // Deprecated alias — points at the most-recently-connected toaster.
    window.wabiToaster = this
  }

  disconnect() {
    const toasterId = this.element.id || "wabi-toaster"
    if (window.wabiToasters && window.wabiToasters[toasterId] === this) {
      delete window.wabiToasters[toasterId]
    }
    if (window.wabiToaster === this) {
      // Falls back to the first remaining toaster in insertion order. Callers
      // should migrate to window.wabiToasters[id], which is always precise.
      window.wabiToaster = Object.values(window.wabiToasters || {})[0] || null
    }
  }
}
