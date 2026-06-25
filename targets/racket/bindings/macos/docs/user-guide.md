# racket macOS binding — user guide (§22)

The entry point for **using** the generated racket binding for macOS. This page orients you to the
binding artifact and its layout; the comprehensive, task-oriented walkthrough is the
[**racket developer guide**](../../../docs/developer-guide.md) — start there for your first
program, delegates, completion blocks, threading, packaging, and AppKit quirks.

## What you are using

A class-and-method binding over directly-dispatched ObjC. Every class is a flat module of free
procedures named `<class>-<method>` operating on an opaque `objc-object?` struct — **not** the
Racket class system. If a familiar idiom surprises you, the friction is almost always FFI-shaped,
not OO-shaped (see the developer guide's *What "OO" means* section). The target model behind it is
mapped in [`../../../docs/overview.md`](../../../docs/overview.md).

## The binding layout (`bindings/macos/`)

| dir | what it holds |
|---|---|
| `generated/<framework>/<class>.rkt` | emitted per-class binding source (gitignored — produced by `apianyware-generate`) |
| `runtime/` | the hand-written runtime (the ffi2 seam, object model, `DelegateBridge`/`BlockBridge`, main-thread bounce) |
| `lib/` | the built `libAPIAnywareRacket.dylib` |
| `tests/` | Racket-level binding tests |
| `reports/` | screenshots / VM-verify artifacts |

See [`../README.md`](../README.md) for the dir contract.

## Requiring bindings

Import the per-class files you need; use `only-in` for framework-level functions/constants so a
broken sibling module can't leak through:

```racket
(require "../../generated/appkit/nsbutton.rkt"
         (only-in "../../generated/corefoundation/functions.rkt" CFRelease))
```

The full requiring model — `only-in` semantics, the `racket/contract` `->` rename, and the
escape hatch when a module has a load-time error — is in the developer guide's *Requiring
generated bindings* section. For dropping below the binding entirely, see
[`unsafe-escape-hatches.md`](unsafe-escape-hatches.md).

## Where to go next

- [**developer-guide.md**](../../../docs/developer-guide.md) — the comprehensive user guide.
- [`platform-docs-mapping.md`](platform-docs-mapping.md) — translate an Apple API-doc page into
  the racket names.
- [`api-coverage.md`](api-coverage.md) — what is and isn't covered, and how faithfully.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching APIs the binding doesn't model.
- [`../../../docs/reference.md`](../../../docs/reference.md) — the deep target reference.
