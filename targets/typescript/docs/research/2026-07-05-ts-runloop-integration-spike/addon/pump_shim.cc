// pump_shim.cc — THROWAWAY spike: the v8-aware pump primitives napi's public surface lacks.
//
// A bare uv_run(NOWAIT) driven from a CFRunLoop callback (a) crashes in CheckImmediate without a
// v8::HandleScope, and (b) never runs the V8 microtask checkpoint / node nextTick drain, so
// Promise/await/nextTick chains stall. Node's own SpinEventLoop and Electron's UvRunOnce wrap
// uv_run in HandleScope + Context::Scope and force a microtask checkpoint. These entrypoints let
// the Rust addon reproduce that. v8/node symbols resolve at load time against libnode (the addon
// is loaded into the node process), like the libuv symbols.

#include <node.h>
#include <v8.h>

// Forward-declare the one libuv entry we need (resolved against libnode/libuv at load time),
// so we don't need libuv's C++-hostile headers on the include path.
extern "C" int uv_run(void* loop, int mode);
static const int AW_UV_RUN_NOWAIT = 2;

extern "C" {

// One non-blocking libuv iteration inside a proper V8 scope, then a microtask checkpoint.
// The HandleScope is REQUIRED (else node::Environment::CheckImmediate crashes on the first
// setImmediate). The checkpoint is the correct shape for the production architecture (native owns
// main; pump at the top of the runloop with no ambient JS call). NOTE (spike finding): while a
// *blocking* napi call (runApp) is on the stack, V8 SUPPRESSES the microtask checkpoint — so this
// checkpoint is a no-op under the spike's blocking-call harness; draining pure Promise/await/
// nextTick work needs the ambient JS call gone (the Electron model). libuv-driven callbacks still
// run; only work with no libuv handle of its own is deferred until the ambient call returns.
void aw_rl_pump_v8(void* loop_) {
  v8::Isolate* iso = v8::Isolate::GetCurrent();
  if (iso == nullptr) return;
  v8::HandleScope handle_scope(iso);
  v8::Local<v8::Context> ctx = iso->GetCurrentContext();
  v8::Context::Scope context_scope(ctx);
  uv_run(loop_, AW_UV_RUN_NOWAIT);
  iso->PerformMicrotaskCheckpoint();
}

// Standalone microtask checkpoint (diagnostic).
void aw_rl_checkpoint() {
  v8::Isolate* iso = v8::Isolate::GetCurrent();
  if (iso != nullptr) iso->PerformMicrotaskCheckpoint();
}

}  // extern "C"
