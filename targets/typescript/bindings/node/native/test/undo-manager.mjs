// Standalone compile+run check for text-undo-surface-gap-k121 — drives the REAL native
// dispatch entries the generated NSTextView.ts / NSResponder.ts / NSUndoManager.ts call sites
// use (same entry codes, read off the real generated files), against the real compiled addon.
// Headless (no visible window — an offscreen NSWindow, no VM). Raw dispatch, matching this
// directory's own convention (dynamic-class.mjs, geometry.mjs, marshal.mjs) rather than
// importing the generated ESM modules directly, since the bundler step (Step 8, ADR-0060) that
// resolves their bare `@apianyware/*` specifiers at runtime does not exist yet.
//
// An offscreen NSWindow is required, not a nicety: NSResponder's default `-undoManager`
// forwards up the responder chain, which for an orphan NSTextView (no superview/window) is
// empty — a real, correct `nil`, not a binding bug. `note-editor-k118`'s real window gives the
// chain somewhere to resolve to; this test reproduces that shape headlessly.
//
// Run: node targets/typescript/bindings/node/native/test/undo-manager.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { __class, __cfstr, __installDispatch, __sel } = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

const alloc = (className) => addon.aw_ts_msg_0_P(__class(className), __sel('alloc'));
const utf8 = (id) => addon.aw_ts_msg_0_N(id, __sel('UTF8String'));

// `[[NSWindow alloc] initWithContentRect:styleMask:backing:defer:]` — NSWindowStyleMaskBorderless
// (0), NSBackingStoreBuffered (2), defer NO — an offscreen window, never ordered front.
const windowRect = { origin: { x: 0, y: 0 }, size: { width: 200, height: 200 } };
const window = addon.aw_ts_msg_RQQb_P_o(
  alloc('NSWindow'),
  __sel('initWithContentRect:styleMask:backing:defer:'),
  windowRect,
  0n,
  2n,
  false,
);
check('NSWindow alloc/init produced a real instance', window !== 0n, String(window));

// `[[NSTextView alloc] initWithFrame:rect]` — the real designated init, real CGRect crossing.
const viewRect = { origin: { x: 0, y: 0 }, size: { width: 100, height: 100 } };
const view = addon.aw_ts_msg_R_P_o(alloc('NSTextView'), __sel('initWithFrame:'), viewRect);
check('NSTextView alloc/initWithFrame: produced a real instance', view !== 0n, String(view));

addon.aw_ts_msg_P_v(window, __sel('setContentView:'), view);
check(
  'the text view is really installed as the window contentView',
  addon.aw_ts_msg_0_P(window, __sel('contentView')) === view,
);

// ── Gap B: NSTextView.allowsUndo / setAllowsUndo: (the `NSSharing` category — was invisible
// before category methods merged into `Class::methods`, text-undo-surface-gap-k121). ──────────
addon.aw_ts_msg_b_v(view, __sel('setAllowsUndo:'), false);
check(
  'setAllowsUndo:(false) takes effect',
  addon.aw_ts_msg_0_b(view, __sel('allowsUndo')) === false,
);
addon.aw_ts_msg_b_v(view, __sel('setAllowsUndo:'), true);
check(
  'setAllowsUndo:(true) restores it',
  addon.aw_ts_msg_0_b(view, __sel('allowsUndo')) === true,
);

// ── Gap A: NSResponder.undoManager (the `NSUndoSupport` category — was invisible), now
// resolving through a real responder chain (text view → window). ───────────────────────────────
const um = addon.aw_ts_msg_0_P(view, __sel('undoManager'));
check('undoManager returns a real object', um !== 0n, String(um));
check(
  'the object really is an NSUndoManager',
  addon.className(addon.classOf(um)) === 'NSUndoManager',
  addon.className(addon.classOf(um)),
);

// ── A real undo/redo cycle through the fetched NSUndoManager, driving `allowsUndo`'s own
// documented mechanism — a real `insertText:replacementRange:` edit, not a bare `setString:` —
// so the automatic forward-AND-inverse registration `allowsUndo` promises (spec §9) covers
// BOTH canUndo/undo and canRedo/redo, exactly as `note-editor-k118`'s real typing will. ────────
const edit = 'hello-undo-redo';

check('canUndo is false before any edit', addon.aw_ts_msg_0_b(um, __sel('canUndo')) === false);

addon.aw_ts_msg_PG_v(view, __sel('insertText:replacementRange:'), __cfstr(edit), {
  location: 0,
  length: 0,
});
check('string() reflects the insert', utf8(addon.aw_ts_msg_0_P(view, __sel('string'))) === edit);
check('canUndo is true once allowsUndo has recorded the edit', addon.aw_ts_msg_0_b(um, __sel('canUndo')) === true);

addon.aw_ts_msg_0_v(um, __sel('undo'));
check('undo() reverts the insert', utf8(addon.aw_ts_msg_0_P(view, __sel('string'))) === '');
check(
  'canRedo is true — allowsUndo registered the redo automatically',
  addon.aw_ts_msg_0_b(um, __sel('canRedo')) === true,
);

addon.aw_ts_msg_0_v(um, __sel('redo'));
check('redo() re-applies the insert', utf8(addon.aw_ts_msg_0_P(view, __sel('string'))) === edit);

console.log(failures === 0 ? 'ALL PASS' : `${failures} FAILURE(S)`);
process.exit(failures === 0 ? 0 : 1);
