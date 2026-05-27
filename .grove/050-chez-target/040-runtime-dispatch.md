# 040-runtime-dispatch

**Kind:** work

## Goal
Fill `runtime/dispatch.sls` — the cluster carrying Scheme→ObjC call
trampolines. Three sub-machineries:

1. **Block bridge** — `make-objc-block`, `free-objc-block`,
   `call-with-objc-block`. Implementation: `foreign-callable` produces the
   block's invoke pointer; the `Block_layout` and `Block_descriptor_1`
   structs are constructed via `define-ftype`. The `_NSConcreteGlobalBlock`
   reference and `BLOCK_HAS_COPY_DISPOSE` flag come from the
   `aw_chez_create_block` helper in `libAPIAnywareChez.dylib` (until 060
   lands, use the racket-flavour `aw_racket_create_block` since the block
   ABI doesn't actually depend on the callable's source language — note
   this in the file header).
2. **Delegate bridge** — `make-delegate` + `set-delegate-method`. Wraps
   `aw_chez_register_delegate` (until 060: `aw_racket_register_delegate`)
   passing arrays of selector strings and per-selector
   `foreign-callable` pointers.
3. **Dynamic-class bridge** — `make-dynamic-subclass`,
   `allocate-subclass`, `add-method!`, `register-subclass!`. Wraps the
   libobjc surface declared in `runtime/ffi.sls`. IMPs are
   `foreign-callable` pointers, not the racket `function-ptr` form.

## Context
- ADR-0007 (lifetime — `foreign-callable` trampolines must run their body
  inside an autoreleasepool).
- `generation/targets/racket/runtime/block.rkt`, `delegate.rkt`,
  `dynamic-class.rkt` — for the API contract, not the implementation.
- Chez `foreign-callable` docs (lock-object, prevent-gc behaviour).

## Done when
- A demo block (e.g. `NSArray enumerateObjectsUsingBlock:`) invoked from
  Scheme via `make-objc-block` calls the Scheme proc per element.
- A demo delegate (a stub `NSURLSessionDelegate`) receives a callback
  from `NSURLSession`.
- A demo dynamic subclass (`NSView` override of `drawRect:`) instantiates
  and the override fires when AppKit calls into it.
- All three demos run under `(define-entry-point …)` — i.e. inside an
  autoreleasepool wrap, with guardian drain after.

## Notes
- The `foreign-callable` invoke must `lock-object` its Scheme closure to
  keep it alive across the C boundary. Document the pattern in the file
  header; sample-app authors will hit it too.
- The choice of whether to use Chez's `with-interrupts-disabled` around
  the callable body is settled here based on observation — note the
  outcome in `knowledge/targets/chez.md` (leaf 150).
