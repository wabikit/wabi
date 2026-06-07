import { describe, it, expect } from "vitest"
import Controller from "./tags_input_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as tagsInput from "@zag-js/tags-input"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--tags-input"
const api = (ctrl) => tagsInput.connect(ctrl.machine.service, normalizeProps)
const hiddens = () => [...root().querySelectorAll(':scope > input[type="hidden"][data-wabi--tags-input-hidden="true"]')]
const tags = () => [...root().querySelectorAll('[data-wabi--tags-input-tag="true"]')]

const FIXTURE = (attrs) => `
  <div data-controller="wabi--tags-input" ${attrs}>
    <div data-wabi--tags-input-target="control">
      <input type="text" data-wabi--tags-input-target="input">
    </div>
  </div>`

describe("wabi--tags-input", () => {
  it("mirrors initial tags to name[] hidden inputs and renders tag nodes", async () => {
    mount(ID, Controller, FIXTURE(`data-wabi--tags-input-name-value="tags" data-wabi--tags-input-value-value='["ruby","rails"]'`))
    await tick()
    const hs = hiddens()
    expect(hs.length).toBe(2)
    expect(hs.map((i) => i.name)).toEqual(["tags[]", "tags[]"])
    expect(hs.map((i) => i.value)).toEqual(["ruby", "rails"])
    expect(tags().length).toBe(2)
  })

  it("re-syncs hidden inputs with no leak when a tag is removed", async () => {
    const h = mount(ID, Controller, FIXTURE(`data-wabi--tags-input-name-value="tags" data-wabi--tags-input-value-value='["ruby","rails"]'`))
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    api(ctrl).setValue(["ruby"])
    await tick()
    expect(hiddens().length).toBe(1)
    expect(hiddens()[0].value).toBe("ruby")
    expect(tags().length).toBe(1)
  })
})
