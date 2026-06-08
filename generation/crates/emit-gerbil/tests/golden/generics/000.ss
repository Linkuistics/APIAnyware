;;; Generated gerbil-bindings generics shard — do not edit
;; One :std/generic generic per selector in this shard's slice of the
;; global instance-surface selector set. Sharded to bound each gsc unit
;; (ADR-0023); the facade :gerbil-bindings/generics re-exports every shard.
(import (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod)))
(export
  animate-with-duration-animations
  dealloc
  description
  enabled
  frame
  hidden
  is-highlighted
  label
  load-resource-error
  resource-named
  set-enabled!
  set-frame!
  set-hidden!
  set-label!
  set-needs-display!
  set-tag!
  set-target-action!
  set-title!
  tag
  title
  )

(g:defgeneric animate-with-duration-animations)
(g:defgeneric dealloc)
(g:defgeneric description)
(g:defgeneric enabled)
(g:defgeneric frame)
(g:defgeneric hidden)
(g:defgeneric is-highlighted)
(g:defgeneric label)
(g:defgeneric load-resource-error)
(g:defgeneric resource-named)
(g:defgeneric set-enabled!)
(g:defgeneric set-frame!)
(g:defgeneric set-hidden!)
(g:defgeneric set-label!)
(g:defgeneric set-needs-display!)
(g:defgeneric set-tag!)
(g:defgeneric set-target-action!)
(g:defgeneric set-title!)
(g:defgeneric tag)
(g:defgeneric title)
