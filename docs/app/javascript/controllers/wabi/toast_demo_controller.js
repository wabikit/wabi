import { Controller } from "@hotwired/stimulus"

// Demo-only controller: stores three pre-rendered Toast HTML strings as
// Stimulus String values, then injects the chosen one into #wabi-toaster
// using insertAdjacentHTML. Production apps would use Turbo Streams
// (`turbo_stream.append "wabi-toaster", Components::UI::Toast.new(...)`)
// instead; the docs site has no backend emitting streams, so this demo
// wires the equivalent client-side.
//
// Avoids <template> tags because Phlex 2.x + phlex-rails has rendering
// quirks where `template do ... end` blocks inside a Phlex view_template
// can swallow the surrounding content (Sprint 4 Task 2 debugging).
export default class extends Controller {
  static values  = {
    toasterId:       { type: String, default: "wabi-toaster" },
    infoHtml:        String,
    successHtml:     String,
    destructiveHtml: String,
  }

  spawn(event) {
    const key  = event.params.key
    const html = this[`${key}HtmlValue`]
    if (!html) return
    const toaster = document.getElementById(this.toasterIdValue)
    if (!toaster) return
    toaster.insertAdjacentHTML("beforeend", html)
  }
}
