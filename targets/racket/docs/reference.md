# racket — Target Reference

Self-contained reference for the `racket` generation target: the emitter, its
runtime library, the FFI/contract design, verification harnesses, and the macOS
framework gotchas discovered while building it. The target is past build-out —
emitter, 18-file runtime, C-API emission, snapshot + runtime-load harnesses,
7 sample apps, and a developer guide are all complete.

## 0. Toolchain (Racket 9.2 + ffi2)

The target is pinned to **Racket 9.2**, reached at `/opt/homebrew/bin/racket`
(the path baked into `bundle-racket`'s `DEFAULT_RACKET_PATH`, used by sample-app
bundles, the runtime-load harness, and these docs). On the dev host that path is
a symlink into a full `/Applications/Racket v9.2/` distribution; 9.2 is a
pre-release/snapshot build (the public mirror tops out at 9.1), so it is **not
downloadable** — provision a fresh machine by copying the host distribution, not
by running an installer (see the VM-verify recipe in §8). **ffi2** is provisioned
with a single `raco pkg install ffi2-lib` (source: the official
`github.com/racket/racket` monorepo, `pkgs/ffi2-lib`); ffi2 is **not** in the
base distribution, so a fresh 9.2 machine must run that one command after install
(it fetches from GitHub). `(require ffi2)` then resolves.

ffi2 and `ffi/unsafe`/`ffi/unsafe/objc` **coexist** in one installation. As of
the 2026-06 migration (grove `update-racket-to-9.2-and-use-ffi2`) the emitter and
runtime are **on ffi2 by default**: generated C-function dispatch goes through
the typed native dispatch table (ADR-0013, `runtime/ffi2-dispatch.rkt`) with
values crossing the seam via `id->ffi2-ptr`/`ffi2-ptr->id`; `ffi/unsafe`/
`ffi/unsafe/objc` is retained only where ffi2 has no equivalent (ObjC message
dispatch boundary). See `CONTEXT.md` "ffi2" and
`targets/racket/docs/research/2026-05-31-racket-9.2-ffi2-migration.md`.

- **Three-way `->` conflict (new, 2026-05-31).** `ffi2` *also* exports `->`
  (its arrow type). A module that requires both `ffi2` and `ffi/unsafe` fails
  with `identifier already required: -> … also provided by ffi2` — the same
  class of clash §2.1 already documents between `ffi/unsafe` and
  `racket/contract`. Any 040 emit site mixing the two FFIs must `rename-in` one
  of the arrows (e.g. keep `ffi2`'s `->` bare and rename `ffi/unsafe`'s, or vice
  versa) on top of the existing `racket/contract` `->` → `c->` rename.

## 1. Overview

"OO" is a target *name* only. Every file under `generation/targets/racket/`
is `#lang racket/base` with **zero** use of the Racket class system — no
`class*`, `define/public`, `inherit`, `interface`, or `mixin` forms anywhere.
The generated API is flat and procedural.

- **ObjC inheritance is flattened at emit time.** `effective_methods()` merges
  the full superclass method set into each class file. Inheritance is a
  collection-time concern; nothing about it survives into the runtime.
- **Protocols emit delegate factories, not interfaces.** A protocol file
  generates `make-<proto>` — a thin wrapper over `make-delegate` that pre-fills
  the handler hash and the `#:param-types` hash from protocol IR. No OO forms.
- **`make-dynamic-subclass` is the only genuine OO mechanism.** All ObjC
  subclassing routes through `runtime/dynamic-class.rkt`. Everything else is
  flat message-passing. The friction in this target is FFI-shaped, not
  OO-shaped.

**IR schema deltas from the base IR.** The `racket` emitter consumes an IR
that differs from the base schema in three fields:
- `Enum.enum_type` is a `TypeRef` (not `String`).
- `EnumValue.value` is `i64` (not `String`).
- `Method` carries `source` / `provenance` / `doc_refs` fields.

## 2. Emitter architecture

### 2.1 File layout & require blocks

Generated tree under the target root:
- Class files: `generated/oo/<fw>/<class>.rkt`
- Protocol files: `generated/oo/<fw>/protocols/<proto>.rkt`
- Apps: `apps/<name>/<name>.rkt`

Relative paths to `runtime/` and `generated/oo/` depend on file depth:
- Class files → `../../../runtime/`
- Protocol files → `../../../../runtime/` (the `protocols/` subdir adds a level)
- Apps → `../../runtime/` and `../../generated/oo/`

After any layout refactor, all three categories must be re-validated. Apps
carry stale path prefixes indefinitely — the emitter never rewrites app files.

**The `->` name conflict.** Requiring both `ffi/unsafe` and `racket/contract`
causes a hard `->` identifier conflict (FFI arrow vs. contract arrow). The
mandatory form renames the contract arrow:

```racket
(require ffi/unsafe
         (rename-in racket/contract [-> c->]))
```

Contract arrows then become `(c-> arg-contract ... ret-contract)`. This applies
to `functions.rkt`, `constants.rkt`, every class wrapper, and any file needing
`racket/contract`. Protocol files use `->*` and technically dodge the conflict,
but `rename-in` is applied prophylactically anyway.

**Framework dylib loading.** `constants.rkt` and `functions.rkt` load the
framework dylib as `_fw-lib` (excluded from `provide`) and bind via
`get-ffi-obj`:
- Constants: `(define Name (get-ffi-obj 'Name _fw-lib _type))`
- Functions: `(define Name (get-ffi-obj 'Name _fw-lib (_fun arg-types... -> ret-type)))`

Both files **unconditionally** require `ffi/unsafe`, `ffi/unsafe/objc`, and the
renamed `racket/contract`, regardless of whether any binding uses `_id`.
Unconditional is cheaper than per-binding Id-detection drift, and forgetting
`ffi/unsafe/objc` is invisible until a file with an `_id`-typed binding loads.
`type-mapping.rkt` is a *conditional* require for `functions.rkt` only — emitted
when `any_struct_type` (in `shared_signatures.rs`) returns true. `constants.rkt`
never requires `type-mapping.rkt`: struct-typed globals use `ffi-obj-ref`, which
needs no cstruct type.

### 2.2 What gets emitted / filtered

- **Variadic and inline functions are skipped** — neither can be bound via
  `get-ffi-obj`. TestKit deliberately includes both kinds to verify exclusion.
- **Swift-style selectors containing `(`** (e.g. `init(string:)`) are filtered —
  they cannot be dispatched via `objc_msgSend`.
- **Function vs. class framework subsets differ.** The set of frameworks with
  emittable C functions (non-variadic, non-inline) is a strict subset of the
  class-emission set, which covers all frameworks. WebKit has classes but no C
  functions — a recurring source of confusion when cross-referencing log lines.
- **`FunctionPointer` / `Block` param auto-warning.** `generate_functions_file()`
  emits a 3-line `; WARNING:` comment before any `define` whose params include a
  `FunctionPointer` or `Block` type, citing `_cprocedure`, SIGILL risk, and the
  `#:async-apply`/deadlock tradeoff (see §7.4).

