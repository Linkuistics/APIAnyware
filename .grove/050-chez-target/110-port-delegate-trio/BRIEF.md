# 110-port-delegate-trio — brief

## Goal
Bring three sample apps from racket to chez at full parity:
`ui-controls-gallery`, `scenekit-viewer`, `pdfkit-viewer`. All three
exercise the same new runtime piece — the **sync delegate** wired
via `runtime/dispatch.sls`'s `make-delegate` (target-action,
NSTextField actions, single delegate, multi-delegate) — at
increasing reach. They are the rungs 2-4 of the feature ladder in
the chez design spec §7.

End state: each app `.sls` is idiomatic Chez (no leftover `tell`,
no `_cprocedure`, `(values result error)` for fallible calls), each
bundles via `bundle-chez`, each passes TestAnyware in the VM.

## Why decomposed
The original leaf `110-port-delegate-trio.md` (now this node, with
its work split across the 010-040 children) treated the three apps
as one work leaf because they exercise one runtime feature. First
pass at execution showed the leaf is undersized for one session:
each port is hello-window-scale (~250 racket LOC plus delegate
adapter work — chez's `make-delegate` takes a list-of-specs, not
racket's keyword-argument shape), and per-app TestAnyware
verification cannot be CLI-driven
([[feedback-use-testanyware]] / [[feedback-vm-verify-every-app]]).

The leaf itself flagged this option in its notes
("If the leaf takes more than one session, split it… This is
grove-legal — see constraint 5."). Decomposed here, with one port
leaf per app + one batched verify leaf, mirroring the prior
[[100-port-hello-window-precedent]] (under
`.grove/done/050-chez-target/100-port-hello-window/`).

## Done when
- All four child leaves retire.
- Each app's source `.sls` is idiomatic Chez (no leftover racket
  forms or `_cprocedure`).
- Each app bundles via `bundle-chez` (precompile path included,
  per leaf `105`) and launches.
- Each app's TestAnyware run is green and a per-app report lands
  under `generation/targets/chez/test-results/<script>/report.md`.
- Activity Monitor: no growth.

## Decomposition

The runtime piece (sync delegate) is already in place — see
`runtime/dispatch.sls`'s `make-delegate` /
`set-delegate-method` / `free-delegate`. The three ports are
independent at the source level; sharing a delegate-bug fix-and-
revalidate flow happens via the batched `040` leaf, not via shared
intermediate state.

Order: simpler → more complex along the ladder rungs.

- `010-port-ui-controls-gallery.md` — rung 2. Two target-action
  delegates (radio mutual exclusion, slider live-value), broad
  AppKit control sweep (NSSlider, NSStepper, NSDatePicker,
  NSPopupButton, NSCombobox, NSColorWell, NSImageView,
  NSProgressIndicator, NSScrollView, NSStackView, NSSecureTextField).
- `020-port-scenekit-viewer.md` — rung 3. Single delegate +
  SceneKit framework reach. First use of SceneKit under chez —
  may surface emitter or runtime gaps SceneKit-specific.
- `030-port-pdfkit-viewer.md` — rung 4. Multi-delegate (PDFView
  delegate + something else from the racket source — confirm in
  the leaf). PDFKit framework reach.
- `040-testanyware-verify-trio.md` — VM-verify all three apps in
  one session. One report.md per app under
  `test-results/<script>/`. Per-app screenshots indistinguishable
  from the racket bar.

## Runtime delegate API (vs racket)

Chez `make-delegate` takes a list of 4-element specs:
```scheme
(make-delegate
  `(("selectorA:" ,procA (void*) void)
    ("selectorB:" ,procB (void*) void)))
```
where each element is `(selector proc param-types return-type)`.
The Swift trampoline strips `self` and `_cmd`, so `proc` receives
only the method args. `param-types` will almost always be
`(void*)` — the trampoline always delivers args as opaque
pointers.

Racket's API by contrast was keyword-driven:
```racket
(make-delegate
  #:return-types (hash "selectorA:" 'void)
  #:param-types  (hash "selectorA:" '(object))
  "selectorA:" (lambda (sender) …))
```

So the port is not a literal transliteration — every `make-delegate`
call must be rewritten in the list-of-specs form, and the wrapping
record must be kept alive (Cocoa delegate properties are weak;
`runtime/dispatch.sls` documents the lifetime invariant).

## Notes
- If a runtime bug surfaces during any one port, fix it in
  `runtime/dispatch.sls` (or wherever) and re-CLI-smoke all three
  before the verify leaf retires.
- The chez per-class library set is rich enough for these apps —
  see `apianyware/appkit/`, `apianyware/scenekit/`, `apianyware/pdfkit/`
  in the staged tree. If a needed symbol is missing, that's an
  emitter gap and earns its own leaf in this node.
- Precompile is on the path for every bundle — leaf 105 landed
  the `.sls` → `.so` pass at the bundler level. Bundle size grew
  ~2.7× per app; document in each app's report.
- Bundled menu-bar name reads as `chez` (matches racket bar) —
  not per-app fixable.

## Pointers
- Racket sources: `generation/targets/racket/apps/{ui-controls-gallery,
  scenekit-viewer,pdfkit-viewer}/*.rkt`.
- Chez delegate runtime: `generation/targets/chez/apianyware/runtime/dispatch.sls`
  (lines 285-405 ish — `delegate` record, `make-delegate`,
  `set-delegate-method`, `free-delegate`).
- App-menu helper: `generation/targets/chez/apianyware/runtime/cocoa.sls`'s
  `install-standard-app-menu!` (already used by hello-window).
- Design spec §7 (feature ladder).
- Prior art: `.grove/done/050-chez-target/100-port-hello-window/` —
  every leaf in there is a template for the parallel work here.
