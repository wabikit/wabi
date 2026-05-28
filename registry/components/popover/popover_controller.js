import { Controller } from "@hotwired/stimulus"
import * as popover from "@zag-js/popover"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { WabiPortalRegistry } from "controllers/wabi/_shared/portal_registry"

export default class extends Controller {
  static targets = ["trigger", "positioner", "content", "closeTrigger"]
  static values  = {
    open:   { type: Boolean, default: false },
    modal:  { type: Boolean, default: false },
    portal: { type: Boolean, default: true  },
  }

  connect() {
    this.contentEl    = this.hasContentTarget    ? this.contentTarget    : null
    this.positionerEl = this.hasPositionerTarget ? this.positionerTarget : null
    this.triggerEl    = this.hasTriggerTarget    ? this.triggerTarget    : null
    this.closeTriggerEls = this.contentEl
      ? Array.from(this.contentEl.querySelectorAll('[data-wabi--popover-target="closeTrigger"]'))
      : []

    this.originalParents = {
      content:    this.contentEl?.parentNode,
      positioner: this.positionerEl?.parentNode,
    }

    this.portaled = this.portalValue
    if (this.portaled) this.attachToBody()

    this.machine = new VanillaMachine(popover.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      modal: this.modalValue,
      onOpenChange: ({ open }) => {
        this.openValue = open
        WabiPortalRegistry.onOpenChange()
        if (this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
        }
        this.dispatch("change", { detail: { open } })
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    if (this.portaled) WabiPortalRegistry.register(this)
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    if (this.portaled) {
      WabiPortalRegistry.unregister(this)
      this.restoreFromBody()
    }
  }

  isOpen() { return this.openValue }

  attachToBody() {
    [this.contentEl, this.positionerEl].forEach((el) => {
      if (el && el.parentNode !== document.body) document.body.appendChild(el)
    })
  }

  restoreFromBody() {
    if (this.contentEl    && this.originalParents.content)    this.originalParents.content.appendChild(this.contentEl)
    if (this.positionerEl && this.originalParents.positioner) this.originalParents.positioner.appendChild(this.positionerEl)
  }

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
