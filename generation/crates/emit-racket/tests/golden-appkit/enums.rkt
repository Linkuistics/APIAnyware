#lang racket/base
;; Generated enum definitions for AppKit

(provide (all-defined-out))

;; NSAccessibilityAnnotationPosition
(define NSAccessibilityAnnotationPositionFullRange 0)
(define NSAccessibilityAnnotationPositionStart 1)
(define NSAccessibilityAnnotationPositionEnd 2)

;; NSAccessibilityCustomRotorSearchDirection
(define NSAccessibilityCustomRotorSearchDirectionPrevious 0)
(define NSAccessibilityCustomRotorSearchDirectionNext 1)

;; NSAccessibilityCustomRotorType
(define NSAccessibilityCustomRotorTypeCustom 0)
(define NSAccessibilityCustomRotorTypeAny 1)
(define NSAccessibilityCustomRotorTypeAnnotation 2)
(define NSAccessibilityCustomRotorTypeBoldText 3)
(define NSAccessibilityCustomRotorTypeHeading 4)
(define NSAccessibilityCustomRotorTypeHeadingLevel1 5)
(define NSAccessibilityCustomRotorTypeHeadingLevel2 6)
(define NSAccessibilityCustomRotorTypeHeadingLevel3 7)
(define NSAccessibilityCustomRotorTypeHeadingLevel4 8)
(define NSAccessibilityCustomRotorTypeHeadingLevel5 9)
(define NSAccessibilityCustomRotorTypeHeadingLevel6 10)
(define NSAccessibilityCustomRotorTypeImage 11)
(define NSAccessibilityCustomRotorTypeItalicText 12)
(define NSAccessibilityCustomRotorTypeLandmark 13)
(define NSAccessibilityCustomRotorTypeLink 14)
(define NSAccessibilityCustomRotorTypeList 15)
(define NSAccessibilityCustomRotorTypeMisspelledWord 16)
(define NSAccessibilityCustomRotorTypeTable 17)
(define NSAccessibilityCustomRotorTypeTextField 18)
(define NSAccessibilityCustomRotorTypeUnderlinedText 19)
(define NSAccessibilityCustomRotorTypeVisitedLink 20)
(define NSAccessibilityCustomRotorTypeAudiograph 21)

;; NSAccessibilityOrientation
(define NSAccessibilityOrientationUnknown 0)
(define NSAccessibilityOrientationVertical 1)
(define NSAccessibilityOrientationHorizontal 2)

;; NSAccessibilityPriorityLevel
(define NSAccessibilityPriorityLow 10)
(define NSAccessibilityPriorityMedium 50)
(define NSAccessibilityPriorityHigh 90)

;; NSAccessibilityRulerMarkerType
(define NSAccessibilityRulerMarkerTypeUnknown 0)
(define NSAccessibilityRulerMarkerTypeTabStopLeft 1)
(define NSAccessibilityRulerMarkerTypeTabStopRight 2)
(define NSAccessibilityRulerMarkerTypeTabStopCenter 3)
(define NSAccessibilityRulerMarkerTypeTabStopDecimal 4)
(define NSAccessibilityRulerMarkerTypeIndentHead 5)
(define NSAccessibilityRulerMarkerTypeIndentTail 6)
(define NSAccessibilityRulerMarkerTypeIndentFirstLine 7)

;; NSAccessibilitySortDirection
(define NSAccessibilitySortDirectionUnknown 0)
(define NSAccessibilitySortDirectionAscending 1)
(define NSAccessibilitySortDirectionDescending 2)

;; NSAccessibilityUnits
(define NSAccessibilityUnitsUnknown 0)
(define NSAccessibilityUnitsInches 1)
(define NSAccessibilityUnitsCentimeters 2)
(define NSAccessibilityUnitsPoints 3)
(define NSAccessibilityUnitsPicas 4)

;; NSAlertStyle
(define NSAlertStyleWarning 0)
(define NSAlertStyleInformational 1)
(define NSAlertStyleCritical 2)

;; NSAnimationBlockingMode
(define NSAnimationBlocking 0)
(define NSAnimationNonblocking 1)
(define NSAnimationNonblockingThreaded 2)

;; NSAnimationCurve
(define NSAnimationEaseInOut 0)
(define NSAnimationEaseIn 1)
(define NSAnimationEaseOut 2)
(define NSAnimationLinear 3)

;; NSAnimationEffect
(define NSAnimationEffectDisappearingItemDefault 0)
(define NSAnimationEffectPoof 10)

;; NSApplicationActivationOptions
(define NSApplicationActivateAllWindows 1)
(define NSApplicationActivateIgnoringOtherApps 2)

;; NSApplicationActivationPolicy
(define NSApplicationActivationPolicyRegular 0)
(define NSApplicationActivationPolicyAccessory 1)
(define NSApplicationActivationPolicyProhibited 2)

;; NSApplicationDelegateReply
(define NSApplicationDelegateReplySuccess 0)
(define NSApplicationDelegateReplyCancel 1)
(define NSApplicationDelegateReplyFailure 2)

;; NSApplicationOcclusionState
(define NSApplicationOcclusionStateVisible 2)

;; NSApplicationPresentationOptions
(define NSApplicationPresentationDefault 0)
(define NSApplicationPresentationAutoHideDock 1)
(define NSApplicationPresentationHideDock 2)
(define NSApplicationPresentationAutoHideMenuBar 4)
(define NSApplicationPresentationHideMenuBar 8)
(define NSApplicationPresentationDisableAppleMenu 16)
(define NSApplicationPresentationDisableProcessSwitching 32)
(define NSApplicationPresentationDisableForceQuit 64)
(define NSApplicationPresentationDisableSessionTermination 128)
(define NSApplicationPresentationDisableHideApplication 256)
(define NSApplicationPresentationDisableMenuBarTransparency 512)
(define NSApplicationPresentationFullScreen 1024)
(define NSApplicationPresentationAutoHideToolbar 2048)
(define NSApplicationPresentationDisableCursorLocationAssistance 4096)

;; NSApplicationPrintReply
(define NSPrintingCancelled 0)
(define NSPrintingSuccess 1)
(define NSPrintingReplyLater 2)
(define NSPrintingFailure 3)

;; NSApplicationTerminateReply
(define NSTerminateCancel 0)
(define NSTerminateNow 1)
(define NSTerminateLater 2)

;; NSAutoresizingMaskOptions
(define NSViewNotSizable 0)
(define NSViewMinXMargin 1)
(define NSViewWidthSizable 2)
(define NSViewMaxXMargin 4)
(define NSViewMinYMargin 8)
(define NSViewHeightSizable 16)
(define NSViewMaxYMargin 32)

;; NSBackgroundStyle
(define NSBackgroundStyleNormal 0)
(define NSBackgroundStyleEmphasized 1)
(define NSBackgroundStyleRaised 2)
(define NSBackgroundStyleLowered 3)

;; NSBackingStoreType
(define NSBackingStoreRetained 0)
(define NSBackingStoreNonretained 1)
(define NSBackingStoreBuffered 2)

;; NSBezelStyle
(define NSBezelStyleAutomatic 0)
(define NSBezelStylePush 1)
(define NSBezelStyleFlexiblePush 2)
(define NSBezelStyleDisclosure 5)
(define NSBezelStyleCircular 7)
(define NSBezelStyleHelpButton 9)
(define NSBezelStyleSmallSquare 10)
(define NSBezelStyleToolbar 11)
(define NSBezelStyleAccessoryBarAction 12)
(define NSBezelStyleAccessoryBar 13)
(define NSBezelStylePushDisclosure 14)
(define NSBezelStyleBadge 15)
(define NSBezelStyleGlass 16)
(define NSBezelStyleShadowlessSquare 6)
(define NSBezelStyleTexturedSquare 8)
(define NSBezelStyleRounded 1)
(define NSBezelStyleRegularSquare 2)
(define NSBezelStyleTexturedRounded 11)
(define NSBezelStyleRoundRect 12)
(define NSBezelStyleRecessed 13)
(define NSBezelStyleRoundedDisclosure 14)
(define NSBezelStyleInline 15)

;; NSBezierPathElement
(define NSBezierPathElementMoveTo 0)
(define NSBezierPathElementLineTo 1)
(define NSBezierPathElementCubicCurveTo 2)
(define NSBezierPathElementClosePath 3)
(define NSBezierPathElementQuadraticCurveTo 4)
(define NSBezierPathElementCurveTo 2)

;; NSBitmapFormat
(define NSBitmapFormatAlphaFirst 1)
(define NSBitmapFormatAlphaNonpremultiplied 2)
(define NSBitmapFormatFloatingPointSamples 4)
(define NSBitmapFormatSixteenBitLittleEndian 256)
(define NSBitmapFormatThirtyTwoBitLittleEndian 512)
(define NSBitmapFormatSixteenBitBigEndian 1024)
(define NSBitmapFormatThirtyTwoBitBigEndian 2048)

;; NSBitmapImageFileType
(define NSBitmapImageFileTypeTIFF 0)
(define NSBitmapImageFileTypeBMP 1)
(define NSBitmapImageFileTypeGIF 2)
(define NSBitmapImageFileTypeJPEG 3)
(define NSBitmapImageFileTypePNG 4)
(define NSBitmapImageFileTypeJPEG2000 5)

;; NSBorderType
(define NSNoBorder 0)
(define NSLineBorder 1)
(define NSBezelBorder 2)
(define NSGrooveBorder 3)

;; NSBoxType
(define NSBoxPrimary 0)
(define NSBoxSeparator 2)
(define NSBoxCustom 4)

;; NSBrowserColumnResizingType
(define NSBrowserNoColumnResizing 0)
(define NSBrowserAutoColumnResizing 1)
(define NSBrowserUserColumnResizing 2)

;; NSBrowserDropOperation
(define NSBrowserDropOn 0)
(define NSBrowserDropAbove 1)

;; NSButtonType
(define NSButtonTypeMomentaryLight 0)
(define NSButtonTypePushOnPushOff 1)
(define NSButtonTypeToggle 2)
(define NSButtonTypeSwitch 3)
(define NSButtonTypeRadio 4)
(define NSButtonTypeMomentaryChange 5)
(define NSButtonTypeOnOff 6)
(define NSButtonTypeMomentaryPushIn 7)
(define NSButtonTypeAccelerator 8)
(define NSButtonTypeMultiLevelAccelerator 9)

;; NSCellAttribute
(define NSCellDisabled 0)
(define NSCellState 1)
(define NSPushInCell 2)
(define NSCellEditable 3)
(define NSChangeGrayCell 4)
(define NSCellHighlighted 5)
(define NSCellLightsByContents 6)
(define NSCellLightsByGray 7)
(define NSChangeBackgroundCell 8)
(define NSCellLightsByBackground 9)
(define NSCellIsBordered 10)
(define NSCellHasOverlappingImage 11)
(define NSCellHasImageHorizontal 12)
(define NSCellHasImageOnLeftOrBottom 13)
(define NSCellChangesContents 14)
(define NSCellIsInsetButton 15)
(define NSCellAllowsMixedState 16)

;; NSCellHitResult
(define NSCellHitNone 0)
(define NSCellHitContentArea 1)
(define NSCellHitEditableTextArea 2)
(define NSCellHitTrackableArea 4)

;; NSCellImagePosition
(define NSNoImage 0)
(define NSImageOnly 1)
(define NSImageLeft 2)
(define NSImageRight 3)
(define NSImageBelow 4)
(define NSImageAbove 5)
(define NSImageOverlaps 6)
(define NSImageLeading 7)
(define NSImageTrailing 8)

;; NSCellStyleMask
(define NSNoCellMask 0)
(define NSContentsCellMask 1)
(define NSPushInCellMask 2)
(define NSChangeGrayCellMask 4)
(define NSChangeBackgroundCellMask 8)

;; NSCellType
(define NSNullCellType 0)
(define NSTextCellType 1)
(define NSImageCellType 2)

;; NSCharacterCollection
(define NSIdentityMappingCharacterCollection 0)
(define NSAdobeCNS1CharacterCollection 1)
(define NSAdobeGB1CharacterCollection 2)
(define NSAdobeJapan1CharacterCollection 3)
(define NSAdobeJapan2CharacterCollection 4)
(define NSAdobeKorea1CharacterCollection 5)

;; NSCloudKitSharingServiceOptions
(define NSCloudKitSharingServiceStandard 0)
(define NSCloudKitSharingServiceAllowPublic 1)
(define NSCloudKitSharingServiceAllowPrivate 2)
(define NSCloudKitSharingServiceAllowReadOnly 16)
(define NSCloudKitSharingServiceAllowReadWrite 32)

;; NSCollectionElementCategory
(define NSCollectionElementCategoryItem 0)
(define NSCollectionElementCategorySupplementaryView 1)
(define NSCollectionElementCategoryDecorationView 2)
(define NSCollectionElementCategoryInterItemGap 3)

