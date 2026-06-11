# frozen_string_literal: true

require "net/http"
require "json"

module Components
  module Site
    # Header link to the GitHub repo, styled as a "Star {count}" button. The
    # star count is fetched server-side from the GitHub API and cached for an
    # hour, so the unauthenticated 60-req/hr limit is never a concern (≈1 call/hr
    # total, not per visitor) and there's no external script or CSP change. If the
    # fetch fails (network, rate limit, cold start) the button still renders —
    # just without the count — so the header never breaks.
    class GithubStar < Components::Base
      REPO      = "wabikit/wabi"
      REPO_URL  = "https://github.com/#{REPO}"
      API_URL   = "https://api.github.com/repos/#{REPO}"
      CACHE_KEY = "github_stars:#{REPO}"

      # Octicon "mark-github"
      GITHUB_SVG = '<svg class="h-4 w-4 shrink-0" viewBox="0 0 16 16" fill="currentColor" ' \
                   'aria-hidden="true"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 ' \
                   '5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94' \
                   '-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 ' \
                   '1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 ' \
                   '0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 ' \
                   '1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 ' \
                   '2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 ' \
                   '1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>'

      STAR_SVG = '<svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="currentColor" ' \
                 'aria-hidden="true"><path d="M12 2l2.9 6.26L22 9.27l-5 4.87 1.18 6.88L12 ' \
                 '17.77l-6.18 3.25L7 14.14l-5-4.87 7.1-1.01L12 2z"/></svg>'

      def view_template
        count = self.class.star_count
        a(
          href: REPO_URL,
          target: "_blank",
          rel: "noopener noreferrer",
          "aria-label": count ? "Star Wabi on GitHub — #{count} stars" : "Wabi on GitHub",
          class: "inline-flex items-center gap-2 rounded-md text-sm font-medium h-9 px-3 " \
                 "border border-input bg-background hover:bg-accent hover:text-accent-foreground"
        ) do
          raw safe(GITHUB_SVG)
          span(class: "hidden sm:inline") { "Star" }
          if count
            span(class: "inline-flex items-center gap-1 rounded-full bg-muted px-2 py-0.5 " \
                        "text-xs font-semibold text-foreground") do
              raw safe(STAR_SVG)
              plain self.class.format_count(count)
            end
          end
        end
      end

      # Cached server-side. Only successful integer counts are cached (for an
      # hour); a failed fetch returns nil and is retried on the next request
      # rather than caching the failure for an hour.
      def self.star_count
        cached = Rails.cache.read(CACHE_KEY)
        return cached if cached

        count = fetch_remote
        Rails.cache.write(CACHE_KEY, count, expires_in: 1.hour) if count
        count
      end

      def self.fetch_remote
        uri = URI(API_URL)
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 2, read_timeout: 2) do |http|
          http.get(uri.request_uri, "Accept" => "application/vnd.github+json", "User-Agent" => "wabi-docs")
        end
        return nil unless res.is_a?(Net::HTTPSuccess)

        count = JSON.parse(res.body)["stargazers_count"]
        count.is_a?(Integer) ? count : nil
      rescue StandardError
        nil
      end

      # 1234 → "1.2k", 1_200_000 → "1.2M", < 1000 → as-is.
      def self.format_count(n)
        if n >= 1_000_000
          "#{(n / 100_000) / 10.0}M".sub(".0M", "M")
        elsif n >= 1_000
          "#{(n / 100) / 10.0}k".sub(".0k", "k")
        else
          n.to_s
        end
      end
    end
  end
end
