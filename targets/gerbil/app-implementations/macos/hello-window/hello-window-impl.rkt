#lang app-spec/impl

;; Impl descriptor for the gerbil build of Hello Window — consumed by the
;; AppSpec runner as `runner/main.rkt --impl <this file>` (ADR-0011/ADR-0013).
;; Contract: ../../../../../apps/macos/hello-window/docs/logging-contract.md
;; See the racket descriptor's header for the #:events-path/#:binary rationale.
(impl
  #:name             "Hello Window (Gerbil)"
  #:binary           "/Applications/HelloWindow-gerbil.app"
  #:config-env       "HELLO_WINDOW_TEST_CONFIG"
  #:log-env          "HELLO_WINDOW_EVENTS_LOG"
  #:bundle-id        "com.linkuistics.hello-window-gerbil"
  #:launch-via       'open
  #:events-path      "/tmp/hello-window/events.log"
  #:test-config-path "/tmp/hello-window/test-config.scm")
