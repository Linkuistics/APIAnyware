# 010-port-ui-controls-gallery

**Kind:** work

## Goal
Port `ui-controls-gallery` from racket to chez. End state: a
`generation/targets/chez/apps/ui-controls-gallery/ui-controls-gallery.sls`
that bundles via `bundle-chez`, launches in the VM (via leaf `040`'s
TestAnyware run), and looks indistinguishable from the racket bar.

CLI-side this leaf covers: write the `.sls`, ensure it compiles in
the chez tree (precompile pass must succeed), bundle it. VM-verify
is leaf `040`.

## Context
- Racket source: `generation/targets/racket/apps/ui-controls-gallery/ui-controls-gallery.rkt`
  (358 LOC).
- Knowledge spec: `knowledge/apps/ui-controls-gallery/spec.md` —
  display name + intended behaviour. Read once before porting.
- Chez delegate API: see node BRIEF "Runtime delegate API (vs racket)"
  section; runtime in `apianyware/runtime/dispatch.sls`.
- App-menu helper: `(install-standard-app-menu! app "UI Controls Gallery")`
  — already used by hello-window.

## Controls in scope
The racket app showcases (top → bottom of stack):

1. Text fields — `NSTextField`, `NSSecureTextField` (placeholder
   strings).
2. Buttons — push button (`NSBezelStyleRounded`), checkbox
   (`NSButtonTypeSwitch`), radio button trio (`NSButtonTypeRadio`)
   with a `selectRadio:` target-action delegate enforcing mutual
   exclusion.
3. Sliders — continuous `NSSlider` with a `sliderChanged:`
   target-action delegate that updates a value label live.
4. Popup & combo — `NSPopupButton` with three items, `NSCombobox`
   with three items.
5. Date picker — `NSDatePicker` with text-field-and-stepper style,
   element flags for year-month-day and hour-minute-second, set to
   `(nsdate-now)`.
6. Progress indicators — determinate bar at 65%, indeterminate
   spinner started via `start-animation`.
7. Stepper — `NSStepper` with `stepperChanged:` target-action
   delegate updating a value label.
8. Color & image — `NSColorWell` set to `nscolor-system-blue-color`,
   `NSImageView` showing `NSActionTemplate`.

All inside an `NSScrollView` wrapping an `NSStackView` (vertical
orientation, 16pt spacing).

## Done when
- `apps/ui-controls-gallery/ui-controls-gallery.sls` exists,
  imports `(chezscheme)`, the two facades `(apianyware appkit)` and
  `(apianyware foundation)`, and the runtime libraries
  `(apianyware runtime cocoa)`, `(apianyware runtime objc)`,
  `(apianyware runtime types)`, plus `(apianyware runtime dispatch)`
  for `make-delegate`.
- All `make-delegate` calls use the chez list-of-specs shape, not
  the racket keyword shape. Delegates are bound to top-level
  variables so they outlive the controls that reference them
  weakly.
- No leftover `_cprocedure`, no `tell` macro, no `define-cstruct`.
  Geometry literals use `make-nsrect` / `make-nssize` / `make-nspoint`.
- App is bundled via `cargo run --example bundle_app -p
  apianyware-macos-bundle-chez -- ui-controls-gallery`. Precompile
  pass must succeed; bundle launches.
- CLI smoke: `chez --libdirs generation/targets/chez --script
  generation/targets/chez/apps/ui-controls-gallery/ui-controls-gallery.sls`
  reaches the run loop. (Full UI verification deferred to leaf
  `040`; CLI smoke only proves the imports load and class/method
  resolution succeeds before the run loop blocks.)
- `knowledge/apps/ui-controls-gallery/spec.md` exists (copy from
  racket if missing).

## Notes
- The racket version notes "set-edge-insets! omitted — the
  generated binding uses _uint64 instead of NSEdgeInsets". Check
  what the chez emitter does for `NSEdgeInsets`. If it's emitted as
  geometry by-value (per leaf 010 of the hello-window node), this
  workaround can be dropped; if not, document the same gap in the
  chez port and file a follow-up.
- The radio-button mutual-exclusion delegate takes a `sender`
  arg. In chez, `sender` arrives as a raw `void*` pointer. To call
  `nsbutton-set-int-value!` on it, wrap with `borrow-objc-object`
  (or whatever the chez equivalent is — check `apianyware/runtime/objc.sls`).
- Constants like `NSWindowStyleMaskTitled`, `NSButtonTypeSwitch`,
  `NSDatePickerElementFlagYearMonthDay`, etc. should come from the
  generated facade if they're emitted; otherwise define inline as
  the racket version did. Check the generated `appkit.sls` exports
  first.
- The racket source uses `(for ([btn (list radio-a radio-b radio-c)])
  …)`. In chez idiom this becomes `(for-each (lambda (btn) …) (list
  radio-a radio-b radio-c))`.
- The racket source uses `(format "Value: ~a" n)`. Chez has the
  same `format` with `~a` — same syntax.
- One `define-entry-point` wrapping the body — same shape as
  hello-window. Body is the `(let* …)` cascade of UI construction
  followed by `(nsapplication-run app)`.

## Pointers
- Working sample to model on: `.grove/done/050-chez-target/100-port-hello-window/030-port-hello-window-app.md`
  + the resulting `generation/targets/chez/apps/hello-window/hello-window.sls`.
