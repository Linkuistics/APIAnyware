;; runtime/swift-trampoline.sls — chez-side support for the Swift-native
;; trampolines (ADR-0027 ported to chez in leaf 060; ADR-0011 hermetic
;; isolation; ADR-0015 Scheme-side marshalling).
;;
;; The generated `@_cdecl` trampolines in libAPIAnywareChez's
;; `Generated/Trampolines.swift` re-export Swift-native (`s:`) APIs behind a flat
;; C ABI. The generated `functions.sls` / `constants.sls` of a framework that has
;; any such residual bind those entries with a plain `foreign-procedure` (the
;; dylib is already loaded by `(apianyware runtime ffi)`), and wrap the
;; string/throws shapes with the coercers here.
;;
;; Divergence from racket (ADR-0015): racket converts NSString in native code
;; (`aw_racket_nsstring_to_string`); chez keeps the value marshalling **Scheme
;; side**, reusing the existing `nsstring-ptr->string` / `objc_release` surface
;; rather than adding a second native bridge. Only the genuinely-native concerns
;; (the opaque value box, the throws out-param) get new Swift in APIAnywareChez.

(library (apianyware runtime swift-trampoline)
  (export aw-string-arg aw-string-result aw-call/error aw-raise-swift-error
          aw-trampoline-lib-ready)
  (import (chezscheme)
          (apianyware runtime ffi))

  ;; Chez instantiates a library **lazily** — its body runs only when one of its
  ;; exports is first referenced. `(apianyware runtime ffi)` loads
  ;; `libAPIAnywareChez.dylib` *in its body*, so a generated `functions.sls` /
  ;; `constants.sls` whose only residual is a pure-scalar trampoline (using none of
  ;; the coercers below) would never trigger that load, and its `foreign-procedure`
  ;; entries (`aw_chez_swift_*`, defined in the dylib) would fail to resolve.
  ;; Emitting a reference to this binding in the trampoline section forces *this*
  ;; library to instantiate, and the reference to `objc_release` here forces ffi —
  ;; hence the dylib — to load first. (Same idiom as ffi.sls's own `%dylib-loaded`.)
  (define aw-trampoline-lib-ready objc_release)

  ;; A `String` argument crossing into a trampoline: the chez caller passes a
  ;; Scheme string, which becomes a +1-retained NSString `void*` for the
  ;; `@_cdecl` body's `… as String` reconstruction. (`string->nsstring-ptr` owns
  ;; the retain; mirrors the racket `aw-string-arg`.)
  (define (aw-string-arg s)
    (and s (string->nsstring-ptr s)))

  ;; A `String` result coming back from a trampoline: the `@_cdecl` handed us a
  ;; +1-retained NSString `id`. In chez a `void*` return is an exact integer
  ;; machine address (0 = NULL). Copy its bytes to a Scheme string, release the
  ;; +1, and pass NULL through as #f. Marshalling stays Scheme-side (ADR-0015).
  (define (aw-string-result p)
    (if (or (not p) (and (integer? p) (zero? p)))
        #f
        (let ([s (nsstring-ptr->string p)])
          (objc_release p)
          s)))

  ;; Raise a Scheme exception for a Swift-native error. The trampoline wrote a
  ;; +1-retained `NSError *` through the error out-buffer (the dispatch
  ;; `error_out` shape). Release the +1 and raise — richer NSError message
  ;; extraction (it needs a live `-localizedDescription` crossing) is deferred;
  ;; here we keep the raise dependency-free, as racket's `aw-raise-swift-error`.
  (define (aw-raise-swift-error err)
    (objc_release err)
    (error 'swift-trampoline "Swift-native call raised an NSError"))

  ;; Invoke a throwing trampoline `raw` (whose last C argument is an `NSError **`
  ;; out-buffer) with `args`, then raise if it reported an error, else return the
  ;; (coerced) value. `coerce` post-processes the raw result on the success path
  ;; (`aw-string-result`, or `values` for a scalar/identity result).
  ;;
  ;; The cell is a single pointer (8 bytes — this target is 64-bit macOS only,
  ;; per the layout assumptions in `runtime/types.sls`); `uptr` reads/writes a
  ;; pointer-sized word, the same token `constants.sls` uses for pointer globals.
  (define (aw-call/error raw coerce . args)
    (let ([errbuf (foreign-alloc 8)])
      (foreign-set! 'uptr errbuf 0 0)
      (let* ([result (apply raw (append args (list errbuf)))]
             [err (foreign-ref 'uptr errbuf 0)])
        (foreign-free errbuf)
        (if (and (integer? err) (not (zero? err)))
            (aw-raise-swift-error err)
            (coerce result))))))
