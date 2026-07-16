// Runtime error roots: the use-after-dispose signal (ObjectDisposedError, ADR-0057 §6) and
// the ADR-0058 §3 Cocoa throw hierarchy (ObjCError root, NSExceptionError, NSErrorError).
//
// Layering note (ADR-0058 §1/§3, reconciled here): NSExceptionError.exception and
// NSErrorError.error are typed as the runtime root NSObject, not the Foundation NSError /
// NSException classes. Only NSObject is runtime-owned; NSError/NSException are ordinary
// Foundation classes and @apianyware/foundation imports *from* this package, so naming them
// here would form a package cycle. The native object behind the handle IS a real
// NSError/NSException; its typed accessors (.domain, .userInfo, …) are a future Foundation
// class-registration refinement, not reachable from the dumb runtime.

import type { NSObject } from './lifetime.js';

/** Thrown when a disposed wrapper's handle is used — a loud failure, never a use-after-free. */
export class ObjectDisposedError extends Error {
  constructor(message = 'ObjC object used after dispose') {
    super(message);
    this.name = 'ObjectDisposedError';
  }
}

/**
 * The thrown-side root (ADR-0058 §3) — every Cocoa failure that reaches the throw channel is
 * an `ObjCError`, so `catch (e) { if (e instanceof ObjCError) … }` catches them all. It is a
 * JS-native `Error` subclass (stack trace, `instanceof Error`); `cause` flows through the
 * standard `ErrorOptions`. Deliberately NOT a superclass of `ObjectDisposedError`: a
 * use-after-dispose is a programming fault, not a Cocoa error.
 */
export class ObjCError extends Error {
  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = 'ObjCError';
  }
}

/**
 * The thrown `NSException` path (ADR-0058 §2) — sbcl `ns:objc-exception` analogue. `.message`
 * is the exception's reason (captured native-side and carried in the `…_e` discriminant, since
 * the root-typed wrapper exposes no `-reason` accessor); `.exception` is the wrapped
 * `NSException` (typed `NSObject`, layering note above).
 */
export class NSExceptionError extends ObjCError {
  readonly exception: NSObject;

  constructor(exception: NSObject, reason: string, options?: ErrorOptions) {
    super(reason, options);
    this.name = 'NSExceptionError';
    this.exception = exception;
  }
}

/**
 * The escalated `NSError` path (ADR-0058 §3) — sbcl `ns:cocoa-error` analogue. Produced only
 * when a caller opts to bubble a `Result` failure as a throw (via `unwrap`); the default
 * `NSError**` surface is the in-band `Result`, never a throw. `.error` is the wrapped
 * `NSError` (typed `NSObject`, layering note above).
 */
export class NSErrorError extends ObjCError {
  readonly error: NSObject;

  constructor(error: NSObject, message = 'Cocoa NSError raised', options?: ErrorOptions) {
    super(message, options);
    this.name = 'NSErrorError';
    this.error = error;
  }
}
