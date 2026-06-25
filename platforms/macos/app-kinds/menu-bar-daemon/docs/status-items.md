# menu-bar-daemon — status items

The defining feature of a `menu-bar-daemon`: it presents to the user through an
`NSStatusItem` in the system menu bar, not through windows and a Dock tile. This is
platform truth — what the kind *is* — not how any target builds it (the domain rule;
projection lives in `targets/`, workstream 6).

## The status item

A `menu-bar-daemon` runs the full AppKit stack (`NSApplicationMain`, the AppKit main
loop) exactly like a `gui-app`, but instead of opening windows it asks the shared
`NSStatusBar` for a status item:

- it acquires an `NSStatusItem` from `[NSStatusBar systemStatusBar]` — the small
  control that appears at the right end of the menu bar;
- it gives the item a button (an icon and/or title) and usually an `NSMenu` that
  drops down when clicked;
- the item is the app's primary, often only, point of presence — the user interacts
  with the daemon through that menu rather than through a window or the Dock.

The status item is a live, main-thread AppKit object: it is created on the main run
loop after launch and torn down at termination. Because it lives in the menu bar —
a shared, always-on surface — a `menu-bar-daemon` is typically a long-lived
background helper (a clipboard manager, a VPN toggle, a sync indicator) rather than a
document app the user opens and closes.

## Why an AppKit app, not a daemon

A `menu-bar-daemon` needs the AppKit run loop and a window-server connection: status
items, menus, and their drawing are AppKit, and AppKit is main-thread-affine and
requires a GUI session. That is why this kind is a bundled `.app` running the
`ns-application` loop — distinct from a `launch-agent`, which has no GUI session and
services events on a bare `CFRunLoop`. A `menu-bar-daemon` is a *foreground-capable*
app that merely declines a Dock tile; a `launch-agent` is a true background process.
