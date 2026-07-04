# Typed `make-instance` init appliers, and FP-trap masking for Cocoa

Two runtime mechanisms the first GUI app (hello-window)
required, refining the SBCL object model (**ADR-0034** §5, `make-instance` →
`alloc`/`init`) and lifetime/threading runtime (**ADR-0036**). Both block *every* app, so
they are settled here before the ladder proceeds.

## 1. Typed init appliers

### Context

`make-instance` → `aw-apply-init` originally handled only **0- and 1-arg `id`** inits
(`ecase (length kw-list) (0)(1)`, each value passed via `aw-ptr`); `register-objc-init`
baked only the selector's keyword list, **no argument types**. So a multi-arg or
non-`id`-typed designated init could not be built — `NSWindow`'s
`initWithContentRect:styleMask:backing:defer:` (an `NSRect` by value + two enums + a
`BOOL`) fell through the `ecase`. The runtime cannot synthesize the call from runtime
type data because `sb-alien:alien-funcall` needs the C function type at **compile time**.

### Decision

The emitter — which knows the init's signature — bakes a **typed applier closure** into
`register-objc-init`, reusing the exact `sb-alien` type-mapping and per-arg coercion it
uses for method dispatch:

```lisp
(register-objc-init 'ns:ns-window "initWithContentRect:styleMask:backing:defer:"
  (:init-with-content-rect :style-mask :backing :defer)
  (lambda (%alloced %args)
    (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
      (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer
        sb-alien:system-area-pointer (sb-alien:struct ns-rect)
        (sb-alien:unsigned 64) (sb-alien:unsigned 64) (sb-alien:boolean 8)))
      %alloced (aw-sel "initWithContentRect:styleMask:backing:defer:")
      (getf %args :init-with-content-rect) (getf %args :style-mask)
      (getf %args :backing) (getf %args :defer))))
```

`aw-apply-init` matches the init by initarg keys (order-independent) and `funcall`s the
applier with the alloc'd `id` + the initarg plist; the applier pulls each arg from the
plist by keyword, coerces by role (object → `aw-ptr`, selector → `aw-sel`, plain
scalar/bool/struct as-is — `sb-alien` coerces a Lisp generalized-boolean to `(boolean 8)`
and an integer to a scalar), and returns the raw `+1` `id` (the metaclass `make-instance`
wraps it). Handles **any arity and any arg type**, including by-value structs.

`register-objc-init`'s applier is **optional** (`&optional`): a legacy 3-arg form
(hand-authored smoke fixtures) registers `applier = nil` and takes the original
0/1-arg-`id` fallback in `aw-apply-init`. (`initWith…:error:` inits are not yet handled —
a documented follow-up; the error-cell threading exists for methods.)

### By-value geometry construction

A by-value geometry arg (an `NSRect` init/method arg) needs an `sb-alien` struct **value**.
The runtime adds stack-allocating constructor macros `aw-with-point` / `aw-with-size` /
`aw-with-rect` (`with-alien`, no leak; the C call copies by value, so the binding need
only outlive the call). A value-returning `make-rect` would have to `make-alien` (malloc)
and leak; the scoped macro is the non-leaking primitive the sample ladder uses.

## 2. FP-trap masking — required for any Cocoa code

### Context

SBCL is unusual in **enabling** the IEEE FP traps (`:invalid` / `:divide-by-zero` /
`:overflow`) by default; almost every other runtime masks them. AppKit/CoreGraphics
routinely produce NaN/∞ intermediates during ordinary layout and geometry — even a bare
`[[NSWindow alloc] init]` trips `:invalid` — so an unmasked SBCL crashes any GUI app with
`FLOATING-POINT-INVALID-OPERATION`.

### Decision

The runtime clears the FP traps — `(sb-int:set-floating-point-modes :traps '())` via
`aw-mask-fp-traps` — at load AND in the **startup re-resolution hook** (FP modes are
thread-local and do not survive a `save-lisp-and-die` revive). The Lisp-Cocoa bridges
(CCL, cl-objc) do the same. The bounce model (ADR-0035) means Cocoa callbacks run on the
main thread, which is the thread that masks; foreign threads never run Lisp.

## Consequences

`make-instance` now constructs the full designated-init surface, proven end-to-end on
`NSWindow` (by-value `NSRect` + enums + `BOOL`) with FP traps masked. All 7 runtime
smokes stay green (the optional applier preserves the hand-authored fixtures). Goldens
re-blessed for the new `register-objc-init` shape.
