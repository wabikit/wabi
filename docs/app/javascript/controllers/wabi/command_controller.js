import { Controller } from "@hotwired/stimulus"

// Bridge between the nested wabi--combobox (selection events) and the
// outer wabi--dialog (close action). Because the dialog portal moves the
// combobox under <body>, the combobox's bubbled change event can no
// longer reach the Command root via DOM ancestry. Solution: listen on
// `document` and filter by id linkage — every Command root has a unique
// `data-wabi--command-id` and we stamp the same id onto the dialog
// content at connect so the event's composedPath includes a matching
// element.
export default class extends Controller {
  connect() {
    this.commandId = this.element.getAttribute("data-wabi--command-id")
    if (!this.commandId) {
      console.warn("wabi--command: missing data-wabi--command-id on root; bridge disabled")
      return
    }

    // Stamp the id onto the dialog content so event filtering works
    // post-portal-move. Because wabi--command is listed first in
    // data-controller, it connects before wabi--dialog, so the content
    // is still a descendant here and the stamp lands before the portal move.
    const dialogContent = this.element.querySelector('[data-wabi--dialog-target="content"]')
    if (dialogContent) dialogContent.setAttribute("data-wabi--command-id", this.commandId)

    this.boundOnComboboxChange = this.onComboboxChange.bind(this)
    document.addEventListener("wabi--combobox:change", this.boundOnComboboxChange)
  }

  disconnect() {
    if (this.boundOnComboboxChange) {
      document.removeEventListener("wabi--combobox:change", this.boundOnComboboxChange)
    }
  }

  onComboboxChange(event) {
    if (!this.eventBelongsToThisCommand(event)) return
    const dialogController = this.application.getControllerForElementAndIdentifier(
      this.element, "wabi--dialog"
    )
    if (dialogController) dialogController.close()
  }

  eventBelongsToThisCommand(event) {
    const path = event.composedPath()
    for (const node of path) {
      if (node.nodeType !== 1) continue
      if (node.getAttribute && node.getAttribute("data-wabi--command-id") === this.commandId) return true
    }
    return false
  }
}
