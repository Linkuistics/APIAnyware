# 040-emit-gerbil-crate — brief

Create the `emit-gerbil` emitter crate (`generation/crates/emit-gerbil/`),
modelled on `emit-chez` (NOT `emit-racket` — gerbil keeps the crossing in Gerbil,
ADR-0017), emitting maximally-idiomatic Gerbil from the enriched IR.

## Why a node

The chez reference is ~3,600 lines across 11 files (`emit_class.rs` alone is
1,208). Too big for one focused session, so this leaf is decomposed: a
**foundation** leaf that stands the crate up and compiles (the IR-neutral
machinery the shared `emit` crate exposes is reused; only the Gerbil-specific
half is written), then one leaf per construct family. Each construct leaf wires
its emitter into `emit_framework` so the crate compiles and tests green at every
commit.

## Shape of the crate (mirrors emit-chez)

- `Cargo.toml` + `lib.rs` — crate skeleton; deps `apianyware-macos-types`,
  `apianyware-macos-emit`; workspace member + `workspace.dependencies` entry.
- `naming.rs` — selector → Gerbil identifier mapping (reuses shared
  `selector_to_kebab_name`/`class_name_to_lowercase`; Gerbil idents share the
  Scheme alphabet, so this is thin like chez's).
- `ffi_type_mapping.rs` — `GerbilFfiTypeMapper`: arm64 width aliases +
  **struct-by-value** `(c-define-type CGRect (struct "CGRect"))`, by-value args
  (FINDINGS §4) — the genuine divergence from chez's by-reference `(& NSRect)`.
- `method_filter.rs` — which methods the emitter can bind (variadic/deprecated
  skip, struct/block bridgeability).
- `shared_signatures.rs` — per-signature `define-c-lambda` dedup helpers + the
  framework→shared-object / unexported-symbol skip lists.
- `emit_class.rs`, `emit_protocol.rs`, `emit_enums.rs`, `emit_constants.rs`,
  `emit_functions.rs`, `emit_framework.rs` — the construct emitters + orchestrator.

## Done when (the node)

Everything in the design spec §2/§3/§3a/§8 + the original leaf's Done-when is
emitted and the crate compiles wired into the workspace. The 040-level
acceptance is the union of the child leaves' Done-whens:

- **Dispatch (ADR-0017):** one typed `define-c-lambda` per distinct method ABI
  signature (`shared_signatures` dedup), inline-cast `objc_msgSend` bodies,
  `___CAST`/`___return` for `const` returns (FINDINGS §1).
- **`begin-ffi`** blocks with C-safe headers (`<objc/runtime.h>`,
  `<objc/message.h>`, CoreGraphics); FFI unit compiled `-x objective-c` (§4).
- **Object model (ADR-0020, supersedes ADR-0018):** the **full ObjC class graph
  reified as a `defclass` hierarchy**, with **both** dispatch surfaces over it
  (built-in `{sel obj}` MOP *and* `:std/generic` `(sel obj)`, shared identifiers)
  forwarding to an inlinable per-class proc core; **transparent extensible
  subclassing** (`(defclass (MyView NSView) …)` synthesizes a real ObjC subclass).
- **Error model:** `(values result error)` for trailing-`NSError**` methods
  (ADR-0006 applied to gerbil).
- Enums/constants/functions in idiomatic Gerbil.
- Module/package layout: a binding **library** (compiled once to `.ssi`+`.o1` —
  the *runtime/CLI* compiles; the emitter writes Gerbil **source** `.ss` modules),
  per-class files, a `main` re-export (cross-target on-disk symmetry, CONTEXT.md).

## Children

- **010** crate foundation — skeleton + `naming`/`ffi_type_mapping`/
  `method_filter`/`shared_signatures` + a minimal `emit_framework` (empty
  framework → module-layout skeleton + `main` re-export). Compiles, empty-fw test
  green. Settles the Gerbil **module/package layout** (`.ss` filenames, the
  `(import :…/<fw>/<cls>)` form, the `main` re-export shape) since every later
  emitter slots into it.
- **020** class emitter (`emit_class.rs`) — the heavy one, **re-decomposed after
  the ADR-0020 object-model pivot** into: 030 manifest `defclass` graph, 040 proc
  core + dual consumption surfaces (`{}` + `:std/generic`) + constructors +
  properties, 050 `(values result error)`. (010 dispatch-proc-core done — its
  `%msg-…` crossings survive; its single-`objc-obj` surface is rewritten onto the
  graph.) See `020-emit-class/BRIEF.md`. Wire into `emit_framework`.
- **030** protocol emitter (`emit_protocol.rs`) — delegate-protocol emission.
  Wire in.
- **040** enums + constants + functions emitters — idiomatic Gerbil. Wire in.

## Pointers

- Design: `docs/specs/2026-06-03-gerbil-target-design.md` (§2 idiom, §3 dispatch,
  §3a object model, §4 C-vs-ObjC FFI, §8 layout).
- Reference: `generation/crates/emit-chez/src/` (every file has a Gerbil
  counterpart) and `generation/crates/emit/src/` (shared trait/writer reused).
- Glossary: `CONTEXT.md` — `Manifest class hierarchy (gerbil)`, `Generated
  define-c-lambda dispatch (gerbil)`, `Dual dispatch surface / proc core
  (gerbil)`, `Transparent extensible subclassing (gerbil)`, `:std/foreign`.
- ADRs: 0017 (dispatch + native core), **0020 (object model — supersedes 0018)**,
  0019 (lifetime), 0006 (error model).
- FINDINGS: `docs/research/2026-06-03-gerbil-ffi-dispatch-spike/FINDINGS.md`
  §1 (`___CAST`/const), §4 (struct-by-value, `-x objective-c`).

## Out of scope (later leaves)

CLI registration + emission/snapshot tests are **060**; the Gerbil runtime
modules + ObjC native core are **050**. This node writes the *emitter* only. It
may add a workspace-member entry so the crate compiles, but the
`generation/crates/cli` registry wiring stays in 060 per the build-subtree plan.
