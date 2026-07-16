// embed_main.mm — ui-controls-gallery's own dev launcher: a native main()-owner that embeds Node
// under AppKit and pumps libuv as a guest (ADR-0056 mechanism (c)). Identical shape to
// hello-window's own embed_main.mm (see its doc for the full rationale — this is the same
// dev-loop launcher every ladder rung reuses as-is until Step 8 lands); only the smoke env var
// name and doc references are app-specific.
//
// AW_UCG_SMOKE=1 (the host construction pre-flight): boots Node and lets bootstrap.cjs's async
// chain run to completion via the ORDINARY blocking Node event loop (`node::SpinEventLoop`) — no
// AppKit, no pump, no visible window — then exits. Unset: the real run — AppKit owns thread 0,
// the pump services libuv as a guest, `[NSApp run]` blocks until Quit.

#include <mach-o/dyld.h>
#include <node.h>
#include <v8.h>
#import <AppKit/AppKit.h>
#include <climits>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

extern "C" {
void aw_rl_pump_v8(void* loop);
void aw_rl_pump_start(uintptr_t loop, void (*pump_v8)(void*));
void aw_rl_pump_teardown(void);
}

using node::CommonEnvironmentSetup;
using node::Environment;
using node::MultiIsolatePlatform;
using v8::Context;
using v8::HandleScope;
using v8::Isolate;
using v8::Locker;
using v8::MaybeLocal;
using v8::V8;
using v8::Value;

// The app dir (holding bootstrap.cjs/loader.mjs/build/js/) is resolved at RUNTIME from the
// executable's own path — see hello-window's embed_main.mm for the full rationale.
static std::string app_dir() {
  char buf[PATH_MAX];
  uint32_t size = sizeof(buf);
  if (_NSGetExecutablePath(buf, &size) != 0) {
    fprintf(stderr, "error: executable path exceeds PATH_MAX\n");
    exit(1);
  }
  char resolved[PATH_MAX];
  if (realpath(buf, resolved) == nullptr) {
    fprintf(stderr, "error: realpath(%s) failed\n", buf);
    exit(1);
  }
  std::string exe(resolved);
  size_t build_dir = exe.find_last_of('/');       // strip the executable's own filename
  size_t app_dir_slash = exe.find_last_of('/', build_dir - 1);  // strip "build/"
  return exe.substr(0, app_dir_slash);
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
  bool smoke = getenv("AW_UCG_SMOKE") != nullptr;
  {
    Locker locker(isolate);
    Isolate::Scope isolate_scope(isolate);
    HandleScope handle_scope(isolate);
    Context::Scope context_scope(setup->context());

    std::string boot =
        "const { createRequire } = require('module');"
        "const req = createRequire('" + app_dir() + "/');"
        "req('./bootstrap.cjs');";
    MaybeLocal<Value> ret = node::LoadEnvironment(env, boot.c_str());
    if (ret.IsEmpty()) { fprintf(stderr, "LoadEnvironment failed\n"); return 1; }

    if (smoke) {
      exit_code = node::SpinEventLoop(env).FromMaybe(1);
    } else {
      @autoreleasepool {
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

        void* loop = static_cast<void*>(setup->event_loop());
        aw_rl_pump_start(reinterpret_cast<uintptr_t>(loop), &aw_rl_pump_v8);

        [NSApp run];  // returns once Quit (Cmd-Q / the app menu) calls -terminate:

        aw_rl_pump_teardown();
      }
    }
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
