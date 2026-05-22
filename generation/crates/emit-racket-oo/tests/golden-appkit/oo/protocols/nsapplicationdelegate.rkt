#lang racket/base
;; Generated protocol definition for NSApplicationDelegate (AppKit)
;; Do not edit — regenerate from enriched IR
;;
;; NSApplicationDelegate defines 45 methods:
;;   void-returning (29):
;;     applicationShouldTerminate:  (sender:NSApplication)
;;     application:openURLs:  (application:NSApplication, urls:id)
;;     application:openFiles:  (sender:NSApplication, filenames:id)
;;     application:printFiles:withSettings:showPrintPanels:  (application:NSApplication, fileNames:id, printSettings:id, showPrintPanels:bool)
;;     application:didRegisterForRemoteNotificationsWithDeviceToken:  (application:NSApplication, deviceToken:NSData)
;;     application:didFailToRegisterForRemoteNotificationsWithError:  (application:NSApplication, error:NSError)
;;     application:didReceiveRemoteNotification:  (application:NSApplication, userInfo:id)
;;     application:willEncodeRestorableState:  (app:NSApplication, coder:NSCoder)
;;     application:didDecodeRestorableState:  (app:NSApplication, coder:NSCoder)
;;     application:didFailToContinueUserActivityWithType:error:  (application:NSApplication, userActivityType:NSString, error:NSError)
;;     application:didUpdateUserActivity:  (application:NSApplication, userActivity:NSUserActivity)
;;     application:userDidAcceptCloudKitShareWithMetadata:  (application:NSApplication, metadata:CKShareMetadata)
;;     applicationWillFinishLaunching:  (notification:NSNotification)
;;     applicationDidFinishLaunching:  (notification:NSNotification)
;;     applicationWillHide:  (notification:NSNotification)
;;     applicationDidHide:  (notification:NSNotification)
;;     applicationWillUnhide:  (notification:NSNotification)
;;     applicationDidUnhide:  (notification:NSNotification)
;;     applicationWillBecomeActive:  (notification:NSNotification)
;;     applicationDidBecomeActive:  (notification:NSNotification)
;;     applicationWillResignActive:  (notification:NSNotification)
;;     applicationDidResignActive:  (notification:NSNotification)
;;     applicationWillUpdate:  (notification:NSNotification)
;;     applicationDidUpdate:  (notification:NSNotification)
;;     applicationWillTerminate:  (notification:NSNotification)
;;     applicationDidChangeScreenParameters:  (notification:NSNotification)
;;     applicationDidChangeOcclusionState:  (notification:NSNotification)
;;     applicationProtectedDataWillBecomeUnavailable:  (notification:NSNotification)
;;     applicationProtectedDataDidBecomeAvailable:  (notification:NSNotification)
;;   bool-returning (13):
;;     application:openFile:  (sender:NSApplication, filename:NSString)
;;     application:openTempFile:  (sender:NSApplication, filename:NSString)
;;     applicationShouldOpenUntitledFile:  (sender:NSApplication)
;;     applicationOpenUntitledFile:  (sender:NSApplication)
;;     application:openFileWithoutUI:  (sender:id, filename:NSString)
;;     application:printFile:  (sender:NSApplication, filename:NSString)
;;     applicationShouldTerminateAfterLastWindowClosed:  (sender:NSApplication)
;;     applicationShouldHandleReopen:hasVisibleWindows:  (sender:NSApplication, hasVisibleWindows:bool)
;;     applicationSupportsSecureRestorableState:  (app:NSApplication)
;;     application:willContinueUserActivityWithType:  (application:NSApplication, userActivityType:NSString)
;;     application:continueUserActivity:restorationHandler:  (application:NSApplication, userActivity:NSUserActivity, restorationHandler:block)  — block param 2: async-copied (runtime-managed)
;;     application:delegateHandlesKey:  (sender:NSApplication, key:NSString)  — param 1: weak reference
;;     applicationShouldAutomaticallyLocalizeKeyEquivalents:  (application:NSApplication)
;;   id-returning (3):
;;     applicationDockMenu:  (sender:NSApplication)
;;     application:willPresentError:  (application:NSApplication, error:NSError)
;;     application:handlerForIntent:  (application:NSApplication, intent:INIntent)

(require racket/contract
         "../../../../runtime/delegate.rkt")

