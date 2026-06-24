# SBCL target runtime

The hand-written SBCL runtime the generated CLOS bindings sit on — the **upper
layer** of the ADR-0038 two-layer design (the lower layer is the
`libAPIAnywareSbcl` Swift dylib at `targets/sbcl/adapters/macos/sources/`). Generated
framework trees land beside this `runtime/` dir and are read in the
`apianyware-sbcl-impl` package; bound Cocoa names stay `ns:`-qualified (the
CL-family contract surface, ADR-0033).

Built across node **050** (`.grove/050-build-runtime-native-core/`), bottom-up:
010 native dylib → 020 FFI seam → 030 MOP object model → 040 subclass/conformance
→ 050 lifetime/conditions → 060 threading/callbacks → 070 startup re-resolution →
**080 integration** (this README + the integration smoke). Design is settled in
the SBCL target design spec (`../../../docs/design/2026-06-20-sbcl-target-design.md`)
+ ADRs 0034–0038; these modules implement it.

## Modules (dev load order — see `load.lisp`)

| Module | Role | Leaf |
|---|---|---|
| `packages.lisp` | The two packages: `ns` (pure contract-surface holder, `(:use)` nothing) + `apianyware-sbcl-impl` (the runtime + the package every generated file is read in). | 020 |
| `ffi.lisp` | The `sb-alien` seam (ADR-0015): libobjc primitives, the `+objc-msgsend+` SAP + the typed-cast dispatch shape, lazy/cached/re-resolvable `aw-sel`/`aw-class`, `aw-ptr`/`aw-wrap`, the UTF-8 String bridge, the geometry struct typedefs, the seam hooks (`*objc-class-registry*`, `*subclass-instances*`, `*startup-reresolve-hooks*`). | 020 |
| `objc.lisp` | The MOP headline (ADR-0034): the `objc-class` metaclass + `validate-superclass`, the foreign ivar slot mechanism (`slot-value-using-class` over baked offsets), the `ns:ns-object` root, the baked-table consumers (`register-objc-class`, `register-objc-init`, `define-objc-constant`), and `make-instance`→alloc/init. | 030 |
| `swift-trampoline.lisp` | The Swift-native residual binding shape (ADR-0038 §3): the dylib loader, `aw-box-free`, the residual String coercers (`aw-swift-string-arg`/`-result`). | 020 |
| `subclass.lisp` | ObjC subclass synthesis + protocol conformance (ADR-0034 §5): `define-objc-subclass`/`define-objc-method`, `objc_allocateClassPair`/`registerClassPair`, the ONE forwarding dispatcher (post-bounce, GC-safe), `register-objc-protocol`, super-dispatch (`call-super`/`call-super-id`). | 040 |
| `lifetime.lisp` | `sb-ext:finalize` + the main-thread release queue + `with-autorelease-pool`/`define-entry-point` (ADR-0036). Finalizers run OFF-main → enqueue raw `id`; the main pool drain `release`s. | 050 |
| `conditions.lisp` | The `ns:objc-error`/`ns:cocoa-error`/`ns:objc-exception` hierarchy (ADR-0037), the single `signal-cocoa-error`, and the two call-site macros `aw-with-error-cell` (direct `NSError**`) / `aw-swift-call/error` (the `ThrowsBridge` consumer). | 050 |
| `threading.lisp` | The foreign-thread model (ADR-0035): `aw-block` (Lisp closure → C block, bounced to main), `aw-on-main`, the `sb-thread` native-worker boundary (`with-background-work`). | 060 |
| `startup.lisp` | The mandatory startup re-resolution pass (ADR-0034 §6 / ADR-0038 §5): re-`dlopen` direct frameworks + re-resolve every `Class`/`SEL`/`objc_msgSend` from baked string identity, run the subsystem reset hooks. On `sb-ext:*init-hooks*`. | 070 |

## Smoke suite — `tests/`

