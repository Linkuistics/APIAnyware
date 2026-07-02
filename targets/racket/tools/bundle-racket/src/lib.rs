//! Bundle racket sample apps into macOS `.app` bundles.
//!
//! Wraps `apianyware-stub-launcher` with the racket–specific
//! conventions: where source files live, how relative `(require ...)`
//! paths resolve, and how to lay out the bundle's `Resources` directory
//! so those same relative requires keep working from inside the bundle.
//!
//! Two modes:
//!
//! - **Self-contained** ([`bundle_app_self_contained`], the sample-app
//!   default since `racket-self-contained-bundle-k76`): `raco exe` +
//!   `raco distribute` under `Resources/racket-dist/` — the bundle runs on
//!   a machine with no Racket install, no `ffi2-lib` package, and no
//!   first-launch source compilation. See [`standalone`](self) module docs.
//! - **Shared-runtime** ([`bundle_app`] / [`bundle_app_with_entry`]): ships
//!   uncompiled `.rkt` source under `Resources/racket-app/` and execs a host
//!   racket. Kept for colocated dev projects (Modaliser-style) where a host
//!   Racket is a given and source-in-bundle aids debugging.
//!
//! # Example
//!
//! ```no_run
//! use apianyware_bundle_racket::{bundle_app_self_contained, AppSpec};
//! use std::path::Path;
//!
//! let spec = AppSpec::from_script_name("hello-window");
//! // The §18 domain tree splits apps from bindings: app-implementations under
//! // one root, the binding package (runtime / generated / lib) under another.
//! let apps_root = Path::new("targets/racket/app-implementations/macos");
//! let bindings_root = Path::new("targets/racket/bindings/macos");
//! let output_dir = Path::new("targets/racket/app-implementations/macos/hello-window/build");
//! let app_path = bundle_app_self_contained(&spec, apps_root, bindings_root, output_dir).unwrap();
//! println!("built: {}", app_path.display());
//! ```
//!
//! The shared-runtime bundle layout mirrors the colocated logical tree under
//! `Resources/racket-app/`:
//!
//! ```text
//! <App>.app/
//!   Contents/
//!     MacOS/<App>                          <- Swift stub, execvs into racket
//!     Info.plist                           <- CFBundleName = "<App>"
//!     Resources/racket-app/
//!       apps/<script>/<script>.rkt         <- entry script
//!       runtime/*.rkt                      <- traversed deps
//!       generated/<fw>/*.rkt            <- traversed deps
//!       lib/libAPIAnywareRacket.dylib      <- if present in source tree
//! ```

mod bundle;
mod deps;
mod spec;
mod standalone;

pub use bundle::{
    bundle_app, bundle_app_with_entry, resolve_signing_identity, AppSpec, BundleError,
    DEFAULT_RACKET_PATH, LOCAL_SIGNING_IDENTITY,
};
pub use deps::{collect_dependencies, collect_dependencies_in, SourceRoots};
pub use spec::read_display_name_from_spec;
pub use standalone::{bundle_app_self_contained, DIST_RESOURCE_SUBDIR};