### 2.3 Class & property emission

- **Contract-export plumbing.** `build_export_contracts` in `emit_class.rs`
  pre-computes `(name, contract)` pairs for constructors, properties, instance
  methods, and class methods, then emits a single `provide/contract` form. Any
  new exported binding must be added to `build_export_contracts` or it won't be
  provided.
- **Class/instance selector disambiguation.** `emit_class.rs` builds
  `instance_bindings` = instance method names ∪ instance property getter names,
  then `class_method_disambig` flags class methods whose selector collides with
  an instance binding. `make_class_method_name(..., true)` appends a `-class`
  suffix. Example: NSEvent's `+modifierFlags` / `-modifierFlags` split into
  `nsevent-modifier-flags-class` and `nsevent-modifier-flags`.
- **Collision sets partition by class vs. instance.** `PropertyNameSets` in
  `emit_class.rs` keeps `class_property_names` and `instance_property_names`
  separate. A flat merged set produces cross-level false positives — e.g. an
  instance bool-property getter name suppressing a same-named class factory
  method. Class methods collide only with class property names; an instance
  property whose getter name matches a class method name is suppressed (the
  class method wins).
- **Class-property methods omit `self`.** Class-property getters/setters take no
  `self` parameter. `build_export_contracts` drops `self` when
  `prop.class_property` is set; `emit_property`'s setter branches substitute
  `class_name` for `(coerce-arg self)` as the message target. TestKit has no
  class-method properties, so this arity divergence is caught only by a
  real-framework canary (`nsmenuitem.rkt` is in `LIBRARY_LOAD_CHECKS`).
- **Default constructor synthesis (mechanism).** For any class whose IR carries
  no explicit init beyond bare `init`, the emitter synthesizes
  `(define (make-<class>) (wrap-objc-object (tell (tell <Class> alloc) init) #:retained #t))`.
  The trigger is `has_explicit_constructor` in `emit_class.rs`, which mirrors the
  long-standing emit-time skip of `m.selector == "init"`. When at least one
  explicit init exists the synthesis is suppressed (e.g. NSWindow keeps only
  `make-nswindow-init-with-content-rect-...`). Even a class with no methods or
  properties gets the synthesized constructor — `[[Class alloc] init]` is always
  callable. This removed the need for the `objc-interop.rkt` escape hatch for
  init-less classes such as NSAlert, NSColorPanel, NSStackView, NSSavePanel,
  NSOpenPanel, NSFileManager.
- **`tell #:type` must match the IR return type.** A bare `tell` defaults to
  `#:type _id`, so against a void method it reads return-register garbage as a
  tagged pointer. `(void (tell ...))` only satisfies the Racket-side contract —
  it does not fix the type mismatch. Correct void emission is
  `(tell #:type _void target args)`. The same applies to property setters with
  `Id`-shaped value types (still `_void`-returning). The two emit sites needing
  an explicit `#:type` are the `_id`-typed property setter (`emit_property`) and
  the Tell-dispatch void-method body (`emit_method`, `ret_is_void` branch).
  TypedMsgSend dispatch handles this via `mapper.map_type`. Test pattern: assert
  `tell #:type _void` present AND `(void (tell` absent.
- **`make-nsrect` forms.** The 4-scalar convenience constructor `make-nsrect`
  `(x y w h)` is the form apps use. The low-level `make-NSRect` struct
  constructor takes an `NSPoint` and an `NSSize`. The same split applies to
  `make-nssize`/`make-NSSize` and `make-nspoint`/`make-NSPoint`.

### 2.4 Protocol emission

Protocol files generate delegate factories. Each file exports exactly two
bindings:
- `make-<proto>` — contract `(->* () () #:rest (listof (or/c string? procedure?)) any/c)`
- `<proto>-selectors` — contract `(listof string?)`

`make-<proto>` is a thin wrapper over `make-delegate` that pre-fills the handler
hash, the `#:return-types` hash, and the `#:param-types` hash from protocol IR.
The `#:param-types` entries are generated by `param_type_symbol` in
`emit_protocol.rs` from IR param types; the same path generates `'int`/`'long`
return-kind entries. No per-method contracts exist — delegate handlers are
user-supplied lambdas, not emitted bindings. The contract strings live in
`MAKE_DELEGATE_CONTRACT` and `SELECTOR_LIST_CONTRACT` in `emit_protocol.rs`.

## 3. Contract design

Every FFI boundary uses `provide/contract`. There are **three contract mappers**:

- **`map_contract`** in `emit_functions.rs` (value/function boundaries):
  primitives → `real?` / `exact-integer?` / `exact-nonnegative-integer?` /
  `boolean?`; objects → `cpointer?`, or `(or/c cpointer? #f)` for nullable;
  CString return → `(or/c string? #f)` (`_string` converts NULL → `#f`); CString
  param → `string?`; geometry structs → `any/c`; void → `void?`. (Note:
  `exact-nonneg-integer?` is *not* a Racket predicate — a typo there fails only
  at load time.)
- **`map_param_contract`** in `emit_class.rs` (class-wrapper params):
  `Id`/`Class`/`Instancetype` → `(or/c string? objc-object? #f)` for all object
  params — *always* includes `#f` (ObjC nil messaging is always a no-op);
  `cpointer?` is excluded. SEL → `string?`. Block → `(or/c procedure? #f)`.
  Primitives delegate to `map_contract`.
- **`map_return_contract`** in `emit_class.rs` (class-wrapper returns): a
  `<class>?` predicate for `TypeRefKind::Class { name }`, made nullable as
  `(or/c <class>? objc-nil?)`; `any/c` for `Id`/`Instancetype`; void/primitives
  delegate to `map_contract`.

**Class-wrapper contracts.** `self` uses the **class-specific predicate**
(e.g. `nsview?`) for instance methods and instance property getters/setters —
this rejects "wrong class" misuse with precise caller blame. The predicate name
is produced by `make_class_predicate_name` in `emit_class.rs` (lowercases the
class name and appends `?`), and the predicate definition is always emitted
before the `provide/contract` block. `objc-object?` is in scope because
`coerce.rkt` re-exports `runtime/objc-base.rkt`. SEL params are `string?` at
the boundary; the wrapper calls `sel_registerName` internally.

**Per-file inline class predicates.** Each class file defines its own return
predicate, e.g. `(define (nsview? v) (objc-instance-of? v "NSView"))`. There are
no cross-class requires and no central barrel — those would create circular
dependency risk and are disproportionate for this narrow scope. `objc-instance-of?`
(a primitive in `runtime/objc-base.rkt`) backs every predicate via
`class_isKindOfClass:` from libobjc, so subclass instances satisfy a parent
predicate. Predicates affect only `map_return_contract` return positions — all
params flow through `coerce-arg` regardless.

**Nullable typed returns.** `map_return_contract` emits `(or/c <pred>? objc-nil?)`
for every `TypeRefKind::Class { name }` return; `objc-nil?` lives in
`runtime/objc-base.rkt`. This is necessary because legitimately-nil Cocoa
properties — `PDFView.document` before assignment, `NSTableView.dataSource`
before wiring, `NSWindow.firstResponder` under timing races — would otherwise
fail their own contracts.

