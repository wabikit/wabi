import { Controller } from "@hotwired/stimulus"
import * as carousel from "@zag-js/carousel"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["itemGroup", "item", "control", "prevTrigger", "nextTrigger", "indicatorGroup", "indicator"]
  static values  = {
    slideCount:    Number,
    slidesPerPage: { type: Number,  default: 1 },
    slidesPerMove: { type: Number,  default: 1 },
    loop:          { type: Boolean, default: false },
    orientation:   { type: String,  default: "horizontal" },
    autoplay:      { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(carousel.machine, {
      id: this.element.id || crypto.randomUUID(),
      slideCount: this.slideCountValue,
      slidesPerPage: this.slidesPerPageValue,
      slidesPerMove: this.slidesPerMoveValue,
      loop: this.loopValue,
      orientation: this.orientationValue,
      autoplay: this.autoplayValue || undefined,
      onPageChange: ({ page }) => this.dispatch("change", { detail: { page } }),
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
  }

  render() {
    const api = carousel.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
    if (this.hasItemGroupTarget)      spreadProps(this.itemGroupTarget,      api.getItemGroupProps())
    if (this.hasControlTarget)        spreadProps(this.controlTarget,        api.getControlProps())
    if (this.hasPrevTriggerTarget)    spreadProps(this.prevTriggerTarget,    api.getPrevTriggerProps())
    if (this.hasNextTriggerTarget)    spreadProps(this.nextTriggerTarget,    api.getNextTriggerProps())
    if (this.hasIndicatorGroupTarget) spreadProps(this.indicatorGroupTarget, api.getIndicatorGroupProps())

    this.itemTargets.forEach((el) => spreadProps(el, api.getItemProps({ index: parseInt(el.dataset.wabiIndex, 10) })))
    this.indicatorTargets.forEach((el) => spreadProps(el, api.getIndicatorProps({ index: parseInt(el.dataset.wabiIndex, 10) })))
  }
}
