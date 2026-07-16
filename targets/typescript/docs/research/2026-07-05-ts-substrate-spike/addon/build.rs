use std::path::PathBuf;

fn main() {
    // napi: on macOS this emits `-undefined dynamic_lookup` so the N-API symbols
    // (provided by the host runtime at load time) resolve at link time.
    napi_build::setup();

    // Link the throwaway Swift bridge dylib built by ../swift/build.sh.
    let manifest = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let swift_dir = manifest.parent().unwrap().join("swift");
    println!("cargo:rustc-link-search=native={}", swift_dir.display());
    println!("cargo:rustc-link-lib=dylib=tsbridge");
    // The Swift dylib links AppKit/Foundation transitively; nothing else needed —
    // its install_name is absolute, so the loaded .node resolves it at runtime.
    println!("cargo:rerun-if-changed=build.rs");
}
