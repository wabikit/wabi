# Releasing Wabi

The `wabi` gem is published to [RubyGems.org](https://rubygems.org/gems/wabi)
automatically by the [`gem-release`](.github/workflows/gem-release.yml) GitHub
Actions workflow whenever a version tag (`vX.Y.Z`) is pushed. Publishing uses
**Trusted Publishing (OIDC)** — there are no API keys or secrets stored in the
repository; GitHub mints a short-lived token at publish time.

## One-time setup (already done once per repo — documented for the record)

These two steps must exist before the first automated release. They are
configured in web UIs and cannot be scripted.

### 1. Register the Trusted Publisher on RubyGems.org

1. Sign in to rubygems.org as an owner of the `wabi` gem.
2. Go to the gem page → **Trusted publishers** → **Create**.
3. Enter (these must match the workflow exactly):
   - **Repository owner:** `wabikit`
   - **Repository name:** `wabi`
   - **Workflow filename:** `gem-release.yml`
   - **Environment:** `release`

> For the very first publish of a brand-new gem name, RubyGems also supports a
> "pending" trusted publisher (configurable before the gem exists). `wabi`
> already exists, so use the gem-page form above.

### 2. Create the GitHub `release` environment

Repo → **Settings** → **Environments** → **New environment** → name it
`release`. Optionally add a required-reviewer protection rule so a human must
approve each publish. The workflow references `environment: release`, and the
trusted-publisher config above pins the same environment name.

## Cutting a release

All steps run locally on `main` until the final tag push, which triggers CI.

1. **Bump the version** in `gem/lib/wabi/version.rb`.
2. **Update `gem/CHANGELOG.md`** — add the new version section (move items out of
   Unreleased; include the breaking-changes table for `1.0.0`).
3. **Update the README status badge** in `gem/README.md` (line ~7) if it tracks
   the version/status.
4. **Re-bundle the docs app** so its path-gem lockfile picks up the new version:
   `cd docs && mise exec -- bundle install` (updates `docs/Gemfile.lock`).
5. **Commit** the release: `git commit -am "release: vX.Y.Z — <summary>"`.
6. **Tag** it: `git tag vX.Y.Z`. The tag's version **must** match
   `Wabi::VERSION` — the workflow fails the release otherwise.
7. **Push** branch + tag: `git push origin main --tags`.
   - The `main` push triggers the Render deploy (docs + registry; `registry/dist`
     is rebuilt at deploy time).
   - The tag push triggers `gem-release.yml`, which: verifies the tag matches
     `Wabi::VERSION`, runs the gem test suite, builds the gem, pushes it to
     RubyGems via OIDC, and creates the GitHub Release with generated notes.
8. **Verify**: watch the `gem-release` run in the Actions tab, then confirm the
   new version on https://rubygems.org/gems/wabi and the GitHub Releases page.

## What the workflow does NOT do

- **It does not bump the version or tag** — that's a deliberate human step
  (you decide when to release). The workflow only publishes the tag you push.
- **It does not regenerate `gem/templates/tokens.css`** — that file is committed
  and must be current before tagging. If you changed themes, run the registry
  build first (`cd registry && mise exec -- bundle exec ./bin/build`) and commit
  the regenerated `tokens.css`.

## If a release fails

- **Version mismatch**: the tag and `Wabi::VERSION` differ — fix
  `version.rb` (or delete/retag) and push the corrected tag.
- **Tests fail**: the gem suite gates the publish; fix and re-tag.
- **OIDC/permission error**: confirm the Trusted Publisher values on rubygems.org
  match the workflow (owner/repo/filename/environment) and that the `release`
  GitHub environment exists.
- A failed publish is safe to retry: delete the tag (`git push --delete origin
  vX.Y.Z`), fix, and re-push. RubyGems rejects re-pushing an already-published
  version, so a partially-succeeded publish needs a new patch version.
