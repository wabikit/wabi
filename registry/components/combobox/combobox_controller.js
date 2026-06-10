import { Controller } from "@hotwired/stimulus"
import * as combobox from "@zag-js/combobox"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { attachToBody, restoreFromBody } from "controllers/wabi/_shared/overlay_portal"

export default class extends Controller {
  static targets = ["label", "control", "input", "trigger", "positioner", "content", "item", "itemIndicator", "hiddenInput", "loading", "error"]
  static values  = {
    name:        String,
    items:       Array,
    value:       String,
    placeholder: { type: String,  default: "Select an option..." },
    disabled:    { type: Boolean, default: false },
    portal:      { type: Boolean, default: true  },
    url:         { type: String,  default: "" },
    param:       { type: String,  default: "q" },
    debounce:    { type: Number,  default: 250 },
    minLength:   { type: Number,  default: 1 },
  }

  connect() {
    // Capture refs BEFORE portal move (Sprint 9 trap).
    this.contentEl    = this.hasContentTarget    ? this.contentTarget    : null
    this.positionerEl = this.hasPositionerTarget ? this.positionerTarget : null

    // In-content targets need capture before move (Sprint 9 trap).
    this.itemEls = this.contentEl
      ? Array.from(this.contentEl.querySelectorAll('[data-wabi--combobox-target="item"]'))
      : []
    this.itemIndicatorEls = this.contentEl
      ? Array.from(this.contentEl.querySelectorAll('[data-wabi--combobox-target="itemIndicator"]'))
      : []

    this.originalParents = {
      positioner: this.positionerEl?.parentNode,
    }

    this.portaled = this.portalValue
    if (this.portaled) attachToBody(this)

    // When items-value is empty (e.g. Command palette renders items as static
    // HTML rather than passing a JSON array), build the collection from the
    // captured DOM elements so Zag can spread getItemProps onto them.
    const domItems = this.itemEls.map((el) => ({
      value:    el.dataset.wabiValue    || "",
      label:    el.dataset.wabiLabel    || el.textContent.trim(),
      // CommandItem always emits data-wabi-disabled="true|false". (ComboboxItem
      // emits data-disabled only when disabled — but ComboboxItem is never used
      // in this DOM-fallback path: standalone comboboxes always pass items-value.)
      disabled: el.hasAttribute("data-disabled") || el.dataset.wabiDisabled === "true",
    }))
    this.items = this.itemsValue.length > 0 ? this.itemsValue : domItems

    const collection = combobox.collection({
      items: this.items,
      itemToString: (item) => item.label,
      itemToValue:  (item) => item.value,
      isItemDisabled: (item) => item.disabled === true,
    })

    this.machine = new VanillaMachine(combobox.machine, {
      id: this.element.id || crypto.randomUUID(),
      collection,
      // Intentionally NOT passing `name` to the machine. Zag would forward it to
      // the visible <input>, which then submits the LABEL ("Ruby on Rails")
      // instead of the VALUE ("rails"). We mirror the value to a hidden input
      // on every change for form submission instead.
      defaultValue: this.valueValue ? [this.valueValue] : undefined,
      disabled: this.disabledValue,
      placeholder: this.placeholderValue,
      onValueChange: ({ value }) => {
        this.valueValue = value[0] || ""
        if (this.hasHiddenInputTarget) this.hiddenInputTarget.value = this.valueValue
        this.dispatch("change", { detail: { value: value[0] } })
      },
      onOpenChange: ({ open }) => {
        if (this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
        }
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()

    if (this.urlValue) {
      this.boundOnAsyncInput = this.onAsyncInput.bind(this)
      this.inputTarget?.addEventListener("input", this.boundOnAsyncInput)
    }
  }

  disconnect() {
    this._disconnected = true
    if (this.boundOnAsyncInput) this.inputTarget?.removeEventListener("input", this.boundOnAsyncInput)
    this.abortController?.abort()
    clearTimeout(this.debounceTimer)
    this.unsubscribe?.()
    this.machine?.stop()
    if (this.portaled) restoreFromBody(this)
  }

  // Imperative open/close actions, used by sibling controllers (e.g. the
  // wabi--command bridge auto-opens this combobox when its dialog opens).
  open() {
    if (!this.machine) return
    const api = combobox.connect(this.machine.service, normalizeProps)
    if (typeof api.setOpen === "function") api.setOpen(true)
  }

  close() {
    if (!this.machine) return
    const api = combobox.connect(this.machine.service, normalizeProps)
    if (typeof api.setOpen === "function") api.setOpen(false)
  }

  onAsyncInput(event) {
    const query = event.target.value
    clearTimeout(this.debounceTimer)
    if (query.length < this.minLengthValue) return
    this.debounceTimer = setTimeout(() => this.fetchItems(query), this.debounceValue)
  }

  async fetchItems(query) {
    if (this._disconnected || !this.contentEl) return
    this.abortController?.abort()
    const controller = (this.abortController = new AbortController())
    this.showLoading(true)
    this.showError(false)
    try {
      const sep = this.urlValue.includes("?") ? "&" : "?"
      const url = `${this.urlValue}${sep}${encodeURIComponent(this.paramValue)}=${encodeURIComponent(query)}`
      const res = await fetch(url, { headers: { Accept: "text/html" }, signal: controller.signal })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const html = await res.text()
      if (this._disconnected) return
      this.replaceItems(html)
    } catch (err) {
      if (err.name === "AbortError") return  // superseded by a newer keystroke / disconnect
      console.warn("wabi--combobox: async fetch failed; keeping prior results", err)
      this.showError(true)
    } finally {
      // Only the LATEST fetch clears loading — a superseded fetch's finally
      // must not hide the indicator while a newer fetch is still in flight.
      if (this.abortController === controller) this.showLoading(false)
    }
  }

  // Toggle the loading indicator: a data attr on the content (styling hook)
  // plus the optional ComboboxLoading slot's `hidden` attribute (what the
  // user actually sees). The slot ref is cached because innerHTML swaps in
  // replaceItems destroy + re-prepend it.
  // NOTE: the content is portaled to <body>, so Stimulus's target registry
  // doesn't see it — we query the DOM directly via _loadingEl().
  _loadingEl() {
    // Prefer cached ref (survives innerHTML swaps via replaceItems re-prepend).
    if (this.__loadingEl?.isConnected) return this.__loadingEl
    // Fall back to DOM query on contentEl (first fetch, or after re-connect).
    const el = this.contentEl?.querySelector('[data-wabi--combobox-target="loading"]')
    if (el) this.__loadingEl = el
    return el || null
  }

  showLoading(on) {
    if (this.contentEl) {
      if (on) this.contentEl.setAttribute("data-wabi--combobox-loading", "true")
      else    this.contentEl.removeAttribute("data-wabi--combobox-loading")
    }
    // Toggle sr-only instead of the `hidden` attribute so the aria-live region
    // stays in the accessibility tree at all times (WCAG live-region requirement).
    const el = this._loadingEl()
    if (el) { if (on) el.classList.remove("sr-only"); else el.classList.add("sr-only") }
  }

  _errorEl() {
    // Prefer cached ref (survives innerHTML swaps via replaceItems re-prepend).
    if (this.__errorEl?.isConnected) return this.__errorEl
    // Fall back to DOM query on contentEl (first fetch, or after re-connect).
    const el = this.contentEl?.querySelector('[data-wabi--combobox-target="error"]')
    if (el) this.__errorEl = el
    return el || null
  }

  // Toggle sr-only instead of the `hidden` attribute so the aria-live region
  // stays in the accessibility tree at all times (WCAG live-region requirement).
  showError(on) {
    const el = this._errorEl()
    if (el) { if (on) el.classList.remove("sr-only"); else el.classList.add("sr-only") }
  }

  replaceItems(html) {
    if (this._disconnected || !this.machine) return
    // Preserve the loading and error slots across the innerHTML swap (they live
    // inside the content and would otherwise be destroyed, breaking later fetches).
    const loadingEl = this._loadingEl()
    const errorEl = this._errorEl()
    this.contentEl.innerHTML = html
    if (loadingEl) { this.contentEl.prepend(loadingEl); this.__loadingEl = loadingEl }
    if (errorEl) { this.contentEl.prepend(errorEl); this.__errorEl = errorEl }
    this.showError(false)
    this.itemEls = Array.from(this.contentEl.querySelectorAll('[data-wabi--combobox-target="item"]'))
    this.itemIndicatorEls = Array.from(this.contentEl.querySelectorAll('[data-wabi--combobox-target="itemIndicator"]'))
    this.items = this.itemEls.map((el) => ({
      value:    el.dataset.wabiValue || "",
      label:    el.dataset.wabiLabel || el.textContent.trim(),
      disabled: el.hasAttribute("data-disabled") || el.dataset.wabiDisabled === "true",
    }))
    const collection = combobox.collection({
      items: this.items,
      itemToString: (item) => item.label,
      itemToValue:  (item) => item.value,
      isItemDisabled: (item) => item.disabled === true,
    })
    this.machine.updateProps({ collection })
    this.render()
  }

  render() {
    const api = combobox.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())

    if (this.hasLabelTarget)    spreadProps(this.labelTarget,    api.getLabelProps())
    if (this.hasControlTarget)  spreadProps(this.controlTarget,  api.getControlProps())
    if (this.hasInputTarget)    spreadProps(this.inputTarget,    api.getInputProps())
    if (this.hasTriggerTarget)  spreadProps(this.triggerTarget,  api.getTriggerProps())
    if (this.positionerEl)      spreadProps(this.positionerEl,   api.getPositionerProps())
    if (this.contentEl) {
      spreadProps(this.contentEl, api.getContentProps())
      this.contentEl.hidden = false
    }

    this.itemEls.forEach((el) => {
      const value = el.dataset.wabiValue
      const item  = this.items.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemProps({ item }))
    })

    this.itemIndicatorEls.forEach((el) => {
      // Walk up to the nearest item element to look up the item object,
      // then spread Zag's per-item indicator props (toggles `hidden` based
      // on whether the item is currently selected).
      const itemEl = el.closest('[data-wabi--combobox-target="item"]')
      const value  = itemEl?.dataset.wabiValue
      const item   = this.items.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemIndicatorProps({ item }))
    })
  }
}
