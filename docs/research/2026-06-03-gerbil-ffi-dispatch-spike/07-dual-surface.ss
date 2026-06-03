;;; Spike 07: can ONE identifier serve BOTH dispatch surfaces over ONE
;;; defclass hierarchy?  Settles the 040/020 object-model pivot: gerbil emits
;;; a manifest ObjC class graph and layers BOTH Gerbil's built-in {} MOP
;;; dispatch AND :std/generic generic-function dispatch over it.
;;;
;;; Tests, with NO FFI (pure dispatch semantics — FFI already proven in 01/03):
;;;   T1  defclass inheritance: NSObject -> NSString -> NSMutableString
;;;   T2  built-in {} method `length` dispatches + inherits down the graph
;;;   T3  :std/generic generic `length` dispatches + inherits down the graph
;;;   T4  THE QUESTION: can the SAME identifier `length` be both a {} method
;;;       and a :std/generic generic in one module, called {length o} and
;;;       (length o), without a binding collision?
;;;   T5  a method WITH an argument on both surfaces (setObject:forKey: shape)
;;;
;;; Run:  gxi 07-dual-surface.ss

(import (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod)))

;; --- T1: a reified ObjC class graph as a defclass hierarchy ---------------
(defclass NSObject (ptr) transparent: #t)
(defclass (NSString NSObject) () transparent: #t)
(defclass (NSMutableString NSString) () transparent: #t)

(def root (make-NSObject ptr: 0))
(def str  (make-NSString ptr: 11))       ; pretend ptr=11 is a length-ish marker
(def mstr (make-NSMutableString ptr: 22))

(displayln "T1 hierarchy:  NSString is-NSObject? " (NSObject? str)
           "  NSMutableString is-NSString? " (NSString? mstr))

;; --- T2: built-in {} method named `length`, defined on NSString ----------
;; NSMutableString inherits it (no own definition).
(defmethod {length NSString} (lambda (self) (NSObject-ptr self)))

(displayln "T2 {length str}  = " {length str}
           "   {length mstr} (inherited) = " {length mstr})

;; --- T3 + T4: a :std/generic generic ALSO named `length` -----------------
;; If this module compiles AND both call forms work, one identifier serves
;; both surfaces.
(g:defgeneric length)
(g:defmethod (length (o NSString)) (* 100 (NSObject-ptr o)))

(displayln "T3 (length str)  = " (length str)
           "   (length mstr) (inherited) = " (length mstr))

(displayln "T4 SAME NAME both surfaces:  {length str}=" {length str}
           "  (length str)=" (length str)
           "  -> distinct bodies, same id? "
           (and (= {length str} 11) (= (length str) 1100)))

;; --- T5: a method with an argument, both surfaces, same id ---------------
(defmethod {append NSString} (lambda (self other) (+ (NSObject-ptr self) (NSObject-ptr other))))
(g:defgeneric append)
(g:defmethod (append (o NSString) (other NSObject)) (* -1 (+ (NSObject-ptr o) (NSObject-ptr other))))

(displayln "T5 {append str mstr}=" {append str mstr}
           "  (append str mstr)=" (append str mstr))

(displayln "ALL-OK")
