//! Gerbil Scheme code generation.
//!
//! Produces idiomatic Gerbil bindings per framework: per-class `.ss` modules
//! whose bodies hold `begin-ffi` blocks of typed `define-c-lambda`
//! `objc_msgSend` call sites (one per distinct method ABI signature), a
//! procedural core of plain procedures over the single `objc-obj` handle, and
//! an opt-in `:std/generic` veneer — plus companion `enums.ss`, `constants.ss`,
//! `functions.ss`, `protocols/<proto>.ss`, and a sibling `<framework>.ss`
//! re-export facade.
//!
//! The crate is modelled on `emit-chez` (NOT `emit-racket`): Gerbil keeps the
//! crossing *in Gerbil* — generated per-signature `define-c-lambda`, no generated
//! Swift dispatch table, no `swift build` step (ADR-0017). The genuine
//! divergence from chez is at the source-form level: geometry structs cross
//! **by value** via `(c-define-type CGRect (struct "CGRect"))` rather than
//! chez's by-reference ftype-pointers, and dispatch is open-coded as inline-cast
//! `objc_msgSend` inside `define-c-lambda` bodies (FINDINGS §4, §1).
//!
//! ## Module/package layout (settled here; constrains the construct emitters)
//!
//! - Package: **`gerbil-bindings`**. A class `<Cls>` of framework `<Fw>` is
//!   imported as `:gerbil-bindings/<fw>/<cls>` (design spec §2). The emitter
//!   writes Gerbil **source** `.ss` modules; compilation to `.ssi`+`.o1` is the
//!   runtime/CLI's job (leaf 050/060), not this crate's.
//! - On disk (under the emitter's `output_dir`, the package root —
//!   `generated_subdir = "lib"`, design §8):
//!   ```text
//!   <fw>.ss                 facade — :gerbil-bindings/<fw>, re-exports siblings
//!   <fw>/<cls>.ss           one module per class — :gerbil-bindings/<fw>/<cls>
//!   <fw>/enums.ss
//!   <fw>/constants.ss
//!   <fw>/functions.ss
//!   <fw>/protocols/<proto>.ss
//!   ```
//!   This mirrors chez's `apianyware/<fw>.sls` + `apianyware/<fw>/<cls>.sls`
//!   shape, so the facade-generation machinery (`SubModule` collection +
//!   collision-rename) ports directly. The `<fw>.ss` facade IS the per-framework
//!   `main` re-export (cross-target on-disk symmetry, CONTEXT.md).
//! - The static `gerbil.pkg` package manifest (one file for the whole tree,
//!   IR-independent) is owned by the runtime/build setup (leaf 050), not emitted
//!   per run. See the inbox note captured for 050.

pub mod class_graph;
pub mod emit_class;
pub mod emit_constants;
pub mod emit_enums;
pub mod emit_framework;
pub mod emit_functions;
pub mod emit_protocol;
pub mod ffi_type_mapping;
pub mod method_filter;
pub mod naming;
pub mod shared_signatures;

pub use emit_framework::GerbilEmitter;
