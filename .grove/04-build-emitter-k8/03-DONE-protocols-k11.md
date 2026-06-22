# protocols-k11

**Kind:** work

## Goal

- **`emit_protocol.rs`** — emit each ObjC protocol as the CLOS surface for its
  methods. A static emitter that *declares conformance* to existing protocols
  (contract §3.5 — methods belong to Lisp-created subclasses; no category-on-
  foreign-class). Emit per-protocol generics where the protocol contributes a
  selector not otherwise on the class graph; the runtime drives conformance.
- **`protocol_registry.rs`** — the cross-framework `ProtocolRegistry` (peer
  `emit-gerbil/protocol_registry.rs`): the emitter flattens a class's
  conformed-protocol methods via the class's **own conformance closure only**
  (the gerbil 120-leaf convention — see the gerbil-grove memory). Build the
  registry over all loaded frameworks in the generate pre-pass (mirror gerbil's
  empty-registry-in-`new` + populated-swap pattern; see `cli/.../generate.rs` and
  the registry comment in `cli/src/registry.rs`).

## Context

Contract spec §3.5 (defining methods / protocol conformance). SBCL design spec §6
(contract §3.2 dispatch maps to per-selector generics). Reference:
`emit-gerbil/src/{emit_protocol.rs,protocol_registry.rs}` and how `generate.rs`
swaps in the populated registry. The `objc_exposed` split applies to protocol
methods as to class methods (ADR-0026 §3).

## Done when

- `emit_protocol` produces the protocol surface for a fixture framework with
  protocols (testkit `tkcopying`/`tkdelegate` analogues); snapshot tests pass.
- `ProtocolRegistry` flattens conformed-protocol methods via own-closure only;
  populated-registry swap wired through `generate.rs`.

## Notes

- Verify SBCL needs the same flattening gerbil's 120-leaf added — if the CLOS
  generic model already covers protocol-method dispatch via the class graph,
  flattening may be lighter. Decide and record inline.

## Decisions (recorded — this leaf is done)

**D-prot-1 — SBCL needs the SAME flattening as gerbil; it is not lighter.** The
`defclass … :metaclass objc-class` graph reifies only the ObjC *superclass* chain
(ADR-0034). CLOS method inheritance covers superclass methods structurally (a
`defmethod` on `ns:ns-view` applies to `ns:ns-control` instances) — so those are
never re-emitted, exactly gerbil's ADR-0020 win. But **protocol conformance is
orthogonal to the class graph**: a protocol is no CLOS superclass, so a conformed
protocol's methods (`NSData`'s `copyWithZone:` from `NSCopying`) live on no
ancestor and would be unreachable. They are flattened onto each conforming class
via the class's **own conformance closure only** (`ProtocolRegistry`), identical
to gerbil's leaf-120. A CLOS-mixin alternative (each protocol as an extra
`defclass` superclass, one `defmethod` for all conformers) was considered and
rejected — it would change ADR-0034's settled "ObjC ancestor chain only" graph and
force the metaclass to validate superclasses with no ObjC class behind them.
Recorded durably in `protocol_registry.rs` + `emit_generics.rs` module docs.

**D-prot-2 — no `make-<proto>` delegate constructor (gerbil divergence).** The
CL-family contract realizes the delegate pattern through `define-objc-subclass` +
`define-objc-method` (§3.4/§3.5 — methods belong to Lisp-created subclasses), not a
delegate-object constructor. So `emit_protocol` emits the CLOS surface
(`defgeneric`s for delegate-only selectors not on the class graph) + a
`register-objc-protocol` name table, NOT gerbil's `make-<proto>` + marshalling-token
table. The runtime reads ABI type encodings from the *live* protocol — "the runtime
drives conformance". New 040→050 contract element recorded in the 050 leaf.

**D-prot-3 — the `with_registries` swap + `generate.rs` "sbcl" branch are
deferred to 060, not done here.** The leaf's "Done when" listed the populated swap
"wired through generate.rs", but `emit_framework` is still the 040/010 scaffold
(no class-graph / generics / protocol emission), so a generate.rs branch that
*built* both registries and swapped them in would feed a no-op emitter — registries
built then discarded, untested dead wiring (violates grove's lazy-artifact rule).
The flattening **capability** is delivered + unit-tested here (every emit path is
parameterized on `&ProtocolRegistry`); the swap call-site lands in 060 together
with `emit_framework`'s consumption of it (its rightful consumer). The 060 leaf
Goal now spells this out exactly. Node done-bar is unaffected — 060 is the
node's integration/done-bar leaf regardless.
