# Memory

## Circular dependencies broken via hooks
State-machine, event-dispatch, and DSL modules form cycles. Broken via
`set-modal-key-handler!`, `set-keyboard-hooks!`, `set-overlay-hooks!`,
`set-leader-hooks!`. One-way dependency: event-dispatch → state-machine.
Same pattern for chooser's `index-files-fn` hook (services → chooser).

## Config loader uses flat namespace
`make-base-namespace` + `namespace-set-variable-value!` for each DSL/service
binding, then `(parameterize ([current-namespace ns]) (load path))`. Sidesteps
Racket's module system. Config runs with full user privileges. User's
`config.scm` loads unchanged from the LispKit original.

## `send-keystroke` arg order mismatch
Config uses `(send-keystroke '(cmd) "t")` (modifiers first); FFI emitter uses
`(send-keystroke "t" numeric-flags)` (key first). `config-send-keystroke`
wrapper reorders args and calls `parse-modifier-symbols`.

## CGEvent callback must be at module top level
`function-ptr` created inside `start-keyboard-capture!` (called from
`applicationDidFinishLaunching:` — C-to-Racket reentry) produces an object the
CGEvent tap never invokes. Racket CS FFI limitation: callback allocation during
foreign reentry requires module-top-level placement.

## FFI pointers and GC: hold at module scope
`_cprocedure` callback proc and `function-ptr` pointer must be stored in
module-level variables. If only held locally, GC collects them and the C-side
callback becomes a dangling pointer.

## `coerce-arg` required for raw `tell`
Generated bindings return `objc-object` wrappers; raw `tell` expects `_id`
pointers. Use `(tell (coerce-arg obj) ...)` when mixing generated bindings with
raw `tell`. Missing coercion causes silent failures or arm64e PAC traps.

## KVC `forKey:` needs NSString, not C string
`forKey: #:type _string "key"` passes `char*` where `NSString*` is expected.
On arm64e this triggers a PAC trap. Use `forKey: (coerce-arg "key")`.

## AX constants are C macros, not symbols
`kAXWindowsAttribute` etc. are `CFSTR("AXWindows")` macros. Create at runtime
via `CFStringCreateWithCString`. AX functions live in HIServices; load it to
pull symbols into shared cache, then resolve via `(ffi-lib #f)`.

## CF Create/Copy rule requires caller CFRelease
`AXUIElementCopyAttributeValue`, `CGEventSourceCreate`, `AXValueCreate` etc.
follow the Create/Copy rule — caller must `CFRelease`. Use `dynamic-wind` for
exception-safe cleanup. `cfstring` creates new CFStrings — pre-allocate
constants for hot paths (e.g., `kAXMainAttribute`).

## `AXUIElementGetPid` uses Get-rule out-param
Takes `_int32` out-param, returns `AXError`. No CFTypeRef, no unwrap, no
ownership. Public symbol (unlike `_AXUIElementGetWindow`). Wrapper `ax-get-pid`
in `ffi/accessibility.rkt` guards `pid <= 0` → `#f`. Prefer over
workspace-based PID lookup when holding the owning element.

## Derive metadata from element, not workspace
If a function receives an AX element, extract owner/pid/title from it directly.
Do not query NSWorkspace for frontmost app — wrong for non-focused windows.
`save-window-frame!` and `restore-window` both use `ax-get-pid` on the window
they receive.

## Never use `hasheq` with dynamic string keys
`hasheq` uses `eq?` (identity). `string-downcase` and other ops create new
objects, so lookup fails. Use `hash` (`equal?`-based).

## `unless`/`when` are not early-return
Racket's `unless`/`when` are conditional expressions. Code after them always
executes. Use `cond` with exclusive branches for if/else-if flow.

## `system*`+`with-output-to-string` for bounded stdout
`(with-output-to-string (lambda () (system* path arg...)))` captures stdout
via `current-output-port`. No pipe management or drain-before-wait needed.
Use instead of manual `subprocess` for bounded-output one-shot commands
(e.g., `sw_vers`). See "Subprocess: drain pipes before wait" for the manual pattern.

## `struct-out` avoids struct accessor shadowing
Lambda names matching struct auto-accessors (e.g., `binding-key`) shadow the
accessors and cause infinite recursion. Use
`(provide (struct-out struct-name))` in the providing file; never redefine
struct field names as same-named lambdas in scope.

## Subprocess: drain pipes before wait
`subprocess-wait` before `port->string` deadlocks if the child fills the pipe
buffer (~64KB). Always drain stdout/stderr before `subprocess-wait`. Affects
`shell.rkt` and `app-scanner.rkt`.

## `racket/base` missing common utilities
`string-contains?` → `racket/string`. `port->string` → `racket/port`.
`uri-encode` → `net/uri-codec` (not `net/url-string`). `getpid` → `racket/os`.
`call-with-port` (R7RS) unavailable — use `dynamic-wind`. `check-true` requires
exactly `#t`; use `check-not-false` for truthy values.