;; NSCollectionLayoutSectionOrthogonalScrollingBehavior
(define NSCollectionLayoutSectionOrthogonalScrollingBehaviorNone 0)
(define NSCollectionLayoutSectionOrthogonalScrollingBehaviorContinuous 1)
(define NSCollectionLayoutSectionOrthogonalScrollingBehaviorContinuousGroupLeadingBoundary 2)
(define NSCollectionLayoutSectionOrthogonalScrollingBehaviorPaging 3)
(define NSCollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging 4)
(define NSCollectionLayoutSectionOrthogonalScrollingBehaviorGroupPagingCentered 5)

;; NSCollectionUpdateAction
(define NSCollectionUpdateActionInsert 0)
(define NSCollectionUpdateActionDelete 1)
(define NSCollectionUpdateActionReload 2)
(define NSCollectionUpdateActionMove 3)
(define NSCollectionUpdateActionNone 4)

;; NSCollectionViewDropOperation
(define NSCollectionViewDropOn 0)
(define NSCollectionViewDropBefore 1)

;; NSCollectionViewItemHighlightState
(define NSCollectionViewItemHighlightNone 0)
(define NSCollectionViewItemHighlightForSelection 1)
(define NSCollectionViewItemHighlightForDeselection 2)
(define NSCollectionViewItemHighlightAsDropTarget 3)

;; NSCollectionViewScrollDirection
(define NSCollectionViewScrollDirectionVertical 0)
(define NSCollectionViewScrollDirectionHorizontal 1)

;; NSCollectionViewScrollPosition
(define NSCollectionViewScrollPositionNone 0)
(define NSCollectionViewScrollPositionTop 1)
(define NSCollectionViewScrollPositionCenteredVertically 2)
(define NSCollectionViewScrollPositionBottom 4)
(define NSCollectionViewScrollPositionNearestHorizontalEdge 512)
(define NSCollectionViewScrollPositionLeft 8)
(define NSCollectionViewScrollPositionCenteredHorizontally 16)
(define NSCollectionViewScrollPositionRight 32)
(define NSCollectionViewScrollPositionLeadingEdge 64)
(define NSCollectionViewScrollPositionTrailingEdge 128)
(define NSCollectionViewScrollPositionNearestVerticalEdge 256)

;; NSColorPanelMode
(define NSColorPanelModeNone -1)
(define NSColorPanelModeGray 0)
(define NSColorPanelModeRGB 1)
(define NSColorPanelModeCMYK 2)
(define NSColorPanelModeHSB 3)
(define NSColorPanelModeCustomPalette 4)
(define NSColorPanelModeColorList 5)
(define NSColorPanelModeWheel 6)
(define NSColorPanelModeCrayon 7)

;; NSColorPanelOptions
(define NSColorPanelGrayModeMask 1)
(define NSColorPanelRGBModeMask 2)
(define NSColorPanelCMYKModeMask 4)
(define NSColorPanelHSBModeMask 8)
(define NSColorPanelCustomPaletteModeMask 16)
(define NSColorPanelColorListModeMask 32)
(define NSColorPanelWheelModeMask 64)
(define NSColorPanelCrayonModeMask 128)
(define NSColorPanelAllModesMask 65535)

;; NSColorRenderingIntent
(define NSColorRenderingIntentDefault 0)
(define NSColorRenderingIntentAbsoluteColorimetric 1)
(define NSColorRenderingIntentRelativeColorimetric 2)
(define NSColorRenderingIntentPerceptual 3)
(define NSColorRenderingIntentSaturation 4)

;; NSColorSpaceModel
(define NSColorSpaceModelUnknown -1)
(define NSColorSpaceModelGray 0)
(define NSColorSpaceModelRGB 1)
(define NSColorSpaceModelCMYK 2)
(define NSColorSpaceModelLAB 3)
(define NSColorSpaceModelDeviceN 4)
(define NSColorSpaceModelIndexed 5)
(define NSColorSpaceModelPatterned 6)

;; NSColorSystemEffect
(define NSColorSystemEffectNone 0)
(define NSColorSystemEffectPressed 1)
(define NSColorSystemEffectDeepPressed 2)
(define NSColorSystemEffectDisabled 3)
(define NSColorSystemEffectRollover 4)

;; NSColorType
(define NSColorTypeComponentBased 0)
(define NSColorTypePattern 1)
(define NSColorTypeCatalog 2)

;; NSColorWellStyle
(define NSColorWellStyleDefault 0)
(define NSColorWellStyleMinimal 1)
(define NSColorWellStyleExpanded 2)

;; NSComboButtonStyle
(define NSComboButtonStyleSplit 0)
(define NSComboButtonStyleUnified 1)

;; NSCompositingOperation
(define NSCompositingOperationClear 0)
(define NSCompositingOperationCopy 1)
(define NSCompositingOperationSourceOver 2)
(define NSCompositingOperationSourceIn 3)
(define NSCompositingOperationSourceOut 4)
(define NSCompositingOperationSourceAtop 5)
(define NSCompositingOperationDestinationOver 6)
(define NSCompositingOperationDestinationIn 7)
(define NSCompositingOperationDestinationOut 8)
(define NSCompositingOperationDestinationAtop 9)
(define NSCompositingOperationXOR 10)
(define NSCompositingOperationPlusDarker 11)
(define NSCompositingOperationHighlight 12)
(define NSCompositingOperationPlusLighter 13)
(define NSCompositingOperationMultiply 14)
(define NSCompositingOperationScreen 15)
(define NSCompositingOperationOverlay 16)
(define NSCompositingOperationDarken 17)
(define NSCompositingOperationLighten 18)
(define NSCompositingOperationColorDodge 19)
(define NSCompositingOperationColorBurn 20)
(define NSCompositingOperationSoftLight 21)
(define NSCompositingOperationHardLight 22)
(define NSCompositingOperationDifference 23)
(define NSCompositingOperationExclusion 24)
(define NSCompositingOperationHue 25)
(define NSCompositingOperationSaturation 26)
(define NSCompositingOperationColor 27)
(define NSCompositingOperationLuminosity 28)

;; NSControlBorderShape
(define NSControlBorderShapeAutomatic 0)
(define NSControlBorderShapeCapsule 1)
(define NSControlBorderShapeRoundedRectangle 2)
(define NSControlBorderShapeCircle 3)

;; NSControlCharacterAction
(define NSControlCharacterActionZeroAdvancement 1)
(define NSControlCharacterActionWhitespace 2)
(define NSControlCharacterActionHorizontalTab 4)
(define NSControlCharacterActionLineBreak 8)
(define NSControlCharacterActionParagraphBreak 16)
(define NSControlCharacterActionContainerBreak 32)

;; NSControlSize
(define NSControlSizeRegular 0)
(define NSControlSizeSmall 1)
(define NSControlSizeMini 2)
(define NSControlSizeLarge 3)
(define NSControlSizeExtraLarge 4)

;; NSControlTint
(define NSDefaultControlTint 0)
(define NSBlueControlTint 1)
(define NSGraphiteControlTint 6)
(define NSClearControlTint 7)

;; NSCorrectionIndicatorType
(define NSCorrectionIndicatorTypeDefault 0)
(define NSCorrectionIndicatorTypeReversion 1)
(define NSCorrectionIndicatorTypeGuesses 2)

;; NSCorrectionResponse
(define NSCorrectionResponseNone 0)
(define NSCorrectionResponseAccepted 1)
(define NSCorrectionResponseRejected 2)
(define NSCorrectionResponseIgnored 3)
(define NSCorrectionResponseEdited 4)
(define NSCorrectionResponseReverted 5)

;; NSCursorFrameResizeDirections
(define NSCursorFrameResizeDirectionsInward 1)
(define NSCursorFrameResizeDirectionsOutward 2)
(define NSCursorFrameResizeDirectionsAll 3)

;; NSCursorFrameResizePosition
(define NSCursorFrameResizePositionTop 1)
(define NSCursorFrameResizePositionLeft 2)
(define NSCursorFrameResizePositionBottom 4)
(define NSCursorFrameResizePositionRight 8)
(define NSCursorFrameResizePositionTopLeft 3)
(define NSCursorFrameResizePositionTopRight 9)
(define NSCursorFrameResizePositionBottomLeft 6)
(define NSCursorFrameResizePositionBottomRight 12)

;; NSDatePickerElementFlags
(define NSDatePickerElementFlagHourMinute 12)
(define NSDatePickerElementFlagHourMinuteSecond 14)
(define NSDatePickerElementFlagTimeZone 16)
(define NSDatePickerElementFlagYearMonth 192)
(define NSDatePickerElementFlagYearMonthDay 224)
(define NSDatePickerElementFlagEra 256)

;; NSDatePickerMode
(define NSDatePickerModeSingle 0)
(define NSDatePickerModeRange 1)

;; NSDatePickerStyle
(define NSDatePickerStyleTextFieldAndStepper 0)
(define NSDatePickerStyleClockAndCalendar 1)
(define NSDatePickerStyleTextField 2)

;; NSDirectionalRectEdge
(define NSDirectionalRectEdgeNone 0)
(define NSDirectionalRectEdgeTop 1)
(define NSDirectionalRectEdgeLeading 2)
(define NSDirectionalRectEdgeBottom 4)
(define NSDirectionalRectEdgeTrailing 8)
(define NSDirectionalRectEdgeAll 15)

;; NSDisplayGamut
(define NSDisplayGamutSRGB 1)
(define NSDisplayGamutP3 2)

;; NSDocumentChangeType
(define NSChangeDone 0)
(define NSChangeUndone 1)
(define NSChangeRedone 5)
(define NSChangeCleared 2)
(define NSChangeReadOtherContents 3)
(define NSChangeAutosaved 4)
(define NSChangeDiscardable 256)

;; NSDragOperation
(define NSDragOperationNone 0)
(define NSDragOperationCopy 1)
(define NSDragOperationLink 2)
(define NSDragOperationGeneric 4)
(define NSDragOperationPrivate 8)
(define NSDragOperationMove 16)
(define NSDragOperationDelete 32)
(define NSDragOperationAll_Obsolete 15)
(define NSDragOperationAll 15)

;; NSDraggingContext
(define NSDraggingContextOutsideApplication 0)
(define NSDraggingContextWithinApplication 1)

;; NSDraggingFormation
(define NSDraggingFormationDefault 0)
(define NSDraggingFormationNone 1)
(define NSDraggingFormationPile 2)
(define NSDraggingFormationList 3)
(define NSDraggingFormationStack 4)

;; NSDraggingItemEnumerationOptions
(define NSDraggingItemEnumerationConcurrent 1)
(define NSDraggingItemEnumerationClearNonenumeratedImages 65536)

;; NSDrawerState
(define NSDrawerClosedState 0)
(define NSDrawerOpeningState 1)
(define NSDrawerOpenState 2)
(define NSDrawerClosingState 3)

;; NSEventButtonMask
(define NSEventButtonMaskPenTip 1)
(define NSEventButtonMaskPenLowerSide 2)
(define NSEventButtonMaskPenUpperSide 4)

;; NSEventGestureAxis
(define NSEventGestureAxisNone 0)
(define NSEventGestureAxisHorizontal 1)
(define NSEventGestureAxisVertical 2)

;; NSEventMask
(define NSEventMaskLeftMouseDown 2)
(define NSEventMaskLeftMouseUp 4)
(define NSEventMaskRightMouseDown 8)
(define NSEventMaskRightMouseUp 16)
(define NSEventMaskMouseMoved 32)
(define NSEventMaskLeftMouseDragged 64)
(define NSEventMaskRightMouseDragged 128)
(define NSEventMaskMouseEntered 256)
(define NSEventMaskMouseExited 512)
(define NSEventMaskKeyDown 1024)
(define NSEventMaskKeyUp 2048)
(define NSEventMaskFlagsChanged 4096)
(define NSEventMaskAppKitDefined 8192)
(define NSEventMaskSystemDefined 16384)
(define NSEventMaskApplicationDefined 32768)
(define NSEventMaskPeriodic 65536)
(define NSEventMaskCursorUpdate 131072)
(define NSEventMaskScrollWheel 4194304)
(define NSEventMaskTabletPoint 8388608)
(define NSEventMaskTabletProximity 16777216)
(define NSEventMaskOtherMouseDown 33554432)
(define NSEventMaskOtherMouseUp 67108864)
(define NSEventMaskOtherMouseDragged 134217728)
(define NSEventMaskGesture 536870912)
(define NSEventMaskMagnify 1073741824)
(define NSEventMaskSwipe 2147483648)
(define NSEventMaskRotate 262144)
(define NSEventMaskBeginGesture 524288)
(define NSEventMaskEndGesture 1048576)
(define NSEventMaskSmartMagnify 4294967296)
(define NSEventMaskPressure 17179869184)
(define NSEventMaskDirectTouch 137438953472)
(define NSEventMaskChangeMode 274877906944)
(define NSEventMaskMouseCancelled 1099511627776)

