# Controls Gallery (sbcl)

The broad-surface sample app (ladder 3/8): a single fixed-size window showing **18 distinct
AppKit controls** in a two-column, section-headed layout — buttons, toggles, value
selectors, pickers, fields, and an image view. Exercises a wide slice of the generated
AppKit binding (class convenience constructors, bare `make-instance`, inherited NSControl
value setters, and a spread of enum constants).

Written against the **CL-family interface contract** (ADR-0033 / the contract spec): it
names only the `ns:` Cocoa surface, `make-instance` (§3.3), the per-selector generics
(§3.2, including the `(eql (find-class 'ns:…))` class-method convenience constructors), and
the `@"…"` NSString reader (§3.2). Pure ObjC calls — no Swift-native trampoline residual
(`:load-residual nil`) — but since the AppSpec instrumentation (k92) the app loads
`libAPIAnywareSbcl` for the subclass bounce shim its callbacks need (terminate delegate +
the four `[controls]` target-actions; ADR-0035).

Instrumented per the k87 logging contract
(`../../../../../apps/macos/ui-controls-gallery/docs/logging-contract.md`): writes
`/tmp/ui-controls-gallery/events.log` (lifecycle + the four `[controls]` state-change
events) for the AppSpec scenario runner.

## Controls

| Section | Controls |
|---|---|
| Buttons & Toggles | push button, checkbox, radio pair, NSSwitch, NSSegmentedControl |
| Value Selectors | NSSlider (ticks), NSStepper, NSLevelIndicator (rating), NSProgressIndicator (bar + spinner) |
| Pickers & Fields | NSPopUpButton, NSComboBox, NSTextField, NSSecureTextField, NSColorWell, NSDatePicker |
| Display | NSImageView with a tinted SF Symbol |

## Files

| File | Role |
|---|---|
| `ui-controls-gallery.lisp` | the app — layout helpers + per-control constructors + the controller subclass + the window |
| `events.lisp` | the structured event log (pure CL; the k87 logging contract's emitters) |
| `run.lisp` | dev host runner; `AW_GALLERY_SMOKE=1` = construction pre-flight (no run loop) |
| `dump.lisp` | `save-lisp-and-die :executable t` → standalone exe; `AW_GALLERY_SMOKE` revive smoke |
| `build.sh` | full build: pre-flight → bundler (dump + stub + vendor + sign) → per-impl rename/id |
| `ui-controls-gallery-impl.rkt` | `#lang app-spec/impl` descriptor the AppSpec runner consumes |
| `learnings.md` | the init-registry decision + construction notes + the k92 instrumentation findings |

## Build

```sh
targets/sbcl/app-implementations/macos/ui-controls-gallery/build.sh
# → targets/sbcl/app-implementations/macos/ui-controls-gallery/build/UIControlsGallery-sbcl.app
```

Pipeline (hello-window's shape post-k75): host construction pre-flight → the production
bundler `apianyware-bundle-sbcl` (drives `dump.lisp`, compiles the DYLD-fallback stub,
vendors `libzstd` + `libAPIAnywareSbcl` into `Contents/Frameworks/`, signs) → rename to
`UIControlsGallery-sbcl.app` + set the per-impl `CFBundleIdentifier`
(`com.linkuistics.ui-controls-gallery-sbcl`) + re-sign → revive smoke through the stub.
The `.app` travels alone — the VM needs nothing staged.

## Dev run (interactive, needs a GUI session)

```sh
SDKROOT=macosx sbcl --script targets/sbcl/app-implementations/macos/ui-controls-gallery/run.lisp
```

## Verification

TestAnyware VM-verified — window + all 18 controls render with correct states; controls
are live (checkbox/segment/slider interactions); Cmd-Q quits. See
`../../test-results/ui-controls-gallery/report.md`.

## Distribution note

Same as hello-window post-k75: the bundler vendors `libzstd` (the image's hard
`LC_LOAD_DYLIB`, resolved by leaf name via the stub's `DYLD_FALLBACK_LIBRARY_PATH`) and
`libAPIAnywareSbcl` (dlopen'd via the recorded `@executable_path/../Frameworks/`
namestring) into the bundle — post-dump Mach-O relocation remains impossible, so
self-containment is closed at runtime, never by editing the image (ADR-0041).
