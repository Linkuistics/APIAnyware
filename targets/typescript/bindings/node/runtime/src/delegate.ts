// JS object → ObjC delegate — the runtime *policy* half of ADR-0059 §3 (delegate surface) + §6
// (keep-alive). A JS object (a plain object literal *or* a class instance, ADR-0055 §4) reaching a
// **protocol-bound slot** is wrapped in an instance of a **per-protocol** memoized forwarding ObjC
// class: ONE `objc_allocateClassPair` per protocol (memoized here, thread-0 only), one typed inbound
// trampoline IMP per protocol method, a back-ref ivar to the JS object, and a per-instance
// `respondsToSelector:` snapshot (a bitset) taken at set-time so `@optional` fidelity is exact.
//
// This module owns the *when/what* — memoize the synthesis, register the delegate (a strong
// keep-alive), compute the responds snapshot, decide the associated-object keep-alive. The C-ABI
// *mechanism* (`objc_allocateClassPair`, `class_addMethod`, the trampolines, the
// `respondsToSelector:` IMP, `objc_setAssociatedObject`) is Swift-native — the ADR-0059 Mechanics
// policy-TS / mechanism-Swift seam, the same split as the subclass surface (k37).
//
// ── A slot, not a setter (reconciles ADR-0059 §3/§6; `emitted-delegate-spec-k84`) ─────────────────
// §6 was written around `setDelegate_` and keyed its association "per delegate-property". But
// ADR-0055 §4b binds **every** `id<P>` position, and a bound param admits a JS object literal by
// type — so *every* one of them must bridge, or the type lies. Measured over the corpus: 122 bound
// param sites, of which only 73 are one-arg setters; the rest are plain instance params (28),
// `init…` params (17) and statics (4). There is no IR fact separating "stored" from "transient", and
// a name sniff is exactly what ADR-0047 §4 exists to retire — so there is **one** rule for all of
// them:
//
//   • the **owner** is the receiver the slot is reached through (`this`, the class for a static, the
//     *return* for an `init…` — see `__protocolAdopt`);
//   • the **key** is `<selector>#<param-index>`, which for a property setter *is* per-property, and
//     which uniquely names every other slot too. Re-setting a slot releases its prior forwarder, so
//     a hot call site holds at most one live forwarder per (owner, slot) — bounded, never a leak;
//   • `associate` is the ADR-0059 §6 test, now on the **resolved** three-state ownership the emitter
//     reads from the IR (non-retaining / absent → associate; declared-retaining → skip).
//
// The skip arm cannot simply hand the forwarder over and drop it — the ObjC send has not happened
// yet when this function returns, so an unheld forwarder would already be dead. It hands back a
// `retainAutorelease`d one instead: the real ObjC +0 contract (alive for this runloop turn, so the
// callee's own retain lands), which is the very same reasoning `marshal.ts` uses for a `+0` return.

import {
  type CallbackId,
  type CallbackMarshal,
  __ensureInbound,
  __registerCallback,
} from './callbacks.js';
import { __dispatch } from './dispatch.js';
import { NSObject, __unwrap } from './lifetime.js';
import type { SubclassOverride } from './subclass.js';

/**
 * The per-protocol responds snapshot is a **64-bit bitset on the forwarder instance** (ADR-0059 §3:
 * "a bitset on the forwarder"), so a single protocol is bounded to this many methods. Real Cocoa
 * delegate protocols are far smaller — large surfaces are split into sub-protocols — so this is not
 * a practical limit; a protocol exceeding it is a **hard, visible error**, never a silent
 * responds-miscompute (a method past bit 63 would else read as "not implemented"). Widening to a
 * multi-word bitset is a trivial future change if one is ever needed.
 */
export const MAX_PROTOCOL_METHODS = 64;

/**
 * The static description of **one protocol** the emitter derives from the IR (ADR-0059 §3/§8) — and
 * nothing else. It carries no setter, no property key and no associate flag: those describe a *slot*,
 * not a protocol, and the same protocol types many slots (module doc). The call site passes them.
 */
