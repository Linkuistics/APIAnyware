use std::path::PathBuf;

fn main() {
    // napi: on macOS this emits `-undefined dynamic_lookup` so the N-API symbols
    // (provided by the host runtime at load time) resolve at link time.
    napi_build::setup();

    // Link the throwaway Swift bridge dylib built by ../swift/build.sh.
    let manifest = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let swift_dir = manifest.parent().unwrap().join("swift");
    println!("cargo:rustc-link-search=native={}", swift_dir.display());
    println!("cargo:rustc-link-lib=dylib=tsrlbridge");
    // The Swift dylib links AppKit/Foundation transitively; nothing else needed —
    // its install_name is absolute, so the loaded .node resolves it at runtime.

    // Compile the v8-aware pump shim (pump_shim.cc). v8/node symbols resolve at load time
    // against libnode via napi_build's `-undefined dynamic_lookup`. Needs node's C++ headers.
    let node_inc = std::process::Command::new("node")
        .args([
            "-e",
            "const p=require('path');console.log(p.join(p.dirname(p.dirname(process.execPath)),'include','node'))",
        ])
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .expect("could not locate node include dir");
    cc::Build::new()
        .cpp(true)
        .std("c++20") // v8's headers require C++20
        .file("pump_shim.cc")
        .include(&node_inc)
        .compile("aw_rl_pump_shim");

    println!("cargo:rerun-if-changed=pump_shim.cc");
    println!("cargo:rerun-if-changed=build.rs");
}
