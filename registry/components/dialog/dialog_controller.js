import { Controller } from "@hotwired/stimulus"
import * as dialog from "@zag-js/dialog"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { WabiPortalRegistry } from "controllers/wabi/_shared/portal_registry"
import { capturePortalRefs, attachToBody, restoreFromBody } from "controllers/wabi/_shared/overlay_portal"

export default class extends Controller {
  static targets = ["trigger", "backdrop", "positioner", "content", "title", "description", "closeTrigger"]
  static values  = {
    open:   { type: Boolean, default: false },
    modal:  { type: Boolean, default: true  },
    portal: { type: Boolean, default: true  },
  }

  connect() {
    capturePortalRefs(this)
    this.triggerEl    = this.hasTriggerTarget    ? this.triggerTarget    : null

    // Capture in-content targets BEFORE move — Stimulus targets only resolve to
    // descendants of the controller element, but after the move these live under
    // <body>. Items/buttons inside content need their captured refs in render().
    this.closeTriggerEls = this.contentEl
      ? Array.from(this.contentEl.querySelectorAll('[data-wabi--dialog-target="closeTrigger"]'))
      : []
    this.titleEl       = this.contentEl?.querySelector('[data-wabi--dialog-target="title"]') || null
    this.descriptionEl = this.contentEl?.querySelector('[data-wabi--dialog-target="description"]') || null

    this.portaled = this.portalValue
    this.isModalOverlay = this.modalValue
    if (this.portaled) attachToBody(this)

    this.machine = new VanillaMachine(dialog.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      modal: this.modalValue,
      onOpenChange: ({ open }) => {
        this.openValue = open
        if (this.isModalOverlay) WabiPortalRegistry.onOpenChange()
        if (this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
        }
        this.dispatch("change", { detail: { open } })
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    if (this.portaled && this.isModalOverlay) WabiPortalRegistry.register(this)
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    if (this.portaled) {
      restoreFromBody(this)
      if (this.isModalOverlay) WabiPortalRegistry.unregister(this)
    }
  }

  isOpen() { return this.openValue }

  open()  { this.api()?.setOpen(true)  }
  close() { this.api()?.setOpen(false) }

  api() {
    return this.machine && dialog.connect(this.machine.service, normalizeProps)
  }

  render() {
    const api = this.api()
    if (!api) return

    if (this.triggerEl)     spreadProps(this.triggerEl,    api.getTriggerProps())
    if (this.positionerEl)  spreadProps(this.positionerEl, api.getPositionerProps())
    if (this.titleEl)       spreadProps(this.titleEl,       api.getTitleProps())
    if (this.descriptionEl) spreadProps(this.descriptionEl, api.getDescriptionProps())
    this.closeTriggerEls.forEach((el) => spreadProps(el, api.getCloseTriggerProps()))

    if (this.backdropEl) {
      spreadProps(this.backdropEl, api.getBackdropProps())
      this.backdropEl.hidden = false
    }
    if (this.contentEl) {
      spreadProps(this.contentEl, api.getContentProps())
      this.contentEl.hidden = false
      // Zag hardcodes role="dialog" in getContentProps regardless of the machine
      // role prop. Re-apply role="alertdialog" when the Ruby component set alert=true.
      if (this.contentEl.dataset.wabiDialogAlert === "true") {
        this.contentEl.setAttribute("role", "alertdialog")
      }
    }
  }
}
