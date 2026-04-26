#lang racket/base
;; tests/test-integration-panel-script-message.rkt — Integration test for the
;; WKScriptMessage delegate path in ui/panel-manager.rkt.
;;
;; Why this exists: the third runtime bug from the prior session lived in
;; `dispatch-script-message` — the WKScriptMessage delegate argument arrives
;; as a raw cpointer, but `wkscriptmessage-body` requires `objc-object?`. The
;; fix wraps the arg with `borrow-objc-object` (memory:
;; "wkscriptmessage-body requires objc-object?"). No prior test exercised the
;; real WKWebView → JS → Racket message path, so the same regression could
;; slip again.
;;
;; This test creates a non-activating WKWebView panel under NSApplication,
;; loads inline HTML that posts a script message immediately on parse, and
;; verifies the registered Racket handler receives the body with the expected
;; fields. The auto-terminating Cocoa-loop pattern (memory) provides the
;; safety net: if the message round-trip never completes, the 5 s safety
;; timer fires `(exit 1)`.
;;
;; Failure mode if the contract regresses: `dispatch-script-message`'s
;; `with-handlers` boundary catches the contract violation and prints to
;; stderr, but the handler never fires. The safety net then fires and the
;; test exits non-zero.
;;
;; Real WKWebView is required — there's no headless substitute. The panel
;; renders briefly on screen during the test.

(require "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/delegate.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../ffi/main-thread.rkt"
         "../ui/panel-manager.rkt")

(file-stream-buffer-mode (current-output-port) 'line)

(define NSApplicationActivationPolicyAccessory 1)
(define app (nsapplication-shared-application))
(void (nsapplication-set-activation-policy! app NSApplicationActivationPolicyAccessory))

(define test-panel-id "test-script-message-panel")

;; HTML loads, then posts a single message to the "modaliser" handler.
;; The body is a JS object — arrives in Racket as an NSDictionary that
;; `objc-dict-get` / `objc-dict-get-number` can decode.
(define test-html
  (string-append
   "<!DOCTYPE html><html><head><meta charset=\"utf-8\"></head>"
   "<body><script>"
   "window.addEventListener('DOMContentLoaded', () => {"
   "  webkit.messageHandlers.modaliser.postMessage({"
   "    type: 'ping',"
   "    value: 42,"
   "    name: 'hello'"
   "  });"
   "});"
   "</script></body></html>"))

(define (fail! fmt . args)
  (apply eprintf fmt args)
  (with-handlers ([exn:fail? (lambda (e) (void))])
    (close-panel! test-panel-id))
  (exit 1))

(define (handle-message body)
  (define msg-type (objc-dict-get body "type"))
  (define name (objc-dict-get body "name"))
  (define value (objc-dict-get-number body "value"))
  (cond
    [(not (equal? msg-type "ping"))
     (fail! "test-integration-panel-script-message: expected type=\"ping\", got ~s\n"
            msg-type)]
    [(not (equal? name "hello"))
     (fail! "test-integration-panel-script-message: expected name=\"hello\", got ~s\n"
            name)]
    [(not (and value (= value 42)))
     (fail! "test-integration-panel-script-message: expected value=42, got ~s\n"
            value)]
    [else
     (close-panel! test-panel-id)
     (displayln "test-integration-panel-script-message: round-trip ok — handler received body with expected fields")
     (exit 0)]))

(define delegate
  (make-delegate
   "applicationDidFinishLaunching:"
   (lambda (notification)
     (call-on-main-thread-after
      5.0
      (lambda ()
        (eprintf "test-integration-panel-script-message: SAFETY EXIT (5s elapsed) — handler never fired\n")
        (with-handlers ([exn:fail? (lambda (e) (void))])
          (close-panel! test-panel-id))
        (exit 1)))
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "test-integration-panel-script-message: setup raised: ~a\n"
                                 (exn-message e))
                        (exit 1))])
       (create-panel! test-panel-id
                      #:width 200
                      #:height 100
                      #:activating #f
                      #:floating #t
                      #:transparent #f)
       (panel-set-message-handler! test-panel-id handle-message)
       (panel-set-html! test-panel-id test-html)))))

(void (nsapplication-set-delegate! app delegate))
(nsapplication-run app)
