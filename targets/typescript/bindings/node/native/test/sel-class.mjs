// Integration check for the SEL / Class **value surface** (`sel-classref-surface-k72`).
//
// `TypeRefKind::Selector` and `TypeRefKind::ClassRef` are pointer-shaped at the ABI — they share the
// object entries and route to the `_n` non-folding, non-wrapping siblings (k70/k71). At the TS
// surface they are nothing like an object: a SEL is a `string` (ADR-0055 §3), a Class is the bound
// constructor. Before k72 the emitted bodies passed BOTH directions RAW, so the declared types lied:
//
//   setAction_(action: string)  ->  ...(__unwrap(this), __sel('setAction:'), action)   // a JS string
//   action(): string            ->  return __dispatch.aw_ts_msg_0_P_n(...)             // a bigint
//
// A JS string reaching `napiReadHandle` read as 0 — so `-[NSControl setAction:]` bound a **nil SEL**,
// silently. This drives the real ObjC runtime through the real addon to prove the crossing converts.
//
//   1. SEL round-trip   — setAction:/action through a live NSButton: the selector set from a JS
//                         string comes back as the SAME string, and the ObjC runtime agrees it is a
//                         real, non-nil SEL (cross-checked via NSStringFromSelector).
//   2. SEL nil          — a control with no action returns null, not a bogus name (`__selName(0n)`).
//   3. Class round-trip — NSClassFromString / NSStringFromClass: a Class handle resolves to the
//                         BOUND constructor (`===` the emitted class, so statics compose), and
//                         passing it back reaches the same ObjC class.
//   4. Class stand-in   — `-[@"x" class]` is `__NSCFConstantString`, a private class NO binding
//                         declares. It must still round-trip through a stand-in carrying the true
//                         handle — the common case for `-[NSObject class]`, not an edge case.
//   5. No fold          — neither kind is an object, so nothing retains (ADR-0057 §4: `objc_retain`
//                         on a SEL is UB, a retained Class leaks). The `_n` entries are raw.
//
// Run: node targets/typescript/bindings/node/native/test/sel-class.mjs
// Requires: the addon built (build.sh).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const addon = require(fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url)));

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// AppKit must be loaded before its classes resolve (the addon links only Foundation & friends).
addon.aw_ts_fn_NSClassFromString; // touch the exports object
const NSButton = addon.getClass('NSButton');
if (NSButton === 0n) {
  // NSControl/NSButton live in AppKit — force the image in via the lazy free-function resolver,
  // which dlopens the owning framework on first call (fn-entry-spine-k68).
  addon.aw_ts_fn_NSStringFromClass(addon.getClass('NSObject'));
}

// ── The runtime seam, in miniature ────────────────────────────────────────────────────────────
// The emitted `.ts` calls these through '@apianyware/runtime'; here we exercise the exact
// primitives they bottom out in, against the real addon.
const __sel = (name) => (name === null ? 0n : addon.getSelector(name));
const __selName = (sel) => (sel === 0n ? null : addon.selectorName(sel));
const __class = (name) => addon.getClass(name);

const ctors = new Map();
const resolved = new Map();
const standIns = new WeakSet();
const handles = new Map();
class NSObjectStub {}
function __registerClass(name, ctor) {
  ctors.set(name, ctor);
  handles.set(ctor, () => __class(name));
}
function __classArg(cls) {
  if (cls === null) return 0n;
  const thunk = handles.get(cls);
  if (thunk === undefined) throw new Error('not a bound ObjC class');
  return thunk();
}
function __classCtor(cls) {
  if (cls === 0n) return null;
  const memo = resolved.get(cls);
  if (memo !== undefined && !standIns.has(memo)) return memo;
  const name = addon.className(cls);
  const bound = ctors.get(name);
  if (bound !== undefined) {
    resolved.set(cls, bound);
    return bound;
  }
  if (memo !== undefined) return memo;
  const stand = class extends NSObjectStub {};
  Object.defineProperty(stand, 'name', { value: name });
  standIns.add(stand);
  handles.set(stand, () => cls);
  resolved.set(cls, stand);
  return stand;
}

// The emitted classes, as the generator writes them (static-block registration).
class NSString extends NSObjectStub {
  static {
    __registerClass('NSString', NSString);
  }
}
class NSButtonCls extends NSObjectStub {
  static {
    __registerClass('NSButton', NSButtonCls);
  }
}

// ── 1. SEL round-trip through a live NSButton ────────────────────────────────────────────────
// The emitted bodies are:
//   setAction_(action: string): void { …aw_ts_msg_P_v(__unwrap(this), __sel('setAction:'), __sel(action)); }
//   action(): string { return __selName(…aw_ts_msg_0_P_n(__unwrap(this), __sel('action')))!; }
const btnCls = __class('NSButton');
check('NSButton resolves (AppKit loaded)', btnCls !== 0n, `handle=${btnCls}`);

const btn = addon.aw_ts_msg_0_P_o(btnCls, __sel('alloc')); // +1 owned
const inited = addon.aw_ts_msg_0_P_o(btn, __sel('init'));