export interface DelegateSpec {
  /** **Stable, unique** protocol identity — the per-protocol synthesis memo key *and* the ObjC
   *  `Protocol` name for `class_addProtocol` conformance. The emitter emits exactly one spec per
   *  protocol, so a `protocol` string maps to one `methods` layout by construction (the memo freezes
   *  the class + its selector→bit map at first synthesis; two differing layouts under one name would
   *  disagree on bit indices). Not re-validated here — the dumb-runtime posture, ADR-0055 §2. */
  readonly protocol: string;
  /** The protocol's methods, ordered; a method's **position is its bit index** in the responds
   *  snapshot. Each is `[rawSelector, objcTypeEncoding]` (e.g. `['archiver:willEncodeObject:',
   *  '@@:@@']`) — the encoding content-addresses the inbound trampoline (the inbound dual of the
   *  outbound `aw_ts_msg_*` codes), as in the subclass surface (k37). **Emitter contract:** every
   *  encoding here has an installable trampoline — the emitter derives them from `InboundSig` and
   *  *omits* (counted, never silently) a member whose shape is outside the inbound alphabet. A JS
   *  delegate may still declare such a method; `respondsToSelector:` answers NO for it and it never
   *  fires. */
  readonly methods: readonly SubclassOverride[];
  /** The protocol's **inbound value surface** (ADR-0059 §8) — the converter built from the emitted
   *  per-method value-kind descriptors (`__methodMarshal`, marshal.ts), keyed by **raw selector**, so
   *  the delegate receives the object/`SEL`/`Class` types its interface declares instead of raw
   *  handles. Optional: a spec without one traffics in raw `bigint`s (the pre-descriptor behaviour the
   *  native-level batteries are written against). **Emitter contract:** a spec that carries one must
   *  cover every selector in `methods` — an uncovered selector throws rather than guessing (marshal.ts). */
  readonly marshal?: CallbackMarshal | undefined;
}

/** At most one synthesized forwarding `Class` per protocol (ADR-0059 §3 — memoized, never disposed). */
const forwarders = new Map<string, bigint>();
let forwarderSeq = 0;

/**
 * The per-protocol forwarding `Class` handle for `spec`, synthesized on first use and memoized
 * (ADR-0059 §3 — one class per protocol, never per-object). Thread-0 only (`objc_registerClassPair`
 * races off main, ADR-0059 Mechanics). Throws before allocating if the protocol exceeds the
 * responds-snapshot bound, so an oversized protocol fails loudly rather than miscomputing responds.
 */
export function __forwarderClass(spec: DelegateSpec): bigint {
  const cached = forwarders.get(spec.protocol);
  if (cached !== undefined) return cached;
  if (spec.methods.length > MAX_PROTOCOL_METHODS) {
    throw new RangeError(
      `@apianyware/runtime: protocol ${spec.protocol} has ${spec.methods.length} methods, ` +
        `exceeding the ${MAX_PROTOCOL_METHODS}-method responds-snapshot bound (ADR-0059 §3)`,
    );
  }
  __ensureInbound();
  forwarderSeq += 1;
  const name = `APIAnyware_Forwarder_${spec.protocol}_${forwarderSeq}`;
  const encoded = spec.methods.map(([selector, encoding]) => `${selector}|${encoding}`);
  const handle = __dispatch.defineForwarder(spec.protocol, name, encoded);
  forwarders.set(spec.protocol, handle);
  return handle;
}

/**
 * The set-time `respondsToSelector:` snapshot (ADR-0059 §3): bit `i` set iff the JS delegate `jsObj`
 * implements the injective-mapped (`:`→`_`, ADR-0055 §3) name of `methods[i]`. Taken once at set-time
 * on thread 0 so `@optional` fidelity is exact and the framework's optional-probing never triggers a
 * live off-main JS consult. Post-set mutation of `jsObj`'s method set is unsupported (matching ObjC's
 * fixed method set), as the ADR notes.
 */
export function __respondsBits(jsObj: object, methods: readonly SubclassOverride[]): bigint {
  let bits = 0n;
  for (let i = 0; i < methods.length; i++) {
    const name = methods[i][0].replace(/:/g, '_');
    if (typeof (jsObj as Record<string, unknown>)[name] === 'function') {
      bits |= 1n << BigInt(i);
    }
  }
  return bits;
}

