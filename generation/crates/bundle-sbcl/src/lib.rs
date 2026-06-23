//! Bundle sbcl sample apps into self-contained macOS `.app` bundles.
//!
//! An sbcl `.app` ships a `save-lisp-and-die :executable t` **image** (which
//! embeds the SBCL runtime, the loaded binding library, and the app) behind a
//! thin Swift **stub** launcher. The pipeline, per app ([`standalone::bundle_app`]):
//!
//! 1. **Dump** ([`dump`]) — drive the app's own `dump.lisp` (which declares its
//!    framework set + run-loop `:toplevel`) to write the image into
//!    `Contents/Resources/`. For a residual app, the dylib is loaded from its
//!    build path and its recorded `*shared-objects*` namestring is relocated to
//!    `@executable_path/../Frameworks/...` (ADR-0041).
//! 2. **Stub** ([`stub`]) — compile a Swift launcher as `CFBundleExecutable`
//!    that sets `DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks` and
//!    `execv`s the image.
//! 3. **Vendor** ([`vendor`]) — copy the Homebrew `libzstd` the image links (by
//!    leaf name) and the residual `libAPIAnywareSbcl` into `Contents/Frameworks/`,
//!    re-signing each.
//! 4. **Sign** — sign the whole bundle (stub + sealed resources). The dumped
//!    image keeps its own `save-lisp-and-die` ad-hoc signature.
//!
//! # Why a stub, not `install_name_tool` (ADR-0041)
//!
//! The peer bundlers (chez/gerbil, ADR-0009/0029 §3) relocate Homebrew dylibs
//! with `install_name_tool` + `@executable_path`. That is **impossible** on a
//! dumped image: `save-lisp-and-die` appends the Lisp core past `__LINKEDIT`, so
//! the Mach-O is uneditable and `codesign --force` rejects the layout. The two
//! self-containment gaps are closed at runtime instead — the libzstd *load
//! command* via `DYLD_FALLBACK_LIBRARY_PATH` (the stub), the `dlopen`ed residual
//! dylib via its recorded namestring (the dump). Neither edits the image.
//!
//! # Example
//!
//! ```no_run
//! use apianyware_bundle_sbcl::{bundle_app, AppSpec};
//! use std::path::Path;
//!
//! let spec = AppSpec::from_script_name("hello-window");
//! let source_root = Path::new("generation/targets/sbcl");
//! let output_dir = Path::new("generation/targets/sbcl/apps/hello-window/build");
//! let workspace_root = Path::new(".");
//! let app = bundle_app(&spec, source_root, output_dir, workspace_root).unwrap();
//! println!("built: {}", app.display());
//! ```

mod dump;
mod spec;
mod standalone;
mod stub;
mod vendor;

pub use dump::{
    discover_swift_dylib, driver_needs_dylib, ensure_swift_dylib, DYLIB_RECORD_AS, RECORD_AS_ENV,
    SWIFT_DYLIB_NAME,
};
pub use spec::{
    read_display_name_from_spec, resolve_signing_identity, AppSpec, BundleError,
    LOCAL_SIGNING_IDENTITY,
};
pub use standalone::{bundle_app, FRAMEWORKS_SUBDIR};
pub use stub::generate_stub_source;
pub use vendor::{homebrew_deps_of, vendor_dylibs};
