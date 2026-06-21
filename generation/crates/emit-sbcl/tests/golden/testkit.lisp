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
     ns::animate-with-duration_animations_
     ns::appearance
     ns::copy-with-zone_
     ns::dealloc
     ns::description
     ns::enabled
     ns::frame
     ns::hidden
     ns::is-highlighted
     ns::label
     ns::load-resource_error_
     ns::manager-did-finish_
     ns::manager-should-continue_
     ns::manager-will-return-result_
     ns::maximum-count
     ns::resource-named_
     ns::set-enabled_
     ns::set-frame_
     ns::set-hidden_
     ns::set-label_
     ns::set-needs-display
     ns::set-tag_
     ns::set-target_action_
     ns::set-title_
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
