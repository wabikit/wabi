import { Controller } from "@hotwired/stimulus"
import * as splitter from "@zag-js/splitter"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["panel", "resizeTrigger"]
  static values  = {
    panels:      Array,
    orientation: { type: String, default: "horizontal" },
    defaultSize: Array,
  }

  connect() {
    this.machine = new VanillaMachine(splitter.machine, {
      id: this.element.id || crypto.randomUUID(),
      panels: this.panelsValue,
      orientation: this.orientationValue,
      defaultSize: this.defaultSizeValue.length ? this.defaultSizeValue : undefined,
      onResize: ({ size }) => this.dispatch("change", { detail: { size } }),
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()

    // Zag's syncSize() runs at start() but bails when the root has no layout yet
    // (inside an inactive tab panel, below the fold, in a closed overlay), leaving
    // `size` empty — so dragging the gutter has no base sizes to resize from and does
    // nothing. ROOT.RESIZE re-runs syncSize against the now-laid-out root. Fire it once
    // the splitter is visible, then stop (so a later re-intersection can't reset a
    // user's drag back to the defaults).
    if ("IntersectionObserver" in window) {
      this.visibilityObserver = new IntersectionObserver((entries) => {
        if (!entries.some((entry) => entry.isIntersecting)) return
        this.machine.service.send({ type: "ROOT.RESIZE" })
        if (this.machine.service.context.get("size").length > 0) {
          this.visibilityObserver.disconnect()
        }
      })
      this.visibilityObserver.observe(this.element)
    }
  }

  disconnect() {
    this.visibilityObserver?.disconnect()
    this.unsubscribe?.()
    this.machine?.stop()
  }

  render() {
    const api = splitter.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
    this.panelTargets.forEach((el) => spreadProps(el, api.getPanelProps({ id: el.dataset.wabiId })))
    this.resizeTriggerTargets.forEach((el) =>
      spreadProps(el, {
        ...api.getResizeTriggerProps({ id: el.dataset.wabiId }),
        "aria-label": el.dataset.wabiLabel || "Resize panels",
      })
    )
  }
}
