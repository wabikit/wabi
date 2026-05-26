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
    // v0.1: NO portal move-to-body. Moving the portal subtree out of the
    // controller's scope makes Stimulus lose track of every nested target
    // (positioner/content/backdrop), so the render() guards short-circuit and
    // the dialog opens internally (preventScroll fires) but never becomes
    // visible. position:fixed + z-50 escapes normal flow for the common case.
    // Edge case (transformed ancestor traps fixed positioning) is a v0.2
    // follow-up -- proper portal needs ref capture before move, NOT Stimulus
    // targets.

    this.machine = new VanillaMachine(dialog.machine, {
      id: this.element.id || crypto.randomUUID(),
      // `defaultOpen` keeps the open bindable uncontrolled so the machine can
      // mutate it on trigger click / Escape / interact-outside. Passing
      // `open:` would lock the value to whatever we pass and ignore events.
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

  // Stimulus actions: `data-action="click->wabi--dialog#open"` / `#close`.
  open()  { this.api()?.setOpen(true)  }
  close() { this.api()?.setOpen(false) }

  api() {
    return this.machine && dialog.connect(this.machine.service, normalizeProps)
  }

  render() {
    const api = this.api()
    if (!api) return

    if (this.hasTriggerTarget)     spreadProps(this.triggerTarget,     api.getTriggerProps())
    if (this.hasBackdropTarget)    spreadProps(this.backdropTarget,    api.getBackdropProps())
    if (this.hasPositionerTarget)  spreadProps(this.positionerTarget,  api.getPositionerProps())
    if (this.hasContentTarget)     spreadProps(this.contentTarget,     api.getContentProps())
    if (this.hasTitleTarget)       spreadProps(this.titleTarget,       api.getTitleProps())
    if (this.hasDescriptionTarget) spreadProps(this.descriptionTarget, api.getDescriptionProps())
    this.closeTriggerTargets.forEach((el) => spreadProps(el, api.getCloseTriggerProps()))

    // Zag emits `hidden: !open` on backdrop + content but NOT on positioner.
    // We mirror it manually so the fixed-inset-0 wrapper isn't sitting on top
    // of the page intercepting clicks when the dialog is closed.
    if (this.hasPositionerTarget) this.positionerTarget.hidden = !api.open
  }
}