(provide/contract
  [make-nsapplicationdelegate (->* () () #:rest (listof (or/c string? procedure?)) any/c)]
  [nsapplicationdelegate-selectors (listof string?)])

;; All selectors in this protocol
(define nsapplicationdelegate-selectors
  '("applicationShouldTerminate:"
    "application:openURLs:"
    "application:openFile:"
    "application:openFiles:"
    "application:openTempFile:"
    "applicationShouldOpenUntitledFile:"
    "applicationOpenUntitledFile:"
    "application:openFileWithoutUI:"
    "application:printFile:"
    "application:printFiles:withSettings:showPrintPanels:"
    "applicationShouldTerminateAfterLastWindowClosed:"
    "applicationShouldHandleReopen:hasVisibleWindows:"
    "applicationDockMenu:"
    "application:willPresentError:"
    "application:didRegisterForRemoteNotificationsWithDeviceToken:"
    "application:didFailToRegisterForRemoteNotificationsWithError:"
    "application:didReceiveRemoteNotification:"
    "applicationSupportsSecureRestorableState:"
    "application:handlerForIntent:"
    "application:willEncodeRestorableState:"
    "application:didDecodeRestorableState:"
    "application:willContinueUserActivityWithType:"
    "application:continueUserActivity:restorationHandler:"
    "application:didFailToContinueUserActivityWithType:error:"
    "application:didUpdateUserActivity:"
    "application:userDidAcceptCloudKitShareWithMetadata:"
    "application:delegateHandlesKey:"
    "applicationShouldAutomaticallyLocalizeKeyEquivalents:"
    "applicationWillFinishLaunching:"
    "applicationDidFinishLaunching:"
    "applicationWillHide:"
    "applicationDidHide:"
    "applicationWillUnhide:"
    "applicationDidUnhide:"
    "applicationWillBecomeActive:"
    "applicationDidBecomeActive:"
    "applicationWillResignActive:"
    "applicationDidResignActive:"
    "applicationWillUpdate:"
    "applicationDidUpdate:"
    "applicationWillTerminate:"
    "applicationDidChangeScreenParameters:"
    "applicationDidChangeOcclusionState:"
    "applicationProtectedDataWillBecomeUnavailable:"
    "applicationProtectedDataDidBecomeAvailable:"))

;; Create a NSApplicationDelegate delegate.
;; Pass selector string → handler procedure pairs.
;; Example:
;;   (make-nsapplicationdelegate
;;     "applicationShouldTerminate:" (lambda (sender) ...)
;;     "application:openFile:" (lambda (sender filename) ... #t)
;;   )
(define (make-nsapplicationdelegate . selector+handler-pairs)
  (apply make-delegate
    #:return-types
    (hash "application:openFile:" 'bool "application:openTempFile:" 'bool "applicationShouldOpenUntitledFile:" 'bool "applicationOpenUntitledFile:" 'bool "application:openFileWithoutUI:" 'bool "application:printFile:" 'bool "applicationShouldTerminateAfterLastWindowClosed:" 'bool "applicationShouldHandleReopen:hasVisibleWindows:" 'bool "applicationSupportsSecureRestorableState:" 'bool "application:willContinueUserActivityWithType:" 'bool "application:continueUserActivity:restorationHandler:" 'bool "application:delegateHandlesKey:" 'bool "applicationShouldAutomaticallyLocalizeKeyEquivalents:" 'bool "applicationDockMenu:" 'id "application:willPresentError:" 'id "application:handlerForIntent:" 'id)
    #:param-types
    (hash "applicationShouldTerminate:" '(object) "application:openURLs:" '(object object) "application:openFile:" '(object object) "application:openFiles:" '(object object) "application:openTempFile:" '(object object) "applicationShouldOpenUntitledFile:" '(object) "applicationOpenUntitledFile:" '(object) "application:openFileWithoutUI:" '(object object) "application:printFile:" '(object object) "application:printFiles:withSettings:showPrintPanels:" '(object object object bool) "applicationShouldTerminateAfterLastWindowClosed:" '(object) "applicationShouldHandleReopen:hasVisibleWindows:" '(object bool) "applicationDockMenu:" '(object) "application:willPresentError:" '(object object) "application:didRegisterForRemoteNotificationsWithDeviceToken:" '(object object) "application:didFailToRegisterForRemoteNotificationsWithError:" '(object object) "application:didReceiveRemoteNotification:" '(object object) "applicationSupportsSecureRestorableState:" '(object) "application:handlerForIntent:" '(object object) "application:willEncodeRestorableState:" '(object object) "application:didDecodeRestorableState:" '(object object) "application:willContinueUserActivityWithType:" '(object object) "application:continueUserActivity:restorationHandler:" '(object object pointer) "application:didFailToContinueUserActivityWithType:error:" '(object object object) "application:didUpdateUserActivity:" '(object object) "application:userDidAcceptCloudKitShareWithMetadata:" '(object object) "application:delegateHandlesKey:" '(object object) "applicationShouldAutomaticallyLocalizeKeyEquivalents:" '(object) "applicationWillFinishLaunching:" '(object) "applicationDidFinishLaunching:" '(object) "applicationWillHide:" '(object) "applicationDidHide:" '(object) "applicationWillUnhide:" '(object) "applicationDidUnhide:" '(object) "applicationWillBecomeActive:" '(object) "applicationDidBecomeActive:" '(object) "applicationWillResignActive:" '(object) "applicationDidResignActive:" '(object) "applicationWillUpdate:" '(object) "applicationDidUpdate:" '(object) "applicationWillTerminate:" '(object) "applicationDidChangeScreenParameters:" '(object) "applicationDidChangeOcclusionState:" '(object) "applicationProtectedDataWillBecomeUnavailable:" '(object) "applicationProtectedDataDidBecomeAvailable:" '(object))
    selector+handler-pairs))
