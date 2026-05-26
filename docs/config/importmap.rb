# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@zag-js/dom-query", to: "@zag-js--dom-query.js" # @1.41.0
pin "@zag-js/checkbox", to: "@zag-js--checkbox.js" # @1.41.0
pin "@zag-js/anatomy", to: "@zag-js--anatomy.js" # @1.41.0
pin "@zag-js/core", to: "@zag-js--core.js" # @1.41.0
pin "@zag-js/focus-visible", to: "@zag-js--focus-visible.js" # @1.41.0
pin "@zag-js/types", to: "@zag-js--types.js" # @1.41.0
pin "@zag-js/utils", to: "@zag-js--utils.js" # @1.41.0
pin "@zag-js/switch", to: "@zag-js--switch.js" # @1.41.0