// No action set yet → the nil SEL → null (NOT '' and NOT a bogus name).
const before = __selName(addon.aw_ts_msg_0_P_n(inited, __sel('action')));
check('2. a control with no action returns null, not a bogus name', before === null, `${before}`);

// Set from a JS string — the crossing that used to send a nil SEL.
addon.aw_ts_msg_P_v(inited, __sel('setAction:'), __sel('doThing:'));
const after = __selName(addon.aw_ts_msg_0_P_n(inited, __sel('action')));
check('1. setAction:/action round-trips the selector NAME', after === 'doThing:', `${after}`);

// Cross-check against the ObjC runtime itself: the SEL the control now holds is the same SEL
// `sel_registerName("doThing:")` returns, and NSStringFromSelector agrees on its name.
const held = addon.aw_ts_msg_0_P_n(inited, __sel('action'));
check('1. …and it is the SAME SEL libobjc interns', held === __sel('doThing:'), `${held}`);
const viaFn = addon.aw_ts_fn_NSStringFromSelector(__sel('doThing:'));
const viaFnName = addon.aw_ts_msg_0_N(viaFn, __sel('UTF8String'));
check('1. NSStringFromSelector(__sel(s)) === s', viaFnName === 'doThing:', `${viaFnName}`);

// The pre-k72 bug, reproduced deliberately: passing the raw JS string binds the NIL selector.
// (This is what every emitted `setAction_` used to do.)
let rawThrewOrNil = false;
try {
  addon.aw_ts_msg_P_v(inited, __sel('setAction:'), 'doThing:');
  rawThrewOrNil = addon.aw_ts_msg_0_P_n(inited, __sel('action')) === 0n;
} catch {
  rawThrewOrNil = true; // napi refuses the string outright — equally "not a SEL"
}
check(
  '1. (regression witness) passing the raw JS string does NOT bind a selector',
  rawThrewOrNil,
  'nil SEL or napi throw — the defect k72 fixes',
);

// ── 3. Class round-trip ───────────────────────────────────────────────────────────────────────
// NSClassFromString(s): typeof NSObject  →  __classCtor(raw)!
const nsstringCls = addon.aw_ts_fn_NSClassFromString(addon.cfstr('NSString'));
const resolvedCtor = __classCtor(nsstringCls);
check(
  '3. a Class return resolves to the BOUND constructor (=== the emitted class)',
  resolvedCtor === NSString,
  resolvedCtor?.name,
);
// …and back in: NSStringFromClass(aClass) → __classArg(aClass)
const nameObj = addon.aw_ts_fn_NSStringFromClass(__classArg(NSString));
const roundTripped = addon.aw_ts_msg_0_N(nameObj, __sel('UTF8String'));
check('3. Class round-trips out and back in', roundTripped === 'NSString', roundTripped);
check(
  '3. NSClassFromString of an unknown class is null (nil Class), not a lie',
  __classCtor(addon.aw_ts_fn_NSClassFromString(addon.cfstr('NoSuchClass_k72'))) === null,
);

// ── 4. The stand-in: -[NSObject class] on a real string ───────────────────────────────────────
// A constant NSString's class is `__NSCFConstantString` — private, absent from every binding.
const str = addon.cfstr('hello');
const strClass = addon.aw_ts_msg_0_P_n(str, __sel('class'));
const stand = __classCtor(strClass);
check('4. an unregistered (private) class still resolves', stand !== null, stand?.name);
check(
  '4. …the stand-in carries the TRUE handle (round-trips to the same ObjC class)',
  __classArg(stand) === strClass,
);
check('4. …and its identity is stable', __classCtor(strClass) === stand);
const standName = addon.aw_ts_msg_0_N(
  addon.aw_ts_fn_NSStringFromClass(__classArg(stand)),
  __sel('UTF8String'),
);
check(
  '4. …NSStringFromClass(stand-in) names the real private class',
  standName === stand.name,
  standName,
);

// ── 5. No retain fold on either kind (ADR-0057 §4) ────────────────────────────────────────────
// A Class is permanent and must never be retained; the `_n` entry passes it through raw. If the
// entry folded an objc_retain, the same handle fetched twice would still be identical (a Class is
// a singleton) — so instead assert the SEL/Class entries return the identical raw handles the
// runtime's own lookups do, i.e. nothing was wrapped, boxed, or transformed.
check(
  '5. the `_n` Class entry returns the raw runtime handle (no wrap, no fold)',
  addon.aw_ts_msg_0_P_n(str, __sel('class')) === strClass,
);
// The regression witness above left the button's action nil (that was its whole point), so
// re-establish it through the honest crossing before reading it back.
addon.aw_ts_msg_P_v(inited, __sel('setAction:'), __sel('doThing:'));
check(
  '5. the `_n` SEL entry returns the raw interned SEL (no wrap, no fold)',
  addon.aw_ts_msg_0_P_n(inited, __sel('action')) === __sel('doThing:'),
);

console.log(failures === 0 ? '\nALL PASS' : `\n${failures} FAILURE(S)`);
process.exit(failures === 0 ? 0 : 1);
