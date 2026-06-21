# 020-hello-window

**Kind:** work

## Goal

Build the `hello-window` sample app (window + centred label) under
`generation/targets/sbcl/apps/hello-window/`, written against the CL-family contract,
and TestAnyware VM-verify it. As the first app it also stands up the shared pipeline
(generate `--target sbcl` → `swift build` dylib → load → run) and the dev
binding-library loader the ladder reuses.

## Context

First member of the 060 ladder; proves the whole pipeline end-to-end on pure-ObjC API.
Repeatable green baseline: the 050 runtime smoke (`run-integration-smoke.sh`).

## Done when

- hello-window built + VM-verified; `learnings.md` + `test-results/report.md` recorded.

## Progress / running log

**Pipeline bootstrap done (2026-06-21):** this worktree had no collected/enriched IR
(both gitignored). Ran the full first-time bootstrap and confirmed each stage:
- `apianyware-macos-collect` → 284 frameworks, 0 errors.
- `analyze --only Foundation,AppKit,CoreGraphics resolve` → `annotate --llm-dir
  analysis/ir/llm-annotations` (seeds the committed LLM annotations) → `enrich`.
- `apianyware-macos-generate --target sbcl` → 647 files / 626 classes / 186 protocols /
  566 enums + `swift/Sources/APIAnywareSbcl/Generated/Trampolines.swift`. **First time
  the emitter ran against REAL frameworks** (previously only synthetic TestKit goldens).
- `swift build --product APIAnywareSbcl` → `libAPIAnywareSbcl.dylib`. `otool -L`: only
  dep is itself (`@rpath`) + `/usr/lib` + system frameworks → **the dylib travels alone**
  (no vendored Swift libs); all `/usr/lib/swift/*` ship in the VM.

**Loader done:** `apps/_support/load-bindings.lisp` — `aw-app-load-framework` globs a
generated framework (facade → generics → class files in ARBITRARY order →
protocols/enums/constants/functions). Confirmed: Foundation loads + all 309 classes
finalize in arbitrary order — CLOS forward-referenced superclasses (ADR-0034 §1) make
the topological-load problem vanish, so no `.asd` manifest is needed for the dev loader
(the production ASDF loader stays 070's job).

**TWO BLOCKERS surfaced — the first real multi-framework load cannot proceed:**

1. **Cross-framework generic arity collisions (ADR-worthy).** Kebab-casing drops the
   selector `:`, so `foo` (0-arg) and `foo:` (1-arg, the action shape) both map to
   `ns:foo` at different arities. Foundation emits `(defgeneric ns:cancel (receiver))`,
   AppKit emits `(defgeneric ns:cancel (receiver arg0))` → CLOS rejects the incongruent
   redefinition at load (`New lambda-list … incompatible with existing methods`).
   Cross-framework so far: `ns:cancel ns:stop ns:terminate`; within-AppKit (the emit-time
   first-wins WARN): 14 more (`activate hide stop-animation start-animation …`). The
   emitter's `generic_arity_conflicts` ASSUMED this "empty in practice" AND only runs
   per-framework, so it never sees the cross-framework clash. Candidate resolutions:
   (a) `&optional`-pad colliding generics (keep clean call syntax + both methods
   reachable — leaning); (b) uniform `(receiver &rest args)` generics; (c) first-wins
   drop (LOSSY — violates the complete-API model ADR-0025; rejected); (d) collision-rename
   the action selector. Needs a GLOBAL generic pass (max-arity per name across all
   frameworks) — touches `emit_generics`/`emit_class` + the contract spec §3.2.

2. **Typed multi-arg ObjC inits not wired.** `make-instance` → `aw-apply-init`
   (objc.lisp) handles only 0-arg and 1-arg **id** inits (`ecase (length kw-list) (0)(1)`,
   args passed as `aw-ptr`). `register-objc-init` bakes **only keywords, no arg types**.
   So `NSWindow`'s designated `initWithContentRect:styleMask:backing:defer:` (NSRect by
   value + 2 enums + BOOL) cannot be constructed via the contract path. Flagged as a
   "documented refinement" in the runtime + design spec §8; hello-window is the forcing
   function. Fix: emitter bakes per-arg sb-alien types into `register-objc-init`; runtime
   marshals a typed `objc_msgSend` (structs by value, scalars, bools, ids).

Both block ALL apps (every app coloads ≥2 frameworks + constructs typed-init objects).
Awaiting direction on process (design/planning leaf vs fix-in-place) — see session report.
