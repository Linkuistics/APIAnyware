# 060-delete-racket-fallbacks

**Kind:** work

## Goal
Make the racket native dylib **mandatory** and delete the pure-Racket fallbacks
the native lib now covers (the `swift-available?` branches in `objc-base.rkt`,
`type-mapping.rkt`, `block.rkt`, etc.). Confirm the retained `ffi/unsafe`/
`ffi/unsafe/objc` surface is exactly the boundary set from 020/010 and no more —
a grep for `ffi/unsafe` should flag only the deliberately-retained ObjC layer.

## Done when
- No `swift-available?` fallback branches remain; the runtime errors clearly if
  the dylib is absent.
- Retained `ffi/unsafe`(+`/objc`) usage matches the documented boundary exactly.
- Build green. (VM-verify deferred to root leaf 050.)

## Notes
- Depends on 040 (emitter) + the native lib carrying the relocated logic.
- This is where "the binding is almost entirely native" (ADR-0010) lands.
