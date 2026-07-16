// embed_main.mm — the k42 test harness: a native main()-owner that embeds Node under AppKit.
//
// This is NOT the shipped per-app launcher (that is Step 8 / `bundle-typescript`, ADR-0060). It is a
// minimal native `main()`-owner that exercises the reusable pump core (pump.swift + pump_shim.cc)
// under the *production* entry architecture (ADR-0056 findings A/B/C): AppKit owns thread 0 from the
// top level, Node is embedded via the C++ embedder API (CommonEnvironmentSetup + LoadEnvironment,
// *without* SpinEventLoop/uv_run(DEFAULT)), and libuv is pumped as a guest from a
// kCFRunLoopCommonModes source. Because there is no ambient blocking JS→native call on the stack, the
// V8 microtask checkpoint runs (finding C) — the criterion the k6 blocking-call harness could not
// satisfy. ObjC++ so it can mix the Node/V8 C++ embedder API, AppKit, and the Swift @_cdecl pump.

#include <node.h>
#include <v8.h>
#import <AppKit/AppKit.h>
#include <dispatch/dispatch.h>
#include <pthread.h>
#include <unistd.h>
#include <cstdio>
#include <string>
#include <vector>

// ── The Swift pump (@_cdecl, pump.swift) + the C++ scoped pump (pump_shim.cc) ────────────────────────
extern "C" {
void aw_rl_pump_v8(void* loop);
void aw_rl_pump_start(uintptr_t loop, void (*pump_v8)(void*));
void aw_rl_pump_nudge(void);
void aw_rl_pump_teardown(void);
void aw_rl_pump_mark_nested_start(void);
void aw_rl_pump_mark_nested_end(void);
void aw_rl_pump_stats(int64_t* out);  // [passes, helperPolls, sourceFires, lastTimeout, nStart, nEnd]
}

using node::CommonEnvironmentSetup;
using node::Environment;
using node::MultiIsolatePlatform;
using v8::Context;
using v8::HandleScope;
using v8::Isolate;
using v8::Local;
using v8::Locker;
using v8::MaybeLocal;
using v8::String;
using v8::V8;
using v8::Value;

#ifndef APP_DIR
#error "APP_DIR must be defined at compile time (the harness/ directory holding app.cjs)"
#endif
#define AW_STR2(x) #x
#define AW_STR(x) AW_STR2(x)

// ── A background pinger: uv_async_send every 50ms, so the nested-runloop-survival window has libuv
// wake-ups to service (k6 test 3 shape). Runs for the harness lifetime. ─────────────────────────────
static volatile bool g_pinger_stop = false;
static void* pinger_main(void*) {
  while (!g_pinger_stop) {
    aw_rl_pump_nudge();
    usleep(50 * 1000);
  }
  return nullptr;
}

// ── V8 global readers (after NSApp.run() returns, still inside the isolate/context scopes) ───────────
static bool read_global_bool(Isolate* iso, Local<Context> ctx, const char* name, bool dflt) {
  Local<Value> key = String::NewFromUtf8(iso, name).ToLocalChecked();
  Local<Value> v;
  if (!ctx->Global()->Get(ctx, key).ToLocal(&v)) return dflt;
  if (!v->IsBoolean()) return dflt;
  return v->BooleanValue(iso);
}

static std::string read_global_string(Isolate* iso, Local<Context> ctx, const char* name) {
  Local<Value> key = String::NewFromUtf8(iso, name).ToLocalChecked();
  Local<Value> v;
  if (!ctx->Global()->Get(ctx, key).ToLocal(&v)) return "";
  if (!v->IsString()) return "";
  String::Utf8Value s(iso, v);
  return *s ? std::string(*s) : std::string();
}

