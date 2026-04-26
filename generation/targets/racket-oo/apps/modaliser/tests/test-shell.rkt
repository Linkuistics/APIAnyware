#lang racket/base
;; test-shell.rkt — Tests for services/shell.rkt

(require rackunit
         racket/string
         "../services/shell.rkt")

;; --- Load-time smoke test ---
;; shell.rkt previously used dead scheduler forms for its async timeout
;; watchdog. Static guardrail lives in tests/test-source-guards.rkt;
;; this file keeps the dynamic-require smoke load to catch load-time
;; breakage (memory: "Verify regenerated bindings by loading, not
;; grepping").
(check-not-exn
 (lambda ()
   (dynamic-require
    (build-path (current-directory) "services" "shell.rkt") #f))
 "shell.rkt must load without errors")

;; --- run-shell (synchronous) ---

;; Basic command execution
(check-equal? (run-shell "echo hello") "hello\n"
              "echo should return the string with newline")

;; Command with multiple words
(check-equal? (run-shell "echo -n foo") "foo"
              "echo -n should return string without trailing newline")

;; Command that produces no output
(check-equal? (run-shell "true") ""
              "true should produce empty output")

;; Command that fails should return ""
(check-equal? (run-shell "false") ""
              "false exits non-zero but stdout is still empty")

;; Invalid command should return "" (caught by error handler)
(check-equal? (run-shell "nonexistent_command_xyz_12345 2>/dev/null") ""
              "invalid command should return empty string")

;; Shell features work (pipes, env vars)
(check-true (> (string-length (run-shell "echo $HOME")) 0)
            "shell should expand env vars")

(check-equal? (run-shell "echo hello | tr h H") "Hello\n"
              "shell should support pipes")

;; --- run-shell-async ---

;; Async basic execution
(let ([result-box (box #f)]
      [done (make-semaphore 0)])
  (run-shell-async "echo async-test"
                   (lambda (exit-code stdout stderr)
                     (set-box! result-box (list exit-code stdout stderr))
                     (semaphore-post done)))
  (semaphore-wait done)
  (define result (unbox result-box))
  (check-equal? (car result) 0 "exit code should be 0")
  (check-equal? (cadr result) "async-test\n" "stdout should match")
  (check-equal? (caddr result) "" "stderr should be empty"))

;; Async with non-zero exit
(let ([result-box (box #f)]
      [done (make-semaphore 0)])
  (run-shell-async "exit 42"
                   (lambda (exit-code stdout stderr)
                     (set-box! result-box exit-code)
                     (semaphore-post done)))
  (semaphore-wait done)
  (check-equal? (unbox result-box) 42 "should report non-zero exit code"))

;; Async with stderr
(let ([result-box (box #f)]
      [done (make-semaphore 0)])
  (run-shell-async "echo oops >&2"
                   (lambda (exit-code stdout stderr)
                     (set-box! result-box stderr)
                     (semaphore-post done)))
  (semaphore-wait done)
  (check-equal? (unbox result-box) "oops\n" "should capture stderr"))

;; Async with timeout
(let ([result-box (box #f)]
      [done (make-semaphore 0)])
  (run-shell-async "sleep 10"
                   (lambda (exit-code stdout stderr)
                     (set-box! result-box (list exit-code stderr))
                     (semaphore-post done))
                   #:timeout 0.5)
  (semaphore-wait done)
  (define result (unbox result-box))
  (check-equal? (car result) -1 "timed-out exit code should be -1")
  (check-equal? (cadr result) "timeout" "timed-out stderr should be 'timeout'"))

;; Timeout set but command completes first — the user command must
;; actually run and return its stdout. Previously broken: the zsh wrapper
;; `sleep && kill &` was parsed as `sleep && (kill &)`, blocking the
;; outer shell on the foreground sleep so `exec` to the user command
;; never ran.
(let ([result-box (box #f)]
      [done (make-semaphore 0)])
  (run-shell-async "echo quick-exit"
                   (lambda (exit-code stdout stderr)
                     (set-box! result-box (list exit-code stdout))
                     (semaphore-post done))
                   #:timeout 5)
  (semaphore-wait done)
  (define result (unbox result-box))
  (check-equal? (car result) 0
                "command completing before timeout should report exit 0")
  (check-equal? (cadr result) "quick-exit\n"
                "stdout must reflect the user command, proving exec happened"))

;; Pipeline with a timeout: the watcher must signal the whole process
;; group, otherwise pipeline stages are orphaned and keep Racket's
;; stdout pipe open until they finish naturally — turning a 0.5 s
;; timeout into a 10 s wall-clock wait.
(let ([result-box (box #f)]
      [done (make-semaphore 0)]
      [start (current-inexact-milliseconds)])
  (run-shell-async "sleep 10 | cat"
                   (lambda (exit-code stdout stderr)
                     (set-box! result-box
                               (list exit-code
                                     (- (current-inexact-milliseconds) start)))
                     (semaphore-post done))
                   #:timeout 0.5)
  (semaphore-wait done)
  (define result (unbox result-box))
  (check-equal? (car result) -1
                "pipeline timeout should report -1")
  (check-true (< (cadr result) 3000)
              (format "pipeline timeout elapsed ~a ms — should be well under 3 s"
                      (cadr result))))

;; run-shell must spawn the shell as its own process-group leader
;; (subprocess-group-enabled #t), so pipeline stages can be reached by
;; a group-kill. Verified by asking the shell itself: its own pid ($$)
;; and the pgid of that pid should match iff the shell is a group leader.
(let* ([output (run-shell "echo \"$$ $(ps -o pgid= -p $$ | tr -d ' ')\"")]
       [parts (string-split (string-trim output))])
  (check-equal? (length parts) 2
                "run-shell pgid probe should produce two numbers")
  (check-equal? (car parts) (cadr parts)
                (format "run-shell must spawn zsh as process-group leader (pid=pgid); got ~s"
                        output)))

;; --- terminate-all-processes! ---

;; Should not error when no processes are active
(check-not-exn (lambda () (terminate-all-processes!))
               "terminate-all-processes! should be safe when empty")

;; terminate-all-processes! must reach pipeline children, not just the
;; outer zsh. Without subprocess-group-enabled on the async path, killing
;; the outer shell would orphan `cat`, leaving it holding Racket's stdout
;; pipe open until the upstream `sleep` exited on its own (~10 s). With
;; group-enabled, subprocess-kill sends SIGKILL to the whole group and
;; the pipeline tears down immediately.
(let ([start (current-inexact-milliseconds)]
      [done (make-semaphore 0)]
      [elapsed-box (box #f)])
  (thread
   (lambda ()
     (run-shell-async "sleep 10 | cat"
                      (lambda (exit-code stdout stderr)
                        (set-box! elapsed-box
                                  (- (current-inexact-milliseconds) start))
                        (semaphore-post done)))))
  ;; Give the shell time to fork the pipeline before we kill it.
  (sleep 0.3)
  (terminate-all-processes!)
  (semaphore-wait done)
  (check-true (< (unbox elapsed-box) 3000)
              (format "terminate-all-processes! on pipeline: elapsed ~a ms — should be well under 3 s"
                      (unbox elapsed-box))))

(displayln "test-shell: all checks passed")