;; NSEventModifierFlags
(define NSEventModifierFlagCapsLock 65536)
(define NSEventModifierFlagShift 131072)
(define NSEventModifierFlagControl 262144)
(define NSEventModifierFlagOption 524288)
(define NSEventModifierFlagCommand 1048576)
(define NSEventModifierFlagNumericPad 2097152)
(define NSEventModifierFlagHelp 4194304)
(define NSEventModifierFlagFunction 8388608)
(define NSEventModifierFlagDeviceIndependentFlagsMask 4294901760)

;; NSEventPhase
(define NSEventPhaseNone 0)
(define NSEventPhaseBegan 1)
(define NSEventPhaseStationary 2)
(define NSEventPhaseChanged 4)
(define NSEventPhaseEnded 8)
(define NSEventPhaseCancelled 16)
(define NSEventPhaseMayBegin 32)

;; NSEventSubtype
(define NSEventSubtypeWindowExposed 0)
(define NSEventSubtypeApplicationActivated 1)
(define NSEventSubtypeApplicationDeactivated 2)
(define NSEventSubtypeWindowMoved 4)
(define NSEventSubtypeScreenChanged 8)
(define NSEventSubtypePowerOff 1)
(define NSEventSubtypeMouseEvent 0)
(define NSEventSubtypeTabletPoint 1)
(define NSEventSubtypeTabletProximity 2)
(define NSEventSubtypeTouch 3)

;; NSEventSwipeTrackingOptions
(define NSEventSwipeTrackingLockDirection 1)
(define NSEventSwipeTrackingClampGestureAmount 2)

;; NSEventType
(define NSEventTypeLeftMouseDown 1)
(define NSEventTypeLeftMouseUp 2)
(define NSEventTypeRightMouseDown 3)
(define NSEventTypeRightMouseUp 4)
(define NSEventTypeMouseMoved 5)
(define NSEventTypeLeftMouseDragged 6)
(define NSEventTypeRightMouseDragged 7)
(define NSEventTypeMouseEntered 8)
(define NSEventTypeMouseExited 9)
(define NSEventTypeKeyDown 10)
(define NSEventTypeKeyUp 11)
(define NSEventTypeFlagsChanged 12)
(define NSEventTypeAppKitDefined 13)
(define NSEventTypeSystemDefined 14)
(define NSEventTypeApplicationDefined 15)
(define NSEventTypePeriodic 16)
(define NSEventTypeCursorUpdate 17)
(define NSEventTypeScrollWheel 22)
(define NSEventTypeTabletPoint 23)
(define NSEventTypeTabletProximity 24)
(define NSEventTypeOtherMouseDown 25)
(define NSEventTypeOtherMouseUp 26)
(define NSEventTypeOtherMouseDragged 27)
(define NSEventTypeGesture 29)
(define NSEventTypeMagnify 30)
(define NSEventTypeSwipe 31)
(define NSEventTypeRotate 18)
(define NSEventTypeBeginGesture 19)
(define NSEventTypeEndGesture 20)
(define NSEventTypeSmartMagnify 32)
(define NSEventTypeQuickLook 33)
(define NSEventTypePressure 34)
(define NSEventTypeDirectTouch 37)
(define NSEventTypeChangeMode 38)
(define NSEventTypeMouseCancelled 40)

;; NSFindPanelAction
(define NSFindPanelActionShowFindPanel 1)
(define NSFindPanelActionNext 2)
(define NSFindPanelActionPrevious 3)
(define NSFindPanelActionReplaceAll 4)
(define NSFindPanelActionReplace 5)
(define NSFindPanelActionReplaceAndFind 6)
(define NSFindPanelActionSetFindString 7)
(define NSFindPanelActionReplaceAllInSelection 8)
(define NSFindPanelActionSelectAll 9)
(define NSFindPanelActionSelectAllInSelection 10)

;; NSFindPanelSubstringMatchType
(define NSFindPanelSubstringMatchTypeContains 0)
(define NSFindPanelSubstringMatchTypeStartsWith 1)
(define NSFindPanelSubstringMatchTypeFullWord 2)
(define NSFindPanelSubstringMatchTypeEndsWith 3)

;; NSFocusRingPlacement
(define NSFocusRingOnly 0)
(define NSFocusRingBelow 1)
(define NSFocusRingAbove 2)

;; NSFocusRingType
(define NSFocusRingTypeDefault 0)
(define NSFocusRingTypeNone 1)
(define NSFocusRingTypeExterior 2)

;; NSFontAction
(define NSNoFontChangeAction 0)
(define NSViaPanelFontAction 1)
(define NSAddTraitFontAction 2)
(define NSSizeUpFontAction 3)
(define NSSizeDownFontAction 4)
(define NSHeavierFontAction 5)
(define NSLighterFontAction 6)
(define NSRemoveTraitFontAction 7)

;; NSFontAssetRequestOptions
(define NSFontAssetRequestOptionUsesStandardUI 1)

;; NSFontCollectionOptions
(define NSFontCollectionApplicationOnlyMask 1)

;; NSFontCollectionVisibility
(define NSFontCollectionVisibilityProcess 1)
(define NSFontCollectionVisibilityUser 2)
(define NSFontCollectionVisibilityComputer 4)

;; NSFontDescriptorSymbolicTraits
(define NSFontDescriptorTraitItalic 1)
(define NSFontDescriptorTraitBold 2)
(define NSFontDescriptorTraitExpanded 32)
(define NSFontDescriptorTraitCondensed 64)
(define NSFontDescriptorTraitMonoSpace 1024)
(define NSFontDescriptorTraitVertical 2048)
(define NSFontDescriptorTraitUIOptimized 4096)
(define NSFontDescriptorTraitTightLeading 32768)
(define NSFontDescriptorTraitLooseLeading 65536)
(define NSFontDescriptorTraitEmphasized 2)
(define NSFontDescriptorClassMask 4026531840)
(define NSFontDescriptorClassUnknown 0)
(define NSFontDescriptorClassOldStyleSerifs 268435456)
(define NSFontDescriptorClassTransitionalSerifs 536870912)
(define NSFontDescriptorClassModernSerifs 805306368)
(define NSFontDescriptorClassClarendonSerifs 1073741824)
(define NSFontDescriptorClassSlabSerifs 1342177280)
(define NSFontDescriptorClassFreeformSerifs 1879048192)
(define NSFontDescriptorClassSansSerif 2147483648)
(define NSFontDescriptorClassOrnamentals 2415919104)
(define NSFontDescriptorClassScripts 2684354560)
(define NSFontDescriptorClassSymbolic 3221225472)

;; NSFontPanelModeMask
(define NSFontPanelModeMaskFace 1)
(define NSFontPanelModeMaskSize 2)
(define NSFontPanelModeMaskCollection 4)
(define NSFontPanelModeMaskUnderlineEffect 256)
(define NSFontPanelModeMaskStrikethroughEffect 512)
(define NSFontPanelModeMaskTextColorEffect 1024)
(define NSFontPanelModeMaskDocumentColorEffect 2048)
(define NSFontPanelModeMaskShadowEffect 4096)
(define NSFontPanelModeMaskAllEffects 1048320)
(define NSFontPanelModesMaskStandardModes 65535)
(define NSFontPanelModesMaskAllModes 4294967295)

;; NSFontRenderingMode
(define NSFontDefaultRenderingMode 0)
(define NSFontAntialiasedRenderingMode 1)
(define NSFontIntegerAdvancementsRenderingMode 2)
(define NSFontAntialiasedIntegerAdvancementsRenderingMode 3)

;; NSFontTraitMask
(define NSItalicFontMask 1)
(define NSBoldFontMask 2)
(define NSUnboldFontMask 4)
(define NSNonStandardCharacterSetFontMask 8)
(define NSNarrowFontMask 16)
(define NSExpandedFontMask 32)
(define NSCondensedFontMask 64)
(define NSSmallCapsFontMask 128)
(define NSPosterFontMask 256)
(define NSCompressedFontMask 512)
(define NSFixedPitchFontMask 1024)
(define NSUnitalicFontMask 16777216)

;; NSGestureRecognizerState
(define NSGestureRecognizerStatePossible 0)
(define NSGestureRecognizerStateBegan 1)
(define NSGestureRecognizerStateChanged 2)
(define NSGestureRecognizerStateEnded 3)
(define NSGestureRecognizerStateCancelled 4)
(define NSGestureRecognizerStateFailed 5)
(define NSGestureRecognizerStateRecognized 3)

;; NSGlassEffectViewStyle
(define NSGlassEffectViewStyleRegular 0)
(define NSGlassEffectViewStyleClear 1)

;; NSGlyphInscription
(define NSGlyphInscribeBase 0)
(define NSGlyphInscribeBelow 1)
(define NSGlyphInscribeAbove 2)
(define NSGlyphInscribeOverstrike 3)
(define NSGlyphInscribeOverBelow 4)

;; NSGlyphProperty
(define NSGlyphPropertyNull 1)
(define NSGlyphPropertyControlCharacter 2)
(define NSGlyphPropertyElastic 4)
(define NSGlyphPropertyNonBaseCharacter 8)

;; NSGradientDrawingOptions
(define NSGradientDrawsBeforeStartingLocation 1)
(define NSGradientDrawsAfterEndingLocation 2)

;; NSGradientType
(define NSGradientNone 0)
(define NSGradientConcaveWeak 1)
(define NSGradientConcaveStrong 2)
(define NSGradientConvexWeak 3)
(define NSGradientConvexStrong 4)

;; NSGridCellPlacement
(define NSGridCellPlacementInherited 0)
(define NSGridCellPlacementNone 1)
(define NSGridCellPlacementLeading 2)
(define NSGridCellPlacementTop 2)
(define NSGridCellPlacementTrailing 3)
(define NSGridCellPlacementBottom 3)
(define NSGridCellPlacementCenter 4)
(define NSGridCellPlacementFill 5)

;; NSGridRowAlignment
(define NSGridRowAlignmentInherited 0)
(define NSGridRowAlignmentNone 1)
(define NSGridRowAlignmentFirstBaseline 2)
(define NSGridRowAlignmentLastBaseline 3)

;; NSHapticFeedbackPattern
(define NSHapticFeedbackPatternGeneric 0)
(define NSHapticFeedbackPatternAlignment 1)
(define NSHapticFeedbackPatternLevelChange 2)

;; NSHapticFeedbackPerformanceTime
(define NSHapticFeedbackPerformanceTimeDefault 0)
(define NSHapticFeedbackPerformanceTimeNow 1)
(define NSHapticFeedbackPerformanceTimeDrawCompleted 2)

;; NSHorizontalDirections
(define NSHorizontalDirectionsLeft 1)
(define NSHorizontalDirectionsRight 2)
(define NSHorizontalDirectionsAll 3)

;; NSImageAlignment
(define NSImageAlignCenter 0)
(define NSImageAlignTop 1)
(define NSImageAlignTopLeft 2)
(define NSImageAlignTopRight 3)
(define NSImageAlignLeft 4)
(define NSImageAlignBottom 5)
(define NSImageAlignBottomLeft 6)
(define NSImageAlignBottomRight 7)
(define NSImageAlignRight 8)

;; NSImageCacheMode
(define NSImageCacheDefault 0)
(define NSImageCacheAlways 1)
(define NSImageCacheBySize 2)
(define NSImageCacheNever 3)

;; NSImageDynamicRange
(define NSImageDynamicRangeUnspecified -1)
(define NSImageDynamicRangeStandard 0)
(define NSImageDynamicRangeConstrainedHigh 1)
(define NSImageDynamicRangeHigh 2)

;; NSImageFrameStyle
(define NSImageFrameNone 0)
(define NSImageFramePhoto 1)
(define NSImageFrameGrayBezel 2)
(define NSImageFrameGroove 3)
(define NSImageFrameButton 4)

;; NSImageInterpolation
(define NSImageInterpolationDefault 0)
(define NSImageInterpolationNone 1)
(define NSImageInterpolationLow 2)
(define NSImageInterpolationMedium 4)
(define NSImageInterpolationHigh 3)

;; NSImageLayoutDirection
(define NSImageLayoutDirectionUnspecified -1)
(define NSImageLayoutDirectionLeftToRight 2)
(define NSImageLayoutDirectionRightToLeft 3)

;; NSImageLoadStatus
(define NSImageLoadStatusCompleted 0)
(define NSImageLoadStatusCancelled 1)
(define NSImageLoadStatusInvalidData 2)
(define NSImageLoadStatusUnexpectedEOF 3)
(define NSImageLoadStatusReadError 4)

;; NSImageRepLoadStatus
(define NSImageRepLoadStatusUnknownType -1)
(define NSImageRepLoadStatusReadingHeader -2)
(define NSImageRepLoadStatusWillNeedAllData -3)
(define NSImageRepLoadStatusInvalidData -4)
(define NSImageRepLoadStatusUnexpectedEOF -5)
(define NSImageRepLoadStatusCompleted -6)

