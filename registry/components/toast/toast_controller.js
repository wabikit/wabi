import { Controller } from "@hotwired/stimulus"
import * as toast from "@zag-js/toast"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

// Toaster controller: hosts a single @zag-js/toast group machine. Toasts
// are created via `controller.create({...})` (called by the
// `wabi_toast_create` Turbo Stream action) and the machine handles max,
// gap, swipe, and pause-on-group-hover. There is one Toaster per page by
// default; multi-placement layouts use multiple Toaster components with
// distinct IDs.
export default class extends Controller {
  static targets = ["template"]
  static values  = {
    max:            { type: Number, default: 5 },
    gap:            { type: Number, default: 16 },
    placement:      { type: String, default: "bottom-end" },
    duration:       { type: Number, default: 5000 },
    swipeDirection: { type: String, default: "right" },
  }

  connect() {
    this.machine = new VanillaMachine(toast.group.machine, {
      id:             this.element.id || "wabi-toaster",
      max:            this.maxValue,
      gap:            this.gapValue,
      placement:      this.placementValue,
      swipeDirection: this.swipeDirectionValue,
      overlap:        false,
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()

    this.boundIntercept = this.interceptStream.bind(this)
    document.addEventListener("turbo:before-stream-render", this.boundIntercept)
    window.wabiToaster = this
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    document.removeEventListener("turbo:before-stream-render", this.boundIntercept)
    if (window.wabiToaster === this) delete window.wabiToaster
  }

  create(opts) {
    this.api().create({ duration: this.durationValue, ...opts })
  }
  dismiss(id)  { this.api().dismiss(id)  }
  pause()      { this.api().pause()      }
  resume()     { this.api().resume()     }

  api() {
    return toast.group.connect(this.machine.service, normalizeProps)
  }

  render() {
    const api = this.api()
    spreadProps(this.element, api.getGroupProps())

    const wanted = new Set(api.getToasts().map((t) => t.id))
    this.toastEls().forEach((el) => {
      if (!wanted.has(el.dataset.toastId)) el.remove()
    })

    api.getToasts().forEach((t) => {
      let el = this.element.querySelector(`[data-toast-id="${t.id}"]`)
      if (!el) {
        el = this.cloneTemplate(t)
        this.element.appendChild(el)
      }
      const itemApi = toast.connect(t, normalizeProps)
      spreadProps(el, itemApi.getRootProps())
      const titleEl = el.querySelector('[data-slot="title"]')
      const descEl  = el.querySelector('[data-slot="description"]')
      if (titleEl) titleEl.textContent = t.title  || ""
      if (descEl)  descEl.textContent  = t.description || ""
      el.querySelectorAll('[data-slot="close"]').forEach((c) => {
        spreadProps(c, itemApi.getCloseTriggerProps())
      })
    })
  }

  toastEls() {
    return Array.from(this.element.querySelectorAll("[data-toast-id]"))
  }

  cloneTemplate(t) {
    const tpl = this.templateTarget.content.firstElementChild.cloneNode(true)
    tpl.dataset.toastId = t.id
    if (t.type) tpl.classList.add(`appearance-${t.type}`)
    return tpl
  }

  interceptStream(event) {
    const stream = event.detail?.newStream
    if (!stream) return
    if (stream.getAttribute("action") !== "wabi_toast_create") return
    event.preventDefault()
    const payload = JSON.parse(stream.getAttribute("data-payload") || "{}")
    this.create(payload)
  }
}
