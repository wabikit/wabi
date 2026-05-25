# End-to-end smoke test

Procedure (last run: 2026-05-25, Sprint 0):

1. Boot registry + docs: `cd registry && mise exec -- bundle exec bin/build; cd ../docs && mise exec -- bin/dev`
2. Generate fresh Rails app: `mise exec -- rails new /tmp/wabi-smoke --css=tailwind --javascript=importmap`
3. Add wabi path-dep + phlex-rails to Gemfile, run `bundle install`
4. `bin/rails g phlex:install`
5. Register `UI` acronym in `config/initializers/inflections.rb`
6. `bin/rails g wabi:install`
7. `bin/rails g wabi:registry http://localhost:3000/r`
8. `bin/rails g wabi:add button`
9. Wrap generated button in `module Components` for Phlex 2.x autoload
10. Append `@import "./wabi/tokens.css";` to `app/assets/tailwind/application.css`
11. Render `Components::UI::Button` in a Phlex view, with `stylesheet_link_tag("tailwind", "data-turbo-track": "reload")`
12. Boot smoke app on port 4000, verify in browser: Button shows with primary color, large size
