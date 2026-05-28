# Chez target — design spec

**Status:** approved (output of `.grove/050-chez-target/010-design-emit-chez.md`)
**Companion ADRs:** 0004 (paradigm retired), 0005 (chez emits idiomatic Chez),
0006 (NSError shape), 0007 (lifetime model), 0008 (emit-chez standalone).
**Companion brief:** `.grove/050-chez-target/BRIEF.md` (10 inherited decisions).

## 1. Scope

This spec covers the **whole chez target** as a peer of the existing racket
target — emitter crate, runtime libraries, Swift dylib surface, generated
framework set, bundler crate, sample-app portfolio. It does **not** cover the
post-grove rewrite of `docs/adding-a-language-target.md` (that is the
`060-rewrite-adding-language-target.md` peer leaf).

Symmetry between the two targets is on disk (per-class files, `main`
re-export per framework, `runtime/` + `generated/` layout, the same
framework set, the same 7 sample apps) and at the IR-decision level (what
gets emitted) — **not** at the source-form level. Inside each generated
file the code is target-native: `(library …)` forms, `foreign-procedure`,
`define-record-type`, `let-values` for fallible signatures, guardians for
lifetimes.

## 2. Runtime decomposition

Decision recorded in the 010 grilling: a **coarser cluster layout** of
~5 libraries, not a 1:1 mirror of racket's 18 `.rkt` files. The five
clusters and the racket files each cluster absorbs:

| Chez cluster                         | Racket files absorbed                                                                             | Disposition       |
|--------------------------------------|---------------------------------------------------------------------------------------------------|-------------------|
| `runtime/ffi.sls`                    | `swift-helpers.rkt`                                                                                | full rewrite      |
| `runtime/objc.sls`                   | `objc-base.rkt`, `objc-interop.rkt`                                                                | forced rewrite (ADR-0007) |
| `runtime/dispatch.sls`               | `block.rkt`, `delegate.rkt`, `dynamic-class.rkt`                                                   | forced rewrite (ADR-0007, decision 6) |
| `runtime/types.sls`                  | `type-mapping.rkt`, `coerce.rkt`, `cf-bridge.rkt`                                                  | mechanical port   |
| `runtime/cocoa.sls`                  | `app-menu.rkt`, `main-thread.rkt`, `nsview-helpers.rkt`, `nsevent-helpers.rkt`, `cgevent-helpers.rkt`, `ax-helpers.rkt`, `spi-helpers.rkt`, `objc-subclass.rkt` | logic ports, FFI sigs rewrite |

**Deleted from the chez runtime entirely** (no chez analog):
- `variadic-helpers.rkt` — Chez `foreign-procedure` natively supports
  trailing-args via `(... fixed-args ...) variadic-args`; the workaround
  layer racket carries isn't needed.

**`runtime/ffi.sls`** holds the mandatory-dylib load of
`libAPIAnywareChez.dylib` (a hard error if absent — ADR-0005-aligned: the
chez target assumes its environment), the libobjc / libdispatch
`foreign-procedure` declarations, and the curated `objc_*` runtime
bindings (`objc_getClass`, `objc_msgSend`, `objc_allocateClassPair`,
`objc_registerClassPair`, `class_addMethod`, `sel_registerName`,
`class_getInstanceMethod`, `method_getTypeEncoding`,
`objc_autoreleasePoolPush`, `objc_autoreleasePoolPop`,
`objc_retain`, `objc_release`).

**`runtime/objc.sls`** holds the `objc-object` record (single field:
`ptr`), the `objc-guardian` parameter, `wrap-objc-object` /
`borrow-objc-object` / `unwrap-objc-object`, the
`(with-autorelease-pool body …)` macro, the `(drain-objc-guardian)`
procedure, and the `(define-entry-point name (args …) body …)` macro
that wraps each entry-point body in an autoreleasepool + post-pool
guardian-drain.

**`runtime/dispatch.sls`** holds:
- The `block` machinery — a `Block_layout` and `Block_descriptor_1`
  defined via `define-ftype`, a `make-objc-block` procedure that wraps a
  Scheme procedure into a C function pointer via `foreign-callable` and
  populates the ftype-pointer structure pointing at it. The Swift-side
  `aw_chez_create_block` (in `libAPIAnywareChez.dylib`) handles
  `_NSConcreteGlobalBlock`, `BLOCK_HAS_COPY_DISPOSE`, and the
  arm64e PAC-signing details — the chez side only provides the
  `foreign-callable` invoke pointer.
