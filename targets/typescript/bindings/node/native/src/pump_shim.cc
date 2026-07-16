// pump_shim.cc — the V8-aware scoped pump body napi's public surface lacks (ADR-0056 finding A).
//
// A bare `uv_run(NOWAIT)` driven from a CFRunLoop callback (a) crashes in
// `node::Environment::CheckImmediate` (`v8::ToLocalChecked` on an empty `MaybeLocal`) the first
// time JS calls `setImmediate` — there is no active `v8::HandleScope` — and (b) never runs the V8
// microtask checkpoint, so `Promise`/`await`/`nextTick` chains stall. Node's own `SpinEventLoop`
// and Electron's `UvRunOnce` wrap `uv_run` in `HandleScope` + `Context::Scope` and force a
// microtask checkpoint; this reproduces that loop-iteration body. It is the crux of making the
// embedded pump preserve V8/Node semantics (the same for either ADR-0056 §2 mechanism).
//
// Ported from `targets/typescript/docs/research/2026-07-05-ts-runloop-integration-spike/addon/
// pump_shim.cc` (k6, first-hand-proven). Reusable native core (ADR-0060 §1): the shipped
// `bundle-typescript` launcher links this same primitive.
//
// The isolate is entered (`v8::Isolate::Scope`) on thread 0 by the embedder for the whole duration
// of `NSApplication.run()`, so `Isolate::GetCurrent()` / `GetCurrentContext()` resolve when this
// runs from the runloop source on thread 0 (the Electron model: keep the main isolate entered).
// V8/Node symbols resolve at link time against the embedded `libnode` (like the addon's dynamic
// lookup); we forward-declare the one libuv entry so libuv's C++-hostile headers stay off the path.

#include <node.h>
#include <v8.h>

extern "C" int uv_run(void* loop, int mode);
static const int AW_UV_RUN_NOWAIT = 2;

extern "C" {

// One non-blocking libuv iteration inside a proper V8 scope, then a microtask checkpoint.
// The `HandleScope` is REQUIRED (else `node::Environment::CheckImmediate` crashes on the first
// `setImmediate`). The checkpoint drains `Promise`/`await`/`process.nextTick` work — which, under
// the production entry architecture (native owns `main()`, no ambient blocking JS→native call),
// runs at a top-level callback scope and is NOT suppressed (contrast the k6 blocking-call harness).
void aw_rl_pump_v8(void* loop) {
  v8::Isolate* iso = v8::Isolate::GetCurrent();
  if (iso == nullptr) return;
  v8::HandleScope handle_scope(iso);
  v8::Local<v8::Context> ctx = iso->GetCurrentContext();
  if (ctx.IsEmpty()) return;
  v8::Context::Scope context_scope(ctx);
  uv_run(loop, AW_UV_RUN_NOWAIT);
  iso->PerformMicrotaskCheckpoint();
}

}  // extern "C"
