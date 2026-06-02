// Helpers shared by the overlay controller tests. The overlay controllers
// portal their positioner/content to <body> on connect, so after mount the
// nodes are NOT under the controller root — query the whole document by the
// Stimulus target attribute instead.
import { Application } from "@hotwired/stimulus"

// The controller instance for the mounted root, so tests can call its public
// API (open()/close()/isOpen()). `root` is document.body.firstElementChild.
export function controllerFor(application, identifier, root) {
  return application.getControllerForElementAndIdentifier(root, identifier)
}

// First element anywhere in the document carrying the given Stimulus target.
// Works whether or not the node was portaled to <body>.
export function byTarget(identifier, name) {
  return document.querySelector(`[data-${identifier}-target="${name}"]`)
}

export function allByTarget(identifier, name) {
  return [...document.querySelectorAll(`[data-${identifier}-target="${name}"]`)]
}

// The mounted root element (the controller host).
export const root = () => document.body.firstElementChild
