;;; prelude.ss — boot prelude for the self-contained chez `.app`.
;;;
;;; Compiled to an object file by bundle-chez's standalone.rs and
;;; concatenated into the boot *ahead of* the whole-program app object:
;;;
;;;   (make-boot-file <app.boot> '() petite.boot scheme.boot prelude.so whole.so)
;;;
;;; Its top-level forms therefore run during Sbuild_heap, before the
;;; apianyware libraries (tree-shaken into whole.so) instantiate. That
;;; ordering is load-bearing: `runtime/ffi.sls`'s `resolve-dylib-path`
;;; probes each `(library-directories)` entry for `lib/libAPIAnywareChez.dylib`
;;; the moment those libraries instantiate, and a custom embedding host has
;;; no `--libdirs` arg-parsing to seed it (the embedded kernel defaults
;;; `(library-directories)` to "." and does not read CHEZSCHEMELIBDIRS).
;;;
;;; embed_main.c hands us the exe-relative resource dir via the
;;; AW_RESOURCE_DIR environment variable (set before Sbuild_heap) so we can
;;; point `(library-directories)` at it without touching the process cwd.
;;; The dylib lives at <AW_RESOURCE_DIR>/lib/libAPIAnywareChez.dylib (spec
;;; §5), so the directory we register is AW_RESOURCE_DIR itself.

(import (chezscheme))

;; Suppress the kernel's "Chez Scheme Version …" startup banner. Harmless
;; inside a windowed `.app` (no console) but noise in console runs; this
;; runs before the greeting would print (spike F6).
(suppress-greeting #t)

;; Seed the dylib search root from the exe-relative resource dir. Use the
;; (src . obj) pair form so a resource path containing a colon is not
;; misparsed as Chez's source:object directory separator. If the env var is
;; missing (e.g. an unbundled dev run that already set --libdirs), leave the
;; existing (library-directories) untouched.
(let ([rd (getenv "AW_RESOURCE_DIR")])
  (when (and rd (not (string=? rd "")))
    (library-directories (list (cons rd rd)))))