## `dynamic-require` resolves against `current-directory`
Not against the calling module's directory. Test helpers must build absolute
paths via `(build-path (current-directory) "services" "shell.rkt")`.

## Generated binding workarounds
- `(tell NSMenuItem separatorItem)` returns raw `_id` cpointer that fails
  `nsmenu-add-item!`'s `objc-object?` contract. Use generated `nsmenuitem-separator-item`.
- `nsscreen.rkt` has duplicate definition preventing load. Use raw `tell`.
- `wkwebview-set-autoresizing-mask!` missing (inherited from NSView). Use
  direct `objc_msgSend`.
- NSStatusBarButton's `setImage:` inherited — use raw `tell` with `coerce-arg`.
- `make-nsrect` takes 4 flat args: `(make-nsrect x y w h)`, not point+size.
  Same for `make-nspoint`, `make-nssize`.
- `wkwebview.rkt` references unbound `_NSEdgeInsets`; anything transitively
  pulling WKWebView cannot load in isolation. Tests must use full app load path
  or stub. APIAnyware binding-generation bug.
- **Enum categories populated.** CG enum
  categories (`CGEventType`, `CGEventTapLocation`, `CGEventSourceStateID`,
  `CGEventField`, `CGWindowListOption`, etc.), AX enums (`AXError`,
  `AXValueType`), and CF enums (`CFStringBuiltInEncodings`, `CFNumberType`)
  all emit values. Modaliser imports 17 constants from generated `enums.rkt`.
  `kCGNullWindowID` stays local — CGWindowID typedef, not an enum.
- **Integer args may be widened to `_uint64`** — generator emits `_uint64` for
  some integer params (e.g., `CGEventTapCreate`'s first three, `AXValueCreate`,
  `CFNumberGetValue`). Zero-extension is lossless for small constants; matches
  Apple's wire encoding either way. Expect generated signatures to differ from
  hand-written `_uint32` params. Still affects `AXValueCreate`/`AXValueGetValue`
  and `CFNumberGetValue` — local overrides retained for these.
- **C bool returns use `_bool`.** Generator emits `_bool` for C bool returns
  (`AXIsProcessTrusted*`, `CFBooleanGetValue`, `CFStringGetCString`,
  `AXValueGetValue`). No `positive?` wrapper needed.
  Local overrides for `CFBooleanGetValue` and `CFStringGetCString` now match
  generated types exactly (retained for other param-type reasons).
- **`_id` partially replaced by `_uint64`** — generator emits `_uint64` for some
  formerly `_id` enum-typed params (e.g., `AXValueCreate`/`AXValueGetValue`).
  Still not correct type (`_uint32`) but functional. Local overrides retained.
- **`CFStringCreateWithCString` uses `_string`.** Generator emits `_string` for
  the C string param. Local override retained for consistency with other CF
  string functions.
- **`CFStringGetCStringPtr` generated contract rejects NULL** — generated
  contract says return must be `string?` but function legitimately returns NULL
  when internal encoding doesn't match. Local override uses `_pointer` return.
  `cfstring->string` handles the NULL → slow-path fallback.

## AX functions live in `applicationservices/`
`applicationservices/functions.rkt` contains the `AXIsProcessTrusted*`,
`AXUIElement*`, `AXValue*` family. The `accessibility/` framework dir covers
UIKit-style data APIs (charts, braille, math expressions) — two distinct symbol
sets with no naming collision.

## `function-ptr` satisfies `cpointer?` in generated contracts
`_cprocedure`/`function-ptr` callbacks pass generated-binding contracts without
unwrapping. Tap-style FFI (e.g., `CGEventTapCreate` callback param typed
`(or/c cpointer? #f)`) accepts `function-ptr` directly. No raw-symbol fallback
needed. Applies to any generated function taking a function-pointer arg.

## Migrating ffi/*.rkt to generated bindings
- `(only-in "../bindings/generated/oo/<framework>/functions.rkt" Func1 Func2 ...)`
  for C functions. `only-in` documents which generated names the file uses
  and stops `racket/contract` re-exports from leaking via the wholesale
  framework re-export.
- `(only-in "../bindings/generated/oo/<framework>/constants.rkt" kFoo)` for
  C globals (incl. CFStringRef constants like `kCFRunLoopCommonModes` —
  blocker for `_dispatch_main_q`: libdispatch header not in racket-oo input set,
  not a generator limitation).
- Local `define`s retained only for type-mismatch cases (see migration pattern
  notes). Enum categories are populated; use `(only-in ".../enums.rkt" ...)` for
  enum constants. Exception: `kCGNullWindowID` — CGWindowID typedef, stays local.
- Keep Racket-side mechanism (thunk registry, `_cprocedure` callback type,
  `function-ptr` GC-root variables) — these aren't FFI symbol lookups.
- Verify each migration with `dynamic-require` smoke load + the relevant
  per-module test + full `./tests/run-all.sh`. Load-time verification catches
  contract-vs-impl arity bugs.