- The `delegate` machinery — `make-delegate` constructs an instance of a
  Swift-defined `APIAnywareChezDelegate` class (mirroring the racket
  flavour), with selector→`foreign-callable` mappings supplied per-call.
- The `dynamic-class` machinery — `make-dynamic-subclass` wraps the
  libobjc surface from `runtime/ffi.sls`, using `foreign-callable` for
  IMPs rather than racket's `function-ptr`.

**`runtime/types.sls`** holds the NSString/NSArray/NSDictionary marshal
helpers, the geometry ftypes (`NSPoint`, `NSSize`, `NSRect`, `NSRange`,
`NSEdgeInsets`, etc.) as `define-ftype` instead of `define-cstruct`, and
the CoreFoundation bridging helpers.

**`runtime/cocoa.sls`** holds the helper procedures that aren't FFI
primitives: `install-standard-app-menu!`, main-thread dispatch
(`dispatch_get_main_queue` + `dispatch_async`), AppKit/AX/SPI helpers
that the sample apps call. Mostly logic, with FFI signatures rewritten
against `foreign-procedure`.

The five clusters import each other in a strict order: `ffi` →
`objc` → `dispatch`, `types`, `cocoa`. The `cocoa` cluster may import
from `dispatch` (delegate-based notifications, for example).

## 3. Emitted-class form

Decision recorded in the 010 grilling: **procedures over a shared
`objc-object` record** — no per-class record subtype. Each generated
class file is a Chez `library` exporting a flat namespace of procedures:

```scheme
(library (apianyware appkit nswindow)
  (export make-nswindow-init-with-content-rect-style-mask-backing-defer
          nswindow-set-title!
          nswindow-title
          nswindow-content-view
          nswindow-center!
          nswindow-make-key-and-order-front
          ;; … all NSWindow-derived selectors
          )
  (import (chezscheme)
          (apianyware runtime ffi)
          (apianyware runtime objc)
          (apianyware runtime types))

  (define sel-initWithContentRect-styleMask-backing-defer
    (sel-register "initWithContentRect:styleMask:backing:defer:"))

  (define-foreign-procedure objc_msgSend-window-init
    "objc_msgSend" libobjc
    (id sel (& nsrect) unsigned-long-int unsigned-long-int boolean) -> id)

  (define (make-nswindow-init-with-content-rect-style-mask-backing-defer rect mask backing defer)
    (let* ([cls (objc-get-class "NSWindow")]
           [alloc-sel (sel-register "alloc")]
           [raw (objc_msgSend-window-init
                  (objc_msgSend-alloc cls alloc-sel)
                  sel-initWithContentRect-styleMask-backing-defer
                  rect mask backing defer)])
      (wrap-objc-object raw #:retained #t)))

  (define (nswindow-set-title! win title)
    (let* ([sel (sel-register "setTitle:")]
           [nsstr (string->nsstring title)])
      (objc_msgSend-id-id (unwrap-objc-object win) sel nsstr))))
```

(That is a sketch, not a normative template — `emit-chez` will produce
this shape but the exact macro vs. raw-procedure mix is finalised in the
emit-chez crate-scaffold leaf.)

Constructors named `make-<class>-<selector-with-dashes>`; instance
methods named `<class>-<selector-with-dashes>`; setters keep the racket
convention of a trailing `!` (`nswindow-set-title!`). Naming reuses
`emit/src/naming.rs::class_name_to_lowercase` and the selector-to-dashes
conversion already used by emit-racket.

## 3a. Struct-by-value returns and the 16-byte indirect-result threshold

Geometry typedefs return by value on the ObjC side. The chez emitter
declares them in the `foreign-procedure` form as `(& <ftype>)` — Chez's
notation for pass-by-reference of an ftype. The non-obvious half is how
the *return* shape works:

- **≤ 16 bytes (NSPoint, NSSize, NSRange, CGVector).** The arm64 / x86_64
  ABIs return the aggregate in two registers (`x0/x1` or `xmm0/xmm1`).
  Chez allocates the result buffer internally and hands a fresh
  ftype-pointer back as the foreign-procedure's value. The wrapper is the
  shape you'd naively write:

  ```scheme
  (define %msg-point (foreign-procedure "objc_msgSend" (void* void*) (& NSPoint)))
  (define (nsevent-location-in-window self)
    (%msg-point (coerce-arg self) %sel-location-in-window))
  ```

