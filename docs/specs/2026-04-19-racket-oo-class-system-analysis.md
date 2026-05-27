# racket Class System Analysis

**Date:** 2026-04-19
**Status:** Analysis — no code change yet
**Audience:** APIAnyware-MacOS maintainers deciding the racket target's next direction

## Executive summary

The target called **racket** does **not** use Racket's class system
(`racket/class`). Generated bindings are flat modules of free functions
named `<class>-<method>` over opaque `objc-object?` structs. The "OO" label
is currently a labelling convention, not a technical reality; the only
thing that would distinguish racket from a future racket-functional
target is "receiver is the first argument" vs "no implicit receiver".

The nine sample apps (2,632 lines, all working and VM-validated) cope
with the flat API without obvious friction. The pain points recorded in
`LLM_STATE/targets/racket/memory.md` are about FFI boundary
plumbing — `borrow-objc-object`, nullable returns, class/instance name
collisions, CS `malloc`/`free` semantics — none of which `racket/class`
would address.

There is one place Racket's class system would produce a dramatically
better caller experience: **dynamic subclassing**. Apps like
`drawing-canvas` override multiple ObjC methods via
`make-dynamic-subclass` and flat `(selector imp type-encoding)` tuples;
`class* parent% () (define/override ...)` is the natural shape for
that. This is latent lived pain, not theoretical.

**Recommendation:** do **not** rewrite generated class files as `class*`
forms. Instead, introduce a targeted `racket/class` layer for dynamic
subclassing only, and decide separately whether to rename the target to
reflect what it actually is.

## Findings

### 1. Zero use of `racket/class` anywhere

Verified by `grep -r "racket/class"` across the entire
`generation/targets/racket/` tree: no matches. Every generated file
begins with `#lang racket/base`, which does not even transitively import
`racket/class`. The runtime helpers (`objc-base.rkt`, `dynamic-class.rkt`,
`delegate.rkt`) do not use `class`, `class*`, `define/public`, `send`,
`interface`, or `mixin`.

### 2. Generated class shape is a procedural module

`appkit/nsview.rkt` (example):

```racket
#lang racket/base
(require ffi/unsafe ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt" ...)

(define (nsview? v) (objc-instance-of? v "NSView"))

(provide/contract
  [make-nsview-init-with-frame (c-> any/c any/c)]
  [nsview-set-alpha-value!     (c-> objc-object? real? void?)]
  [nsview-bounds               (c-> objc-object? any/c)]
  ...)
```

Every "method" is a free function. Class identity is a **runtime
predicate** (`objc-instance-of?` calls `class_isKindOfClass:` via
libobjc), so `(nsview? x)` works on subclass instances too — but there
is no static inheritance structure in the Racket file itself.

### 3. Inheritance is flattened, not structural

`effective_methods()` in `emit_class.rs` walks the IR inheritance chain
and emits every inherited method as a fresh `define` at the leaf class.
`NSButton` re-declares `nsbutton-set-alpha-value!` even though the
method belongs to NSView — because there is no `inherit` form in the
output to borrow from a parent class file. This works because ObjC's own
dispatch is dynamic (every method call hits `objc_msgSend` regardless
of which Racket file holds the wrapper), but it means `NSButton` is
not a Racket-level subtype of `NSView`.

### 4. Protocols are delegate factories, not interfaces

A protocol file exports exactly two bindings: `make-<proto>` (a variadic
procedure that constructs a delegate by pairing selector strings with
Racket lambdas) and `<proto>-selectors` (a `(listof string?)`). Racket's
`interface` form is not used; protocol conformance cannot be checked by
a contract.

### 5. Dispatch is procedural, not message-send

Sample-app callers use `(nsbutton-set-target! btn target)`, never
`(send btn set-target! target)`. The `send` form does not work because
generated bindings aren't `class%` instances.

## Where the current approach actually hurts

Grepping the runtime load harness, sample apps, and `memory.md` for
logged caller friction:

| Friction | Would `racket/class` help? |
|---|---|
| Raw cpointer → `objc-object?` wrapping at delegate boundaries | No — that's an FFI contract-layer issue |
| Nullable returns needing `(or/c <pred>? objc-nil?)` | No — orthogonal to OO |
| Class/instance selector name collisions (`+modifierFlags` vs `-modifierFlags`) | Partially — `class%` class methods live in a separate namespace, but the disambiguation fix already exists |
| `malloc`/`free` mismatch under Racket CS | No |
| Dynamic subclassing ergonomics (drawing-canvas, modaliser NSPanel override) | **Yes — materially** |
| Static polymorphism across sibling classes | Yes in principle, but no sample app wants this |

