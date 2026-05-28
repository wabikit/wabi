import { Controller } from "@hotwired/stimulus"
import * as toast from "@zag-js/toast"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

// Toaster controller. Hosts a @zag-js/toast group machine + a createStore for
// group-level config (placement/gap/max/overlap). Each rendered toast gets its
// OWN VanillaMachine instance wrapping `toast.machine`; the group machine
// orchestrates the queue, individual machines own per-toast timer/state.
//
// To create a toast: use the Stimulus controller's `create(opts)` method
// (proxies to the store), via window.wabiToaster.create() in JS or via the
// `wabi_toast_create` custom Turbo Stream action.
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
    // Group-level config goes into the store. Per-toast options (duration,
    // type, swipe overrides) are passed at create() time.
    this.store = toast.createStore({
      overlap:   false,
      placement: this.placementValue,
      gap:       this.gapValue,
      max:       this.maxValue,
    })

    this.machine = new VanillaMachine(toast.group.machine, {
      id:    this.element.id || "wabi-toaster",
      store: this.store,
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()

    // Per-toast machine registry. Created on first render of an actor,
    // stopped + removed when the actor is no longer in getToasts().
    this.itemMachines  = new Map()  // id -> VanillaMachine
    this.itemUnsubs    = new Map()  // id -> unsubscribe fn

    this.render()

    this.boundIntercept = this.interceptStream.bind(this)
    document.addEventListener("turbo:before-stream-render", this.boundIntercept)
    window.wabiToaster = this
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    this.itemUnsubs.forEach((unsub) => unsub?.())
    this.itemMachines.forEach((m) => m.stop())
    this.itemUnsubs.clear()
    this.itemMachines.clear()
    document.removeEventListener("turbo:before-stream-render", this.boundIntercept)
    if (window.wabiToaster === this) delete window.wabiToaster
  }

  // Public API — proxies to the store.
  create(opts) { return this.store.create({ duration: this.durationValue, ...opts }) }
  dismiss(id)  { this.store.dismiss(id) }
  pause(id)    { this.store.pause(id)   }
  resume(id)   { this.store.resume(id)  }

  render() {
    if (!this.machine?.service) return
    const groupApi = toast.group.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, groupApi.getGroupProps())

    const toasts    = groupApi.getToasts()
    const wantedIds = new Set(toasts.map((t) => t.id))

    // Tear down DOM + machines for actors no longer present.
    this.toastEls().forEach((el) => {
      const id = el.dataset.toastId
      if (wantedIds.has(id)) return
      this.itemUnsubs.get(id)?.()
      this.itemMachines.get(id)?.stop()
      this.itemUnsubs.delete(id)
      this.itemMachines.delete(id)
      el.remove()
    })

    // Materialize new actors + render every visible item.
    toasts.forEach((actor, index) => {
      if (!this.itemMachines.has(actor.id)) {
        const el = this.cloneTemplate(actor)
        this.element.appendChild(el)

        const itemMachine = new VanillaMachine(toast.machine, {
          ...actor,
          index,
          parent: this.machine.service,
        })
        const unsub = itemMachine.subscribe(() => this.renderItem(actor.id))
        itemMachine.start()
        this.itemMachines.set(actor.id, itemMachine)
        this.itemUnsubs.set(actor.id, unsub)
      }
      this.renderItem(actor.id)
    })
  }

  renderItem(id) {
    const el          = this.element.querySelector(`[data-toast-id="${id}"]`)
    const itemMachine = this.itemMachines.get(id)
    if (!el || !itemMachine?.service) return

    const itemApi = toast.connect(itemMachine.service, normalizeProps)
    spreadProps(el, itemApi.getRootProps())

    const titleEl = el.querySelector('[data-slot="title"]')
    const descEl  = el.querySelector('[data-slot="description"]')

    if (titleEl) {
      spreadProps(titleEl, itemApi.getTitleProps())
      titleEl.textContent = itemApi.title || ""
    }
    if (descEl) {
      spreadProps(descEl, itemApi.getDescriptionProps())
      descEl.textContent = itemApi.description || ""
    }

    el.querySelectorAll('[data-slot="close"]').forEach((c) => {
      spreadProps(c, itemApi.getCloseTriggerProps())
    })
  }

  toastEls() {
    return Array.from(this.element.querySelectorAll("[data-toast-id]"))
  }

  cloneTemplate(actor) {
    const tpl = this.templateTarget.content.firstElementChild.cloneNode(true)
    tpl.dataset.toastId = actor.id
    if (actor.type) tpl.classList.add(`appearance-${actor.type}`)
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