**`provide/contract` rest-arg limitation.** `provide/contract` cannot express
positional alternation inside `#:rest`. `(listof (or/c string? procedure?))`
catches type errors but cannot enforce the string/procedure *pairing* that
`make-<proto>` requires. Stronger enforcement would need a dependent contract
combinator.

## 4. FFI type-coercion rules

- **`coerce-arg`** must cast an `objc-object-ptr` to `_id` via
  `(cast ptr _pointer _id)` for `tell` macro compatibility, and it also accepts
  Racket strings (auto-converting to NSString), raw cpointers, and `#f`.
  TypedMsgSend methods (`_msg-N` bindings) expect *raw* pointers for id-typed
  params, not wrapped `objc-object` structs.
- **Collection-time type resolution.** Typedef aliases resolve to canonical
  types at collection time: object-pointer typedefs → `Id`/`Class`; primitive
  typedefs → `Primitive` (including `Boolean` → `bool`); record typedefs →
  `TypeRefKind::Struct`. Category property deduplication by name is required (a
  HashSet filter in `extract_declarations.rs`). Without canonical resolution the
  FFI mapper defaults unknown aliases to `_uint64`.
- **Unsigned-enum canonicalization.** `is_unsigned_int_kind` in
  `extract_declarations.rs` must canonicalize via `get_canonical_type()` before
  checking the underlying enum type — otherwise `NS_ENUM(NSUInteger, ...)`
  presents as `Typedef` kind and misses the unsigned branch. Clang's
  `get_enum_constant_value()` returns `(i64, u64)`; use `.1` (unsigned) for
  unsigned-backed enums. Values exceeding `i64::MAX` are skipped with a
  `tracing::warn!` (the IR schema is i64; silent wrapping would corrupt value
  semantics). Requires a re-collect to propagate.
- **Record typedefs → `TypeRefKind::Struct`.** `map_typedef` in `extract-objc`
  emits `TypeRefKind::Struct { name }` (not `Alias`) for `TypeKind::Record`
  typedefs. This lets `is_struct_data_symbol` in the constants emitter recognize
  CF struct globals and geometry zero-constants. Requires a re-collect.
- **`const char *` → `TypeRefKind::CString`.** `is_c_string_pointee()` in
  `extract-objc` accepts `CharS | CharU` pointees only and requires
  `is_const_qualified()` on the *pointee* (not the pointer). Non-const `char *`
  (output buffers) maps to `Pointer`. The IR carries `TypeRefKind::CString`; the
  FFI mapper emits `_string`. Requires a re-collect.
- **`type-mapping.rkt` cstruct provide list.** Every `define-cstruct` in
  `runtime/type-mapping.rkt` must appear in its `(provide ...)` list. Current
  exports: `_NSPoint`, `_NSSize`, `_NSRect`, `_NSRange`, `_CGPoint`, `_CGSize`,
  `_CGRect`, `_NSEdgeInsets`, `_NSDirectionalEdgeInsets`,
  `_NSAffineTransformStruct`, `_CGAffineTransform`, `_CGVector`. Adding a
  geometry struct is a four-step operation: (1) `define-cstruct`; (2) add to
  the `provide` list; (3) add the name to `is_known_geometry_struct` in
  `generation/crates/emit/src/ffi_type_mapping.rs` (used by `map_type` for FFI
  type emission); (4) add the name to the **second** copy of
  `is_known_geometry_struct` in
  `generation/crates/emit-racket/src/emit_functions.rs` (used by
  `map_contract` for function contract strings). Both copies must be kept in
  sync. Struct detection flows through `any_struct_type(type_refs, mapper)` in
  `shared_signatures.rs`, used by class wrappers, `emit_functions.rs`, and
  `emit_constants.rs`. (libclang classifies `NSRect`, `CGRect`, etc. as
  *typedefs* / aliases rather than structs, which is why the allowlist exists.)
- **Struct-typed global constants.** Constants whose IR type is
  `TypeRefKind::Struct` (e.g. `_dispatch_main_q`, `_dispatch_source_type_*`,
  geometry zero-constants like `NSZeroPoint` / `NSEdgeInsetsZero`) are emitted as
  `(define sym (ffi-obj-ref 'sym lib))` — returning the symbol's *address*.
  Non-struct constants keep `(get-ffi-obj 'sym lib type)` — *dereferencing* the
  symbol. The split is decided by `is_struct_data_symbol()` in
  `generate_constants_file`. The contract for struct globals is `cpointer?`.
  Known gap: CF struct globals `kCFTypeDictionaryKeyCallBacks` and
  `kCFTypeDictionaryValueCallBacks` are absent from collected IR and so are not
  emitted; the workaround is a direct
  `(get-ffi-obj 'kCFTypeDictionaryKeyCallBacks (ffi-lib "CoreFoundation") _pointer)`.
- **Generic-type-param heuristic.** `is_generic_type_param` (in
  `emit/src/ffi_type_mapping.rs`) identifies an ObjC generic type parameter as a
  single uppercase letter followed by lowercase chars (e.g. `ObjectType`,
  `KeyType`). Framework-prefixed aliases have 2+ uppercase chars (e.g.
  `AXValueType`) and are *not* generic params. This prevents mapping
  framework-defined aliases as `_uint64`, and replaces a maintained allowlist of
  15+ framework prefixes that used to live in `map_contract`.
- **libdispatch `id` → `_pointer`.** `dispatch_queue_t`, `dispatch_group_t`,
  etc. resolve to `id` in the IR (under `OS_OBJECT_USE_OBJC=1`), but no wrapper
  classes exist for them. The emitter maps `_id` → `_pointer` in libdispatch's
  `functions.rkt` so consumers can pass raw cpointers without a
  `(cast ... _pointer _id)` ceremony — the ABI is identical. This override is
  scoped to `framework == "libdispatch"` in `generate_functions_file`; future
  OS-object frameworks (`xpc_object_t`, etc.) would extend the same override.
- **CFSTR constants.** `CFSTR(...)` macro constants are not linked to any dylib.
  `ir.rs` carries `macro_value: Option<String>` on `Constant`; the ObjC
  extractor tokenises source ranges to match `CFSTR("literal")` patterns. The
  emitter outputs a module-level `_make-cfstr` preamble (loading
  `CFStringCreateWithCString` from CoreFoundation) and one
  `(define kFoo (_make-cfstr "literal"))` per constant. The `CFStringRef`
  lifetime is pinned to the module (no ARC); the contract is `(or/c cpointer? #f)`.
- **Property dedup by getter name.** ObjC/Swift dual-extracted properties can
  differ only in casing (e.g. `CGDirectDisplayID` vs. `cgDirectDisplayID`) yet
  kebab-case to the same Racket identifier. `effective_properties` must
  deduplicate by *generated Racket getter name*; deduplicating by IR name leaves
  duplicate `define` forms in emitted class files.

