# Emitter Contract

Cross-language conventions every target emitter must implement. This is the
canonical place to record IR shapes whose handling is *not* obvious from the
type itself and would otherwise be re-discovered by each new target.

If you are starting a new target language emitter (Haskell, OCaml, Idris2,
Zig, Common Lisp, etc.), read this document first. Each section describes a
real-world surprise that the racket-oo emitter already handles and that
your emitter must also handle.

## Table of contents

- [OS_OBJECT_USE_OBJC bridged types (GCD)](#os_object_use_objc-bridged-types-gcd)

## OS_OBJECT_USE_OBJC bridged types (GCD)

### The IR shape

When the macOS SDK headers are compiled with `OS_OBJECT_USE_OBJC=1` (the
default on macOS), GCD handle types — `dispatch_queue_t`,
`dispatch_source_t`, `dispatch_data_t`, etc. — are declared as Objective-C
object pointers via the `OS_OBJECT_DECL_*` macro family. libclang therefore
reports them with the same shape as a real ObjC `id` reference, and the IR
records them as `TypeRefKind::Id`.

Concretely, in `collection/ir/collected/libdispatch.json`:

```jsonc
// dispatch_async(dispatch_queue_t queue, void (^block)(void))
{
  "name": "dispatch_async",
  "params": [
    { "name": "queue", "type": { "kind": "id" } },
    { "name": "block", "type": { "kind": "block", ... } }
  ]
}
```

The `kind: "id"` is correct — that is what the SDK header genuinely
declares. There is no per-class wrapper for `dispatch_queue_t`; the SDK
treats `dispatch_queue_t` as an ObjC object handle without a separate ObjC
`@interface` declaration that an emitter could discover.

### The mismatch

The same library exposes the well-known `_dispatch_main_q` *struct global*:

```jsonc
// libdispatch.json — constants[]
{
  "name": "_dispatch_main_q",
  "type": { "kind": "struct", "name": "struct dispatch_queue_s" }
}
```

So the global lives as `TypeRefKind::Struct` (correct — it is a struct
allocated in the dylib's data segment, and consumers need its *address*
via the `is_struct_data_symbol` path; see
[`emit_constants.rs`](../crates/emit-racket-oo/src/emit_constants.rs) and
the "Struct globals need address-of; pointer globals need dereference"
project memory).

That gives the emitted constant a raw pointer type. But every dispatch
function consuming the queue declares the parameter as
`TypeRefKind::Id` — i.e. an ObjC object reference. In a strictly-typed
target language, `pointer-from-data-segment` and `objc-object-id` are
*not* the same thing, and a direct call from one to the other will fail
to type-check or will require an explicit cast at every call site.

### Two acceptable resolutions

**(A) Substitute pointer-equivalent at FFI emission for the libdispatch
framework.** This is what `emit-racket-oo` does today:

```rust
// generation/crates/emit-racket-oo/src/emit_functions.rs
let t = mapper.map_type(&p.param_type, false);
// libdispatch OS-object types (dispatch_queue_t etc.) resolve to _id via
// OS_OBJECT_USE_OBJC, but no wrapper classes exist. Emit _pointer so
// consumers can pass raw cpointers (e.g. from ffi-obj-ref) without a
// (cast ... _pointer _id) ceremony.
if is_libdispatch && t == "_id" {
    "_pointer".to_string()
} else {
    t
}
```

A new emitter should add the equivalent override gated on
`framework == "libdispatch"`, picking whatever the target language's
"raw native pointer" type is (Haskell `Ptr ()`, OCaml `Ctypes.ptr void`,
Zig `*anyopaque`, Idris2 `AnyPtr`, etc.). Regression tests:
[`test_libdispatch_id_params_emit_pointer`](../crates/emit-racket-oo/src/emit_functions.rs)
and `test_libdispatch_id_return_emits_pointer`.

**(B) Emit an explicit cast at every call site.** Acceptable when the
target language's calling convention does not allow widening a raw
pointer to its bridged-id type without ceremony. Document it in the
target's runtime support library.

### When to promote to an IR annotation

Path (A) is per-emitter discovery, gated by the framework name. This is
acceptable while *only libdispatch* exhibits the pattern. If a second
framework triggers it — i.e. exposes a struct global whose typed
consumer signatures use `Id` for a non-class ObjC bridge — then the
right fix is to add an IR-level annotation marking the affected
`TypeRef` so emitters can apply the substitution mechanically without
hard-coding framework names.

A reasonable shape: a boolean flag on `TypeRef` (e.g.
`os_object_bridged: bool`) set during ObjC extraction by recognising the
`OS_OBJECT_DECL_*` macro origin. Until then the framework-name gate is
correct and minimal.

### Cross-references

- Project memory: `os-object-use-objc-makes-gcd-types-appear-as-objc-objects-in-ir`
- Project memory: `struct-globals-need-address-of-pointer-globals-need-dereference`
- Project memory: `synthetic-pseudo-framework-pattern-for-non-framework-system-headers`
  (libdispatch is a synthetic pseudo-framework)
- Backlog (closed): `ir-annotation-for-os-object-use-objc-typed-gcd-handles`
