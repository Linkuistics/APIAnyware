#!/usr/bin/env bash
# Spike 5 — does save-lisp-and-die keep foreign Class/SEL pointers across a dump?
# Demonstrates that the CCL-revive-objc-classes-equivalent startup pass is mandatory.
set -euo pipefail
cd "$(dirname "$0")"

cat > _dump.lisp <<'EOF'
(in-package :cl-user)
(sb-alien:define-alien-routine ("objc_getClass" objc-get-class)
    sb-alien:system-area-pointer (name sb-alien:c-string))
(sb-alien:define-alien-routine ("dlopen" dlopen)
    sb-alien:system-area-pointer (path sb-alien:c-string) (mode sb-alien:int))
(dlopen "/System/Library/Frameworks/Foundation.framework/Foundation" 2)   ; RTLD_NOW
(defvar *names* '("NSObject" "NSString"))
(defvar *captured* (mapcar (lambda (n) (cons n (sb-sys:sap-int (objc-get-class n)))) *names*))
(format t "~&### [dump] captured pointers baked into image~%")
(sb-ext:save-lisp-and-die "_spike.core")
EOF

cat > _revive.lisp <<'EOF'
(in-package :cl-user)
(sb-alien:define-alien-routine ("objc_getClass" objc-get-class)
    sb-alien:system-area-pointer (name sb-alien:c-string))
(sb-alien:define-alien-routine ("dlopen" dlopen)
    sb-alien:system-area-pointer (path sb-alien:c-string) (mode sb-alien:int))
(format t "~&### [revive] baked names survived dump = ~s~%" *names*)
(format t "### WITHOUT reloading Foundation:~%")
(dolist (p *captured*)
  (let ((fresh (sb-sys:sap-int (objc-get-class (car p)))))
    (format t "###   ~a re-resolved valid=~a~%" (car p) (/= fresh 0))))
(dlopen "/System/Library/Frameworks/Foundation.framework/Foundation" 2)
(format t "### AFTER reloading Foundation:~%")
(dolist (p *captured*)
  (let ((fresh (sb-sys:sap-int (objc-get-class (car p)))))
    (format t "###   ~a re-resolved valid=~a~%" (car p) (/= fresh 0))))
(sb-ext:exit)
EOF

sbcl --non-interactive --load _dump.lisp 2>&1 | grep '^###' || true
echo "--- reload core in a fresh process ---"
sbcl --core _spike.core --non-interactive --load _revive.lisp 2>&1 | grep '^###'
# Expected: NSString invalid until Foundation is re-dlopen'd; NSObject (libobjc) always valid.
rm -f _dump.lisp _revive.lisp _spike.core
