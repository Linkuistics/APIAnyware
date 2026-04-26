#lang racket/base
;; http-worker.rkt — HTTP fetch worker running inside a Racket place
;;
;; Loaded by services/http.rkt via dynamic-place. Each place has its own
;; Racket VM with its own scheduler, so net/url's get-pure-port works
;; here — unlike call-in-os-thread, where tcp-connect segfaults because
;; Racket CS's TCP implementation is not safe on foreign OS threads.
;;
;; Protocol (all messages are place-message-allowed):
;;   Parent → worker:   (list id url-string)   or   'quit
;;   Worker → parent:   (cons id body-or-#f)
;;
;; On any error (network failure, DNS, timeout, parse) the body is #f.
;; The worker never raises into the main loop, so a single bad URL
;; cannot kill the place.

(require racket/place
         net/url
         racket/port)

(provide http-worker-body)

(define (http-worker-body ch)
  (let loop ()
    (define req (place-channel-get ch))
    (cond
      [(eq? req 'quit) (void)]
      [(and (pair? req) (integer? (car req)) (string? (cadr req)))
       (define id (car req))
       (define url-string (cadr req))
       (place-channel-put ch (cons id (fetch url-string)))
       (loop)]
      [else
       ;; Unknown message shape — ignore and keep the loop alive.
       (loop)])))

;; Fetch a URL and return its body as a string, or #f on any failure.
;; dynamic-wind ensures the TCP connection is closed even if
;; port->string throws mid-stream.
(define (fetch url-string)
  (with-handlers ([exn:fail? (lambda (_e) #f)])
    (define u (string->url url-string))
    (define in (get-pure-port u #:redirections 5))
    (dynamic-wind
      void
      (lambda () (port->string in))
      (lambda () (close-input-port in)))))