## 5. Non-linkable & unavailable symbol filtering

Non-linkable symbols (preprocessor macros, internal-linkage decls, Swift-native
identifiers) otherwise leak into the IR as `get-ffi-obj` calls that fail at
`dlsym` time. **Filter routing differs by extractor:** extract-swift filters
route through `non_c_linkable_skip_reason` in
`collection/crates/extract-swift/src/declaration_mapping.rs`; extract-objc
filters (internal-linkage, `is_unavailable_on_macos`, `is_definition()` guards)
are direct inline checks in
`collection/crates/extract-objc/src/extract_declarations.rs`. **The six closed
filters** (each validated by the runtime load harness):

1. **extract-objc internal-linkage filter** — skips C decls with internal
   linkage (e.g. `NSHashTableCopyIn`).
2. **extract-swift `s:` USR filter** — skips Swift-native identifiers whose USR
   begins with `s:` (e.g. `NSLocalizedString`, `NSNotFound`).
3. **extract-swift `c:@macro@` USR filter** — skips C-preprocessor macros
   surfaced via the Swift digester (e.g. `kCTVersionNumber10_10`).
4. **Stale-checkpoint ghost symbols** — symbols in `swift.skipped_symbols`
   (e.g. `NEFilterFlowBytesMax`, `CoreSpotlightAPIVersion`) reappearing in
   downstream IR. Root cause is a stale downstream checkpoint, not a code bug;
   pipeline regeneration removes them.
5. **extract-objc `is_unavailable_on_macos()` filter** — skips bare
   `c:@<name>` preprocessor macros (e.g.
   `kAudioServicesDetailIntendedSpatialExperience`, AudioToolbox).
6. **extract-swift `c:@Ea@` / `c:@EA@` USR filter** — skips anonymous enum
   members in `declaration_mapping.rs` (e.g. `nw_browse_result_change_identical`,
   Network).

Adding a new filter: (a) for Swift-side symbols, add a skip-reason branch in
`non_c_linkable_skip_reason` in `declaration_mapping.rs`; for ObjC-side symbols,
add a direct inline check in `extract_declarations.rs`; (b) add a canary
framework to harness coverage — harness extensions are a *discovery mechanism*
that surfaces new leak classes.

**Four-level platform-availability filtering.** The platform-availability filter
operates at classes, protocols, methods, *and* properties. Both extractors
record every filter decision in `skipped_symbols` with a tagged reason:
`internal_linkage`, `platform_unavailable_macos`, `swift_native`,
`preprocessor_macro`, `anonymous_enum_member`. Grep `skipped_symbols` in
collected IR to debug a missing-symbol issue.

**`is_definition()` guards.** In `extract_declarations.rs`, the `EnumDecl`,
`StructDecl`, and `ObjCProtocolDecl` arms carry `entity.is_definition()` guards
to skip forward declarations that would shadow populated definitions in the
`seen_*` HashSets. `ObjCInterfaceDecl` intentionally has **no** guard: in
Clang's AST an `@interface` is a *declaration* (the *definition* is
`@implementation`, absent from SDK headers), so `is_definition()` returns `false`
for every `ObjCInterfaceDecl` cursor in framework headers. Forward `@class`
declarations produce `ObjCClassRef` cursors, not `ObjCInterfaceDecl`, so no
forward-decl shadowing is possible for this entity kind.

**Header-declared ≠ dylib-exported.** Some symbols present in SDK headers do not
exist in the live dylib shared cache. Snapshot tests cannot detect this — only
the runtime load harness can. Always run the harness before declaring new
framework coverage complete.

**Emit-time dylib-unexported filter.** Header-declared symbols absent from the
live dylib are filtered at *emit time*, not collection time — collection-time
filtering would require a Rust `dlopen`/`dlsym` probe per symbol. The emit-time
filter `is_libdispatch_unexported` in `emit_functions.rs` is a single grep-able
location for "what did we omit and why". Libdispatch known-missing:
`dispatch_cancel`, `dispatch_notify`, `dispatch_testcancel`, `dispatch_wait`,
`pthread_jit_write_with_callback_np`.

## 6. Synthetic pseudo-frameworks & subframeworks

**Synthetic pseudo-framework structure.** For system headers outside the
`.framework` tree (libdispatch, pthread, …): a checked-in umbrella header lives
at `collection/crates/extract-objc/synthetic-frameworks/<name>/<name>.h`;
`sdk.rs` appends a synthetic `FrameworkInfo` via `synthetic_frameworks()`;
`is_from_framework` in `collection/crates/extract-objc/src/extract_declarations.rs`
branches on the synthetic name to accept the relevant `usr/include/` paths.
Emitter hookup: `framework_ffi_lib_arg` in `shared_signatures.rs` maps the
synthetic framework name to the actual dylib short name. No other emitter
changes are needed.

**libdispatch `ffi-lib` = `"libSystem"`.** The `libdispatch` short name does not
resolve via dyld's shared cache on macOS even though the symbols exist —
dispatch symbols are re-exported from `libSystem`. `framework_ffi_lib_arg` maps
`libdispatch → "libSystem"`.

**Symlinked-subframework resolution.** ColorSync, CoreGraphics, CoreText, and
ImageIO live under `ApplicationServices.framework` as symlinks, but libclang
resolves their declarations to the canonical *top-level* framework paths
(`System/Library/Frameworks/CoreGraphics.framework/...`). Only genuinely
non-symlinked subframeworks (HIServices, ATS, PrintCore) need an allowlist
entry in `is_from_framework`; the symlinked ones are accepted via their own
top-level entries.

**Subframework allowlist.** `SUBFRAMEWORK_ALLOWLIST = &["ApplicationServices"]`
in `collection/crates/extract-objc/src/extract_declarations.rs`'s
`is_from_framework` accepts header paths under that framework containing
`/Headers/`. Quartz is deliberately excluded: the `clang-2.0.0` crate panics on
a UTF-8 error when visiting a Quartz subframework path during a full collect.
Expanding the allowlist to Carbon/CoreServices would require fixing that panic
first.

## 7. Runtime library

The runtime is 18 files under `generation/targets/racket/runtime/`. The
canonical short name of the optional Swift helper dylib is
`libAPIAnywareRacket` (referenced only in `swift-helpers.rkt`).

### 7.1 Object model

- **`objc-object?` is a struct predicate, not a cpointer test.** A raw cpointer
  produced by `(cast ptr _pointer _id)` is FFI-tagged but is **not** an
  `objc-object` struct, so it fails the `objc-object?` contract at class-wrapper
  boundaries. The runtime distinguishes a wrapped object from a bare pointer.
