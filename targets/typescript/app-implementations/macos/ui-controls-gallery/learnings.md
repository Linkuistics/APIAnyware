# ui-controls-gallery — learnings (Node TypeScript target, ladder app 2/7)

The broad-surface AppKit control roster. Reused hello-window's launcher/bootstrap/loader shape
unchanged (as the parent brief predicted), and needed **no runtime changes at all** — everything
below is either a design finding specific to this app, or a VM-provisioning correction. This is
the first app to genuinely exercise ADR-0059's subclass/target-action machinery end-to-end.

## Finding: radio-button sibling exclusion is NOT automatic — needs an explicit callback

The app's own first draft assumed (from a misreading of sbcl's `ui-controls-gallery.lisp` comment)
that two `NSButtonTypeRadio` buttons sharing an immediate superview auto-exclude, with no
target-action needed. **Measured false in-VM**: clicking "Option B" left "Option A" still selected
(both read `value="1"`). Re-reading sbcl's own comment more carefully — "wiring the shared radio
action is itself what forms the platform sibling-exclusion group (same superview **+ same
action**)" — the exclusion is contingent on the shared action wiring, not on type+superview alone
(or at minimum, not reliably enough to depend on for this construction path).

Fixed with the explicit-callback path spec §7 itself names as a valid realization ("via an explicit
selection callback that clears siblings and selects the sender"): `GalleryController extends
NSObject`, built directly on the **raw** `__subclassAlloc`/`__bindSubclass` primitives (not the
`extends`-with-`override` sugar, which only covers a parent's pre-declared `__overridable`
methods) — a `class_addMethod`-added `selectRadio:` (encoding `v@:@`) that walks its registered
radio buttons and sets each one's state to match whichever's raw handle sent the message. Both
radios' `setTarget_`/`setAction_` point at one shared `GalleryController` instance, held alive by a
**module-level `const`** — `NSControl.target` is a non-retaining property, so nothing native keeps
a target instance alive; only a live JS reference does (confirmed this matters by reasoning, not by
reproducing the dangle — the instance is used immediately after construction in this app).

This is the first proof, outside `native/test/super.mjs`'s own integration test, that the
`__subclassAlloc`/`__bindSubclass` target-action path works end-to-end in a real sample app. A
later rung wiring any other target-action control (a button click handler, a slider live-value
callback) can copy this shape directly.

## Finding: `NSDate` carries no `+now`/`+date`/`+distantFuture` class factory in the emitted surface

The spec (§6, control 9) wants the date picker initialized to "the current date (`NSDate` `now`) at
launch" — sbcl's own implementation uses `(ns:now (find-class 'ns:ns-date))`. The emitted
`nsdate.ts` has none of `now`, `distantFuture`, `distantPast`, or any `dateWithTimeIntervalSince*:`
class factory, even though `resolved.kdl` records all of them as declared, non-instance selectors
on `NSDate` (`"source": "unknown"` on every one of these facts — possibly the tell for why they
didn't make it into the emitted surface, though this leaf did not dig further). Worked around
without touching the emitter: `NSDate` **does** carry the instance initializer
`initWithTimeIntervalSinceReferenceDate_`, so "now" is computed as
`Date.now() / 1000 - 978307200` (the fixed NSDate-reference-epoch-to-Unix-epoch offset) and passed
through that. Confirmed correct in-VM: the date picker showed the VM's real current date
(7/15/2026), not a stale or zero date.

Worth root-causing in a future leaf (not this one — externalizing per this node's own "grow lazily,
don't absorb" discipline): is `"source": "unknown"` on a resolved fact a signal the emitter should
treat as "don't bind" and this is working as intended, or is it a genuine gap the way k57/k66/k76's
"lossy map used as a key" species usually turns out to be? No leaf currently tracks this.

## VM-provisioning finding: a naive "copy the one resolved dylib" closure misses symlink aliases

hello-window's own learnings.md already established the 25-ish-file transitive Homebrew dylib
closure needs vendoring (not just `libnode`+`libuv`). This leaf's first provisioning attempt
computed that closure by `os.path.realpath()`-resolving every `@rpath`/absolute dependency and
copying **only the resolved real file** per formula (e.g. `libuv.1.0.0.dylib`) — which crashed the
launcher on the VM with `Library not loaded: /opt/homebrew/opt/libuv/lib/libuv.1.dylib` (`dyld`
never dereferences the symlink itself; the LC_LOAD_DYLIB path is the literal string `libuv.1.dylib`,
a symlink to the real file, and both must exist on disk). Fixed by copying every `*.dylib` in each
formula's `lib/` directory with `cp -P` (preserving symlinks as symlinks, not dereferencing them),
not just the one realpath-resolved file. A later rung's own VM provisioning should copy whole
`lib/` directories, never cherry-pick by resolved real filename.

## Testing-tool findings (not app defects)

- **`testanyware agent press --role … --label …` 400'd on every element this session tried**
  (button, radio, checkbox), including after `agent window-focus` and even though a filtered
  `agent snapshot --window "…" --role … --label …` confirmed a matching, enabled, `AXPress`-capable
  element existed. Root cause not identified (raised as a possible tool gap, not chased further per
  the "don't loop on a failing tool call" guidance). Worked around with `testanyware input click
  <x> <y>` against coordinates read from the accessibility snapshot's `positionX`/`positionY` —
  fully sufficient for this leaf's verification, but **the unscoped `agent snapshot` (no `--window`
  filter) also silently returns `elements: []`** for a background window even in JSON mode — always
  pass `--window <name>` once the app's target window may not be frontmost (Notification Center /
  another app can steal focus between actions, matching hello-window's own finding).
- **A small stepper's up/down arrow hit-targets (22×15 px in this VM's accessibility tree) are hard
  to hit precisely via raw VNC pixel clicks** — repeated clicks at the same nominal coordinate
  landed inconsistently on the increment vs. decrement half across attempts (value sequence
  5→2→6→4 across ~40 clicks, never exceeding [0, 10] but not cleanly monotonic either). Good enough
  to confirm live interaction + in-range behaviour; not a precise clamp-at-boundary proof. A later
  rung needing exact stepper-boundary verification should read the child `increment arrow
  button`/`decrement arrow button` elements' own precise coordinates from the snapshot (as this
  leaf eventually did) rather than estimate from the parent `spin-button`'s frame, and/or space
  clicks further apart.

## Findings for later rungs

- **AppKit's native behaviour alone is enough for checkbox toggle, slider/stepper clamping, and
  secure-field masking** — no app-side callback needed for any of those three. Radio exclusion is
  the one exception in this roster; assume nothing else is "automatic" without measuring it
  in-VM first, per this leaf's own radio finding above.
- **No block call site was needed here either** (matching hello-window) — every control in this
  roster uses target-action, not a block-based callback. The blocks frontier is still ungrown;
  still not this rung's concern.
- **The two-file bootstrap split, the `AW_*_SMOKE` construction-preflight convention, and the dev
  launcher (`embed_main.mm`) all carried over unchanged** — no new finding there, just confirmation
  they generalize past the app that introduced them.
