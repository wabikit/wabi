import { Controller } from "@hotwired/stimulus"
import * as menu from "@zag-js/menu"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["trigger", "positioner", "content", "item", "optionItem", "optionItemIndicator"]
  static values  = {
    open: { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(menu.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      onSelect: ({ value }) => {
        this.handleOptionToggle(value)
        this.dispatch("select", { detail: { value } })
      },
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

  // Mutate optionItem state in the DOM so the next render() picks up new
  // checked values via the data-wabi-checked attribute. Zag's menu machine
  // does not own the checked state -- callers wire it via onSelect.
  handleOptionToggle(value) {
    if (!this.hasOptionItemTarget) return
    const target = this.optionItemTargets.find((el) => el.dataset.wabiValue === value)
    if (!target) return
    const type = target.dataset.wabiType
    if (type === "checkbox") {
      target.dataset.wabiChecked = target.dataset.wabiChecked === "true" ? "false" : "true"
    } else if (type === "radio") {
      const name = target.dataset.wabiName
      this.optionItemTargets
        .filter((el) => el.dataset.wabiType === "radio" && el.dataset.wabiName === name)
        .forEach((el) => { el.dataset.wabiChecked = (el === target ? "true" : "false") })
    }
  }

  render() {
    const api = menu.connect(this.machine.service, normalizeProps)
    if (this.hasTriggerTarget)    spreadProps(this.triggerTarget,    api.getTriggerProps())
    if (this.hasPositionerTarget) spreadProps(this.positionerTarget, api.getPositionerProps())
    if (this.hasContentTarget) {
      spreadProps(this.contentTarget, api.getContentProps())
      // Visibility lives on data-state for animation; inert keeps content out
      // of tab order + a11y tree when closed (see Sprint 4 cleanup).
      this.contentTarget.hidden = false
    }

    // Regular menuitem items.
    this.itemTargets.forEach((el) => {
      spreadProps(el, api.getItemProps({
        value:    el.dataset.wabiValue,
        disabled: el.dataset.wabiDisabled === "true",
      }))
    })

    // Option items (checkbox / radio).
    this.optionItemTargets.forEach((el) => {
      const value   = el.dataset.wabiValue
      const type    = el.dataset.wabiType    // "checkbox" | "radio"
      const checked = el.dataset.wabiChecked === "true"
      spreadProps(el, api.getOptionItemProps({
        type, value, checked,
        disabled: el.dataset.wabiDisabled === "true",
      }))
    })

    // Indicators inside option items: hidden mirrors the ancestor's
    // data-wabi-checked. Easier and more deterministic than relying on
    // CSS group-data variants here.
    this.optionItemIndicatorTargets.forEach((indicator) => {
      const parent = indicator.closest("[data-wabi--dropdown-menu-target='optionItem']")
      indicator.hidden = !(parent && parent.dataset.wabiChecked === "true")
    })
  }
}
