import { Controller } from "@hotwired/stimulus"
import * as navigationMenu from "@zag-js/navigation-menu"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { capturePanelRefs, attachPanelsToBody, restorePanelsFromBody } from "controllers/wabi/_shared/overlay_portal"

export default class extends Controller {
  static targets = ["list", "item", "trigger", "content", "link"]
  static values  = {
    orientation: { type: String, default: "horizontal" },
  }

  connect() {
    // Capture the content panels + their parents BEFORE portaling — Stimulus
    // targets stop resolving once a node leaves the controller subtree
    // (the Sprint 9 trap). render() iterates this.panelEls, not contentTargets.
    capturePanelRefs(this)
    attachPanelsToBody(this)

    this.machine = new VanillaMachine(navigationMenu.machine, {
      id: this.element.id || crypto.randomUUID(),
      orientation: this.orientationValue,
      onValueChange: ({ value }) => this.dispatch("change", { detail: { value } }),
    })
    window.addEventListener("scroll", this.reposition, true)
    window.addEventListener("resize", this.reposition)
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    window.removeEventListener("scroll", this.reposition, true)
    window.removeEventListener("resize", this.reposition)
    restorePanelsFromBody(this)
  }

  render() {
    const api = navigationMenu.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
    if (this.hasListTarget) spreadProps(this.listTarget, api.getListProps())

    // Items + triggers stay in the subtree (only content was portaled).
    this.itemTargets.forEach((el)    => spreadProps(el, api.getItemProps({ value: el.dataset.wabiValue })))
    this.triggerTargets.forEach((el) => spreadProps(el, api.getTriggerProps({ value: el.dataset.wabiValue })))

    // Panels live at <body> now; iterate the captured array. Links ride inside
    // each panel, so they also left the subtree — query them per panel.
    this.panelEls.forEach((el) => {
      spreadProps(el, api.getContentProps({ value: el.dataset.wabiValue }))
      el.hidden = false
      el.querySelectorAll('[data-wabi--navigation-menu-target="link"]').forEach((link) =>
        spreadProps(link, api.getLinkProps({ value: link.dataset.wabiValue })))
      const open = el.getAttribute("data-state") === "open"
      if (open) {
        el.removeAttribute("inert")
        this.positionPanel(el)
      } else {
        el.setAttribute("inert", "")
      }
    })
  }

  // Position the panel fixed under its trigger, clamped to the viewport right edge.
  positionPanel(el) {
    const trigger = this.triggerTargets.find((t) => t.dataset.wabiValue === el.dataset.wabiValue)
    if (!trigger) return
    const r = trigger.getBoundingClientRect()
    const width = el.offsetWidth
    let left = r.left
    if (left + width > window.innerWidth - 8) {
      left = Math.max(8, window.innerWidth - width - 8)
    }
    el.style.position = "fixed"
    // Panels anchor below the trigger (top-nav use). Vertical viewport overflow
    // is intentionally not flipped/clamped — out of scope for this fix.
    el.style.top = `${r.bottom + 6}px`
    el.style.left = `${left}px`
  }

  // Bound as a field so the same reference is added and removed as a listener.
  reposition = () => {
    const openPanel = this.panelEls.find((el) => el.getAttribute("data-state") === "open")
    if (openPanel) this.positionPanel(openPanel)
  }
}
