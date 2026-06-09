import { Controller } from "@hotwired/stimulus"
import * as datePicker from "@zag-js/date-picker"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { parseDate } from "@internationalized/date"
import { capturePortalRefs, attachToBody, restoreFromBody } from "controllers/wabi/_shared/overlay_portal"

const DAY_CELL_CLASS =
  "w-9 h-9 inline-flex items-center justify-center rounded-md text-sm transition-colors motion-reduce:transition-none " +
  "hover:bg-accent hover:text-accent-foreground " +
  "data-[selected]:bg-primary data-[selected]:text-primary-foreground data-[selected]:hover:bg-primary " +
  "data-[today]:font-bold data-[outside-range]:text-muted-foreground/40 " +
  "data-[disabled]:opacity-40 data-[disabled]:pointer-events-none"

// Range "tunnel": the connecting band lives on the CELL (via :has on the trigger's
// data-in-range / data-*-hover-range), so adjacent cells form a continuous strip and
// the primary-colored endpoints (on the button) sit on top without a class collision.
const RANGE_CELL_CLASS =
  "p-0 text-center " +
  "[&:has([data-in-range])]:bg-accent [&:has([data-in-hover-range])]:bg-accent/50 " +
  "[&:has([data-range-start])]:rounded-l-md [&:has([data-hover-range-start])]:rounded-l-md " +
  "[&:has([data-range-end])]:rounded-r-md [&:has([data-hover-range-end])]:rounded-r-md"

export default class extends Controller {
  static targets = [
    "control", "input", "trigger", "positioner", "content",
    "viewControl", "prev", "next", "viewTrigger",
    "gridHead", "grid", "hiddenStart", "hiddenEnd",
  ]
  static values = {
    name:          String,
    selectionMode: { type: String, default: "single" },
    locale:        { type: String, default: "en-US" },
    defaultValue:  String,
    min:           String,
    max:           String,
    numOfMonths:   { type: Number, default: 1 },
    disabled:      { type: Boolean, default: false },
    readonly:      { type: Boolean, default: false },
    portal:        { type: Boolean, default: true },
  }

