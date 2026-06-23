(declaim (optimize (safety 3) (debug 1)))
(sb-alien:load-shared-object "/tmp/libspike.dylib")
(defstruct (ctr (:constructor make-ctr)) (n 0 :type sb-ext:word))
(sb-ext:defglobal *calls* (make-ctr))
;; identical heap work in every variant: cons a 64-list, sum it
(declaim (inline do-cons-work))
(defun do-cons-work ()
  (let ((s 0)) (declare (fixnum s))
    (dolist (x (loop for i fixnum from 0 below 64 collect i)) (incf s x))
    (sb-ext:atomic-incf (ctr-n *calls*) (logand s #xff))) (values))
(sb-alien:define-alien-callable aw-spike-cb sb-alien:void ((tid sb-alien:long))
  (declare (ignore tid)) (do-cons-work))
(sb-alien:define-alien-routine ("aw_spike_run" aw-spike-run) sb-alien:void
  (cb sb-alien:system-area-pointer) (outer sb-alien:long) (inner sb-alien:long))
(defvar *stop* nil)
(defun start-bg () (sb-thread:make-thread
  (lambda () (loop until *stop* do (do-cons-work))) :name "bg-conser"))
(let ((test (or (sb-ext:posix-getenv "SPIKE_TEST") "foreign-concurrent"))
      (cbsap (sb-alien:alien-sap (sb-alien:alien-callable-function 'aw-spike-cb))))
  (cond
    ;; (1) genuine GCD foreign workers run Lisp, concurrently with a native conser
    ((string= test "foreign-concurrent")
     (let ((bg (start-bg)))
       (dotimes (rep 50) (aw-spike-run cbsap 8 500)
         (when (zerop (mod rep 10)) (sb-ext:gc :full t)))
       (setf *stop* t) (sb-thread:join-thread bg)))
    ;; (2) CONTROL: same load on SBCL-NATIVE threads (must survive => foreignness is the cause)
    ((string= test "native-concurrent")
     (let ((bg (start-bg))
           (workers (loop repeat 8 collect
                      (sb-thread:make-thread
                       (lambda () (dotimes (rep 50) (dotimes (j 500) (do-cons-work)))) :name "native-worker"))))
       (mapc #'sb-thread:join-thread workers)
       (setf *stop* t) (sb-thread:join-thread bg)))
    ;; (3) single foreign worker, NO competing native conser, NO forced gc
    ((string= test "foreign-serial")
     (dotimes (rep 50) (aw-spike-run cbsap 1 500))))
  (format t "~&SURVIVED test=~a calls=~d~%" test (ctr-n *calls*)))
