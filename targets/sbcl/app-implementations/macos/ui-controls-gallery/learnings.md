# ui-controls-gallery — learnings (sbcl target, 060 ladder app 3/8)

The broad-surface app: 18 distinct AppKit controls in one window. It is the app
hello-window's learnings flagged as the one to "force" the exact-class init-registry
decision. It surfaced **no contract gaps** — the emitter + runtime + contract carried a
wide AppKit slice unchanged — so the findings here are a recorded design decision plus a
couple of construction notes for the GUI apps still ahead (050–090).

## Decision: the exact-class init registry — workaround, NOT the runtime fix

hello-window flagged that `aw-apply-init` looks up `(gethash class *objc-init-registry*)`
with no superclass walk, so an inherited typed init (`initWithFrame:`, registered on
`NSView`/`NSControl`) is invisible to `make-instance` on a subclass — and predicted it
would "bite the controls app hard." **It did not bite.** Every control here is built one
of two idiomatic ways, neither of which needs a typed *inherited* init:

- **Class convenience constructor** — `+buttonWithTitle:target:action:`,
  `+checkboxWithTitle:…`, `+radioButtonWithTitle:…`, `+imageViewWithImage:`,
  `+[NSImage imageWithSystemSymbolName:accessibilityDescription:]`. These are emitted as
  `(eql (find-class 'ns:…))` class-method generics (contract §3.2) and return a +0
  autoreleased instance, no init registry involved.
- **Bare `make-instance`** (alloc/init → the control's own `initWithFrame:NSZeroRect`)
  + `setFrame:` + property setters — for NSSwitch, NSSlider, NSStepper, NSLevelIndicator,
  NSProgressIndicator, NSPopUpButton, NSComboBox, NSTextField, NSSecureTextField,
  NSColorWell, NSDatePicker. The no-initargs `make-instance` path is `alloc` + `-init`
  (objc.lisp `aw-alloc-init`), which never touches the registry.

This is **the idiomatic modern AppKit construction path** — Apple steers callers to
convenience constructors + Auto Layout and away from manual `initWithFrame:`. So the
workaround is not a compromise here. **Decision: do not implement the superclass-walk
runtime change for the ladder.** It stays a clean future enhancement (and it *is* clean —
the ADR-0040 applier sends its selector to the already-`alloc`'d instance via
`objc_msgSend`, which dispatches dynamically, so a superclass applier would work on a
subclass instance unchanged; only the registry *lookup* would need to walk the CPL). No
ladder app is expected to need a typed *inherited* init; if 050–090 surfaces one, that is
the moment to add the walk + its own tests, not before.

## Construction notes for the GUI apps ahead (050–090)

- **Inherited NSControl value setters resolve by CLOS inheritance.**
  `setDoubleValue:`/`setIntegerValue:`/`setStringValue:` are emitted only on
  `ns:ns-control` (not redefined per subclass), and dispatch onto NSSlider/NSStepper/
  NSComboBox/… via the class graph — the same mechanism hello-window's label used for the
  inherited `ns:set-string-value_`. Grepping a subclass file for these returns 0; that is
  correct, not a gap.
- **`setState:` has no emitted enum.** `NSControlStateValueOn/Off/Mixed` are not in
  `enums.lisp`, so the literal `1`/`0` go straight to `ns:set-state_` (an `NSInteger`).
  Documented inline. (A general "named integer constants that are not framework enums"
  question, not specific to this app.)
- **Convenience constructors return +0 autoreleased** — the emitter wraps them
  `(aw-wrap … )` *without* the `t` retained flag, correctly: a class factory method
  (`+buttonWithTitle:…`) yields an autoreleased instance the entry-point pool drains, and
  the superview retains it on `addSubview:`. Contrast the alloc/init path, which is +1 and
  wraps with `t`. Both are correct and both appear in this app.
- **Radio grouping is automatic** for sibling `+radioButtonWithTitle:target:action:`
  buttons that share an action — here both use the empty action `""` (the same cached
  `SEL`), so clicking one deselects the other (verified: A=1/B=0, and the click test).
- **`+[NSImage imageWithSystemSymbolName:accessibilityDescription:]` + `setContentTintColor:`**
  renders and tints an SF Symbol with no asset bundle — a zero-dependency way to show a
  real image in a sample app (used for the star). `setImageScaling:` with
  `ns:ns-image-scale-proportionally-up-or-down` sizes it to the image view.

## Carried-forward (unchanged from earlier apps)

- Pure ObjC → `:load-residual nil`, no `libAPIAnywareSbcl` dylib; VM provisioning is
  libzstd only (hello-window's 070-distribution findings still hold — absolute libzstd
  path, no post-dump Mach-O surgery, ad-hoc signature left intact).
- App package `apianyware-sbcl-impl`; the not-yet-portable touchpoints (impl-package home,
  `aw-with-rect` geometry primitive) are the same contract-surface follow-ups
  hello-window recorded — they do not affect the portable `ns:`-named Cocoa calls.
