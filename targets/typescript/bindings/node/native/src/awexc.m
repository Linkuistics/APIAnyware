// The outbound error-out (`…_e`) exception-catch shim (ADR-0058) — the one ObjC
// compilation unit in the otherwise Swift-native addon.
//
// Why ObjC and not Swift: an escaping `NSException` must never unwind the C ABI into V8
// (it would corrupt the stack / crash the ADR-0056 pump). Swift's `do`/`catch` cannot
// catch an ObjC exception, and letting one unwind *through a Swift frame* is undefined
// behaviour. So the fallible `objc_msgSend` runs HERE, directly inside `@try`/`@catch`,
// with no Swift frame between the throw and the catch — Swift (`dispatch.swift`) reads
// only the structured `AWErrorOutResult`, never an exception.
//
// Compiled MRC (no ARC) on purpose: the caught exception and the out-param `NSError` are
// retained +1 *explicitly* and handed back as raw `uintptr_t`, never as an ARC-managed
// Swift `AnyObject` (the ARC-over-release trap the `inbound.swift` discipline warns of).
// That +1 is the "fold" the runtime's `__wrapRetained`/`result.ts` expects (fold-iff-+0):
// both objects are +0 autoreleased (Apple convention), so both fold.

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <stdlib.h>
#import <string.h>

#import "shim.h"

// `objc_msgSend` cast to the concrete pointer-arg signature (argc pointer-width args +
// the trailing synthesized `NSError**`). Object args and an `id` primary cross as `void *`;
// a BOOL primary lands in the low byte of the returned register (masked caller-side). It
// MUST be cast to the exact prototype before calling (arm64 has no variadic `objc_msgSend`).
typedef void *(*AWMsgSend0)(void *, void *, NSError **);
typedef void *(*AWMsgSend1)(void *, void *, void *, NSError **);
typedef void *(*AWMsgSend2)(void *, void *, void *, void *, NSError **);
typedef void *(*AWMsgSend3)(void *, void *, void *, void *, void *, NSError **);
typedef void *(*AWMsgSend4)(void *, void *, void *, void *, void *, void *, NSError **);
typedef void *(*AWMsgSend5)(void *, void *, void *, void *, void *, void *, void *, NSError **);
typedef void *(*AWMsgSend6)(void *, void *, void *, void *, void *, void *, void *, void *,
                            NSError **);
typedef void *(*AWMsgSend7)(void *, void *, void *, void *, void *, void *, void *, void *,
                            void *, NSError **);
typedef void *(*AWMsgSend8)(void *, void *, void *, void *, void *, void *, void *, void *,
                            void *, void *, NSError **);

AWErrorOutResult aw_msgsend_error_catching(uintptr_t recv, uintptr_t sel,
                                           const uintptr_t *args, int argc) {
  AWErrorOutResult out = {0, 0, 0, NULL};
  void *self_ = (void *)recv;
  void *cmd = (void *)sel;
  NSError *err = nil;
  void *r = NULL;
  @try {
    switch (argc) {
      case 0:
        r = ((AWMsgSend0)objc_msgSend)(self_, cmd, &err);
        break;
      case 1:
        r = ((AWMsgSend1)objc_msgSend)(self_, cmd, (void *)args[0], &err);
        break;
      case 2:
        r = ((AWMsgSend2)objc_msgSend)(self_, cmd, (void *)args[0], (void *)args[1], &err);
        break;
      case 3:
        r = ((AWMsgSend3)objc_msgSend)(self_, cmd, (void *)args[0], (void *)args[1],
                                       (void *)args[2], &err);
        break;
      case 4:
        r = ((AWMsgSend4)objc_msgSend)(self_, cmd, (void *)args[0], (void *)args[1],
                                       (void *)args[2], (void *)args[3], &err);
        break;
      case 5:
        r = ((AWMsgSend5)objc_msgSend)(self_, cmd, (void *)args[0], (void *)args[1],
                                       (void *)args[2], (void *)args[3], (void *)args[4], &err);
        break;
      case 6:
        r = ((AWMsgSend6)objc_msgSend)(self_, cmd, (void *)args[0], (void *)args[1],
                                       (void *)args[2], (void *)args[3], (void *)args[4],
                                       (void *)args[5], &err);
        break;
      case 7:
        r = ((AWMsgSend7)objc_msgSend)(self_, cmd, (void *)args[0], (void *)args[1],
                                       (void *)args[2], (void *)args[3], (void *)args[4],
                                       (void *)args[5], (void *)args[6], &err);
        break;
      case 8:
        r = ((AWMsgSend8)objc_msgSend)(self_, cmd, (void *)args[0], (void *)args[1],
                                       (void *)args[2], (void *)args[3], (void *)args[4],
                                       (void *)args[5], (void *)args[6], (void *)args[7], &err);
        break;
      default:
        return out;  // argc out of range — non-routable (never emitted); leaves a nil result.
    }
  } @catch (NSException *exc) {
    // Retain the exception +1 (the fold `__wrapRetained` takes) and copy its `-reason` before
    // returning — `strdup(NULL)` is UB, so an absent reason becomes "". `exception != 0` is the
    // caller's signal that the exception axis fired; `primary`/`error` stay 0.
    out.exception = (uintptr_t)[exc retain];
    const char *reason = [[exc reason] UTF8String];
    out.reason = strdup(reason ? reason : "");
    return out;
  }
  // Normal return. The primary is the raw register value — Swift folds an *object* primary per
  // its +0/+1 convention (a BOOL primary is read from the low byte). The out-param `NSError` is
  // +0 autoreleased; retain it +1 here (read only by the runtime when the primary keys failure).
  out.primary = (uintptr_t)r;
  if (err != nil) {
    out.error = (uintptr_t)[err retain];
  }
  return out;
}
