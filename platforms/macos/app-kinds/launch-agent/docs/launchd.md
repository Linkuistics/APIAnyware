# launch-agent — the launchd job model

A `launch-agent` is launched and supervised by `launchd`, the system's service
manager — not by Launch Services or a shell. This documents that relationship as
platform truth, and draws the boundary between what is the *kind* and what is the
concrete app-spec. It does not say how any target builds the binary (that is
`targets/`, workstream 6).

## launchd, not Launch Services

`launchd` is the macOS init/service daemon. A *launch agent* is a launchd job that
runs in a user's GUI login context (under `~/Library/LaunchAgents` or the system
`/Library/LaunchAgents`), as opposed to a *launch daemon* (system context,
`/Library/LaunchDaemons`). launchd starts the job's executable, can keep it alive
(restart on crash), can start it on demand (a socket, a path change, a calendar
interval), and stops it by sending a signal.

The executable itself is a **bare Mach-O** — `bundle "none"`, no `.app`, no
Info.plist. Everything launchd needs to manage it lives in a separate **job plist**,
not in the binary.

## The job plist is app-spec material, not the kind

The launchd job is described by a property list — `Label`, `ProgramArguments`,
`RunAtLoad`, `KeepAlive`, `StartInterval`/`StartCalendarInterval`, `WatchPaths`,
`MachServices`, and so on. That plist is a **concrete-app** decision
(`apps/macos/<app>/`, workstream 7): *this* agent's label, *this* agent's restart
policy, *this* agent's trigger. It is **not** part of the `launch-agent` *kind*,
which describes only the process model every launch agent shares.

So `kind.apiw` deliberately carries no Info.plist block and no launchd-plist schema:

- the **kind** owns the process model — bare executable, no GUI session, a manual
  run loop, signal-driven termination;
- the **app-spec** owns the job plist — the specific launchd configuration that
  loads and triggers one agent.

This mirrors how a `gui-app` kind fixes the *required* Info.plist keys while a
concrete app chooses its identifier and optional keys: the kind is the shared
contract, the app-spec is the instance.

## Lifecycle consequence

Because launchd owns loading and unloading, a `launch-agent` must behave well under
that regime — start promptly, run its `cf-run-loop` to service whatever it was
loaded for, and shut down cleanly when launchd sends SIGTERM at unload. See
`lifecycle.md` for the process model in detail.