- **`tell` receiver must be `coerce-arg`'d.** `tell` (from `ffi/unsafe/objc`)
  accepts only `_id`-tagged cpointers or imported class refs — *not*
  `objc-object?` struct wrappers, and *not* raw cpointers from ObjC trampolines
  (e.g. `self`/`event` args in dynamic-subclass IMPs). Both give
  `id->C: argument is not 'id' pointer`. `borrow-objc-object` does **not** fix
  this — its result is still a struct. The correct form is
  `(tell (coerce-arg receiver) selector ...)`; `coerce-arg` does the
  `(cast ... _pointer _id)` internally for all of `{string?, objc-object?,
  cpointer?, #f}`. Example: `(tell #:type _NSPoint (coerce-arg event) locationInWindow)`.
  Do **not** use `tell` as a bypass for non-object params (int, bool, SEL) —
  `tell` rejects them with the same `id->C` error.
- **`borrow-objc-object` / `wrap-objc-object`.** `borrow-objc-object` (in
  `objc-base.rkt`) wraps a raw cpointer as an `objc-object?` struct with **no**
  retain/release. `wrap-objc-object` wraps with ownership; `#:retained #t` marks
  a +1 owned pointer so the finalizer balances it. `make-delegate` returns a
  `borrow-objc-object` so delegates satisfy `objc-object?` at class-wrapper
  boundaries (e.g. `nsbutton-set-target!`). `as-id` in `objc-base.rkt` must
  `(cast ... _pointer _id)` in **both** its `objc-object?` and `cpointer?`
  branches — if the `objc-object?` branch returned the raw pointer, callers
  passing a wrapped object to `tell` would get the `id->C` error.
- **`objc-autorelease`** converts a +1 owned pointer to +0 autoreleased — used
  when a delegate callback returns an ObjC object (e.g. an NSString from
  `tableView:objectValueForTableColumn:row:`).
- **Precise GC registries.** Racket's GC is precise, so the runtime must
  actively prevent collection of ObjC objects, C callback pointers, and block
  structs. The `active-blocks` hash and `swift-gc-handles` registry pin these.
  Cocoa holds observers/delegates weakly, so a GC'd `make-delegate` silently
  stops firing — keep delegate results in module-level variables.
- **`with-autorelease-pool` uses `begin0`.** It expands to a `begin0` form
  internally, so `define` forms inside its body are invalid — use `let`/`let*`.
- **`->string`** (in `type-mapping.rkt`, re-exported via `coerce.rkt`) converts
  an NSString polymorphically: it accepts `objc-object`, `cpointer`, `string?`,
  or `#f`. It replaces the per-app `ns->str` helpers.
- **`list->nsarray` / `hash->nsdictionary`** (in `type-mapping.rkt`) wrap the
  `(tell (tell NSMutableArray alloc) init)` result via
  `(wrap-objc-object arr #:retained #t)` — `alloc+init` is +1 retained so the
  finalizer balances. Callers pass the result straight into class-wrapper param
  contracts. `nsarray->list` / `nsdictionary->hash` accept both raw cpointers
  and wrappers via `unwrap-objc-object`.

### 7.2 Delegates & protocols

- **`make-delegate` handler shape.** Positional args to `make-delegate` are
  alternating selector-string / procedure pairs. Handler lambdas do **not**
  receive `self` — only the delegated arguments. Keyword args are
  `#:return-types` and `#:param-types`. `make-<proto>` pre-fills both hashes
  from protocol IR.
- **`#:param-types` auto-coerces callback args.** It is a hash mapping selectors
  to lists of type symbols (`'object`, `'long`, `'int`, `'bool`, `'pointer`).
  The trampoline coerces each arg before the handler runs; `'object`-typed args
  are wrapped via `borrow-objc-object` so they satisfy `objc-object?` at wrapper
  boundaries. `delegate-set!` also reads the stored param-types. Without
  `#:param-types`, a dynamic-subclass IMP passes raw cpointers for id-typed
  args, and any class-wrapper call on that arg fails the `objc-object?` self
  contract — the symptom looks identical to the `tell`-on-cpointer error but the
  root cause is a contract violation at the delegate boundary.
- **Delegate return kinds.** `runtime/delegate.rkt` supports five return kinds:
  `'void`, `'bool`, `'id`, `'int`, and `'long`. `'int` casts the trampoline
  pointer to `_int32` (truncating the upper 32 bits); `'long` casts to `_int64`
  (lossless on 64-bit). `DelegateBridge.swift` provides `impInt0..3` (returning
  `Int32`) and `impLong0..3` (returning `Int64`); `selectIMP` and `typeEncoding`
  carry `("int", N)` / `("long", N)` cases. `delegate.rkt` mirrors them in
  `return-kind->string`, `make-delegate/swift`, `make-delegate/racket`,
  `delegate-set!`, plus `type-encoding-int` / `type-encoding-long` helpers.
- **Encoding `q` = NSInteger.** `NSInteger` is `typedef long NSInteger` on
  64-bit Apple platforms, and clang encodes `long` as `q` (not `l`). The
  delegate trampoline maps `'long → "q"` in both the Swift `typeEncoding` and
  the Racket `return-kind->string`. No separate `'nsinteger` kind is needed —
  `'long` is the correct return kind for an NSInteger-returning delegate method.

### 7.3 ObjC subclassing

- **`dynamic-class.rkt` surface.** `runtime/dynamic-class.rkt` exports the raw
  libobjc subclassing primitives: `objc-get-class`, `allocate-subclass`,
  `add-method!`, `register-subclass!`, `get-instance-method`,
  `method-type-encoding`, and `make-dynamic-subclass` (which chains
  allocate → add-method → register in the correct order). It also exports the
  type aliases `_Class` / `_SEL` / `_Method` / `_IMP` for raw-msgSend consumers.
  When overriding a superclass method, pull the type encoding via
  `(method-type-encoding (get-instance-method SuperClass sel))` rather than
  hardcoding the string — hardcoded encodings drift silently if Apple changes
  the ABI. `make-dynamic-subclass` guards against duplicate registration:
  `objc_allocateClassPair` returns NULL for an already-registered name (and
  `class_addMethod(NULL, ...)` would crash), so it returns the existing class
  via `objc_getClass` first. `class_addMethod` on an already-registered
  (non-NULL) class is a libobjc no-op, so re-requiring a module that calls
  `make-dynamic-subclass` at load time is safe.
- **`define-objc-subclass` macro.** `runtime/objc-subclass.rkt` implements
  Option B: `define-objc-subclass` layered over `make-dynamic-subclass`. It
  eliminates manual IMP/fptr assembly, GC pinning, and superclass-encoding
  lookup. The `(self SEL)` prefix is handled automatically — user lambdas
  receive args without the SEL. IMPs are pinned module-level against GC. Use
  `#:arg-types` / `#:ret-type` for unsupported struct/union/bitfield types;
  `syntax-parse`'s `~?` collapses an absent optional keyword clause to a
  sentinel without nested `if`. Constructor synthesis (`make-<class>`) is
  deliberately absent — inferring inherited init FFI signatures at expansion
  time would drift per superclass. `drawing-canvas.rkt` is the canonical
  consumer; design rationale is in
  `targets/racket/docs/design/2026-04-19-racket-oo-class-system-analysis.md`.