;; NSImageResizingMode
(define NSImageResizingModeTile 0)
(define NSImageResizingModeStretch 1)

;; NSImageScaling
(define NSImageScaleProportionallyDown 0)
(define NSImageScaleAxesIndependently 1)
(define NSImageScaleNone 2)
(define NSImageScaleProportionallyUpOrDown 3)
(define NSScaleProportionally 0)
(define NSScaleToFit 1)
(define NSScaleNone 2)

;; NSImageSymbolColorRenderingMode
(define NSImageSymbolColorRenderingModeAutomatic 0)
(define NSImageSymbolColorRenderingModeFlat 1)
(define NSImageSymbolColorRenderingModeGradient 2)

;; NSImageSymbolScale
(define NSImageSymbolScaleSmall 1)
(define NSImageSymbolScaleMedium 2)
(define NSImageSymbolScaleLarge 3)

;; NSImageSymbolVariableValueMode
(define NSImageSymbolVariableValueModeAutomatic 0)
(define NSImageSymbolVariableValueModeColor 1)
(define NSImageSymbolVariableValueModeDraw 2)

;; NSLayoutAttribute
(define NSLayoutAttributeLeft 1)
(define NSLayoutAttributeRight 2)
(define NSLayoutAttributeTop 3)
(define NSLayoutAttributeBottom 4)
(define NSLayoutAttributeLeading 5)
(define NSLayoutAttributeTrailing 6)
(define NSLayoutAttributeWidth 7)
(define NSLayoutAttributeHeight 8)
(define NSLayoutAttributeCenterX 9)
(define NSLayoutAttributeCenterY 10)
(define NSLayoutAttributeLastBaseline 11)
(define NSLayoutAttributeBaseline 11)
(define NSLayoutAttributeFirstBaseline 12)
(define NSLayoutAttributeNotAnAttribute 0)

;; NSLayoutConstraintOrientation
(define NSLayoutConstraintOrientationHorizontal 0)
(define NSLayoutConstraintOrientationVertical 1)

;; NSLayoutFormatOptions
(define NSLayoutFormatAlignAllLeft 2)
(define NSLayoutFormatAlignAllRight 4)
(define NSLayoutFormatAlignAllTop 8)
(define NSLayoutFormatAlignAllBottom 16)
(define NSLayoutFormatAlignAllLeading 32)
(define NSLayoutFormatAlignAllTrailing 64)
(define NSLayoutFormatAlignAllCenterX 512)
(define NSLayoutFormatAlignAllCenterY 1024)
(define NSLayoutFormatAlignAllLastBaseline 2048)
(define NSLayoutFormatAlignAllFirstBaseline 4096)
(define NSLayoutFormatAlignAllBaseline 2048)
(define NSLayoutFormatAlignmentMask 65535)
(define NSLayoutFormatDirectionLeadingToTrailing 0)
(define NSLayoutFormatDirectionLeftToRight 65536)
(define NSLayoutFormatDirectionRightToLeft 131072)
(define NSLayoutFormatDirectionMask 196608)

;; NSLayoutRelation
(define NSLayoutRelationLessThanOrEqual -1)
(define NSLayoutRelationEqual 0)
(define NSLayoutRelationGreaterThanOrEqual 1)

;; NSLevelIndicatorPlaceholderVisibility
(define NSLevelIndicatorPlaceholderVisibilityAutomatic 0)
(define NSLevelIndicatorPlaceholderVisibilityAlways 1)
(define NSLevelIndicatorPlaceholderVisibilityWhileEditing 2)

;; NSLevelIndicatorStyle
(define NSLevelIndicatorStyleRelevancy 0)
(define NSLevelIndicatorStyleContinuousCapacity 1)
(define NSLevelIndicatorStyleDiscreteCapacity 2)
(define NSLevelIndicatorStyleRating 3)

;; NSLineBreakMode
(define NSLineBreakByWordWrapping 0)
(define NSLineBreakByCharWrapping 1)
(define NSLineBreakByClipping 2)
(define NSLineBreakByTruncatingHead 3)
(define NSLineBreakByTruncatingTail 4)
(define NSLineBreakByTruncatingMiddle 5)

;; NSLineBreakStrategy
(define NSLineBreakStrategyNone 0)
(define NSLineBreakStrategyPushOut 1)
(define NSLineBreakStrategyHangulWordPriority 2)
(define NSLineBreakStrategyStandard 65535)

;; NSLineCapStyle
(define NSLineCapStyleButt 0)
(define NSLineCapStyleRound 1)
(define NSLineCapStyleSquare 2)

;; NSLineJoinStyle
(define NSLineJoinStyleMiter 0)
(define NSLineJoinStyleRound 1)
(define NSLineJoinStyleBevel 2)

;; NSLineMovementDirection
(define NSLineDoesntMove 0)
(define NSLineMovesLeft 1)
(define NSLineMovesRight 2)
(define NSLineMovesDown 3)
(define NSLineMovesUp 4)

;; NSLineSweepDirection
(define NSLineSweepLeft 0)
(define NSLineSweepRight 1)
(define NSLineSweepDown 2)
(define NSLineSweepUp 3)

;; NSMatrixMode
(define NSRadioModeMatrix 0)
(define NSHighlightModeMatrix 1)
(define NSListModeMatrix 2)
(define NSTrackModeMatrix 3)

;; NSMediaLibrary
(define NSMediaLibraryAudio 1)
(define NSMediaLibraryImage 2)
(define NSMediaLibraryMovie 4)

;; NSMenuItemBadgeType
(define NSMenuItemBadgeTypeNone 0)
(define NSMenuItemBadgeTypeUpdates 1)
(define NSMenuItemBadgeTypeNewItems 2)
(define NSMenuItemBadgeTypeAlerts 3)

;; NSMenuPresentationStyle
(define NSMenuPresentationStyleRegular 0)
(define NSMenuPresentationStylePalette 1)

;; NSMenuProperties
(define NSMenuPropertyItemTitle 1)
(define NSMenuPropertyItemAttributedTitle 2)
(define NSMenuPropertyItemKeyEquivalent 4)
(define NSMenuPropertyItemImage 8)
(define NSMenuPropertyItemEnabled 16)
(define NSMenuPropertyItemAccessibilityDescription 32)

;; NSMenuSelectionMode
(define NSMenuSelectionModeAutomatic 0)
(define NSMenuSelectionModeSelectOne 1)
(define NSMenuSelectionModeSelectAny 2)

;; NSMultibyteGlyphPacking
(define NSNativeShortGlyphPacking 5)

;; NSOpenGLContextParameter
(define NSOpenGLContextParameterSwapInterval 222)
(define NSOpenGLContextParameterSurfaceOrder 235)
(define NSOpenGLContextParameterSurfaceOpacity 236)
(define NSOpenGLContextParameterSurfaceBackingSize 304)
(define NSOpenGLContextParameterReclaimResources 308)
(define NSOpenGLContextParameterCurrentRendererID 309)
(define NSOpenGLContextParameterGPUVertexProcessing 310)
(define NSOpenGLContextParameterGPUFragmentProcessing 311)
(define NSOpenGLContextParameterHasDrawable 314)
(define NSOpenGLContextParameterMPSwapsInFlight 315)
(define NSOpenGLContextParameterSwapRectangle 200)
(define NSOpenGLContextParameterSwapRectangleEnable 201)
(define NSOpenGLContextParameterRasterizationEnable 221)
(define NSOpenGLContextParameterStateValidation 301)
(define NSOpenGLContextParameterSurfaceSurfaceVolatile 306)

;; NSOpenGLGlobalOption
(define NSOpenGLGOFormatCacheSize 501)
(define NSOpenGLGOClearFormatCache 502)
(define NSOpenGLGORetainRenderers 503)
(define NSOpenGLGOUseBuildCache 506)
(define NSOpenGLGOResetLibrary 504)

;; NSPDFPanelOptions
(define NSPDFPanelShowsPaperSize 4)
(define NSPDFPanelShowsOrientation 8)
(define NSPDFPanelRequestsParentDirectory 16777216)

;; NSPageControllerTransitionStyle
(define NSPageControllerTransitionStyleStackHistory 0)
(define NSPageControllerTransitionStyleStackBook 1)
(define NSPageControllerTransitionStyleHorizontalStrip 2)

;; NSPageLayoutResult
(define NSPageLayoutResultCancelled 0)
(define NSPageLayoutResultChanged 1)

;; NSPaperOrientation
(define NSPaperOrientationPortrait 0)
(define NSPaperOrientationLandscape 1)

;; NSPasteboardAccessBehavior
(define NSPasteboardAccessBehaviorDefault 0)
(define NSPasteboardAccessBehaviorAsk 1)
(define NSPasteboardAccessBehaviorAlwaysAllow 2)
(define NSPasteboardAccessBehaviorAlwaysDeny 3)

;; NSPasteboardContentsOptions
(define NSPasteboardContentsCurrentHostOnly 1)

;; NSPasteboardReadingOptions
(define NSPasteboardReadingAsData 0)
(define NSPasteboardReadingAsString 1)
(define NSPasteboardReadingAsPropertyList 2)
(define NSPasteboardReadingAsKeyedArchive 4)

;; NSPasteboardWritingOptions
(define NSPasteboardWritingPromised 512)

;; NSPathStyle
(define NSPathStyleStandard 0)
(define NSPathStylePopUp 2)
(define NSPathStyleNavigationBar 1)

;; NSPickerTouchBarItemControlRepresentation
(define NSPickerTouchBarItemControlRepresentationAutomatic 0)
(define NSPickerTouchBarItemControlRepresentationExpanded 1)
(define NSPickerTouchBarItemControlRepresentationCollapsed 2)

;; NSPickerTouchBarItemSelectionMode
(define NSPickerTouchBarItemSelectionModeSelectOne 0)
(define NSPickerTouchBarItemSelectionModeSelectAny 1)
(define NSPickerTouchBarItemSelectionModeMomentary 2)

;; NSPointingDeviceType
(define NSPointingDeviceTypeUnknown 0)
(define NSPointingDeviceTypePen 1)
(define NSPointingDeviceTypeCursor 2)
(define NSPointingDeviceTypeEraser 3)

;; NSPopUpArrowPosition
(define NSPopUpNoArrow 0)
(define NSPopUpArrowAtCenter 1)
(define NSPopUpArrowAtBottom 2)

;; NSPopoverAppearance
(define NSPopoverAppearanceMinimal 0)
(define NSPopoverAppearanceHUD 1)

;; NSPopoverBehavior
(define NSPopoverBehaviorApplicationDefined 0)
(define NSPopoverBehaviorTransient 1)
(define NSPopoverBehaviorSemitransient 2)

;; NSPressureBehavior
(define NSPressureBehaviorUnknown -1)
(define NSPressureBehaviorPrimaryDefault 0)
(define NSPressureBehaviorPrimaryClick 1)
(define NSPressureBehaviorPrimaryGeneric 2)
(define NSPressureBehaviorPrimaryAccelerator 3)
(define NSPressureBehaviorPrimaryDeepClick 5)
(define NSPressureBehaviorPrimaryDeepDrag 6)

;; NSPrintPanelOptions
(define NSPrintPanelShowsCopies 1)
(define NSPrintPanelShowsPageRange 2)
(define NSPrintPanelShowsPaperSize 4)
(define NSPrintPanelShowsOrientation 8)
(define NSPrintPanelShowsScaling 16)
(define NSPrintPanelShowsPrintSelection 32)
(define NSPrintPanelShowsPageSetupAccessory 256)
(define NSPrintPanelShowsPreview 131072)

;; NSPrintPanelResult
(define NSPrintPanelResultCancelled 0)
(define NSPrintPanelResultPrinted 1)

;; NSPrintRenderingQuality
(define NSPrintRenderingQualityBest 0)
(define NSPrintRenderingQualityResponsive 1)

;; NSPrinterTableStatus
(define NSPrinterTableOK 0)
(define NSPrinterTableNotFound 1)
(define NSPrinterTableError 2)

;; NSPrintingOrientation
(define NSPortraitOrientation 0)
(define NSLandscapeOrientation 1)

;; NSPrintingPageOrder
(define NSDescendingPageOrder -1)
(define NSSpecialPageOrder 0)
(define NSAscendingPageOrder 1)
(define NSUnknownPageOrder 2)

;; NSPrintingPaginationMode
(define NSPrintingPaginationModeAutomatic 0)
(define NSPrintingPaginationModeFit 1)
(define NSPrintingPaginationModeClip 2)

;; NSProgressIndicatorStyle
(define NSProgressIndicatorStyleBar 0)
(define NSProgressIndicatorStyleSpinning 1)

