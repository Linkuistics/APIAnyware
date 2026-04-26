#lang racket/base
;; test-events.rkt — Structured event emitter format tests.

(require rackunit
         racket/file
         racket/string
         (prefix-in evt: (submod "../lib/events.rkt" test-hooks))
         "../lib/events.rkt")

;; --- format-value: bare values (numbers, booleans, safe symbols) ---
(check-equal? (evt:format-value 42) "42")
(check-equal? (evt:format-value -7) "-7")
(check-equal? (evt:format-value 0) "0")
(check-equal? (evt:format-value #t) "true")
(check-equal? (evt:format-value #f) "false")
(check-equal? (evt:format-value 'enter) "enter"
              "symbol → its name, bare when chars are safe")
(check-equal? (evt:format-value 'secondary-action) "secondary-action"
              "hyphen is safe in bare symbols")
(check-equal? (evt:format-value 'com.apple.Safari) "com.apple.Safari"
              "dotted symbol (bundle-id style) stays bare")

;; --- format-value: strings always quoted ---
(check-equal? (evt:format-value "safari") "\"safari\""
              "strings always quoted (scenario-regex consistency)")
(check-equal? (evt:format-value "hello world") "\"hello world\""
              "space stays inside quotes")
(check-equal? (evt:format-value "say \"hi\"") "\"say \\\"hi\\\"\""
              "embedded dquote escaped")
(check-equal? (evt:format-value "a\\b") "\"a\\\\b\""
              "embedded backslash escaped")
(check-equal? (evt:format-value "line1\nline2") "\"line1\\nline2\""
              "embedded newline escaped")
(check-equal? (evt:format-value "tab\there") "\"tab\\there\""
              "embedded tab escaped")

;; Symbols with unsafe chars get quoted via symbol->string fallback.
(check-equal? (evt:format-value (string->symbol "has space")) "\"has space\""
              "symbol with space falls back to quoted form")

;; --- log-event full line format ---
(define tmp (make-temporary-file "modaliser-events-~a.log"))
(events-init! #:path tmp)

(log-event 'lifecycle 'startup)
(log-event 'modal 'enter 'tree "global")
(log-event 'chooser 'push 'query "safari" 'results 5)
(log-event 'launch 'bundle 'id "com.apple.Safari")
(log-event 'window 'move 'x 100 'y 200 'w 800 'h 600)
(log-event 'chooser 'close 'reason 'cancel)

(close-events!)

(define lines (string-split (file->string tmp) "\n" #:trim? #t))
(check-equal? (length lines) 6)
(check-equal? (list-ref lines 0) "[lifecycle] startup")
(check-equal? (list-ref lines 1) "[modal] enter tree=\"global\"")
(check-equal? (list-ref lines 2) "[chooser] push query=\"safari\" results=5")
(check-equal? (list-ref lines 3) "[launch] bundle id=\"com.apple.Safari\"")
(check-equal? (list-ref lines 4) "[window] move x=100 y=200 w=800 h=600")
(check-equal? (list-ref lines 5) "[chooser] close reason=cancel")

(delete-file tmp)

;; --- no-op before init ---
;; Synthesize a path that doesn't exist yet (make-temporary-file would
;; create it). close-events! guarantees no port is open.
(define tmp2-dir (find-system-path 'temp-dir))
(define tmp2 (build-path tmp2-dir
                         (format "modaliser-events-never-~a.log" (current-seconds))))
(when (file-exists? tmp2) (delete-file tmp2))
(close-events!)
(log-event 'lifecycle 'startup 'note "should not appear")
(check-false (file-exists? tmp2)
             "log-event before events-init! must not create any file")

;; --- odd kv args raise ---
(define tmp3 (make-temporary-file "modaliser-events-~a.log"))
(events-init! #:path tmp3)
(check-exn exn:fail?
           (lambda () (log-event 'm 'e 'key)))
(close-events!)
(delete-file tmp3)

(displayln "test-events: all checks passed")