- **Encoding parser.** ObjC encoding strings interleave stack-offset *digits*
  between type tokens (e.g. `q8@0:4`); the parser in `objc-subclass.rkt` must
  skip numeric characters explicitly between tokens. Struct and union tokens
  (`{...}` / `(...)`) require *balanced-delimiter* parsing, not simple character
  dispatch — e.g. `{CGRect={CGPoint=dd}{CGSize=dd}}` nests arbitrarily deep.

### 7.4 Concurrency & threading

- **Green threads are dead under `nsapplication-run`.** Once `nsapplication-run`
  is called, all Racket green-thread primitives (`thread`, `sleep`, `sync`,
  `sync/timeout`, `thread-wait`, `semaphore-wait`) are non-functional — the
  Cocoa run loop blocks the Racket place main thread, so the scheduler never
  advances and `(thread ...)` bodies silently never execute. Alternatives:
  `call-on-main-thread` / `call-on-main-thread-after` (GCD dispatch),
  synchronous main-thread execution, or shell-level watchdogs.
- **GCD main-thread dispatch.** `main-thread.rkt` provides `on-main-thread?`,
  `call-on-main-thread` (synchronous if already on main, async via
  `dispatch_async_f` otherwise), and `call-on-main-thread-after` (delayed via
  `dispatch_after_f`). FFI details: `_dispatch_main_q` is a global *struct*, not
  a pointer — access it via `dlsym` directly; a module-level `function-ptr`
  prevents GC collection of the C callback pointer.
