// Automated accessibility audit: runs axe-core (WCAG 2.0/2.1 A + AA) over every
// component's docs page in real headless Chrome. Catches what jsdom/unit-tests
// can't (focus, contrast, computed roles). See ../../A11Y-TESTING.md for the
// manual screen-reader layer this complements.
//
// Usage (the docs server must be running):
//   cd docs && bin/rails server -p 3007 -e development &   # or any port
//   cd registry && BASE_URL=http://localhost:3007 pnpm run a11y
//
// Env:
//   BASE_URL    docs origin (default http://localhost:3007)
//   CHROME_PATH path to a Chrome/Chromium binary (default: macOS system Chrome)
//
// Exit code: 1 if any NEW component-level violation is found (regression gate);
// 0 if clean or only KNOWN/ACCEPTED findings remain (see ACCEPTED below).

import { createRequire } from "module"
import { readdirSync } from "fs"
import { fileURLToPath } from "url"
import { dirname, join } from "path"
import puppeteer from "puppeteer-core"
import fs from "fs"

const require = createRequire(import.meta.url)
const axeSource = fs.readFileSync(require.resolve("axe-core/axe.min.js"), "utf8")

const here = dirname(fileURLToPath(import.meta.url))
const BASE = (process.env.BASE_URL || "http://localhost:3007").replace(/\/$/, "")
const CHROME = process.env.CHROME_PATH || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

// Rules that fire on the DOCS SITE chrome, not the components (the docs <html> has
// no lang; the syntax-highlighted code blocks are scrollable-but-not-focusable).
// Fix those in the docs app, not here — they're out of scope for the library audit.
const DOCS_CHROME = new Set([
  "html-has-lang", "scrollable-region-focusable", "region",
  "landmark-one-main", "page-has-heading-one", "document-title", "landmark-unique",
])

// Known, triaged, deliberately-accepted component findings (documented in each
// component's docs Accessibility section + docs/superpowers/2026-06-09-axe-audit-triage.md).
// Keyed by `${component}/${ruleId}`. Anything NOT here is a regression → exit 1.
const ACCEPTED = new Set([
  "alert_dialog/aria-valid-attr-value", // trigger aria-controls -> portaled content absent while closed (Zag)
  "file_upload/nested-interactive",     // focusable dropzone contains the browse button (Zag); both operable
  "tree_view/nested-interactive",       // branch role=button contains the selection checkbox (Zag); both operable
  "tags_input/color-contrast",          // disabled-tag text; WCAG 1.4.3 exempts inactive components
])

const components = readdirSync(join(here, "..", "components"), { withFileTypes: true })
  .filter((d) => d.isDirectory() && !d.name.startsWith("_"))
  .map((d) => d.name)
  .sort()

const browser = await puppeteer.launch({ executablePath: CHROME, headless: true, args: ["--no-sandbox"] })
let regressions = 0
let accepted = 0
let first = true
for (const name of components) {
  const page = await browser.newPage()
  try {
    await page.goto(`${BASE}/docs/components/${name}`, { waitUntil: "networkidle2", timeout: first ? 90000 : 30000 })
    first = false
    await new Promise((r) => setTimeout(r, 500))
    await page.evaluate(axeSource)
    const res = await page.evaluate(async () =>
      await window.axe.run(document, { runOnly: { type: "tag", values: ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"] } })
    )
    const real = res.violations.filter((v) => !DOCS_CHROME.has(v.id))
    const newFindings = real.filter((v) => !ACCEPTED.has(`${name}/${v.id}`))
    accepted += real.length - newFindings.length
    if (newFindings.length) {
      regressions += newFindings.length
      console.log(`XX ${name}`)
      newFindings.forEach((v) => console.log(`   NEW ${v.id} [${v.impact}] x${v.nodes.length}: ${v.nodes[0]?.html.replace(/\s+/g, " ").slice(0, 100)}`))
    } else {
      console.log(`ok ${name}${real.length ? ` (${real.length} accepted)` : ""}`)
    }
  } catch (e) {
    console.log(`ERR ${name}: ${e.message}`)
    regressions++
  } finally {
    await page.close()
  }
}
await browser.close()
console.log(`\n=== ${regressions === 0 ? "PASS" : "FAIL"}: ${regressions} new finding(s), ${accepted} accepted (documented) ===`)
process.exit(regressions === 0 ? 0 : 1)
