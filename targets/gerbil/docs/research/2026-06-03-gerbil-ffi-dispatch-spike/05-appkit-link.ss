;; item 5b: confirm -framework AppKit links + an AppKit class resolves at runtime.
(import :std/foreign)
(export main)
(begin-ffi (nsapp-class-name)
  (c-declare "#include <objc/runtime.h>")
  (define-c-lambda nsapp-class-name () char-string
    "Class c = objc_getClass(\"NSApplication\");
     ___return( c ? (char*)class_getName(c) : (char*)\"<nil>\" );"))
(def (main . _)
  (let (n (nsapp-class-name))
    (displayln "NSApplication class = " n)
    (displayln (if (equal? n "NSApplication") "AppKit PASS" "AppKit FAIL"))))
