import { Controller } from "@hotwired/stimulus"

// Demo-only controller: looks up a <template> child by data-wabi-key, clones
// its content fragment, and appends to #wabi-toaster. Production apps would
// use Turbo Streams (`turbo_stream.append "wabi-toaster",
// Components::UI::Toast.new(...)`) for the equivalent server-driven flow.
//
// History: an earlier v0.1 attempt used Stimulus String values holding
// pre-rendered Toast HTML + insertAdjacentHTML. That worked but was a
// workaround for a suspected Phlex 2.x quirk -- when the layout's
// `yield_content` capture path interacts with <template> blocks inside the
// view, surrounding content "disappeared". v0.1 polish reproduced this
// scenario after the Sprint 4 cleanup pass moved yield_content to
// `raw safe(yield_content(&block))` and it now renders cleanly. So we're
// back to the cleaner <template> + cloneNode pattern.
export default class extends Controller {
  static targets = ["template"]
  static values  = {
    toasterId: { type: String, default: "wabi-toaster" },
  }

  spawn(event) {
    const key      = event.params.key
    const template = this.templateTargets.find((t) => t.dataset.wabiKey === key)
    if (!template) return
    const toaster = document.getElementById(this.toasterIdValue)
    if (!toaster) return
    toaster.appendChild(template.content.cloneNode(true))
  }
}
