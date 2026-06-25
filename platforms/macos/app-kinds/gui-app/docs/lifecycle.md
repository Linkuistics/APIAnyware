# gui-app — lifecycle

The process model a `gui-app` *is*. This is platform truth — what macOS does when
a windowed Cocoa application of this kind runs — not a statement of how any target
language builds one (the domain rule; projection lives in `targets/`, workstream 6).

## Entry — `ns-application-main`

Launch Services starts the bundle's executable and the process bootstraps through
`NSApplicationMain` (or the equivalent hand-rolled sequence): it creates the shared
`NSApplication` instance, loads the principal class named by the bundle's
`NSPrincipalClass` Info.plist key (`NSApplication` itself, unless overridden),
installs the application delegate, and hands control to the run loop. By the time
the delegate's `applicationDidFinishLaunching:` fires, the menu bar and Dock tile
exist and the app is a foreground UI session.

## Run loop — `ns-application`

The main thread runs AppKit's main run loop (`-[NSApplication run]`). The run loop
owns the thread for the lifetime of the app, dispatching window-server events,
timers, and main-queue blocks. Two platform consequences follow, and both are facts
a binding must honour:

- **AppKit is main-thread-affine.** Almost all of AppKit must be touched only on
  this main thread (the §30 `main-thread-only` weirdness). Work raised on other
  threads bounces back to the main run loop.
- **The run loop must actually run.** A `gui-app` that returns from its entry
  without entering the run loop never presents UI; one that blocks the main thread
  starves event delivery (the §30 `requires-run-loop` / `must-not-block` weirdness).

## Termination — `ns-application-terminate`

A `gui-app` quits cooperatively through `-[NSApplication terminate:]` — typically
from the Quit menu item, the last window closing (when the delegate opts in via
`applicationShouldTerminateAfterLastWindowClosed:`), or a Dock/▲Q request. The
termination sequence gives the delegate a veto point
(`applicationShouldTerminate:`) and a teardown notification
(`applicationWillTerminate:`) before the process exits. This is distinct from a
`cli-tool`'s `return` (main falls off the end) and a daemon's `signal` (SIGTERM
from launchd): a `gui-app`'s exit is an AppKit-mediated, user-initiated event.

## Activation — `regular`

A `gui-app` is a *regular* application (`NSApplicationActivationPolicyRegular`): it
appears in the Dock, owns the menu bar when frontmost, and participates in normal
window cycling and activation. It carries no `LSUIElement` or `LSBackgroundOnly`
key — those mark the accessory and background kinds (`menu-bar-daemon`,
`launch-agent`).