Coverage: CGEvent functions ✓, CFRunLoop functions ✓, CFRelease ✓,
`kCFRunLoopCommonModes` global ✓, libdispatch + pthread ✓,
`_dispatch_main_q` struct global ✓, AX functions ✓ (`AXIsProcessTrusted*`,
`AXUIElement*`, `AXValue*`), `kAXTrustedCheckOptionPrompt` global ✓,
CF memory/collection/string functions ✓, CG window list ✓,
`kCFBooleanTrue`/`kCFBooleanFalse` ✓, `kCGWindowNumber`/`kCGWindowOwnerPID` ✓,
CG/AX/CF enum constants ✓ (17 values from generated `enums.rkt`).
All `ffi/*.rkt` fully migrated (no `ffi/unsafe`). Local definitions retained
only for type-mismatch C functions (see migration pattern notes).

## Struct-typed data symbols use `ffi-obj-ref`
Generator emits `(ffi-obj-ref 'foo _fw-lib)` for struct-typed globals
(e.g., `_dispatch_main_q`, `_dispatch_data_empty`,
`_dispatch_queue_attr_concurrent`, `_dispatch_source_type_*`). Verified:
generated address matches dlsym. `ffi/main-thread.rkt` migrated with zero
workarounds.

## Dispatch queue params are `_pointer`, not `_id`
`dispatch_async_f`, `dispatch_after_f` queue params are typed `_pointer`.
Generated `_dispatch_main_q` (cpointer/ffi-obj from `ffi-obj-ref`) accepted
directly without cast.

## `ffi-obj-ref` vs `get-ffi-obj` for data symbols
`get-ffi-obj` wraps the raw symbol address with type conversion — for
`_pointer`, it dereferences once. `ffi-obj-ref` returns the symbol's
address directly (equivalent to `dlsym`), no dereferencing. Use
`ffi-obj-ref` whenever you want `&symbol` rather than `*symbol`. Returns
a `#<cpointer/ffi-obj>`-tagged pointer; cast via `_pointer` or `_id` to
strip the tag for ObjC consumers.

## Swift stub launcher for TCC independence
~15-line Swift stub compiled via `swiftc -O`, `execv`s into
`/opt/homebrew/bin/racket`. Unique CDHash gives independent macOS TCC
permissions (accessibility, screen capture). Uses `racket` (not `gracket`)
since main.rkt creates NSApplication via FFI. "Modaliser Dev" certificate
preserves TCC across rebuilds. Ad-hoc codesigning changes CDHash on every
rebuild; existing TCC grants silently become invalid — use a stable signing
identity. SSH direct invocation (e.g., `Contents/MacOS/Modaliser`) bypasses
launchservicesd and creates TCC entries attributed to the launcher, not the
`.app`; use `open Modaliser.app` for correct TCC attribution.

## Bundle symlinks are machine-specific; distributable needs rpath
Source files copied into `Contents/Resources/racket-app/`. Bindings use absolute
symlinks to `APIAnyware-MacOS/generation/targets/racket-oo/`. Tied to this
machine's layout. Distributable version needs copied bindings and fixed dylib
`@rpath`. Proper bundling belongs in APIAnyware-MacOS.

## Main-thread dispatch via GCD
`ffi/main-thread.rkt` provides `call-on-main-thread` (async) and
`call-on-main-thread-after` (delayed) via `dispatch_async_f` /
`dispatch_after_f` + `dispatch_time`. Main queue via generated
`_dispatch_main_q` from `libdispatch/constants.rkt` (uses `ffi-obj-ref`
for correct symbol-address semantics). Thunk registry maps integer IDs →
closures, passes ID as `void *context`. Module-level `function-ptr` +
`_cprocedure` proc for GC stability.

## Green threads dead under `nsapplication-run`
`(thread ...)`, `(sleep ...)`, `(sync ...)`, `(sync/timeout ...)`,
`(thread-wait ...)`, `(semaphore-wait ...)` — any form depending on the Racket
scheduler — never fire when the Cocoa run loop blocks the place main thread.
Failure mode is silent no-op.

**Sanctioned concurrency primitives:**
- `after-delay` in `core/state-machine.rkt`
- `call-on-main-thread[-after]` in `ffi/main-thread.rkt` (GCD-backed)
- Shell-level timeout watcher in `services/shell.rkt`
- Async generation counter pattern for race-free async continuations
- Places + `place-channel-try-get` for off-main-thread network/subprocess
  (see "Places for I/O off the main thread")
- `ffi/unsafe/os-thread` for pure computation only (see that entry)

No known offenders remain in `core/`, `services/`, `ui/`, `lib/`, `ffi/`,
or `main.rkt`.

**Source guard:** `tests/source-guards.rkt` provides `check-source-tree`
(API: `roots #:allow allow-list`) — walks source tree and asserts no forbidden
scheduler forms. Regex: open paren before name + whitespace after; string
literals and comment lines don't trip. Entry point `tests/test-source-guards.rkt`
runs top-level (not in `test-case`) — violations exit non-zero. All violations
collected before raising.

