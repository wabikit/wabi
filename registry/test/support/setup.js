import { afterEach } from "vitest"
import { stopAll } from "./mount.js"

// Global teardown: stop any Stimulus Applications a test started, so controllers
// never leak across test files.
afterEach(() => stopAll())
