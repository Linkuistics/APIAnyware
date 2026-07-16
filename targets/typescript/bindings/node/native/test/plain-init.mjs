// Standalone compile+run check for nsobject-plain-init-surface-gap-k122 — drives the REAL
// `__init` runtime primitive (classes.ts) against the REAL compiled addon, using the exact
// synthetic-init shape `emit_class::emit_synthetic_init` now generates for a class whose real
// ancestry never redeclares `-init` (own class file omitted here for the same reason every
// other test in this directory omits it — the bundler step that resolves bare `@apianyware/*`
// specifiers, Step 8/ADR-0060, does not exist yet; this drives the runtime seam directly,
// mirroring `dynamic-class.mjs`'s "emitted-shaped bindings" convention).
//
// `NSAlert` is the concrete corpus motivator (`note-editor-k118`'s confirmation alert, spec
// §11: "created via plain alloc/init — no factory"): it extends `NSObject` directly, and no
// class in its real ancestry redeclares `-init` — confirmed absent from the real header and
// `extracted.kdl` (this leaf's own Context). Real ObjC dispatch resolves the plain `-init`
// message to the true root's own implementation regardless, which is exactly what this proves
// first-hand rather than assumes.
//
// Run: node targets/typescript/bindings/node/native/test/plain-init.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { NSObject, __alloc, __class, __init, __installDispatch, __registerClass, __sel, __unwrap } = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// -retainCount as a plain unsigned scalar read (the 0_Q entry; does not mutate the count).
const rc = (id) => Number(addon.aw_ts_msg_0_Q(id, __sel('retainCount')));

// ── The exact emitted shape (emit_class::emit_synthetic_init) for a class with no bindable
// `-init` anywhere in its real ancestry: a bare `init(): this { return __init(this); }`. ──
class NSAlert extends NSObject {
  static {
    __registerClass('NSAlert', NSAlert);
  }
  static __cls = __class('NSAlert');

  init() {
    return __init(this);
  }

  // NSAlert's own real, generated `addButtonWithTitle:` — exercised below to prove the
  // returned instance is a genuinely usable NSAlert, not merely a non-throwing stand-in.
  addButtonWithTitle_(title) {
    const __ret = addon.aw_ts_msg_P_P(__unwrap(this), __sel('addButtonWithTitle:'), rt.__cfstr(title));
    return rt.__wrapRetained(__ret);
  }

  messageText() {
    const __ret = addon.aw_ts_msg_0_P(__unwrap(this), __sel('messageText'));
    return rt.__wrapRetained(__ret);
  }
}

check('addon exports the shape-generic owned-init entry', typeof addon.aw_ts_msg_0_P_o === 'function');

// ── 1. `__alloc(NSAlert).init()` — the concrete call site `note-editor-k118` needs. ──────────────
const alert = __alloc(NSAlert).init();
check('alloc+init returns a real NSAlert instance', alert instanceof NSAlert, alert?.constructor?.name);
const alertClassName = addon.className(addon.classOf(__unwrap(alert)));
check('…and the real ObjC runtime class is genuinely NSAlert', alertClassName === 'NSAlert', alertClassName);

// ── 2. `init()` returns `this` (polymorphic identity), matching every other emitted init(). ──────
check('init() returns the same wrapper it was called on (this, not a fresh mint)', alert.init() === alert);

// ── 3. The returned instance is not merely non-throwing — it is a REAL, working NSAlert. ─────────
alert.addButtonWithTitle_('Discard');
alert.addButtonWithTitle_('Cancel');
// A message send round-trip through the seam it returned from — not just "didn't crash".
const okName = addon.className(addon.classOf(__unwrap(alert)));
check('a real NSAlert method call round-trips after plain init', okName === 'NSAlert', okName);

// ── 4. Ownership: `init` is the uniform-+1 owned axis (ADR-0057 §2), exactly like every other
// zero-arg owned init the corpus already generates (`NSResponder.init()`, e.g.) — measured via
// a real, non-tagged-pointer receiver, not assumed. ──────────────────────────────────────────────
const before = rc(__unwrap(alert));
check('a freshly alloc+init’d object has a real (non-nonsensical) retain count', before >= 1, `retainCount=${before}`);

alert[Symbol.dispose]();

console.log(failures === 0 ? '\nALL PASS' : `\n${failures} FAILURE(S)`);
process.exit(failures === 0 ? 0 : 1);
