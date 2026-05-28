import { Controller } from "@hotwired/stimulus"
import * as menu from "@zag-js/menu"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { WabiPortalRegistry } from "controllers/wabi/_shared/portal_registry"

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
    open:   { type: Boolean, default: false },
    portal: { type: Boolean, default: true  },
  }

  connect() {
    this.contentEl    = this.hasContentTarget    ? this.contentTarget    : null
    this.positionerEl = this.hasPositionerTarget ? this.positionerTarget : null
    this.triggerEl    = this.hasTriggerTarget    ? this.triggerTarget    : null

    // Sub portal nodes: collect content/positioner per sub by index.
    this.subContentEls    = []
    this.subPositionerEls = []
    this.subTargets.forEach((subEl, idx) => {
      this.subContentEls[idx]    = subEl.querySelector("[data-wabi--dropdown-menu-target='subContent']")
      this.subPositionerEls[idx] = subEl.querySelector("[data-wabi--dropdown-menu-target='subPositioner']")
    })

    this.originalParents = {
      content:    this.contentEl?.parentNode,
      positioner: this.positionerEl?.parentNode,
      subContent: this.subContentEls.map((el) => el?.parentNode),
      subPositioner: this.subPositionerEls.map((el) => el?.parentNode),
    }

    this.portaled = this.portalValue
    if (this.portaled) this.attachToBody()

    this.machine = new VanillaMachine(menu.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      onSelect: ({ value }) => {
        this.handleOptionToggle(value)
        this.dispatch("select", { detail: { value } })
      },
      onOpenChange: ({ open }) => {
        this.openValue = open
        WabiPortalRegistry.onOpenChange()
        if (!this.portaled && this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
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
          WabiPortalRegistry.onOpenChange()
          if (!this.portaled) {
            const subContEl = this.subContentEls[idx]
            if (subContEl) {
              if (open) subContEl.removeAttribute("inert")
              else      subContEl.setAttribute("inert", "")
            }
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

    if (this.portaled) WabiPortalRegistry.register(this)
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    // Stop sub machines BEFORE portal cleanup so any final onOpenChange
    // from a stopping sub doesn't race the body-DOM restore.
    this.subUnsubscribes?.forEach((unsub) => unsub?.())
    this.subMachines?.forEach((sub) => sub.stop())
    if (this.portaled) {
      WabiPortalRegistry.unregister(this)
      this.restoreFromBody()
    }
  }

  isOpen() {
    if (this.openValue) return true
    return this.subMachines.some((sub) => {
      const api = menu.connect(sub.service, normalizeProps)
      return api.open
    })
  }

  attachToBody() {
    [this.contentEl, this.positionerEl].forEach((el) => {
      if (el && el.parentNode !== document.body) document.body.appendChild(el)
    })
    this.subContentEls.forEach((el) => {
      if (el && el.parentNode !== document.body) document.body.appendChild(el)
    })
    this.subPositionerEls.forEach((el) => {
      if (el && el.parentNode !== document.body) document.body.appendChild(el)
    })
  }

  restoreFromBody() {
    if (this.contentEl    && this.originalParents.content)    this.originalParents.content.appendChild(this.contentEl)
    if (this.positionerEl && this.originalParents.positioner) this.originalParents.positioner.appendChild(this.positionerEl)
    this.subContentEls.forEach((el, idx) => {
      const parent = this.originalParents.subContent[idx]
      if (el && parent) parent.appendChild(el)
    })
    this.subPositionerEls.forEach((el, idx) => {
      const parent = this.originalParents.subPositioner[idx]
      if (el && parent) parent.appendChild(el)
    })
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
    if (this.triggerEl)    spreadProps(this.triggerEl,    api.getTriggerProps())
    if (this.positionerEl) spreadProps(this.positionerEl, api.getPositionerProps())
    if (this.contentEl) {
      spreadProps(this.contentEl, api.getContentProps())
      this.contentEl.hidden = false
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
      const subPosEl  = this.subPositionerEls[idx]
      const subContEl = this.subContentEls[idx]
      if (subPosEl)  spreadProps(subPosEl,  subApi.getPositionerProps())
      if (subContEl) {
        spreadProps(subContEl, subApi.getContentProps())
        subContEl.hidden = false
      }
    })
  }
}
