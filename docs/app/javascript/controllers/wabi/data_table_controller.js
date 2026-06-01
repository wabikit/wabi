import { Controller } from "@hotwired/stimulus"

// Row-selection coordinator for a DataTable. Native checkboxes (no per-row Zag
// machine): a header "select all" + one per row. Toggling updates each row's
// data-state="selected" (TableRow styles data-[state=selected]:bg-muted), keeps
// the select-all checked/indeterminate in sync, and dispatches
// `wabi--data-table:change` with the selected row values for app-side bulk actions.
export default class extends Controller {
  static targets = ["selectAll", "rowCheckbox"]

  connect() {
    this.rowCheckboxTargets.forEach((cb) => this.syncRow(cb))
    this.syncSelectAll()
  }

  toggleAll() {
    const checked = this.hasSelectAllTarget ? this.selectAllTarget.checked : false
    this.rowCheckboxTargets.forEach((cb) => {
      cb.checked = checked
      this.syncRow(cb)
    })
    this.syncSelectAll()
    this.emitChange()
  }

  toggleRow() {
    this.rowCheckboxTargets.forEach((cb) => this.syncRow(cb))
    this.syncSelectAll()
    this.emitChange()
  }

  syncRow(cb) {
    const row = cb.closest("tr")
    if (!row) return
    if (cb.checked) row.dataset.state = "selected"
    else delete row.dataset.state
  }

  syncSelectAll() {
    if (!this.hasSelectAllTarget) return
    const total = this.rowCheckboxTargets.length
    const checked = this.rowCheckboxTargets.filter((cb) => cb.checked).length
    this.selectAllTarget.checked = total > 0 && checked === total
    this.selectAllTarget.indeterminate = checked > 0 && checked < total
  }

  emitChange() {
    const values = this.rowCheckboxTargets.filter((cb) => cb.checked).map((cb) => cb.value)
    this.dispatch("change", { detail: { values, count: values.length } })
  }
}
