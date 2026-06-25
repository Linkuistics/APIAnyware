# cli-tool — lifecycle

The process model a `cli-tool` *is*. This is platform truth — what macOS does when
a bare command-line tool of this kind runs — not a statement of how any target
language builds one (the domain rule; projection lives in `targets/`, workstream 6).

## Entry — `c-main`

A `cli-tool` is a plain Mach-O executable. It is started by `exec`-ing the binary
directly — from a shell, a `Process`/`posix_spawn`, a Makefile, another tool — not
by Launch Services and not through a bundle. Control enters at the C `main(argc,
argv, envp)` the program owns; there is no `NSApplication`, no principal class, and
no bundle to read launch metadata from. The process inherits the caller's
environment, working directory, and standard streams.

## Run loop — `none`

There is no event loop. A `cli-tool` runs straight-line to completion: it reads its
arguments and stdin, does its work, writes stdout/stderr, and finishes. It may still
*block* (on I/O, a subprocess, a `read`), but it does not host a `CFRunLoop` or
AppKit loop dispatching asynchronous events — when its work is done, it is done. A
tool that needs to service events indefinitely is a different kind (`launch-agent`).

## Termination — `return`

A `cli-tool` ends by returning from `main` (or calling `exit()`), yielding a process
exit code: `0` for success, non-zero for failure. This is the Unix process
contract — the exit status is the tool's primary machine-readable result, and a
caller (shell, script, test harness) branches on it. This is distinct from a
`gui-app`'s `terminate:` (an AppKit-mediated quit) and a daemon's `signal`
(SIGTERM): a `cli-tool` decides for itself when it is finished and reports that
decision as a status code.

## Activation — `background`

A `cli-tool` has no window-server presence at all: no Dock tile, no menu bar, no
foreground UI session. It is not an `LSUIElement` accessory (it has no Info.plist to
carry one) — it simply never connects to the window server, because a bare
executable launched outside a GUI session has nothing to present. Its only interface
is its arguments, environment, standard streams, and exit code.

## No bundle

A `cli-tool` ships as a single Mach-O executable: no `.app`, no `Contents/`, no
Info.plist (`bundle "none"`). It carries none of the bundle metadata the bundled
kinds require — there is no container to hold it. A concrete tool may still be code
*signed* (a flat signature on the Mach-O), but that is a build/distribution detail,
not part of the kind's process model.
