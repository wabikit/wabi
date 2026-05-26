import { Controller } from "@hotwired/stimulus"
import * as dialog from "@zag-js/dialog"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["trigger", "portal", "backdrop", "positioner", "content", "title", "description", "closeTrigger"]
  static values  = {
    open:  { type: Boolean, default: false },
    modal: { type: Boolean, default: true  },
  }

  connect() {
    this.machine = new VanillaMachine(dialog.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      modal: this.modalValue,
      onOpenChange: ({ open }) => {
        this.openValue = open
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
  }

  open()  { this.api()?.setOpen(true)  }
  close() { this.api()?.setOpen(false) }

  api() {
    return this.machine && dialog.connect(this.machine.service, normalizeProps)
  }

  render() {
    const api = this.api()
    if (!api) return

    if (this.hasTriggerTarget)     spreadProps(this.triggerTarget,    api.getTriggerProps())
    if (this.hasPositionerTarget)  spreadProps(this.positionerTarget, api.getPositionerProps())
    if (this.hasTitleTarget)       spreadProps(this.titleTarget,       api.getTitleProps())
    if (this.hasDescriptionTarget) spreadProps(this.descriptionTarget, api.getDescriptionProps())
    this.closeTriggerTargets.forEach((el) => spreadProps(el, api.getCloseTriggerProps()))

    // Backdrop + content: spreadProps sets data-state + hidden. We KEEP
    // data-state (CSS uses it for transitions) but force-clear hidden so
    // display:none doesn't cut off the fade-out. `inert` on the content
    // takes over for tab order + screen-reader hiding when closed.
    if (this.hasBackdropTarget) {
      spreadProps(this.backdropTarget, api.getBackdropProps())
      this.backdropTarget.hidden = false
    }
    if (this.hasContentTarget) {
      spreadProps(this.contentTarget, api.getContentProps())
      // Visibility lives on `data-state` (CSS opacity + pointer-events). We
      // force `hidden=false` so the fade-out can actually run instead of
      // display:none cutting it off. inert is left to the user for now --
      // setting it timing-correctly with Zag's focus trap is fiddly (a v0.2
      // a11y task).
      this.contentTarget.hidden = false
    }
  }
}