static int run_embedded(MultiIsolatePlatform* platform,
                        const std::vector<std::string>& args,
                        const std::vector<std::string>& exec_args) {
  std::vector<std::string> errors;
  std::unique_ptr<CommonEnvironmentSetup> setup =
      CommonEnvironmentSetup::Create(platform, &errors, args, exec_args);
  if (!setup) {
    for (const std::string& err : errors) fprintf(stderr, "setup error: %s\n", err.c_str());
    return 1;
  }
  Isolate* isolate = setup->isolate();
  Environment* env = setup->env();
  int exit_code = 0;
  {
    // Keep the isolate entered on thread 0 for the whole app lifetime (the Electron model) so the
    // pump source callback's Isolate::GetCurrent()/GetCurrentContext() resolve.
    Locker locker(isolate);
    Isolate::Scope isolate_scope(isolate);
    HandleScope handle_scope(isolate);
    Local<Context> context = setup->context();
    Context::Scope context_scope(context);

    // Load the app: set up require, run app.cjs (kicks off the async facility tests, then returns).
    std::string boot =
        "const { createRequire } = require('module');"
        "const req = createRequire('" AW_STR(APP_DIR) "/');"
        "globalThis.require = req;"
        "req('./app.cjs');";
    MaybeLocal<Value> ret = node::LoadEnvironment(env, boot.c_str());
    if (ret.IsEmpty()) { fprintf(stderr, "LoadEnvironment failed\n"); return 1; }

    // AppKit owns thread 0 from here. Start the pump BEFORE NSApp.run() so libuv is serviced as a guest.
    @autoreleasepool {
      [NSApplication sharedApplication];
      [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];  // no dock icon / window needed

      void* loop = static_cast<void*>(setup->event_loop());
      aw_rl_pump_start(reinterpret_cast<uintptr_t>(loop), &aw_rl_pump_v8);

      pthread_t pinger;
      pthread_create(&pinger, nullptr, pinger_main, nullptr);

      // At t=1.0s: run a NESTED runloop in event-tracking mode for 1.0s (reproduces AppKit's
      // modal/menu/resize nested runloops). A kCFRunLoopCommonModes pump source keeps firing across it.
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
        aw_rl_pump_mark_nested_start();
        CFRunLoopRunInMode((CFRunLoopMode)NSEventTrackingRunLoopMode, 1.0, false);
        aw_rl_pump_mark_nested_end();
      });

      // At t=2.5s: quit. Stop NSApp and post a dummy event so run() returns promptly.
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
        [NSApp stop:nil];
        NSEvent* ev = [NSEvent otherEventWithType:NSEventTypeApplicationDefined
                                         location:NSZeroPoint modifierFlags:0 timestamp:0
                                     windowNumber:0 context:nil subtype:0 data1:0 data2:0];
        [NSApp postEvent:ev atStart:YES];
      });

      [NSApp run];

      g_pinger_stop = true;
      pthread_join(pinger, nullptr);
      aw_rl_pump_teardown();
    }

    // Read results (still inside the scopes). Native side owns the nested-runloop-survival verdict.
    bool js_ok = read_global_bool(isolate, context, "__ok", false);
    bool js_done = read_global_bool(isolate, context, "__done", false);
    std::string details = read_global_string(isolate, context, "__resultsJson");

    int64_t st[6] = {0};
    aw_rl_pump_stats(st);
    int64_t nested_passes = st[4] > 0 ? (st[5] - st[4]) : 0;
    bool nested_ok = nested_passes > 0;

    printf("\n=== embed-pump-harness-k42 ===\n");
    printf("uv_run passes total: %lld   helper polls: %lld   source fires: %lld\n", st[0], st[1], st[2]);
    printf("nested-runloop survival: %lld uv_run passes during the 1.0s NSEventTrackingRunLoopMode window  -> %s\n",
           nested_passes, nested_ok ? "GREEN (survived)" : "RED (starved)");
    printf("JS facilities: %s\n", details.c_str());
    printf("JS __done=%s __ok=%s\n", js_done ? "true" : "false", js_ok ? "true" : "false");

    // Surface any bounce-test diagnostics (tsfn-bounce-k43) so a failure is legible, not just false.
    std::string bounce_detail = read_global_string(isolate, context, "__bounceDetail");
    std::string bounce_error = read_global_string(isolate, context, "__bounceError");
    if (!bounce_detail.empty()) printf("bounce detail: %s\n", bounce_detail.c_str());
    if (!bounce_error.empty()) printf("bounce error: %s\n", bounce_error.c_str());

    // Surface any off-main-delivery diagnostics (off-main-delivery-k44) likewise.
    std::string off_main_detail = read_global_string(isolate, context, "__offMainDetail");
    std::string off_main_error = read_global_string(isolate, context, "__offMainError");
    if (!off_main_detail.empty()) printf("off-main detail: %s\n", off_main_detail.c_str());
    if (!off_main_error.empty()) printf("off-main error: %s\n", off_main_error.c_str());

    bool all_ok = js_ok && js_done && nested_ok;
    printf("\n%s\n", all_ok ? "ALL CHECKS PASSED" : "CHECKS FAILED");
    exit_code = all_ok ? 0 : 1;
  }
  node::Stop(env);
  return exit_code;
}

int main(int argc, char** argv) {
  std::vector<std::string> args(argv, argv + argc);
  std::shared_ptr<node::InitializationResult> result =
      node::InitializeOncePerProcess(
          args,
          {node::ProcessInitializationFlags::kNoInitializeV8,
           node::ProcessInitializationFlags::kNoInitializeNodeV8Platform});
  for (const std::string& error : result->errors())
    fprintf(stderr, "init error: %s\n", error.c_str());
  if (result->early_return() != 0) return result->exit_code();

  std::unique_ptr<MultiIsolatePlatform> platform = MultiIsolatePlatform::Create(4);
  V8::InitializePlatform(platform.get());
  V8::Initialize();

  int ret = run_embedded(platform.get(), result->args(), result->exec_args());

  V8::Dispose();
  V8::DisposePlatform();
  node::TearDownOncePerProcess();
  return ret;
}
