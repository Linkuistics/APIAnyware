#lang app-spec/impl

;; Impl descriptor for the sbcl build of Hello Window — consumed by the
;; AppSpec runner as `runner/main.rkt --impl <this file>` (ADR-0011/ADR-0013).
;; Contract: ../../../../../apps/macos/hello-window/docs/logging-contract.md
;; See the racket descriptor's header for the #:events-path/#:binary rationale.
;;
;; NB: sbcl's existing build.sh hardcodes CFBundleIdentifier
;; "com.linkuistics.hello-window"; build child k30 updates it to the per-impl
;; "com.linkuistics.hello-window-sbcl" so #:bundle-id matches the built bundle.
(impl
  #:name             "Hello Window (SBCL)"
  #:binary           "/Applications/HelloWindow-sbcl.app"
  #:config-env       "HELLO_WINDOW_TEST_CONFIG"
  #:log-env          "HELLO_WINDOW_EVENTS_LOG"
  #:bundle-id        "com.linkuistics.hello-window-sbcl"
  #:launch-via       'open
  #:events-path      "/tmp/hello-window/events.log"
  #:test-config-path "/tmp/hello-window/test-config.scm")
