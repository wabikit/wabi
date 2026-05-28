import { Controller } from "@hotwired/stimulus"
import * as tooltip from "@zag-js/tooltip"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { WabiPortalRegistry } from "controllers/wabi/_shared/portal_registry"

export default class extends Controller {
  static targets = ["trigger", "positioner", "content"]
  static values  = {
    openDelay:  { type: Number,  default: 700   },
    closeDelay: { type: Number,  default: 300   },
    open:       { type: Boolean, default: false },
    portal:     { type: Boolean, default: true  },
  }

  connect() {
    this.contentEl    = this.hasContentTarget    ? this.contentTarget    : null
    this.positionerEl = this.hasPositionerTarget ? this.positionerTarget : null
    this.triggerEl    = this.hasTriggerTarget    ? this.triggerTarget    : null
    this.originalParents = {
      positioner: this.positionerEl?.parentNode,
    }

    this.portaled = this.portalValue
    if (this.portaled) this.attachToBody()

    this.machine = new VanillaMachine(tooltip.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      openDelay:   this.openDelayValue,
      closeDelay:  this.closeDelayValue,
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
    // Move positioner; content rides along inside it (do not extract).
    if (this.positionerEl && this.positionerEl.parentNode !== document.body) {
      document.body.appendChild(this.positionerEl)
    }
  }

  restoreFromBody() {
    if (this.positionerEl && this.originalParents.positioner) this.originalParents.positioner.appendChild(this.positionerEl)
  }

  render() {
    const api = tooltip.connect(this.machine.service, normalizeProps)
    if (this.triggerEl)    spreadProps(this.triggerEl,    api.getTriggerProps())
    if (this.positionerEl) spreadProps(this.positionerEl, api.getPositionerProps())
    if (this.contentEl) {
      spreadProps(this.contentEl, api.getContentProps())
      this.contentEl.hidden = false
    }
  }
}
