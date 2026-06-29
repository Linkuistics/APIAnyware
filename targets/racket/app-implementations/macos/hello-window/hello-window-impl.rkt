#lang app-spec/impl

;; Impl descriptor for the racket build of Hello Window — consumed by the
;; AppSpec runner as `runner/main.rkt --impl <this file>` (ADR-0011/ADR-0013).
;; Contract: ../../../../../apps/macos/hello-window/docs/logging-contract.md
;;
;; #:events-path / #:test-config-path mirror the impl's fixed-default paths
;; (logging-contract.md "The events.log file") so the runner tails / the impl
;; writes the same file whether or not #:log-env/#:config-env propagate through
;; LaunchServices under `launch-via 'open`. #:binary is the VM install path
;; (the `04-live-run` leaf installs the built .app there); #:bundle-id must equal
;; the built bundle's CFBundleIdentifier (the build child k28 sets it).
(impl
  #:name             "Hello Window (Racket)"
  #:binary           "/Applications/HelloWindow-racket.app"
  #:config-env       "HELLO_WINDOW_TEST_CONFIG"
  #:log-env          "HELLO_WINDOW_EVENTS_LOG"
  #:bundle-id        "com.linkuistics.hello-window-racket"
  #:launch-via       'open
  #:events-path      "/tmp/hello-window/events.log"
  #:test-config-path "/tmp/hello-window/test-config.scm")