Allowlist: per-(file, form) pairs — one exemption never masks others in the
same file. Each entry documented with rationale. Current:
`lib/place-channel-utils.rkt` → `sync/timeout` (non-blocking place-channel
try-receive); `main.rkt` → `semaphore-wait` (reachable only under
`MODALISER_TEST_BLOCK`, never under Cocoa loop).

**Shell-level timeout uses process-group kill:**
```
{ sleep "$1" && kill -KILL -$$ 2>/dev/null ; } >/dev/null 2>&1 &
exec /bin/zsh -c "$2"
```
Command passed via argv (`$2`) to avoid quoting. `subprocess-group-enabled #t`
wraps all three `subprocess` call sites in `services/shell.rkt` (sync,
async-no-timeout, async-with-timeout) — missing it breaks pipeline kill.
`kill -KILL -$$` kills all process group children; exit code 137 signals
timeout. See "zsh compound-command backgrounding requires explicit braces".

## Racket CS converts SIGINT to `exn:break`
C `signal()` via FFI cannot override Racket CS's SIGINT bridge — the runtime
converts OS signals to `exn:break` before user code runs. Shutdown handling
belongs in `uncaught-exception-handler` with `exn:break?` dispatch. Raw
`signal(2)` FFI approach silently fails.

## `MODALISER_TEST_BLOCK` gates Cocoa paths in `main.rkt`
When set, `main.rkt` skips Cocoa-dependent code (semaphore-wait, NSApp startup).
Integration tests exercise headless shutdown paths without Cocoa. Source-guard
allowlist exempts `main.rkt` → `semaphore-wait` on this basis.

## `_cprocedure` unsafe from foreign OS threads
A `_cprocedure` callback without `#:async-apply` crashes with SIGILL when
invoked from an OS thread Racket didn't create. GCD global queue with
`dispatch-callback-fptr` produces instant `exit 132` — runtime requires
registered threads.

`#:async-apply` queues to the Racket main thread stuck in `nsapplication-run`
— the queue never drains under the Cocoa loop. Deadlock.

`ffi/cgevent.rkt`'s tap callback is **not** proof that foreign threads work —
installed via `CFRunLoopGetMain`/`CFRunLoopAddSource`, fires on the main OS
thread. No true foreign-thread `_cprocedure` exists in this project.

**Implication:** GCD worker queues cannot host `_cprocedure` callbacks.
`call-on-main-thread[-after]` is the only safe GCD destination. For
off-main-thread work use `ffi/unsafe/os-thread` (pure Racket) or
`dynamic-place` (full VM, safe for I/O).

## `ffi/unsafe/os-thread`: pure Racket only
Racket CS provides `call-in-os-thread`, `os-thread-enabled?`,
`make-os-semaphore`/`os-semaphore-post`/`os-semaphore-wait`. Returns `#t` on
this macOS build. `os-semaphore-*` are real cross-OS-thread semaphores
independent of the Racket scheduler.

**Safe:** pure computation, allocation, closures, list/hash ops, file I/O
(`open-input-file`, `read-string`, `read-line`, `close-input-port`),
`parameterize`.

**Segfaults:** `tcp-connect`, `subprocess`/`system`, anything using Racket's
place scheduler I/O event pump. `net/url` uses TCP, transitively unsafe.

Use for CPU-bound work (fuzzy matching, serialization). For network/subprocess,
use places.

## Places for I/O off the main thread
`dynamic-place module-path start-fn-sym` spawns a separate Racket VM on its own
OS thread with its own scheduler. `net/url`, `tcp-connect`, `subprocess` all
work correctly.

**Place-channel semantics:**
- `place-channel-put` — fully buffered sender-side. 5 puts against busy worker
  all return in 0 ms. Main thread never blocks.
- `place-channel-get` — blocking; fatal on main thread under
  `nsapplication-run`.
- `place-channel-try-get` — `sync/timeout 0 place-chan`, non-blocking. Wrapped
  in `lib/place-channel-utils.rkt` (source-guard allowlist entry).

**Message constraints:** place-message-allowed only (numbers, booleans, symbols,
strings, byte-strings, lists, vectors, hashes of these). No closures — pass
data, not code.

**Worker layout:** place body in standalone `.rkt` file (not submod). Path via
`define-runtime-path` for relocatable resolution.

First use: `services/http-worker.rkt` + `services/http.rkt`.

## Async HTTP via place + main-thread polling
`services/http.rkt` facades a long-lived `services/http-worker.rkt` place:

- `ensure-worker-started!` spawns lazily on first `http-get`. Startup ~100 ms,
  paid once.
- `http-get url callback` allocates monotonic id, stores callback in
  `pending-callbacks` (hasheqv), sends `(list id url)` to worker, calls
  `ensure-poll-scheduled!`.
- `ensure-poll-scheduled!` schedules one
  `call-on-main-thread-after 0.05 drain-and-maybe-reschedule!` tick, guarded
  so only one is in flight.
- `drain-and-maybe-reschedule!` drains via `place-channel-try-get`, routes
  `(id . body)` to callback (inside `with-handlers`), reschedules if pending
  hash non-empty.