- **`_cprocedure` callbacks are unsafe from foreign OS threads.** Racket CS
  SIGILLs (exit 132) when a `_cprocedure` callback is invoked from an OS thread
  not registered with the Racket VM (e.g. a GCD worker-pool thread from
  libdispatch). `#:async-apply` converts the crash into a *deadlock* under
  `nsapplication-run`, because the async-apply queue drains on the main Racket
  thread, which is stuck in the Cocoa run loop. A CGEvent tap callback fires on
  `CFRunLoopGetMain` (the main OS thread), not a foreign thread — it is safe
  *without* `#:async-apply`. Any binding exposing a C callback type should warn
  against installing it on a non-main GCD queue or libdispatch worker. (This is
  the rationale for the emitter's `FunctionPointer`/`Block` auto-warning, §2.2.)
- **`function-ptr` satisfies `(or/c cpointer? #f)`.** A `function-ptr` built
  from `_cprocedure` satisfies the `(or/c cpointer? #f)` contract emitted for C
  callback params — no raw-symbol fallback is needed for callback params in
  generated bindings.
- **OS threads vs. places.** `call-in-os-thread` (from `ffi/unsafe/os-thread`)
  is safe only for pure Racket / file-I/O work: closures, list/hash ops,
  `parameterize`, `open-input-file`. It segfaults on `tcp-connect`,
  `subprocess`/`system`, and anything using the place scheduler's I/O event pump
  (`net/url` uses TCP, so it is transitively unsafe). Useful for CPU-bound work
  (fuzzy matching, serialization). For I/O off the main thread, use
  `dynamic-place`: each place runs a separate Racket VM on its own OS thread
  with its own scheduler, so `net/url`, `tcp-connect`, and `subprocess` work
  inside it. Place-channel semantics: `place-channel-put` is fully buffered
  (non-blocking sender); `place-channel-get` *blocks* (fatal on the main thread
  under `nsapplication-run`); `sync/timeout 0` on a place-channel is a
  non-blocking try-receive that is safe under `nsapplication-run`. Pattern: the
  place does I/O; the main thread polls via a non-blocking try-get on a
  `call-on-main-thread-after` timer and never blocks.

### 7.5 Memory

`(malloc …)` in Racket CS returns **GC-tracked** memory. Passing it to `free`
causes SIGABRT — `free` expects C-heap pointers only. Never call `free` on
`(malloc …)` buffers; the GC reclaims them automatically. Only call `free` on
memory returned by a C function that itself called `malloc` internally.

### 7.6 Runtime helper files

- **`cf-bridge.rkt`** — exports `racket-string->cfstring` /
  `cfstring->racket-string`, `cfnumber->integer` / `cfnumber->real`,
  `cfboolean->boolean`, `cfarray->list`, `make-cfdictionary`, and `with-cf-value`
  (auto-release).
- **`nsview-helpers.rkt`** — NSView geometry helpers.
- **`ax-helpers.rkt`** — typed AX attribute access. `ax-get-attribute/raw`
  returns a +1 owned `CFTypeRef`; `ax-get-attribute/array` calls `cfarray->list`
  with a `_CFRetain` per element; `malloc`/`CFRelease` are scoped internally (no
  `free` — see §7.5).
- **`cgevent-helpers.rkt`** — `CGEventTapCreate` + `CFRunLoop` plumbing.
  `make-cgevent-tap` accepts an `#:on-disabled` keyword (default: auto-re-enables
  the tap); the tap pointer is threaded through a `tap-box` to break a
  forward-reference cycle; it exports `kCGEventTapDisabledByTimeout` /
  `kCGEventTapDisabledByUserInput`; a module-level `function-ptr` provides GC
  stability; the tap fires on `CFRunLoopGetMain` so `_cprocedure` is safe
  without `#:async-apply` (§7.4).
- **`spi-helpers.rkt`** — `_AXUIElementGetWindow` with a graceful `#f` fallback.
- **`objc-interop.rkt`** — a named-`provide` re-export of `ffi/unsafe` +
  `ffi/unsafe/objc` symbols, for code that needs the raw FFI surface.
- **`app-menu.rkt`** — installs the standard app menu via
  `install-standard-app-menu!`. `tell` fails on selectors with SEL parameters
  (`addItemWithTitle:action:keyEquivalent:`,
  `initWithTitle:action:keyEquivalent:`) because Racket SELs are plain
  `cpointer`, not `_id`-tagged. `app-menu.rkt` therefore defines explicitly-typed
  `objc_msgSend` aliases (`_msg-init-with-title-action-key`,
  `_msg-add-item-with-title-action-key`, …) and calls them with
  `sel_registerName` selectors — the same pattern the generated framework
  bindings use for non-id-parameter methods.
- **`make-objc-block` nil guard.** `make-objc-block` returns `(values #f #f)`
  for `#f` input (NULL block pointer, no block-id). `free-objc-block` handles
  `#f` gracefully (a no-op via a `hash-ref` miss). `call-with-objc-block` passes
  `#f` straight through to its body.

Other runtime files: `block.rkt`, `coerce.rkt`, `delegate.rkt`,
`dynamic-class.rkt`, `main-thread.rkt`, `nsevent-helpers.rkt`,
`objc-base.rkt`, `objc-subclass.rkt`, `swift-helpers.rkt`,
`type-mapping.rkt`, `variadic-helpers.rkt`.

## 8. Verification

**Three verification layers — none alone suffices:**
- **Snapshot tests** verify the *text shape* of generated files.
- **The runtime-load harness** verifies that files load and *link*.
- **Static cross-reference** verifies that FFI binding types agree with the IR.

Calling-convention mismatches (e.g. a void method bound as `-> _id`) are
silently benign on M1 arm64 — the return register holds garbage that is read and
discarded. Neither snapshots nor the harness detect this; only a static audit
cross-referencing FFI dispatch types against the IR `return_type` catches it
(this is the rationale for the `tell #:type` matching rule, §2.3).

**The runtime-load harness.** It lives at
`generation/crates/emit-racket/tests/runtime_load_test.rs`. Two tests are
broad load checks:
- `runtime_load_libraries_via_dynamic_require` — loads each library file via a
  single Racket script that collects all failures.
- `runtime_load_apps_via_raco_make` — runs `raco make` over all sample apps.

The rest are targeted behavioral checks: `runtime_block_nil_guard` (the
`make-objc-block` nil guard, §7.6); `runtime_objc_subclass_macro` and
`runtime_objc_subclass_struct_encoding` (the `define-objc-subclass` macro —
primitive encodings, and the nested balanced-delimiter `{...}` encoding parser
plus `#:arg-types`/`#:ret-type` overrides, §7.3); `runtime_default_constructors`
(synthesized and factory class constructors actually construct, §2.3); and
`runtime_framework_deep_checks` (CoreGraphics/AVFoundation/MapKit functions
called with asserted results). Add a behavioral test here whenever a runtime or
emitter mechanism gains a failure mode the load checks would not catch.

The harness is gated on `RUNTIME_LOAD_TEST=1` and auto-skips when `racket`/`raco`
are missing or the enriched IR is absent. It builds a hermetic tempdir matching
the canonical target tree so it does not race the `compiled/` cache. It uses
`(dynamic-require `(file ,p) #f)` — a raw path string trips a `module-path?`
contract violation; the `(file ...)` quasi-form wraps absolute paths. It probes
for tooling via `binary_on_path("racket", "--version")` and
`binary_on_path("raco", "help")` — `raco --version` exits non-zero, so `raco help`
is the reliable probe.

Three arrays drive the harness:
- `RUNTIME_FILES` — the 18 runtime files.
- `LIBRARY_LOAD_CHECKS` — generated framework files exercised for load+link;
  several real-framework canaries (`nsmenuitem.rkt`, `nsevent.rkt`,
  `wkwebview.rkt`, …) catch arity and require-shape bugs that TestKit cannot.
- `APPS` — the sample apps, exercised via `raco make`.

**Standing rule:** extend `LIBRARY_LOAD_CHECKS` whenever a new framework
candidate appears — a new framework costs well under 1 s amortized against
Racket startup, and each extension is a chance to surface a new leak class
(§5). A new runtime file must be added to **both** `RUNTIME_FILES` and
`LIBRARY_LOAD_CHECKS`. A new sample app must be appended to `APPS` (and to
`REQUIRED_FRAMEWORKS` if it imports a framework not already in the hermetic
tree).

**`raco make` for apps.** For library files `dynamic-require` is the right
check. For apps under `apps/<name>/<name>.rkt`, `dynamic-require` opens a window
and blocks (apps call `nsapplication-run`); `raco make` instead compiles the
module and its full require graph without instantiating the body. GUI-level
verification belongs to the VM-based visual-testing workflow.

**Snapshot infrastructure.** `load_enriched_framework(name)` in `snapshot_test.rs`
generalizes framework loading — adding a framework is a file list plus a test
function. The AppKit suite has 24 curated golden files covering the key class
hierarchies (NSResponder → NSView → NSControl → NSButton, NSWindow, table view,
menus, text, layout). Rich classes like NSButton and NSWindow exercise more
typed-message-send variants and geometry-struct handling than Foundation
classes. Wire-format changes — serde annotations on core IR structs — update
Rust source across all crates but do **not** auto-update golden files; those
need `UPDATE_GOLDEN=1`.

**Gitignored generated state.** `generation/targets/racket/generated/` and
`analysis/ir/enriched/` are gitignored. Source fixes do not propagate to disk
until the pipeline is re-run, so: regenerate before testing emitter changes,
and when triaging a "bug" in generated output, check whether the source already
carries a fix that has not been regenerated.

**VM-verification (TestAnyware), racket recipe.** racket sample apps are
stub-launcher bundles that exec the *system* Racket (unlike chez's self-contained
binaries), so the VM must have Racket 9.2 + ffi2 provisioned. The TestAnyware
golden ships neither, and 9.2 is not downloadable (§0). Working recipe (verified
2026-06-02, TestAnyware 1.2.0, golden `macos-tahoe`/26.3):
1. `vmid=$(testanyware vm start --platform macos)`; `export TESTANYWARE_VM_ID=$vmid`.
2. Disable the tahoe desktop-reveal focus-steal once:
   `testanyware exec "defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false; killall WindowManager"`.
3. Provision Racket: tar the host distribution **excluding `doc`, `share/doc`,
   and the GUI `*.app`s** (≈223 MB gzip vs 977 MB full) and restore it to the
   **identical path** `/Applications/Racket v9.2/` in the VM so baked-in absolute
   paths resolve with zero relocation. TestAnyware 1.2.0 `upload` has **no** 4 MB
   chunk limit (the old `split -b 4m` recipe is obsolete) — single-shot the
   tarball. Symlink `/opt/homebrew/bin/{racket,raco}` → the distribution (the
   bundle's `DEFAULT_RACKET_PATH`). Then `raco pkg install --auto --scope user
   ffi2-lib` (fetches from GitHub; VM has network).
4. Build bundles on the host (`cargo run --example bundle_app -p
   apianyware-bundle-racket -- --all`), `tar`/`upload`/extract each `.app`,
   `xattr -dr com.apple.quarantine`, then `open -n --stderr <log> --stdout <log>
   "<App>.app"`. **First launch compiles the bundle's `.rkt` graph** (no `.zo`
   shipped) — allow ~25–35 s before a window appears.
5. The `testanyware exec` channel times out at **30 s** — keep per-call `sleep`s
   under that; poll the window with `testanyware agent windows` and capture with
   `testanyware screenshot`. `input key` modifiers use `--modifiers cmd,shift`
   (not `cmd+a`). If a window is reported `[focused]` but absent from a
   screenshot, the desktop-reveal stole focus — re-apply step 2 and
   `testanyware agent window-move --window <name> --x .. --y ..` to raise it.

## 9. Sample apps & bundling

**Why `.app` bundles.** A sample app must be packaged as a proper `.app` bundle
to (a) display the correct menu-bar app name and (b) get a per-app TCC
permission identity. The menu-bar name comes from `CFBundleName` in
`Info.plist`. `NSProcessInfo setProcessName:` has **no effect** on the bold
app-name slot on modern macOS, and `racket script.rkt` direct execution always
shows "racket" — bundling is required for correct app identity, not optional
polish.

**The two-crate story:**
- **`apianyware-stub-launcher`** (language-agnostic) — generates the
  Swift stub binary, the `Info.plist`, and the `.app` skeleton.
- **`apianyware-bundle-racket`** (this language) — does a require-tree
  BFS from the entry script to discover dependencies, copies the discovered
  files into `Resources/racket-app/<rel>` mirroring the source tree so relative
  requires resolve at runtime, and copies the optional
  `lib/libAPIAnywareRacket.dylib`. Only files actually reachable from the entry
  script's static requires enter the bundle.

**`bundle_app` CLI.** Build a bundle with
`cargo run --example bundle_app -p apianyware-bundle-racket -- <script>`
(or `-- --all`). Built bundles land at `apps/<name>/build/<App Name>.app`
(gitignored). The display name is read from the H1 of
`apps/macos/<name>/docs/spec.md` — a kebab→title conversion produces wrong
capitalisation for acronyms (e.g. "Ui Controls Gallery"). The bundle id is
`com.linkuistics.<NoSpaceTitle>`.

**`Resources/racket-app/` layout.** It mirrors the source tree:
`apps/<name>/<name>.rkt` for the entry, sibling `runtime/`,
`generated/oo/<framework>/`, and an optional `lib/` directory.

**A new app needs `spec.md` only.** Create `apps/<name>/<name>.rkt` and
`apps/macos/<name>/docs/spec.md` with `# <Display Name>` as the first heading.
The `bundle-racket` integration test auto-discovers apps via a directory
walk, so no test edits are needed for a new app. (The runtime-load harness's
`APPS` array is separate and *does* need the manual append — §8.)

**Bundle invariants.**
- *Exclude `compiled/`.* Host-compiled `.zo` files under `compiled/` are
  machine- and Racket-version-specific (linklets bake in host-specific path
  references); copying them to another machine causes load-time contract errors
  (e.g. a wrong-arity contract on a generated constructor). `bundle-racket`
  enforces this automatically: the `.rkt`-only walker skips `compiled/`
  implicitly, and `copy_dir_recursive` for `lib/` explicitly skips any
  `compiled/` subdirectory. Tests `bundle_lib_copy_excludes_compiled_subdirectory`
  and `bundle_has_no_compiled_directories_anywhere` guard this.
- *Normalize the dylib install_name.* After copying `lib/`,
  `normalize_dylib_install_names` shells out to
  `install_name_tool -id @executable_path/../Resources/racket-app/lib/<name>`
  on each `.dylib`. Racket's `ffi-lib` uses an explicit filesystem path and is
  indifferent to the identity, but any native consumer can now resolve the
  dylib inside the bundle. It is non-fatal if `install_name_tool` is missing (a
  `tracing::warn!`). Test `bundle_dylib_install_name_is_bundle_relative` guards
  the `@executable_path/` prefix.
- *Plist round-trip skip.* `plist::to_file_xml` output is not byte-identical to
  Apple's `PlistBuddy`. `merge_info_plist_overrides` skips the
  read-modify-write cycle entirely when `info_plist_overrides` is empty, to
  avoid spurious diffs.
- *`scan_rkt_string_literals` skips comments.* The require-discovery scanner in
  `bundle-racket/src/deps.rs` must skip `;`-to-EOL comments in its state
  machine — otherwise a string literal in a doc-comment (e.g. the path
  `".../runtime/objc-interop.rkt"` in `objc-interop.rkt`'s own header comment)
  is treated as a broken require target. Two regression tests guard this.

**Two-stage signing.** Sign the stub binary *before* copying `Resources/`
(first pass), then re-sign the full bundle *after* `Resources/` is populated
(second pass). A single post-copy sign produces an inconsistent bundle that
Gatekeeper rejects. `stub-launcher`'s `codesign.rs` implements both passes via
`codesign --force --sign`.

**Current app list (7 apps):** `hello-window`, `ui-controls-gallery`,
`note-editor`, `mini-browser`, `drawing-canvas`, `scenekit-viewer`,
`pdfkit-viewer`. Every app calls `(install-standard-app-menu! app "<Display>")`
from `runtime/app-menu.rkt`.

## 10. UI / framework gotchas

These are durable macOS-framework facts surfaced while building the sample apps.

- **NSStackView baseline alignment.** NSButton text and NSTextField text do not
  share a baseline by default — the controls compute their text origin
  differently (a button has a bezel inset; a field uses NSTextFieldCell vertical
  centering). Manual y-coordinate fiddling lands within ~1 px but is not perfect
  across font sizes. Use a horizontal `NSStackView` with
  `NSLayoutAttributeFirstBaseline` (= 12) alignment — Auto Layout pins the
  children's `firstBaselineAnchor`s together exactly.
- **NSStepper.** Requires `setContinuous: YES` to fire its target-action. An
  NSStepper placed inside a plain NSView nested in an NSStackView may not
  receive clicks — add it directly as an arranged subview of the stack view.
- **Radio buttons.** Mutual exclusion requires a manual target-action delegate
  — Cocoa does not group standalone radio buttons automatically.
- **NSScrollView.** A `dy = +50` scroll moves the content toward the *top*
  (toward Cocoa's unflipped origin) — the opposite of the natural-scrolling
  mental model. The default scroll-view bezel border looks wrong on a
  flush-to-window list — set `setBorderType: NSNoBorder` (= 0). Cell-based
  NSTableView row alignment looks "off" at the default 17 pt row height; an
  explicit 20 pt row height plus `setEditable: NO` per column gives a clean
  read-only list.
- **NSColor RGB color space.** `nscolor-red-component`, `-green-component`,
  `-blue-component`, and `-alpha-component` raise an `NSException` on a color
  that is not in an RGB color space (pattern, named, or greyscale colors).
  Before reading components off a color from NSColorPanel (whose color space is
  user-selectable), convert via
  `(nscolor-color-using-color-space c (nscolorspace-device-rgb-color-space))`.
  The result may be `#f` if the color cannot be converted — always guard with
  `(when rgb ...)` after the conversion.
- **PDFView notification observer pattern.** To observe
  `PDFViewPageChangedNotification` via NSNotificationCenter:
  1. The constant is generated as
     `(get-ffi-obj 'PDFViewPageChangedNotification _fw-lib _id)` — a raw
     `_id`-typed cpointer. The `name` param contract is
     `(or/c string? objc-object? #f)`, which rejects raw cpointers, so wrap it
     via `(borrow-objc-object PDFViewPageChangedNotification)` — the constant's
     lifetime is tied to the dylib, so no retain/release is needed.
  2. The observer is a `make-delegate` whose handler selector can be any valid
     ObjC identifier ending in `:`, with
     `#:param-types (hash "pageChanged:" '(object))` so the NSNotification arg
     arrives as an `objc-object?` wrapper.
  3. Keep the `make-delegate` result in a module-level variable — Cocoa holds
     observers weakly, and a GC'd observer silently stops firing.
- **NSSavePanel completion block.**
  `NSSavePanel beginSheetModalForWindow:completionHandler:` expects a block
  typed `(Int64 -> Void)`. Pass it via `make-objc-block`; the completion
  receives `NSModalResponseOK` (1) or `NSModalResponseCancel` (0) as the `Int64`
  argument. The same pattern works for any modal completion handler whose
  response is an `NSModalResponse` enum.
