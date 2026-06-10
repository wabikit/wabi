// One-off verification: portaled overlays must close + restore on
// turbo:before-cache so back-navigation doesn't leave orphaned open overlays.
// Drives the real docs site (Turbo enabled) in headless Chrome.
//
//   cd docs && bin/rails server -p 3007 &
//   cd registry && node scripts/verify_turbo_cache.mjs
import puppeteer from "puppeteer-core"

const BASE = (process.env.BASE_URL || "http://localhost:3007").replace(/\/$/, "")
const CHROME = process.env.CHROME_PATH || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

const log = (s) => console.log(s)
let failures = 0
const check = (label, ok, detail = "") => {
  log(`${ok ? "PASS" : "FAIL"}  ${label}${detail ? ` — ${detail}` : ""}`)
  if (!ok) failures++
}

const overlayState = (page) =>
  page.evaluate(() => {
    const open = [...document.querySelectorAll('[data-state="open"]')].map(
      (el) => `${el.tagName.toLowerCase()}${el.id ? `#${el.id}` : ""}.${[...el.classList].slice(0, 2).join(".")}`
    )
    const bodyPortals = [...document.body.children].filter((el) =>
      el.matches('[data-wabi--dialog-target], [data-wabi--popover-target], [class*="positioner"], [data-part="positioner"]')
    ).length
    const backdropVisible = [...document.querySelectorAll('[data-wabi--dialog-target="backdrop"]')].some((el) => {
      const cs = getComputedStyle(el)
      return cs.display !== "none" && cs.visibility !== "hidden" && cs.opacity !== "0" && el.getAttribute("data-state") === "open"
    })
    return { open, bodyPortals, backdropVisible }
  })

const browser = await puppeteer.launch({ executablePath: CHROME, headless: "new" })
const page = await browser.newPage()
await page.setViewport({ width: 1280, height: 900 })

// ---------- Scenario 1: modal dialog ----------
log("\n== Dialog page ==")
await page.goto(`${BASE}/docs/components/dialog`, { waitUntil: "networkidle0" })
await page.waitForSelector('[data-controller~="wabi--dialog"]', { timeout: 10000 })

// open the first dialog demo
await page.click('[data-wabi--dialog-target="trigger"]')
await page.waitForSelector('[data-wabi--dialog-target="content"][data-state="open"]', { timeout: 5000 })
let s = await overlayState(page)
check("dialog opens", s.open.length > 0, s.open.join(", "))

// Turbo-navigate away via a real sidebar link (history entry + cache snapshot)
await Promise.all([
  page.waitForNavigation({ waitUntil: "networkidle0" }),
  page.evaluate(() => {
    const link = [...document.querySelectorAll('a[href$="/docs/components/button"]')].at(0)
    link.click()
  }),
])
check("navigated to /docs/components/button", page.url().includes("/docs/components/button"))

// back → Turbo restores the cached snapshot
await Promise.all([page.waitForNavigation({ waitUntil: "networkidle0" }), page.goBack()])
await new Promise((r) => setTimeout(r, 600)) // let Stimulus reconnect settle
s = await overlayState(page)
check("no orphaned open overlay after back", s.open.length === 0, s.open.join(", ") || "clean")
check("no visible backdrop after back", !s.backdropVisible)

// the dialog must still WORK on the restored page
await page.click('[data-wabi--dialog-target="trigger"]')
try {
  await page.waitForSelector('[data-wabi--dialog-target="content"][data-state="open"]', { timeout: 5000 })
  check("dialog re-opens after restore", true)
} catch {
  check("dialog re-opens after restore", false, "trigger click did not open the dialog")
}
// and close it again via Escape
await page.keyboard.press("Escape")
await new Promise((r) => setTimeout(r, 300))
s = await overlayState(page)
check("dialog closes again via Escape", s.open.length === 0, s.open.join(", ") || "clean")

// ---------- Scenario 2: popover (no public close()) ----------
log("\n== Popover page ==")
await page.goto(`${BASE}/docs/components/popover`, { waitUntil: "networkidle0" })
await page.waitForSelector('[data-controller~="wabi--popover"]', { timeout: 10000 })
await page.click('[data-wabi--popover-target="trigger"]')
await page.waitForSelector('[data-wabi--popover-target="content"][data-state="open"]', { timeout: 5000 })
check("popover opens", true)

await Promise.all([
  page.waitForNavigation({ waitUntil: "networkidle0" }),
  page.evaluate(() => [...document.querySelectorAll('a[href$="/docs/components/button"]')].at(0).click()),
])
await Promise.all([page.waitForNavigation({ waitUntil: "networkidle0" }), page.goBack()])
await new Promise((r) => setTimeout(r, 600))
s = await overlayState(page)
check("no orphaned open popover after back", s.open.length === 0, s.open.join(", ") || "clean")

await page.click('[data-wabi--popover-target="trigger"]')
try {
  await page.waitForSelector('[data-wabi--popover-target="content"][data-state="open"]', { timeout: 5000 })
  check("popover re-opens after restore", true)
} catch {
  check("popover re-opens after restore", false)
}

// ---------- Scenario 3 (probe): rapid double back/forward with select ----------
log("\n== Select page (probe: forward + back twice) ==")
await page.goto(`${BASE}/docs/components/select`, { waitUntil: "networkidle0" })
await page.waitForSelector('[data-controller~="wabi--select"]', { timeout: 10000 })
await page.click('[data-wabi--select-target="trigger"]')
await new Promise((r) => setTimeout(r, 400))
await Promise.all([
  page.waitForNavigation({ waitUntil: "networkidle0" }),
  page.evaluate(() => [...document.querySelectorAll('a[href$="/docs/components/button"]')].at(0).click()),
])
await Promise.all([page.waitForNavigation({ waitUntil: "networkidle0" }), page.goBack()])
await Promise.all([page.waitForNavigation({ waitUntil: "networkidle0" }), page.goForward()])
await Promise.all([page.waitForNavigation({ waitUntil: "networkidle0" }), page.goBack()])
await new Promise((r) => setTimeout(r, 600))
s = await overlayState(page)
check("select page clean after back/forward/back", s.open.length === 0, s.open.join(", ") || "clean")
const dup = await page.evaluate(
  () => document.querySelectorAll('[data-wabi--select-target="content"]').length
)
const triggers = await page.evaluate(
  () => document.querySelectorAll('[data-wabi--select-target="trigger"]').length
)
check("no duplicated select portals", dup <= triggers, `content nodes: ${dup}, triggers: ${triggers}`)

await page.screenshot({ path: "/tmp/turbo_cache_verify.png" })
await browser.close()
log(`\n${failures === 0 ? "ALL CHECKS PASSED" : `${failures} CHECK(S) FAILED`}`)
process.exit(failures === 0 ? 0 : 1)
