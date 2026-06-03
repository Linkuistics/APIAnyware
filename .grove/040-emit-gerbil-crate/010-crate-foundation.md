# 010-crate-foundation

**Kind:** work

## Goal

Stand up the `emit-gerbil` crate so it **compiles, is a workspace member, and
emits the module-layout skeleton for an empty framework**. Write the foundation
modules every construct emitter depends on, and settle the Gerbil
module/package layout that the later emitters slot into.

## Context

Node brief: `.grove/040-emit-gerbil-crate/BRIEF.md`. Design spec §2 (idiom),
§4 (C-vs-ObjC FFI), §8 (layout). Mirror `emit-chez`'s foundation files; the
shared `emit` crate (`generation/crates/emit/src/`) already provides the
IR-neutral half (`TargetEmitter`/`TargetInfo`/`EmitResult`, `CodeWriter`,
`FileEmitter`, `naming::{selector_to_kebab_name, class_name_to_lowercase,
camel_to_kebab, is_mutating_selector}`, the `FfiTypeMapper` trait) — reuse it,
don't reinvent.

## Done when

- `generation/crates/emit-gerbil/` exists with `Cargo.toml` (deps
  `apianyware-macos-types`, `apianyware-macos-emit`; `[lints] workspace = true`)
  and `lib.rs`; added to root `Cargo.toml` `members` + `workspace.dependencies`
  as `apianyware-macos-emit-gerbil`. `cargo build -p apianyware-macos-emit-gerbil`
  is green.
- `naming.rs` — selector → Gerbil identifier mapping (constructor `make-…`,
  method, property getter/setter `…-set-x!`, class-method disambiguation, the
  per-method msgSend/selector binding names). Thin over the shared helpers, like
  chez's. Unit tests mirror chez's.
- `ffi_type_mapping.rs` — `GerbilFfiTypeMapper: FfiTypeMapper`. Primitive →
  Gerbil/Gambit C type tokens; `id`/`Class`/`SEL`/block → the pointer token.
  **The divergence to get right:** geometry structs cross **by value** —
  `(c-define-type CGRect (struct "CGRect"))` with by-value args (FINDINGS §4),
  NOT chez's by-reference `(& NSRect)`. Carry the geometry-alias set + the
  block-bridgeability helpers (`is_bridgeable_block`, the token allow-list) the
  way chez does. Settle exactly which Gambit/`:std/foreign` type tokens are used
  (e.g. `int`, `unsigned-int`, `double`, `float`, the `(pointer void)` form) —
  this is a real research/decision sub-task; record the mapping in a doc-comment.
- `method_filter.rs` — `is_supported_method` (skip variadic/deprecated/Swift-paren;
  defer unsupported struct-by-value / un-bridgeable block params / fn-pointer &
  raw-pointer params). Port chez's predicates.
- `shared_signatures.rs` — the `define-c-lambda` per-signature dedup helper(s)
  (an ABI-signature key the class emitter will group by) + framework→shared-object
  arg + the libdispatch-unexported skip list. (chez's `shared_signatures.rs` only
  carries the latter two; the *dedup* is the gerbil analogue of chez's
  per-signature `foreign-procedure` sharing — design the key here so 020 reuses it.)
- `emit_framework.rs` — `GerbilEmitter` impl of `TargetEmitter` with
  `GERBIL_TARGET_INFO` (`id: "gerbil"`, `display_name: "Gerbil Scheme"`,
  `generated_subdir`: pick the Gerbil-resolver-correct value — see Notes).
  `emit_framework` handles the **empty framework**: writes the `main` re-export
  and nothing else. Empty-framework test green (analogue of chez's
  `empty_framework_writes_just_main`). Class/protocol/enum/const/function loops
  are stubbed-but-present (call into the sub-emitters added by 020–040), or
  omitted until those leaves wire them in — implementer's call, but the file must
  compile.

## Notes

**Module layout decision (settle here, it constrains 020–040).** chez writes
per-class `.sls` + a sibling `<framework>.sls` facade because Chez's resolver maps
`(apianyware <fw>)` → `<libdir>/apianyware/<fw>.sls`. Gerbil's resolver is
different: modules are `.ss` source resolved by `:package/path` against the
package root + `gerbil.pkg`. Decide: the `.ss` filename per class, the
`(import :…/<fw>/<cls>)` import path, and the `main` re-export module shape
(Gerbil `(export (import: …))` re-export vs explicit `(export …)`), consistent
with design §8's `lib/` layout and CONTEXT.md's cross-target on-disk symmetry
(per-class files + a `main` re-export). The emitter writes Gerbil **source** —
compilation to `.ssi`+`.o1` is 050/060's job, not this crate's.

`generated_subdir` + any package-root/`gerbil.pkg` emission interacts with how
060's CLI invokes the emitter and how 050's runtime imports it; if a clean
answer needs the runtime's package name, capture an inbox note to 050 rather than
guessing. Keep the layout decision in a doc-comment on `emit_framework.rs` so
020–040 and 060 inherit it.
