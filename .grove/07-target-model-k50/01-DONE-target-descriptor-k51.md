# target-descriptor-k51

**Kind:** work

## Goal

Stand up the **target-model foundation** (ws6 child 1, D7): the shared
`targets/_shared/tools/target-model` crate with its first submodule `descriptor/`, the
`schemas/spec-format/target.kdl-schema` contract, and an authored `target.apiw` **descriptor**
for each of the four live targets (racket / chez / gerbil / sbcl). This is the smallest
foundational unit — it sets the authored-`.apiw` + KDL-Schema + focused-validator pattern the
later ws6 children mirror (the ws4 platform-manifest-first move).

## Context (see `grove-llm brief-chain` — esp. node BRIEF running log D1–D7)

- **D4 (target descriptor):** `target.apiw` carries §17's seven per-implementation facets —
  `family` / `dialect` / `implementation` / `ffi-backend` / `runtime-model` / `projection-policy`
  / `adapter-strategy`. `targets/<t>/` is one implementation; flat dir; no `implementations/`
  subdir yet.
- **D5 (crate home):** one shared `targets/_shared/tools/target-model` crate, submodules per
  entity. This child creates the crate + the `descriptor/` submodule only (later children add
  `capability/`, `idioms/`, … to the *same* crate). ws6 authors the `.apiw` KDL Schema + focused
  in-crate validator; **ws8** owns the machine JSON Schema.
- **Conventions to mirror** (read before coding): an existing one-crate/submodule platform model
  crate (`platforms/macos/tools/app-kinds` or `platforms/macos/tools/platform-tests`) for the
  `.apiw` parse + serde + focused-validator + KDL-Schema-sibling pattern; an existing
  `schemas/spec-format/*.kdl-schema` (e.g. `app-kind.kdl-schema`) for the schema dialect; the
  authored overlay is **KDL 2.0 `.apiw`** (ADR-0046), machine side JSON. Crate-home convention:
  shared machinery → `targets/_shared/tools/<crate>/`; register in the root `Cargo.toml`
  `members`.
- **Facet values** come from `CONTEXT.md` (the target toolchain sections already state each
  target's FFI backend, runtime model, projection posture): racket (ffi2 + `ffi/unsafe/objc`,
  interpreted-FFI, stub-launcher distribution, trampoline-elided), chez (`foreign-procedure`,
  compiled-FFI, guardian lifetime, self-contained), gerbil (`:std/foreign`/`define-c-lambda`,
  compiled-FFI, `static-exe`), sbcl (`sb-alien`, image-dump/`save-lisp-and-die`, sole-native-unit
  `libAPIAnywareSbcl`, MOP/CLOS). Ground each facet in CONTEXT, don't invent.

## Done when

- `targets/_shared/tools/target-model` crate exists (in root `Cargo.toml` `members`), builds, with
  a `descriptor/` submodule: serde types for the §17 facets + a `.apiw` parser + a focused validator
  (required-facet presence + controlled-vocab checks where a facet is enumerable).
- `schemas/spec-format/target.kdl-schema` authored (the language-neutral contract; Rust types
  conform to it, not vice-versa — the ws2 rule).
- `targets/{racket,chez,gerbil,sbcl}/target.apiw` authored, each parsing + validating green.
- Tests: parse+validate the four authored files; a malformed/missing-facet fixture rejected.
- **Goldens unmoved** (no emitter touched); `cargo build` + the crate's tests + the existing
  suite green. Partial discharge of the `targets/README.md` ws6 marker (target descriptors done;
  rest of the layer still owed).

## Notes

- Skeleton-first: this child is buildable + goldens-green on its own; it adds no consumer.
- Keep the validator **focused** (the contract's subset), not a general KDL-Schema validator
  (that is ws8) — the ws2/ws3/ws4 precedent.
- Commit handle: `target-descriptor-k51`.