- **> 16 bytes (NSRect, NSEdgeInsets, NSDirectionalEdgeInsets,
  NSAffineTransformStruct, CGAffineTransform).** The arm64 ABI uses the
  indirect-result register (`x8`) — the caller pre-allocates storage and
  passes its address as a hidden leading argument. Chez exposes this
  faithfully: per the csug `(& ftype)` return convention, the caller
  *must* supply an extra `(* ftype)` argument before all declared
  parameters, and the foreign-procedure's directly returned value is
  unspecified. The declared `param-types` list stays the same as for the
  small case — the buffer arg is implicit. The wrapper allocates, calls,
  and returns the buffer:

  ```scheme
  (define %msg-nsview-frame-getter
    (foreign-procedure "objc_msgSend" (void* void*) (& NSRect)))
  (define (nsview-frame self)
    (let ([%result-buf (make-ftype-pointer NSRect
                                           (foreign-alloc (ftype-sizeof NSRect)))])
      (%msg-nsview-frame-getter %result-buf (coerce-arg self) %sel-nsview-frame-getter)
      %result-buf))
  ```

Threshold classification is mechanical, encoded once in
`emit-chez/src/ffi_type_mapping.rs::large_struct_return_ftype`. The
emitter uses the same code path for method returns and property getters;
setters take `(& T)` as a regular parameter and need no special handling.

There is no `objc_msgSend_stret` to consider — Apple's arm64 ABI
unified the calling convention and removed the `_stret` variant. The
hidden-buffer arg via Chez's foreign-procedure is the only way to land
large-struct returns correctly.

Lifetime: the buffer is allocated via `foreign-alloc` and leaks per
call. Acceptable for now — geometry returns are typically short-lived
(one rect per layout pass). A future runtime leaf may add a drain hook
or switch to Scheme-allocated storage.

## 4. Emitter file layout — `generation/crates/emit-chez/`

Mirrors `emit-racket/` structurally (per ADR-0008, structural mirroring at
the crate-organisation level, not the source-form level):

```text
generation/crates/emit-chez/
  Cargo.toml                 — depends on emit/, apianyware-macos-types
  src/
    lib.rs                   — module declarations + pub use ChezEmitter
    emit_framework.rs        — top-level orchestrator, impl LanguageEmitter
    emit_class.rs            — per-class library generation
    emit_constants.rs        — constants.sls
    emit_enums.rs            — enums.sls
    emit_functions.rs        — functions.sls
    emit_protocol.rs         — protocols/<proto>.sls
    enrichment_comments.rs   — same as emit-racket
    method_filter.rs         — same as emit-racket
    naming.rs                — chez-specific naming (most utilities lift to emit/)
    shared_signatures.rs     — chez-specific shared signature emit
```

`ChezEmitter` impls `LanguageEmitter` from
`generation/crates/emit/src/binding_style.rs`. `LANG_INFO`:

```rust
pub const CHEZ_LANGUAGE_INFO: LanguageInfo = LanguageInfo {
    id: "chez",
    display_name: "Chez Scheme",
};
```

`emit_framework` writes `<framework>/`:
- one `<class>.sls` per class
- `enums.sls` if any
- `constants.sls` if any
- `functions.sls` if any (skipping inline and variadic, same predicate as
  emit-racket)
- `protocols/<proto>.sls` per delegate protocol
- `main.sls` re-export

The `main.sls` re-export form:

```scheme
(library (apianyware appkit)
  (export …)
  (import (apianyware appkit nsapplication)
          (apianyware appkit nswindow)
          …)
  ;; Chez `library` re-export: `(export (rename …))` not required
  ;; because we re-export by include, but the export list must be
  ;; explicit. emit-chez emits the union of every imported library's
  ;; export list.
  )
```

Naming the library `(apianyware <framework>)` (where `<framework>` is
the lowercase framework name) gives a clean import path from sample
apps:

```scheme
(import (apianyware appkit) (apianyware foundation))
```

## 5. Framework set and emission order

**Same framework set as racket emits today** — no chez-specific exclusions.
Emission order uses the existing `emit/src/framework_ordering.rs`
topological sort. `emit-chez` calls the same sort with the same IR; the
order is target-independent.

## 6. Swift dylib surface — `libAPIAnywareChez.dylib`

`swift/Package.swift` already declares the target:

