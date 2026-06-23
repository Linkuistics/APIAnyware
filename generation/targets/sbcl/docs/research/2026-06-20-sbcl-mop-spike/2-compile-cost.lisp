;;;; Spike 2 — cold compile cost of a full-scale CLOS binding.
;;;; Prereq: python3 gen-binding.py
;;;; Run: sbcl --dynamic-space-size 8192 --non-interactive --load 2-compile-cost.lisp
(in-package :cl-user)
(defun ts (label thunk)
  (let ((start (get-internal-real-time)))
    (funcall thunk)
    (format t "~&### ~a: ~,2f s~%" label
            (float (/ (- (get-internal-real-time) start)
                      internal-time-units-per-second)))))

(ts "compile classes (manifest graph, objc-class metaclass)"
    (lambda () (compile-file "spike-classes.lisp" :output-file "spike-classes.fasl")))
(ts "compile generics (6500 defgeneric, pure decls)"
    (lambda () (compile-file "spike-generics.lisp" :output-file "spike-generics.fasl")))
(ts "load classes+generics"
    (lambda () (load "spike-classes.fasl") (load "spike-generics.fasl")))
(ts "compile methods (40000 defmethod)"
    (lambda () (compile-file "spike-methods.lisp" :output-file "spike-methods.fasl")))
(ts "load methods"
    (lambda () (load "spike-methods.fasl")))
(format t "~&### dynamic-space used: ~d MB~%" (round (/ (sb-kernel:dynamic-usage) 1048576)))
(sb-ext:exit)
