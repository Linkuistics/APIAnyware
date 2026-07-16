# scenekit-viewer — learnings (Node TypeScript target, ladder app 3/7)

The first app to exercise `@apianyware/scenekit` and to route **three** target-action selectors
through one handler object. Needed no runtime changes — every finding below is either a
design/API-surface finding specific to this app, a corpus-typecheck finding, or a
VM-provisioning/tooling note.

## Finding: `SCNView`'s designated initializer needs a real (if empty) options dictionary

`SCNView` declares its own `initWithFrame:options:` and does **not** override plain
`initWithFrame:` — so unlike this ladder's prior apps (which all used a class's own inherited
`NSView.initWithFrame_`), a bare `__alloc(SCNView).initWithFrame_(rect)` would silently run only
`NSView`'s init, skipping whatever `SCNView`'s own designated initializer sets up. No emitted
signature in this corpus is nullable at an object parameter yet (ADR-0055's "`T | null` from
annotations" applies to positions Apple's headers actually annotate nullable; `options:` isn't
one), so there is no way to spell Apple's own "pass nil for defaults" convention directly. Worked
around with `__alloc(NSDictionary).init()` as the options argument — confirmed correct in-VM (the
view renders, lights, and accepts camera control normally; an empty dictionary and a nil
dictionary are behaviourally identical for every key `SCNView` reads). Worth root-causing whether
the emitter should surface nullable object params in a future leaf if a case turns up where an
empty stand-in isn't equivalent to nil (this one clearly was).

## Finding: the target-action handler pattern scales cleanly from one selector to three

`ui-controls-gallery`'s `GalleryController` (one `selectRadio:` selector) generalizes directly to
this app's `SceneController` (`geometryChanged:`/`openColor:`/`colorChanged:`) with no new
runtime machinery — same `__subclassAlloc`/`__bindSubclass` primitives, same
`SubclassOverride[]` shape (`['selector:', 'v@:@']` per selector, all three the vanilla
one-object-arg-void-return encoding), same module-level-`const`-keeps-it-alive rule (`NSControl`
target/action are non-retaining). The controller also holds ordinary instance state (`node`,
`picker`, `currentColor`) set in its own constructor after `super()` — nothing SceneKit-specific
about the wiring itself. A later rung wiring any number of target-action selectors to one handler
can copy this shape directly; there is no practical selector-count limit this leaf hit.

## Finding: colour persistence needed no manual retain bookkeeping, unlike sbcl's own-color dance

The spec's load-bearing behaviour (§7) is that the current colour survives a geometry swap even
though SceneKit hands every new geometry a **fresh** default material. sbcl's own implementation
(the closest architectural reference) needs an explicit `own-color` helper that retains the
colour to +1 and arms a release finalizer, because Lisp's GC has no relationship to ObjC retain
counts — the material that used to hold the colour is what kept it alive, and swapping geometry
deallocates that material. **This target needed none of that**: ADR-0057's uniform-+1 unique
wrapper model means every returned object (including the colour `NSColorPanel.color()` hands
back, and the one `colorUsingColorSpace:` converts) is retained for as long as *any* JS reference
to its wrapper exists — so simply assigning `this.currentColor = converted` in the controller is
the entire lifetime story. Confirmed in-VM across two consecutive swaps (Sphere → Torus → Cube,
recolouring once in between): the colour never reverted to white. Worth calling out explicitly
for a later rung: **don't port a Lisp reference implementation's manual retain dance verbatim** —
check whether ADR-0057's model already makes it unnecessary before adding one.

## Corpus finding: this app is the first to reach `SCNLayer`'s pre-existing TS2420

Compiling `app.ts` pulled `@apianyware/scenekit` into the transitive `tsc` closure for the first
time in this ladder, which reaches `scnlayer.ts` — `SCNLayer` conforms both `CALayerDelegate`
(via its `CALayer` ancestry) and `SCNSceneRenderer`, whose `setDelegate:` signatures collide, the
same "vacuous-but-ObjC-legal conformance" species `corpus-typecheck-gate-k75`'s own census
already catalogued for `CALayoutManager`. Not a regression — the generated file is untouched,
gitignored, machine output. `build.sh`'s tolerance regex (previously `TS2559` only, copied from
hello-window/ui-controls-gallery) now also accepts `TS2420`. A later rung reaching a framework
outside the 17-framework set `corpus-typecheck-gate-k75` originally measured should expect the
same: a previously-uncounted-but-real residual from the same known bucket, not a new defect.

## Tooling finding: a multi-line tsc diagnostic breaks a single-line `grep -v` tolerance filter

