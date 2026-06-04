# 020-native-bridges

**Kind:** work

## Goal

Author the ObjC native core's two **callback bridges** — `make-objc-block` and
`make-delegate` — replacing the 010 stubs. These are the pieces that genuinely
cannot be a thin `define-c-lambda` call (ADR-0017 §6): ObjC code, compiled by gsc
`-x objective-c` (via `c-declare` / a companion `.m`), statically linked.

## Context

Parent brief contracts: the **`make-delegate`** 4-tuple spec (protocols inbox note,
now in the parent brief) and the Gambit FFI **token vocabulary** the IMP signatures
marshal against. Racket analogues: block-bridge + `DelegateBridge`. Main-thread
model only — foreign-thread activation is node 080 (callbacks may bounce to main as
a placeholder, racket ADR-0014).

## Done when

- **`make-objc-block`** — constructs an ObjC block trampoline that invokes a
  registered Gerbil callback; used by any constant/function/method taking a block
  arg. Args/return marshalled per the FFI token vocabulary.
- **`make-delegate`** — the monomorphic delegate-bridge constructor. Contract
  (from the protocol inbox note, now in the parent brief):
  - one arg: a list of per-selector specs, each `(selector-string proc
    (param-token …) return-token)`;
  - returns an ObjC instance (`objc_allocateClassPair` + per-selector IMP
    trampolines) dispatching each protocol selector into its Gerbil `proc`,
    marshalling per the tokens;
  - lifetime: +1/retained-owned by the caller; the Gerbil side must root it (AppKit
    `setDelegate:` does not retain) — register the ADR-0019 will appropriately or
    document the rooting rule.
  - Token marshalling: object/id/Class/SEL/block/raw-pointer → `(pointer void)`
    (handler `wrap`s); scalars → `bool`/`intN`/`unsigned-intN`/`float`/`double`;
    C strings → `char-string`; by-value geometry structs → `CGRect`/… (may defer);
    return `void` is the common case.
- The emitter-side `make-<proto>` exposes the alternating selector/handler pair
  shape (witness `make-nswindowdelegate`); this leaf MAY reshape the spec (e.g.
  keyword/plist) **iff** it co-adjusts `emit_protocol.rs` + the parent contract.
- **Smoke:** a delegate built by `make-delegate` receives a real framework callback
  (e.g. an `NSTimer` target/action or a simple protocol method) and the Gerbil proc
  runs; a block built by `make-objc-block` is invoked by a framework API. Via gxc.

## Notes

Shares `objc_allocateClassPair` plumbing with 030's subclass synthesis — factor the
common class-pair/IMP-install C helpers so 030 reuses them. The IMP-signature
inference from tokens is the fiddly part; keep the token→`@encode` mapping table in
one place.