- Staleness is caller's concern. `web-search-handler` uses its own
  `current-search-query` box; `http.rkt` eventually delivers every registered
  callback.

Main thread never blocked: every step is non-blocking put or bounded (~1 ms)
drain tick. Multiple concurrent requests share one poll loop.

**Testing without Cocoa loop:** `call-on-main-thread-after` ticks don't fire
without a Cocoa/Foundation run loop. Test hook `(submod "services/http.rkt"
test-hooks)` exports `drain-all-ready-responses!` and `pending-request-count`
for manual drain in a bounded poll loop. GCD path covered by
`test-integration-keyboard-capture.rkt` under real NSApp loop.

## `after-delay` hookable for headless testing
`set-after-delay-handler!` in `core/state-machine.rkt` replaces the
`call-on-main-thread-after`-backed implementation with a test-supplied function.
Default handler unchanged — production behavior identical.
`modal-show-overlay-delayed` and the modal safety watchdog dispatch through
`after-delay`.

Recording pattern (`test-integration-overlay.rkt`): list-based handler
`cons`ing `(seconds . thunk)` pairs; filter by delay threshold to separate
sub-second show callback from 5 s watchdog. Verifies schedule and
generation-counter staleness without a Cocoa run loop.

## ObjC delegate callbacks need error handling
`make-delegate` and dynamic-subclass callbacks lack exception handling by
default — unhandled error crashes with no Racket stack trace. Wrap at the
delegate boundary (C→Racket reentry) with `(with-handlers ([exn:fail?
(lambda (e) (eprintf "…" (exn-message e)))]) ...)`, regardless of inner
handlers.

**Guarded sites:**
- `core/state-machine.rkt` — no delegates (state mutation only)
- `ffi/cgevent.rkt` `tap-callback-proc` — CGEvent tap
- `ffi/main-thread.rkt` `dispatch-callback-proc` — GCD trampoline
- `ui/panel-manager.rkt` `dispatch-script-message` — WKScriptMessageHandler
  (panel-manager delegate one-liner calls this, so guard in callee suffices)
- `ui/panel-manager.rkt` `windowDidResignKey:` resign-delegate — wrapped at
  lambda body
- `main.rkt` `applicationDidFinishLaunching:`/`applicationWillTerminate:` —
  both wrapped
- `services/lifecycle.rkt` `settingsClicked:`/`relaunchClicked:`/
  `quitClicked:` — all wrapped

**Exempt:** `ui/panel-manager.rkt` `returns-yes-proc` (IMP for
`ModaliserKeyablePanel.canBecomeKeyWindow`/`canBecomeMainWindow`) — literal
`(lambda (self sel) #t)`, cannot throw.

No helper abstraction — inline form is house style. Six sites not enough to
justify factoring.

## `module+ test-hooks` exposes module internals
`(module+ test-hooks (provide current-status-item current-menu-handler))` in
`services/lifecycle.rkt`. Integration tests `dynamic-require` the
`test-hooks` submodule to read module-level state that has no public API.
Pattern keeps production API clean while allowing white-box assertion.
Used by `test-integration-status-bar.rkt` to verify menu structure after
`setup-status-bar!`.

## Test suite runner: `tests/run-all.sh`
Walks every `tests/test-*.rkt`, runs each under
`timeout -k 1 ${TIMEOUT:-90}`. Requires GNU coreutils `timeout`. Outcomes:
`[OK]`/`[FAIL]`/`[SILENT]`/`[TIMEOUT]`; exits non-zero on any non-OK.
`test-lifecycle-events.rkt` cold-loads `main.rkt` per subprocess (~50 s total);
TIMEOUT must be ≥90 s. Other slow loads: `ui/overlay.rkt` and `ui/chooser.rkt`
(7–8 s each, transitively pulling `panel-manager.rkt` → `nspanel.rkt`).

No env-gate or skip list — every file runs, including all integration tests.
`test-integration-keyboard-capture.rkt` auto-terminates (see
"Auto-terminating Cocoa-loop test pattern").

**Silent-failure backstop:** rackunit `check-*` exit 0 on failure (see that
entry). Runner greps output for `^FAILURE$` or `^name:[ \t]+check-`; any
hit → `[SILENT]` even when rc=0.

**Precondition pattern:** setup checks (accessibility permission, CGEvent tap,
NSApplication startup) use `(unless precondition (eprintf "...") (exit 1))`
not `check-true`. Precondition failures are setup issues, not test failures.
`exit` is not caught by `exn:fail?` handlers, so even inside delegate bodies
it terminates immediately. Converted: `test-window-manager.rkt`,
`test-integration-modal.rkt`, `test-integration-services.rkt`,
`test-integration-window.rkt`, `test-integration-keyboard-capture.rkt`,
`test-config-loading.rkt`.

Runner is structural backstop: future hangs → `[TIMEOUT]`, future silent
`check-*` failures → `[SILENT]`. No silent failure modes remain.

