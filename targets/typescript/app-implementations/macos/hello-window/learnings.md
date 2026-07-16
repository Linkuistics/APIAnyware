# hello-window — learnings (Node TypeScript target, ladder app 1/7)

The first real GUI app on the Node TypeScript target. True to its forcing-function role, it
surfaced one runtime gap (fixed), one genuine JS-language-shape constraint no prior target hit,
and a distribution-scope finding for Step 8. Every one of these is reusable machinery, not a
one-off workaround — the remaining six ladder rungs inherit it as-is.

## Runtime gap fixed here: `__alloc` — `+alloc` is not emitted per class

ADR-0055 §6 promises "faithful alloc/init", and `lifetime.ts`'s own `NSObject` constructor doc
already says "the public creation path is alloc/init" — but no emitted class actually carried a
`static alloc()` **except `NSProxy`** (a root class with no ObjC `NSObject` to inherit `alloc`
from, so the emitter special-cases it). Every other class's own `init…` instance method (e.g.
`NSWindow.initWithContentRect_styleMask_backing_defer_`) assumes its receiver is already an
alloc'd-but-uninitialized instance — with no way to produce one, hello-window's window/menu/label
construction had no idiomatic call path at all.

Fixed as a **shared runtime primitive**, not a generated one: `+alloc`'s ABI is always
`Class -> id` regardless of the receiver (`aw_ts_msg_0_P`, already a fixed dispatch entry), so
`__alloc<T>(cls)` (`classes.ts`, exported from the barrel) is the ONE place this is derived —
`__wrapOwned(cls, __dispatch.aw_ts_msg_0_P(__classArg(cls), __sel('alloc')))!`. A generated
per-class `static alloc()` would have been the wrong fix: it would just be `__alloc` copy-pasted
206+ times (once per bound class), the exact "one decision, N readers" violation this codebase's
own history (k57/k66/k76/k87/k90/k92/k99) keeps calling out on other axes. Covered by a new
`classes.test.ts` case; the whole runtime suite (118 tests) still passes.

## Language-shape finding: a two-file split, forced by ES module static-import evaluation order

`app.ts` cannot be the module the native launcher's boot script directly imports. An ES module's
static `import` declarations evaluate before anything else in the importing file runs — so a
top-level `import { NSWindow } from '@apianyware/appkit'` would execute `NSWindow`'s own
`static { __registerClass(...) }` / `static __cls = __class(...)` the INSTANT the module loads,
which is before any code that could call `__installDispatch` first. Every prior inbound/outbound
integration test (`test/*.mjs`) sidesteps this by using the raw addon primitives directly
(`addon.aw_ts_msg_0_P(...)`) rather than a generated class — hello-window is the first thing in
this target to actually **import a generated framework class into a real entry point**, so it is
the first thing that hits this ordering constraint.

Fixed with a two-file split, not a language workaround: `bootstrap.cjs` installs the dispatch
backend (and, generally, `__ensureInbound()` for anything with a delegate/subclass/callback —
hello-window needs neither), THEN dynamically `import()`s `app.js` — by which point every
generated class's static initializer runs against a live backend. Every later ladder rung needing
inbound machinery reuses this same two-file shape (install first, dynamic-import the real app
module second); it is not a hello-window-specific quirk.

## Language-shape finding: the embedder's `LoadEnvironment` boot script needs a real CJS referrer

A first attempt made `bootstrap.mjs` (an ES module) the direct target of the embedder's inline
boot-script `import()` call. This failed with `ERR_UNKNOWN_BUILTIN_MODULE` — the boot string
passed straight to `node::LoadEnvironment` has no resolvable module referrer of its own, so its
*first* dynamic import falls through to a builtin-module resolution path meant for internal use.
The k42 test harness's own `app.cjs` never hit this because it is `require()`'d (a real CJS file,
hence a real referrer) rather than `import()`'d directly from the boot string. Fixed by renaming
`bootstrap.mjs` → `bootstrap.cjs` (CommonJS, `require()`'d from the boot string, exactly the
harness's own shape) with an async IIFE inside doing the ESM-only steps (`register()`,
`await import(...)`) — not by changing the embedder setup itself. Every later rung's boot script
should stay CJS for the same reason.

## Distribution finding for Step 8: this Homebrew Node build is NOT minimally-linked

ADR-0060 §2 assumed Node's `--shared` build "statically links V8 + ICU into `libnode`, so its
`otool -L` shows only system libraries → minimal transitive vendoring." Measured directly against
the actual installed Homebrew `node@26` on this host: `libnode.147.dylib` dynamically links **18**
other Homebrew-built dylibs (ICU ×2, brotli ×2, c-ares, hdr-histogram, llhttp, ada-url, simdjson,
simdutf, nghttp2/nghttp3/ngtcp2, sqlite, libffi, uvwasi, zstd, a merve/nbytes pair), two of which
(`libicudata`/`libbrotlicommon`) are reached only via `@loader_path`/`@rpath` and so do not even
show up in a naive absolute-path `otool -L` scan of the top-level binary — the full transitive
closure (computed recursively, not just one level) is **23 dylibs**. VM-verification here vendored
all 23 onto the guest at their exact absolute Homebrew paths (~91 MB, no Mach-O relocation needed
— literally the same absolute paths the launcher's load commands already reference) rather than
install Homebrew in the VM. **This is a real correction Step 8 needs, not a dev-loop-only
workaround**: `bundle-typescript`'s "vendor `libnode` + relocate via `@rpath`" plan (ADR-0060 §5)
must vendor this whole closure, not just `libnode` itself, or the shipped `.app` will fail to
launch on a vanilla machine exactly the way the unmodified launcher failed on a vanilla VM here
(`dyld: Library not loaded: @loader_path/libicudata.78.dylib`).

## Findings for later rungs

- **`window.center()` centres horizontally exactly; vertical placement is AppKit's own "pleasing"
  convention, not true vertical center** — measured x=760 (exact `(1920−400)/2`), y=215 (not the
  arithmetic center). Not a bug; don't assert exact vertical center in a later rung's own report.
- **The app menu's bold name slot falls back to the process name (`hello-window-launcher`)
  without a `CFBundleName`** — expected pre-Step-8 (same racket/chez/sbcl finding: "Bold app-name
  slot in the menu bar comes from CFBundleName when launched as a `.app` bundle"). A later rung
  does not need to re-discover this.
- **A TestAnyware golden-image quirk, not an app defect:** Notification Center panels
  intermittently claim frontmost-app status between interactions, so a later rung's own Cmd-Q /
  menu-interaction check should explicitly re-focus the target window (`agent window-focus` and/or
  a direct click on the title bar) immediately before the interaction, not just once at the start
  of the session.
- **The `AW_HELLO_SMOKE` construction pre-flight only proves construction, not display** — the
  same posture other targets already established (`sbcl`'s `AW_HELLO_SMOKE`/`run.lisp`
  convention). A later rung with more surface (controls, callbacks) should keep this gate and
  extend the diagnostic read it performs rather than skip straight to the VM.
- **Every `.node`-loading integration test in `native/test/` and the native README's own examples
  still use raw addon primitives, not generated classes** — hello-window is the first thing to
  idiomatically construct a generated class end-to-end. A later rung hitting a construction gap
  the raw-primitive tests never would have surfaced (like `__alloc` here) should suspect the same
  root cause: something only a *generated-class* call path exercises.
