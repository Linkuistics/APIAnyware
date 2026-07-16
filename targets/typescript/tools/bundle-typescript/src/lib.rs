//! Bundle Node TypeScript sample apps into self-contained macOS `.app`
//! bundles (ADR-0060; Step 8 of `adding-a-language-target.md`).
//!
//! A Node TypeScript `.app`'s `CFBundleExecutable` is a **per-app native
//! launcher that owns `main()` and embeds Node** — the Electron /
//! NativeScript-for-macOS shape (ADR-0056 forces this: the native side must
//! own `main()` with no ambient blocking JS→native call while pumping libuv,
//! which rules out the four Lisp targets' stub-`execv`-a-shared-runtime
//! model). The pipeline, per app:
//!
//! 1. **Compile** ([`launcher`]) — discover the build-time Node embedder
//!    toolchain, generate the launcher's ObjC++ source with this app's
//!    identity baked in, and link it against the shared `pump.swift`/
//!    `pump_shim.cc` embedder core every sample app's own dev launcher already
//!    proves (`embed-pump-harness-k42`).
//! 2. **Assemble** ([`standalone`]) — lay out the `.app`: the launcher at
//!    `Contents/MacOS/<script>`, the app's already-`tsc`-compiled `build/js/`
//!    tree + `loader.mjs` + a generated `bootstrap.cjs` under
//!    `Contents/Resources/app/`, and the already-built native addon at
//!    `Contents/Frameworks/APIAnywareTypeScript.node`.
//! 3. **Relocate** ([`relocate`]) — vendor every Homebrew dylib the launcher
//!    transitively links (`libnode` + its own Homebrew closure) into
//!    `Contents/Frameworks/` and rewrite every load command to
//!    `@executable_path/../Frameworks/<name>` via `install_name_tool` (the
//!    native addon needs no relocation: its N-API symbols dlopen-resolve
//!    against the host process, and its only other deps are system
//!    frameworks + OS-resident Swift dylibs).
//! 4. **Codesign** each vendored dylib/addon, then the whole bundle.
//!
//! # Example
//!
//! ```no_run
//! use apianyware_bundle_typescript::{bundle_app, AppSpec};
//! use std::path::Path;
//!
//! let spec = AppSpec::from_script_name("hello-window");
//! let app_dir = Path::new("targets/typescript/app-implementations/macos/hello-window");
//! let native_dir = Path::new("targets/typescript/bindings/node/native");
//! let output_dir = app_dir.join("build");
//! let app_path = bundle_app(&spec, app_dir, native_dir, &output_dir).unwrap();
//! println!("built: {}", app_path.display());
//! ```
//!
//! Bundle layout (ADR-0060 §4):
//!
//! ```text
//! <App>.app/Contents/
//!   MacOS/<script>                     <- per-app native launcher (CFBundleExecutable)
//!   Frameworks/
//!     libnode.<ver>.dylib              <- vendored + relocated
//!     libuv.<ver>.dylib                <- vendored + relocated
//!     …                                <- libnode's own Homebrew closure, vendored + relocated
//!     APIAnywareTypeScript.node        <- vendored native addon (no relocation needed)
//!   Resources/app/
//!     loader.mjs                       <- copied verbatim (self-relative resolution)
//!     bootstrap.cjs                    <- generated (Frameworks-relative addon require())
//!     build/js/…                       <- copied verbatim from the app's own tsc output
//!   Info.plist
//! ```

mod bundle;
mod launcher;
mod relocate;
mod spec;
mod standalone;

pub use bundle::{resolve_signing_identity, AppSpec, BundleError, LOCAL_SIGNING_IDENTITY};
pub use launcher::{compile_launcher, discover_node_toolchain, generate_launcher_source, NodeToolchain};
pub use relocate::{homebrew_deps_of, relocated_install_name, vendor_and_relocate_homebrew_deps};
pub use spec::read_display_name_from_spec;
pub use standalone::bundle_app;
