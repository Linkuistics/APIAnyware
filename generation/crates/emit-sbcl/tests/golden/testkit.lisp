;;; Generated TestKit bindings — facade / package surface — do not edit
;;;
;;; The framework's ASDF system (runtime leaf 050) loads this facade FIRST —
;;; it interns + exports every bound ns: symbol so the construct files'
;;; single-colon references read — then generics.lisp, then the per-class
;;; files superclass-before-subclass, then protocols/enums/constants/functions
;;; (10 sibling file(s) under testkit/).
(in-package #:apianyware-sbcl-impl)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export
   '(
     ns::animate-with-duration-animations
     ns::appearance
     ns::copy-with-zone
     ns::dealloc
     ns::description
     ns::enabled
     ns::frame
     ns::hidden
     ns::is-highlighted
     ns::label
     ns::load-resource-error
     ns::manager-did-finish
     ns::manager-should-continue
     ns::manager-will-return-result
     ns::maximum-count
     ns::resource-named
     ns::set-enabled
     ns::set-frame
     ns::set-hidden
     ns::set-label
     ns::set-needs-display
     ns::set-tag
     ns::set-target-action
     ns::set-title
     ns::shared-manager
     ns::tag
     ns::title
     ns::tk-alignment-center
     ns::tk-alignment-left
     ns::tk-alignment-right
     ns::tk-button
     ns::tk-compute-distance
     ns::tk-create-buffer
     ns::tk-default-timeout
     ns::tk-get-name
     ns::tk-helper
     ns::tk-manager
     ns::tk-object
     ns::tk-register-callback
     ns::tk-reset
     ns::tk-status-attribute
     ns::tk-transform-point
     ns::tk-version-string
     ns::tk-view
     ns::version-string
     )
   (find-package '#:ns)))
