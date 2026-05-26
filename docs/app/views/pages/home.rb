# frozen_string_literal: true

module Views
  module Pages
    class Home < Views::Base
      def view_template
        render Components::Site::Layout.new(title: "Wabi") do
          main(class: "container mx-auto py-16 px-4") do
            h1(class: "text-4xl font-bold mb-4") { "Wabi" }
            p(class: "text-muted-foreground mb-8") { "Beautifully imperfect components for Rails." }
            div(class: "flex gap-3 flex-wrap") do
              render Components::UI::Button.new                          { "Primary" }
              render Components::UI::Button.new(appearance: :secondary)   { "Secondary" }
              render Components::UI::Button.new(appearance: :destructive) { "Destructive" }
              render Components::UI::Button.new(appearance: :outline)     { "Outline" }
              render Components::UI::Button.new(appearance: :ghost)       { "Ghost" }
              render Components::UI::Button.new(appearance: :link)        { "Link" }
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Form fields" }
              div(class: "max-w-sm space-y-4") do
                div(class: "space-y-2") do
                  render Components::UI::Label.new(for_: "email") { "Email" }
                  render Components::UI::Input.new(id: "email", type: :email, placeholder: "you@example.com")
                end
                div(class: "space-y-2") do
                  render Components::UI::Label.new(for_: "bio") { "Bio" }
                  render Components::UI::Textarea.new(id: "bio", rows: 4)
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Checkbox" }
              div(class: "flex items-center gap-2") do
                render Components::UI::Checkbox.new(id: "terms", name: "terms")
                render Components::UI::Label.new(for_: "terms") { "Accept terms" }
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Switch" }
              div(class: "flex items-center gap-2") do
                render Components::UI::Switch.new(id: "notifications", name: "notifications")
                render Components::UI::Label.new(for_: "notifications") { "Email notifications" }
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Toast" }
              p(class: "text-sm text-muted-foreground mb-2") { "Click a button to spawn a toast in the top-right corner. Hover to pause auto-dismiss." }
              # Pre-render the three toast variants and stash the HTML on the
              # demo controller as Stimulus String values. `insertAdjacentHTML`
              # injects on click. Avoiding <template> tags: Phlex's `template`
              # element method renders, but combined with the layout's capture
              # path it has edge cases worth dodging for a docs demo.
              div(
                data: {
                  controller: "wabi--toast-demo",
                  "wabi--toast-demo-info-html-value":        Components::UI::Toast.new(title: "Heads up", description: "This is an informational message.", appearance: :info).call,
                  "wabi--toast-demo-success-html-value":     Components::UI::Toast.new(title: "Saved", description: "Profile updated successfully.", appearance: :success).call,
                  "wabi--toast-demo-destructive-html-value": Components::UI::Toast.new(title: "Error", description: "Something went wrong, try again.", appearance: :destructive).call,
                }
              ) do
                div(class: "flex gap-2 flex-wrap") do
                  [
                    { key: "info",        label: "Info toast",    css: "border-input bg-background hover:bg-accent" },
                    { key: "success",     label: "Success toast", css: "bg-primary text-primary-foreground hover:bg-primary/90" },
                    { key: "destructive", label: "Error toast",   css: "bg-destructive text-destructive-foreground hover:bg-destructive/90" },
                  ].each do |opt|
                    button(
                      type: "button",
                      data: {
                        action: "click->wabi--toast-demo#spawn",
                        "wabi--toast-demo-key-param": opt[:key],
                      },
                      class: "inline-flex items-center justify-center rounded-md text-sm font-medium h-10 px-4 py-2 border #{opt[:css]}"
                    ) { opt[:label] }
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Tabs" }
              div(class: "max-w-md") do
                render Components::UI::Tabs.new(value: "account") do
                  render Components::UI::TabsList.new do
                    render Components::UI::TabsTrigger.new(value: "account")  { "Account" }
                    render Components::UI::TabsTrigger.new(value: "password") { "Password" }
                    render Components::UI::TabsTrigger.new(value: "billing")  { "Billing" }
                  end
                  render Components::UI::TabsContent.new(value: "account") do
                    p(class: "text-sm text-muted-foreground") { "Manage your account settings here." }
                  end
                  render Components::UI::TabsContent.new(value: "password") do
                    p(class: "text-sm text-muted-foreground") { "Change your password." }
                  end
                  render Components::UI::TabsContent.new(value: "billing") do
                    p(class: "text-sm text-muted-foreground") { "Update your billing info." }
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Accordion" }
              div(class: "max-w-md") do
                render Components::UI::Accordion.new(type: :single, collapsible: true) do
                  render Components::UI::AccordionItem.new(value: "item-1") do
                    render Components::UI::AccordionTrigger.new(value: "item-1") { "Is it accessible?" }
                    render Components::UI::AccordionContent.new(value: "item-1") do
                      "Yes. It adheres to the WAI-ARIA design pattern."
                    end
                  end
                  render Components::UI::AccordionItem.new(value: "item-2") do
                    render Components::UI::AccordionTrigger.new(value: "item-2") { "Is it styled?" }
                    render Components::UI::AccordionContent.new(value: "item-2") do
                      "Yes. Wabi components come with default Tailwind styling, customizable via your tokens."
                    end
                  end
                  render Components::UI::AccordionItem.new(value: "item-3") do
                    render Components::UI::AccordionTrigger.new(value: "item-3") { "Is it animated?" }
                    render Components::UI::AccordionContent.new(value: "item-3") do
                      "Yes. Height animates via the CSS grid-template-rows trick — no keyframes required."
                    end
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "DropdownMenu" }
              render Components::UI::DropdownMenu.new do
                render Components::UI::DropdownMenuTrigger.new(class: "inline-flex items-center justify-center rounded-md text-sm font-medium border border-input bg-background hover:bg-accent hover:text-accent-foreground h-10 px-4 py-2") { "Actions ▾" }
                render Components::UI::DropdownMenuContent.new do
                  render Components::UI::DropdownMenuLabel.new { "Actions" }
                  render Components::UI::DropdownMenuItem.new(value: "edit") do
                    plain "Edit"
                    render Components::UI::DropdownMenuShortcut.new { "⌘E" }
                  end
                  render Components::UI::DropdownMenuItem.new(value: "duplicate") do
                    plain "Duplicate"
                    render Components::UI::DropdownMenuShortcut.new { "⌘D" }
                  end
                  render Components::UI::DropdownMenuSeparator.new
                  render Components::UI::DropdownMenuItem.new(value: "archive") { "Archive" }
                  render Components::UI::DropdownMenuItem.new(value: "delete", disabled: true) { "Delete (disabled)" }
                  render Components::UI::DropdownMenuSeparator.new
                  render Components::UI::DropdownMenuLabel.new { "Visibility" }
                  render Components::UI::DropdownMenuCheckboxItem.new(value: "show_bookmarks", checked: true) { "Show bookmarks" }
                  render Components::UI::DropdownMenuCheckboxItem.new(value: "show_panel") { "Show full panel" }
                  render Components::UI::DropdownMenuSeparator.new
                  render Components::UI::DropdownMenuLabel.new { "Sort by" }
                  render Components::UI::DropdownMenuRadioGroup.new(name: "sort", value: "name") do
                    render Components::UI::DropdownMenuRadioItem.new(value: "name", name: "sort", checked: true) { "Name" }
                    render Components::UI::DropdownMenuRadioItem.new(value: "date", name: "sort") { "Date" }
                    render Components::UI::DropdownMenuRadioItem.new(value: "size", name: "sort") { "Size" }
                  end
                  render Components::UI::DropdownMenuSeparator.new
                  render Components::UI::DropdownMenuSub.new do
                    render Components::UI::DropdownMenuSubTrigger.new(value: "share") { "Share" }
                    render Components::UI::DropdownMenuSubContent.new do
                      render Components::UI::DropdownMenuItem.new(value: "share_email")  { "Email" }
                      render Components::UI::DropdownMenuItem.new(value: "share_slack")  { "Slack" }
                      render Components::UI::DropdownMenuSeparator.new
                      render Components::UI::DropdownMenuCheckboxItem.new(value: "share_notify_team", checked: true) { "Notify team" }
                    end
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Popover" }
              render Components::UI::Popover.new do
                render Components::UI::PopoverTrigger.new(class: "inline-flex items-center justify-center rounded-md text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2") { "Open popover" }
                render Components::UI::PopoverContent.new do
                  div(class: "grid gap-3") do
                    h3(class: "font-medium leading-none") { "Dimensions" }
                    p(class: "text-sm text-muted-foreground") { "Set the dimensions for the layer." }
                    div(class: "flex justify-end") do
                      render Components::UI::PopoverClose.new { "Done" }
                    end
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Tooltip" }
              p(class: "text-sm text-muted-foreground mb-2") { "Hover or focus the buttons below — tooltip appears after a short delay." }
              div(class: "flex gap-4 items-center") do
                render Components::UI::Tooltip.new do
                  render Components::UI::TooltipTrigger.new(class: "inline-flex items-center justify-center rounded-md text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2") { "Hover me" }
                  render Components::UI::TooltipContent.new { "Got it — this is a tooltip." }
                end
                render Components::UI::Tooltip.new(open_delay: 200) do
                  render Components::UI::TooltipTrigger.new(class: "inline-flex items-center justify-center rounded-md text-sm font-medium border border-input bg-background hover:bg-accent hover:text-accent-foreground h-10 px-4 py-2") { "Fast tooltip" }
                  render Components::UI::TooltipContent.new { "200ms openDelay." }
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Drawer" }
              div(class: "flex gap-2 flex-wrap") do
                [:top, :right, :bottom, :left].each do |side|
                  render Components::UI::Drawer.new(side: side) do
                    render Components::UI::DrawerTrigger.new(class: "inline-flex items-center justify-center rounded-md text-sm font-medium border border-input bg-background hover:bg-accent hover:text-accent-foreground h-10 px-4 py-2") { "Open #{side.to_s}" }
                    render Components::UI::DrawerContent.new(side: side) do
                      render Components::UI::DrawerHeader.new do
                        render Components::UI::DrawerTitle.new       { "Drawer (#{side})" }
                        render Components::UI::DrawerDescription.new { "Side-anchored dialog variant. Esc and click-outside dismiss work as in Dialog." }
                      end
                      div(class: "flex-1") { p { "Drawer body content goes here." } }
                      render Components::UI::DrawerFooter.new do
                        render Components::UI::DrawerClose.new { "Close" }
                      end
                    end
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Dialog" }
              render Components::UI::Dialog.new do
                render Components::UI::DialogTrigger.new(class: "inline-flex items-center justify-center rounded-md text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2") { "Open dialog" }
                render Components::UI::DialogContent.new do
                  render Components::UI::DialogHeader.new do
                    render Components::UI::DialogTitle.new       { "Delete account" }
                    render Components::UI::DialogDescription.new { "This action cannot be undone. This will permanently delete your account and remove your data from our servers." }
                  end
                  render Components::UI::DialogFooter.new do
                    render Components::UI::DialogCancel.new { "Cancel" }
                    render Components::UI::DialogAction.new(appearance: :destructive, data: { action: "click->wabi--dialog#close" }) { "Delete" }
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Select" }
              fruits = [
                { value: "apple",  label: "Apple" },
                { value: "banana", label: "Banana" },
                { value: "cherry", label: "Cherry" },
                { value: "date",   label: "Date" },
              ]
              div(class: "max-w-xs") do
                render Components::UI::Select.new(name: "fruit", items: fruits, placeholder: "Pick a fruit") do
                  render Components::UI::SelectTrigger.new do
                    render Components::UI::SelectValue.new
                  end
                  render Components::UI::SelectContent.new do
                    fruits.each do |item|
                      render Components::UI::SelectItem.new(value: item[:value]) { item[:label] }
                    end
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Card" }
              div(class: "max-w-md") do
                render Components::UI::Card.new do
                  render Components::UI::CardHeader.new do
                    render Components::UI::CardTitle.new { "Onboarding" }
                    render Components::UI::CardDescription.new { "Complete your profile to continue." }
                  end
                  render Components::UI::CardContent.new do
                    p { "This is the card body content." }
                  end
                  render Components::UI::CardFooter.new do
                    render Components::UI::Button.new { "Continue" }
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Badge" }
              div(class: "flex gap-2") do
                render Components::UI::Badge.new                            { "Primary" }
                render Components::UI::Badge.new(appearance: :secondary)    { "Secondary" }
                render Components::UI::Badge.new(appearance: :destructive)  { "Destructive" }
                render Components::UI::Badge.new(appearance: :outline)      { "Outline" }
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Separator" }
              div(class: "max-w-md") do
                p { "Above separator" }
                render Components::UI::Separator.new(class: "my-4")
                p { "Below separator" }
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Alert" }
              div(class: "max-w-xl space-y-4") do
                render Components::UI::Alert.new do
                  render Components::UI::AlertTitle.new       { "Heads up!" }
                  render Components::UI::AlertDescription.new { "You can add components to your app using the CLI." }
                end
                render Components::UI::Alert.new(appearance: :destructive) do
                  render Components::UI::AlertTitle.new       { "Error" }
                  render Components::UI::AlertDescription.new { "Your session has expired. Please log in again." }
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Avatar" }
              div(class: "flex gap-4 items-center") do
                render Components::UI::Avatar.new do
                  render Components::UI::AvatarImage.new(src: "https://github.com/OscarOrtega.png", alt: "Oscar")
                  render Components::UI::AvatarFallback.new { "OO" }
                end
                render Components::UI::Avatar.new(class: "h-16 w-16") do
                  render Components::UI::AvatarFallback.new { "JD" }
                end
              end
            end
          end
        end
      end
    end
  end
end
