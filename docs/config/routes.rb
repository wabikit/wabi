Rails.application.routes.draw do
  root "pages#home"
  get "/docs/themes", to: "pages#themes"

  # Registry endpoints — consumed by the wabi CLI in user apps
  get "/r/:name", to: "registry#show", as: :registry_component, constraints: { name: /[a-z][a-z0-9_]*/ }
  get "/r/:name.json", to: "registry#show", constraints: { name: /[a-z][a-z0-9_]*/ }
  get "/r/themes/:slug.css", to: "registry#theme", as: :registry_theme,
      constraints: { slug: /(_shared|[a-z][a-z0-9_]*)/ }
end
