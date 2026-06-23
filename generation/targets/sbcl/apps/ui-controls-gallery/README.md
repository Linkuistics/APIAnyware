# Controls Gallery (sbcl)

The broad-surface sample app (ladder 3/8): a single fixed-size window showing **18 distinct
AppKit controls** in a two-column, section-headed layout — buttons, toggles, value
selectors, pickers, fields, and an image view. Exercises a wide slice of the generated
AppKit binding (class convenience constructors, bare `make-instance`, inherited NSControl
value setters, and a spread of enum constants).

Written against the **CL-family interface contract** (ADR-0033 / the contract spec): it
names only the `ns:` Cocoa surface, `make-instance` (§3.3), the per-selector generics
(§3.2, including the `(eql (find-class 'ns:…))` class-method convenience constructors), and
the `@"…"` NSString reader (§3.2). Pure ObjC — no Swift-native residual, so no
`libAPIAnywareSbcl` dylib.

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
| `ui-controls-gallery.lisp` | the app — layout helpers + per-control constructors + the window |
| `run.lisp` | dev host runner; `AW_GALLERY_SMOKE=1` = construction pre-flight (no run loop) |
| `dump.lisp` | `save-lisp-and-die :executable t` → standalone exe; `AW_GALLERY_SMOKE` revive smoke |
| `build.sh` | full build: pre-flight → dump → wrap in `UIControlsGallery.app` |
| `learnings.md` | the init-registry decision (workaround, not the runtime fix) + construction notes |

## Build

```sh
generation/targets/sbcl/apps/ui-controls-gallery/build.sh
# → generation/targets/sbcl/apps/ui-controls-gallery/build/UIControlsGallery.app
```

Pipeline (the ladder's shared shape, see hello-window/build.sh): host construction
pre-flight → `save-lisp-and-die` dump → wrap in `UIControlsGallery.app`
(`com.linkuistics.ui-controls-gallery`). Production packaging is 070-distribution's
`bundle-sbcl`.

## Dev run (interactive, needs a GUI session)

```sh
SDKROOT=macosx sbcl --script generation/targets/sbcl/apps/ui-controls-gallery/run.lisp
```

## Verification

TestAnyware VM-verified — window + all 18 controls render with correct states; controls
are live (checkbox/segment/slider interactions); Cmd-Q quits. See
`../../test-results/ui-controls-gallery/report.md`.

## Distribution note

Same as hello-window: the dumped exe links Homebrew's `libzstd` at an absolute path; a
target without Homebrew must provide that one dylib (post-dump relocation is impossible).
