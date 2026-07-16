import { expect, test } from 'vitest';
import { NSErrorError, NSExceptionError, ObjCError, ObjectDisposedError } from './errors.js';
import { NSObject } from './lifetime.js';

// The ADR-0058 §3 throw hierarchy: ObjCError root, NSExceptionError (the thrown NSException
// path), NSErrorError (the escalated NSError path). All are JS-native Error subclasses so a
// single `catch (e) { if (e instanceof ObjCError) … }` catches any thrown Cocoa failure.

test('ObjCError is an Error and names itself', () => {
  const e = new ObjCError('boom');
  expect(e).toBeInstanceOf(Error);
  expect(e).toBeInstanceOf(ObjCError);
  expect(e.name).toBe('ObjCError');
  expect(e.message).toBe('boom');
});

test('NSExceptionError extends ObjCError; .message is the reason, .exception the wrapper', () => {
  const exc = new NSObject(0x9001n);
  const e = new NSExceptionError(exc, 'NSRangeException: index out of bounds');
  expect(e).toBeInstanceOf(ObjCError);
  expect(e).toBeInstanceOf(Error);
  expect(e.name).toBe('NSExceptionError');
  expect(e.message).toBe('NSRangeException: index out of bounds');
  expect(e.exception).toBe(exc);
});

test('NSErrorError extends ObjCError; .error is the wrapper', () => {
  const err = new NSObject(0x9002n);
  const e = new NSErrorError(err);
  expect(e).toBeInstanceOf(ObjCError);
  expect(e).toBeInstanceOf(Error);
  expect(e.name).toBe('NSErrorError');
  expect(e.error).toBe(err);
});

test('a single ObjCError catch catches every thrown Cocoa failure kind', () => {
  const thrown: ObjCError[] = [
    new NSExceptionError(new NSObject(0x1n), 'reason'),
    new NSErrorError(new NSObject(0x2n)),
  ];
  for (const e of thrown) {
    expect(e instanceof ObjCError).toBe(true);
  }
});

test('cause is preserved through the ObjCError hierarchy', () => {
  const root = new Error('native');
  const e = new NSErrorError(new NSObject(0x3n), 'escalated', { cause: root });
  expect(e.cause).toBe(root);
});

test('ObjectDisposedError remains a plain Error, outside the ObjCError hierarchy', () => {
  // A use-after-dispose is a programming fault (ADR-0057 §6), not a Cocoa failure — it must
  // NOT be swept up by a `catch (e instanceof ObjCError)` handler meant for Cocoa errors.
  const e = new ObjectDisposedError();
  expect(e).toBeInstanceOf(Error);
  expect(e).not.toBeInstanceOf(ObjCError);
});