CLI/`--load` smoke (the VM-verify bar belongs to 060-sample-apps —
`feedback-vm-verify-every-app`; CLI smoke never satisfies a sample app's done-bar).
Each per-leaf smoke hand-authors a binding slice in the emitter's exact output
shape and drives it against **live, real** ObjC (the enriched IR is gitignored, so
`generate --target sbcl` cannot run locally for a real framework).

**Run the whole suite (builds the dylib first):**

```sh
targets/sbcl/bindings/macos/runtime/tests/run-integration-smoke.sh
```

| Smoke | Proves | Leaf |
|---|---|---|
| `smoke-ffi-seam.lisp` | the seam + the residual binding shape | 020 |
| `smoke-object-model.lisp` | the MOP: metaclass, dispatch, `call-next-method`, class methods, covariant wrap, foreign slots | 030 |
| `smoke-subclass-conformance.lisp` | subclass synthesis + a framework callback on main + `NSCopying` conformance + super-dispatch | 040 |
| `smoke-lifetime-conditions.lisp` | background release + pool drain on normal/signalled exit + `NSError**`→`ns:cocoa-error` | 050 |
| `smoke-threading-callbacks.lisp` | the ADR-0035 regression gate: a concurrent foreign block storm bounces to main + survives GC | 060 |
| `smoke-startup-reresolution.lisp` | the dumped-image re-resolution pass | 070 |
| **`smoke-integration.lisp`** | **the 050 NODE DONE-BAR** — see below | **080** |

### The integration smoke (`smoke-integration.lisp`, the node done-bar)

The whole 050 stack composed against a real framework, with the emitted bindings
loaded on top. Self-contained: it compiles its own Swift residual fixture
(`swift-residual-fixture.swift`, via `swiftc`) + the C foreign-thread harness
(`smoke-threading-callbacks.c`, via `clang`) at run time. Five gates:

- **Gate A — emitted-tree-loads.** The emitter's ACTUAL output (the committed
  `emit-sbcl/tests/golden/testkit/` tree) loads on the runtime: metaclass-backed
  classes, the `register-objc-{class,init,protocol}` baked tables, the
  defgeneric/defmethod lockstep, a geometry-returning method.
- **Gate B — four MOP operations** against live Foundation: instantiate (alloc/init
  + explicit-init), dispatch (chain + `call-next-method` + class method), subclass
  (override driven by an `NSNotificationCenter` callback), callback (a block from a
  foreign GCD thread bounces to main).
- **Gate C — background release** (ADR-0036) in the integrated runtime.
- **Gate D — the §6d Swift-native residual BY SHAPE** (a first-class outcome, equal
  to the ObjC/MOP work): function, constant, class-owner method (045), class-owner
  init (045), value-opaque box (round-trip + `aw-box-free`), `throws`→`ns:cocoa-error`
  — each links + calls through `libAPIAnywareSbcl` (+ the fixture dylib standing in
  for the gitignored `Generated/Trampolines.swift`). **Recorded PENDING** (not
  skipped): the **value-struct-owner** method/init (needs leaf **090**) and the
  **async-method trampoline** (the Lisp async-completion consumer is a deferred
  follow-up; the `CallbackBounce` family is covered by Gate B's callback op).

## Integration fixes (surfaced by 080)

080 is the first thing in the grove to *load emitted output on the runtime*, so it
surfaced three gaps the emitter delegates to the runtime ("leaf 050"). All fixed in
their owning units:

- **Geometry struct typedefs** (`ffi.lisp`). The FFI mapper emits
  `(sb-alien:struct ns-rect)` and explicitly delegates the matching
  `define-alien-type` to the runtime (`emit-sbcl/src/ffi_type_mapping.rs`). The nine
  canonical geometry structs (`ns-point`/`ns-size`/`ns-rect`/`ns-range`/insets/
  transforms/`cg-vector`, arm64 layout) now live in the seam — without them any
  `frame`/`bounds`/`rangeOfString:` binding fails to *load*. By-value struct passing
  is confirmed end-to-end (a live `NSRange {6, 5}` through `+objc-msgsend+`).
- **`define-objc-constant`** (`objc.lisp`). Every emitted `constants.lisp` uses this
  macro; it was defined nowhere. A `defparameter` over the emitter's foreign read.
- **Baked-table forms are MACROS, not functions** (`register-objc-init` in
  `objc.lisp`, `register-objc-protocol` in `subclass.lisp`). The node BRIEF's runtime
  contract emits these with **unquoted** literal data (`(:kw …)`, `((sel gen) …)`), so
  a function would try to *call* the data. Converted to macros that quote it.
