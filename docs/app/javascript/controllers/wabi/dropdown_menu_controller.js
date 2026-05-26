import { Controller } from "@hotwired/stimulus"
import * as menu from "@zag-js/menu"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

// Single controller owns the parent menu machine AND a child machine per
// `sub` boundary. Nested same-type controllers would collide on Stimulus
// target scoping (a target inside a child controller is hidden from the
// parent), so all sub machinery lives here. Item / option-item targets are
// routed to the right machine via closest("[...-target='sub']").
//
// Sub limit for v0.1: single-level nesting. Multi-level nesting works in
// Zag itself (setChild can chain) but needs an extra wrapping pass we
// haven't put in yet -- a sub's items only see this controller, not their
// own sub controller, so a sub-inside-a-sub isn't supported.
export default class extends Controller {
  static targets = [
    "trigger", "positioner", "content", "item", "optionItem", "optionItemIndicator",
    "sub", "subTrigger", "subPositioner", "subContent",
  ]
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
        // inert toggle: synchronous in onOpenChange so it lands before Zag's
        // setInitialFocus action moves focus into the menu. Closes mirror
        // back to inert.
        if (this.hasContentTarget) {
          if (open) this.contentTarget.removeAttribute("inert")
          else      this.contentTarget.setAttribute("inert", "")
        }
        this.dispatch("change", { detail: { open } })
      },
    })

    // Build a sub machine per sub boundary. Tag each `sub` element with its
    // index so render() can route items/option-items inside it.
    this.subMachines = []
    this.subTargets.forEach((subEl, idx) => {
      subEl.dataset.wabiSubIndex = String(idx)
      const subMachine = new VanillaMachine(menu.machine, {
        id: crypto.randomUUID(),
        onSelect: ({ value }) => {
          this.handleOptionToggle(value)
          this.dispatch("select", { detail: { value } })
        },
        onOpenChange: ({ open }) => {
          const contentEl = subEl.querySelector("[data-wabi--dropdown-menu-target='subContent']")
          if (contentEl) {
            if (open) contentEl.removeAttribute("inert")
            else      contentEl.setAttribute("inert", "")
          }
        },
      })
      this.subMachines.push(subMachine)
    })

    // Start everything before wiring parent <-> child so both services exist.
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.subUnsubscribes = this.subMachines.map((sub) => sub.subscribe(() => this.render()))
    this.subMachines.forEach((sub) => sub.start())

    // setChild / setParent take MenuService (NOT api). Wire after start.
    const parentApi = menu.connect(this.machine.service, normalizeProps)
    this.subMachines.forEach((sub) => {
      parentApi.setChild(sub.service)
      const subApi = menu.connect(sub.service, normalizeProps)
      subApi.setParent(this.machine.service)
    })

    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    this.subUnsubscribes?.forEach((unsub) => unsub?.())
    this.subMachines?.forEach((sub) => sub.stop())
  }

  // Toggles the data-wabi-checked attribute on checkbox/radio option items
  // so the next render() picks up the new checked state. Zag's menu machine
  // doesn't own this state -- callers wire it via onSelect.
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

  // Returns the API for the machine that owns this DOM element (parent menu
  // or one of the sub menus, by closest sub ancestor).
  apiFor(el) {
    const subEl = el.closest("[data-wabi--dropdown-menu-target='sub']")
    if (subEl) {
      const idx = parseInt(subEl.dataset.wabiSubIndex, 10)
      const subMachine = this.subMachines[idx]
      if (subMachine) return menu.connect(subMachine.service, normalizeProps)
    }
    return menu.connect(this.machine.service, normalizeProps)
  }

  render() {
    const api = menu.connect(this.machine.service, normalizeProps)
    if (this.hasTriggerTarget)    spreadProps(this.triggerTarget,    api.getTriggerProps())
    if (this.hasPositionerTarget) spreadProps(this.positionerTarget, api.getPositionerProps())
    if (this.hasContentTarget) {
      spreadProps(this.contentTarget, api.getContentProps())
      this.contentTarget.hidden = false
    }

    // Regular menuitem items, routed by closest sub ancestor.
    this.itemTargets.forEach((el) => {
      spreadProps(el, this.apiFor(el).getItemProps({
        value:    el.dataset.wabiValue,
        disabled: el.dataset.wabiDisabled === "true",
      }))
    })

    // Option items (checkbox / radio), routed by closest sub ancestor.
    this.optionItemTargets.forEach((el) => {
      const value   = el.dataset.wabiValue
      const type    = el.dataset.wabiType    // "checkbox" | "radio"
      const checked = el.dataset.wabiChecked === "true"
      spreadProps(el, this.apiFor(el).getOptionItemProps({
        type, value, checked,
        disabled: el.dataset.wabiDisabled === "true",
      }))
    })

    // Option-item indicators: hidden mirrors the ancestor's data-wabi-checked.
    this.optionItemIndicatorTargets.forEach((indicator) => {
      const parent = indicator.closest("[data-wabi--dropdown-menu-target='optionItem']")
      indicator.hidden = !(parent && parent.dataset.wabiChecked === "true")
    })

    // Sub triggers: parentApi.getTriggerItemProps(childApi) merges parent
    // getItemProps + child getTriggerProps so the same element acts as
    // both an item in the parent menu AND the trigger for the submenu.
    this.subTriggerTargets.forEach((el) => {
      const subEl = el.closest("[data-wabi--dropdown-menu-target='sub']")
      if (!subEl) return
      const idx = parseInt(subEl.dataset.wabiSubIndex, 10)
      const subMachine = this.subMachines[idx]
      if (!subMachine) return
      const subApi = menu.connect(subMachine.service, normalizeProps)
      spreadProps(el, api.getTriggerItemProps(subApi))
    })

    // Sub positioner + content per sub.
    this.subTargets.forEach((subEl, idx) => {
      const subMachine = this.subMachines[idx]
      if (!subMachine) return
      const subApi = menu.connect(subMachine.service, normalizeProps)
      const subPosEl  = subEl.querySelector("[data-wabi--dropdown-menu-target='subPositioner']")
      const subContEl = subEl.querySelector("[data-wabi--dropdown-menu-target='subContent']")
      if (subPosEl)  spreadProps(subPosEl,  subApi.getPositionerProps())
      if (subContEl) {
        spreadProps(subContEl, subApi.getContentProps())
        subContEl.hidden = false
      }
    })
  }
}
