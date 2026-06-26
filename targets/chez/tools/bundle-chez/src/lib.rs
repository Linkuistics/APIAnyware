//! Bundle chez sample apps into self-contained macOS `.app` bundles.
//!
//! A chez `.app` is a **standalone open-world** binary that embeds the
//! Chez kernel and a whole-program boot image — it launches on a machine
//! with no Chez Scheme installed (ADR-0009; design spec
//! `targets/chez/docs/design/2026-05-29-chez-standalone-distribution-design.md`). The
//! host Chez is a *build-time* dependency only (the kernel artifacts are
//! discovered from it). There is no source-exec / system-Chez path.
//!
//! # Example
//!
//! ```no_run
//! use apianyware_bundle_chez::{bundle_app, AppSpec};
//! use std::path::Path;
//!
//! let spec = AppSpec::from_script_name("hello-window");
//! // The §18 domain tree splits the chez material: apps under one root, the
//! // package root (`apianyware/`) + dylib (`lib/`) under another. The bundler
//! // stages both into one whole-program-compile tree natively
//! // (`SourceRoots::split`) — no stitching by the caller.
//! let apps_root = Path::new("targets/chez/app-implementations/macos");
//! let bindings_root = Path::new("targets/chez/bindings/macos");
//! let output_dir = Path::new("targets/chez/app-implementations/macos/hello-window/build");
//! let app_path = bundle_app(&spec, apps_root, bindings_root, output_dir).unwrap();
//! println!("built: {}", app_path.display());
//! ```
//!
//! Bundle layout per design spec §5:
//!
//! ```text
//! <App>.app/
//!   Contents/
//!     MacOS/<App>                          <- native binary: embed_main + libkernel + app boot
//!     Info.plist                           <- CFBundleName = "<App>"
//!     Resources/
//!       <App>.boot                         <- petite+scheme+app whole-program boot
//!       lib/libAPIAnywareChez.dylib        <- loaded at runtime by ffi.sls (mandatory)
//! ```
//!
//! ## Difference from bundle-racket
//!
//! - **Dependency walker.** Chez `(import ...)` uses library
//!   references, not filesystem paths. The walker (`deps.rs`) shells
//!   out to `chez --script scripts/extract-deps.ss` to use chez's own
//!   reader and library-spec semantics — far less fragile than a
//!   hand-rolled Rust s-expr parser.
//! - **Mandatory dylib.** `libAPIAnywareChez.dylib` must exist under
//!   `<source_root>/lib/`; bundling fails fast if it's missing.
//!   bundle-racket treats the dylib as optional (a runtime-load
//!   fallback exists on the racket side).
//! - **Self-contained binary.** Where bundle-racket ships a Swift stub
//!   that execs the system `racket`, the chez bundle embeds the Chez
//!   kernel directly (`standalone.rs`): no runtime interpreter, no
//!   `--libdirs` indirection.

mod bundle;
mod deps;
mod spec;
mod standalone;

pub use bundle::{resolve_signing_identity, AppSpec, BundleError, LOCAL_SIGNING_IDENTITY};
pub use deps::{
    collect_dependencies, collect_dependencies_split, collect_dependencies_with_chez, SourceRoots,
    DEFAULT_CHEZ_BIN,
};
pub use spec::read_display_name_from_spec;
pub use standalone::{bundle_app, compute_collisions, generate_wrapper, Collisions};
