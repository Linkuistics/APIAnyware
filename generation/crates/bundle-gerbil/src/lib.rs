//! Bundle gerbil sample apps into self-contained macOS `.app` bundles.
//!
//! A gerbil `.app` is built by **driving the bottle (Homebrew) gerbil
//! toolchain** end-to-end and then packaging the resulting native binary
//! (ADR-0009; design spec `generation/targets/gerbil/docs/design/2026-06-03-gerbil-target-design.md` §7,
//! corrected at grove leaf 070/020). The pipeline, per app:
//!
//! 1. **Walk the import closure** ([`deps`]) — parse the app's `.ss`
//!    `(import …)` form, follow every `:gerbil-bindings/…` reference
//!    transitively (each generated class module imports its superclass
//!    module + `runtime/objc` + `generics`), and topologically order the
//!    result so dependencies compile before dependents.
//! 2. **Compile** ([`compile`]) — clang-compile the one block-literal
//!    companion (`native_block.c`, `-fblocks`), `gxc -O` the closure into a
//!    persistent `GERBIL_PATH` cache (imports are *not* recursively compiled
//!    by `gxc -exe`), then `gxc -exe -O` to link the app exe with
//!    `-lobjc`, the touched `-framework`s, and `native_block.o`.
//! 3. **Assemble + relocate** ([`standalone`], [`relocate`]) — lay out the
//!    `.app`, write `Info.plist`, then vendor every `/opt/homebrew/*` dylib
//!    the exe transitively links (the Gerbil stdlib's `openssl@3`:
//!    `libssl`/`libcrypto`) into `Contents/Frameworks/` and rewrite every
//!    Homebrew load command to `@executable_path/../Frameworks/<name>` via
//!    `install_name_tool`, so `otool -L` shows no Homebrew dependency. When the
//!    app links the Swift-native trampoline dylib `libAPIAnywareGerbil.dylib`
//!    (ADR-0029 — its closure pulled a Swift-native binding), that dylib is
//!    vendored + relocated by the *same* path ([`relocate::relocate_swift_dylib`]),
//!    a no-op for an app with no Swift-native residual.
//! 4. **Codesign** the relocated dylibs then the whole bundle.
//!
//! # Example
//!
//! ```no_run
//! use apianyware_macos_bundle_gerbil::{bundle_app, AppSpec};
//! use std::path::Path;
//!
//! let spec = AppSpec::from_script_name("hello-window");
//! let source_root = Path::new("generation/targets/gerbil");
//! let output_dir = Path::new("generation/targets/gerbil/apps/hello-window/build");
//! let app_path = bundle_app(&spec, source_root, output_dir).unwrap();
//! println!("built: {}", app_path.display());
//! ```
//!
//! Bundle layout:
//!
//! ```text
//! <App>.app/
//!   Contents/
//!     MacOS/<App>                  <- the gxc -exe binary (embeds the Gambit runtime)
//!     Info.plist                   <- CFBundleName = "<App>", com.linkuistics.* id
//!     Frameworks/
//!       libssl.3.dylib             <- vendored + relocated to @executable_path
//!       libcrypto.3.dylib
//! ```
//!
//! ## Difference from bundle-chez
//!
//! Gerbil is **simpler** than chez: there is no boot image, no kernel embed,
//! and no duplicate-import collision probe. `gxc -exe` already links
//! `libgambit.a` statically, so the binary embeds the whole Gerbil/Gambit
//! runtime — the *only* self-containment gap is the openssl@3 dylib
//! relocation. The chez bundler's whole-program-compile / `make-boot-file` /
//! `cc`-link machinery has no analogue here.
//!
//! ## Difference from bundle-racket
//!
//! racket ships a Swift stub that `execv`s the system `racket`; gerbil (like
//! chez) *is* its own executable. The dylib-relocation idea is shared with
//! bundle-racket's `normalize_dylib_install_names`, but gerbil must also
//! rewrite the **exe's** and the **inter-dylib** load commands (`-change`),
//! not just each dylib's own `-id`.

mod bundle;
mod compile;
mod deps;
mod relocate;
mod spec;
mod standalone;

pub use bundle::{resolve_signing_identity, AppSpec, BundleError, LOCAL_SIGNING_IDENTITY};
pub use compile::{discover_gerbil_bin_dir, DEFAULT_GERBIL_BIN_ENV};
pub use deps::collect_closure;
pub use relocate::{
    homebrew_deps_of, relocate_swift_dylib, relocated_install_name, swift_dylib_load_command,
    SWIFT_DYLIB_NAME,
};
pub use spec::read_display_name_from_spec;
pub use standalone::bundle_app;