;; NSProgressIndicatorThickness
(define NSProgressIndicatorPreferredThickness 14)
(define NSProgressIndicatorPreferredSmallThickness 10)
(define NSProgressIndicatorPreferredLargeThickness 18)
(define NSProgressIndicatorPreferredAquaThickness 12)

;; NSRectAlignment
(define NSRectAlignmentNone 0)
(define NSRectAlignmentTop 1)
(define NSRectAlignmentTopLeading 2)
(define NSRectAlignmentLeading 3)
(define NSRectAlignmentBottomLeading 4)
(define NSRectAlignmentBottom 5)
(define NSRectAlignmentBottomTrailing 6)
(define NSRectAlignmentTrailing 7)
(define NSRectAlignmentTopTrailing 8)

;; NSRemoteNotificationType
(define NSRemoteNotificationTypeNone 0)
(define NSRemoteNotificationTypeBadge 1)
(define NSRemoteNotificationTypeSound 2)
(define NSRemoteNotificationTypeAlert 4)

;; NSRequestUserAttentionType
(define NSCriticalRequest 0)
(define NSInformationalRequest 10)

;; NSRuleEditorNestingMode
(define NSRuleEditorNestingModeSingle 0)
(define NSRuleEditorNestingModeList 1)
(define NSRuleEditorNestingModeCompound 2)
(define NSRuleEditorNestingModeSimple 3)

;; NSRuleEditorRowType
(define NSRuleEditorRowTypeSimple 0)
(define NSRuleEditorRowTypeCompound 1)

;; NSRulerOrientation
(define NSHorizontalRuler 0)
(define NSVerticalRuler 1)

;; NSSaveOperationType
(define NSSaveOperation 0)
(define NSSaveAsOperation 1)
(define NSSaveToOperation 2)
(define NSAutosaveInPlaceOperation 4)
(define NSAutosaveElsewhereOperation 3)
(define NSAutosaveAsOperation 5)
(define NSAutosaveOperation 3)

;; NSScrollArrowPosition
(define NSScrollerArrowsMaxEnd 0)
(define NSScrollerArrowsMinEnd 1)
(define NSScrollerArrowsDefaultSetting 0)
(define NSScrollerArrowsNone 2)

;; NSScrollElasticity
(define NSScrollElasticityAutomatic 0)
(define NSScrollElasticityNone 1)
(define NSScrollElasticityAllowed 2)

;; NSScrollViewFindBarPosition
(define NSScrollViewFindBarPositionAboveHorizontalRuler 0)
(define NSScrollViewFindBarPositionAboveContent 1)
(define NSScrollViewFindBarPositionBelowContent 2)

;; NSScrollerArrow
(define NSScrollerIncrementArrow 0)
(define NSScrollerDecrementArrow 1)

;; NSScrollerKnobStyle
(define NSScrollerKnobStyleDefault 0)
(define NSScrollerKnobStyleDark 1)
(define NSScrollerKnobStyleLight 2)

;; NSScrollerPart
(define NSScrollerNoPart 0)
(define NSScrollerDecrementPage 1)
(define NSScrollerKnob 2)
(define NSScrollerIncrementPage 3)
(define NSScrollerDecrementLine 4)
(define NSScrollerIncrementLine 5)
(define NSScrollerKnobSlot 6)

;; NSScrollerStyle
(define NSScrollerStyleLegacy 0)
(define NSScrollerStyleOverlay 1)

;; NSScrubberAlignment
(define NSScrubberAlignmentNone 0)
(define NSScrubberAlignmentLeading 1)
(define NSScrubberAlignmentTrailing 2)
(define NSScrubberAlignmentCenter 3)

;; NSScrubberMode
(define NSScrubberModeFixed 0)
(define NSScrubberModeFree 1)

;; NSSegmentDistribution
(define NSSegmentDistributionFit 0)
(define NSSegmentDistributionFill 1)
(define NSSegmentDistributionFillEqually 2)
(define NSSegmentDistributionFillProportionally 3)

;; NSSegmentStyle
(define NSSegmentStyleAutomatic 0)
(define NSSegmentStyleRounded 1)
(define NSSegmentStyleRoundRect 3)
(define NSSegmentStyleTexturedSquare 4)
(define NSSegmentStyleSmallSquare 6)
(define NSSegmentStyleSeparated 8)
(define NSSegmentStyleTexturedRounded 2)
(define NSSegmentStyleCapsule 5)

;; NSSegmentSwitchTracking
(define NSSegmentSwitchTrackingSelectOne 0)
(define NSSegmentSwitchTrackingSelectAny 1)
(define NSSegmentSwitchTrackingMomentary 2)
(define NSSegmentSwitchTrackingMomentaryAccelerator 3)

;; NSSelectionAffinity
(define NSSelectionAffinityUpstream 0)
(define NSSelectionAffinityDownstream 1)

;; NSSelectionDirection
(define NSDirectSelection 0)
(define NSSelectingNext 1)
(define NSSelectingPrevious 2)

;; NSSelectionGranularity
(define NSSelectByCharacter 0)
(define NSSelectByWord 1)
(define NSSelectByParagraph 2)

;; NSSharingCollaborationMode
(define NSSharingCollaborationModeSendCopy 0)
(define NSSharingCollaborationModeCollaborate 1)

;; NSSharingContentScope
(define NSSharingContentScopeItem 0)
(define NSSharingContentScopePartial 1)
(define NSSharingContentScopeFull 2)

;; NSSliderType
(define NSSliderTypeLinear 0)
(define NSSliderTypeCircular 1)

;; NSSpeechBoundary
(define NSSpeechImmediateBoundary 0)
(define NSSpeechWordBoundary 1)
(define NSSpeechSentenceBoundary 2)

;; NSSpellingState
(define NSSpellingStateSpellingFlag 1)
(define NSSpellingStateGrammarFlag 2)

;; NSSplitViewDividerStyle
(define NSSplitViewDividerStyleThick 1)
(define NSSplitViewDividerStyleThin 2)
(define NSSplitViewDividerStylePaneSplitter 3)

;; NSSplitViewItemBehavior
(define NSSplitViewItemBehaviorDefault 0)
(define NSSplitViewItemBehaviorSidebar 1)
(define NSSplitViewItemBehaviorContentList 2)
(define NSSplitViewItemBehaviorInspector 3)

;; NSSplitViewItemCollapseBehavior
(define NSSplitViewItemCollapseBehaviorDefault 0)
(define NSSplitViewItemCollapseBehaviorPreferResizingSplitViewWithFixedSiblings 1)
(define NSSplitViewItemCollapseBehaviorPreferResizingSiblingsWithFixedSplitView 2)
(define NSSplitViewItemCollapseBehaviorUseConstraints 3)

;; NSSpringLoadingHighlight
(define NSSpringLoadingHighlightNone 0)
(define NSSpringLoadingHighlightStandard 1)
(define NSSpringLoadingHighlightEmphasized 2)

;; NSSpringLoadingOptions
(define NSSpringLoadingDisabled 0)
(define NSSpringLoadingEnabled 1)
(define NSSpringLoadingContinuousActivation 2)
(define NSSpringLoadingNoHover 8)

;; NSStackViewDistribution
(define NSStackViewDistributionGravityAreas -1)
(define NSStackViewDistributionFill 0)
(define NSStackViewDistributionFillEqually 1)
(define NSStackViewDistributionFillProportionally 2)
(define NSStackViewDistributionEqualSpacing 3)
(define NSStackViewDistributionEqualCentering 4)

;; NSStackViewGravity
(define NSStackViewGravityTop 1)
(define NSStackViewGravityLeading 1)
(define NSStackViewGravityCenter 2)
(define NSStackViewGravityBottom 3)
(define NSStackViewGravityTrailing 3)

;; NSStatusItemBehavior
(define NSStatusItemBehaviorRemovalAllowed 2)
(define NSStatusItemBehaviorTerminationOnRemoval 4)

;; NSStringDrawingOptions
(define NSStringDrawingUsesLineFragmentOrigin 1)
(define NSStringDrawingUsesFontLeading 2)
(define NSStringDrawingUsesDeviceMetrics 8)
(define NSStringDrawingTruncatesLastVisibleLine 32)
(define NSStringDrawingOptionsResolvesNaturalAlignmentWithBaseWritingDirection 512)
(define NSStringDrawingDisableScreenFontSubstitution 4)
(define NSStringDrawingOneShot 16)

;; NSTIFFCompression
(define NSTIFFCompressionNone 1)
(define NSTIFFCompressionCCITTFAX3 3)
(define NSTIFFCompressionCCITTFAX4 4)
(define NSTIFFCompressionLZW 5)
(define NSTIFFCompressionJPEG 6)
(define NSTIFFCompressionNEXT 32766)
(define NSTIFFCompressionPackBits 32773)
(define NSTIFFCompressionOldJPEG 32865)

;; NSTabPosition
(define NSTabPositionNone 0)
(define NSTabPositionTop 1)
(define NSTabPositionLeft 2)
(define NSTabPositionBottom 3)
(define NSTabPositionRight 4)

;; NSTabState
(define NSSelectedTab 0)
(define NSBackgroundTab 1)
(define NSPressedTab 2)

;; NSTabViewBorderType
(define NSTabViewBorderTypeNone 0)
(define NSTabViewBorderTypeLine 1)
(define NSTabViewBorderTypeBezel 2)

;; NSTabViewControllerTabStyle
(define NSTabViewControllerTabStyleSegmentedControlOnTop 0)
(define NSTabViewControllerTabStyleSegmentedControlOnBottom 1)
(define NSTabViewControllerTabStyleToolbar 2)
(define NSTabViewControllerTabStyleUnspecified -1)

;; NSTabViewType
(define NSTopTabsBezelBorder 0)
(define NSLeftTabsBezelBorder 1)
(define NSBottomTabsBezelBorder 2)
(define NSRightTabsBezelBorder 3)
(define NSNoTabsBezelBorder 4)
(define NSNoTabsLineBorder 5)
(define NSNoTabsNoBorder 6)

;; NSTableColumnResizingOptions
(define NSTableColumnNoResizing 0)
(define NSTableColumnAutoresizingMask 1)
(define NSTableColumnUserResizingMask 2)

;; NSTableRowActionEdge
(define NSTableRowActionEdgeLeading 0)
(define NSTableRowActionEdgeTrailing 1)

;; NSTableViewAnimationOptions
(define NSTableViewAnimationEffectNone 0)
(define NSTableViewAnimationEffectFade 1)
(define NSTableViewAnimationEffectGap 2)
(define NSTableViewAnimationSlideUp 16)
(define NSTableViewAnimationSlideDown 32)
(define NSTableViewAnimationSlideLeft 48)
(define NSTableViewAnimationSlideRight 64)

;; NSTableViewColumnAutoresizingStyle
(define NSTableViewNoColumnAutoresizing 0)
(define NSTableViewUniformColumnAutoresizingStyle 1)
(define NSTableViewSequentialColumnAutoresizingStyle 2)
(define NSTableViewReverseSequentialColumnAutoresizingStyle 3)
(define NSTableViewLastColumnOnlyAutoresizingStyle 4)
(define NSTableViewFirstColumnOnlyAutoresizingStyle 5)

;; NSTableViewDraggingDestinationFeedbackStyle
(define NSTableViewDraggingDestinationFeedbackStyleNone -1)
(define NSTableViewDraggingDestinationFeedbackStyleRegular 0)
(define NSTableViewDraggingDestinationFeedbackStyleSourceList 1)
(define NSTableViewDraggingDestinationFeedbackStyleGap 2)

;; NSTableViewDropOperation
(define NSTableViewDropOn 0)
(define NSTableViewDropAbove 1)

;; NSTableViewGridLineStyle
(define NSTableViewGridNone 0)
(define NSTableViewSolidVerticalGridLineMask 1)
(define NSTableViewSolidHorizontalGridLineMask 2)
(define NSTableViewDashedHorizontalGridLineMask 8)

;; NSTableViewRowActionStyle
(define NSTableViewRowActionStyleRegular 0)
(define NSTableViewRowActionStyleDestructive 1)

;; NSTableViewRowSizeStyle
(define NSTableViewRowSizeStyleDefault -1)
(define NSTableViewRowSizeStyleCustom 0)
(define NSTableViewRowSizeStyleSmall 1)
(define NSTableViewRowSizeStyleMedium 2)
(define NSTableViewRowSizeStyleLarge 3)

;; NSTableViewSelectionHighlightStyle
(define NSTableViewSelectionHighlightStyleNone -1)
(define NSTableViewSelectionHighlightStyleRegular 0)
(define NSTableViewSelectionHighlightStyleSourceList 1)

;; NSTableViewStyle
(define NSTableViewStyleAutomatic 0)
(define NSTableViewStyleFullWidth 1)
(define NSTableViewStyleInset 2)
(define NSTableViewStyleSourceList 3)
(define NSTableViewStylePlain 4)

