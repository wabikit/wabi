import { Controller } from "@hotwired/stimulus"
import * as popover from "@zag-js/popover"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { WabiPortalRegistry } from "controllers/wabi/_shared/portal_registry"
import { capturePortalRefs, attachToBody, restoreFromBody } from "controllers/wabi/_shared/overlay_portal"

export default class extends Controller {
  static targets = ["trigger", "positioner", "content", "closeTrigger"]
  static values  = {
    open:   { type: Boolean, default: false },
    modal:  { type: Boolean, default: false },
    portal: { type: Boolean, default: true  },
  }

  connect() {
    capturePortalRefs(this)
    this.triggerEl    = this.hasTriggerTarget    ? this.triggerTarget    : null
    this.closeTriggerEls = this.contentEl
      ? Array.from(this.contentEl.querySelectorAll('[data-wabi--popover-target="closeTrigger"]'))
      : []

    this.portaled = this.portalValue
    this.isModalOverlay = this.modalValue
    if (this.portaled) attachToBody(this)

    this.machine = new VanillaMachine(popover.machine, {
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

  render() {
    const api = popover.connect(this.machine.service, normalizeProps)
    if (this.triggerEl)    spreadProps(this.triggerEl,    api.getTriggerProps())
    if (this.positionerEl) spreadProps(this.positionerEl, api.getPositionerProps())
    if (this.contentEl) {
      spreadProps(this.contentEl, api.getContentProps())
      this.contentEl.hidden = false
    }
    this.closeTriggerEls.forEach((el) => spreadProps(el, api.getCloseTriggerProps()))
  }
}
