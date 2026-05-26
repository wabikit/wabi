import { Controller } from "@hotwired/stimulus"

// Two-state toggle: "preview" (default) shows the live render, "code"
// shows the syntax-highlighted source. The trigger buttons carry
// data-active so CSS variants can highlight the current selection without
// our touching their class lists.
export default class extends Controller {
  static targets = ["preview", "code"]

  show(event) {
    const which = event.params.tab
    if (this.hasPreviewTarget) this.previewTarget.hidden = which !== "preview"
    if (this.hasCodeTarget)    this.codeTarget.hidden    = which !== "code"

    this.element.querySelectorAll("button[data-site--preview-tabs-tab-param]").forEach((btn) => {
      const isActive = btn.dataset["sitePreviewTabsTabParam"] === which
      btn.dataset.active = String(isActive)
    })
  }
}