;; NSTextAlignment
(define NSTextAlignmentLeft 0)
(define NSTextAlignmentCenter 1)
(define NSTextAlignmentRight 2)
(define NSTextAlignmentJustified 3)
(define NSTextAlignmentNatural 4)

;; NSTextBlockDimension
(define NSTextBlockWidth 0)
(define NSTextBlockMinimumWidth 1)
(define NSTextBlockMaximumWidth 2)
(define NSTextBlockHeight 4)
(define NSTextBlockMinimumHeight 5)
(define NSTextBlockMaximumHeight 6)

;; NSTextBlockLayer
(define NSTextBlockPadding -1)
(define NSTextBlockBorder 0)
(define NSTextBlockMargin 1)

;; NSTextBlockValueType
(define NSTextBlockAbsoluteValueType 0)
(define NSTextBlockPercentageValueType 1)

;; NSTextBlockVerticalAlignment
(define NSTextBlockTopAlignment 0)
(define NSTextBlockMiddleAlignment 1)
(define NSTextBlockBottomAlignment 2)
(define NSTextBlockBaselineAlignment 3)

;; NSTextContentManagerEnumerationOptions
(define NSTextContentManagerEnumerationOptionsNone 0)
(define NSTextContentManagerEnumerationOptionsReverse 1)

;; NSTextCursorAccessoryPlacement
(define NSTextCursorAccessoryPlacementUnspecified 0)
(define NSTextCursorAccessoryPlacementBackward 1)
(define NSTextCursorAccessoryPlacementForward 2)
(define NSTextCursorAccessoryPlacementInvisible 3)
(define NSTextCursorAccessoryPlacementCenter 4)
(define NSTextCursorAccessoryPlacementOffscreenLeft 5)
(define NSTextCursorAccessoryPlacementOffscreenTop 6)
(define NSTextCursorAccessoryPlacementOffscreenRight 7)
(define NSTextCursorAccessoryPlacementOffscreenBottom 8)

;; NSTextFieldBezelStyle
(define NSTextFieldSquareBezel 0)
(define NSTextFieldRoundedBezel 1)

;; NSTextFinderAction
(define NSTextFinderActionShowFindInterface 1)
(define NSTextFinderActionNextMatch 2)
(define NSTextFinderActionPreviousMatch 3)
(define NSTextFinderActionReplaceAll 4)
(define NSTextFinderActionReplace 5)
(define NSTextFinderActionReplaceAndFind 6)
(define NSTextFinderActionSetSearchString 7)
(define NSTextFinderActionReplaceAllInSelection 8)
(define NSTextFinderActionSelectAll 9)
(define NSTextFinderActionSelectAllInSelection 10)
(define NSTextFinderActionHideFindInterface 11)
(define NSTextFinderActionShowReplaceInterface 12)
(define NSTextFinderActionHideReplaceInterface 13)

;; NSTextFinderMatchingType
(define NSTextFinderMatchingTypeContains 0)
(define NSTextFinderMatchingTypeStartsWith 1)
(define NSTextFinderMatchingTypeFullWord 2)
(define NSTextFinderMatchingTypeEndsWith 3)

;; NSTextInputTraitType
(define NSTextInputTraitTypeDefault 0)
(define NSTextInputTraitTypeNo 1)
(define NSTextInputTraitTypeYes 2)

;; NSTextInsertionIndicatorAutomaticModeOptions
(define NSTextInsertionIndicatorAutomaticModeOptionsShowEffectsView 1)
(define NSTextInsertionIndicatorAutomaticModeOptionsShowWhileTracking 2)

;; NSTextInsertionIndicatorDisplayMode
(define NSTextInsertionIndicatorDisplayModeAutomatic 0)
(define NSTextInsertionIndicatorDisplayModeHidden 1)
(define NSTextInsertionIndicatorDisplayModeVisible 2)

;; NSTextLayoutFragmentEnumerationOptions
(define NSTextLayoutFragmentEnumerationOptionsNone 0)
(define NSTextLayoutFragmentEnumerationOptionsReverse 1)
(define NSTextLayoutFragmentEnumerationOptionsEstimatesSize 2)
(define NSTextLayoutFragmentEnumerationOptionsEnsuresLayout 4)
(define NSTextLayoutFragmentEnumerationOptionsEnsuresExtraLineFragment 8)

;; NSTextLayoutFragmentState
(define NSTextLayoutFragmentStateNone 0)
(define NSTextLayoutFragmentStateEstimatedUsageBounds 1)
(define NSTextLayoutFragmentStateCalculatedUsageBounds 2)
(define NSTextLayoutFragmentStateLayoutAvailable 3)

;; NSTextLayoutManagerSegmentOptions
(define NSTextLayoutManagerSegmentOptionsNone 0)
(define NSTextLayoutManagerSegmentOptionsRangeNotRequired 1)
(define NSTextLayoutManagerSegmentOptionsMiddleFragmentsExcluded 2)
(define NSTextLayoutManagerSegmentOptionsHeadSegmentExtended 4)
(define NSTextLayoutManagerSegmentOptionsTailSegmentExtended 8)
(define NSTextLayoutManagerSegmentOptionsUpstreamAffinity 16)

;; NSTextLayoutManagerSegmentType
(define NSTextLayoutManagerSegmentTypeStandard 0)
(define NSTextLayoutManagerSegmentTypeSelection 1)
(define NSTextLayoutManagerSegmentTypeHighlight 2)

;; NSTextLayoutOrientation
(define NSTextLayoutOrientationHorizontal 0)
(define NSTextLayoutOrientationVertical 1)

;; NSTextListOptions
(define NSTextListPrependEnclosingMarker 1)

;; NSTextMovement
(define NSTextMovementReturn 16)
(define NSTextMovementTab 17)
(define NSTextMovementBacktab 18)
(define NSTextMovementLeft 19)
(define NSTextMovementRight 20)
(define NSTextMovementUp 21)
(define NSTextMovementDown 22)
(define NSTextMovementCancel 23)
(define NSTextMovementOther 0)

;; NSTextScalingType
(define NSTextScalingStandard 0)
(define NSTextScalingiOS 1)

;; NSTextSelectionAffinity
(define NSTextSelectionAffinityUpstream 0)
(define NSTextSelectionAffinityDownstream 1)

;; NSTextSelectionGranularity
(define NSTextSelectionGranularityCharacter 0)
(define NSTextSelectionGranularityWord 1)
(define NSTextSelectionGranularityParagraph 2)
(define NSTextSelectionGranularityLine 3)
(define NSTextSelectionGranularitySentence 4)

;; NSTextSelectionNavigationDestination
(define NSTextSelectionNavigationDestinationCharacter 0)
(define NSTextSelectionNavigationDestinationWord 1)
(define NSTextSelectionNavigationDestinationLine 2)
(define NSTextSelectionNavigationDestinationSentence 3)
(define NSTextSelectionNavigationDestinationParagraph 4)
(define NSTextSelectionNavigationDestinationContainer 5)
(define NSTextSelectionNavigationDestinationDocument 6)

;; NSTextSelectionNavigationDirection
(define NSTextSelectionNavigationDirectionForward 0)
(define NSTextSelectionNavigationDirectionBackward 1)
(define NSTextSelectionNavigationDirectionRight 2)
(define NSTextSelectionNavigationDirectionLeft 3)
(define NSTextSelectionNavigationDirectionUp 4)
(define NSTextSelectionNavigationDirectionDown 5)

;; NSTextSelectionNavigationLayoutOrientation
(define NSTextSelectionNavigationLayoutOrientationHorizontal 0)
(define NSTextSelectionNavigationLayoutOrientationVertical 1)

;; NSTextSelectionNavigationModifier
(define NSTextSelectionNavigationModifierExtend 1)
(define NSTextSelectionNavigationModifierVisual 2)
(define NSTextSelectionNavigationModifierMultiple 4)

;; NSTextSelectionNavigationWritingDirection
(define NSTextSelectionNavigationWritingDirectionLeftToRight 0)
(define NSTextSelectionNavigationWritingDirectionRightToLeft 1)

;; NSTextStorageEditActions
(define NSTextStorageEditedAttributes 1)
(define NSTextStorageEditedCharacters 2)

;; NSTextTabType
(define NSLeftTabStopType 0)
(define NSRightTabStopType 1)
(define NSCenterTabStopType 2)
(define NSDecimalTabStopType 3)

;; NSTextTableLayoutAlgorithm
(define NSTextTableAutomaticLayoutAlgorithm 0)
(define NSTextTableFixedLayoutAlgorithm 1)

;; NSTickMarkPosition
(define NSTickMarkPositionBelow 0)
(define NSTickMarkPositionAbove 1)
(define NSTickMarkPositionLeading 1)
(define NSTickMarkPositionTrailing 0)

;; NSTintProminence
(define NSTintProminenceAutomatic 0)
(define NSTintProminenceNone 1)
(define NSTintProminencePrimary 2)
(define NSTintProminenceSecondary 3)

;; NSTitlePosition
(define NSNoTitle 0)
(define NSAboveTop 1)
(define NSAtTop 2)
(define NSBelowTop 3)
(define NSAboveBottom 4)
(define NSAtBottom 5)
(define NSBelowBottom 6)

;; NSTitlebarSeparatorStyle
(define NSTitlebarSeparatorStyleAutomatic 0)
(define NSTitlebarSeparatorStyleNone 1)
(define NSTitlebarSeparatorStyleLine 2)
(define NSTitlebarSeparatorStyleShadow 3)

;; NSTokenStyle
(define NSTokenStyleDefault 0)
(define NSTokenStyleNone 1)
(define NSTokenStyleRounded 2)
(define NSTokenStyleSquared 3)
(define NSTokenStylePlainSquared 4)

;; NSToolbarDisplayMode
(define NSToolbarDisplayModeDefault 0)
(define NSToolbarDisplayModeIconAndLabel 1)
(define NSToolbarDisplayModeIconOnly 2)
(define NSToolbarDisplayModeLabelOnly 3)

;; NSToolbarItemGroupControlRepresentation
(define NSToolbarItemGroupControlRepresentationAutomatic 0)
(define NSToolbarItemGroupControlRepresentationExpanded 1)
(define NSToolbarItemGroupControlRepresentationCollapsed 2)

;; NSToolbarItemGroupSelectionMode
(define NSToolbarItemGroupSelectionModeSelectOne 0)
(define NSToolbarItemGroupSelectionModeSelectAny 1)
(define NSToolbarItemGroupSelectionModeMomentary 2)

;; NSToolbarItemStyle
(define NSToolbarItemStylePlain 0)
(define NSToolbarItemStyleProminent 1)

;; NSToolbarSizeMode
(define NSToolbarSizeModeDefault 0)
(define NSToolbarSizeModeRegular 1)
(define NSToolbarSizeModeSmall 2)

;; NSTouchPhase
(define NSTouchPhaseBegan 1)
(define NSTouchPhaseMoved 2)
(define NSTouchPhaseStationary 4)
(define NSTouchPhaseEnded 8)
(define NSTouchPhaseCancelled 16)
(define NSTouchPhaseTouching 7)

;; NSTouchType
(define NSTouchTypeDirect 0)
(define NSTouchTypeIndirect 1)

;; NSTouchTypeMask
(define NSTouchTypeMaskDirect 1)
(define NSTouchTypeMaskIndirect 2)

;; NSTrackingAreaOptions
(define NSTrackingMouseEnteredAndExited 1)
(define NSTrackingMouseMoved 2)
(define NSTrackingCursorUpdate 4)
(define NSTrackingActiveWhenFirstResponder 16)
(define NSTrackingActiveInKeyWindow 32)
(define NSTrackingActiveInActiveApp 64)
(define NSTrackingActiveAlways 128)
(define NSTrackingAssumeInside 256)
(define NSTrackingInVisibleRect 512)
(define NSTrackingEnabledDuringMouseDrag 1024)

;; NSTypesetterBehavior
(define NSTypesetterLatestBehavior -1)
(define NSTypesetterOriginalBehavior 0)
(define NSTypesetterBehavior_10_2_WithCompatibility 1)
(define NSTypesetterBehavior_10_2 2)
(define NSTypesetterBehavior_10_3 3)
(define NSTypesetterBehavior_10_4 4)

;; NSTypesetterControlCharacterAction
(define NSTypesetterZeroAdvancementAction 1)
(define NSTypesetterWhitespaceAction 2)
(define NSTypesetterHorizontalTabAction 4)
(define NSTypesetterLineBreakAction 8)
(define NSTypesetterParagraphBreakAction 16)
(define NSTypesetterContainerBreakAction 32)

;; NSUnderlineStyle
(define NSUnderlineStyleNone 0)
(define NSUnderlineStyleSingle 1)
(define NSUnderlineStyleThick 2)
(define NSUnderlineStyleDouble 9)
(define NSUnderlineStylePatternSolid 0)
(define NSUnderlineStylePatternDot 256)
(define NSUnderlineStylePatternDash 512)
(define NSUnderlineStylePatternDashDot 768)
(define NSUnderlineStylePatternDashDotDot 1024)
(define NSUnderlineStyleByWord 32768)