```swift
.library(name: "APIAnywareChez", type: .dynamic, targets: ["APIAnywareChez"]),
.target(name: "APIAnywareChez", dependencies: ["APIAnywareCommon"]),
```

`APIAnywareCommon` already exports the target-agnostic helpers:
`AutoreleasePool`, `ClassLookup`, `MemoryManagement`, `MessageSend`,
`ObservationBridge`, `StringConversion`, `StructMarshal`. The chez-side
work is **three Swift files** in `swift/Sources/APIAnywareChez/`:

- `BlockBridge.swift` — exports `aw_chez_create_block(invoke: UnsafeRawPointer) -> UnsafeMutableRawPointer`
  and `aw_chez_release_block(block: UnsafeMutableRawPointer)`. The
  Block_layout / Block_descriptor_1 construction mirrors
  `APIAnywareRacket/BlockBridge.swift` but takes a `foreign-callable`
  C function pointer instead of `_cprocedure`.
- `DelegateBridge.swift` — exports `aw_chez_register_delegate(selectors:
  …, return_types: …, count: Int32) -> UnsafeMutableRawPointer`,
  `aw_chez_set_method(delegate: …, selector: …, callable: …)`,
  `aw_chez_free_delegate(delegate: …)`. Delegate class is a Swift class
  with stored per-selector callable pointers.
- `GCPrevention.swift` — if needed. The guardian-based lifetime model
  (ADR-0007) may obviate it; if the Swift side never needs to pin a
  Scheme value against the Scheme GC (because the foreign-callable
  trampoline is statically allocated and the closed-over Scheme proc is
  managed by `lock-object` on the chez side), this file is empty or
  absent. **Decided during the 060 leaf**; the spec marks this as the
  one runtime/Swift decision deferred.

Initial `ChezFFI.swift` stub already exists at
`swift/Sources/APIAnywareChez/ChezFFI.swift`; the 060 leaf flattens it
into the three files above (or keeps it as a fourth coordinator file).

## 7. Sample-app port order and runtime feature ladder

Decision recorded in the 010 grilling. Each app exercises exactly one
new runtime piece relative to its predecessor:

| Order | App                        | New runtime feature exercised                              | LOC (racket) |
|-------|----------------------------|------------------------------------------------------------|--------------|
| 1     | `hello-window`             | baseline — class construction, accessor procedures         | 72           |
| 2     | `ui-controls-gallery`      | sync delegate (NSTextField action handlers, NSButton tgt)  | 358          |
| 3     | `scenekit-viewer`          | single delegate, SceneKit framework reach                  | 219          |
| 4     | `pdfkit-viewer`            | multi-delegate                                             | 248          |
| 5     | `mini-browser`             | async multi-callback delegate (WKNavigationDelegate)       | 302          |
| 6     | `note-editor`              | **block bridge** (completion handler from Scheme proc)     | 521          |
| 7     | `drawing-canvas`           | **dynamic NSView subclass** via `make-dynamic-subclass`    | 356          |

A regression localises to the most-recently-added runtime piece. The
delegate-only trio (apps 2–4) is grouped under a **single work leaf**
since they exercise the same runtime piece at different reach;
the remaining four are each their own leaf.

TestAnyware-driven validation is per-app — see
[[feedback-use-testanyware]]: each app gets the same VM-driven UI
verification bar racket has, and the work-leaf doesn't retire until the
app's TestAnyware run is green.

## 8. Bundle-chez crate surface

Decision recorded in the 010 grilling: **source-launched now, precompile
later**. `bundle-chez` mirrors `bundle-racket` exactly:

```text
generation/crates/bundle-chez/
  Cargo.toml
  src/
    lib.rs
    bundle.rs        — bundle_app(spec, source_root, output_dir) -> .app
    deps.rs          — traverse (import …) forms to find dependencies
    spec.rs          — AppSpec::from_script_name(name)
```

### Source tree and bundle layout — `apianyware/` namespace root

Settled in `.grove/done/050-chez-target/100-port-hello-window/020-chez-library-loading.md`:
Chez's library-name resolution maps `(apianyware <category> <name>)` to
`<libdir>/apianyware/<category>/<name>.sls` with no per-library
configuration available. Rather than installing a
`library-search-handler` to layer a different convention, the chez
target **honours the convention on disk** — the runtime cluster and
every emit-chez output live under one `apianyware/` namespace root.

Source tree (`generation/targets/chez/`):

