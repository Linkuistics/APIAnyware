;;; runtime/swift-trampoline.ss — gerbil-side support for the Swift-native
;;; trampolines (ADR-0029; ADR-0011 hermetic isolation; ADR-0015 Scheme-side
;;; marshalling).
;;;
;;; The generated `@_cdecl` trampolines in libAPIAnywareGerbil's
;;; `Generated/Trampolines.swift` re-export Swift-native (`s:`) APIs behind a flat
;;; C ABI. The generated `functions.ss` / `constants.ss` of a framework that has
;;; any such residual bind those entries with a per-signature `define-c-lambda`
;;; (against the dylib linked at `gxc -exe` time) and wrap the string / object /
;;; throws shapes with the helpers here.
;;;
;;; Divergence from chez (ADR-0029): chez needs a lazy-load forcing reference
;;; because an R6RS library instantiates lazily and loads its dylib in a module
;;; body. Gerbil links libAPIAnywareGerbil at `gxc -exe` time via `-l`, so every
;;; `aw_gerbil_swift_*` symbol resolves at image load — no forcing reference (§4).
;;; And unlike racket's native string coercer, value marshalling stays Scheme-side
;;; (ADR-0015), reusing the existing `runtime/ffi.ss` surface
;;; (`string->nsstring` / `nsstring->string` / the NSError** cell helpers); only
;;; the opaque box + throws shapes are hermetic Swift in libAPIAnywareGerbil.

;; Imports the objc runtime for the ffi surface this unit uses internally
;; (`string->nsstring` / `nsstring->string` / `objc-release` / the NSError** cell
;; helpers). It deliberately exports **only** the `aw-swift-*` coercers — `wrap` /
;; `->ptr` / the string bridge stay owned by `objc.ss`, so a generated module
;; imports *both* `objc` and this unit without a double-binding of `wrap`.
(import :gerbil-bindings/runtime/objc)
(export aw-swift-string-arg aw-swift-string-result aw-swift-call/error)

;; A `String` argument crossing into a trampoline: the gerbil caller passes a
;; Scheme string, bridged to a +1-retained NSString `id` for the `@_cdecl` body's
;; `… as String` reconstruction. `#f` → NULL (a nil String parameter). Mirrors the
;; chez `aw-string-arg`.
(def (aw-swift-string-arg s)
  (and s (string->nsstring s)))

;; A `String` result coming back from a trampoline: the `@_cdecl` handed us a
;; +1-retained NSString `id`. Copy its bytes to a Scheme string, release the +1,
;; and pass NULL through as `#f`. Marshalling stays Scheme-side (ADR-0015).
(def (aw-swift-string-result p)
  (if (ptr-null? p)
    #f
    (let (s (nsstring->string p))
      (objc-release p)
      s)))

;; Invoke a throwing trampoline through its trailing `NSError **` out-cell. `call`
;; takes the allocated cell and applies the `%swift-…` crossing with it as the
;; trailing arg; on a written error we release the +1 NSError and raise, else we
;; apply `coerce` to the (raw) success result (`aw-swift-string-result`, a wrap
;; thunk, or `values` for a scalar/handle). Cell lifetime is fully local.
;;
;; Richer NSError-message extraction (it needs a live `-localizedDescription`
;; crossing) is deferred — kept dependency-free here, as chez's
;; `aw-raise-swift-error`.
(def (aw-swift-call/error call coerce)
  (let (cell (alloc-id-cell))
    (let* ((raw (call cell))
           (err (id-cell-ref cell)))
      (free-cell cell)
      (if (ptr-null? err)
        (coerce raw)
        (begin
          (objc-release err)
          (error "Swift-native call raised an NSError"))))))
