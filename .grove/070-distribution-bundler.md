# 070-distribution-bundler

**Kind:** work

## Goal

Build the `bundle-sbcl` crate (guide Step 8) that packages a sample app as a
self-contained `.app` via `sb-ext:save-lisp-and-die :executable t` (D4): load the
sbcl bindings + app into an image, dump a standalone executable, wrap it with the
shared `stub-launcher` `.app` skeleton + codesigning, `CFBundleName` from the
app spec H1, bundle id `com.linkuistics.<NoSpaceTitle>`. No SBCL needed on the
target machine.

## Context

Peers: `bundle-chez` (self-contained, ADR-0009), `bundle-gerbil` (gxc -exe). The
language-agnostic `apianyware-macos-stub-launcher` provides the `.app` skeleton +
codesigning; this crate does the image dump + dependency staging. **Self-containment
+ the dylib (ADR-0038 §6 / design spec §4):** `save-lisp-and-die :executable t`
embeds the SBCL runtime in the exe; `libAPIAnywareSbcl` is **vendored + relocated**
into `Contents/Frameworks/` via `install_name_tool` (extend `bundle-gerbil`'s
`relocate.rs` path, ADR-0029 §3), after which the bundled exe's `otool -L` shows
only `/usr/lib/*`, system frameworks, and `@executable_path/..`. The Swift runtime
is OS-resident (`/usr/lib/swift/`) — not vendored.

## Done when

- `cargo run --example bundle_app -p apianyware-macos-bundle-sbcl -- <app>`
  produces a runnable, codesigned, self-contained `.app`; used by the 060 apps.

## Notes