```text
generation/targets/chez/
  apianyware/
    runtime/*.sls         ← (apianyware runtime <cluster>)  ← tracked
    <fw>.sls              ← (apianyware <fw>) facade        ← gitignored
    <fw>/*.sls            ← (apianyware <fw> <cls>)         ← gitignored
    <fw>/protocols/*.sls  ← (apianyware <fw> protocols <p>) ← gitignored
  apps/<script>/<script>.sls  ← entry scripts (top-level, no library form)
  lib/libAPIAnywareChez.dylib
```

The per-framework facade lives at `apianyware/<fw>.sls` — one level
**above** the framework directory — because Chez's library-name resolver
maps `(apianyware <fw>)` to `<libdir>/apianyware/<fw>.sls` (no
`<dir>/main.sls` convention). The file and the directory of the same
stem coexist on disk; Chez's reader handles that without ceremony.

The gitignore allows `apianyware/runtime/` through and drops every
sibling — the framework libraries regenerate from the enriched IR.
emit-chez writes to `apianyware/<fw>/` because `LanguageInfo` declares
`generated_subdir: "apianyware"`; racket keeps its conventional
`generated/` subdir.

Bundle layout:

```text
<App>.app/
  Contents/
    MacOS/<App>                         ← stub-launcher, execvs into chez
    Info.plist                          ← CFBundleName = "<App>"
    Resources/chez-app/
      apps/<script>/<script>.sls        ← entry script
      apianyware/runtime/*.sls          ← traversed deps
      apianyware/<fw>/*.sls             ← traversed deps
      lib/libAPIAnywareChez.dylib       ← always present (mandatory dylib)
```

`stub-launcher` runs `chez --libdirs <chez-app-root> --script
<entry>` — the libdirs path is computed at runtime via
`Bundle.main.resourcePath! + "/chez-app"` (the stub's
`libdirs_resource_subdir` config — set by bundle-chez to
`"chez-app"`). Unbundled invocations pass `--libdirs
generation/targets/chez` explicitly. Both cases let Chez's default
library-name resolution find every imported library without any
bootstrap code.

**Precompile pass (added 2026-05-28, leaf
`105-precompile-bundled-libraries`).** After staging every `.sls`
under `Resources/chez-app/`, the bundler runs
`chez --script scripts/precompile.ss <chez-app>` which calls
`compile-library` on each *root* library — framework facades
(`apianyware/<fw>.sls`) and runtime libraries
(`apianyware/runtime/<cluster>.sls`) — with
`(compile-imported-libraries #t)` set. Chez writes `.so` files next
to the source via the default `library-extensions`, and the existing
`chez --libdirs <chez-app> --script <entry>` invocation picks them up
without any stub-launcher change. Cold-launch dropped from ~75s to
~1.85s on the dev host; bundle size grew ~2.7× (hello-window: 38 MB
→ 102 MB). See `generation/crates/bundle-chez/README.md` for the
caveats (Chez-version coupling, why the entry script is not
precompiled, how to opt out via `AppSpec::skip_precompile`).

## 9. Knowledge file — `knowledge/targets/chez.md`

First-pass scope, written in the final work leaf:
- Reader's mental model: guardian + entry-point autoreleasepool, why
  both.
- Sample-app authoring rules: every long-running loop outside the run
  loop wraps in `(with-autorelease-pool …)`.
- The `(values result error)` calling convention for fallible
  procedures.
- The chez-only escape hatches (raw `foreign-procedure`, direct
  `objc_msgSend` for non-emitted selectors).
- Comparison surface with racket (when does each target shine).

Same authoring bar as `knowledge/targets/racket.md` (if/when that
exists) — short, opinionated, written-after-the-fact rather than
designed-ahead.

## 10. Open implementation details (settled during work leaves, not here)

- The `nserror` Scheme-record field set — `(domain code
  localised-description userinfo)` is the working set, but unicodeisms
  in `userinfo` may force a per-call surface decision.
- The `define-foreign-procedure` macro layer that emit-chez emits — does
  every method's `objc_msgSend` get its own typed binding, or do we
  share via parametric type fingerprints. Decided in the 080 leaf when
  we see the size of the generated FFI surface.
- Whether `GCPrevention.swift` is empty under the guardian model
  (see §6).
- Whether `runtime/cocoa.sls` is one library or two (helpers vs
  app-menu/main-thread) — settled when its content stabilises during
  the 050 leaf.