  connect() {
    capturePortalRefs(this) // sets this.contentEl / this.positionerEl (null for inline Calendar)

    this.controlEl     = this.hasControlTarget     ? this.controlTarget     : null
    this.inputEl       = this.hasInputTarget       ? this.inputTarget       : null
    this.triggerEl     = this.hasTriggerTarget     ? this.triggerTarget     : null
    this.hiddenStartEl = this.hasHiddenStartTarget ? this.hiddenStartTarget : null
    this.hiddenEndEl   = this.hasHiddenEndTarget   ? this.hiddenEndTarget   : null

    const scope = this.contentEl || this.element
    this.viewControlEl = scope.querySelector('[data-wabi--date-picker-target="viewControl"]')
    this.prevEl        = scope.querySelector('[data-wabi--date-picker-target="prev"]')
    this.nextEl        = scope.querySelector('[data-wabi--date-picker-target="next"]')
    this.viewTriggerEl = scope.querySelector('[data-wabi--date-picker-target="viewTrigger"]')
    this.gridHeadEl    = scope.querySelector('[data-wabi--date-picker-target="gridHead"]')
    this.gridEl        = scope.querySelector('[data-wabi--date-picker-target="grid"]')

    this.portaled = this.portalValue && !!this.positionerEl
    if (this.portaled) attachToBody(this)

    const defaults = this.defaultValueValue
      ? this.defaultValueValue.split(",").filter(Boolean).map((s) => parseDate(s))
      : undefined

    // Inline Calendar (no positioner at all) renders an always-visible grid.
    // Zag's `inline` flag forces the machine into the `open` state so day cells
    // are interactive (CELL.CLICK is only handled while open). A field DatePicker
    // has a positioner (popover) and opens via its trigger — this must be false
    // even when portal:false (positioner kept in-tree rather than moved to body).
    this.inline = !this.positionerEl // inline calendar (no positioner) starts open; a field with a positioner opens via its trigger, even when portal:false

    this.machine = new VanillaMachine(datePicker.machine, {
      id: this.element.id || crypto.randomUUID(),
      locale: this.localeValue,
      selectionMode: this.selectionModeValue,
      numOfMonths: this.numOfMonthsValue,
      inline: this.inline,
      defaultValue: defaults,
      min: this.minValue ? parseDate(this.minValue) : undefined,
      max: this.maxValue ? parseDate(this.maxValue) : undefined,
      disabled: this.disabledValue,
      readOnly: this.readonlyValue,
      onValueChange: (details) => {
        this.syncHidden(details.value)
        this.dispatch("change", { detail: { valueAsString: details.valueAsString } })
      },
      onOpenChange: ({ open }) => {
        if (this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
        }
        this.dispatch("toggle", { detail: { open } })
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
    this.syncHidden(this.api.value)
  }

  disconnect() {
    cancelAnimationFrame(this.rangeInputRaf)
    this.unsubscribe?.()
    this.machine?.stop()
    if (this.portaled) restoreFromBody(this)
  }

  get api() { return datePicker.connect(this.machine.service, normalizeProps) }

  render() {
    const api = this.api
    spreadProps(this.element, api.getRootProps())
    if (this.controlEl) spreadProps(this.controlEl, api.getControlProps())
    if (this.inputEl) {
      spreadProps(this.inputEl, api.getInputProps())
      // getInputProps() reflects only index 0 (the start date), so a single
      // collapsed field would hide the end of a range. Show the whole selection
      // joined as "start – end". Zag ALSO re-syncs this input to the start inside
      // a requestAnimationFrame that lands AFTER this synchronous render — so on
      // the first range pick the field would flash to start-only until the next
      // render. Re-assert the full range on the next frame too: this rAF is
      // registered after Zag's (render runs after the machine reaction), so it wins.
      if (this.selectionModeValue === "range") {
        const rangeText = (api.valueAsString || []).filter(Boolean).join(" – ")
        this.inputEl.value = rangeText
        cancelAnimationFrame(this.rangeInputRaf)
        this.rangeInputRaf = requestAnimationFrame(() => {
          if (this.inputEl) this.inputEl.value = rangeText
        })
      }
    }
    if (this.triggerEl) spreadProps(this.triggerEl, api.getTriggerProps())
    if (this.positionerEl) spreadProps(this.positionerEl, api.getPositionerProps())
    if (this.contentEl) { spreadProps(this.contentEl, api.getContentProps()); this.contentEl.hidden = false }

    if (this.viewControlEl) spreadProps(this.viewControlEl, api.getViewControlProps({ view: "day" }))
    if (this.prevEl) spreadProps(this.prevEl, api.getPrevTriggerProps())
    if (this.nextEl) spreadProps(this.nextEl, api.getNextTriggerProps())
    if (this.viewTriggerEl) {
      spreadProps(this.viewTriggerEl, api.getViewTriggerProps({ view: "day" }))
      this.viewTriggerEl.textContent = api.visibleRangeText.start
    }
    this.renderGrid(api)
  }

  renderGrid(api) {
    // Renders the first visible month from api.weeks. Multi-month side-by-side
    // (num_of_months > 1) is deferred — range selection still works across months
    // via prev/next navigation.
    if (this.gridHeadEl) {
      this.gridHeadEl.innerHTML = ""
      api.weekDays.forEach((wd) => {
        const th = document.createElement("th")
        th.scope = "col"
        th.setAttribute("aria-label", wd.long)
        th.className = "w-9 h-9 text-xs font-normal text-muted-foreground"
        th.textContent = wd.narrow
        this.gridHeadEl.appendChild(th)
      })
    }
    if (!this.gridEl) return
    this.gridEl.innerHTML = ""
    api.weeks.forEach((week) => {
      const tr = document.createElement("tr")
      week.forEach((day) => {
        const td = document.createElement("td")
        spreadProps(td, api.getDayTableCellProps({ value: day }))
        td.className = RANGE_CELL_CLASS
        const btn = document.createElement("button")
        btn.type = "button"
        spreadProps(btn, api.getDayTableCellTriggerProps({ value: day }))
        btn.className = DAY_CELL_CLASS
        btn.textContent = String(day.day)
        td.appendChild(btn)
        tr.appendChild(td)
      })
      this.gridEl.appendChild(tr)
    })
  }

  syncHidden(value) {
    const iso = (d) => (d ? d.toString() : "")
    if (this.hiddenStartEl) this.hiddenStartEl.value = iso(value && value[0])
    if (this.hiddenEndEl)   this.hiddenEndEl.value   = iso(value && value[1])
  }
}
