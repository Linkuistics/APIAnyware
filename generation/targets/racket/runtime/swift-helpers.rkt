#lang racket/base
;; swift-helpers.rkt — Mandatory loading of libAPIAnywareRacket.dylib
;;
;; Loads the Swift helper dylib from ../lib/ relative to this file and exports
;; FFI bindings for the aw_racket_* C functions. The dylib is the binding
;; (ADR-0010): there is no pure-Racket fallback. If the dylib cannot be loaded,
;; or a required aw_racket_* symbol is missing (a stale/mismatched build), the
;; module fails to load with a clear error rather than silently degrading.
;;
;; Usage in other runtime modules:
;;   (require "swift-helpers.rkt")
;;   (swift:autorelease-push) ...

(require ffi/unsafe
         racket/path)

(provide ;; Autorelease pool
         swift:autorelease-push
         swift:autorelease-pop

         ;; Memory management
         swift:retain
         swift:release

         ;; Class/selector lookup
         swift:get-class
         swift:sel-register

         ;; String conversion
         swift:string-to-nsstring
         swift:nsstring-to-string
         swift:nsstring-length

         ;; Collection marshalling (batched — leaf 050/030)
         swift:list->nsarray
         swift:nsarray-count
         swift:nsarray-get-all
         swift:hash->nsdictionary
         swift:nsdictionary-count
         swift:nsdictionary-get-all

         ;; Block bridging
         swift:create-block
         swift:release-block

         ;; Delegate bridging
         swift:register-delegate
         swift:set-method
         swift:free-delegate

         ;; GC prevention
         swift:prevent-gc
         swift:allow-gc
         swift:gc-count)

;; --- Dylib loading ---

;; Locate the dylib relative to this source file: ../lib/libAPIAnywareRacket
(define this-dir
  (let* ([vr (#%variable-reference)]
         [mp (variable-reference->resolved-module-path vr)]
         [path (resolved-module-path-name mp)])
    (if (path? path) (path-only path) (current-directory))))

;; The dylib is mandatory (ADR-0010). A load failure here is fatal: the runtime
;; cannot function without the native binding, so surface a clear error at module
;; load time rather than degrade to a non-existent fallback.
(define anyware-lib
  (with-handlers
      ([exn:fail?
        (lambda (e)
          (error 'swift-helpers
                 (string-append
                  "libAPIAnywareRacket.dylib could not be loaded from ~a.\n"
                  "The native library is mandatory (ADR-0010); there is no "
                  "pure-Racket fallback.\nBuild it with `swift build` and ensure "
                  "lib/libAPIAnywareRacket.dylib resolves to it.\nUnderlying "
                  "error: ~a")
                 (build-path this-dir 'up "lib")
                 (exn-message e)))])
    (ffi-lib (build-path this-dir 'up "lib" "libAPIAnywareRacket"))))

;; Helper: bind an aw_racket_* C function from the dylib. A missing symbol is a
;; hard error (stale/mismatched dylib) — no failure thunk, so the module fails
;; to load clearly instead of binding the name to #f.
(define-syntax-rule (define-swift name c-name type)
  (define name (get-ffi-obj c-name anyware-lib type)))

;; --- Autorelease pool ---

(define-swift swift:autorelease-push "aw_racket_autorelease_push"
  (_fun -> _pointer))

(define-swift swift:autorelease-pop "aw_racket_autorelease_pop"
  (_fun _pointer -> _void))

;; --- Memory management ---

(define-swift swift:retain "aw_racket_retain"
  (_fun _pointer -> _pointer))

(define-swift swift:release "aw_racket_release"
  (_fun _pointer -> _void))

;; --- Class/selector lookup ---

(define-swift swift:get-class "aw_racket_get_class"
  (_fun _string -> _pointer))

(define-swift swift:sel-register "aw_racket_sel_register"
  (_fun _string -> _pointer))

;; --- String conversion ---

(define-swift swift:string-to-nsstring "aw_racket_string_to_nsstring"
  (_fun _string -> _pointer))

(define-swift swift:nsstring-to-string "aw_racket_nsstring_to_string"
  (_fun _pointer -> _string))

(define-swift swift:nsstring-length "aw_racket_nsstring_length"
  (_fun _pointer -> _uint64))

;; --- Collection marshalling (batched — leaf 050/030) ---
;;
;; One native call per collection instead of N per-element `tell`s. The input
;; direction uses `(_list i …)` so `ffi/unsafe` marshals the Racket list to a
;; transient C array for the call; the read-back direction uses `(_list o … n)`,
;; which allocates the out buffer, passes it native to fill, and converts the
;; result back to a Racket list of length `n`. `_intptr` matches Swift's `Int`.

;; (id* items, Int count) -> NSArray (+1 retained)
(define-swift swift:list->nsarray "aw_racket_list_to_nsarray"
  (_fun (_list i _pointer) _intptr -> _pointer))

(define-swift swift:nsarray-count "aw_racket_nsarray_count"
  (_fun _pointer -> _intptr))

;; (NSArray, Int count, id* out) -> fills `out`; returns the Racket list.
(define-swift swift:nsarray-get-all "aw_racket_nsarray_get_all"
  (_fun (arr : _pointer)
        (count : _intptr)
        (out : (_list o _pointer count))
        -> _void
        -> out))

;; (char** keys, id* values, Int count) -> NSDictionary (+1 retained)
(define-swift swift:hash->nsdictionary "aw_racket_hash_to_nsdictionary"
  (_fun (_list i _string) (_list i _pointer) _intptr -> _pointer))

(define-swift swift:nsdictionary-count "aw_racket_nsdictionary_count"
  (_fun _pointer -> _intptr))

;; (NSDictionary, Int count, char** outKeys, id* outValues) -> fills both;
;; returns (values key-strings value-pointers). Keys convert char*→Racket string.
(define-swift swift:nsdictionary-get-all "aw_racket_nsdictionary_get_all"
  (_fun (dict : _pointer)
        (count : _intptr)
        (keys : (_list o _string count))
        (vals : (_list o _pointer count))
        -> _void
        -> (values keys vals)))

;; --- Block bridging ---

(define-swift swift:create-block "aw_racket_create_block"
  (_fun _pointer -> _pointer))

(define-swift swift:release-block "aw_racket_release_block"
  (_fun _pointer -> _void))

;; --- Delegate bridging ---
;;
;; register-delegate takes arrays of selector and return-type C strings:
;;   selectors:    pointer to array of C strings
;;   return-types: pointer to array of C strings ("void", "bool", "id")
;;   count:        int32
;; Returns: ObjC instance pointer

(define-swift swift:register-delegate "aw_racket_register_delegate"
  (_fun (_list i _string)
        (_list i _string)
        _int32
        -> _pointer))

(define-swift swift:set-method "aw_racket_set_method"
  (_fun _pointer _string _pointer -> _void))

(define-swift swift:free-delegate "aw_racket_free_delegate"
  (_fun _pointer -> _void))

;; --- GC prevention ---

(define-swift swift:prevent-gc "aw_racket_prevent_gc"
  (_fun _pointer -> _int64))

(define-swift swift:allow-gc "aw_racket_allow_gc"
  (_fun _int64 -> _void))

(define-swift swift:gc-count "aw_racket_gc_count"
  (_fun -> _int64))
