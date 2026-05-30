import { Controller } from "@hotwired/stimulus"
import * as slider from "@zag-js/slider"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["label", "track", "range", "thumb", "markerGroup", "marker"]
  static values  = {
    name:        String,
    value:       Array,
    min:         { type: Number, default: 0   },
    max:         { type: Number, default: 100 },
    step:        { type: Number, default: 1   },
    orientation: { type: String, default: "horizontal" },
    disabled:    { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(slider.machine, {
      id: this.element.id || crypto.randomUUID(),
      name: this.nameValue || undefined,
      defaultValue: this.valueValue,
      min: this.minValue,
      max: this.maxValue,
      step: this.stepValue,
      orientation: this.orientationValue,
      disabled: this.disabledValue,
      onValueChange: ({ value }) => {
        this.valueValue = value
        this.dispatch("change", { detail: { value } })
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

  render() {
    const api = slider.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())

    if (this.hasLabelTarget) spreadProps(this.labelTarget, api.getLabelProps())
    if (this.hasTrackTarget) spreadProps(this.trackTarget, api.getTrackProps())
    if (this.hasRangeTarget) spreadProps(this.rangeTarget, api.getRangeProps())

    this.thumbTargets.forEach((el) => {
      const index = parseInt(el.dataset.wabiIndex, 10)
      spreadProps(el, api.getThumbProps({ index }))
    })

    if (this.hasMarkerGroupTarget) spreadProps(this.markerGroupTarget, api.getMarkerGroupProps())
    this.markerTargets.forEach((el) => {
      const value = parseFloat(el.dataset.wabiMarkValue)
      spreadProps(el, api.getMarkerProps({ value }))
    })

    this.syncHiddenInputs()
  }

  syncHiddenInputs() {
    this.element.querySelectorAll(':scope > input[type="hidden"][data-wabi--slider-hidden="true"]').forEach((el) => el.remove())
    if (!this.nameValue) return
    const value = this.valueValue
    if (value.length === 1) {
      this.appendHidden(this.nameValue, value[0])
    } else if (value.length === 2) {
      // Range mode: nested-bracket params so Rails parses
      // params[:price][:min] / params[:price][:max] — strong-params can
      // permit them via params.require(:price).permit(:min, :max).
      // BREAKING in v0.7 from v0.6's `name_min` / `name_max`.
      this.appendHidden(`${this.nameValue}[min]`, value[0])
      this.appendHidden(`${this.nameValue}[max]`, value[1])
    }
  }

  appendHidden(name, value) {
    const inp = document.createElement("input")
    inp.type = "hidden"
    inp.name = name
    inp.value = String(value)
    inp.dataset.wabiSliderHidden = "true"
    this.element.appendChild(inp)
  }
}
