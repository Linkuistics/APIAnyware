# 010-data-plane

**Kind:** work

## Goal

Stand up the `gerbil-bindings` runtime package skeleton and the **data plane** of
the `objc`/`types` runtime modules — everything the *non-callback, non-subclass*
generated code needs to compile and run. The two ObjC-native-core bridges
(`make-delegate`, `make-objc-block`) and subclass synthesis are **stubbed** here
(raise "not yet implemented") so the package compiles; 020/030 fill them in.

## Context

Parent brief (`../BRIEF.md`) carries the full binding contracts. Reference:
chez `runtime/objc.sls` (will→guardian differs; wills here per ADR-0019) and
`runtime/types.sls`. Toolchain + `-x objective-c` rule in the parent Context.

The runtime `objc` module is imported by every generated module as
`:gerbil-bindings/runtime/objc`. The package root is
`generation/targets/gerbil/lib/` (`generated_subdir = "lib"`); decide whether the
runtime modules live under that package (`:gerbil-bindings/runtime/objc`) or a
sibling — the emitted code references runtime entries by **bare imported name**, so
any path works as long as the names resolve.

## Done when

- **Package skeleton:** `generation/targets/gerbil/lib/gerbil.pkg`
  (`(package: gerbil-bindings)`) + a `runtime/` source tree + the build config that
  compiles the FFI/runtime unit `-x objective-c` (gxc `-cc-options`/`-ld-options`).
- **`objc` module data plane**, exporting by the exact spellings the parent contract
  fixes:
  - `(defclass NSObject (ptr) transparent: #t)` root + `NSObject?` `NSObject-ptr`
    `make-NSObject` (keyword ctor `(make-NSObject ptr: …)`); the ptr slot carries the
    ADR-0019 Gambit `will` sending `release`.
  - `register-objc-class!` — `(register-objc-class! <class> "<objc>" "<objc-super>")`
    building the ObjC-name→Gerbil-type registry (+ storing the ObjC super name for
    030's bridge).
  - `wrap` — class-aware: `object_getClass` → exact bound type, nearest **bound**
    ancestor fallback; `(wrap p)` = +0 autoreleased (retain), `(wrap p #t)` = +1
    retained (no retain); registers the will. Replaces chez `wrap-objc-object`.
  - `->ptr` — outbound `id` coercion (bound instance → ptr; `#f`/nil → null).
  - `with-autorelease-pool` + `define-entry-point` (entry-point pool macros,
    ADR-0019); the receiver fast-path reads `(NSObject-ptr self)` directly.
- **`types` module:** `string->nsstring` (Gerbil string → +1-retained NSString*
  raw ptr, caller owns — see constants contract), value marshalling, CGRect-style
  struct decomposition (FINDINGS §4), the geometry `c-define-type` typedefs.
- **`nserror` + error model:** `make-nserror nserror? nserror-domain nserror-code
  nserror-localised-description nserror-userinfo` + `call-with-nserror-out` (the
  out-param settler returning `(values result error)`, +1-owning the NSError, will
  registered) — exact contract in parent "leaf 040/020/050" section.
- **Dual-surface imports:** `:std/generic` available; confirm the renamed import
  `(rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))` and
  the built-in `{}` `defmethod` both resolve (spike `07-dual-surface.ss`).
- **Stubs:** `make-delegate`, `make-objc-block`, and the shadowing
  `defclass`/`defmethod` subclass forms exist but raise "not yet implemented" so a
  full generated framework still compiles.
- **First-compile open items resolved (or inbox-noted to 020/030 with findings):**
  geometry struct tags compile (adjust `geometry_decl` in `emit_class.rs` if not),
  the `(declare (inline))` pragma is honoured by gsc (else adjust
  `emit_surface_decls`), and a decision on cross-module generic unification (shared
  generics module here vs. punt to leaf 060 CLI pre-pass — record it).
- **Smoke:** a hand-written class module (mimicking emitted shape) round-trips
  `NSString`/`NSMutableArray` through `wrap`/`->ptr`/`with-autorelease-pool`/will
  and exercises one `call-with-nserror-out` path — compiles + runs via gxc.

## Notes

Stub design: keep the stub signatures matching the real contracts (the 4-tuple
`make-delegate`, the block ctor) so 020 only swaps bodies. The will + class-aware
wrap is the load-bearing, hardest-to-get-right data-plane piece — get its smoke
green before moving on.
