#lang racket/base
;; Generated protocol definition for NSWindowDelegate (AppKit)
;; Do not edit — regenerate from enriched IR
;;
;; NSWindowDelegate defines 53 methods:
;;   void-returning (42):
;;     windowWillResize:toSize:  (sender:NSWindow, frameSize:NSSize)
;;     windowWillUseStandardFrame:defaultFrame:  (window:NSWindow, newFrame:NSRect)
;;     window:willPositionSheet:usingRect:  (window:NSWindow, sheet:NSWindow, rect:NSRect)
;;     window:willUseFullScreenContentSize:  (window:NSWindow, proposedSize:NSSize)
;;     window:willUseFullScreenPresentationOptions:  (window:NSWindow, proposedOptions:NSApplicationPresentationOptions)
;;     window:startCustomAnimationToEnterFullScreenWithDuration:  (window:NSWindow, duration:double)
;;     windowDidFailToEnterFullScreen:  (window:NSWindow)
;;     window:startCustomAnimationToExitFullScreenWithDuration:  (window:NSWindow, duration:double)
;;     window:startCustomAnimationToEnterFullScreenOnScreen:withDuration:  (window:NSWindow, screen:NSScreen, duration:double)
;;     windowDidFailToExitFullScreen:  (window:NSWindow)
;;     window:willResizeForVersionBrowserWithMaxPreferredSize:maxAllowedSize:  (window:NSWindow, maxPreferredFrameSize:NSSize, maxAllowedFrameSize:NSSize)
;;     window:willEncodeRestorableState:  (window:NSWindow, state:NSCoder)
;;     window:didDecodeRestorableState:  (window:NSWindow, state:NSCoder)
;;     windowDidResize:  (notification:NSNotification)
;;     windowDidExpose:  (notification:NSNotification)
;;     windowWillMove:  (notification:NSNotification)
;;     windowDidMove:  (notification:NSNotification)
;;     windowDidBecomeKey:  (notification:NSNotification)
;;     windowDidResignKey:  (notification:NSNotification)
;;     windowDidBecomeMain:  (notification:NSNotification)
;;     windowDidResignMain:  (notification:NSNotification)
;;     windowWillClose:  (notification:NSNotification)
;;     windowWillMiniaturize:  (notification:NSNotification)
;;     windowDidMiniaturize:  (notification:NSNotification)
;;     windowDidDeminiaturize:  (notification:NSNotification)
;;     windowDidUpdate:  (notification:NSNotification)
;;     windowDidChangeScreen:  (notification:NSNotification)
;;     windowDidChangeScreenProfile:  (notification:NSNotification)
;;     windowDidChangeBackingProperties:  (notification:NSNotification)
;;     windowWillBeginSheet:  (notification:NSNotification)
;;     windowDidEndSheet:  (notification:NSNotification)
;;     windowWillStartLiveResize:  (notification:NSNotification)
;;     windowDidEndLiveResize:  (notification:NSNotification)
;;     windowWillEnterFullScreen:  (notification:NSNotification)
;;     windowDidEnterFullScreen:  (notification:NSNotification)
;;     windowWillExitFullScreen:  (notification:NSNotification)
;;     windowDidExitFullScreen:  (notification:NSNotification)
;;     windowWillEnterVersionBrowser:  (notification:NSNotification)
;;     windowDidEnterVersionBrowser:  (notification:NSNotification)
;;     windowWillExitVersionBrowser:  (notification:NSNotification)
;;     windowDidExitVersionBrowser:  (notification:NSNotification)
;;     windowDidChangeOcclusionState:  (notification:NSNotification)
;;   bool-returning (4):
;;     windowShouldClose:  (sender:NSWindow)
;;     windowShouldZoom:toFrame:  (window:NSWindow, newFrame:NSRect)
;;     window:shouldPopUpDocumentPathMenu:  (window:NSWindow, menu:NSMenu)
;;     window:shouldDragDocumentWithEvent:from:withPasteboard:  (window:NSWindow, event:NSEvent, dragImageLocation:NSPoint, pasteboard:NSPasteboard)
;;   id-returning (7):
;;     windowWillReturnFieldEditor:toObject:  (sender:NSWindow, client:id)
;;     windowWillReturnUndoManager:  (window:NSWindow)
;;     customWindowsToEnterFullScreenForWindow:  (window:NSWindow)
;;     customWindowsToExitFullScreenForWindow:  (window:NSWindow)
;;     customWindowsToEnterFullScreenForWindow:onScreen:  (window:NSWindow, screen:NSScreen)
;;     previewRepresentableActivityItemsForWindow:  (window:NSWindow)
;;     windowForSharingRequestFromWindow:  (window:NSWindow)

(require racket/contract
         "../../../runtime/delegate.rkt")

