# gui-app — test obligations

The `kind.apiw` declares two `test-obligation` references — `lifecycle` and
`bundle-structure`. These are **forward pointers**: the obligation *bodies* (the
projection-free, target-independent expectation declarations) are authored later in
`platforms/macos/tests/app-kinds/gui-app.apiw` (workstream 4 child 3,
`platform-tests`), and they are *executed* against a running target binding by the
testing architecture (workstream 9; ADR-0046 declare-now / execute-later seam, node
brief D3). This file records what each obligation will assert, in prose.

## `lifecycle`

Drives the entry → run-loop → termination model end-to-end against a built binding:

- launching the app reaches `applicationDidFinishLaunching:` (the bootstrap
  completed: shared application, principal class, delegate installed);
- the app presents a foreground UI session with a menu bar and a Dock tile (the
  `regular` activation policy took effect);
- a Quit / `terminate:` request runs the cooperative shutdown
  (`applicationWillTerminate:` observed) and the process exits cleanly — not by
  signal, not by hang.

## `bundle-structure`

Checks the on-disk `.app` is well-formed platform-truth:

- the bundle has `Contents/Info.plist`, `Contents/MacOS/<CFBundleExecutable>`, and a
  `Resources/` directory;
- every required Info.plist key from `kind.apiw` is present and non-empty, and
  `CFBundlePackageType` is `APPL`;
- `CFBundleExecutable` names the Mach-O actually present under `Contents/MacOS/`;
- the bundle is launchable by Launch Services (not merely exec'able).

## Boundary

This kind owns only the *declaration* of these obligations — what a `gui-app` must
satisfy. It owns neither the fixtures-and-runner that execute them (workstream 9)
nor any target-specific hook that builds the binding under test (workstream 6). The
obligation names here are the stable handles those later layers resolve against.
