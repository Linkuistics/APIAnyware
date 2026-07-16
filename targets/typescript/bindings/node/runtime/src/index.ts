// @apianyware/runtime — the dumb runtime seam the emitted per-framework modules import from
// (ADR-0011 hermetic seam; ADR-0055/0056/0057/0058/0059). This barrel exposes only the public seam;
// internal helpers (__frCleanup, __installFinalization) stay module-private.
//
// This package provides the object-model root + lifetime spine (ADR-0055 §7 / ADR-0057), the
// error-model roots (Result, __result*, the ObjCError throw hierarchy, unwrap, __cfstr; ADR-0058),
// and the inbound callback / delivery half (the registry, onCallbackError containment, and the
// value-returning delivery discipline the Step-4 native trampolines call into; ADR-0056/0059).

export {
  type CallbackErrorContext,
  type CallbackErrorHandler,
  type CallbackFn,
  type CallbackId,
  type CallbackMarshal,
  type InboundCall,
  type InboundResult,
  __deliverDealloc,
  __deliverValueReturning,
  __ensureInbound,
  __invokeCallback,
  __registerCallback,
  __releaseCallback,
  __resolveCallback,
  onCallbackError,
} from './callbacks.js';
export {
  NSObject,
  __unwrap,
  __wrapBorrowed,
  __wrapOwned,
  __wrapRetained,
  withAutoreleasePool,
} from './lifetime.js';
// The inbound value surface (ADR-0059 §8) — the kind descriptors an emitted delegate/subclass/block
// spec carries, and the converters the registry funnel applies.
export {
  type ArgKind,
  type MethodMarshal,
  type RetKind,
  type RetainAxis,
  CLS,
  OBJ,
  RAW,
  RET_OBJ,
  RET_RAW,
  SEL,
  __blockMarshal,
  __methodMarshal,
} from './marshal.js';
export {
  type NativeDispatch,
  type NativeEntry,
  __cfstr,
  __class,
  __dispatch,
  __installDispatch,
  __sel,
  __selName,
} from './dispatch.js';
export {
  type ObjCClass,
  __alloc,
  __classArg,
  __classCtor,
  __init,
  __registerClass,
} from './classes.js';
export { NSErrorError, NSExceptionError, ObjCError, ObjectDisposedError } from './errors.js';
export {
  type NativeErrorResult,
  type Result,
  __resultOwned,
  __resultRetained,
  __resultScalar,
  __resultScalarValue,
  unwrap,
} from './result.js';
export { __makeEscapingBlock, __withNoescapeBlock } from './blocks.js';
export {
  type SubclassOverride,
  __bindSubclass,
  __subclassAlloc,
  __subclassClass,
} from './subclass.js';
export { type OverridableMethod, __allocSubclass, __detectOverrides } from './super.js';
export {
  type DelegateSpec,
  MAX_PROTOCOL_METHODS,
  __forwarderClass,
  __protocolAdopt,
  __protocolArg,
  __respondsBits,
} from './delegate.js';
// The POD geometry family (ADR-0055 §5) — pure types, no runtime value; emitted modules
// `import type` them from here, as they do `Result<T>`.
export type {
  CGAffineTransform,
  CGPoint,
  CGRect,
  CGSize,
  CGVector,
  NSAffineTransformStruct,
  NSDirectionalEdgeInsets,
  NSEdgeInsets,
  NSRange,
} from './structs.js';
