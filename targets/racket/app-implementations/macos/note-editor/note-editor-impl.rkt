#lang app-spec/impl

;; Impl descriptor for the racket build of Note Editor — consumed by
;; the AppSpec runner as `runner/main.rkt --impl <this file>` (ADR-0011/ADR-0013).
;; Contract: ../../../../../apps/macos/note-editor/docs/logging-contract.md
;;
;; #:events-path / #:test-config-path mirror the impl's fixed-default paths
;; (logging-contract.md "The events.log file") so the runner tails / the impl
;; writes the same file whether or not #:log-env/#:config-env propagate through
;; LaunchServices under `launch-via 'open`. #:binary is the VM install path
;; (the Tier-2 live-run leaf installs the built .app there); #:bundle-id must
;; equal the built bundle's CFBundleIdentifier (build.sh sets it).
(impl
  #:name             "Note Editor (Racket)"
  #:binary           "/Applications/NoteEditor-racket.app"
  #:config-env       "NOTE_EDITOR_TEST_CONFIG"
  #:log-env          "NOTE_EDITOR_EVENTS_LOG"
  #:bundle-id        "com.linkuistics.note-editor-racket"
  #:launch-via       'open
  #:events-path      "/tmp/note-editor/events.log"
  #:test-config-path "/tmp/note-editor/test-config.scm")