## Auto-terminating Cocoa-loop test pattern
Tests entering `nsapplication-run` (CGEvent tap, delegate reentry, full
lifecycle) must self-terminate. Pattern from
`tests/test-integration-keyboard-capture.rkt`:

1. `applicationDidFinishLaunching:` body first schedules safety-net:
   `(call-on-main-thread-after 5.0 (lambda () (eprintf "...") (exit 1)))`.
   Must precede any assertion — delegate `with-handlers` swallows exceptions,
   so without safety net a failed assertion leaves the loop spinning.
2. Run assertions inside existing `with-handlers` boundary.
3. Schedule normal-path exit:
   `(call-on-main-thread-after 0.5 (lambda () ... (exit 0)))`.
4. File ends with `(nsapplication-run app)`.

Outcomes: assertions pass → `(exit 0)` → `[OK]`. Assertion raises (caught) →
safety net fires → `(exit 1)` → `[FAIL]`. Genuine hang → runner's
`timeout -k 1 30` → `[TIMEOUT]`.

## Integration tests must not mutate shared state
Integration tests wiring command handlers for side-effecting operations must
use stub lambdas that only log/record. To verify a function is callable, use
`dynamic-require` smoke load (see "Verify bindings by loading, not grepping").
The test runner has no backstop for external side effects — only the test
author guards against this.

Read-only integration (e.g., `list-windows`, `focused-app-bundle-id`,
`start-window-cache!`) is fine: enumeration queries have no observable side
effects.

## CGEvents only capture physical keyboard input
`CGEventTapCreate` captures hardware keyboard events only. Programmatic input
(Bash, `subprocess`, `system`) does not produce CGEvents. Testing the event tap
requires physical key presses.

## `make-objc-block` cannot accept `#f`
Passing `#f` (intending nil) creates a block calling `(apply #f ...)` on
invocation. Pass a no-op lambda for optional completion handlers. APIAnyware
bug in `runtime/block.rkt`.

