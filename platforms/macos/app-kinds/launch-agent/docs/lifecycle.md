# launch-agent — lifecycle

The process model a `launch-agent` *is*. This is platform truth — how a
launchd-managed background agent of this kind starts, runs, and stops — not a
statement of how any target language builds one (the domain rule; projection lives
in `targets/`, workstream 6). The launchd *job plist* that configures all of this
is app-spec material; see `launchd.md`.

## Entry — `c-main`

A `launch-agent` is a bare Mach-O executable. launchd `exec`s it directly (with the
`ProgramArguments` from its job plist); control enters at the C `main` the program
owns. There is no `NSApplication`, no principal class, and no bundle — the agent
does its own setup (open its sockets/ports, install signal handlers, build its run
loop) inside `main`.

## Run loop — `cf-run-loop`

A `launch-agent` services events for as long as launchd keeps it loaded, but does so
*without* AppKit. It drives a manual `CFRunLoop` (or `dispatch_main()` / a GCD
event-source loop): it registers the sources it cares about — Mach ports, file
descriptors, dispatch sources, timers — and runs the loop on its main thread. This
is the daemon analogue of the AppKit loop: it must actually run (an agent that
returns from `main` exits and launchd may restart it) and it must not busy-wait
(it blocks in the run loop until a source fires). Unlike a `menu-bar-daemon`, it has
no window-server connection — the loop services system events, not UI events.

## Termination — `signal`

A `launch-agent` is stopped by a **signal**, not by returning and not by
`terminate:`. When launchd unloads the job (logout, `launchctl bootout`, a
`KeepAlive` policy change, system shutdown) it sends SIGTERM and, after a grace
period, SIGKILL. A well-behaved agent installs a SIGTERM handler (or a
`dispatch_source` for it), stops its run loop, flushes and releases its resources,
and exits promptly — before launchd escalates to SIGKILL. Clean, prompt
signal-driven shutdown is the agent's side of the launchd contract.

## Activation — `background`

A `launch-agent` has no GUI session: no Dock tile, no menu bar, no window-server
connection. As a bare executable it carries no Info.plist, so it has no
`LSBackgroundOnly` *key* — its background nature is **inherent**, a consequence of
being a launchd-managed daemon rather than a windowserver-launched app. (The
`background` activation token names exactly this "no GUI session" policy; in a
*bundled* app the same policy would be spelled `LSBackgroundOnly` in Info.plist, but
this kind has no bundle to carry it.) An agent that needs UI is the wrong kind — a
`menu-bar-daemon` is the `accessory`, windowserver-connected alternative.
