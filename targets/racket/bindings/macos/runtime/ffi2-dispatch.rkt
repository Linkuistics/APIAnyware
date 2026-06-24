#lang racket/base
;; ffi2-dispatch.rkt — the ffi2 definer for the generated typed native dispatch
;; table (ADR-0013).
;;
;; The `racket` target dispatches Objective-C methods through native entry points
;; generated *per distinct ABI signature* (`aw_racket_msg_<code>`), compiled into
;; `libAPIAnywareRacket` by `swift build` from the emitter-produced
;; `swift/Sources/APIAnywareRacket/Generated/Dispatch.swift`. Each entry casts
;; `objc_msgSend` to its concrete `@convention(c)` shape (the shipped form of the
;; 010 spike's `aw_t_*` C entries; see FINDINGS.md §1b — ~5–6 ns/call, ~2× the
;; status-quo typed msgSend and ~8× on struct returns).
;;
;; Generated class files `(require ".../ffi2-dispatch.rkt")` and bind the entries
;; they use with `define-aw-msg`, then call them with `ptr_t` receiver/selector/
;; object arguments — the thin static seam of ADR-0010 (the native library *is*
;; the binding; ffi2 is the crossing, not the home of the logic).
;;
;; Design: generation/targets/racket/docs/design/2026-05-31-racket-native-binding-design.md §2;
;; docs/adr/0013-generated-typed-native-dispatch.md.

(require racket/path
         "ffi2-seam.rkt") ; ffi2 (incl. ffi2-lib, define-ffi2-definer, ->) + the
                          ; ptr_t<->cpointer bridge, with `->` collision resolved.

;; Re-export the seam wholesale so a class file needs a single require for the
;; ffi2 surface, the bridge, and the dispatch definer.
(provide (all-from-out "ffi2-seam.rkt")
         define-aw-msg)

;; Locate libAPIAnywareRacket relative to this module: ../lib/ (mirrors
;; swift-helpers.rkt's `anyware-lib`). ffi2-lib wants a path string.
(define this-dir
  (let* ([vr (#%variable-reference)]
         [mp (variable-reference->resolved-module-path vr)]
         [path (resolved-module-path-name mp)])
    (if (path? path) (path-only path) (current-directory))))

(define _aw-dispatch-lib
  (ffi2-lib (path->string (build-path this-dir 'up "lib" "libAPIAnywareRacket.dylib"))))

;; `(define-aw-msg aw_racket_msg_<code> (-> ptr_t ptr_t <args…> <ret>))` binds one
;; generated dispatch entry. The Racket identifier equals the C symbol; the two
;; leading `ptr_t`s are the implicit `self` + `_cmd`.
(define-ffi2-definer define-aw-msg #:lib _aw-dispatch-lib)
