# menu-bar-daemon — test obligations

The `kind.apiw` declares three `test-obligation` references — `lifecycle`,
`accessory-activation`, and `status-item`. These are **forward pointers**: the
obligation *bodies* (the projection-free, target-independent expectation
declarations) are authored later in
`platforms/macos/tests/app-kinds/menu-bar-daemon.apiw` (workstream 4 child 3,
`platform-tests`), and they are *executed* against a running target binding by the
testing architecture (workstream 9; ADR-0046 declare-now / execute-later seam, node
brief D3). This file records what each obligation will assert, in prose.

## `lifecycle`

Drives the entry → run-loop → termination model end-to-end against a built binding:

- launching the app reaches `applicationDidFinishLaunching:` (the AppKit bootstrap
  completed: shared application, principal class, delegate installed);
- the AppKit main run loop runs and services events (the app is not a straight-line
  tool);
- a Quit / `terminate:` request runs the cooperative shutdown
  (`applicationWillTerminate:` observed) and the process exits cleanly.

## `accessory-activation`

Checks the `LSUIElement` accessory policy took effect:

- the app shows **no Dock tile** and does not own the global menu bar;
- launching it does **not** deactivate the user's current foreground app;
- it nonetheless has a live window-server session (it can draw a status item and
  menus) — i.e. accessory, not background.

## `status-item`

Checks the kind's defining presence:

- after launch the app installs an `NSStatusItem` in the system menu bar (an icon
  and/or title is visible);
- the item responds to interaction — clicking it presents the app's menu;
- the status item is removed at termination, leaving no orphan in the menu bar.

## Boundary

This kind owns only the *declaration* of these obligations — what a
`menu-bar-daemon` must satisfy. It owns neither the fixtures-and-runner that execute
them (workstream 9) nor any target-specific hook that builds the binding under test
(workstream 6). The obligation names here are the stable handles those later layers
resolve against.