;; NSUsableScrollerParts
(define NSNoScrollerParts 0)
(define NSOnlyScrollerArrows 1)
(define NSAllScrollerParts 2)

;; NSUserInterfaceLayoutDirection
(define NSUserInterfaceLayoutDirectionLeftToRight 0)
(define NSUserInterfaceLayoutDirectionRightToLeft 1)

;; NSUserInterfaceLayoutOrientation
(define NSUserInterfaceLayoutOrientationHorizontal 0)
(define NSUserInterfaceLayoutOrientationVertical 1)

;; NSVerticalDirections
(define NSVerticalDirectionsUp 1)
(define NSVerticalDirectionsDown 2)
(define NSVerticalDirectionsAll 3)

;; NSViewControllerTransitionOptions
(define NSViewControllerTransitionNone 0)
(define NSViewControllerTransitionCrossfade 1)
(define NSViewControllerTransitionSlideUp 16)
(define NSViewControllerTransitionSlideDown 32)
(define NSViewControllerTransitionSlideLeft 64)
(define NSViewControllerTransitionSlideRight 128)
(define NSViewControllerTransitionSlideForward 320)
(define NSViewControllerTransitionSlideBackward 384)
(define NSViewControllerTransitionAllowUserInteraction 4096)

;; NSViewLayerContentsPlacement
(define NSViewLayerContentsPlacementScaleAxesIndependently 0)
(define NSViewLayerContentsPlacementScaleProportionallyToFit 1)
(define NSViewLayerContentsPlacementScaleProportionallyToFill 2)
(define NSViewLayerContentsPlacementCenter 3)
(define NSViewLayerContentsPlacementTop 4)
(define NSViewLayerContentsPlacementTopRight 5)
(define NSViewLayerContentsPlacementRight 6)
(define NSViewLayerContentsPlacementBottomRight 7)
(define NSViewLayerContentsPlacementBottom 8)
(define NSViewLayerContentsPlacementBottomLeft 9)
(define NSViewLayerContentsPlacementLeft 10)
(define NSViewLayerContentsPlacementTopLeft 11)

;; NSViewLayerContentsRedrawPolicy
(define NSViewLayerContentsRedrawNever 0)
(define NSViewLayerContentsRedrawOnSetNeedsDisplay 1)
(define NSViewLayerContentsRedrawDuringViewResize 2)
(define NSViewLayerContentsRedrawBeforeViewResize 3)
(define NSViewLayerContentsRedrawCrossfade 4)

;; NSViewLayoutRegionAdaptivityAxis
(define NSViewLayoutRegionAdaptivityAxisNone 0)
(define NSViewLayoutRegionAdaptivityAxisHorizontal 1)
(define NSViewLayoutRegionAdaptivityAxisVertical 2)

;; NSVisualEffectBlendingMode
(define NSVisualEffectBlendingModeBehindWindow 0)
(define NSVisualEffectBlendingModeWithinWindow 1)

;; NSVisualEffectMaterial
(define NSVisualEffectMaterialTitlebar 3)
(define NSVisualEffectMaterialSelection 4)
(define NSVisualEffectMaterialMenu 5)
(define NSVisualEffectMaterialPopover 6)
(define NSVisualEffectMaterialSidebar 7)
(define NSVisualEffectMaterialHeaderView 10)
(define NSVisualEffectMaterialSheet 11)
(define NSVisualEffectMaterialWindowBackground 12)
(define NSVisualEffectMaterialHUDWindow 13)
(define NSVisualEffectMaterialFullScreenUI 15)
(define NSVisualEffectMaterialToolTip 17)
(define NSVisualEffectMaterialContentBackground 18)
(define NSVisualEffectMaterialUnderWindowBackground 21)
(define NSVisualEffectMaterialUnderPageBackground 22)
(define NSVisualEffectMaterialAppearanceBased 0)
(define NSVisualEffectMaterialLight 1)
(define NSVisualEffectMaterialDark 2)
(define NSVisualEffectMaterialMediumLight 8)
(define NSVisualEffectMaterialUltraDark 9)

;; NSVisualEffectState
(define NSVisualEffectStateFollowsWindowActiveState 0)
(define NSVisualEffectStateActive 1)
(define NSVisualEffectStateInactive 2)

;; NSWindingRule
(define NSWindingRuleNonZero 0)
(define NSWindingRuleEvenOdd 1)

;; NSWindowAnimationBehavior
(define NSWindowAnimationBehaviorDefault 0)
(define NSWindowAnimationBehaviorNone 2)
(define NSWindowAnimationBehaviorDocumentWindow 3)
(define NSWindowAnimationBehaviorUtilityWindow 4)
(define NSWindowAnimationBehaviorAlertPanel 5)

;; NSWindowBackingLocation
(define NSWindowBackingLocationDefault 0)
(define NSWindowBackingLocationVideoMemory 1)
(define NSWindowBackingLocationMainMemory 2)

;; NSWindowButton
(define NSWindowCloseButton 0)
(define NSWindowMiniaturizeButton 1)
(define NSWindowZoomButton 2)
(define NSWindowToolbarButton 3)
(define NSWindowDocumentIconButton 4)
(define NSWindowDocumentVersionsButton 6)

;; NSWindowCollectionBehavior
(define NSWindowCollectionBehaviorDefault 0)
(define NSWindowCollectionBehaviorCanJoinAllSpaces 1)
(define NSWindowCollectionBehaviorMoveToActiveSpace 2)
(define NSWindowCollectionBehaviorManaged 4)
(define NSWindowCollectionBehaviorTransient 8)
(define NSWindowCollectionBehaviorStationary 16)
(define NSWindowCollectionBehaviorParticipatesInCycle 32)
(define NSWindowCollectionBehaviorIgnoresCycle 64)
(define NSWindowCollectionBehaviorFullScreenPrimary 128)
(define NSWindowCollectionBehaviorFullScreenAuxiliary 256)
(define NSWindowCollectionBehaviorFullScreenNone 512)
(define NSWindowCollectionBehaviorFullScreenAllowsTiling 2048)
(define NSWindowCollectionBehaviorFullScreenDisallowsTiling 4096)
(define NSWindowCollectionBehaviorPrimary 65536)
(define NSWindowCollectionBehaviorAuxiliary 131072)
(define NSWindowCollectionBehaviorCanJoinAllApplications 262144)

;; NSWindowDepth
(define NSWindowDepthTwentyfourBitRGB 520)
(define NSWindowDepthSixtyfourBitRGB 528)
(define NSWindowDepthOnehundredtwentyeightBitRGB 544)

;; NSWindowListOptions
(define NSWindowListOrderedFrontToBack 1)

;; NSWindowNumberListOptions
(define NSWindowNumberListAllApplications 1)
(define NSWindowNumberListAllSpaces 16)

;; NSWindowOcclusionState
(define NSWindowOcclusionStateVisible 2)

;; NSWindowOrderingMode
(define NSWindowAbove 1)
(define NSWindowBelow -1)
(define NSWindowOut 0)

;; NSWindowSharingType
(define NSWindowSharingNone 0)
(define NSWindowSharingReadOnly 1)

;; NSWindowStyleMask
(define NSWindowStyleMaskBorderless 0)
(define NSWindowStyleMaskTitled 1)
(define NSWindowStyleMaskClosable 2)
(define NSWindowStyleMaskMiniaturizable 4)
(define NSWindowStyleMaskResizable 8)
(define NSWindowStyleMaskTexturedBackground 256)
(define NSWindowStyleMaskUnifiedTitleAndToolbar 4096)
(define NSWindowStyleMaskFullScreen 16384)
(define NSWindowStyleMaskFullSizeContentView 32768)
(define NSWindowStyleMaskUtilityWindow 16)
(define NSWindowStyleMaskDocModalWindow 64)
(define NSWindowStyleMaskNonactivatingPanel 128)
(define NSWindowStyleMaskHUDWindow 8192)

;; NSWindowTabbingMode
(define NSWindowTabbingModeAutomatic 0)
(define NSWindowTabbingModePreferred 1)
(define NSWindowTabbingModeDisallowed 2)

;; NSWindowTitleVisibility
(define NSWindowTitleVisible 0)
(define NSWindowTitleHidden 1)

;; NSWindowToolbarStyle
(define NSWindowToolbarStyleAutomatic 0)
(define NSWindowToolbarStyleExpanded 1)
(define NSWindowToolbarStylePreference 2)
(define NSWindowToolbarStyleUnified 3)
(define NSWindowToolbarStyleUnifiedCompact 4)

;; NSWindowUserTabbingPreference
(define NSWindowUserTabbingPreferenceManual 0)
(define NSWindowUserTabbingPreferenceAlways 1)
(define NSWindowUserTabbingPreferenceInFullScreen 2)

;; NSWorkspaceAuthorizationType
(define NSWorkspaceAuthorizationTypeCreateSymbolicLink 0)
(define NSWorkspaceAuthorizationTypeSetAttributes 1)
(define NSWorkspaceAuthorizationTypeReplaceFile 2)

;; NSWorkspaceIconCreationOptions
(define NSExcludeQuickDrawElementsIconCreationOption 2)
(define NSExclude10_4ElementsIconCreationOption 4)

;; NSWorkspaceLaunchOptions
(define NSWorkspaceLaunchAndPrint 2)
(define NSWorkspaceLaunchWithErrorPresentation 64)
(define NSWorkspaceLaunchInhibitingBackgroundOnly 128)
(define NSWorkspaceLaunchWithoutAddingToRecents 256)
(define NSWorkspaceLaunchWithoutActivation 512)
(define NSWorkspaceLaunchAsync 65536)
(define NSWorkspaceLaunchNewInstance 524288)
(define NSWorkspaceLaunchAndHide 1048576)
(define NSWorkspaceLaunchAndHideOthers 2097152)
(define NSWorkspaceLaunchDefault 65536)
(define NSWorkspaceLaunchAllowingClassicStartup 131072)
(define NSWorkspaceLaunchPreferringClassic 262144)

;; NSWritingDirection
(define NSWritingDirectionNatural -1)
(define NSWritingDirectionLeftToRight 0)
(define NSWritingDirectionRightToLeft 1)

;; NSWritingDirectionFormatType
(define NSWritingDirectionEmbedding 0)
(define NSWritingDirectionOverride 2)

;; NSWritingToolsBehavior
(define NSWritingToolsBehaviorNone -1)
(define NSWritingToolsBehaviorDefault 0)
(define NSWritingToolsBehaviorComplete 1)
(define NSWritingToolsBehaviorLimited 2)

;; NSWritingToolsCoordinatorContextScope
(define NSWritingToolsCoordinatorContextScopeUserSelection 0)
(define NSWritingToolsCoordinatorContextScopeFullDocument 1)
(define NSWritingToolsCoordinatorContextScopeVisibleArea 2)

;; NSWritingToolsCoordinatorState
(define NSWritingToolsCoordinatorStateInactive 0)
(define NSWritingToolsCoordinatorStateNoninteractive 1)
(define NSWritingToolsCoordinatorStateInteractiveResting 2)
(define NSWritingToolsCoordinatorStateInteractiveStreaming 3)

;; NSWritingToolsCoordinatorTextAnimation
(define NSWritingToolsCoordinatorTextAnimationAnticipate 0)
(define NSWritingToolsCoordinatorTextAnimationRemove 1)
(define NSWritingToolsCoordinatorTextAnimationInsert 2)
(define NSWritingToolsCoordinatorTextAnimationAnticipateInactive 8)
(define NSWritingToolsCoordinatorTextAnimationTranslate 9)

;; NSWritingToolsCoordinatorTextReplacementReason
(define NSWritingToolsCoordinatorTextReplacementReasonInteractive 0)
(define NSWritingToolsCoordinatorTextReplacementReasonNoninteractive 1)

;; NSWritingToolsCoordinatorTextUpdateReason
(define NSWritingToolsCoordinatorTextUpdateReasonTyping 0)
(define NSWritingToolsCoordinatorTextUpdateReasonUndoRedo 1)

