# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# Zag.js machines: pinned to jsdelivr's `+esm` bundle endpoint, which resolves
# all transitive submodule imports to absolute URLs on the same CDN. The previous
# `--from jsdelivr` download mode only fetched each package's `dist/index.mjs`
# and left its sibling submodules (`*.machine.mjs`, `*.connect.mjs`, etc.)
# unresolved -- 404 in the browser, controllers never connected. Only specifiers
# imported directly by our Stimulus controllers need a pin; transitive Zag.js
# packages (anatomy/core/focus-visible/types/utils) ride the absolute URLs
# inside the bundle.
pin "@zag-js/vanilla",  to: "https://cdn.jsdelivr.net/npm/@zag-js/vanilla@1.41.0/+esm"
pin "@zag-js/checkbox", to: "https://cdn.jsdelivr.net/npm/@zag-js/checkbox@1.41.0/+esm"
pin "@zag-js/switch",   to: "https://cdn.jsdelivr.net/npm/@zag-js/switch@1.41.0/+esm"
pin "@zag-js/select",   to: "https://cdn.jsdelivr.net/npm/@zag-js/select@1.41.0/+esm"
pin "@zag-js/dialog",   to: "https://cdn.jsdelivr.net/npm/@zag-js/dialog@1.41.0/+esm"
pin "@zag-js/tooltip",  to: "https://cdn.jsdelivr.net/npm/@zag-js/tooltip@1.41.0/+esm"
pin "@zag-js/popover",  to: "https://cdn.jsdelivr.net/npm/@zag-js/popover@1.41.0/+esm"
pin "@zag-js/menu",     to: "https://cdn.jsdelivr.net/npm/@zag-js/menu@1.41.0/+esm"
pin "@zag-js/tabs",     to: "https://cdn.jsdelivr.net/npm/@zag-js/tabs@1.41.0/+esm"
pin "@zag-js/accordion", to: "https://cdn.jsdelivr.net/npm/@zag-js/accordion@1.41.0/+esm"
pin "@zag-js/toggle",   to: "https://cdn.jsdelivr.net/npm/@zag-js/toggle@1.41.0/+esm"
