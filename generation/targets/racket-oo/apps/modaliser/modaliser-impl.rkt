#lang app-spec/impl

;; Reference Modaliser-Racket implementation descriptor.
;;
;; Binary path resolves relative to this file: `bundle/build.sh` writes
;; the .app under apps/modaliser/build/. `launch-via 'open` routes
;; through /usr/bin/open, which attributes TCC permissions to the
;; bundle rather than the launching shell.

(require racket/runtime-path)

(define-runtime-path here ".")

(impl
  #:name       "Modaliser-Racket"
  #:binary     (path->string (build-path here "build/Modaliser.app"))
  #:config-env "MODALISER_CONFIG"
  #:log-env    "MODALISER_EVENTS_LOG"
  #:bundle-id  "dev.antony.Modaliser-Racket"
  #:launch-via 'open)