## Overlay and chooser panels working
Overlay: panel creates, HTML loads, resize messages handled, updates on group
navigation. GCD timer for delay, `coerce-arg` on WKScriptMessage body, no-op
completion handler. Chooser: keyboard input, dismisses on ESC and click-outside
via `windowDidResignKey:` delegate. Requires KeyablePanel (see "Borderless
NSPanel needs KeyablePanel").

## MRU store for chooser
`lib/mru-store.rkt` persists per-selector MRU lists to
`~/.config/modaliser/mru.dat` via `write-to-file`/`file->value`. Hash keyed by
`remember-key` → ordered list of id values (most recent first, cap 50).
`mru-load!` called at startup before `load-config!`. `open-chooser` reorders
items when selector has both `'remember` and `'id-field`.
`chooser-record-mru!` records *before* `close-chooser` clears the selector
node.

## Config DSL keys are strings; alists use symbols
`config.scm` passes `'id-field "bundleId"` (string); services return alists
with symbol keys (`'bundleId`). `(assoc "bundleId" item)` fails — `equal?` on
string vs symbol is `#f`. Every config/service bridge must coerce via
`string->symbol`. Known crossings: `find-installed-apps` translates
`'name`/`'bundle-id` → `'text`/`'bundleId`; `open-chooser` and
`chooser-record-mru!` coerce the id-field before `assoc`.

## Async generation counter pattern
Each new operation increments a generation counter; continuations check equality
before committing. Two variants:
- **Background + main dispatch (double-check):** background thread checks gen
  before dispatching; main thread checks again. Used by chooser/web search.
- **Delayed main dispatch (capture-at-schedule):** continuation captures gen at
  schedule time, bails if bumped. Used by overlay delay timer and
  `restore-window`.

Window-manager keys per-window via `window-cache-key` (`pid:title`);
`bump-window-generation!` called at top of every save/restore.

## App scanner: batch mdls for performance
Single `mdfind -0 | xargs -0 mdls` pipeline instead of per-app `defaults read`.
~670 apps in ~550 ms vs ~6 s. Internal format: `'name`/`'bundle-id` (kebab);
config expects `'text`/`'bundleId` (camelCase). `find-installed-apps` translates.

## `focus-window` needs three AX attributes
Must set `kAXMain`, `kAXFocused`, and `kAXRaise` for multi-window apps to
correctly switch to the target window.

## Cocoa coordinates: origin at bottom-left
Panel resize keeping top edge fixed requires adjusting `origin.y` by height
delta. `screen-containing-ax-point` converts each screen frame to AX coords
before comparing — more correct than mixing coordinate systems on multi-screen.

## Borderless NSPanel needs KeyablePanel
Default borderless NSPanel returns NO for `canBecomeKeyWindow`. WKWebView
`<input autofocus>` never receives focus, keydown/ESC never fire in JS.
Fix: `ModaliserKeyablePanel` — dynamic ObjC subclass via `make-dynamic-subclass`
(see "Dynamic ObjC class creation uses `make-dynamic-subclass`"), overriding
`canBecomeKeyWindow`/`canBecomeMainWindow` to return YES. Activating panels use
KeyablePanel; non-activating (overlay) use plain NSPanel.

## Dynamic ObjC class creation uses `make-dynamic-subclass`
`make-dynamic-subclass` from `bindings/runtime/dynamic-class.rkt` wraps
`objc_allocateClassPair`/`class_addMethod`/`objc_registerClassPair`. Store
the IMP `function-ptr` at module scope for GC stability (see "FFI pointers
and GC: hold at module scope"). `coerce-arg` the result for alloc/init chains
via `tell`. Used for `ModaliserKeyablePanel` in `ui/panel-manager.rkt`.

## Panel delegate cleanup on close
`close-panel!` must call `(tell panel setDelegate: #f)` before
`nspanel-order-out!`/`nspanel-close!`. Otherwise `windowDidResignKey:` fires
spuriously on programmatic close, triggering redundant cancel/close cycle.

## `make-nsmenuitem` action param takes selector name string
`make-nsmenuitem-init-with-title-action-key-equivalent` expects a `string?`
for the `action` param and calls `sel_registerName` internally. Passing a
cpointer from `(sel_registerName "foo:")` fails the contract. Pass the raw
selector name, e.g., `"settingsClicked:"`.

## `wkscriptmessage-body` requires `objc-object?`
The raw `WKScriptMessage` cpointer from the delegate callback fails
`wkscriptmessage-body`'s contract. Wrap with `(borrow-objc-object ptr)` before
passing to any generated WKWebView binding that expects `objc-object?`.

## Generated binding contracts are shallow
APIAnyware emits `provide/contract` on wrappers, functions, and constants
(requires renaming `racket/contract`'s `->` to avoid `ffi/unsafe` collision).
Contracts are effectively `any/c` — no SEL or receiver-class checks. Do not
catch wrong receiver, unwrapped `objc-object` vs `_id`, missing coercion, or
PAC-trapping `char*`-for-NSString.

## rackunit `check-*` forms exit 0 on failure
`check-false`, `check-true`, etc. — including inside `test-case` — report
failures but do not affect process exit code. For guardrails requiring non-zero
exit on failure, use `error` or `raise`.

## Verify bindings by loading, not grepping
Text grep misses load-time errors: name collisions, require conflicts, missing
exports, void-return contract blame. Use
`racket -e '(dynamic-require "…/nsapplication.rkt" #f)'` as sanity check.
Known failures: `->` collision between `ffi/unsafe` and `racket/contract`,
missing class-name re-export from `provide/contract`, `void?` return-contract
mismatch on raw-`tell` property setters.

## Racket `malloc` is GC-managed — never call `free`
Racket CS's `(malloc n)` / `(malloc type)` allocates from GC-tracked memory
(internally `scheme_malloc_atomic`). Calling `(free ptr)` on such memory
invokes C's `free()` on a non-heap pointer → SIGABRT (exit 134). Correct
patterns: (1) let GC reclaim (no explicit free), (2) use `(malloc n 'raw)`
for C-heap allocation if `free` is needed. Modaliser's own code never calls
`free`; upstream `cf-bridge.rkt`, `ax-helpers.rkt`, and `spi-helpers.rkt` all
had this bug — all fixed.

## FFI migration to upstream runtime helpers — complete
All app-layer code (ffi/, services/, ui/, tests/, main.rkt) is `ffi/unsafe`-free. Every former blocker resolved:
- `tell`/`import-class`/`sel_registerName`/`_cprocedure`/`function-ptr`
  re-exported from `bindings/runtime/objc-interop.rkt`.
- AX attribute access via `ax-helpers.rkt` typed wrappers
  (`ax-get-attribute/{raw,array,string,boolean,point,size}`, `ax-set-position!`,
  `ax-set-size!`, `ax-get-pid`) — no local `malloc`/`ptr-ref` out-param overrides.
- `ffi/main-thread.rkt` → thin re-export of `bindings/runtime/main-thread.rkt`.
- `ffi/permissions.rkt` → `make-cfdictionary`/`cf-release` from `cf-bridge.rkt`.
- `ffi/accessibility.rkt` → CF helpers from `cf-bridge.rkt` (renamed on import:
  `racket-string->cfstring` as `cfstring`, `cfstring->racket-string` as
  `cfstring->string`, `cf-release` as `cf-release!`, `cfnumber->integer` as
  `cfnumber->int`).
- `ui/panel-manager.rkt` → `make-dynamic-subclass` from `dynamic-class.rkt`
  replaces raw `objc_allocateClassPair`/`class_addMethod`/`objc_registerClassPair`.
- `services/*.rkt`, `main.rkt`, integration tests → `objc-interop.rkt` for ObjC.
Local definitions retained only for type-mismatch C functions (see migration pattern notes).

## `kAXFullScreenAttribute` not in generated constants
Only `kAXFullScreenButtonAttribute` and `kAXFullScreenButtonSubrole` are
generated. The `AXFullScreen` attribute must be created at runtime via
`racket-string->cfstring "AXFullScreen"`. All other kAX* attributes used
by Modaliser are present in generated `applicationservices/constants.rkt`.

## zsh compound-command backgrounding requires explicit braces
`cmd && cmd2 &` is NOT `(cmd && cmd2) &` in zsh: `&` binds only to `cmd2`,
leaving `cmd` in the foreground. Use `{ cmd && cmd2 ; } &` to background the
entire compound. Diverges from bash. Relevant to shell-level timeout (see
"Shell-level timeout uses process-group kill").

## GUI-dependent Racket in VM requires `open <bundle>`
SSH-direct `racket main.rkt` fails for GUI-dependent code paths — WKWebView
bindings raise a `wkscriptmessage-body` contract error without an Aqua
session. Only `.app` + `open <bundle>.app` works. Applies to any code
transitively pulling `panel-manager.rkt` or WKWebView bindings.

## Strip `compiled/*.zo` on binding changes or transfer
Host-compiled `.zo` files under `compiled/` subdirs are machine-specific
(arch + Racket version). Two trigger cases: (1) transferring a source tree to
another machine — runtime loads stale linklets and fails; (2) regenerating
APIAnyware bindings locally — Racket loads old bytecode mismatched to the new
generated source. `bundle/build.sh` strips `compiled/` dirs after source copy;
clear manually in either case before running.

## `launchctl asuser 501` places SSH process in Aqua session
SSH-launched processes inherit the SSH responsibility chain, bypassing the
Aqua login session. `launchctl asuser 501 <cmd>` places the process in
the GUI session of UID 501, enabling CGEvent tap, TCC-gated APIs, and
status-bar rendering without `open`.

## Modaliser-Spec is at `spec/` in Modaliser-Racket
Automated cross-implementation VM verification suite for every Modaliser
feature. Design doc: `docs/superpowers/specs/2026-04-18-modaliser-spec-design.md`.
Implementation plan at `docs/superpowers/plans/2026-04-18-modaliser-spec-v1.md`
(26 tasks); Tasks 1–24 complete; Tasks 25–26 queued; next is Task 25
(.gitignore audit — likely verify-only). 12 registered scenarios across
modal/, choosers/, launch/, windows/. Task 26 live-VM shake-down gated on
TestAnyware Task 8 and spec-v1-log-tailer.

## Modaliser single-instance lock is `~/.config/modaliser/.lock`
`main.rkt:44-45` writes the lock to `~/.config/modaliser/.lock`. Spec
scenario `lifecycle/03-single-instance.rkt` uses this path for pid-stability
checks.

## Modaliser-Spec verification is three-tiered
Unit tests with mock drivers → null-impl meaningful-failure smoke tests →
live-VM. Extended F-keys (VNC F13–F19) gate only the live-VM tier (Task 26
Step 6); all upstream tasks execute independently.

## `#lang modaliser-spec` registered via `current-library-collection-paths`
Push approach: no global `raco pkg install`. Keeps `spec/` self-contained
and extraction-ready for future packaging.

## Modaliser-Spec scenarios use `#lang modaliser-spec`
Each scenario is a Racket source file, not YAML/data. Located under
`spec/scenarios/`. Layout uses mechanical extraction from Modaliser-Racket source.

## Structured event logging via `lib/events.rkt`
Format: `[<module>] <event> <k>=<v>…`. No-op before `init-event-log!`; swallows
filesystem errors after init. String values quoted; symbol values bare when all
chars are letter/digit/dash/underscore. Spec log regexes must include literal
quotes for string values (e.g., `tree="global"` not `tree=global`).
Wired in 7 modules: main.rkt (lifecycle), config-loader.rkt (config),
state-machine.rkt (modal/group/exit + watchdog reason),
chooser.rkt (open/push/close + reason), mru-store.rkt (record),
window-manager.rkt (focus), util.rkt (launch variants).
Chooser open-selector log reason is the `'prompt` alist field value, not the
selector label text. Gaps: shutdown signal/error paths; implicit focus in
`activate-app!`; window move events (`impl-window-move-logging-gap` task open).

## `MODALISER_CONFIG` env-var overrides config path
`lib/config-loader.rkt` reads `MODALISER_CONFIG` env-var and uses it as the
config file path when set, bypassing the default `~/.config/modaliser/config.scm`.
Useful for running against a test config without touching the live config.

## `register-tree!` stores `'scope` on root node
The root node of a registered tree carries a `'scope` key so `modal-enter` can
recover the tree name for event emission. Avoids altering `modal-enter`'s call
signature or breaking existing tests.

## `setup-dev-cert.sh` creates idempotent Modaliser Dev cert
`bundle/setup-dev-cert.sh` creates a self-signed "Modaliser Dev" certificate in
the login keychain for stable codesigning. Idempotent: exits 0 if the cert exists
unless `--force` is passed. Prompts once for login password; sets
`set-key-partition-list` so subsequent `codesign` runs are non-interactive.
Complements the TCC-stability requirement (see "Swift stub launcher for TCC
independence").

