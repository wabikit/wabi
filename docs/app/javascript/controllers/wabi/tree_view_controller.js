import { Controller } from "@hotwired/stimulus"
import * as treeView from "@zag-js/tree-view"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

const SEL = (name) => `[data-wabi--tree-view-target="${name}"]`

export default class extends Controller {
  static targets = ["label", "tree"]
  static values = {
    items:           Array,
    selectionMode:   { type: String, default: "single" },
    withCheckboxes:  Boolean,
    defaultExpanded: Array,
    defaultSelected: Array,
  }

  connect() {
    this.collection = treeView.collection({
      rootNode: { value: "ROOT", label: "", children: this.itemsValue },
      nodeToValue:    (n) => n.value,
      nodeToString:   (n) => n.label,
      nodeToChildren: (n) => n.children ?? [],
      getNodeDisabled: (n) => n.disabled === true,
    })

    this.machine = new VanillaMachine(treeView.machine, {
      id: this.element.id || crypto.randomUUID(),
      collection: this.collection,
      selectionMode: this.selectionModeValue,
      defaultExpandedValue: this.defaultExpandedValue,
      defaultSelectedValue: this.defaultSelectedValue,
      onExpandedChange:  ({ expandedValue })  => this.dispatch("expand", { detail: { expandedValue } }),
      onSelectionChange: ({ selectedValue })  => this.dispatch("select", { detail: { selectedValue } }),
      onCheckedChange:   ({ checkedValue })   => this.dispatch("check",  { detail: { checkedValue } }),
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
    const api = treeView.connect(this.machine.service, normalizeProps)

    spreadProps(this.element, api.getRootProps())
    if (this.hasLabelTarget) spreadProps(this.labelTarget, api.getLabelProps())
    if (this.hasTreeTarget)  spreadProps(this.treeTarget,  api.getTreeProps())

    // Walk every node element and spread its props. querySelector is scoped to
    // `el`: each node's direct-child sub-parts (branchControl/branchText/…) always
    // precede its branchContent in DOM order, and descendant nodes live inside that
    // branchContent — so el.querySelector(...) always returns the node's OWN
    // sub-part, never a descendant's. (Keep the row before branchContent in the markup.)
    this.element.querySelectorAll("[data-wabi-value]").forEach((el) => {
      const indexPath = JSON.parse(el.dataset.wabiIndexPath)
      const node = this.collection.at(indexPath)
      if (!node) return
      const np = { node, indexPath }

      if (el.dataset.wabiRole === "branch") {
        spreadProps(el, api.getBranchProps(np))
        const control = el.querySelector(SEL("branchControl"))
        if (control) spreadProps(control, api.getBranchControlProps(np))
        const trigger = el.querySelector(SEL("branchTrigger"))
        if (trigger) spreadProps(trigger, api.getBranchTriggerProps(np))
        const indicator = el.querySelector(SEL("branchIndicator"))
        if (indicator) spreadProps(indicator, api.getBranchIndicatorProps(np))
        const text = el.querySelector(SEL("branchText"))
        if (text) spreadProps(text, api.getBranchTextProps(np))
        const content = el.querySelector(SEL("branchContent"))
        if (content) spreadProps(content, api.getBranchContentProps(np))
      } else {
        spreadProps(el, api.getItemProps(np))
        const text = el.querySelector(SEL("itemText"))
        if (text) spreadProps(text, api.getItemTextProps(np))
        const indicator = el.querySelector(SEL("itemIndicator"))
        if (indicator) spreadProps(indicator, api.getItemIndicatorProps(np))
      }

      if (this.withCheckboxesValue) {
        const cb = el.querySelector(SEL("nodeCheckbox"))
        if (cb) spreadProps(cb, api.getNodeCheckboxProps(np))
      }
    })
  }
}
