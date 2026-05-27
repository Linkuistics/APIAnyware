#lang racket/base
;; Generated protocol definition for NSURLSessionTaskDelegate (Foundation)
;; Do not edit — regenerate from enriched IR
;;
;; NSURLSessionTaskDelegate defines 11 methods:
;;   void-returning (11):
;;     URLSession:didCreateTask:  (session:NSURLSession, task:NSURLSessionTask)
;;     URLSession:task:willBeginDelayedRequest:completionHandler:  (session:NSURLSession, task:NSURLSessionTask, request:NSURLRequest, completionHandler:block)  — block param 3: async-copied (runtime-managed)
;;     URLSession:taskIsWaitingForConnectivity:  (session:NSURLSession, task:NSURLSessionTask)
;;     URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:  (session:NSURLSession, task:NSURLSessionTask, response:NSHTTPURLResponse, request:NSURLRequest, completionHandler:block)  — block param 4: async-copied (runtime-managed)
;;     URLSession:task:didReceiveChallenge:completionHandler:  (session:NSURLSession, task:NSURLSessionTask, challenge:NSURLAuthenticationChallenge, completionHandler:block)  — block param 3: async-copied (runtime-managed)
;;     URLSession:task:needNewBodyStream:  (session:NSURLSession, task:NSURLSessionTask, completionHandler:block)  — block param 2: async-copied (runtime-managed)
;;     URLSession:task:needNewBodyStreamFromOffset:completionHandler:  (session:NSURLSession, task:NSURLSessionTask, offset:int64, completionHandler:block)  — block param 3: async-copied (runtime-managed)
;;     URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:  (session:NSURLSession, task:NSURLSessionTask, bytesSent:int64, totalBytesSent:int64, totalBytesExpectedToSend:int64)
;;     URLSession:task:didReceiveInformationalResponse:  (session:NSURLSession, task:NSURLSessionTask, response:NSHTTPURLResponse)
;;     URLSession:task:didFinishCollectingMetrics:  (session:NSURLSession, task:NSURLSessionTask, metrics:NSURLSessionTaskMetrics)
;;     URLSession:task:didCompleteWithError:  (session:NSURLSession, task:NSURLSessionTask, error:NSError)

(require racket/contract
         "../../../runtime/delegate.rkt")

(provide/contract
  [make-nsurlsessiontaskdelegate (->* () () #:rest (listof (or/c string? procedure?)) any/c)]
  [nsurlsessiontaskdelegate-selectors (listof string?)])

;; All selectors in this protocol
(define nsurlsessiontaskdelegate-selectors
  '("URLSession:didCreateTask:"
    "URLSession:task:willBeginDelayedRequest:completionHandler:"
    "URLSession:taskIsWaitingForConnectivity:"
    "URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:"
    "URLSession:task:didReceiveChallenge:completionHandler:"
    "URLSession:task:needNewBodyStream:"
    "URLSession:task:needNewBodyStreamFromOffset:completionHandler:"
    "URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:"
    "URLSession:task:didReceiveInformationalResponse:"
    "URLSession:task:didFinishCollectingMetrics:"
    "URLSession:task:didCompleteWithError:"))

;; Create a NSURLSessionTaskDelegate delegate.
;; Pass selector string → handler procedure pairs.
;; Example:
;;   (make-nsurlsessiontaskdelegate
;;     "URLSession:didCreateTask:" (lambda (session task) ...)
;;   )
(define (make-nsurlsessiontaskdelegate . selector+handler-pairs)
  (apply make-delegate
    #:param-types
    (hash "URLSession:didCreateTask:" '(object object) "URLSession:task:willBeginDelayedRequest:completionHandler:" '(object object object pointer) "URLSession:taskIsWaitingForConnectivity:" '(object object) "URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:" '(object object object object pointer) "URLSession:task:didReceiveChallenge:completionHandler:" '(object object object pointer) "URLSession:task:needNewBodyStream:" '(object object pointer) "URLSession:task:needNewBodyStreamFromOffset:completionHandler:" '(object object long pointer) "URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:" '(object object long long long) "URLSession:task:didReceiveInformationalResponse:" '(object object object) "URLSession:task:didFinishCollectingMetrics:" '(object object object) "URLSession:task:didCompleteWithError:" '(object object object))
    selector+handler-pairs))
