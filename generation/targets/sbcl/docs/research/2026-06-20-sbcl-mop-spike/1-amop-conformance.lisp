;;;; Spike 1 — does sb-mop expose the hooks the MOP projection needs?
;;;; Run: sbcl --non-interactive --load 1-amop-conformance.lisp
(let ((hooks '(sb-mop:validate-superclass
               sb-mop:compute-effective-slot-definition
               sb-mop:slot-value-using-class
               sb-mop:direct-slot-definition-class
               sb-mop:effective-slot-definition-class
               sb-mop:compute-slots
               sb-mop:class-slots
               sb-mop:slot-definition-name
               sb-mop:finalize-inheritance
               sb-mop:ensure-class-using-class)))
  (format t "~&=== sb-mop hooks (want generic-fn=T to specialize on the metaclass) ===~%")
  (dolist (h hooks)
    (format t "~a  generic-fn=~a~%"
            h (and (fboundp h) (typep (fdefinition h) 'generic-function)))))

(format t "~&=== allocate-instance / make-instance are GFs ===~%")
(format t "allocate-instance=~a make-instance=~a shared-initialize=~a~%"
        (typep #'allocate-instance 'generic-function)
        (typep #'make-instance 'generic-function)
        (typep #'shared-initialize 'generic-function))

(format t "~&=== objc-class subclasses standard-class ===~%")
(defclass objc-class (standard-class) ())
(defmethod sb-mop:validate-superclass ((c objc-class) (s standard-class)) t)
(format t "objc-class metaclass + validate-superclass method install: OK~%")
(sb-ext:exit)