/**
 * Mint a forwarder for `jsObj`: a `+1` owned instance of `spec`'s memoized per-protocol forwarding
 * class, carrying the back-ref to its registry entry (the strong JS-side keep-alive, dropped again by
 * the forwarder's own `dealloc` — callbacks.ts `__deliverDealloc`) and its `respondsToSelector:`
 * snapshot. Thread-0 only.
 */
function mintForwarder(jsObj: object, spec: DelegateSpec): bigint {
  const forwarder = __dispatch.allocInit(__forwarderClass(spec)); // +1 owned
  const cbid: CallbackId = __registerCallback(jsObj, spec.marshal);
  __dispatch.setBackRef(forwarder, cbid);
  __dispatch.setRespondsBits(forwarder, __respondsBits(jsObj, spec.methods));
  return forwarder;
}

/**
 * The handle for a **protocol-bound slot's** argument (ADR-0055 §4b) — the one place the corpus
 * discriminates a wrapped ObjC object from a plain JS object, and the reason `__unwrap` no longer has
 * to (`emitted-delegate-spec-k84`). Every emitted `id<P>` param routes through it.
 *
 * - `null` → the nil handle, and any forwarder previously bound to this slot is released (clearing a
 *   delegate must not leave its JS side pinned by a stale association);
 * - a **wrapped ObjC object** → its handle, and likewise the slot's prior forwarder is released (the
 *   caller replaced a JS delegate with a real one);
 * - a **plain JS object** → a freshly minted forwarder (`mintForwarder`), held by one of two owners:
 *   - `associate` (the slot is `weak`/`assign`, or its ownership is undeclared — ADR-0059 §6's
 *     default arm): a strong `objc_setAssociatedObject` on `owner` under `key`, so the forwarder
 *     lives exactly as long as the owner, and re-setting the slot releases the previous one;
 *   - otherwise (the slot is declared-retaining — the framework holds it): `objc_retainAutorelease`,
 *     the ObjC `+0` contract. The send has not happened yet, so the forwarder must survive *this
 *     turn* for the callee's own retain to land on something alive; after that the callee owns it.
 *
 * The alloc `+1` is balanced in both arms, leaving exactly one owner — the association or the callee.
 * `owner` is a raw handle (an instance, or a `Class` for a static slot); `0n` means *not yet* — an
 * `init…` slot, whose owner is the object the initializer returns, adopted by [`__protocolAdopt`].
 * Thread-0 only.
 */
export function __protocolArg(
  owner: bigint,
  key: string,
  value: object | null,
  spec: DelegateSpec,
  associate: boolean,
): bigint {
  if (value === null || value instanceof NSObject) {
    // Only an associating slot can *have* a stale forwarder to clear; a skip-arm one never held one.
    if (associate && owner !== 0n) __dispatch.associate(owner, key, 0n);
    return __unwrap(value as NSObject | null);
  }
  const forwarder = mintForwarder(value, spec);
  if (associate && owner !== 0n) {
    __dispatch.associate(owner, key, forwarder);
  } else {
    __dispatch.retainAutorelease(forwarder);
  }
  __dispatch.release(forwarder);
  return forwarder;
}

/**
 * Give an `init…` slot's forwarder its owner (module doc). An initializer's delegate is stored by the
 * object the initializer **returns**, not by the receiver it was sent to — `[[NSFilePromiseProvider
 * alloc] initWithFileType:delegate:]` — and ObjC lets `init` return a *different* object than `alloc`
 * did, so the owner simply does not exist until the call comes back. [`__protocolArg`] is therefore
 * given `owner = 0n` for such a slot and takes its `retainAutorelease` arm (the forwarder is alive for
 * this turn, which spans the call); this adopts it onto the result.
 *
 * A no-op unless the slot actually minted a forwarder — a wrapper or `null` argument owns itself — and
 * unless the initializer returned something (a failed `init` returns nil, and the un-adopted forwarder
 * simply drains with the pool). Re-tests `value` through the *same* `instanceof NSObject` predicate
 * [`__protocolArg`] used, rather than tracking minted handles: one predicate, no hidden state.
 */
export function __protocolAdopt(
  owner: bigint,
  key: string,
  value: object | null,
  arg: bigint,
  associate: boolean,
): void {
  if (!associate || owner === 0n || arg === 0n) return;
  if (value === null || value instanceof NSObject) return;
  __dispatch.associate(owner, key, arg);
}
