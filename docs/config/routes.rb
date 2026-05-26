Rails.application.routes.draw do
  root "pages#home"
  get "/preview",                     to: "pages#preview"
  get "/docs/getting-started",        to: "pages#getting_started", as: :getting_started_doc
  get "/docs/philosophy",             to: "pages#philosophy",      as: :philosophy_doc
  get "/docs/theming",                to: "pages#theming",         as: :theming_doc
  get "/docs/themes",                 to: "pages#themes"
  get "/docs/components",             to: "components#index", as: :component_index
  get "/docs/components/:name",       to: "components#show",  as: :component_doc,
      constraints: { name: /[a-z][a-z0-9_]*/ }

  # Registry endpoints — consumed by the wabi CLI in user apps
  get "/r/:name",                     to: "registry#show", as: :registry_component, constraints: { name: /[a-z][a-z0-9_]*/ }
  get "/r/:name.json",                to: "registry#show",                              constraints: { name: /[a-z][a-z0-9_]*/ }
  get "/r/themes/:slug.css",          to: "registry#theme", as: :registry_theme,
      constraints: { slug: /(_shared|[a-z][a-z0-9_]*)/ }
end
