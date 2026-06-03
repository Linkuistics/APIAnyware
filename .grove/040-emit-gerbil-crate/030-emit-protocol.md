# 030-emit-protocol

**Kind:** work

## Goal

Write `emit_protocol.rs` — delegate-protocol emission. For each ObjC
`@protocol` declaring ≥1 method, emit a Gerbil module exposing the protocol's
selector table and a constructor that builds a delegate dispatching ObjC
protocol callbacks into Gerbil procedures. Wire into `emit_framework`.

## Context

Node brief + design spec §6 (native core: delegate bridging — the
`DelegateBridge`-equivalent IMP dispatching ObjC protocol methods to Gerbil).
ADR-0019 (lifetime) and §5 (entry-point `@autoreleasepool` wraps every callback
trampoline). Reference: `emit-chez/src/emit_protocol.rs` — emits
`<proto>-selectors` + a variadic `make-<proto>` taking alternating
selector/handler pairs, building a `delegate` record from the runtime via a
monomorphic `make-delegate` fed a static per-selector
`(selector proc param-types return-type)` table. Foundation from 010
(`naming`, `ffi_type_mapping`).

## Done when

- `generate_protocol_file(proto, framework) -> String` and
  `protocol_exports(proto) -> Vec<String>` exist (the two entry points
  `emit_framework` calls).
- Emits, per protocol: a `<proto>-selectors` binding and a `make-<proto>`
  constructor over the runtime's delegate-bridge entry. The Gerbil delegate
  constructor takes the alternating selector/handler form (or the idiomatic
  Gerbil keyword/plist form — implementer's call, matching the runtime's
  `make-delegate` contract from 050). Each selector's `param-types`/`return-type`
  come from the static table the emitter builds from the IR via
  `ffi_type_mapping` — callers never spell ABI types.
- Empty protocols (no required/optional methods) are skipped (chez's
  `empty_protocols_are_skipped`).
- `emit_framework` writes protocol modules (under the layout 010 settled — chez
  uses a `protocols/` subdir; pick the Gerbil-correct nesting) and adds them to
  the `main` re-export, including any name-collision rename for class/protocol
  pairs (chez's `is_protocol` rename path — e.g. `NSAccessibilityElement`).
- Crate compiles; unit test covers a one-method protocol like chez's
  `framework_with_protocol_writes_under_protocols_subdir`.

## Notes

The runtime's `make-delegate` / `DelegateBridge` names + the alternating-pair
vs keyword calling shape are 050's contract. Pick the obvious shape, emit against
it, and **inbox-add to 050** so the runtime matches — don't block. The actual
ObjC IMP synthesis lives in the 050 native core (ObjC-in-gsc), not here; this
leaf only emits the Gerbil-side registration.
