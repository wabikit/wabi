import { describe, it, expect } from "vitest"
import Controller from "./tree_view_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import * as treeView from "@zag-js/tree-view"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--tree-view"
const root = () => document.querySelector('[data-controller="wabi--tree-view"]')
const ctrlFor = (h) => h.application.getControllerForElementAndIdentifier(root(), ID)
const byValue = (v) => document.querySelector(`[data-wabi-value="${v}"]`)
const sub = (el, name) => el.querySelector(`[data-${ID}-target="${name}"]`)

const HTML = `
  <div data-controller="wabi--tree-view"
       data-wabi--tree-view-items-value='[{"value":"src","label":"src","children":[{"value":"app.rb","label":"app.rb"},{"value":"lib","label":"lib","children":[{"value":"util.rb","label":"util.rb"}]}]},{"value":"README","label":"README.md"}]'
       data-wabi--tree-view-selection-mode-value="single"
       data-wabi--tree-view-with-checkboxes-value="false"
       data-wabi--tree-view-default-expanded-value="[]"
       data-wabi--tree-view-default-selected-value="[]">
    <div data-wabi--tree-view-target="tree">
      <div data-wabi--tree-view-target="branch" data-wabi-value="src" data-wabi-index-path="[0]" data-wabi-role="branch">
        <div data-wabi--tree-view-target="branchControl">
          <button data-wabi--tree-view-target="branchTrigger"><span data-wabi--tree-view-target="branchIndicator"></span></button>
          <span data-wabi--tree-view-target="branchText">src</span>
        </div>
        <div data-wabi--tree-view-target="branchContent">
          <div data-wabi--tree-view-target="item" data-wabi-value="app.rb" data-wabi-index-path="[0,0]" data-wabi-role="item">
            <span data-wabi--tree-view-target="itemText">app.rb</span>
            <span data-wabi--tree-view-target="itemIndicator"></span>
          </div>
          <div data-wabi--tree-view-target="branch" data-wabi-value="lib" data-wabi-index-path="[0,1]" data-wabi-role="branch">
            <div data-wabi--tree-view-target="branchControl">
              <button data-wabi--tree-view-target="branchTrigger"><span data-wabi--tree-view-target="branchIndicator"></span></button>
              <span data-wabi--tree-view-target="branchText">lib</span>
            </div>
            <div data-wabi--tree-view-target="branchContent">
              <div data-wabi--tree-view-target="item" data-wabi-value="util.rb" data-wabi-index-path="[0,1,0]" data-wabi-role="item">
                <span data-wabi--tree-view-target="itemText">util.rb</span>
                <span data-wabi--tree-view-target="itemIndicator"></span>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div data-wabi--tree-view-target="item" data-wabi-value="README" data-wabi-index-path="[1]" data-wabi-role="item">
        <span data-wabi--tree-view-target="itemText">README.md</span>
        <span data-wabi--tree-view-target="itemIndicator"></span>
      </div>
    </div>
  </div>`

describe("wabi--tree-view", () => {
  it("builds the collection and spreads root/tree props on connect", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = ctrlFor(h)
    expect(ctrl.collection).toBeTruthy()
    expect(ctrl.collection.at([0])).toBeTruthy()
    expect(sub(root(), "tree").getAttribute("role")).toBe("tree")
  })

  it("spreads treeitem props onto branch controls and leaf items", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const srcControl = sub(byValue("src"), "branchControl")
    expect(srcControl.getAttribute("role")).toBe("button")
    expect(byValue("README").getAttribute("role")).toBe("treeitem")
  })

  it("expands a branch via the api and dispatches :expand", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = ctrlFor(h)
    const seen = []
    document.addEventListener("wabi--tree-view:expand", (e) => seen.push(e.detail.expandedValue))
    treeView.connect(ctrl.machine.service, normalizeProps).expand(["src"])
    await tick()
    const content = sub(byValue("src"), "branchContent")
    expect(content.getAttribute("data-state")).toBe("open")
    expect(seen.length).toBeGreaterThan(0)
    expect(seen[seen.length - 1]).toContain("src")
  })

  it("selects a node via the api and dispatches :select", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = ctrlFor(h)
    const seen = []
    document.addEventListener("wabi--tree-view:select", (e) => seen.push(e.detail.selectedValue))
    treeView.connect(ctrl.machine.service, normalizeProps).select(["README"])
    await tick()
    expect(byValue("README").getAttribute("data-selected")).not.toBeNull()
    expect(seen[seen.length - 1]).toContain("README")
  })

  it("spreads checkbox props and dispatches :check when checkboxes are enabled", async () => {
    const HTML_CB = `
      <div data-controller="wabi--tree-view"
           data-wabi--tree-view-items-value='[{"value":"src","label":"src","children":[{"value":"app.rb","label":"app.rb"}]}]'
           data-wabi--tree-view-selection-mode-value="multiple"
           data-wabi--tree-view-with-checkboxes-value="true"
           data-wabi--tree-view-default-expanded-value="[]"
           data-wabi--tree-view-default-selected-value="[]">
        <div data-wabi--tree-view-target="tree">
          <div data-wabi--tree-view-target="branch" data-wabi-value="src" data-wabi-index-path="[0]" data-wabi-role="branch">
            <div data-wabi--tree-view-target="branchControl">
              <span data-wabi--tree-view-target="nodeCheckbox"></span>
              <button data-wabi--tree-view-target="branchTrigger"><span data-wabi--tree-view-target="branchIndicator"></span></button>
              <span data-wabi--tree-view-target="branchText">src</span>
            </div>
            <div data-wabi--tree-view-target="branchContent">
              <div data-wabi--tree-view-target="item" data-wabi-value="app.rb" data-wabi-index-path="[0,0]" data-wabi-role="item">
                <span data-wabi--tree-view-target="nodeCheckbox"></span>
                <span data-wabi--tree-view-target="itemText">app.rb</span>
                <span data-wabi--tree-view-target="itemIndicator"></span>
              </div>
            </div>
          </div>
        </div>
      </div>`
    const h = mount(ID, Controller, HTML_CB)
    await tick()
    const ctrl = ctrlFor(h)
    const seen = []
    document.addEventListener("wabi--tree-view:check", (e) => seen.push(e.detail.checkedValue))
    treeView.connect(ctrl.machine.service, normalizeProps).setChecked(["app.rb"])
    await tick()
    const cb = sub(byValue("app.rb"), "nodeCheckbox")
    expect(cb.getAttribute("role")).toBe("checkbox")
    expect(cb.getAttribute("data-state")).toBe("checked")
    expect(seen[seen.length - 1]).toContain("app.rb")
  })
})
