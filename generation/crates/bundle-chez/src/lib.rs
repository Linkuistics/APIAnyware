//! Bundle chez sample apps into macOS `.app` bundles.
//!
//! Wraps `apianyware-macos-stub-launcher` with the chez–specific
//! conventions: where source files live, how `(import ...)` forms
//! resolve to file paths via library-name registry, and how to lay out
//! the bundle's `Resources` directory so the bundled `chez --script`
//! invocation finds the entry and its dependencies.
//!
//! # Example
//!
//! ```no_run
//! use apianyware_macos_bundle_chez::{bundle_app, AppSpec};
//! use std::path::Path;
//!
//! let spec = AppSpec::from_script_name("hello-window");
//! let source_root = Path::new("generation/targets/chez");
//! let output_dir = Path::new("generation/targets/chez/apps/hello-window/build");
//! let app_path = bundle_app(&spec, source_root, output_dir).unwrap();
//! println!("built: {}", app_path.display());
//! ```
//!
//! Bundle layout per design spec §8:
//!
//! ```text
//! <App>.app/
//!   Contents/
//!     MacOS/<App>                          <- Swift stub, execvs into chez --script
//!     Info.plist                           <- CFBundleName = "<App>"
//!     Resources/chez-app/
//!       apps/<script>/<script>.sls         <- entry script
//!       apianyware/runtime/*.sls           <- traversed deps
//!       apianyware/<fw>/*.sls              <- traversed deps
//!       lib/libAPIAnywareChez.dylib        <- always present (mandatory)
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
//! - **Stub runtime args.** The stub invokes
//!   `chez --libdirs <Resources/chez-app> --script <entry>`; the
//!   `--libdirs` flag points at the bundle's resource subdir so Chez
//!   resolves `(apianyware ...)` library names against
//!   `apianyware/runtime/` and `apianyware/<fw>/`. bundle-racket
//!   invokes `racket <entry>` with no flag.

mod bundle;
mod deps;
mod precompile;
mod spec;

pub use bundle::{
    bundle_app, bundle_app_with_entry, resolve_signing_identity, AppSpec, BundleError,
    DEFAULT_CHEZ_PATH, LOCAL_SIGNING_IDENTITY,
};
pub use deps::{collect_dependencies, collect_dependencies_with_chez, DEFAULT_CHEZ_BIN};
pub use spec::read_display_name_from_spec;