(provide/contract
  [make-nswindowdelegate (->* () () #:rest (listof (or/c string? procedure?)) any/c)]
  [nswindowdelegate-selectors (listof string?)])

;; All selectors in this protocol
(define nswindowdelegate-selectors
  '("windowShouldClose:"
    "windowWillReturnFieldEditor:toObject:"
    "windowWillResize:toSize:"
    "windowWillUseStandardFrame:defaultFrame:"
    "windowShouldZoom:toFrame:"
    "windowWillReturnUndoManager:"
    "window:willPositionSheet:usingRect:"
    "window:shouldPopUpDocumentPathMenu:"
    "window:shouldDragDocumentWithEvent:from:withPasteboard:"
    "window:willUseFullScreenContentSize:"
    "window:willUseFullScreenPresentationOptions:"
    "customWindowsToEnterFullScreenForWindow:"
    "window:startCustomAnimationToEnterFullScreenWithDuration:"
    "windowDidFailToEnterFullScreen:"
    "customWindowsToExitFullScreenForWindow:"
    "window:startCustomAnimationToExitFullScreenWithDuration:"
    "customWindowsToEnterFullScreenForWindow:onScreen:"
    "window:startCustomAnimationToEnterFullScreenOnScreen:withDuration:"
    "windowDidFailToExitFullScreen:"
    "window:willResizeForVersionBrowserWithMaxPreferredSize:maxAllowedSize:"
    "window:willEncodeRestorableState:"
    "window:didDecodeRestorableState:"
    "previewRepresentableActivityItemsForWindow:"
    "windowForSharingRequestFromWindow:"
    "windowDidResize:"
    "windowDidExpose:"
    "windowWillMove:"
    "windowDidMove:"
    "windowDidBecomeKey:"
    "windowDidResignKey:"
    "windowDidBecomeMain:"
    "windowDidResignMain:"
    "windowWillClose:"
    "windowWillMiniaturize:"
    "windowDidMiniaturize:"
    "windowDidDeminiaturize:"
    "windowDidUpdate:"
    "windowDidChangeScreen:"
    "windowDidChangeScreenProfile:"
    "windowDidChangeBackingProperties:"
    "windowWillBeginSheet:"
    "windowDidEndSheet:"
    "windowWillStartLiveResize:"
    "windowDidEndLiveResize:"
    "windowWillEnterFullScreen:"
    "windowDidEnterFullScreen:"
    "windowWillExitFullScreen:"
    "windowDidExitFullScreen:"
    "windowWillEnterVersionBrowser:"
    "windowDidEnterVersionBrowser:"
    "windowWillExitVersionBrowser:"
    "windowDidExitVersionBrowser:"
    "windowDidChangeOcclusionState:"))

;; Create a NSWindowDelegate delegate.
;; Pass selector string → handler procedure pairs.
;; Example:
;;   (make-nswindowdelegate
;;     "windowWillResize:toSize:" (lambda (sender frame-size) ...)
;;     "windowShouldClose:" (lambda (sender) ... #t)
;;   )
(define (make-nswindowdelegate . selector+handler-pairs)
  (apply make-delegate
    #:return-types
    (hash "windowShouldClose:" 'bool "windowShouldZoom:toFrame:" 'bool "window:shouldPopUpDocumentPathMenu:" 'bool "window:shouldDragDocumentWithEvent:from:withPasteboard:" 'bool "windowWillReturnFieldEditor:toObject:" 'id "windowWillReturnUndoManager:" 'id "customWindowsToEnterFullScreenForWindow:" 'id "customWindowsToExitFullScreenForWindow:" 'id "customWindowsToEnterFullScreenForWindow:onScreen:" 'id "previewRepresentableActivityItemsForWindow:" 'id "windowForSharingRequestFromWindow:" 'id)
    #:param-types
    (hash "windowShouldClose:" '(object) "windowWillReturnFieldEditor:toObject:" '(object object) "windowWillResize:toSize:" '(object pointer) "windowWillUseStandardFrame:defaultFrame:" '(object pointer) "windowShouldZoom:toFrame:" '(object pointer) "windowWillReturnUndoManager:" '(object) "window:willPositionSheet:usingRect:" '(object object pointer) "window:shouldPopUpDocumentPathMenu:" '(object object) "window:shouldDragDocumentWithEvent:from:withPasteboard:" '(object object pointer object) "window:willUseFullScreenContentSize:" '(object pointer) "window:willUseFullScreenPresentationOptions:" '(object pointer) "customWindowsToEnterFullScreenForWindow:" '(object) "window:startCustomAnimationToEnterFullScreenWithDuration:" '(object pointer) "windowDidFailToEnterFullScreen:" '(object) "customWindowsToExitFullScreenForWindow:" '(object) "window:startCustomAnimationToExitFullScreenWithDuration:" '(object pointer) "customWindowsToEnterFullScreenForWindow:onScreen:" '(object object) "window:startCustomAnimationToEnterFullScreenOnScreen:withDuration:" '(object object pointer) "windowDidFailToExitFullScreen:" '(object) "window:willResizeForVersionBrowserWithMaxPreferredSize:maxAllowedSize:" '(object pointer pointer) "window:willEncodeRestorableState:" '(object object) "window:didDecodeRestorableState:" '(object object) "previewRepresentableActivityItemsForWindow:" '(object) "windowForSharingRequestFromWindow:" '(object) "windowDidResize:" '(object) "windowDidExpose:" '(object) "windowWillMove:" '(object) "windowDidMove:" '(object) "windowDidBecomeKey:" '(object) "windowDidResignKey:" '(object) "windowDidBecomeMain:" '(object) "windowDidResignMain:" '(object) "windowWillClose:" '(object) "windowWillMiniaturize:" '(object) "windowDidMiniaturize:" '(object) "windowDidDeminiaturize:" '(object) "windowDidUpdate:" '(object) "windowDidChangeScreen:" '(object) "windowDidChangeScreenProfile:" '(object) "windowDidChangeBackingProperties:" '(object) "windowWillBeginSheet:" '(object) "windowDidEndSheet:" '(object) "windowWillStartLiveResize:" '(object) "windowDidEndLiveResize:" '(object) "windowWillEnterFullScreen:" '(object) "windowDidEnterFullScreen:" '(object) "windowWillExitFullScreen:" '(object) "windowDidExitFullScreen:" '(object) "windowWillEnterVersionBrowser:" '(object) "windowDidEnterVersionBrowser:" '(object) "windowWillExitVersionBrowser:" '(object) "windowDidExitVersionBrowser:" '(object) "windowDidChangeOcclusionState:" '(object))
    selector+handler-pairs))
