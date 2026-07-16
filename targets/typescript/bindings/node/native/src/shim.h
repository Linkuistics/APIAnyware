// Bridging header for the Swift-native N-API addon (ADR-0054 §2, core-language
// confirmed Swift-native at napi-dispatch-spine-k35). Exposes the Node-API C surface
// to Swift; the napi_* symbols are resolved at load time against the Node host binary
// (-undefined dynamic_lookup), not linked here. No Rust / napi-rs layer.
#include <node_api.h>

// The block runtime (`_Block_copy` / `_Block_release`) — the inbound blocks surface
// (ADR-0059 §2) `_Block_copy`s a `@convention(block)` Swift closure to the heap so it
// survives the make→dispatch JS round-trip, and `_Block_release`s it after the call.
#include <Block.h>

#include <stdint.h>

// ── The outbound error-out (`…_e`) exception-catch shim (ADR-0058) ─────────────────────────
// An escaping ObjC `NSException` must never unwind the C ABI into V8 — it would corrupt the
// stack / crash the ADR-0056 pump. Swift's `do`/`catch` cannot catch an ObjC exception, and
// letting one unwind *through a Swift frame* is undefined behaviour (Swift frames don't
// propagate foreign exceptions). So the fallible `objc_msgSend` is performed in an ObjC
// compilation unit (`awexc.m`), directly inside `@try`/`@catch`, with NO Swift frame between
// the throw and the catch. Swift reads only the structured outcome below; no exception ever
// reaches Swift. This C-clean interface (no ObjC types) keeps Swift's imported view minimal.
typedef struct {
  uintptr_t primary;    // the raw x0 return: an object `id` handle, or a BOOL in the low byte
  uintptr_t error;      // the synthesized `NSError**` out-param, retained +1, or 0
  uintptr_t exception;  // the caught NSException, retained +1, or 0 (non-zero ⇒ caught)
  char *reason;         // the exception's `-reason` as a malloc'd UTF-8 copy, or NULL (Swift frees)
} AWErrorOutResult;

// The largest visible-arg count `aw_msgsend_error_catching` dispatches — must stay equal to
// emit-typescript's `native_dispatch::ERROR_OUT_MAX_ARGS` (a fallible method with more visible
// args defers there, so no generated `…_e` entry ever exceeds this switch). Args cross as
// pointer-width slots: object handles directly, integer scalars/BOOLs bit-pattern packed;
// float/double/struct shapes are NOT routable this way (v-register / multi-register — the
// error-out frontier rejects them emitter-side).
#define AW_ERR_MAX_ARGS 8

// Invoke `objc_msgSend(recv, sel, args[0..argc), &err)` under `@try`/`@catch`. `argc` visible
// pointer-width args (the trailing `NSError**` cell is synthesized here, never a visible arg).
// Retains the caught exception + the out-param `NSError` +1 (the fold the runtime's
// `__wrapRetained` expects); the object *primary*'s +0/+1 fold is the caller's per-signature
// decision (fold-iff-+0, ADR-0057 §4). Struct-return primaries are excluded upstream
// (`error_out_from_method`), so plain register-return `objc_msgSend` always applies.
AWErrorOutResult aw_msgsend_error_catching(uintptr_t recv, uintptr_t sel,
                                           const uintptr_t *args, int argc);
