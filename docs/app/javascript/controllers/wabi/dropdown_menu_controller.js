import { Controller } from "@hotwired/stimulus"
import * as menu from "@zag-js/menu"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { capturePortalRefs, attachToBody, restoreFromBody } from "controllers/wabi/_shared/overlay_portal"

// Single controller owns the parent menu machine AND a child machine per
// `sub` boundary. Nested same-type controllers would collide on Stimulus
// target scoping (a target inside a child controller is hidden from the
// parent), so all sub machinery lives here. Item / option-item targets are
// routed to the right machine via closest("[...-target='sub']").
//
// N-level nesting (v0.7): each `sub` boundary carries a unique
// data-wabi-sub-id. The controller starts every sub machine, then links
// each to its parent — the closest ANCESTOR sub (walked via the DOM), or
// the root menu when there is no ancestor sub — by chaining Zag's
// setChild/setParent. This models a chain instead of a star, so a
// sub-inside-a-sub works to arbitrary depth.
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
    capturePortalRefs(this)
    this.triggerEl = this.hasTriggerTarget ? this.triggerTarget : null

    // In-content targets captured before move.
    this.itemEls                = this.contentEl ? Array.from(this.contentEl.querySelectorAll('[data-wabi--dropdown-menu-target="item"]')) : []
    this.optionItemEls          = this.contentEl ? Array.from(this.contentEl.querySelectorAll('[data-wabi--dropdown-menu-target="optionItem"]')) : []
    this.optionItemIndicatorEls = this.contentEl ? Array.from(this.contentEl.querySelectorAll('[data-wabi--dropdown-menu-target="optionItemIndicator"]')) : []
    this.subTriggerEls          = this.contentEl ? Array.from(this.contentEl.querySelectorAll('[data-wabi--dropdown-menu-target="subTrigger"]')) : []
    this.subEls                 = this.contentEl ? Array.from(this.contentEl.querySelectorAll('[data-wabi--dropdown-menu-target="sub"]')) : []

    // Sub portal nodes: collect content/positioner per sub by index.
    this.subContentEls    = []
    this.subPositionerEls = []
    this.subEls.forEach((subEl, idx) => {
      this.subContentEls[idx]    = subEl.querySelector("[data-wabi--dropdown-menu-target='subContent']")
      this.subPositionerEls[idx] = subEl.querySelector("[data-wabi--dropdown-menu-target='subPositioner']")
    })

    this.portaled = this.portalValue
    if (this.portaled) attachToBody(this)

    this.machine = new VanillaMachine(menu.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      onSelect: ({ value }) => {
        this.handleOptionToggle(value)
        this.dispatch("select", { detail: { value } })
      },
      onOpenChange: ({ open }) => {
        this.openValue = open
        if (this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
        }
        this.dispatch("change", { detail: { open } })
      },
    })

    // Build a sub machine per sub boundary. Tag each `sub` element with its
    // index so render() can route items/option-items inside it.
    // Each sub also carries a unique `data-wabi-sub-id` (set by DropdownMenuSub)
    // so we can look machines up by DOM element across arbitrary nesting depth.
    this.subMachines = []
    this.subMachineBySubId = {}
    this.subEls.forEach((subEl, idx) => {
      subEl.dataset.wabiSubIndex = String(idx)
      const subMachine = new VanillaMachine(menu.machine, {
        id: crypto.randomUUID(),
        onSelect: ({ value }) => {
          this.handleOptionToggle(value)
          this.dispatch("select", { detail: { value } })
        },
        onOpenChange: ({ open }) => {
          const subContEl = this.subContentEls[idx]
          if (subContEl) {
            if (open) subContEl.removeAttribute("inert")
            else      subContEl.setAttribute("inert", "")
          }
        },
      })
      this.subMachines.push(subMachine)
      // Index by the stable sub-id so parent-lookup by DOM walk is O(1).
      const subId = subEl.dataset.wabiSubId
      if (subId) this.subMachineBySubId[subId] = subMachine
    })

    // Start everything before wiring parent <-> child so both services exist.
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.subUnsubscribes = this.subMachines.map((sub) => sub.subscribe(() => this.render()))
    this.subMachines.forEach((sub) => sub.start())

    // setChild / setParent take MenuService (NOT api). Wire after start.
    //
    // N-level chain: each sub walks up the DOM to find its closest ancestor
    // `[data-wabi--dropdown-menu-target="sub"]`. If found, that ancestor sub's
    // machine is the parent; otherwise the root machine is the parent.
    // This generalises the flat star topology (all subs → root) to an
    // arbitrarily-deep chain (sub-inside-sub-inside-sub…).
    this.subEls.forEach((subEl, idx) => {
      const subMachine = this.subMachines[idx]
      if (!subMachine) return

      const parentMachine = this._parentMachineFor(subEl)
      const parentApi = menu.connect(parentMachine.service, normalizeProps)
      parentApi.setChild(subMachine.service)
      const subApi = menu.connect(subMachine.service, normalizeProps)
      subApi.setParent(parentMachine.service)
    })

    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    // Stop sub machines BEFORE portal cleanup so any final onOpenChange
    // from a stopping sub doesn't race the body-DOM restore.
    this.subUnsubscribes?.forEach((unsub) => unsub?.())
    this.subMachines?.forEach((sub) => sub.stop())
    this.subEls?.forEach((subEl) => delete subEl.dataset.wabiSubIndex)
    if (this.portaled) {
      restoreFromBody(this)
    }
  }

  // Closest ancestor sub element for a given sub (null = root level).
  _parentSubElFor(subEl) {
    return subEl.parentElement?.closest("[data-wabi--dropdown-menu-target='sub']") || null
  }

  // The machine that owns a given sub: its ancestor sub's machine, or root.
  _parentMachineFor(subEl) {
    const ancestorSubEl = this._parentSubElFor(subEl)
    if (!ancestorSubEl) return this.machine
    const id = ancestorSubEl.dataset.wabiSubId
    return (id && this.subMachineBySubId[id]) || this.machine
  }

  // Toggles the data-wabi-checked attribute on checkbox/radio option items
  // so the next render() picks up the new checked state. Zag's menu machine
  // doesn't own this state -- callers wire it via onSelect.
  handleOptionToggle(value) {
    if (!this.optionItemEls.length) return
    const target = this.optionItemEls.find((el) => el.dataset.wabiValue === value)
    if (!target) return
    const type = target.dataset.wabiType
    if (type === "checkbox") {
      target.dataset.wabiChecked = target.dataset.wabiChecked === "true" ? "false" : "true"
    } else if (type === "radio") {
      const name = target.dataset.wabiName
      this.optionItemEls
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
    this.itemEls.forEach((el) => {
      spreadProps(el, this.apiFor(el).getItemProps({
        value:    el.dataset.wabiValue,
        disabled: el.dataset.wabiDisabled === "true",
      }))
    })

    // Option items (checkbox / radio), routed by closest sub ancestor.
    this.optionItemEls.forEach((el) => {
      const value   = el.dataset.wabiValue
      const type    = el.dataset.wabiType    // "checkbox" | "radio"
      const checked = el.dataset.wabiChecked === "true"
      spreadProps(el, this.apiFor(el).getOptionItemProps({
        type, value, checked,
        disabled: el.dataset.wabiDisabled === "true",
      }))
    })

    // Option-item indicators: hidden mirrors the ancestor's data-wabi-checked.
    this.optionItemIndicatorEls.forEach((indicator) => {
      const parent = indicator.closest("[data-wabi--dropdown-menu-target='optionItem']")
      indicator.hidden = !(parent && parent.dataset.wabiChecked === "true")
    })

    // Sub triggers: parentApi.getTriggerItemProps(childApi) merges parent
    // getItemProps + child getTriggerProps so the same element acts as
    // both an item in the parent menu AND the trigger for the submenu.
    //
    // For N-level nesting the "parent" of this sub-trigger is NOT always the
    // root menu — it is the machine that owns the menu containing this trigger.
    // We determine that by finding the closest ancestor sub element above the
    // sub boundary that encloses this trigger, then looking up that machine.
    // If no ancestor sub exists, the root machine is the owner.
    this.subTriggerEls.forEach((el) => {
      const subEl = el.closest("[data-wabi--dropdown-menu-target='sub']")
      if (!subEl) return
      const idx = parseInt(subEl.dataset.wabiSubIndex, 10)
      const subMachine = this.subMachines[idx]
      if (!subMachine) return
      const subApi = menu.connect(subMachine.service, normalizeProps)

      // Find the parent machine: walk above subEl to the closest ancestor sub.
      const ownerMachine = this._parentMachineFor(subEl)
      const ownerApi = menu.connect(ownerMachine.service, normalizeProps)
      spreadProps(el, ownerApi.getTriggerItemProps(subApi))
    })

    // Sub positioner + content per sub.
    this.subEls.forEach((subEl, idx) => {
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