`build.sh`'s "tolerate known error codes" filter (`grep -v 'TS2559'`) silently assumed every
diagnostic is one line. `TS2420`'s own message wraps onto several indented continuation lines
that carry no error code at all (`Types of property 'setDelegate_' are incompatible.` etc.) — a
naive `grep -vE 'TS2559|TS2420'` still flagged those continuation lines as "unexpected" and
failed the build even though the diagnostic itself was tolerated. Fixed by also excluding any
line starting with whitespace (`grep -vE 'TS2559|TS2420|^[[:space:]]'`) — a continuation of the
preceding (already-classified) diagnostic. A later rung adding a new tolerated code should check
whether that code's own tsc output wraps multi-line before assuming a bare code-match filter is
enough.

## VM-provisioning finding: the golden image already ships a non-empty `/opt/homebrew` prefix

Unlike the mental model hello-window's own learnings might suggest ("nothing installed"), this
session's fresh golden clone already has a real Homebrew *prefix* structure at `/opt/homebrew`
(`bin`/`lib`/`Cellar`/`opt`/etc., owned by the `admin` user) — just no actual formulas installed
under it. The 25-file transitive Homebrew dylib closure (same shape ui-controls-gallery's own
learnings measured: ICU/brotli reached via `@loader_path`/`@rpath`, not just absolute paths)
extracted straight into the existing tree with no `sudo` and no golden-image rebuild — `tar`
printed harmless "Can't restore time" warnings on the pre-existing top-level directories (a
permissions-on-mtime-only issue) but every file extracted correctly. A later rung's own
provisioning script should not assume it needs to `mkdir -p /opt/homebrew` from scratch, and
should not treat a `tar` exit code of non-zero as fatal without checking whether the actual
content landed (`find`/`ls` after extraction, as this leaf did).

## VM-provisioning finding: the first cold exec after extraction needs a longer timeout

Both the construction pre-flight and the first real launch attempt **timed out at the default
30s** `file exec` budget on the VM, then succeeded cleanly on retry with a 60s budget — almost
certainly cold-disk-cache I/O for the freshly-extracted 119 MB dylib closure (25 formula `lib/`
directories, not just the resolved files) plus the 1809-file `build/js/` tree, not an app defect
(the host run and the VM's own *second* run of the same binary were both fast). A later rung's
own first VM exec after provisioning should budget `--timeout 60` (or more) rather than the
default, especially right after a large `tar` extraction.

## Testing-tool findings (not app defects, consistent with prior apps)

- **`testanyware agent press` still 400s on every element this session tried** (the pop-up
  button, its menu items, the colour button) — the same gap ui-controls-gallery's own learnings
  already flagged. Worked around identically: `testanyware input click <x> <y>` against
  coordinates read from `agent snapshot`'s `positionX`/`positionY` (+ half the element's own
  size for the center).
- **A pop-up button's menu re-aligns to show the *currently selected* item at the click point**
  exactly as spec §13's own driver guidance warns — confirmed directly: after selecting "Sphere",
  reopening the picker put "Torus" (the next item) at the position "Sphere" itself had occupied
  in the previous open. **Always re-read the snapshot after every reopen**; never reuse item
  positions from a prior open, even for the "same" menu.
- **A menu item's own bounding box top edge is an unreliable click target** — clicking exactly at
  an item's reported `positionY` (its top edge) landed inconsistently (once reselected the
  already-current item instead of the intended one); clicking at the item's vertical *center*
  (`positionY + sizeHeight / 2`) was reliable across every attempt this session made. A later
  rung driving any AXMenu item should click the center, not the reported top-left corner.
- **The colour panel's own colour wheel has no accessibility-exposed "click here for blue"
  affordance** — recolouring was driven by an approximate raw-pixel click read visually off a
  screenshot of the wheel, not a computed/exact colour value. Sufficient to prove live recolour +
  persistence (the spec's own actual bar — exact RGB values are explicitly "to confirm in-VM" at
  the pixel level, outside the closed verb set per spec §13), but a later rung wanting an *exact*
  target colour should not assume click-to-colour precision from this approach.

## Findings for later rungs

- **The spin action can be invisible on a shape that happens to be rotationally symmetric about
  the spin axis** — this app's own Torus, spun around Y with its hole aligned to Y, showed no
  visible change across two screenshots 3s apart, while the Cube (asymmetric) clearly did. Not a
  bug; don't mistake a symmetric shape's static-looking render for a stalled animation in a later
  rung's own report — verify against an asymmetric shape if in doubt.
- **The two-file bootstrap split, the `AW_*_SMOKE` construction-preflight convention, and the dev
  launcher (`embed_main.mm`) all carried over unchanged again** — third confirmation (after
  hello-window introduced them and ui-controls-gallery reused them) that they generalize past
  AppKit-only apps to a second framework (SceneKit) with no adaptation needed beyond the
  smoke-env-var name and the app.js import path.
- **`globals.d.ts` needs both `process` and `console` ambient declarations** if the app calls
  `console.log` for its launch diagnostic (every app in this ladder does, per spec) — copy
  ui-controls-gallery's `globals.d.ts` (which has both), not hello-window's (which predates the
  app calling `console.log` and only declares `process`).
