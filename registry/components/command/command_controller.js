import { Controller } from "@hotwired/stimulus"

// Bridge between the nested wabi--combobox (selection events) and the
// outer wabi--dialog (close action). Because the dialog portal moves the
// combobox under <body>, the combobox's bubbled change event can no
// longer reach the Command root via DOM ancestry. Solution: listen on
// `document` and filter by id linkage — every Command root has a unique
// `data-wabi--command-id` and we stamp the same id onto the dialog
// content at connect so the event's composedPath includes a matching
// element.
//
// Also listens for wabi--dialog:change to auto-open the nested combobox
// when the palette opens, so item clicks work without typing first.
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
    this.boundOnDialogChange   = this.onDialogChange.bind(this)
    document.addEventListener("wabi--combobox:change", this.boundOnComboboxChange)
    document.addEventListener("wabi--dialog:change",   this.boundOnDialogChange)
  }

  disconnect() {
    if (this.boundOnComboboxChange) document.removeEventListener("wabi--combobox:change", this.boundOnComboboxChange)
    if (this.boundOnDialogChange)   document.removeEventListener("wabi--dialog:change",   this.boundOnDialogChange)
  }

  onComboboxChange(event) {
    if (!this.eventBelongsToThisCommand(event)) return
    const dialogController = this.application.getControllerForElementAndIdentifier(
      this.element, "wabi--dialog"
    )
    if (dialogController) dialogController.close()
  }

  onDialogChange(event) {
    if (!this.eventBelongsToThisCommand(event)) return
    // Find the nested combobox controller and mirror open state.
    // commandId is `cmd-<UUID>` (SecureRandom.uuid) — only [0-9a-f-], so it's
    // safe to interpolate into this attribute selector without escaping.
    const dialogContent = document.querySelector(
      `[data-wabi--dialog-target="content"][data-wabi--command-id="${this.commandId}"]`
    )
    const comboboxRoot = dialogContent?.querySelector('[data-controller~="wabi--combobox"]')
    if (!comboboxRoot) return
    const comboboxController = this.application.getControllerForElementAndIdentifier(
      comboboxRoot, "wabi--combobox"
    )
    if (!comboboxController) return
    if (event.detail.open) comboboxController.open()
    else                   comboboxController.close()
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