;; NSWritingToolsResultOptions
(define NSWritingToolsResultDefault 0)
(define NSWritingToolsResultPlainText 1)
(define NSWritingToolsResultRichText 2)
(define NSWritingToolsResultList 4)
(define NSWritingToolsResultTable 8)
(define NSWritingToolsResultPresentationIntent 16)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/AppKitErrors.h:15:1)
(define NSTextReadInapplicableDocumentTypeError 65806)
(define NSTextWriteInapplicableDocumentTypeError 66062)
(define NSTextReadWriteErrorMinimum 65792)
(define NSTextReadWriteErrorMaximum 66303)
(define NSFontAssetDownloadError 66304)
(define NSFontErrorMinimum 66304)
(define NSFontErrorMaximum 66335)
(define NSServiceApplicationNotFoundError 66560)
(define NSServiceApplicationLaunchFailedError 66561)
(define NSServiceRequestTimedOutError 66562)
(define NSServiceInvalidPasteboardDataError 66563)
(define NSServiceMalformedServiceDictionaryError 66564)
(define NSServiceMiscellaneousError 66800)
(define NSServiceErrorMinimum 66560)
(define NSServiceErrorMaximum 66817)
(define NSSharingServiceNotConfiguredError 67072)
(define NSSharingServiceErrorMinimum 67072)
(define NSSharingServiceErrorMaximum 67327)
(define NSWorkspaceAuthorizationInvalidError 67328)
(define NSWorkspaceErrorMinimum 67328)
(define NSWorkspaceErrorMaximum 67455)
(define NSWindowSharingRequestAlreadyRequested 67456)
(define NSWindowSharingRequestNoEligibleSession 67457)
(define NSWindowSharingRequestUnspecifiedError 67458)
(define NSWindowSharingErrorMinimum 67456)
(define NSWindowSharingErrorMaximum 67466)
(define NSPasteboardMiscellaneousError 67584)
(define NSPasteboardCommunicationError 67585)
(define NSPasteboardInvalidArgumentError 67586)
(define NSPasteboardContentsNotAvailableError 67587)
(define NSPasteboardErrorMinimum 67584)
(define NSPasteboardErrorMaximum 67839)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSAccessibilityConstants.h:731:1)
(define NSAccessibilityHourMinuteDateTimeComponentsFlag 12)
(define NSAccessibilityHourMinuteSecondDateTimeComponentsFlag 14)
(define NSAccessibilityYearMonthDateTimeComponentsFlag 192)
(define NSAccessibilityYearMonthDayDateTimeComponentsFlag 224)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSApplication.h:127:1)
(define NSUpdateWindowsRunLoopOrdering 500000)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSApplication.h:698:1)
(define NSRunStoppedResponse -1000)
(define NSRunAbortedResponse -1001)
(define NSRunContinuesResponse -1002)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSAttributedString.h:379:1)
(define NSNoUnderlineStyle 0)
(define NSSingleUnderlineStyle 1)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSCell.h:363:1)
(define NSAnyType 0)
(define NSIntType 1)
(define NSPositiveIntType 2)
(define NSFloatType 3)
(define NSPositiveFloatType 4)
(define NSDoubleType 6)
(define NSPositiveDoubleType 7)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSEvent.h:557:1)
(define NSUpArrowFunctionKey 63232)
(define NSDownArrowFunctionKey 63233)
(define NSLeftArrowFunctionKey 63234)
(define NSRightArrowFunctionKey 63235)
(define NSF1FunctionKey 63236)
(define NSF2FunctionKey 63237)
(define NSF3FunctionKey 63238)
(define NSF4FunctionKey 63239)
(define NSF5FunctionKey 63240)
(define NSF6FunctionKey 63241)
(define NSF7FunctionKey 63242)
(define NSF8FunctionKey 63243)
(define NSF9FunctionKey 63244)
(define NSF10FunctionKey 63245)
(define NSF11FunctionKey 63246)
(define NSF12FunctionKey 63247)
(define NSF13FunctionKey 63248)
(define NSF14FunctionKey 63249)
(define NSF15FunctionKey 63250)
(define NSF16FunctionKey 63251)
(define NSF17FunctionKey 63252)
(define NSF18FunctionKey 63253)
(define NSF19FunctionKey 63254)
(define NSF20FunctionKey 63255)
(define NSF21FunctionKey 63256)
(define NSF22FunctionKey 63257)
(define NSF23FunctionKey 63258)
(define NSF24FunctionKey 63259)
(define NSF25FunctionKey 63260)
(define NSF26FunctionKey 63261)
(define NSF27FunctionKey 63262)
(define NSF28FunctionKey 63263)
(define NSF29FunctionKey 63264)
(define NSF30FunctionKey 63265)
(define NSF31FunctionKey 63266)
(define NSF32FunctionKey 63267)
(define NSF33FunctionKey 63268)
(define NSF34FunctionKey 63269)
(define NSF35FunctionKey 63270)
(define NSInsertFunctionKey 63271)
(define NSDeleteFunctionKey 63272)
(define NSHomeFunctionKey 63273)
(define NSBeginFunctionKey 63274)
(define NSEndFunctionKey 63275)
(define NSPageUpFunctionKey 63276)
(define NSPageDownFunctionKey 63277)
(define NSPrintScreenFunctionKey 63278)
(define NSScrollLockFunctionKey 63279)
(define NSPauseFunctionKey 63280)
(define NSSysReqFunctionKey 63281)
(define NSBreakFunctionKey 63282)
(define NSResetFunctionKey 63283)
(define NSStopFunctionKey 63284)
(define NSMenuFunctionKey 63285)
(define NSUserFunctionKey 63286)
(define NSSystemFunctionKey 63287)
(define NSPrintFunctionKey 63288)
(define NSClearLineFunctionKey 63289)
(define NSClearDisplayFunctionKey 63290)
(define NSInsertLineFunctionKey 63291)
(define NSDeleteLineFunctionKey 63292)
(define NSInsertCharFunctionKey 63293)
(define NSDeleteCharFunctionKey 63294)
(define NSPrevFunctionKey 63295)
(define NSNextFunctionKey 63296)
(define NSSelectFunctionKey 63297)
(define NSExecuteFunctionKey 63298)
(define NSUndoFunctionKey 63299)
(define NSRedoFunctionKey 63300)
(define NSFindFunctionKey 63301)
(define NSHelpFunctionKey 63302)
(define NSModeSwitchFunctionKey 63303)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSFont.h:147:1)
(define NSControlGlyph 16777215)
(define NSNullGlyph 0)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSFontDescriptor.h:206:1)
(define NSFontUnknownClass 0)
(define NSFontOldStyleSerifsClass 268435456)
(define NSFontTransitionalSerifsClass 536870912)
(define NSFontModernSerifsClass 805306368)
(define NSFontClarendonSerifsClass 1073741824)
(define NSFontSlabSerifsClass 1342177280)
(define NSFontFreeformSerifsClass 1879048192)
(define NSFontSansSerifClass -2147483648)
(define NSFontOrnamentalsClass -1879048192)
(define NSFontScriptsClass -1610612736)
(define NSFontSymbolicClass -1073741824)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSFontDescriptor.h:220:1)
(define NSFontFamilyClassMask 4026531840)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSFontDescriptor.h:224:1)
(define NSFontItalicTrait 1)
(define NSFontBoldTrait 2)
(define NSFontExpandedTrait 32)
(define NSFontCondensedTrait 64)
(define NSFontMonoSpaceTrait 1024)
(define NSFontVerticalTrait 2048)
(define NSFontUIOptimizedTrait 4096)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSFontPanel.h:65:1)
(define NSFontPanelFaceModeMask 1)
(define NSFontPanelSizeModeMask 2)
(define NSFontPanelCollectionModeMask 4)
(define NSFontPanelUnderlineEffectModeMask 256)
(define NSFontPanelStrikethroughEffectModeMask 512)
(define NSFontPanelTextColorEffectModeMask 1024)
(define NSFontPanelDocumentColorEffectModeMask 2048)
(define NSFontPanelShadowEffectModeMask 4096)
(define NSFontPanelAllEffectsModeMask 1048320)
(define NSFontPanelStandardModesMask 65535)
(define NSFontPanelAllModesMask 4294967295)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSFontPanel.h:82:1)
(define NSFPPreviewButton 131)
(define NSFPRevertButton 130)
(define NSFPSetButton 132)
(define NSFPPreviewField 128)
(define NSFPSizeField 129)
(define NSFPSizeTitle 133)
(define NSFPCurrentField 134)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSGlyphGenerator.h:18:1)
(define NSShowControlGlyphs 1)
(define NSShowInvisibleGlyphs 2)
(define NSWantsBidiLevels 4)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSImageRep.h:29:1)
(define NSImageRepMatchesDevice 0)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSInterfaceStyle.h:13:1)
(define NSNoInterfaceStyle 0)
(define NSNextStepInterfaceStyle 1)
(define NSWindows95InterfaceStyle 2)
(define NSMacintoshInterfaceStyle 3)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSLayoutManager.h:438:1)
(define NSGlyphAttributeSoft 0)
(define NSGlyphAttributeElastic 1)
(define NSGlyphAttributeBidiLevel 2)
(define NSGlyphAttributeInscribe 5)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSOpenGL.h:104:1)
(define NSOpenGLProfileVersionLegacy 4096)
(define NSOpenGLProfileVersion3_2Core 12800)
(define NSOpenGLProfileVersion4_1Core 16640)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSOpenGL.h:59:1)
(define NSOpenGLPFAAllRenderers 1)
(define NSOpenGLPFATripleBuffer 3)
(define NSOpenGLPFADoubleBuffer 5)
(define NSOpenGLPFAAuxBuffers 7)
(define NSOpenGLPFAColorSize 8)
(define NSOpenGLPFAAlphaSize 11)
(define NSOpenGLPFADepthSize 12)
(define NSOpenGLPFAStencilSize 13)
(define NSOpenGLPFAAccumSize 14)
(define NSOpenGLPFAMinimumPolicy 51)
(define NSOpenGLPFAMaximumPolicy 52)
(define NSOpenGLPFASampleBuffers 55)
(define NSOpenGLPFASamples 56)
(define NSOpenGLPFAAuxDepthStencil 57)
(define NSOpenGLPFAColorFloat 58)
(define NSOpenGLPFAMultisample 59)
(define NSOpenGLPFASupersample 60)
(define NSOpenGLPFASampleAlpha 61)
(define NSOpenGLPFARendererID 70)
(define NSOpenGLPFANoRecovery 72)
(define NSOpenGLPFAAccelerated 73)
(define NSOpenGLPFAClosestPolicy 74)
(define NSOpenGLPFABackingStore 76)
(define NSOpenGLPFAScreenMask 84)
(define NSOpenGLPFAAllowOfflineRenderers 96)
(define NSOpenGLPFAAcceleratedCompute 97)
(define NSOpenGLPFAOpenGLProfile 99)
(define NSOpenGLPFAVirtualScreenCount 128)
(define NSOpenGLPFAStereo 6)
(define NSOpenGLPFAOffScreen 53)
(define NSOpenGLPFAFullScreen 54)
(define NSOpenGLPFASingleRenderer 71)
(define NSOpenGLPFARobust 75)
(define NSOpenGLPFAMPSafe 78)
(define NSOpenGLPFAWindow 80)
(define NSOpenGLPFAMultiScreen 81)
(define NSOpenGLPFACompliant 83)
(define NSOpenGLPFAPixelBuffer 90)
(define NSOpenGLPFARemotePixelBuffer 91)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSOutlineView.h:27:1)
(define NSOutlineViewDropOnItemIndex -1)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSPanel.h:44:1)
(define NSAlertDefaultReturn 1)
(define NSAlertAlternateReturn 0)
(define NSAlertOtherReturn -1)
(define NSAlertErrorReturn -2)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSPanel.h:50:1)
(define NSOKButton 1)
(define NSCancelButton 0)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSSavePanel.h:292:1)
(define NSFileHandlingPanelCancelButton 0)
(define NSFileHandlingPanelOKButton 1)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSText.h:150:1)
(define NSEnterCharacter 3)
(define NSBackspaceCharacter 8)
(define NSTabCharacter 9)
(define NSNewlineCharacter 10)
(define NSFormFeedCharacter 12)
(define NSCarriageReturnCharacter 13)
(define NSBackTabCharacter 25)
(define NSDeleteCharacter 127)
(define NSLineSeparatorCharacter 8232)
(define NSParagraphSeparatorCharacter 8233)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSText.h:187:1)
(define NSIllegalTextMovement 0)
(define NSReturnTextMovement 16)
(define NSTabTextMovement 17)
(define NSBacktabTextMovement 18)
(define NSLeftTextMovement 19)
(define NSRightTextMovement 20)
(define NSUpTextMovement 21)
(define NSDownTextMovement 22)
(define NSCancelTextMovement 23)
(define NSOtherTextMovement 0)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSText.h:210:1)
(define NSTextWritingDirectionEmbedding 0)
(define NSTextWritingDirectionOverride 2)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSTextAttachment.h:18:1)
(define NSAttachmentCharacter 65532)

;; enum (unnamed at System/Library/Frameworks/AppKit.framework/Headers/NSWindow.h:75:1)
(define NSDisplayWindowRunLoopOrdering 600000)
(define NSResetCursorRectsRunLoopOrdering 700000)

;; NSHorizontalDirection
(define left 0)
(define right 1)

;; NSVerticalDirection
(define up 0)
(define down 1)

;; Depth

;; FrameResizePosition

