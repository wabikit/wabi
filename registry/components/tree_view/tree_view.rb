# frozen_string_literal: true

require "date"
require "json"

module Components
  module UI
    class TreeView < Wabi::Base
      # The row is the Zag-managed element (item / branchControl). Indentation must
      # NOT live here: getItemProps() returns a style ({ --depth }) that the controller
      # spreads, REPLACING the row's style attribute — so any inline --wabi-tv-pad here
      # is wiped. Indentation lives on an inner [data-wabi-indent] wrapper instead.
      ROW_BASE = "group rounded-md py-1 pr-2 cursor-pointer outline-none " \
                 "hover:bg-accent hover:text-accent-foreground " \
                 "data-[selected]:bg-accent data-[selected]:text-accent-foreground " \
                 "focus-visible:ring-2 focus-visible:ring-ring"
      INDENT_BASE = "flex items-center gap-1.5 pl-[var(--wabi-tv-pad)]"

      def initialize(items:, label: nil, id: nil, selection_mode: "single",
                     with_checkboxes: false, default_expanded: [], default_selected: [], **attrs)
        @items            = items
        @label            = label
        @id               = id
        @selection_mode   = selection_mode
        @with_checkboxes  = with_checkboxes
        @default_expanded = default_expanded
        @default_selected = default_selected
        @attrs            = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        div(
          id: @id,
          data: {
            controller: "wabi--tree-view",
            "wabi--tree-view-items-value":            @items.to_json,
            "wabi--tree-view-selection-mode-value":   @selection_mode.to_s,
            "wabi--tree-view-with-checkboxes-value":  (@with_checkboxes ? "true" : "false"),
            "wabi--tree-view-default-expanded-value": @default_expanded.to_json,
            "wabi--tree-view-default-selected-value": @default_selected.to_json,
          },
          class: merge_class("w-full text-sm text-foreground", user_class)
        ) do
          if @label
            div(
              data: { "wabi--tree-view-target": "label" },
              class: "mb-1 px-2 font-medium"
            ) { @label }
          end
          div(data: { "wabi--tree-view-target": "tree" }, class: "space-y-0.5") do
            @items.each_with_index { |node, i| render_node(node, [i]) }
          end
        end
      end

      private

      def render_node(node, index_path)
        branch?(node) ? render_branch(node, index_path) : render_item(node, index_path)
      end

      def branch?(node)
        node.key?(:children) && !node[:children].nil?
      end

      def depth_style(index_path, leaf:)
        base = leaf ? "1.75rem" : "0.5rem"
        "--wabi-tv-pad: calc(#{index_path.length - 1} * 1rem + #{base})"
      end

      def render_branch(node, index_path)
        div(
          data: {
            "wabi--tree-view-target": "branch",
            "wabi-value":      node[:value].to_s,
            "wabi-index-path": index_path.to_json,
            "wabi-role":       "branch",
          }
        ) do
          div(data: { "wabi--tree-view-target": "branchControl" }, class: ROW_BASE) do
            div(
              data: { "wabi-indent": "" },
              class: INDENT_BASE,
              style: depth_style(index_path, leaf: false)
            ) do
              node_checkbox if @with_checkboxes
              button(
                type: "button",
                # aria-label gives the icon-only toggle button an accessible name.
                # Zag's getBranchTriggerProps sets role/data-state/data-disabled/onClick only —
                # it never injects aria-label, so we supply a static default here.
                "aria-label": "Toggle branch",
                data: { "wabi--tree-view-target": "branchTrigger" },
                class: "grid h-4 w-4 place-items-center text-muted-foreground"
              ) do
                span(
                  data: { "wabi--tree-view-target": "branchIndicator" },
                  class: "transition-transform motion-reduce:transition-none group-data-[state=open]:rotate-90"
                ) { chevron_icon }
              end
              node_icon(node)
              span(data: { "wabi--tree-view-target": "branchText" }, class: "truncate") { node[:label].to_s }
            end
          end
          div(data: { "wabi--tree-view-target": "branchContent" }, class: "space-y-0.5") do
            node[:children].each_with_index { |child, i| render_node(child, index_path + [i]) }
          end
        end
      end

      def render_item(node, index_path)
        div(
          data: {
            "wabi--tree-view-target": "item",
            "wabi-value":      node[:value].to_s,
            "wabi-index-path": index_path.to_json,
            "wabi-role":       "item",
          },
          class: ROW_BASE
        ) do
          div(
            data: { "wabi-indent": "" },
            class: INDENT_BASE,
            style: depth_style(index_path, leaf: true)
          ) do
            node_checkbox if @with_checkboxes
            node_icon(node)
            span(data: { "wabi--tree-view-target": "itemText" }, class: "truncate") { node[:label].to_s }
            span(
              data: { "wabi--tree-view-target": "itemIndicator" },
              class: "ml-auto hidden text-foreground group-data-[selected]:block"
            ) { check_icon }
          end
        end
      end

      def node_checkbox
        span(
          data: { "wabi--tree-view-target": "nodeCheckbox" },
          class: "grid h-4 w-4 shrink-0 place-items-center rounded border border-input text-primary-foreground " \
                 "group/cb data-[state=checked]:bg-primary data-[state=checked]:border-primary " \
                 "data-[state=indeterminate]:bg-primary data-[state=indeterminate]:border-primary"
        ) do
          span(class: "hidden group-data-[state=checked]/cb:block") { check_icon }
          span(class: "hidden h-0.5 w-2 rounded bg-current group-data-[state=indeterminate]/cb:block")
        end
      end

      def node_icon(node)
        case node[:icon].to_s
        when "folder" then folder_icon
        when "file"   then file_icon
        end
      end

      # Folder icon lives inside branchControl (which carries `group` + data-state),
      # so the open/closed variants swap via group-data-[state=open].
      def folder_icon
        span(data: { "wabi-icon": "folder" }, class: "shrink-0 text-muted-foreground") do
          span(class: "group-data-[state=open]:hidden") do
            raw(safe(<<~SVG))
              <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/></svg>
            SVG
          end
          span(class: "hidden group-data-[state=open]:block") do
            raw(safe(<<~SVG))
              <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 14 1.5-2.9A2 2 0 0 1 9.24 10H20a2 2 0 0 1 1.94 2.5l-1.55 6a2 2 0 0 1-1.94 1.5H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h3.9a2 2 0 0 1 1.69.9l.81 1.2a2 2 0 0 0 1.67.9H18a2 2 0 0 1 2 2v2"/></svg>
            SVG
          end
        end
      end

      def file_icon
        span(data: { "wabi-icon": "file" }, class: "shrink-0 text-muted-foreground") do
          raw(safe(<<~SVG))
            <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/></svg>
          SVG
        end
      end

      def chevron_icon
        raw(safe(<<~SVG))
          <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
        SVG
      end

      def check_icon
        raw(safe(<<~SVG))
          <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
        SVG
      end
    end
  end
end