Only one row is a strong "yes": dynamic subclassing.

## Options

### A. Full migration to `class*` forms (NOT recommended)

Emit each ObjC class as `(define nsview% (class* nsresponder% () ...))`
with `define/public` per method and `define/override` for subclass
additions. Static inheritance works; `send` works; interfaces work.

**Cost:** 3–6 weeks of emitter work; all 9 apps rewritten; all runtime
helpers revised to speak `class%`; every contract in
`emit_class.rs` (`map_param_contract`, `map_return_contract`,
`SELF_CONTRACT`, `build_export_contracts`, `PropertyNameSets`) replaced
or duplicated; `tell`-dispatch and TypedMsgSend paths must re-integrate
with class-level method tables. Risk of subtle performance regressions
at method-dispatch hot paths.

**Benefit:** racket finally justifies its name. Static polymorphism
becomes expressible. `send` and `is-a?` work uniformly. None of the nine
current apps need this.

### B. Targeted `racket/class` layer for dynamic subclassing (recommended)

Leave generated class bindings as-is. Layer a new runtime module that
lets users write:

```racket
(define drawing-canvas-view%
  (objc-subclass nsview%
    [(draw-rect rect)     (lambda (self rect) ...)]
    [(mouse-down event)   (lambda (self event) ...)]
    [(mouse-dragged event)(lambda (self event) ...)]
    [(mouse-up event)     (lambda (self event) ...)]))
```

Internally this expands to the existing `make-dynamic-subclass` +
`add-method!` calls, with type encodings looked up via
`get-instance-method`/`method-type-encoding`. The ObjC class is still
registered with libobjc; `racket/class` is just the surface syntax.

**Cost:** ~1 week. One new runtime file; no change to the 283-framework
generator. drawing-canvas and future subclass-heavy apps migrate
incrementally.

**Benefit:** the one caller-visible win from OO is delivered without
rewriting everything. The flat-function API stays for sending messages
to existing ObjC classes, which is the common case.

### C. Thin caller-written `class%` veneer (no emitter change)

Document a pattern for users who want OO-style access to existing
classes:

```racket
(define window%
  (class* object% ()
    (init-field win)
    (define/public (set-title! s) (nswindow-set-title! win s))
    (super-new)))
```

**Cost:** zero code change. Write up the pattern in developer docs.
**Benefit:** users who prefer `send` can adopt locally. No ecosystem
fragmentation because it's opt-in.

### D. Rename the binding style (orthogonal to A/B/C)

Replace `"oo"` with `"procedural"` or `"receiver-first"` in the emitter
registry. The target's actual shape (curried first argument, kebab
names) becomes honest. Opens the door for a future real-OO target that
could be called `racket-class` or similar.

**Cost:** rename across directory paths, emitter registry, CLI flags,
tests, docs, bundle crate naming. ~1 day of mechanical churn.
**Benefit:** identity clarity. Users who pick "racket" expecting
`racket/class` no longer get a surprise.

### E. Accept the status quo

Keep the name. Document the style as "procedural wrappers over ObjC
class bindings" in the developer-docs task. Move on.

## Recommendation

Adopt **B + E** — build the targeted `class*` layer for dynamic
subclassing, keep the existing flat API for the rest, and keep the
name. The rename (D) is defensible but introduces churn for a benefit
mostly felt by newcomers; the Developer Documentation task can cover
the mismatch in one paragraph.

Reject **A**. Six weeks of emitter work to fix a name is disproportionate
when nine production apps already demonstrate the flat API works.

## Decision points for the maintainer

1. **Do you want to proceed with option B** (targeted `racket/class`
   layer for dynamic subclassing), and if so when?
2. **Is the "racket" name worth renaming** (option D) before writing
   developer documentation (task #3), or should we document what's
   there and move on?
3. **Should the Future Work entry remain open** as a tracking item for
   option B, or be closed as "analyzed, deferred"?

The existing backlog task can be closed on the basis of this document;
follow-on work (if any) should be a fresh entry naming the chosen
option.
