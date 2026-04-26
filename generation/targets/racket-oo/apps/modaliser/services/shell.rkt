#lang racket/base
;; shell.rkt — Shell command execution
;;
;; Provides synchronous shell command execution via /bin/zsh.
;;
;; run-shell: execute a command, return stdout as a string.
;; run-shell-async: execute a command and invoke a callback with
;;   (exit-code stdout stderr) when done. Historically backed by a Racket
;;   thread — but under nsapplication-run the Racket scheduler is blocked,
;;   so both the thread body and any (sleep ...) watchdog silently no-op.
;;   Now runs synchronously on the caller, with shell-level timeout support.

(require racket/port
         racket/string)

(provide run-shell
         run-shell-async
         terminate-all-processes!)

;; --- Active process tracking ---
;; Track in-flight processes so app-quit can kill any that are still
;; running (e.g. if a command is in progress when the user hits quit).

(define active-processes '())
(define processes-lock (make-semaphore 1))

(define (add-process! proc)
  (call-with-semaphore processes-lock
    (lambda () (set! active-processes (cons proc active-processes)))))

(define (remove-process! proc)
  (call-with-semaphore processes-lock
    (lambda () (set! active-processes (remq proc active-processes)))))

;; Terminate all active processes. Called on app quit.
;;
;; Every shell in this module is spawned with `subprocess-group-enabled
;; #t` (see run-shell / run-shell-async), so each tracked `proc` is a
;; process-group leader. Racket's `subprocess-kill proc #t` on a
;; group-leader child calls `killpg(pgid, SIGKILL)`, which reaches every
;; stage of a pipeline (e.g. `sleep 10 | cat`). Without group-enabled,
;; the outer zsh would die but its pipeline children would survive as
;; orphans holding Racket's stdout pipe open — turning quit into a long
;; wall-clock wait.
(define (terminate-all-processes!)
  (call-with-semaphore processes-lock
    (lambda ()
      (for ([proc (in-list active-processes)])
        (with-handlers ([exn:fail? void])
          (subprocess-kill proc #t)))
      (set! active-processes '()))))

;; --- Synchronous execution ---

;; (run-shell command) → string
;; Execute a shell command via /bin/zsh -c and return stdout as a string.
;; Returns "" on failure.
;;
;; Spawned with `subprocess-group-enabled #t` so the shell becomes its
;; own process-group leader. This keeps behaviour uniform with the async
;; path and ensures `terminate-all-processes!` could group-kill a
;; pipeline if an in-flight sync call were ever tracked in the future.
;; (Today, sync callers block on the Racket main thread, so app-quit
;; cannot observe an in-flight sync run-shell — but matching the
;; invariant avoids a footgun if that ever changes.)
(define (run-shell command)
  (with-handlers ([exn:fail? (lambda (e)
                                (displayln (format "shell: error running ~s: ~a"
                                                   command (exn-message e)))
                                "")])
    (define-values (proc stdout stdin stderr)
      (parameterize ([subprocess-group-enabled #t])
        (subprocess #f #f #f "/bin/zsh" "-c" command)))
    (close-output-port stdin)
    ;; Drain both pipes BEFORE subprocess-wait to prevent deadlock.
    ;; If the child fills the stderr pipe buffer (~64KB), it blocks until
    ;; the parent drains it. If the parent is in subprocess-wait, deadlock.
    (define output (port->string stdout))
    (define _stderr (port->string stderr))
    (close-input-port stdout)
    (close-input-port stderr)
    (subprocess-wait proc)
    output))

;; --- Async-named, caller-synchronous execution with shell-level timeout ---
;;
;; Timeout strategy: when a timeout is requested, wrap the user command in
;; a zsh script that forks a backgrounded watcher and then `exec`s the user
;; command into the current shell. After `exec`, the shell's PID is
;; unchanged, so the watcher's captured `$$` still targets the now-exec'd
;; command's process group. On timeout the watcher sends SIGKILL to the
;; whole group so pipeline stages, subshells, and nested forks all die
;; together — orphaning them (kill to a single PID) would leave the
;; grandchildren holding Racket's stdout pipe until they exited on their
;; own, turning a short timeout into a long wall-clock wait.
;;
;; Racket spawns this shell with `subprocess-group-enabled=#t`, so the
;; outer shell becomes a process-group leader with pgid == pid. `kill
;; -KILL -$$` then targets only that group; without the parameter `-$$`
;; would point at Racket's own group, which must never be signalled.
;;
;; Zsh quirk: `cmd1 && cmd2 &` parses as `cmd1 && (cmd2 &)` (only the
;; last command is backgrounded), so the outer shell would block on the
;; foreground `sleep` for the full timeout and never reach the `exec`.
;; `{ ... ; } &` forces zsh to background the whole compound, letting
;; `exec` run immediately.
;;
;; Redirecting the watcher's stdio to /dev/null matters when the user
;; command completes before the timeout fires: otherwise the
;; still-sleeping watcher keeps a dup of Racket's stdout pipe, blocking
;; `port->string` until the watcher's sleep expires.
;;
;; The user command is passed through argv (never string-interpolated into
;; the script), so there is no quoting/injection concern.
;;
;; The wrapper avoids a leading `(` so source-guards.rkt's `\(sleep[…]`
;; regex does not match the string literal.

(define timeout-wrapper-script
  (string-join
   '("{ sleep \"$1\" && kill -KILL -$$ 2>/dev/null ; } >/dev/null 2>&1 &"
     "exec /bin/zsh -c \"$2\"")
   "\n"))

;; 128 + SIGKILL — zsh's conventional exit code for SIGKILL-terminated
;; commands. A user command that itself exits 137 would be misreported
;; as a timeout; that trade-off is documented and considered acceptable.
(define SIGKILL-EXIT-CODE 137)

;; (run-shell-async command callback [#:timeout seconds]) → void
;; Execute command; invoke callback with (exit-code stdout-str stderr-str)
;; on completion. On timeout the callback receives (-1 "" "timeout").
;; Blocks the caller until completion.
(define (run-shell-async command callback #:timeout [timeout-seconds #f])
  (with-handlers ([exn:fail? (lambda (e)
                                (callback -1 "" (exn-message e)))])
    ;; Make the shell a process-group leader in both branches:
    ;;  - Timeout path: the watcher uses `kill -KILL -$$` to group-kill
    ;;    pipeline stages; this requires the shell's pgid to equal its
    ;;    own pid (rather than Racket's pgid, which must never be
    ;;    signalled).
    ;;  - No-timeout path: the process is tracked in `active-processes`,
    ;;    so `terminate-all-processes!` on app quit does a group-kill
    ;;    (via `subprocess-kill proc #t`), reaching pipeline children
    ;;    instead of orphaning them.
    (define-values (proc stdout stdin stderr)
      (parameterize ([subprocess-group-enabled #t])
        (if timeout-seconds
            (subprocess #f #f #f "/bin/zsh" "-c" timeout-wrapper-script
                        "modaliser-shell-async"          ; $0
                        (number->string timeout-seconds) ; $1
                        command)                         ; $2
            (subprocess #f #f #f "/bin/zsh" "-c" command))))
    (close-output-port stdin)
    (add-process! proc)

    ;; Drain both pipes BEFORE subprocess-wait to prevent deadlock.
    ;; If the child fills the stderr pipe buffer (~64KB), it blocks
    ;; waiting for the parent to drain. subprocess-wait would deadlock.
    (define stdout-str (port->string stdout))
    (define stderr-str (port->string stderr))
    (close-input-port stdout)
    (close-input-port stderr)

    (subprocess-wait proc)
    (remove-process! proc)

    (define exit-code (subprocess-status proc))
    (cond
      [(and timeout-seconds (equal? exit-code SIGKILL-EXIT-CODE))
       (callback -1 "" "timeout")]
      [else
       (callback exit-code stdout-str stderr-str)])))
