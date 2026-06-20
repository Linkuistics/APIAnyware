# 030-protocols

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
