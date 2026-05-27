# frozen_string_literal: true

require "fileutils"

namespace :wabi do
  namespace :docs do
    desc "Crawl docs site and build Pagefind static search index"
    task index: :environment do
      require Rails.root.join("lib/wabi/docs/indexer")

      input_dir  = Rails.root.join("tmp/pagefind-input")
      output_dir = Rails.root.join("public/pagefind")

      puts "Crawling #{Wabi::Docs::Indexer::ROUTES_TO_INDEX.size} routes -> #{input_dir}"
      FileUtils.rm_rf(input_dir)
      Wabi::Docs::Indexer.crawl(output_dir: input_dir)
      puts "  OK"

      puts "Running pagefind -> #{output_dir}"
      FileUtils.rm_rf(output_dir)
      system!("npx pagefind --site \"#{input_dir}\" --output-path \"#{output_dir}\"")
      puts "  OK — commit #{output_dir}"
    end

    def system!(cmd)
      system(cmd) || abort("Command failed: #{cmd}")
    end
  end
end
