import { Controller } from "@hotwired/stimulus"
import * as tooltip from "@zag-js/tooltip"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { capturePortalRefs, attachToBody, restoreFromBody } from "controllers/wabi/_shared/overlay_portal"

export default class extends Controller {
  static targets = ["trigger", "positioner", "content"]
  static values  = {
    openDelay:  { type: Number,  default: 700   },
    closeDelay: { type: Number,  default: 300   },
    open:       { type: Boolean, default: false },
    portal:     { type: Boolean, default: true  },
  }

  connect() {
    capturePortalRefs(this)
    this.triggerEl    = this.hasTriggerTarget    ? this.triggerTarget    : null

    this.portaled = this.portalValue
    if (this.portaled) attachToBody(this)

    this.machine = new VanillaMachine(tooltip.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      openDelay:   this.openDelayValue,
      closeDelay:  this.closeDelayValue,
      onOpenChange: ({ open }) => {
        this.openValue = open
        if (this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
        }
        this.dispatch("change", { detail: { open } })
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    if (this.portaled) {
      restoreFromBody(this)
    }
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
