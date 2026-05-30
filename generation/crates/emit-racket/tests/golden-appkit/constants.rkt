#lang racket/base
;; Generated constant definitions for AppKit

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->]))

(provide/contract
  [NSAbortModalException cpointer?]
  [NSAbortPrintingException cpointer?]
  [NSAboutPanelOptionApplicationIcon cpointer?]
  [NSAboutPanelOptionApplicationName cpointer?]
  [NSAboutPanelOptionApplicationVersion cpointer?]
  [NSAboutPanelOptionCredits cpointer?]
  [NSAboutPanelOptionVersion cpointer?]
  [NSAccessibilityActivationPointAttribute cpointer?]
  [NSAccessibilityAllowedValuesAttribute cpointer?]
  [NSAccessibilityAlternateUIVisibleAttribute cpointer?]
  [NSAccessibilityAnnotationElement cpointer?]
  [NSAccessibilityAnnotationLabel cpointer?]
  [NSAccessibilityAnnotationLocation cpointer?]
  [NSAccessibilityAnnotationTextAttribute cpointer?]
  [NSAccessibilityAnnouncementKey cpointer?]
  [NSAccessibilityAnnouncementRequestedNotification cpointer?]
  [NSAccessibilityAnyTypeSearchKey cpointer?]
  [NSAccessibilityApplicationActivatedNotification cpointer?]
  [NSAccessibilityApplicationDeactivatedNotification cpointer?]
  [NSAccessibilityApplicationHiddenNotification cpointer?]
  [NSAccessibilityApplicationRole cpointer?]
  [NSAccessibilityApplicationShownNotification cpointer?]
  [NSAccessibilityArticleSearchKey cpointer?]
  [NSAccessibilityAscendingSortDirectionValue cpointer?]
  [NSAccessibilityAttachmentTextAttribute cpointer?]
  [NSAccessibilityAttributedStringForRangeParameterizedAttribute cpointer?]
  [NSAccessibilityAutoInteractableAttribute cpointer?]
  [NSAccessibilityAutocorrectedTextAttribute cpointer?]
  [NSAccessibilityAutocorrectionOccurredNotification cpointer?]
  [NSAccessibilityBackgroundColorTextAttribute cpointer?]
  [NSAccessibilityBlockQuoteLevelAttribute cpointer?]
  [NSAccessibilityBlockquoteSameLevelSearchKey cpointer?]
  [NSAccessibilityBlockquoteSearchKey cpointer?]
  [NSAccessibilityBoldFontSearchKey cpointer?]
  [NSAccessibilityBoundsForRangeParameterizedAttribute cpointer?]
  [NSAccessibilityBrowserRole cpointer?]
  [NSAccessibilityBusyIndicatorRole cpointer?]
  [NSAccessibilityButtonRole cpointer?]
  [NSAccessibilityButtonSearchKey cpointer?]
  [NSAccessibilityCancelAction cpointer?]
  [NSAccessibilityCancelButtonAttribute cpointer?]
  [NSAccessibilityCellForColumnAndRowParameterizedAttribute cpointer?]
  [NSAccessibilityCellRole cpointer?]
  [NSAccessibilityCenterTabStopMarkerTypeValue cpointer?]
  [NSAccessibilityCentimetersUnitValue cpointer?]
  [NSAccessibilityCheckBoxRole cpointer?]
  [NSAccessibilityCheckBoxSearchKey cpointer?]
  [NSAccessibilityChildrenAttribute cpointer?]
  [NSAccessibilityChildrenInNavigationOrderAttribute cpointer?]
  [NSAccessibilityClearButtonAttribute cpointer?]
  [NSAccessibilityCloseButtonAttribute cpointer?]
  [NSAccessibilityCloseButtonSubrole cpointer?]
  [NSAccessibilityCollectionListSubrole cpointer?]
  [NSAccessibilityColorWellRole cpointer?]
  [NSAccessibilityColumnCountAttribute cpointer?]
  [NSAccessibilityColumnHeaderUIElementsAttribute cpointer?]
  [NSAccessibilityColumnIndexRangeAttribute cpointer?]
  [NSAccessibilityColumnRole cpointer?]
  [NSAccessibilityColumnTitlesAttribute cpointer?]
  [NSAccessibilityColumnsAttribute cpointer?]
  [NSAccessibilityComboBoxRole cpointer?]
  [NSAccessibilityConfirmAction cpointer?]
  [NSAccessibilityContainsProtectedContentAttribute cpointer?]
  [NSAccessibilityContentListSubrole cpointer?]
  [NSAccessibilityContentsAttribute cpointer?]
  [NSAccessibilityControlSearchKey cpointer?]
  [NSAccessibilityCreatedNotification cpointer?]
  [NSAccessibilityCriticalValueAttribute cpointer?]
  [NSAccessibilityCustomTextAttribute cpointer?]
  [NSAccessibilityDateTimeAreaRole cpointer?]
  [NSAccessibilityDateTimeComponentsAttribute cpointer?]
  [NSAccessibilityDecimalTabStopMarkerTypeValue cpointer?]
  [NSAccessibilityDecrementAction cpointer?]
  [NSAccessibilityDecrementArrowSubrole cpointer?]
  [NSAccessibilityDecrementButtonAttribute cpointer?]
  [NSAccessibilityDecrementPageSubrole cpointer?]
  [NSAccessibilityDefaultButtonAttribute cpointer?]
  [NSAccessibilityDefinitionListSubrole cpointer?]
  [NSAccessibilityDeleteAction cpointer?]
  [NSAccessibilityDescendingSortDirectionValue cpointer?]
  [NSAccessibilityDescriptionAttribute cpointer?]
  [NSAccessibilityDescriptionListSubrole cpointer?]
  [NSAccessibilityDialogSubrole cpointer?]
  [NSAccessibilityDifferentTypeSearchKey cpointer?]
  [NSAccessibilityDisclosedByRowAttribute cpointer?]
  [NSAccessibilityDisclosedRowsAttribute cpointer?]
  [NSAccessibilityDisclosingAttribute cpointer?]
  [NSAccessibilityDisclosureLevelAttribute cpointer?]
  [NSAccessibilityDisclosureTriangleRole cpointer?]
  [NSAccessibilityDocumentAttribute cpointer?]
  [NSAccessibilityDraggingDestinationDragAcceptedNotification cpointer?]
  [NSAccessibilityDraggingDestinationDragNotAcceptedNotification cpointer?]
  [NSAccessibilityDraggingDestinationDropAllowedNotification cpointer?]
  [NSAccessibilityDraggingDestinationDropNotAllowedNotification cpointer?]
  [NSAccessibilityDraggingSourceDragBeganNotification cpointer?]
  [NSAccessibilityDraggingSourceDragEndedNotification cpointer?]
  [NSAccessibilityDrawerCreatedNotification cpointer?]
  [NSAccessibilityDrawerRole cpointer?]
  [NSAccessibilityEditedAttribute cpointer?]
  [NSAccessibilityEmbeddedImageDescriptionAttribute cpointer?]
  [NSAccessibilityEnabledAttribute cpointer?]
  [NSAccessibilityErrorCodeExceptionInfo cpointer?]
  [NSAccessibilityException cpointer?]
  [NSAccessibilityExpandedAttribute cpointer?]
  [NSAccessibilityExtrasMenuBarAttribute cpointer?]
  [NSAccessibilityFilenameAttribute cpointer?]
  [NSAccessibilityFirstLineIndentMarkerTypeValue cpointer?]
  [NSAccessibilityFloatingWindowSubrole cpointer?]
  [NSAccessibilityFocusedAttribute cpointer?]
  [NSAccessibilityFocusedUIElementAttribute cpointer?]
  [NSAccessibilityFocusedUIElementChangedNotification cpointer?]
  [NSAccessibilityFocusedWindowAttribute cpointer?]
  [NSAccessibilityFocusedWindowChangedNotification cpointer?]
  [NSAccessibilityFontBoldAttribute cpointer?]
  [NSAccessibilityFontChangeSearchKey cpointer?]
  [NSAccessibilityFontColorChangeSearchKey cpointer?]
  [NSAccessibilityFontFamilyKey cpointer?]
  [NSAccessibilityFontItalicAttribute cpointer?]
  [NSAccessibilityFontNameKey cpointer?]
  [NSAccessibilityFontSizeKey cpointer?]
  [NSAccessibilityFontTextAttribute cpointer?]
  [NSAccessibilityForegroundColorTextAttribute cpointer?]
  [NSAccessibilityFrameSearchKey cpointer?]
  [NSAccessibilityFrontmostAttribute cpointer?]
  [NSAccessibilityFullScreenButtonAttribute cpointer?]
  [NSAccessibilityFullScreenButtonSubrole cpointer?]
  [NSAccessibilityGraphicSearchKey cpointer?]
  [NSAccessibilityGridRole cpointer?]
  [NSAccessibilityGroupRole cpointer?]
  [NSAccessibilityGrowAreaAttribute cpointer?]
  [NSAccessibilityGrowAreaRole cpointer?]
  [NSAccessibilityHandleRole cpointer?]
  [NSAccessibilityHandlesAttribute cpointer?]
  [NSAccessibilityHeadIndentMarkerTypeValue cpointer?]
  [NSAccessibilityHeaderAttribute cpointer?]
  [NSAccessibilityHeadingLevel1SearchKey cpointer?]
  [NSAccessibilityHeadingLevel2SearchKey cpointer?]
  [NSAccessibilityHeadingLevel3SearchKey cpointer?]
  [NSAccessibilityHeadingLevel4SearchKey cpointer?]
  [NSAccessibilityHeadingLevel5SearchKey cpointer?]
  [NSAccessibilityHeadingLevel6SearchKey cpointer?]
  [NSAccessibilityHeadingLevelAttribute cpointer?]
  [NSAccessibilityHeadingRole cpointer?]
  [NSAccessibilityHeadingSameLevelSearchKey cpointer?]
  [NSAccessibilityHeadingSearchKey cpointer?]
  [NSAccessibilityHelpAttribute cpointer?]
  [NSAccessibilityHelpTagCreatedNotification cpointer?]
  [NSAccessibilityHelpTagRole cpointer?]
  [NSAccessibilityHiddenAttribute cpointer?]
  [NSAccessibilityHorizontalOrientationValue cpointer?]
  [NSAccessibilityHorizontalScrollBarAttribute cpointer?]
  [NSAccessibilityHorizontalUnitDescriptionAttribute cpointer?]
  [NSAccessibilityHorizontalUnitsAttribute cpointer?]
  [NSAccessibilityIdentifierAttribute cpointer?]
  [NSAccessibilityImageRole cpointer?]
  [NSAccessibilityInchesUnitValue cpointer?]
  [NSAccessibilityIncrementAction cpointer?]
  [NSAccessibilityIncrementArrowSubrole cpointer?]
  [NSAccessibilityIncrementButtonAttribute cpointer?]
  [NSAccessibilityIncrementPageSubrole cpointer?]
  [NSAccessibilityIncrementorRole cpointer?]
  [NSAccessibilityIndexAttribute cpointer?]
  [NSAccessibilityIndexForChildUIElementAttribute cpointer?]
  [NSAccessibilityIndexForChildUIElementInNavigationOrderAttribute cpointer?]
  [NSAccessibilityInsertionPointLineNumberAttribute cpointer?]
  [NSAccessibilityItalicFontSearchKey cpointer?]
  [NSAccessibilityKeyboardFocusableSearchKey cpointer?]
  [NSAccessibilityLabelUIElementsAttribute cpointer?]
  [NSAccessibilityLabelValueAttribute cpointer?]
  [NSAccessibilityLandmarkSearchKey cpointer?]
  [NSAccessibilityLanguageAttribute cpointer?]
  [NSAccessibilityLanguageTextAttribute cpointer?]
  [NSAccessibilityLayoutAreaRole cpointer?]
  [NSAccessibilityLayoutChangedNotification cpointer?]
  [NSAccessibilityLayoutItemRole cpointer?]
  [NSAccessibilityLayoutPointForScreenPointParameterizedAttribute cpointer?]
  [NSAccessibilityLayoutSizeForScreenSizeParameterizedAttribute cpointer?]
  [NSAccessibilityLeftTabStopMarkerTypeValue cpointer?]
  [NSAccessibilityLevelIndicatorRole cpointer?]
  [NSAccessibilityLineForIndexParameterizedAttribute cpointer?]
  [NSAccessibilityLinkRole cpointer?]
  [NSAccessibilityLinkSearchKey cpointer?]
  [NSAccessibilityLinkTextAttribute cpointer?]
  [NSAccessibilityLinkedUIElementsAttribute cpointer?]
  [NSAccessibilityListItemIndexTextAttribute cpointer?]
  [NSAccessibilityListItemLevelTextAttribute cpointer?]
  [NSAccessibilityListItemPrefixTextAttribute cpointer?]
  [NSAccessibilityListMarkerRole cpointer?]
  [NSAccessibilityListRole cpointer?]
  [NSAccessibilityListSearchKey cpointer?]
  [NSAccessibilityLiveRegionSearchKey cpointer?]
  [NSAccessibilityMainAttribute cpointer?]
  [NSAccessibilityMainWindowAttribute cpointer?]
  [NSAccessibilityMainWindowChangedNotification cpointer?]
  [NSAccessibilityMarkedMisspelledTextAttribute cpointer?]
  [NSAccessibilityMarkerGroupUIElementAttribute cpointer?]
  [NSAccessibilityMarkerTypeAttribute cpointer?]
  [NSAccessibilityMarkerTypeDescriptionAttribute cpointer?]
  [NSAccessibilityMarkerUIElementsAttribute cpointer?]
  [NSAccessibilityMarkerValuesAttribute cpointer?]
  [NSAccessibilityMatteContentUIElementAttribute cpointer?]
  [NSAccessibilityMatteHoleAttribute cpointer?]
  [NSAccessibilityMatteRole cpointer?]
  [NSAccessibilityMaxValueAttribute cpointer?]
  [NSAccessibilityMenuBarAttribute cpointer?]
  [NSAccessibilityMenuBarItemRole cpointer?]
  [NSAccessibilityMenuBarRole cpointer?]
  [NSAccessibilityMenuButtonRole cpointer?]
  [NSAccessibilityMenuItemRole cpointer?]
  [NSAccessibilityMenuRole cpointer?]
  [NSAccessibilityMinValueAttribute cpointer?]
  [NSAccessibilityMinimizeButtonAttribute cpointer?]
  [NSAccessibilityMinimizeButtonSubrole cpointer?]
  [NSAccessibilityMinimizedAttribute cpointer?]
  [NSAccessibilityMisspelledTextAttribute cpointer?]
  [NSAccessibilityMisspelledWordSearchKey cpointer?]
  [NSAccessibilityModalAttribute cpointer?]
  [NSAccessibilityMovedNotification cpointer?]
  [NSAccessibilityNextContentsAttribute cpointer?]
  [NSAccessibilityNumberOfCharactersAttribute cpointer?]
  [NSAccessibilityOrderedByRowAttribute cpointer?]
  [NSAccessibilityOrientationAttribute cpointer?]
  [NSAccessibilityOutlineRole cpointer?]
  [NSAccessibilityOutlineRowSubrole cpointer?]
  [NSAccessibilityOutlineSearchKey cpointer?]
  [NSAccessibilityOverflowButtonAttribute cpointer?]
  [NSAccessibilityPageRole cpointer?]
  [NSAccessibilityParentAttribute cpointer?]
  [NSAccessibilityPathAttribute cpointer?]
  [NSAccessibilityPicasUnitValue cpointer?]
  [NSAccessibilityPickAction cpointer?]
  [NSAccessibilityPlaceholderValueAttribute cpointer?]
  [NSAccessibilityPlainTextSearchKey cpointer?]
  [NSAccessibilityPointsUnitValue cpointer?]
  [NSAccessibilityPopUpButtonRole cpointer?]
  [NSAccessibilityPopoverRole cpointer?]
  [NSAccessibilityPositionAttribute cpointer?]
  [NSAccessibilityPressAction cpointer?]
  [NSAccessibilityPreviousContentsAttribute cpointer?]
  [NSAccessibilityPriorityKey cpointer?]
  [NSAccessibilityProgressIndicatorRole cpointer?]
  [NSAccessibilityProxyAttribute cpointer?]
  [NSAccessibilityRTFForRangeParameterizedAttribute cpointer?]
  [NSAccessibilityRadioButtonRole cpointer?]
  [NSAccessibilityRadioGroupRole cpointer?]
  [NSAccessibilityRadioGroupSearchKey cpointer?]
  [NSAccessibilityRaiseAction cpointer?]
  [NSAccessibilityRangeForIndexParameterizedAttribute cpointer?]
  [NSAccessibilityRangeForLineParameterizedAttribute cpointer?]
  [NSAccessibilityRangeForPositionParameterizedAttribute cpointer?]
  [NSAccessibilityRatingIndicatorSubrole cpointer?]
  [NSAccessibilityRelevanceIndicatorRole cpointer?]
  [NSAccessibilityRequiredAttribute cpointer?]
  [NSAccessibilityResizedNotification cpointer?]
  [NSAccessibilityResultsForSearchPredicateParameterizedAttribute cpointer?]
  [NSAccessibilityRightTabStopMarkerTypeValue cpointer?]
  [NSAccessibilityRoleAttribute cpointer?]
  [NSAccessibilityRoleDescriptionAttribute cpointer?]
  [NSAccessibilityRowCollapsedNotification cpointer?]
  [NSAccessibilityRowCountAttribute cpointer?]
  [NSAccessibilityRowCountChangedNotification cpointer?]
  [NSAccessibilityRowExpandedNotification cpointer?]
  [NSAccessibilityRowHeaderUIElementsAttribute cpointer?]
  [NSAccessibilityRowIndexRangeAttribute cpointer?]
  [NSAccessibilityRowRole cpointer?]
  [NSAccessibilityRowsAttribute cpointer?]
  [NSAccessibilityRulerMarkerRole cpointer?]
  [NSAccessibilityRulerRole cpointer?]
  [NSAccessibilitySameTypeSearchKey cpointer?]
  [NSAccessibilityScreenPointForLayoutPointParameterizedAttribute cpointer?]
  [NSAccessibilityScreenSizeForLayoutSizeParameterizedAttribute cpointer?]
  [NSAccessibilityScrollAreaRole cpointer?]
  [NSAccessibilityScrollBarRole cpointer?]
  [NSAccessibilityScrollToVisibleAction cpointer?]
  [NSAccessibilitySearchButtonAttribute cpointer?]
  [NSAccessibilitySearchCurrentElementKey cpointer?]
  [NSAccessibilitySearchCurrentRangeKey cpointer?]
  [NSAccessibilitySearchDirectionKey cpointer?]
  [NSAccessibilitySearchDirectionNext cpointer?]
  [NSAccessibilitySearchDirectionPrevious cpointer?]
  [NSAccessibilitySearchFieldSubrole cpointer?]
  [NSAccessibilitySearchIdentifiersKey cpointer?]
  [NSAccessibilitySearchMenuAttribute cpointer?]
  [NSAccessibilitySearchResultDescriptionOverrideKey cpointer?]
  [NSAccessibilitySearchResultElementKey cpointer?]
  [NSAccessibilitySearchResultLoaderKey cpointer?]
  [NSAccessibilitySearchResultRangeKey cpointer?]
  [NSAccessibilitySearchResultsLimitKey cpointer?]
  [NSAccessibilitySearchTextKey cpointer?]
  [NSAccessibilitySectionListSubrole cpointer?]
  [NSAccessibilitySecureTextFieldSubrole cpointer?]
  [NSAccessibilitySelectedAttribute cpointer?]
  [NSAccessibilitySelectedCellsAttribute cpointer?]
  [NSAccessibilitySelectedCellsChangedNotification cpointer?]
  [NSAccessibilitySelectedChildrenAttribute cpointer?]
  [NSAccessibilitySelectedChildrenChangedNotification cpointer?]
  [NSAccessibilitySelectedChildrenMovedNotification cpointer?]
  [NSAccessibilitySelectedColumnsAttribute cpointer?]
  [NSAccessibilitySelectedColumnsChangedNotification cpointer?]
  [NSAccessibilitySelectedRowsAttribute cpointer?]
  [NSAccessibilitySelectedRowsChangedNotification cpointer?]
  [NSAccessibilitySelectedTextAttribute cpointer?]
  [NSAccessibilitySelectedTextChangedNotification cpointer?]
  [NSAccessibilitySelectedTextRangeAttribute cpointer?]
  [NSAccessibilitySelectedTextRangesAttribute cpointer?]
  [NSAccessibilityServesAsTitleForUIElementsAttribute cpointer?]
  [NSAccessibilityShadowTextAttribute cpointer?]
  [NSAccessibilitySharedCharacterRangeAttribute cpointer?]
  [NSAccessibilitySharedFocusElementsAttribute cpointer?]
  [NSAccessibilitySharedTextUIElementsAttribute cpointer?]
  [NSAccessibilitySheetCreatedNotification cpointer?]
  [NSAccessibilitySheetRole cpointer?]
  [NSAccessibilityShowAlternateUIAction cpointer?]
  [NSAccessibilityShowDefaultUIAction cpointer?]
  [NSAccessibilityShowMenuAction cpointer?]
  [NSAccessibilityShownMenuAttribute cpointer?]
  [NSAccessibilitySizeAttribute cpointer?]
  [NSAccessibilitySliderRole cpointer?]
  [NSAccessibilitySortButtonRole cpointer?]
  [NSAccessibilitySortButtonSubrole cpointer?]
  [NSAccessibilitySortDirectionAttribute cpointer?]
  [NSAccessibilitySplitGroupRole cpointer?]
  [NSAccessibilitySplitterRole cpointer?]
  [NSAccessibilitySplittersAttribute cpointer?]
  [NSAccessibilityStandardWindowSubrole cpointer?]
  [NSAccessibilityStaticTextRole cpointer?]
  [NSAccessibilityStaticTextSearchKey cpointer?]
  [NSAccessibilityStrikethroughColorTextAttribute cpointer?]
  [NSAccessibilityStrikethroughTextAttribute cpointer?]
  [NSAccessibilityStringForRangeParameterizedAttribute cpointer?]
  [NSAccessibilityStyleChangeSearchKey cpointer?]
  [NSAccessibilityStyleRangeForIndexParameterizedAttribute cpointer?]
  [NSAccessibilitySubroleAttribute cpointer?]
  [NSAccessibilitySuggestionSubrole cpointer?]
  [NSAccessibilitySuperscriptTextAttribute cpointer?]
  [NSAccessibilitySwitchSubrole cpointer?]
  [NSAccessibilitySystemDialogSubrole cpointer?]
  [NSAccessibilitySystemFloatingWindowSubrole cpointer?]
  [NSAccessibilitySystemWideRole cpointer?]
  [NSAccessibilityTabButtonSubrole cpointer?]
  [NSAccessibilityTabGroupRole cpointer?]
  [NSAccessibilityTableRole cpointer?]
  [NSAccessibilityTableRowSubrole cpointer?]
  [NSAccessibilityTableSameLevelSearchKey cpointer?]
  [NSAccessibilityTableSearchKey cpointer?]
  [NSAccessibilityTabsAttribute cpointer?]
  [NSAccessibilityTailIndentMarkerTypeValue cpointer?]
  [NSAccessibilityTextAlignmentAttribute cpointer?]
  [NSAccessibilityTextAreaRole cpointer?]
  [NSAccessibilityTextAttachmentSubrole cpointer?]
  [NSAccessibilityTextCompletionAttribute cpointer?]
  [NSAccessibilityTextFieldRole cpointer?]
  [NSAccessibilityTextFieldSearchKey cpointer?]
  [NSAccessibilityTextInputMarkedRangeAttribute cpointer?]
  [NSAccessibilityTextInputMarkingSessionBeganNotification cpointer?]
  [NSAccessibilityTextInputMarkingSessionEndedNotification cpointer?]
  [NSAccessibilityTextLinkSubrole cpointer?]
  [NSAccessibilityTextStateChangeTypeKey cpointer?]
  [NSAccessibilityTextStateSyncKey cpointer?]
  [NSAccessibilityTimelineSubrole cpointer?]
  [NSAccessibilityTitleAttribute cpointer?]
  [NSAccessibilityTitleChangedNotification cpointer?]
  [NSAccessibilityTitleUIElementAttribute cpointer?]
  [NSAccessibilityToggleSubrole cpointer?]
  [NSAccessibilityToolbarButtonAttribute cpointer?]
  [NSAccessibilityToolbarButtonSubrole cpointer?]
  [NSAccessibilityToolbarRole cpointer?]
  [NSAccessibilityTopLevelUIElementAttribute cpointer?]
  [NSAccessibilityUIElementDestroyedNotification cpointer?]
  [NSAccessibilityUIElementsForSearchPredicateParameterizedAttribute cpointer?]
  [NSAccessibilityUIElementsKey cpointer?]
  [NSAccessibilityURLAttribute cpointer?]
  [NSAccessibilityUnderlineColorTextAttribute cpointer?]
  [NSAccessibilityUnderlineSearchKey cpointer?]
  [NSAccessibilityUnderlineTextAttribute cpointer?]
  [NSAccessibilityUnitDescriptionAttribute cpointer?]
  [NSAccessibilityUnitsAttribute cpointer?]
  [NSAccessibilityUnitsChangedNotification cpointer?]
  [NSAccessibilityUnknownMarkerTypeValue cpointer?]
  [NSAccessibilityUnknownOrientationValue cpointer?]
  [NSAccessibilityUnknownRole cpointer?]
  [NSAccessibilityUnknownSortDirectionValue cpointer?]
  [NSAccessibilityUnknownSubrole cpointer?]
  [NSAccessibilityUnknownUnitValue cpointer?]
  [NSAccessibilityUnvisitedLinkSearchKey cpointer?]
  [NSAccessibilityValueAttribute cpointer?]
  [NSAccessibilityValueChangedNotification cpointer?]
  [NSAccessibilityValueDescriptionAttribute cpointer?]
  [NSAccessibilityValueIndicatorRole cpointer?]
  [NSAccessibilityVerticalOrientationValue cpointer?]
  [NSAccessibilityVerticalScrollBarAttribute cpointer?]
  [NSAccessibilityVerticalUnitDescriptionAttribute cpointer?]
  [NSAccessibilityVerticalUnitsAttribute cpointer?]
  [NSAccessibilityVisibleCellsAttribute cpointer?]
  [NSAccessibilityVisibleCharacterRangeAttribute cpointer?]
  [NSAccessibilityVisibleChildrenAttribute cpointer?]
  [NSAccessibilityVisibleColumnsAttribute cpointer?]
  [NSAccessibilityVisibleNameKey cpointer?]
  [NSAccessibilityVisibleRowsAttribute cpointer?]
  [NSAccessibilityVisitedAttribute cpointer?]
  [NSAccessibilityVisitedLinkSearchKey cpointer?]
  [NSAccessibilityWarningValueAttribute cpointer?]
  [NSAccessibilityWebAreaRole cpointer?]
  [NSAccessibilityWindowAttribute cpointer?]
  [NSAccessibilityWindowCreatedNotification cpointer?]
  [NSAccessibilityWindowDeminiaturizedNotification cpointer?]
  [NSAccessibilityWindowMiniaturizedNotification cpointer?]
  [NSAccessibilityWindowMovedNotification cpointer?]
  [NSAccessibilityWindowResizedNotification cpointer?]
  [NSAccessibilityWindowRole cpointer?]
  [NSAccessibilityWindowsAttribute cpointer?]
  [NSAccessibilityZoomButtonAttribute cpointer?]
  [NSAccessibilityZoomButtonSubrole cpointer?]
  [NSAdaptiveImageGlyphAttributeName cpointer?]
  [NSAlignmentBinding cpointer?]
  [NSAllRomanInputSourcesLocaleIdentifier cpointer?]
  [NSAllowsEditingMultipleValuesSelectionBindingOption cpointer?]
  [NSAllowsNullArgumentBindingOption cpointer?]
  [NSAlternateImageBinding cpointer?]
  [NSAlternateTitleBinding cpointer?]
  [NSAlwaysPresentsApplicationModalAlertsBindingOption cpointer?]
  [NSAnimateBinding cpointer?]
  [NSAnimationDelayBinding cpointer?]
  [NSAnimationProgressMark cpointer?]
  [NSAnimationProgressMarkNotification cpointer?]
  [NSAnimationTriggerOrderIn cpointer?]
  [NSAnimationTriggerOrderOut cpointer?]
  [NSAntialiasThresholdChangedNotification cpointer?]
  [NSApp cpointer?]
  [NSAppKitIgnoredException cpointer?]
  [NSAppKitVersionNumber real?]
  [NSAppKitVirtualMemoryException cpointer?]
  [NSAppearanceDocumentAttribute cpointer?]
  [NSAppearanceNameAccessibilityHighContrastAqua cpointer?]
  [NSAppearanceNameAccessibilityHighContrastDarkAqua cpointer?]
  [NSAppearanceNameAccessibilityHighContrastVibrantDark cpointer?]
  [NSAppearanceNameAccessibilityHighContrastVibrantLight cpointer?]
  [NSAppearanceNameAqua cpointer?]
  [NSAppearanceNameDarkAqua cpointer?]
  [NSAppearanceNameLightContent cpointer?]
  [NSAppearanceNameVibrantDark cpointer?]
  [NSAppearanceNameVibrantLight cpointer?]
  [NSApplicationDidBecomeActiveNotification cpointer?]
  [NSApplicationDidChangeOcclusionStateNotification cpointer?]
  [NSApplicationDidChangeScreenParametersNotification cpointer?]
  [NSApplicationDidFinishLaunchingNotification cpointer?]
  [NSApplicationDidFinishRestoringWindowsNotification cpointer?]
  [NSApplicationDidHideNotification cpointer?]
  [NSApplicationDidResignActiveNotification cpointer?]
  [NSApplicationDidUnhideNotification cpointer?]
  [NSApplicationDidUpdateNotification cpointer?]
  [NSApplicationFileType cpointer?]
  [NSApplicationLaunchIsDefaultLaunchKey cpointer?]
  [NSApplicationLaunchRemoteNotificationKey cpointer?]
  [NSApplicationLaunchUserNotificationKey cpointer?]
  [NSApplicationProtectedDataDidBecomeAvailableNotification cpointer?]
  [NSApplicationProtectedDataWillBecomeUnavailableNotification cpointer?]
  [NSApplicationShouldBeginSuppressingHighDynamicRangeContentNotification cpointer?]
  [NSApplicationShouldEndSuppressingHighDynamicRangeContentNotification cpointer?]
  [NSApplicationWillBecomeActiveNotification cpointer?]
  [NSApplicationWillFinishLaunchingNotification cpointer?]
  [NSApplicationWillHideNotification cpointer?]
  [NSApplicationWillResignActiveNotification cpointer?]
  [NSApplicationWillTerminateNotification cpointer?]
  [NSApplicationWillUnhideNotification cpointer?]
  [NSApplicationWillUpdateNotification cpointer?]
  [NSArgumentBinding cpointer?]
  [NSAttachmentAttributeName cpointer?]
  [NSAttributedStringBinding cpointer?]
  [NSAuthorDocumentAttribute cpointer?]
  [NSBackgroundColorAttributeName cpointer?]
  [NSBackgroundColorDocumentAttribute cpointer?]
  [NSBackingPropertyOldColorSpaceKey cpointer?]
  [NSBackingPropertyOldScaleFactorKey cpointer?]
  [NSBadBitmapParametersException cpointer?]
  [NSBadComparisonException cpointer?]
  [NSBadRTFColorTableException cpointer?]
  [NSBadRTFDirectiveException cpointer?]
  [NSBadRTFFontTableException cpointer?]
  [NSBadRTFStyleSheetException cpointer?]
  [NSBaseURLDocumentOption cpointer?]
  [NSBaselineOffsetAttributeName cpointer?]
  [NSBlack real?]
  [NSBottomMarginDocumentAttribute cpointer?]
  [NSBrowserColumnConfigurationDidChangeNotification cpointer?]
  [NSBrowserIllegalDelegateException cpointer?]
  [NSCalibratedBlackColorSpace cpointer?]
  [NSCalibratedRGBColorSpace cpointer?]
  [NSCalibratedWhiteColorSpace cpointer?]
  [NSCategoryDocumentAttribute cpointer?]
  [NSCharacterEncodingDocumentAttribute cpointer?]
  [NSCharacterEncodingDocumentOption cpointer?]
  [NSCharacterShapeAttributeName cpointer?]
  [NSCocoaVersionDocumentAttribute cpointer?]
  [NSCollectionElementKindInterItemGapIndicator cpointer?]
  [NSCollectionElementKindSectionFooter cpointer?]
  [NSCollectionElementKindSectionHeader cpointer?]
  [NSColorListDidChangeNotification cpointer?]
  [NSColorListIOException cpointer?]
  [NSColorListNotEditableException cpointer?]
  [NSColorPanelColorDidChangeNotification cpointer?]
  [NSColorPboardType cpointer?]
  [NSComboBoxSelectionDidChangeNotification cpointer?]
  [NSComboBoxSelectionIsChangingNotification cpointer?]
  [NSComboBoxWillDismissNotification cpointer?]
  [NSComboBoxWillPopUpNotification cpointer?]
  [NSCommentDocumentAttribute cpointer?]
  [NSCompanyDocumentAttribute cpointer?]
  [NSConditionallySetsEditableBindingOption cpointer?]
  [NSConditionallySetsEnabledBindingOption cpointer?]
  [NSConditionallySetsHiddenBindingOption cpointer?]
  [NSContentArrayBinding cpointer?]
  [NSContentArrayForMultipleSelectionBinding cpointer?]
  [NSContentBinding cpointer?]
  [NSContentDictionaryBinding cpointer?]
  [NSContentHeightBinding cpointer?]
  [NSContentObjectBinding cpointer?]
  [NSContentObjectsBinding cpointer?]
  [NSContentPlacementTagBindingOption cpointer?]
  [NSContentSetBinding cpointer?]
  [NSContentValuesBinding cpointer?]
  [NSContentWidthBinding cpointer?]
  [NSContextHelpModeDidActivateNotification cpointer?]
  [NSContextHelpModeDidDeactivateNotification cpointer?]
  [NSContinuouslyUpdatesValueBindingOption cpointer?]
  [NSControlTextDidBeginEditingNotification cpointer?]
  [NSControlTextDidChangeNotification cpointer?]
  [NSControlTextDidEndEditingNotification cpointer?]
  [NSControlTintDidChangeNotification cpointer?]
  [NSConvertedDocumentAttribute cpointer?]
  [NSCopyrightDocumentAttribute cpointer?]
  [NSCreatesSortDescriptorBindingOption cpointer?]
  [NSCreationTimeDocumentAttribute cpointer?]
  [NSCriticalValueBinding cpointer?]
  [NSCursorAttributeName cpointer?]
  [NSCustomColorSpace cpointer?]
  [NSDarkGray real?]
  [NSDataBinding cpointer?]
  [NSDefaultAttributesDocumentAttribute cpointer?]
  [NSDefaultAttributesDocumentOption cpointer?]
  [NSDefaultFontExcludedDocumentAttribute cpointer?]
  [NSDefaultTabIntervalDocumentAttribute cpointer?]
  [NSDefinitionPresentationTypeDictionaryApplication cpointer?]
  [NSDefinitionPresentationTypeKey cpointer?]
  [NSDefinitionPresentationTypeOverlay cpointer?]
  [NSDeletesObjectsOnRemoveBindingsOption cpointer?]
  [NSDeviceBitsPerSample cpointer?]
  [NSDeviceBlackColorSpace cpointer?]
  [NSDeviceCMYKColorSpace cpointer?]
  [NSDeviceColorSpaceName cpointer?]
  [NSDeviceIsPrinter cpointer?]
  [NSDeviceIsScreen cpointer?]
  [NSDeviceRGBColorSpace cpointer?]
  [NSDeviceResolution cpointer?]
  [NSDeviceSize cpointer?]
  [NSDeviceWhiteColorSpace cpointer?]
  [NSDirectionalEdgeInsetsZero cpointer?]
  [NSDirectoryFileType cpointer?]
  [NSDisplayNameBindingOption cpointer?]
  [NSDisplayPatternBindingOption cpointer?]
  [NSDisplayPatternTitleBinding cpointer?]
  [NSDisplayPatternValueBinding cpointer?]
  [NSDocFormatTextDocumentType cpointer?]
  [NSDocumentEditedBinding cpointer?]
  [NSDocumentTypeDocumentAttribute cpointer?]
  [NSDocumentTypeDocumentOption cpointer?]
  [NSDoubleClickArgumentBinding cpointer?]
  [NSDoubleClickTargetBinding cpointer?]
  [NSDragPboard cpointer?]
  [NSDraggingException cpointer?]
  [NSDraggingImageComponentIconKey cpointer?]
  [NSDraggingImageComponentLabelKey cpointer?]
  [NSDrawerDidCloseNotification cpointer?]
  [NSDrawerDidOpenNotification cpointer?]
  [NSDrawerWillCloseNotification cpointer?]
  [NSDrawerWillOpenNotification cpointer?]
  [NSEditableBinding cpointer?]
  [NSEditorDocumentAttribute cpointer?]
  [NSEnabledBinding cpointer?]
  [NSEventTrackingRunLoopMode cpointer?]
  [NSExcludedElementsDocumentAttribute cpointer?]
  [NSExcludedKeysBinding cpointer?]
  [NSExpansionAttributeName cpointer?]
  [NSFileContentsPboardType cpointer?]
  [NSFileTypeDocumentAttribute cpointer?]
  [NSFileTypeDocumentOption cpointer?]
  [NSFilenamesPboardType cpointer?]
  [NSFilesPromisePboardType cpointer?]
  [NSFilesystemFileType cpointer?]
  [NSFilterPredicateBinding cpointer?]
  [NSFindPanelCaseInsensitiveSearch cpointer?]
  [NSFindPanelSearchOptionsPboardType cpointer?]
  [NSFindPanelSubstringMatch cpointer?]
  [NSFindPboard cpointer?]
  [NSFontAttributeName cpointer?]
  [NSFontBinding cpointer?]
  [NSFontBoldBinding cpointer?]
  [NSFontCascadeListAttribute cpointer?]
  [NSFontCharacterSetAttribute cpointer?]
  [NSFontCollectionActionKey cpointer?]
  [NSFontCollectionAllFonts cpointer?]
  [NSFontCollectionDidChangeNotification cpointer?]
  [NSFontCollectionDisallowAutoActivationOption cpointer?]
  [NSFontCollectionFavorites cpointer?]
  [NSFontCollectionIncludeDisabledFontsOption cpointer?]
  [NSFontCollectionNameKey cpointer?]
  [NSFontCollectionOldNameKey cpointer?]
  [NSFontCollectionRecentlyUsed cpointer?]
  [NSFontCollectionRemoveDuplicatesOption cpointer?]
  [NSFontCollectionUser cpointer?]
  [NSFontCollectionVisibilityKey cpointer?]
  [NSFontCollectionWasHidden cpointer?]
  [NSFontCollectionWasRenamed cpointer?]
  [NSFontCollectionWasShown cpointer?]
  [NSFontColorAttribute cpointer?]
  [NSFontDescriptorSystemDesignDefault cpointer?]
  [NSFontDescriptorSystemDesignMonospaced cpointer?]
  [NSFontDescriptorSystemDesignRounded cpointer?]
  [NSFontDescriptorSystemDesignSerif cpointer?]
  [NSFontFaceAttribute cpointer?]
  [NSFontFamilyAttribute cpointer?]
  [NSFontFamilyNameBinding cpointer?]
  [NSFontFeatureSelectorIdentifierKey cpointer?]
  [NSFontFeatureSettingsAttribute cpointer?]
  [NSFontFeatureTypeIdentifierKey cpointer?]
  [NSFontFixedAdvanceAttribute cpointer?]
  [NSFontIdentityMatrix (or/c cpointer? #f)]
  [NSFontItalicBinding cpointer?]
  [NSFontMatrixAttribute cpointer?]
  [NSFontNameAttribute cpointer?]
  [NSFontNameBinding cpointer?]
  [NSFontPboard cpointer?]
  [NSFontPboardType cpointer?]
  [NSFontSetChangedNotification cpointer?]
  [NSFontSizeAttribute cpointer?]
  [NSFontSizeBinding cpointer?]
  [NSFontSlantTrait cpointer?]
  [NSFontSymbolicTrait cpointer?]
  [NSFontTextStyleBody cpointer?]
  [NSFontTextStyleCallout cpointer?]
  [NSFontTextStyleCaption1 cpointer?]
  [NSFontTextStyleCaption2 cpointer?]
  [NSFontTextStyleFootnote cpointer?]
  [NSFontTextStyleHeadline cpointer?]
  [NSFontTextStyleLargeTitle cpointer?]
  [NSFontTextStyleSubheadline cpointer?]
  [NSFontTextStyleTitle1 cpointer?]
  [NSFontTextStyleTitle2 cpointer?]
  [NSFontTextStyleTitle3 cpointer?]
  [NSFontTraitsAttribute cpointer?]
  [NSFontUnavailableException cpointer?]
  [NSFontVariationAttribute cpointer?]
  [NSFontVariationAxisDefaultValueKey cpointer?]
  [NSFontVariationAxisIdentifierKey cpointer?]
  [NSFontVariationAxisMaximumValueKey cpointer?]
  [NSFontVariationAxisMinimumValueKey cpointer?]
  [NSFontVariationAxisNameKey cpointer?]
  [NSFontVisibleNameAttribute cpointer?]
  [NSFontWeightBlack real?]
  [NSFontWeightBold real?]
  [NSFontWeightHeavy real?]
  [NSFontWeightLight real?]
  [NSFontWeightMedium real?]
  [NSFontWeightRegular real?]
  [NSFontWeightSemibold real?]
  [NSFontWeightThin real?]
  [NSFontWeightTrait cpointer?]
  [NSFontWeightUltraLight real?]
  [NSFontWidthCompressed real?]
  [NSFontWidthCondensed real?]
  [NSFontWidthExpanded real?]
  [NSFontWidthStandard real?]
  [NSFontWidthTrait cpointer?]
  [NSForegroundColorAttributeName cpointer?]
  [NSFullScreenModeAllScreens cpointer?]
  [NSFullScreenModeApplicationPresentationOptions cpointer?]
  [NSFullScreenModeSetting cpointer?]
  [NSFullScreenModeWindowLevel cpointer?]
  [NSGeneralPboard cpointer?]
  [NSGlyphInfoAttributeName cpointer?]
  [NSGraphicsContextDestinationAttributeName cpointer?]
  [NSGraphicsContextPDFFormat cpointer?]
  [NSGraphicsContextPSFormat cpointer?]
  [NSGraphicsContextRepresentationFormatAttributeName cpointer?]
  [NSGridViewSizeForContent real?]
  [NSHTMLPboardType cpointer?]
  [NSHTMLTextDocumentType cpointer?]
  [NSHandlesContentAsCompoundValueBindingOption cpointer?]
  [NSHeaderTitleBinding cpointer?]
  [NSHiddenBinding cpointer?]
  [NSHyphenationFactorDocumentAttribute cpointer?]
  [NSIllegalSelectorException cpointer?]
  [NSImageBinding cpointer?]
  [NSImageCacheException cpointer?]
  [NSImageColorSyncProfileData cpointer?]
  [NSImageCompressionFactor cpointer?]
  [NSImageCompressionMethod cpointer?]
  [NSImageCurrentFrame cpointer?]
  [NSImageCurrentFrameDuration cpointer?]
  [NSImageDitherTransparency cpointer?]
  [NSImageEXIFData cpointer?]
  [NSImageFallbackBackgroundColor cpointer?]
  [NSImageFrameCount cpointer?]
  [NSImageGamma cpointer?]
  [NSImageHintCTM cpointer?]
  [NSImageHintInterpolation cpointer?]
  [NSImageHintUserInterfaceLayoutDirection cpointer?]
  [NSImageIPTCData cpointer?]
  [NSImageInterlaced cpointer?]
  [NSImageLoopCount cpointer?]
  [NSImageNameActionTemplate cpointer?]
  [NSImageNameAddTemplate cpointer?]
  [NSImageNameAdvanced cpointer?]
  [NSImageNameApplicationIcon cpointer?]
  [NSImageNameBluetoothTemplate cpointer?]
  [NSImageNameBonjour cpointer?]
  [NSImageNameBookmarksTemplate cpointer?]
  [NSImageNameCaution cpointer?]
  [NSImageNameColorPanel cpointer?]
  [NSImageNameColumnViewTemplate cpointer?]
  [NSImageNameComputer cpointer?]
  [NSImageNameDotMac cpointer?]
  [NSImageNameEnterFullScreenTemplate cpointer?]
  [NSImageNameEveryone cpointer?]
  [NSImageNameExitFullScreenTemplate cpointer?]
  [NSImageNameFlowViewTemplate cpointer?]
  [NSImageNameFolder cpointer?]
  [NSImageNameFolderBurnable cpointer?]
  [NSImageNameFolderSmart cpointer?]
  [NSImageNameFollowLinkFreestandingTemplate cpointer?]
  [NSImageNameFontPanel cpointer?]
  [NSImageNameGoBackTemplate cpointer?]
  [NSImageNameGoForwardTemplate cpointer?]
  [NSImageNameGoLeftTemplate cpointer?]
  [NSImageNameGoRightTemplate cpointer?]
  [NSImageNameHomeTemplate cpointer?]
  [NSImageNameIChatTheaterTemplate cpointer?]
  [NSImageNameIconViewTemplate cpointer?]
  [NSImageNameInfo cpointer?]
  [NSImageNameInvalidDataFreestandingTemplate cpointer?]
  [NSImageNameLeftFacingTriangleTemplate cpointer?]
  [NSImageNameListViewTemplate cpointer?]
  [NSImageNameLockLockedTemplate cpointer?]
  [NSImageNameLockUnlockedTemplate cpointer?]
  [NSImageNameMenuMixedStateTemplate cpointer?]
  [NSImageNameMenuOnStateTemplate cpointer?]
  [NSImageNameMobileMe cpointer?]
  [NSImageNameMultipleDocuments cpointer?]
  [NSImageNameNetwork cpointer?]
  [NSImageNamePathTemplate cpointer?]
  [NSImageNamePreferencesGeneral cpointer?]
  [NSImageNameQuickLookTemplate cpointer?]
  [NSImageNameRefreshFreestandingTemplate cpointer?]
  [NSImageNameRefreshTemplate cpointer?]
  [NSImageNameRemoveTemplate cpointer?]
  [NSImageNameRevealFreestandingTemplate cpointer?]
  [NSImageNameRightFacingTriangleTemplate cpointer?]
  [NSImageNameShareTemplate cpointer?]
  [NSImageNameSlideshowTemplate cpointer?]
  [NSImageNameSmartBadgeTemplate cpointer?]
  [NSImageNameStatusAvailable cpointer?]
  [NSImageNameStatusNone cpointer?]
  [NSImageNameStatusPartiallyAvailable cpointer?]
  [NSImageNameStatusUnavailable cpointer?]
  [NSImageNameStopProgressFreestandingTemplate cpointer?]
  [NSImageNameStopProgressTemplate cpointer?]
  [NSImageNameTouchBarAddDetailTemplate cpointer?]
  [NSImageNameTouchBarAddTemplate cpointer?]
  [NSImageNameTouchBarAlarmTemplate cpointer?]
  [NSImageNameTouchBarAudioInputMuteTemplate cpointer?]
  [NSImageNameTouchBarAudioInputTemplate cpointer?]
  [NSImageNameTouchBarAudioOutputMuteTemplate cpointer?]
  [NSImageNameTouchBarAudioOutputVolumeHighTemplate cpointer?]
  [NSImageNameTouchBarAudioOutputVolumeLowTemplate cpointer?]
  [NSImageNameTouchBarAudioOutputVolumeMediumTemplate cpointer?]
  [NSImageNameTouchBarAudioOutputVolumeOffTemplate cpointer?]
  [NSImageNameTouchBarBookmarksTemplate cpointer?]
  [NSImageNameTouchBarColorPickerFill cpointer?]
  [NSImageNameTouchBarColorPickerFont cpointer?]
  [NSImageNameTouchBarColorPickerStroke cpointer?]
  [NSImageNameTouchBarCommunicationAudioTemplate cpointer?]
  [NSImageNameTouchBarCommunicationVideoTemplate cpointer?]
  [NSImageNameTouchBarComposeTemplate cpointer?]
  [NSImageNameTouchBarDeleteTemplate cpointer?]
  [NSImageNameTouchBarDownloadTemplate cpointer?]
  [NSImageNameTouchBarEnterFullScreenTemplate cpointer?]
  [NSImageNameTouchBarExitFullScreenTemplate cpointer?]
  [NSImageNameTouchBarFastForwardTemplate cpointer?]
  [NSImageNameTouchBarFolderCopyToTemplate cpointer?]
  [NSImageNameTouchBarFolderMoveToTemplate cpointer?]
  [NSImageNameTouchBarFolderTemplate cpointer?]
  [NSImageNameTouchBarGetInfoTemplate cpointer?]
  [NSImageNameTouchBarGoBackTemplate cpointer?]
  [NSImageNameTouchBarGoDownTemplate cpointer?]
  [NSImageNameTouchBarGoForwardTemplate cpointer?]
  [NSImageNameTouchBarGoUpTemplate cpointer?]
  [NSImageNameTouchBarHistoryTemplate cpointer?]
  [NSImageNameTouchBarIconViewTemplate cpointer?]
  [NSImageNameTouchBarListViewTemplate cpointer?]
  [NSImageNameTouchBarMailTemplate cpointer?]
  [NSImageNameTouchBarNewFolderTemplate cpointer?]
  [NSImageNameTouchBarNewMessageTemplate cpointer?]
  [NSImageNameTouchBarOpenInBrowserTemplate cpointer?]
  [NSImageNameTouchBarPauseTemplate cpointer?]
  [NSImageNameTouchBarPlayPauseTemplate cpointer?]
  [NSImageNameTouchBarPlayTemplate cpointer?]
  [NSImageNameTouchBarPlayheadTemplate cpointer?]
  [NSImageNameTouchBarQuickLookTemplate cpointer?]
  [NSImageNameTouchBarRecordStartTemplate cpointer?]
  [NSImageNameTouchBarRecordStopTemplate cpointer?]
  [NSImageNameTouchBarRefreshTemplate cpointer?]
  [NSImageNameTouchBarRemoveTemplate cpointer?]
  [NSImageNameTouchBarRewindTemplate cpointer?]
  [NSImageNameTouchBarRotateLeftTemplate cpointer?]
  [NSImageNameTouchBarRotateRightTemplate cpointer?]
  [NSImageNameTouchBarSearchTemplate cpointer?]
  [NSImageNameTouchBarShareTemplate cpointer?]
  [NSImageNameTouchBarSidebarTemplate cpointer?]
  [NSImageNameTouchBarSkipAhead15SecondsTemplate cpointer?]
  [NSImageNameTouchBarSkipAhead30SecondsTemplate cpointer?]
  [NSImageNameTouchBarSkipAheadTemplate cpointer?]
  [NSImageNameTouchBarSkipBack15SecondsTemplate cpointer?]
  [NSImageNameTouchBarSkipBack30SecondsTemplate cpointer?]
  [NSImageNameTouchBarSkipBackTemplate cpointer?]
  [NSImageNameTouchBarSkipToEndTemplate cpointer?]
  [NSImageNameTouchBarSkipToStartTemplate cpointer?]
  [NSImageNameTouchBarSlideshowTemplate cpointer?]
  [NSImageNameTouchBarTagIconTemplate cpointer?]
  [NSImageNameTouchBarTextBoldTemplate cpointer?]
  [NSImageNameTouchBarTextBoxTemplate cpointer?]
  [NSImageNameTouchBarTextCenterAlignTemplate cpointer?]
  [NSImageNameTouchBarTextItalicTemplate cpointer?]
  [NSImageNameTouchBarTextJustifiedAlignTemplate cpointer?]
  [NSImageNameTouchBarTextLeftAlignTemplate cpointer?]
  [NSImageNameTouchBarTextListTemplate cpointer?]
  [NSImageNameTouchBarTextRightAlignTemplate cpointer?]
  [NSImageNameTouchBarTextStrikethroughTemplate cpointer?]
  [NSImageNameTouchBarTextUnderlineTemplate cpointer?]
  [NSImageNameTouchBarUserAddTemplate cpointer?]
  [NSImageNameTouchBarUserGroupTemplate cpointer?]
  [NSImageNameTouchBarUserTemplate cpointer?]
  [NSImageNameTouchBarVolumeDownTemplate cpointer?]
  [NSImageNameTouchBarVolumeUpTemplate cpointer?]
  [NSImageNameTrashEmpty cpointer?]
  [NSImageNameTrashFull cpointer?]
  [NSImageNameUser cpointer?]
  [NSImageNameUserAccounts cpointer?]
  [NSImageNameUserGroup cpointer?]
  [NSImageNameUserGuest cpointer?]
  [NSImageProgressive cpointer?]
  [NSImageRGBColorTable cpointer?]
  [NSImageRepRegistryDidChangeNotification cpointer?]
  [NSIncludedKeysBinding cpointer?]
  [NSInitialKeyBinding cpointer?]
  [NSInitialValueBinding cpointer?]
  [NSInkTextPboardType cpointer?]
  [NSInsertsNullPlaceholderBindingOption cpointer?]
  [NSInterfaceStyleDefault cpointer?]
  [NSInvokesSeparatelyWithArrayObjectsBindingOption cpointer?]
  [NSIsIndeterminateBinding cpointer?]
  [NSKernAttributeName cpointer?]
  [NSKeywordsDocumentAttribute cpointer?]
  [NSLabelBinding cpointer?]
  [NSLeftMarginDocumentAttribute cpointer?]
  [NSLigatureAttributeName cpointer?]
  [NSLightGray real?]
  [NSLinkAttributeName cpointer?]
  [NSLocalizedKeyDictionaryBinding cpointer?]
  [NSMacSimpleTextDocumentType cpointer?]
  [NSManagedObjectContextBinding cpointer?]
  [NSManagerDocumentAttribute cpointer?]
  [NSMarkedClauseSegmentAttributeName cpointer?]
  [NSMaxValueBinding cpointer?]
  [NSMaxWidthBinding cpointer?]
  [NSMaximumRecentsBinding cpointer?]
  [NSMenuDidAddItemNotification cpointer?]
  [NSMenuDidBeginTrackingNotification cpointer?]
  [NSMenuDidChangeItemNotification cpointer?]
  [NSMenuDidEndTrackingNotification cpointer?]
  [NSMenuDidRemoveItemNotification cpointer?]
  [NSMenuDidSendActionNotification cpointer?]
  [NSMenuItemImportFromDeviceIdentifier cpointer?]
  [NSMenuWillSendActionNotification cpointer?]
  [NSMinValueBinding cpointer?]
  [NSMinWidthBinding cpointer?]
  [NSMixedStateImageBinding cpointer?]
  [NSModalPanelRunLoopMode cpointer?]
  [NSModificationTimeDocumentAttribute cpointer?]
  [NSMultipleTextSelectionPboardType cpointer?]
  [NSMultipleValuesMarker cpointer?]
  [NSMultipleValuesPlaceholderBindingOption cpointer?]
  [NSNamedColorSpace cpointer?]
  [NSNibLoadingException cpointer?]
  [NSNibOwner cpointer?]
  [NSNibTopLevelObjects cpointer?]
  [NSNoSelectionMarker cpointer?]
  [NSNoSelectionPlaceholderBindingOption cpointer?]
  [NSNotApplicableMarker cpointer?]
  [NSNotApplicablePlaceholderBindingOption cpointer?]
  [NSNullPlaceholderBindingOption cpointer?]
  [NSObliquenessAttributeName cpointer?]
  [NSObservedKeyPathKey cpointer?]
  [NSObservedObjectKey cpointer?]
  [NSOffStateImageBinding cpointer?]
  [NSOfficeOpenXMLTextDocumentType cpointer?]
  [NSOnStateImageBinding cpointer?]
  [NSOpenDocumentTextDocumentType cpointer?]
  [NSOptionsKey cpointer?]
  [NSOutlineViewColumnDidMoveNotification cpointer?]
  [NSOutlineViewColumnDidResizeNotification cpointer?]
  [NSOutlineViewDisclosureButtonKey cpointer?]
  [NSOutlineViewItemDidCollapseNotification cpointer?]
  [NSOutlineViewItemDidExpandNotification cpointer?]
  [NSOutlineViewItemWillCollapseNotification cpointer?]
  [NSOutlineViewItemWillExpandNotification cpointer?]
  [NSOutlineViewSelectionDidChangeNotification cpointer?]
  [NSOutlineViewSelectionIsChangingNotification cpointer?]
  [NSOutlineViewShowHideButtonKey cpointer?]
  [NSPDFPboardType cpointer?]
  [NSPICTPboardType cpointer?]
  [NSPPDIncludeNotFoundException cpointer?]
  [NSPPDIncludeStackOverflowException cpointer?]
  [NSPPDIncludeStackUnderflowException cpointer?]
  [NSPPDParseException cpointer?]
  [NSPaperSizeDocumentAttribute cpointer?]
  [NSParagraphStyleAttributeName cpointer?]
  [NSPasteboardCommunicationException cpointer?]
  [NSPasteboardDetectionPatternCalendarEvent cpointer?]
  [NSPasteboardDetectionPatternEmailAddress cpointer?]
  [NSPasteboardDetectionPatternFlightNumber cpointer?]
  [NSPasteboardDetectionPatternLink cpointer?]
  [NSPasteboardDetectionPatternMoneyAmount cpointer?]
  [NSPasteboardDetectionPatternNumber cpointer?]
  [NSPasteboardDetectionPatternPhoneNumber cpointer?]
  [NSPasteboardDetectionPatternPostalAddress cpointer?]
  [NSPasteboardDetectionPatternProbableWebSearch cpointer?]
  [NSPasteboardDetectionPatternProbableWebURL cpointer?]
  [NSPasteboardDetectionPatternShipmentTrackingNumber cpointer?]
  [NSPasteboardMetadataTypeContentType cpointer?]
  [NSPasteboardNameDrag cpointer?]
  [NSPasteboardNameFind cpointer?]
  [NSPasteboardNameFont cpointer?]
  [NSPasteboardNameGeneral cpointer?]
  [NSPasteboardNameRuler cpointer?]
  [NSPasteboardTypeColor cpointer?]
  [NSPasteboardTypeFileURL cpointer?]
  [NSPasteboardTypeFindPanelSearchOptions cpointer?]
  [NSPasteboardTypeFont cpointer?]
  [NSPasteboardTypeHTML cpointer?]
  [NSPasteboardTypeMultipleTextSelection cpointer?]
  [NSPasteboardTypePDF cpointer?]
  [NSPasteboardTypePNG cpointer?]
  [NSPasteboardTypeRTF cpointer?]
  [NSPasteboardTypeRTFD cpointer?]
  [NSPasteboardTypeRuler cpointer?]
  [NSPasteboardTypeSound cpointer?]
  [NSPasteboardTypeString cpointer?]
  [NSPasteboardTypeTIFF cpointer?]
  [NSPasteboardTypeTabularText cpointer?]
  [NSPasteboardTypeTextFinderOptions cpointer?]
  [NSPasteboardTypeURL cpointer?]
  [NSPasteboardURLReadingContentsConformToTypesKey cpointer?]
  [NSPasteboardURLReadingFileURLsOnlyKey cpointer?]
  [NSPatternColorSpace cpointer?]
  [NSPlainFileType cpointer?]
  [NSPlainTextDocumentType cpointer?]
  [NSPopUpButtonCellWillPopUpNotification cpointer?]
  [NSPopUpButtonWillPopUpNotification cpointer?]
  [NSPopoverCloseReasonDetachToWindow cpointer?]
  [NSPopoverCloseReasonKey cpointer?]
  [NSPopoverCloseReasonStandard cpointer?]
  [NSPopoverDidCloseNotification cpointer?]
  [NSPopoverDidShowNotification cpointer?]
  [NSPopoverWillCloseNotification cpointer?]
  [NSPopoverWillShowNotification cpointer?]
  [NSPositioningRectBinding cpointer?]
  [NSPostScriptPboardType cpointer?]
  [NSPredicateBinding cpointer?]
  [NSPredicateFormatBindingOption cpointer?]
  [NSPreferredScrollerStyleDidChangeNotification cpointer?]
  [NSPrefixSpacesDocumentAttribute cpointer?]
  [NSPrintAllPages cpointer?]
  [NSPrintAllPresetsJobStyleHint cpointer?]
  [NSPrintBottomMargin cpointer?]
  [NSPrintCancelJob cpointer?]
  [NSPrintCopies cpointer?]
  [NSPrintDetailedErrorReporting cpointer?]
  [NSPrintFaxNumber cpointer?]
  [NSPrintFirstPage cpointer?]
  [NSPrintFormName cpointer?]
  [NSPrintHeaderAndFooter cpointer?]
  [NSPrintHorizontalPagination cpointer?]
  [NSPrintHorizontallyCentered cpointer?]
  [NSPrintJobDisposition cpointer?]
  [NSPrintJobFeatures cpointer?]
  [NSPrintJobSavingFileNameExtensionHidden cpointer?]
  [NSPrintJobSavingURL cpointer?]
  [NSPrintLastPage cpointer?]
  [NSPrintLeftMargin cpointer?]
  [NSPrintManualFeed cpointer?]
  [NSPrintMustCollate cpointer?]
  [NSPrintNoPresetsJobStyleHint cpointer?]
  [NSPrintOperationExistsException cpointer?]
  [NSPrintOrientation cpointer?]
  [NSPrintPackageException cpointer?]
  [NSPrintPagesAcross cpointer?]
  [NSPrintPagesDown cpointer?]
  [NSPrintPagesPerSheet cpointer?]
  [NSPrintPanelAccessorySummaryItemDescriptionKey cpointer?]
  [NSPrintPanelAccessorySummaryItemNameKey cpointer?]
  [NSPrintPaperFeed cpointer?]
  [NSPrintPaperName cpointer?]
  [NSPrintPaperSize cpointer?]
  [NSPrintPhotoJobStyleHint cpointer?]
  [NSPrintPreviewJob cpointer?]
  [NSPrintPrinter cpointer?]
  [NSPrintPrinterName cpointer?]
  [NSPrintReversePageOrder cpointer?]
  [NSPrintRightMargin cpointer?]
  [NSPrintSaveJob cpointer?]
  [NSPrintSavePath cpointer?]
  [NSPrintScalingFactor cpointer?]
  [NSPrintSelectionOnly cpointer?]
  [NSPrintSpoolJob cpointer?]
  [NSPrintTime cpointer?]
  [NSPrintTopMargin cpointer?]
  [NSPrintVerticalPagination cpointer?]
  [NSPrintVerticallyCentered cpointer?]
  [NSPrintingCommunicationException cpointer?]
  [NSRTFDPboardType cpointer?]
  [NSRTFDTextDocumentType cpointer?]
  [NSRTFPboardType cpointer?]
  [NSRTFPropertyStackOverflowException cpointer?]
  [NSRTFTextDocumentType cpointer?]
  [NSRaisesForNotApplicableKeysBindingOption cpointer?]
  [NSReadOnlyDocumentAttribute cpointer?]
  [NSRecentSearchesBinding cpointer?]
  [NSRepresentedFilenameBinding cpointer?]
  [NSRightMarginDocumentAttribute cpointer?]
  [NSRowHeightBinding cpointer?]
  [NSRuleEditorPredicateComparisonModifier cpointer?]
  [NSRuleEditorPredicateCompoundType cpointer?]
  [NSRuleEditorPredicateCustomSelector cpointer?]
  [NSRuleEditorPredicateLeftExpression cpointer?]
  [NSRuleEditorPredicateOperatorType cpointer?]
  [NSRuleEditorPredicateOptions cpointer?]
  [NSRuleEditorPredicateRightExpression cpointer?]
  [NSRuleEditorRowsDidChangeNotification cpointer?]
  [NSRulerPboard cpointer?]
  [NSRulerPboardType cpointer?]
  [NSRulerViewUnitCentimeters cpointer?]
  [NSRulerViewUnitInches cpointer?]
  [NSRulerViewUnitPicas cpointer?]
  [NSRulerViewUnitPoints cpointer?]
  [NSScreenColorSpaceDidChangeNotification cpointer?]
  [NSScrollViewDidEndLiveMagnifyNotification cpointer?]
  [NSScrollViewDidEndLiveScrollNotification cpointer?]
  [NSScrollViewDidLiveScrollNotification cpointer?]
  [NSScrollViewWillStartLiveMagnifyNotification cpointer?]
  [NSScrollViewWillStartLiveScrollNotification cpointer?]
  [NSSelectedIdentifierBinding cpointer?]
  [NSSelectedIndexBinding cpointer?]
  [NSSelectedLabelBinding cpointer?]
  [NSSelectedObjectBinding cpointer?]
  [NSSelectedObjectsBinding cpointer?]
  [NSSelectedTagBinding cpointer?]
  [NSSelectedValueBinding cpointer?]
  [NSSelectedValuesBinding cpointer?]
  [NSSelectionIndexPathsBinding cpointer?]
  [NSSelectionIndexesBinding cpointer?]
  [NSSelectorNameBindingOption cpointer?]
  [NSSelectsAllWhenSettingContentBindingOption cpointer?]
  [NSShadowAttributeName cpointer?]
  [NSSharingServiceNameAddToAperture cpointer?]
  [NSSharingServiceNameAddToIPhoto cpointer?]
  [NSSharingServiceNameAddToSafariReadingList cpointer?]
  [NSSharingServiceNameCloudSharing cpointer?]
  [NSSharingServiceNameComposeEmail cpointer?]
  [NSSharingServiceNameComposeMessage cpointer?]
  [NSSharingServiceNamePostImageOnFlickr cpointer?]
  [NSSharingServiceNamePostOnFacebook cpointer?]
  [NSSharingServiceNamePostOnLinkedIn cpointer?]
  [NSSharingServiceNamePostOnSinaWeibo cpointer?]
  [NSSharingServiceNamePostOnTencentWeibo cpointer?]
  [NSSharingServiceNamePostOnTwitter cpointer?]
  [NSSharingServiceNamePostVideoOnTudou cpointer?]
  [NSSharingServiceNamePostVideoOnVimeo cpointer?]
  [NSSharingServiceNamePostVideoOnYouku cpointer?]
  [NSSharingServiceNameSendViaAirDrop cpointer?]
  [NSSharingServiceNameUseAsDesktopPicture cpointer?]
  [NSSharingServiceNameUseAsFacebookProfileImage cpointer?]
  [NSSharingServiceNameUseAsLinkedInProfileImage cpointer?]
  [NSSharingServiceNameUseAsTwitterProfileImage cpointer?]
  [NSShellCommandFileType cpointer?]
  [NSSliderAccessoryWidthDefault real?]
  [NSSliderAccessoryWidthWide real?]
  [NSSortDescriptorsBinding cpointer?]
  [NSSoundPboardType cpointer?]
  [NSSourceTextScalingDocumentAttribute cpointer?]
  [NSSourceTextScalingDocumentOption cpointer?]
  [NSSpeechCharacterModeProperty cpointer?]
  [NSSpeechCommandDelimiterProperty cpointer?]
  [NSSpeechCommandPrefix cpointer?]
  [NSSpeechCommandSuffix cpointer?]
  [NSSpeechCurrentVoiceProperty cpointer?]
  [NSSpeechDictionaryAbbreviations cpointer?]
  [NSSpeechDictionaryEntryPhonemes cpointer?]
  [NSSpeechDictionaryEntrySpelling cpointer?]
  [NSSpeechDictionaryLocaleIdentifier cpointer?]
  [NSSpeechDictionaryModificationDate cpointer?]
  [NSSpeechDictionaryPronunciations cpointer?]
  [NSSpeechErrorCount cpointer?]
  [NSSpeechErrorNewestCharacterOffset cpointer?]
  [NSSpeechErrorNewestCode cpointer?]
  [NSSpeechErrorOldestCharacterOffset cpointer?]
  [NSSpeechErrorOldestCode cpointer?]
  [NSSpeechErrorsProperty cpointer?]
  [NSSpeechInputModeProperty cpointer?]
  [NSSpeechModeLiteral cpointer?]
  [NSSpeechModeNormal cpointer?]
  [NSSpeechModePhoneme cpointer?]
  [NSSpeechModeText cpointer?]
  [NSSpeechNumberModeProperty cpointer?]
  [NSSpeechOutputToFileURLProperty cpointer?]
  [NSSpeechPhonemeInfoExample cpointer?]
  [NSSpeechPhonemeInfoHiliteEnd cpointer?]
  [NSSpeechPhonemeInfoHiliteStart cpointer?]
  [NSSpeechPhonemeInfoOpcode cpointer?]
  [NSSpeechPhonemeInfoSymbol cpointer?]
  [NSSpeechPhonemeSymbolsProperty cpointer?]
  [NSSpeechPitchBaseProperty cpointer?]
  [NSSpeechPitchModProperty cpointer?]
  [NSSpeechRateProperty cpointer?]
  [NSSpeechRecentSyncProperty cpointer?]
  [NSSpeechResetProperty cpointer?]
  [NSSpeechStatusNumberOfCharactersLeft cpointer?]
  [NSSpeechStatusOutputBusy cpointer?]
  [NSSpeechStatusOutputPaused cpointer?]
  [NSSpeechStatusPhonemeCode cpointer?]
  [NSSpeechStatusProperty cpointer?]
  [NSSpeechSynthesizerInfoIdentifier cpointer?]
  [NSSpeechSynthesizerInfoProperty cpointer?]
  [NSSpeechSynthesizerInfoVersion cpointer?]
  [NSSpeechVolumeProperty cpointer?]
  [NSSpellCheckerDidChangeAutomaticCapitalizationNotification cpointer?]
  [NSSpellCheckerDidChangeAutomaticDashSubstitutionNotification cpointer?]
  [NSSpellCheckerDidChangeAutomaticInlinePredictionNotification cpointer?]
  [NSSpellCheckerDidChangeAutomaticPeriodSubstitutionNotification cpointer?]
  [NSSpellCheckerDidChangeAutomaticQuoteSubstitutionNotification cpointer?]
  [NSSpellCheckerDidChangeAutomaticSpellingCorrectionNotification cpointer?]
  [NSSpellCheckerDidChangeAutomaticTextCompletionNotification cpointer?]
  [NSSpellCheckerDidChangeAutomaticTextReplacementNotification cpointer?]
  [NSSpellingStateAttributeName cpointer?]
  [NSSplitViewControllerAutomaticDimension real?]
  [NSSplitViewDidResizeSubviewsNotification cpointer?]
  [NSSplitViewItemUnspecifiedDimension real?]
  [NSSplitViewWillResizeSubviewsNotification cpointer?]
  [NSStrikethroughColorAttributeName cpointer?]
  [NSStrikethroughStyleAttributeName cpointer?]
  [NSStringPboardType cpointer?]
  [NSStrokeColorAttributeName cpointer?]
  [NSStrokeWidthAttributeName cpointer?]
  [NSSubjectDocumentAttribute cpointer?]
  [NSSuperscriptAttributeName cpointer?]
  [NSSystemColorsDidChangeNotification cpointer?]
  [NSTIFFException cpointer?]
  [NSTIFFPboardType cpointer?]
  [NSTabColumnTerminatorsAttributeName cpointer?]
  [NSTableViewColumnDidMoveNotification cpointer?]
  [NSTableViewColumnDidResizeNotification cpointer?]
  [NSTableViewRowViewKey cpointer?]
  [NSTableViewSelectionDidChangeNotification cpointer?]
  [NSTableViewSelectionIsChangingNotification cpointer?]
  [NSTabularTextPboardType cpointer?]
  [NSTargetBinding cpointer?]
  [NSTargetTextScalingDocumentOption cpointer?]
  [NSTextAlternativesAttributeName cpointer?]
  [NSTextAlternativesSelectedAlternativeStringNotification cpointer?]
  [NSTextCheckingDocumentAuthorKey cpointer?]
  [NSTextCheckingDocumentTitleKey cpointer?]
  [NSTextCheckingDocumentURLKey cpointer?]
  [NSTextCheckingGenerateInlinePredictionsKey cpointer?]
  [NSTextCheckingOrthographyKey cpointer?]
  [NSTextCheckingQuotesKey cpointer?]
  [NSTextCheckingReferenceDateKey cpointer?]
  [NSTextCheckingReferenceTimeZoneKey cpointer?]
  [NSTextCheckingRegularExpressionsKey cpointer?]
  [NSTextCheckingReplacementsKey cpointer?]
  [NSTextCheckingSelectedRangeKey cpointer?]
  [NSTextColorBinding cpointer?]
  [NSTextContentStorageUnsupportedAttributeAddedNotification cpointer?]
  [NSTextContentTypeAddressCity cpointer?]
  [NSTextContentTypeAddressCityAndState cpointer?]
  [NSTextContentTypeAddressState cpointer?]
  [NSTextContentTypeBirthdate cpointer?]
  [NSTextContentTypeBirthdateDay cpointer?]
  [NSTextContentTypeBirthdateMonth cpointer?]
  [NSTextContentTypeBirthdateYear cpointer?]
  [NSTextContentTypeCountryName cpointer?]
  [NSTextContentTypeCreditCardExpiration cpointer?]
  [NSTextContentTypeCreditCardExpirationMonth cpointer?]
  [NSTextContentTypeCreditCardExpirationYear cpointer?]
  [NSTextContentTypeCreditCardFamilyName cpointer?]
  [NSTextContentTypeCreditCardGivenName cpointer?]
  [NSTextContentTypeCreditCardMiddleName cpointer?]
  [NSTextContentTypeCreditCardName cpointer?]
  [NSTextContentTypeCreditCardNumber cpointer?]
  [NSTextContentTypeCreditCardSecurityCode cpointer?]
  [NSTextContentTypeCreditCardType cpointer?]
  [NSTextContentTypeDateTime cpointer?]
  [NSTextContentTypeEmailAddress cpointer?]
  [NSTextContentTypeFamilyName cpointer?]
  [NSTextContentTypeFlightNumber cpointer?]
  [NSTextContentTypeFullStreetAddress cpointer?]
  [NSTextContentTypeGivenName cpointer?]
  [NSTextContentTypeJobTitle cpointer?]
  [NSTextContentTypeLocation cpointer?]
  [NSTextContentTypeMiddleName cpointer?]
  [NSTextContentTypeName cpointer?]
  [NSTextContentTypeNamePrefix cpointer?]
  [NSTextContentTypeNameSuffix cpointer?]
  [NSTextContentTypeNewPassword cpointer?]
  [NSTextContentTypeNickname cpointer?]
  [NSTextContentTypeOneTimeCode cpointer?]
  [NSTextContentTypeOrganizationName cpointer?]
  [NSTextContentTypePassword cpointer?]
  [NSTextContentTypePostalCode cpointer?]
  [NSTextContentTypeShipmentTrackingNumber cpointer?]
  [NSTextContentTypeStreetAddressLine1 cpointer?]
  [NSTextContentTypeStreetAddressLine2 cpointer?]
  [NSTextContentTypeSublocality cpointer?]
  [NSTextContentTypeTelephoneNumber cpointer?]
  [NSTextContentTypeURL cpointer?]
  [NSTextContentTypeUsername cpointer?]
  [NSTextDidBeginEditingNotification cpointer?]
  [NSTextDidChangeNotification cpointer?]
  [NSTextDidEndEditingNotification cpointer?]
  [NSTextEffectAttributeName cpointer?]
  [NSTextEffectLetterpressStyle cpointer?]
  [NSTextEncodingNameDocumentAttribute cpointer?]
  [NSTextEncodingNameDocumentOption cpointer?]
  [NSTextFinderCaseInsensitiveKey cpointer?]
  [NSTextFinderMatchingTypeKey cpointer?]
  [NSTextHighlightColorSchemeAttributeName cpointer?]
  [NSTextHighlightColorSchemeBlue cpointer?]
  [NSTextHighlightColorSchemeDefault cpointer?]
  [NSTextHighlightColorSchemeMint cpointer?]
  [NSTextHighlightColorSchemeOrange cpointer?]
  [NSTextHighlightColorSchemePink cpointer?]
  [NSTextHighlightColorSchemePurple cpointer?]
  [NSTextHighlightStyleAttributeName cpointer?]
  [NSTextHighlightStyleDefault cpointer?]
  [NSTextInputContextKeyboardSelectionDidChangeNotification cpointer?]
  [NSTextKit1ListMarkerFormatDocumentOption cpointer?]
  [NSTextLayoutSectionOrientation cpointer?]
  [NSTextLayoutSectionRange cpointer?]
  [NSTextLayoutSectionsAttribute cpointer?]
  [NSTextLineTooLongException cpointer?]
  [NSTextListMarkerBox cpointer?]
  [NSTextListMarkerCheck cpointer?]
  [NSTextListMarkerCircle cpointer?]
  [NSTextListMarkerDecimal cpointer?]
  [NSTextListMarkerDiamond cpointer?]
  [NSTextListMarkerDisc cpointer?]
  [NSTextListMarkerHyphen cpointer?]
  [NSTextListMarkerLowercaseAlpha cpointer?]
  [NSTextListMarkerLowercaseHexadecimal cpointer?]
  [NSTextListMarkerLowercaseLatin cpointer?]
  [NSTextListMarkerLowercaseRoman cpointer?]
  [NSTextListMarkerOctal cpointer?]
  [NSTextListMarkerSquare cpointer?]
  [NSTextListMarkerUppercaseAlpha cpointer?]
  [NSTextListMarkerUppercaseHexadecimal cpointer?]
  [NSTextListMarkerUppercaseLatin cpointer?]
  [NSTextListMarkerUppercaseRoman cpointer?]
  [NSTextMovementUserInfoKey cpointer?]
  [NSTextNoSelectionException cpointer?]
  [NSTextReadException cpointer?]
  [NSTextScalingDocumentAttribute cpointer?]
  [NSTextSizeMultiplierDocumentOption cpointer?]
  [NSTextStorageDidProcessEditingNotification cpointer?]
  [NSTextStorageWillProcessEditingNotification cpointer?]
  [NSTextViewDidChangeSelectionNotification cpointer?]
  [NSTextViewDidChangeTypingAttributesNotification cpointer?]
  [NSTextViewDidSwitchToNSLayoutManagerNotification cpointer?]
  [NSTextViewWillChangeNotifyingTextViewNotification cpointer?]
  [NSTextViewWillSwitchToNSLayoutManagerNotification cpointer?]
  [NSTextWriteException cpointer?]
  [NSTimeoutDocumentOption cpointer?]
  [NSTitleBinding cpointer?]
  [NSTitleDocumentAttribute cpointer?]
  [NSToolTipAttributeName cpointer?]
  [NSToolTipBinding cpointer?]
  [NSToolbarCloudSharingItemIdentifier cpointer?]
  [NSToolbarCustomizeToolbarItemIdentifier cpointer?]
  [NSToolbarDidRemoveItemNotification cpointer?]
  [NSToolbarFlexibleSpaceItemIdentifier cpointer?]
  [NSToolbarInspectorTrackingSeparatorItemIdentifier cpointer?]
  [NSToolbarItemKey cpointer?]
  [NSToolbarNewIndexKey cpointer?]
  [NSToolbarPrintItemIdentifier cpointer?]
  [NSToolbarSeparatorItemIdentifier cpointer?]
  [NSToolbarShowColorsItemIdentifier cpointer?]
  [NSToolbarShowFontsItemIdentifier cpointer?]
  [NSToolbarSidebarTrackingSeparatorItemIdentifier cpointer?]
  [NSToolbarSpaceItemIdentifier cpointer?]
  [NSToolbarToggleInspectorItemIdentifier cpointer?]
  [NSToolbarToggleSidebarItemIdentifier cpointer?]
  [NSToolbarWillAddItemNotification cpointer?]
  [NSToolbarWritingToolsItemIdentifier cpointer?]
  [NSTopMarginDocumentAttribute cpointer?]
  [NSTouchBarItemIdentifierCandidateList cpointer?]
  [NSTouchBarItemIdentifierCharacterPicker cpointer?]
  [NSTouchBarItemIdentifierFixedSpaceLarge cpointer?]
  [NSTouchBarItemIdentifierFixedSpaceSmall cpointer?]
  [NSTouchBarItemIdentifierFlexibleSpace cpointer?]
  [NSTouchBarItemIdentifierOtherItemsProxy cpointer?]
  [NSTouchBarItemIdentifierTextAlignment cpointer?]
  [NSTouchBarItemIdentifierTextColorPicker cpointer?]
  [NSTouchBarItemIdentifierTextFormat cpointer?]
  [NSTouchBarItemIdentifierTextList cpointer?]
  [NSTouchBarItemIdentifierTextStyle cpointer?]
  [NSTrackingAttributeName cpointer?]
  [NSTransparentBinding cpointer?]
  [NSTypeIdentifierAddressText cpointer?]
  [NSTypeIdentifierDateText cpointer?]
  [NSTypeIdentifierPhoneNumberText cpointer?]
  [NSTypeIdentifierTransitInformationText cpointer?]
  [NSTypedStreamVersionException cpointer?]
  [NSURLPboardType cpointer?]
  [NSUnderlineByWordMask exact-nonnegative-integer?]
  [NSUnderlineColorAttributeName cpointer?]
  [NSUnderlineStrikethroughMask exact-nonnegative-integer?]
  [NSUnderlineStyleAttributeName cpointer?]
  [NSUserActivityDocumentURLKey cpointer?]
  [NSUsesScreenFontsDocumentAttribute cpointer?]
  [NSVCardPboardType cpointer?]
  [NSValidatesImmediatelyBindingOption cpointer?]
  [NSValueBinding cpointer?]
  [NSValuePathBinding cpointer?]
  [NSValueTransformerBindingOption cpointer?]
  [NSValueTransformerNameBindingOption cpointer?]
  [NSValueURLBinding cpointer?]
  [NSVerticalGlyphFormAttributeName cpointer?]
  [NSViewAnimationEffectKey cpointer?]
  [NSViewAnimationEndFrameKey cpointer?]
  [NSViewAnimationFadeInEffect cpointer?]
  [NSViewAnimationFadeOutEffect cpointer?]
  [NSViewAnimationStartFrameKey cpointer?]
  [NSViewAnimationTargetKey cpointer?]
  [NSViewBoundsDidChangeNotification cpointer?]
  [NSViewDidUpdateTrackingAreasNotification cpointer?]
  [NSViewFocusDidChangeNotification cpointer?]
  [NSViewFrameDidChangeNotification cpointer?]
  [NSViewGlobalFrameDidChangeNotification cpointer?]
  [NSViewModeDocumentAttribute cpointer?]
  [NSViewNoInstrinsicMetric real?]
  [NSViewNoIntrinsicMetric real?]
  [NSViewSizeDocumentAttribute cpointer?]
  [NSViewZoomDocumentAttribute cpointer?]
  [NSVisibleBinding cpointer?]
  [NSVoiceAge cpointer?]
  [NSVoiceDemoText cpointer?]
  [NSVoiceGender cpointer?]
  [NSVoiceGenderFemale cpointer?]
  [NSVoiceGenderMale cpointer?]
  [NSVoiceGenderNeuter cpointer?]
  [NSVoiceGenderNeutral cpointer?]
  [NSVoiceIdentifier cpointer?]
  [NSVoiceIndividuallySpokenCharacters cpointer?]
  [NSVoiceLanguage cpointer?]
  [NSVoiceLocaleIdentifier cpointer?]
  [NSVoiceName cpointer?]
  [NSVoiceSupportedCharacters cpointer?]
  [NSWarningValueBinding cpointer?]
  [NSWebArchiveTextDocumentType cpointer?]
  [NSWebPreferencesDocumentOption cpointer?]
  [NSWebResourceLoadDelegateDocumentOption cpointer?]
  [NSWhite real?]
  [NSWidthBinding cpointer?]
  [NSWindowDidBecomeKeyNotification cpointer?]
  [NSWindowDidBecomeMainNotification cpointer?]
  [NSWindowDidChangeBackingPropertiesNotification cpointer?]
  [NSWindowDidChangeOcclusionStateNotification cpointer?]
  [NSWindowDidChangeScreenNotification cpointer?]
  [NSWindowDidChangeScreenProfileNotification cpointer?]
  [NSWindowDidDeminiaturizeNotification cpointer?]
  [NSWindowDidEndLiveResizeNotification cpointer?]
  [NSWindowDidEndSheetNotification cpointer?]
  [NSWindowDidEnterFullScreenNotification cpointer?]
  [NSWindowDidEnterVersionBrowserNotification cpointer?]
  [NSWindowDidExitFullScreenNotification cpointer?]
  [NSWindowDidExitVersionBrowserNotification cpointer?]
  [NSWindowDidExposeNotification cpointer?]
  [NSWindowDidMiniaturizeNotification cpointer?]
  [NSWindowDidMoveNotification cpointer?]
  [NSWindowDidResignKeyNotification cpointer?]
  [NSWindowDidResignMainNotification cpointer?]
  [NSWindowDidResizeNotification cpointer?]
  [NSWindowDidUpdateNotification cpointer?]
  [NSWindowServerCommunicationException cpointer?]
  [NSWindowWillBeginSheetNotification cpointer?]
  [NSWindowWillCloseNotification cpointer?]
  [NSWindowWillEnterFullScreenNotification cpointer?]
  [NSWindowWillEnterVersionBrowserNotification cpointer?]
  [NSWindowWillExitFullScreenNotification cpointer?]
  [NSWindowWillExitVersionBrowserNotification cpointer?]
  [NSWindowWillMiniaturizeNotification cpointer?]
  [NSWindowWillMoveNotification cpointer?]
  [NSWindowWillStartLiveResizeNotification cpointer?]
  [NSWordMLTextDocumentType cpointer?]
  [NSWordTablesReadException cpointer?]
  [NSWordTablesWriteException cpointer?]
  [NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification cpointer?]
  [NSWorkspaceActiveSpaceDidChangeNotification cpointer?]
  [NSWorkspaceApplicationKey cpointer?]
  [NSWorkspaceCompressOperation cpointer?]
  [NSWorkspaceCopyOperation cpointer?]
  [NSWorkspaceDecompressOperation cpointer?]
  [NSWorkspaceDecryptOperation cpointer?]
  [NSWorkspaceDesktopImageAllowClippingKey cpointer?]
  [NSWorkspaceDesktopImageFillColorKey cpointer?]
  [NSWorkspaceDesktopImageScalingKey cpointer?]
  [NSWorkspaceDestroyOperation cpointer?]
  [NSWorkspaceDidActivateApplicationNotification cpointer?]
  [NSWorkspaceDidChangeFileLabelsNotification cpointer?]
  [NSWorkspaceDidDeactivateApplicationNotification cpointer?]
  [NSWorkspaceDidHideApplicationNotification cpointer?]
  [NSWorkspaceDidLaunchApplicationNotification cpointer?]
  [NSWorkspaceDidMountNotification cpointer?]
  [NSWorkspaceDidPerformFileOperationNotification cpointer?]
  [NSWorkspaceDidRenameVolumeNotification cpointer?]
  [NSWorkspaceDidTerminateApplicationNotification cpointer?]
  [NSWorkspaceDidUnhideApplicationNotification cpointer?]
  [NSWorkspaceDidUnmountNotification cpointer?]
  [NSWorkspaceDidWakeNotification cpointer?]
  [NSWorkspaceDuplicateOperation cpointer?]
  [NSWorkspaceEncryptOperation cpointer?]
  [NSWorkspaceLaunchConfigurationAppleEvent cpointer?]
  [NSWorkspaceLaunchConfigurationArchitecture cpointer?]
  [NSWorkspaceLaunchConfigurationArguments cpointer?]
  [NSWorkspaceLaunchConfigurationEnvironment cpointer?]
  [NSWorkspaceLinkOperation cpointer?]
  [NSWorkspaceMoveOperation cpointer?]
  [NSWorkspaceRecycleOperation cpointer?]
  [NSWorkspaceScreensDidSleepNotification cpointer?]
  [NSWorkspaceScreensDidWakeNotification cpointer?]
  [NSWorkspaceSessionDidBecomeActiveNotification cpointer?]
  [NSWorkspaceSessionDidResignActiveNotification cpointer?]
  [NSWorkspaceVolumeLocalizedNameKey cpointer?]
  [NSWorkspaceVolumeOldLocalizedNameKey cpointer?]
  [NSWorkspaceVolumeOldURLKey cpointer?]
  [NSWorkspaceVolumeURLKey cpointer?]
  [NSWorkspaceWillLaunchApplicationNotification cpointer?]
  [NSWorkspaceWillPowerOffNotification cpointer?]
  [NSWorkspaceWillSleepNotification cpointer?]
  [NSWorkspaceWillUnmountNotification cpointer?]
  [NSWritingDirectionAttributeName cpointer?]
  [NSWritingToolsExclusionAttributeName cpointer?]
  )

(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))

(define NSAbortModalException (get-ffi-obj 'NSAbortModalException _fw-lib _id))
(define NSAbortPrintingException (get-ffi-obj 'NSAbortPrintingException _fw-lib _id))
(define NSAboutPanelOptionApplicationIcon (get-ffi-obj 'NSAboutPanelOptionApplicationIcon _fw-lib _id))
(define NSAboutPanelOptionApplicationName (get-ffi-obj 'NSAboutPanelOptionApplicationName _fw-lib _id))
(define NSAboutPanelOptionApplicationVersion (get-ffi-obj 'NSAboutPanelOptionApplicationVersion _fw-lib _id))
(define NSAboutPanelOptionCredits (get-ffi-obj 'NSAboutPanelOptionCredits _fw-lib _id))
(define NSAboutPanelOptionVersion (get-ffi-obj 'NSAboutPanelOptionVersion _fw-lib _id))
(define NSAccessibilityActivationPointAttribute (get-ffi-obj 'NSAccessibilityActivationPointAttribute _fw-lib _id))
(define NSAccessibilityAllowedValuesAttribute (get-ffi-obj 'NSAccessibilityAllowedValuesAttribute _fw-lib _id))
(define NSAccessibilityAlternateUIVisibleAttribute (get-ffi-obj 'NSAccessibilityAlternateUIVisibleAttribute _fw-lib _id))
(define NSAccessibilityAnnotationElement (get-ffi-obj 'NSAccessibilityAnnotationElement _fw-lib _id))
(define NSAccessibilityAnnotationLabel (get-ffi-obj 'NSAccessibilityAnnotationLabel _fw-lib _id))
(define NSAccessibilityAnnotationLocation (get-ffi-obj 'NSAccessibilityAnnotationLocation _fw-lib _id))
(define NSAccessibilityAnnotationTextAttribute (get-ffi-obj 'NSAccessibilityAnnotationTextAttribute _fw-lib _id))
(define NSAccessibilityAnnouncementKey (get-ffi-obj 'NSAccessibilityAnnouncementKey _fw-lib _id))
(define NSAccessibilityAnnouncementRequestedNotification (get-ffi-obj 'NSAccessibilityAnnouncementRequestedNotification _fw-lib _id))
(define NSAccessibilityAnyTypeSearchKey (get-ffi-obj 'NSAccessibilityAnyTypeSearchKey _fw-lib _id))
(define NSAccessibilityApplicationActivatedNotification (get-ffi-obj 'NSAccessibilityApplicationActivatedNotification _fw-lib _id))
(define NSAccessibilityApplicationDeactivatedNotification (get-ffi-obj 'NSAccessibilityApplicationDeactivatedNotification _fw-lib _id))
(define NSAccessibilityApplicationHiddenNotification (get-ffi-obj 'NSAccessibilityApplicationHiddenNotification _fw-lib _id))
(define NSAccessibilityApplicationRole (get-ffi-obj 'NSAccessibilityApplicationRole _fw-lib _id))
(define NSAccessibilityApplicationShownNotification (get-ffi-obj 'NSAccessibilityApplicationShownNotification _fw-lib _id))
(define NSAccessibilityArticleSearchKey (get-ffi-obj 'NSAccessibilityArticleSearchKey _fw-lib _id))
(define NSAccessibilityAscendingSortDirectionValue (get-ffi-obj 'NSAccessibilityAscendingSortDirectionValue _fw-lib _id))
(define NSAccessibilityAttachmentTextAttribute (get-ffi-obj 'NSAccessibilityAttachmentTextAttribute _fw-lib _id))
(define NSAccessibilityAttributedStringForRangeParameterizedAttribute (get-ffi-obj 'NSAccessibilityAttributedStringForRangeParameterizedAttribute _fw-lib _id))
(define NSAccessibilityAutoInteractableAttribute (get-ffi-obj 'NSAccessibilityAutoInteractableAttribute _fw-lib _id))
(define NSAccessibilityAutocorrectedTextAttribute (get-ffi-obj 'NSAccessibilityAutocorrectedTextAttribute _fw-lib _id))
(define NSAccessibilityAutocorrectionOccurredNotification (get-ffi-obj 'NSAccessibilityAutocorrectionOccurredNotification _fw-lib _id))
(define NSAccessibilityBackgroundColorTextAttribute (get-ffi-obj 'NSAccessibilityBackgroundColorTextAttribute _fw-lib _id))
(define NSAccessibilityBlockQuoteLevelAttribute (get-ffi-obj 'NSAccessibilityBlockQuoteLevelAttribute _fw-lib _id))
(define NSAccessibilityBlockquoteSameLevelSearchKey (get-ffi-obj 'NSAccessibilityBlockquoteSameLevelSearchKey _fw-lib _id))
(define NSAccessibilityBlockquoteSearchKey (get-ffi-obj 'NSAccessibilityBlockquoteSearchKey _fw-lib _id))
(define NSAccessibilityBoldFontSearchKey (get-ffi-obj 'NSAccessibilityBoldFontSearchKey _fw-lib _id))
(define NSAccessibilityBoundsForRangeParameterizedAttribute (get-ffi-obj 'NSAccessibilityBoundsForRangeParameterizedAttribute _fw-lib _id))
(define NSAccessibilityBrowserRole (get-ffi-obj 'NSAccessibilityBrowserRole _fw-lib _id))
(define NSAccessibilityBusyIndicatorRole (get-ffi-obj 'NSAccessibilityBusyIndicatorRole _fw-lib _id))
(define NSAccessibilityButtonRole (get-ffi-obj 'NSAccessibilityButtonRole _fw-lib _id))
(define NSAccessibilityButtonSearchKey (get-ffi-obj 'NSAccessibilityButtonSearchKey _fw-lib _id))
(define NSAccessibilityCancelAction (get-ffi-obj 'NSAccessibilityCancelAction _fw-lib _id))
(define NSAccessibilityCancelButtonAttribute (get-ffi-obj 'NSAccessibilityCancelButtonAttribute _fw-lib _id))
(define NSAccessibilityCellForColumnAndRowParameterizedAttribute (get-ffi-obj 'NSAccessibilityCellForColumnAndRowParameterizedAttribute _fw-lib _id))
(define NSAccessibilityCellRole (get-ffi-obj 'NSAccessibilityCellRole _fw-lib _id))
(define NSAccessibilityCenterTabStopMarkerTypeValue (get-ffi-obj 'NSAccessibilityCenterTabStopMarkerTypeValue _fw-lib _id))
(define NSAccessibilityCentimetersUnitValue (get-ffi-obj 'NSAccessibilityCentimetersUnitValue _fw-lib _id))
(define NSAccessibilityCheckBoxRole (get-ffi-obj 'NSAccessibilityCheckBoxRole _fw-lib _id))
(define NSAccessibilityCheckBoxSearchKey (get-ffi-obj 'NSAccessibilityCheckBoxSearchKey _fw-lib _id))
(define NSAccessibilityChildrenAttribute (get-ffi-obj 'NSAccessibilityChildrenAttribute _fw-lib _id))
(define NSAccessibilityChildrenInNavigationOrderAttribute (get-ffi-obj 'NSAccessibilityChildrenInNavigationOrderAttribute _fw-lib _id))
(define NSAccessibilityClearButtonAttribute (get-ffi-obj 'NSAccessibilityClearButtonAttribute _fw-lib _id))
(define NSAccessibilityCloseButtonAttribute (get-ffi-obj 'NSAccessibilityCloseButtonAttribute _fw-lib _id))
(define NSAccessibilityCloseButtonSubrole (get-ffi-obj 'NSAccessibilityCloseButtonSubrole _fw-lib _id))
(define NSAccessibilityCollectionListSubrole (get-ffi-obj 'NSAccessibilityCollectionListSubrole _fw-lib _id))
(define NSAccessibilityColorWellRole (get-ffi-obj 'NSAccessibilityColorWellRole _fw-lib _id))
(define NSAccessibilityColumnCountAttribute (get-ffi-obj 'NSAccessibilityColumnCountAttribute _fw-lib _id))
(define NSAccessibilityColumnHeaderUIElementsAttribute (get-ffi-obj 'NSAccessibilityColumnHeaderUIElementsAttribute _fw-lib _id))
(define NSAccessibilityColumnIndexRangeAttribute (get-ffi-obj 'NSAccessibilityColumnIndexRangeAttribute _fw-lib _id))
(define NSAccessibilityColumnRole (get-ffi-obj 'NSAccessibilityColumnRole _fw-lib _id))
(define NSAccessibilityColumnTitlesAttribute (get-ffi-obj 'NSAccessibilityColumnTitlesAttribute _fw-lib _id))
(define NSAccessibilityColumnsAttribute (get-ffi-obj 'NSAccessibilityColumnsAttribute _fw-lib _id))
(define NSAccessibilityComboBoxRole (get-ffi-obj 'NSAccessibilityComboBoxRole _fw-lib _id))
(define NSAccessibilityConfirmAction (get-ffi-obj 'NSAccessibilityConfirmAction _fw-lib _id))
(define NSAccessibilityContainsProtectedContentAttribute (get-ffi-obj 'NSAccessibilityContainsProtectedContentAttribute _fw-lib _id))
(define NSAccessibilityContentListSubrole (get-ffi-obj 'NSAccessibilityContentListSubrole _fw-lib _id))
(define NSAccessibilityContentsAttribute (get-ffi-obj 'NSAccessibilityContentsAttribute _fw-lib _id))
(define NSAccessibilityControlSearchKey (get-ffi-obj 'NSAccessibilityControlSearchKey _fw-lib _id))
(define NSAccessibilityCreatedNotification (get-ffi-obj 'NSAccessibilityCreatedNotification _fw-lib _id))
(define NSAccessibilityCriticalValueAttribute (get-ffi-obj 'NSAccessibilityCriticalValueAttribute _fw-lib _id))
(define NSAccessibilityCustomTextAttribute (get-ffi-obj 'NSAccessibilityCustomTextAttribute _fw-lib _id))
(define NSAccessibilityDateTimeAreaRole (get-ffi-obj 'NSAccessibilityDateTimeAreaRole _fw-lib _id))
(define NSAccessibilityDateTimeComponentsAttribute (get-ffi-obj 'NSAccessibilityDateTimeComponentsAttribute _fw-lib _id))
(define NSAccessibilityDecimalTabStopMarkerTypeValue (get-ffi-obj 'NSAccessibilityDecimalTabStopMarkerTypeValue _fw-lib _id))
(define NSAccessibilityDecrementAction (get-ffi-obj 'NSAccessibilityDecrementAction _fw-lib _id))
(define NSAccessibilityDecrementArrowSubrole (get-ffi-obj 'NSAccessibilityDecrementArrowSubrole _fw-lib _id))
(define NSAccessibilityDecrementButtonAttribute (get-ffi-obj 'NSAccessibilityDecrementButtonAttribute _fw-lib _id))
(define NSAccessibilityDecrementPageSubrole (get-ffi-obj 'NSAccessibilityDecrementPageSubrole _fw-lib _id))
(define NSAccessibilityDefaultButtonAttribute (get-ffi-obj 'NSAccessibilityDefaultButtonAttribute _fw-lib _id))
(define NSAccessibilityDefinitionListSubrole (get-ffi-obj 'NSAccessibilityDefinitionListSubrole _fw-lib _id))
(define NSAccessibilityDeleteAction (get-ffi-obj 'NSAccessibilityDeleteAction _fw-lib _id))
(define NSAccessibilityDescendingSortDirectionValue (get-ffi-obj 'NSAccessibilityDescendingSortDirectionValue _fw-lib _id))
(define NSAccessibilityDescriptionAttribute (get-ffi-obj 'NSAccessibilityDescriptionAttribute _fw-lib _id))
(define NSAccessibilityDescriptionListSubrole (get-ffi-obj 'NSAccessibilityDescriptionListSubrole _fw-lib _id))
(define NSAccessibilityDialogSubrole (get-ffi-obj 'NSAccessibilityDialogSubrole _fw-lib _id))
(define NSAccessibilityDifferentTypeSearchKey (get-ffi-obj 'NSAccessibilityDifferentTypeSearchKey _fw-lib _id))
(define NSAccessibilityDisclosedByRowAttribute (get-ffi-obj 'NSAccessibilityDisclosedByRowAttribute _fw-lib _id))
(define NSAccessibilityDisclosedRowsAttribute (get-ffi-obj 'NSAccessibilityDisclosedRowsAttribute _fw-lib _id))
(define NSAccessibilityDisclosingAttribute (get-ffi-obj 'NSAccessibilityDisclosingAttribute _fw-lib _id))
(define NSAccessibilityDisclosureLevelAttribute (get-ffi-obj 'NSAccessibilityDisclosureLevelAttribute _fw-lib _id))
(define NSAccessibilityDisclosureTriangleRole (get-ffi-obj 'NSAccessibilityDisclosureTriangleRole _fw-lib _id))
(define NSAccessibilityDocumentAttribute (get-ffi-obj 'NSAccessibilityDocumentAttribute _fw-lib _id))
(define NSAccessibilityDraggingDestinationDragAcceptedNotification (get-ffi-obj 'NSAccessibilityDraggingDestinationDragAcceptedNotification _fw-lib _id))
(define NSAccessibilityDraggingDestinationDragNotAcceptedNotification (get-ffi-obj 'NSAccessibilityDraggingDestinationDragNotAcceptedNotification _fw-lib _id))
(define NSAccessibilityDraggingDestinationDropAllowedNotification (get-ffi-obj 'NSAccessibilityDraggingDestinationDropAllowedNotification _fw-lib _id))
(define NSAccessibilityDraggingDestinationDropNotAllowedNotification (get-ffi-obj 'NSAccessibilityDraggingDestinationDropNotAllowedNotification _fw-lib _id))
(define NSAccessibilityDraggingSourceDragBeganNotification (get-ffi-obj 'NSAccessibilityDraggingSourceDragBeganNotification _fw-lib _id))
(define NSAccessibilityDraggingSourceDragEndedNotification (get-ffi-obj 'NSAccessibilityDraggingSourceDragEndedNotification _fw-lib _id))
(define NSAccessibilityDrawerCreatedNotification (get-ffi-obj 'NSAccessibilityDrawerCreatedNotification _fw-lib _id))
(define NSAccessibilityDrawerRole (get-ffi-obj 'NSAccessibilityDrawerRole _fw-lib _id))
(define NSAccessibilityEditedAttribute (get-ffi-obj 'NSAccessibilityEditedAttribute _fw-lib _id))
(define NSAccessibilityEmbeddedImageDescriptionAttribute (get-ffi-obj 'NSAccessibilityEmbeddedImageDescriptionAttribute _fw-lib _id))
(define NSAccessibilityEnabledAttribute (get-ffi-obj 'NSAccessibilityEnabledAttribute _fw-lib _id))
(define NSAccessibilityErrorCodeExceptionInfo (get-ffi-obj 'NSAccessibilityErrorCodeExceptionInfo _fw-lib _id))
(define NSAccessibilityException (get-ffi-obj 'NSAccessibilityException _fw-lib _id))
(define NSAccessibilityExpandedAttribute (get-ffi-obj 'NSAccessibilityExpandedAttribute _fw-lib _id))
(define NSAccessibilityExtrasMenuBarAttribute (get-ffi-obj 'NSAccessibilityExtrasMenuBarAttribute _fw-lib _id))
(define NSAccessibilityFilenameAttribute (get-ffi-obj 'NSAccessibilityFilenameAttribute _fw-lib _id))
(define NSAccessibilityFirstLineIndentMarkerTypeValue (get-ffi-obj 'NSAccessibilityFirstLineIndentMarkerTypeValue _fw-lib _id))
(define NSAccessibilityFloatingWindowSubrole (get-ffi-obj 'NSAccessibilityFloatingWindowSubrole _fw-lib _id))
(define NSAccessibilityFocusedAttribute (get-ffi-obj 'NSAccessibilityFocusedAttribute _fw-lib _id))
(define NSAccessibilityFocusedUIElementAttribute (get-ffi-obj 'NSAccessibilityFocusedUIElementAttribute _fw-lib _id))
(define NSAccessibilityFocusedUIElementChangedNotification (get-ffi-obj 'NSAccessibilityFocusedUIElementChangedNotification _fw-lib _id))
(define NSAccessibilityFocusedWindowAttribute (get-ffi-obj 'NSAccessibilityFocusedWindowAttribute _fw-lib _id))
(define NSAccessibilityFocusedWindowChangedNotification (get-ffi-obj 'NSAccessibilityFocusedWindowChangedNotification _fw-lib _id))
(define NSAccessibilityFontBoldAttribute (get-ffi-obj 'NSAccessibilityFontBoldAttribute _fw-lib _id))
(define NSAccessibilityFontChangeSearchKey (get-ffi-obj 'NSAccessibilityFontChangeSearchKey _fw-lib _id))
(define NSAccessibilityFontColorChangeSearchKey (get-ffi-obj 'NSAccessibilityFontColorChangeSearchKey _fw-lib _id))
(define NSAccessibilityFontFamilyKey (get-ffi-obj 'NSAccessibilityFontFamilyKey _fw-lib _id))
(define NSAccessibilityFontItalicAttribute (get-ffi-obj 'NSAccessibilityFontItalicAttribute _fw-lib _id))
(define NSAccessibilityFontNameKey (get-ffi-obj 'NSAccessibilityFontNameKey _fw-lib _id))
(define NSAccessibilityFontSizeKey (get-ffi-obj 'NSAccessibilityFontSizeKey _fw-lib _id))
(define NSAccessibilityFontTextAttribute (get-ffi-obj 'NSAccessibilityFontTextAttribute _fw-lib _id))
(define NSAccessibilityForegroundColorTextAttribute (get-ffi-obj 'NSAccessibilityForegroundColorTextAttribute _fw-lib _id))
(define NSAccessibilityFrameSearchKey (get-ffi-obj 'NSAccessibilityFrameSearchKey _fw-lib _id))
(define NSAccessibilityFrontmostAttribute (get-ffi-obj 'NSAccessibilityFrontmostAttribute _fw-lib _id))
(define NSAccessibilityFullScreenButtonAttribute (get-ffi-obj 'NSAccessibilityFullScreenButtonAttribute _fw-lib _id))
(define NSAccessibilityFullScreenButtonSubrole (get-ffi-obj 'NSAccessibilityFullScreenButtonSubrole _fw-lib _id))
(define NSAccessibilityGraphicSearchKey (get-ffi-obj 'NSAccessibilityGraphicSearchKey _fw-lib _id))
(define NSAccessibilityGridRole (get-ffi-obj 'NSAccessibilityGridRole _fw-lib _id))
(define NSAccessibilityGroupRole (get-ffi-obj 'NSAccessibilityGroupRole _fw-lib _id))
(define NSAccessibilityGrowAreaAttribute (get-ffi-obj 'NSAccessibilityGrowAreaAttribute _fw-lib _id))
(define NSAccessibilityGrowAreaRole (get-ffi-obj 'NSAccessibilityGrowAreaRole _fw-lib _id))
(define NSAccessibilityHandleRole (get-ffi-obj 'NSAccessibilityHandleRole _fw-lib _id))
(define NSAccessibilityHandlesAttribute (get-ffi-obj 'NSAccessibilityHandlesAttribute _fw-lib _id))
(define NSAccessibilityHeadIndentMarkerTypeValue (get-ffi-obj 'NSAccessibilityHeadIndentMarkerTypeValue _fw-lib _id))
(define NSAccessibilityHeaderAttribute (get-ffi-obj 'NSAccessibilityHeaderAttribute _fw-lib _id))
(define NSAccessibilityHeadingLevel1SearchKey (get-ffi-obj 'NSAccessibilityHeadingLevel1SearchKey _fw-lib _id))
(define NSAccessibilityHeadingLevel2SearchKey (get-ffi-obj 'NSAccessibilityHeadingLevel2SearchKey _fw-lib _id))
(define NSAccessibilityHeadingLevel3SearchKey (get-ffi-obj 'NSAccessibilityHeadingLevel3SearchKey _fw-lib _id))
(define NSAccessibilityHeadingLevel4SearchKey (get-ffi-obj 'NSAccessibilityHeadingLevel4SearchKey _fw-lib _id))
(define NSAccessibilityHeadingLevel5SearchKey (get-ffi-obj 'NSAccessibilityHeadingLevel5SearchKey _fw-lib _id))
(define NSAccessibilityHeadingLevel6SearchKey (get-ffi-obj 'NSAccessibilityHeadingLevel6SearchKey _fw-lib _id))
(define NSAccessibilityHeadingLevelAttribute (get-ffi-obj 'NSAccessibilityHeadingLevelAttribute _fw-lib _id))
(define NSAccessibilityHeadingRole (get-ffi-obj 'NSAccessibilityHeadingRole _fw-lib _id))
(define NSAccessibilityHeadingSameLevelSearchKey (get-ffi-obj 'NSAccessibilityHeadingSameLevelSearchKey _fw-lib _id))
(define NSAccessibilityHeadingSearchKey (get-ffi-obj 'NSAccessibilityHeadingSearchKey _fw-lib _id))
(define NSAccessibilityHelpAttribute (get-ffi-obj 'NSAccessibilityHelpAttribute _fw-lib _id))
(define NSAccessibilityHelpTagCreatedNotification (get-ffi-obj 'NSAccessibilityHelpTagCreatedNotification _fw-lib _id))
(define NSAccessibilityHelpTagRole (get-ffi-obj 'NSAccessibilityHelpTagRole _fw-lib _id))
(define NSAccessibilityHiddenAttribute (get-ffi-obj 'NSAccessibilityHiddenAttribute _fw-lib _id))
(define NSAccessibilityHorizontalOrientationValue (get-ffi-obj 'NSAccessibilityHorizontalOrientationValue _fw-lib _id))
(define NSAccessibilityHorizontalScrollBarAttribute (get-ffi-obj 'NSAccessibilityHorizontalScrollBarAttribute _fw-lib _id))
(define NSAccessibilityHorizontalUnitDescriptionAttribute (get-ffi-obj 'NSAccessibilityHorizontalUnitDescriptionAttribute _fw-lib _id))
(define NSAccessibilityHorizontalUnitsAttribute (get-ffi-obj 'NSAccessibilityHorizontalUnitsAttribute _fw-lib _id))
(define NSAccessibilityIdentifierAttribute (get-ffi-obj 'NSAccessibilityIdentifierAttribute _fw-lib _id))
(define NSAccessibilityImageRole (get-ffi-obj 'NSAccessibilityImageRole _fw-lib _id))
(define NSAccessibilityInchesUnitValue (get-ffi-obj 'NSAccessibilityInchesUnitValue _fw-lib _id))
(define NSAccessibilityIncrementAction (get-ffi-obj 'NSAccessibilityIncrementAction _fw-lib _id))
(define NSAccessibilityIncrementArrowSubrole (get-ffi-obj 'NSAccessibilityIncrementArrowSubrole _fw-lib _id))
(define NSAccessibilityIncrementButtonAttribute (get-ffi-obj 'NSAccessibilityIncrementButtonAttribute _fw-lib _id))
(define NSAccessibilityIncrementPageSubrole (get-ffi-obj 'NSAccessibilityIncrementPageSubrole _fw-lib _id))
(define NSAccessibilityIncrementorRole (get-ffi-obj 'NSAccessibilityIncrementorRole _fw-lib _id))
(define NSAccessibilityIndexAttribute (get-ffi-obj 'NSAccessibilityIndexAttribute _fw-lib _id))
(define NSAccessibilityIndexForChildUIElementAttribute (get-ffi-obj 'NSAccessibilityIndexForChildUIElementAttribute _fw-lib _id))
(define NSAccessibilityIndexForChildUIElementInNavigationOrderAttribute (get-ffi-obj 'NSAccessibilityIndexForChildUIElementInNavigationOrderAttribute _fw-lib _id))
(define NSAccessibilityInsertionPointLineNumberAttribute (get-ffi-obj 'NSAccessibilityInsertionPointLineNumberAttribute _fw-lib _id))
(define NSAccessibilityItalicFontSearchKey (get-ffi-obj 'NSAccessibilityItalicFontSearchKey _fw-lib _id))
(define NSAccessibilityKeyboardFocusableSearchKey (get-ffi-obj 'NSAccessibilityKeyboardFocusableSearchKey _fw-lib _id))
(define NSAccessibilityLabelUIElementsAttribute (get-ffi-obj 'NSAccessibilityLabelUIElementsAttribute _fw-lib _id))
(define NSAccessibilityLabelValueAttribute (get-ffi-obj 'NSAccessibilityLabelValueAttribute _fw-lib _id))
(define NSAccessibilityLandmarkSearchKey (get-ffi-obj 'NSAccessibilityLandmarkSearchKey _fw-lib _id))
(define NSAccessibilityLanguageAttribute (get-ffi-obj 'NSAccessibilityLanguageAttribute _fw-lib _id))
(define NSAccessibilityLanguageTextAttribute (get-ffi-obj 'NSAccessibilityLanguageTextAttribute _fw-lib _id))
(define NSAccessibilityLayoutAreaRole (get-ffi-obj 'NSAccessibilityLayoutAreaRole _fw-lib _id))
(define NSAccessibilityLayoutChangedNotification (get-ffi-obj 'NSAccessibilityLayoutChangedNotification _fw-lib _id))
(define NSAccessibilityLayoutItemRole (get-ffi-obj 'NSAccessibilityLayoutItemRole _fw-lib _id))
(define NSAccessibilityLayoutPointForScreenPointParameterizedAttribute (get-ffi-obj 'NSAccessibilityLayoutPointForScreenPointParameterizedAttribute _fw-lib _id))
(define NSAccessibilityLayoutSizeForScreenSizeParameterizedAttribute (get-ffi-obj 'NSAccessibilityLayoutSizeForScreenSizeParameterizedAttribute _fw-lib _id))
(define NSAccessibilityLeftTabStopMarkerTypeValue (get-ffi-obj 'NSAccessibilityLeftTabStopMarkerTypeValue _fw-lib _id))
(define NSAccessibilityLevelIndicatorRole (get-ffi-obj 'NSAccessibilityLevelIndicatorRole _fw-lib _id))
(define NSAccessibilityLineForIndexParameterizedAttribute (get-ffi-obj 'NSAccessibilityLineForIndexParameterizedAttribute _fw-lib _id))
(define NSAccessibilityLinkRole (get-ffi-obj 'NSAccessibilityLinkRole _fw-lib _id))
(define NSAccessibilityLinkSearchKey (get-ffi-obj 'NSAccessibilityLinkSearchKey _fw-lib _id))
(define NSAccessibilityLinkTextAttribute (get-ffi-obj 'NSAccessibilityLinkTextAttribute _fw-lib _id))
(define NSAccessibilityLinkedUIElementsAttribute (get-ffi-obj 'NSAccessibilityLinkedUIElementsAttribute _fw-lib _id))
(define NSAccessibilityListItemIndexTextAttribute (get-ffi-obj 'NSAccessibilityListItemIndexTextAttribute _fw-lib _id))
(define NSAccessibilityListItemLevelTextAttribute (get-ffi-obj 'NSAccessibilityListItemLevelTextAttribute _fw-lib _id))
(define NSAccessibilityListItemPrefixTextAttribute (get-ffi-obj 'NSAccessibilityListItemPrefixTextAttribute _fw-lib _id))
(define NSAccessibilityListMarkerRole (get-ffi-obj 'NSAccessibilityListMarkerRole _fw-lib _id))
(define NSAccessibilityListRole (get-ffi-obj 'NSAccessibilityListRole _fw-lib _id))
(define NSAccessibilityListSearchKey (get-ffi-obj 'NSAccessibilityListSearchKey _fw-lib _id))
(define NSAccessibilityLiveRegionSearchKey (get-ffi-obj 'NSAccessibilityLiveRegionSearchKey _fw-lib _id))
(define NSAccessibilityMainAttribute (get-ffi-obj 'NSAccessibilityMainAttribute _fw-lib _id))
(define NSAccessibilityMainWindowAttribute (get-ffi-obj 'NSAccessibilityMainWindowAttribute _fw-lib _id))
(define NSAccessibilityMainWindowChangedNotification (get-ffi-obj 'NSAccessibilityMainWindowChangedNotification _fw-lib _id))
(define NSAccessibilityMarkedMisspelledTextAttribute (get-ffi-obj 'NSAccessibilityMarkedMisspelledTextAttribute _fw-lib _id))
(define NSAccessibilityMarkerGroupUIElementAttribute (get-ffi-obj 'NSAccessibilityMarkerGroupUIElementAttribute _fw-lib _id))
(define NSAccessibilityMarkerTypeAttribute (get-ffi-obj 'NSAccessibilityMarkerTypeAttribute _fw-lib _id))
(define NSAccessibilityMarkerTypeDescriptionAttribute (get-ffi-obj 'NSAccessibilityMarkerTypeDescriptionAttribute _fw-lib _id))
(define NSAccessibilityMarkerUIElementsAttribute (get-ffi-obj 'NSAccessibilityMarkerUIElementsAttribute _fw-lib _id))
(define NSAccessibilityMarkerValuesAttribute (get-ffi-obj 'NSAccessibilityMarkerValuesAttribute _fw-lib _id))
(define NSAccessibilityMatteContentUIElementAttribute (get-ffi-obj 'NSAccessibilityMatteContentUIElementAttribute _fw-lib _id))
(define NSAccessibilityMatteHoleAttribute (get-ffi-obj 'NSAccessibilityMatteHoleAttribute _fw-lib _id))
(define NSAccessibilityMatteRole (get-ffi-obj 'NSAccessibilityMatteRole _fw-lib _id))
(define NSAccessibilityMaxValueAttribute (get-ffi-obj 'NSAccessibilityMaxValueAttribute _fw-lib _id))
(define NSAccessibilityMenuBarAttribute (get-ffi-obj 'NSAccessibilityMenuBarAttribute _fw-lib _id))
(define NSAccessibilityMenuBarItemRole (get-ffi-obj 'NSAccessibilityMenuBarItemRole _fw-lib _id))
(define NSAccessibilityMenuBarRole (get-ffi-obj 'NSAccessibilityMenuBarRole _fw-lib _id))
(define NSAccessibilityMenuButtonRole (get-ffi-obj 'NSAccessibilityMenuButtonRole _fw-lib _id))
(define NSAccessibilityMenuItemRole (get-ffi-obj 'NSAccessibilityMenuItemRole _fw-lib _id))
(define NSAccessibilityMenuRole (get-ffi-obj 'NSAccessibilityMenuRole _fw-lib _id))
(define NSAccessibilityMinValueAttribute (get-ffi-obj 'NSAccessibilityMinValueAttribute _fw-lib _id))
(define NSAccessibilityMinimizeButtonAttribute (get-ffi-obj 'NSAccessibilityMinimizeButtonAttribute _fw-lib _id))
(define NSAccessibilityMinimizeButtonSubrole (get-ffi-obj 'NSAccessibilityMinimizeButtonSubrole _fw-lib _id))
(define NSAccessibilityMinimizedAttribute (get-ffi-obj 'NSAccessibilityMinimizedAttribute _fw-lib _id))
(define NSAccessibilityMisspelledTextAttribute (get-ffi-obj 'NSAccessibilityMisspelledTextAttribute _fw-lib _id))
(define NSAccessibilityMisspelledWordSearchKey (get-ffi-obj 'NSAccessibilityMisspelledWordSearchKey _fw-lib _id))
(define NSAccessibilityModalAttribute (get-ffi-obj 'NSAccessibilityModalAttribute _fw-lib _id))
(define NSAccessibilityMovedNotification (get-ffi-obj 'NSAccessibilityMovedNotification _fw-lib _id))
(define NSAccessibilityNextContentsAttribute (get-ffi-obj 'NSAccessibilityNextContentsAttribute _fw-lib _id))
(define NSAccessibilityNumberOfCharactersAttribute (get-ffi-obj 'NSAccessibilityNumberOfCharactersAttribute _fw-lib _id))
(define NSAccessibilityOrderedByRowAttribute (get-ffi-obj 'NSAccessibilityOrderedByRowAttribute _fw-lib _id))
(define NSAccessibilityOrientationAttribute (get-ffi-obj 'NSAccessibilityOrientationAttribute _fw-lib _id))
(define NSAccessibilityOutlineRole (get-ffi-obj 'NSAccessibilityOutlineRole _fw-lib _id))
(define NSAccessibilityOutlineRowSubrole (get-ffi-obj 'NSAccessibilityOutlineRowSubrole _fw-lib _id))
(define NSAccessibilityOutlineSearchKey (get-ffi-obj 'NSAccessibilityOutlineSearchKey _fw-lib _id))
(define NSAccessibilityOverflowButtonAttribute (get-ffi-obj 'NSAccessibilityOverflowButtonAttribute _fw-lib _id))
(define NSAccessibilityPageRole (get-ffi-obj 'NSAccessibilityPageRole _fw-lib _id))
(define NSAccessibilityParentAttribute (get-ffi-obj 'NSAccessibilityParentAttribute _fw-lib _id))
(define NSAccessibilityPathAttribute (get-ffi-obj 'NSAccessibilityPathAttribute _fw-lib _id))
(define NSAccessibilityPicasUnitValue (get-ffi-obj 'NSAccessibilityPicasUnitValue _fw-lib _id))
(define NSAccessibilityPickAction (get-ffi-obj 'NSAccessibilityPickAction _fw-lib _id))
(define NSAccessibilityPlaceholderValueAttribute (get-ffi-obj 'NSAccessibilityPlaceholderValueAttribute _fw-lib _id))
(define NSAccessibilityPlainTextSearchKey (get-ffi-obj 'NSAccessibilityPlainTextSearchKey _fw-lib _id))
(define NSAccessibilityPointsUnitValue (get-ffi-obj 'NSAccessibilityPointsUnitValue _fw-lib _id))
(define NSAccessibilityPopUpButtonRole (get-ffi-obj 'NSAccessibilityPopUpButtonRole _fw-lib _id))
(define NSAccessibilityPopoverRole (get-ffi-obj 'NSAccessibilityPopoverRole _fw-lib _id))
(define NSAccessibilityPositionAttribute (get-ffi-obj 'NSAccessibilityPositionAttribute _fw-lib _id))
(define NSAccessibilityPressAction (get-ffi-obj 'NSAccessibilityPressAction _fw-lib _id))
(define NSAccessibilityPreviousContentsAttribute (get-ffi-obj 'NSAccessibilityPreviousContentsAttribute _fw-lib _id))
(define NSAccessibilityPriorityKey (get-ffi-obj 'NSAccessibilityPriorityKey _fw-lib _id))
(define NSAccessibilityProgressIndicatorRole (get-ffi-obj 'NSAccessibilityProgressIndicatorRole _fw-lib _id))
(define NSAccessibilityProxyAttribute (get-ffi-obj 'NSAccessibilityProxyAttribute _fw-lib _id))
(define NSAccessibilityRTFForRangeParameterizedAttribute (get-ffi-obj 'NSAccessibilityRTFForRangeParameterizedAttribute _fw-lib _id))
(define NSAccessibilityRadioButtonRole (get-ffi-obj 'NSAccessibilityRadioButtonRole _fw-lib _id))
(define NSAccessibilityRadioGroupRole (get-ffi-obj 'NSAccessibilityRadioGroupRole _fw-lib _id))
(define NSAccessibilityRadioGroupSearchKey (get-ffi-obj 'NSAccessibilityRadioGroupSearchKey _fw-lib _id))
(define NSAccessibilityRaiseAction (get-ffi-obj 'NSAccessibilityRaiseAction _fw-lib _id))
(define NSAccessibilityRangeForIndexParameterizedAttribute (get-ffi-obj 'NSAccessibilityRangeForIndexParameterizedAttribute _fw-lib _id))
(define NSAccessibilityRangeForLineParameterizedAttribute (get-ffi-obj 'NSAccessibilityRangeForLineParameterizedAttribute _fw-lib _id))
(define NSAccessibilityRangeForPositionParameterizedAttribute (get-ffi-obj 'NSAccessibilityRangeForPositionParameterizedAttribute _fw-lib _id))
(define NSAccessibilityRatingIndicatorSubrole (get-ffi-obj 'NSAccessibilityRatingIndicatorSubrole _fw-lib _id))
(define NSAccessibilityRelevanceIndicatorRole (get-ffi-obj 'NSAccessibilityRelevanceIndicatorRole _fw-lib _id))
(define NSAccessibilityRequiredAttribute (get-ffi-obj 'NSAccessibilityRequiredAttribute _fw-lib _id))
(define NSAccessibilityResizedNotification (get-ffi-obj 'NSAccessibilityResizedNotification _fw-lib _id))
(define NSAccessibilityResultsForSearchPredicateParameterizedAttribute (get-ffi-obj 'NSAccessibilityResultsForSearchPredicateParameterizedAttribute _fw-lib _id))
(define NSAccessibilityRightTabStopMarkerTypeValue (get-ffi-obj 'NSAccessibilityRightTabStopMarkerTypeValue _fw-lib _id))
(define NSAccessibilityRoleAttribute (get-ffi-obj 'NSAccessibilityRoleAttribute _fw-lib _id))
(define NSAccessibilityRoleDescriptionAttribute (get-ffi-obj 'NSAccessibilityRoleDescriptionAttribute _fw-lib _id))
(define NSAccessibilityRowCollapsedNotification (get-ffi-obj 'NSAccessibilityRowCollapsedNotification _fw-lib _id))
(define NSAccessibilityRowCountAttribute (get-ffi-obj 'NSAccessibilityRowCountAttribute _fw-lib _id))
(define NSAccessibilityRowCountChangedNotification (get-ffi-obj 'NSAccessibilityRowCountChangedNotification _fw-lib _id))
(define NSAccessibilityRowExpandedNotification (get-ffi-obj 'NSAccessibilityRowExpandedNotification _fw-lib _id))
(define NSAccessibilityRowHeaderUIElementsAttribute (get-ffi-obj 'NSAccessibilityRowHeaderUIElementsAttribute _fw-lib _id))
(define NSAccessibilityRowIndexRangeAttribute (get-ffi-obj 'NSAccessibilityRowIndexRangeAttribute _fw-lib _id))
(define NSAccessibilityRowRole (get-ffi-obj 'NSAccessibilityRowRole _fw-lib _id))
(define NSAccessibilityRowsAttribute (get-ffi-obj 'NSAccessibilityRowsAttribute _fw-lib _id))
(define NSAccessibilityRulerMarkerRole (get-ffi-obj 'NSAccessibilityRulerMarkerRole _fw-lib _id))
(define NSAccessibilityRulerRole (get-ffi-obj 'NSAccessibilityRulerRole _fw-lib _id))
(define NSAccessibilitySameTypeSearchKey (get-ffi-obj 'NSAccessibilitySameTypeSearchKey _fw-lib _id))
(define NSAccessibilityScreenPointForLayoutPointParameterizedAttribute (get-ffi-obj 'NSAccessibilityScreenPointForLayoutPointParameterizedAttribute _fw-lib _id))
(define NSAccessibilityScreenSizeForLayoutSizeParameterizedAttribute (get-ffi-obj 'NSAccessibilityScreenSizeForLayoutSizeParameterizedAttribute _fw-lib _id))
(define NSAccessibilityScrollAreaRole (get-ffi-obj 'NSAccessibilityScrollAreaRole _fw-lib _id))
(define NSAccessibilityScrollBarRole (get-ffi-obj 'NSAccessibilityScrollBarRole _fw-lib _id))
(define NSAccessibilityScrollToVisibleAction (get-ffi-obj 'NSAccessibilityScrollToVisibleAction _fw-lib _id))
(define NSAccessibilitySearchButtonAttribute (get-ffi-obj 'NSAccessibilitySearchButtonAttribute _fw-lib _id))
(define NSAccessibilitySearchCurrentElementKey (get-ffi-obj 'NSAccessibilitySearchCurrentElementKey _fw-lib _id))
(define NSAccessibilitySearchCurrentRangeKey (get-ffi-obj 'NSAccessibilitySearchCurrentRangeKey _fw-lib _id))
(define NSAccessibilitySearchDirectionKey (get-ffi-obj 'NSAccessibilitySearchDirectionKey _fw-lib _id))
(define NSAccessibilitySearchDirectionNext (get-ffi-obj 'NSAccessibilitySearchDirectionNext _fw-lib _id))
(define NSAccessibilitySearchDirectionPrevious (get-ffi-obj 'NSAccessibilitySearchDirectionPrevious _fw-lib _id))
(define NSAccessibilitySearchFieldSubrole (get-ffi-obj 'NSAccessibilitySearchFieldSubrole _fw-lib _id))
(define NSAccessibilitySearchIdentifiersKey (get-ffi-obj 'NSAccessibilitySearchIdentifiersKey _fw-lib _id))
(define NSAccessibilitySearchMenuAttribute (get-ffi-obj 'NSAccessibilitySearchMenuAttribute _fw-lib _id))
(define NSAccessibilitySearchResultDescriptionOverrideKey (get-ffi-obj 'NSAccessibilitySearchResultDescriptionOverrideKey _fw-lib _id))
(define NSAccessibilitySearchResultElementKey (get-ffi-obj 'NSAccessibilitySearchResultElementKey _fw-lib _id))
(define NSAccessibilitySearchResultLoaderKey (get-ffi-obj 'NSAccessibilitySearchResultLoaderKey _fw-lib _id))
(define NSAccessibilitySearchResultRangeKey (get-ffi-obj 'NSAccessibilitySearchResultRangeKey _fw-lib _id))
(define NSAccessibilitySearchResultsLimitKey (get-ffi-obj 'NSAccessibilitySearchResultsLimitKey _fw-lib _id))
(define NSAccessibilitySearchTextKey (get-ffi-obj 'NSAccessibilitySearchTextKey _fw-lib _id))
(define NSAccessibilitySectionListSubrole (get-ffi-obj 'NSAccessibilitySectionListSubrole _fw-lib _id))
(define NSAccessibilitySecureTextFieldSubrole (get-ffi-obj 'NSAccessibilitySecureTextFieldSubrole _fw-lib _id))
(define NSAccessibilitySelectedAttribute (get-ffi-obj 'NSAccessibilitySelectedAttribute _fw-lib _id))
(define NSAccessibilitySelectedCellsAttribute (get-ffi-obj 'NSAccessibilitySelectedCellsAttribute _fw-lib _id))
(define NSAccessibilitySelectedCellsChangedNotification (get-ffi-obj 'NSAccessibilitySelectedCellsChangedNotification _fw-lib _id))
(define NSAccessibilitySelectedChildrenAttribute (get-ffi-obj 'NSAccessibilitySelectedChildrenAttribute _fw-lib _id))
(define NSAccessibilitySelectedChildrenChangedNotification (get-ffi-obj 'NSAccessibilitySelectedChildrenChangedNotification _fw-lib _id))
(define NSAccessibilitySelectedChildrenMovedNotification (get-ffi-obj 'NSAccessibilitySelectedChildrenMovedNotification _fw-lib _id))
(define NSAccessibilitySelectedColumnsAttribute (get-ffi-obj 'NSAccessibilitySelectedColumnsAttribute _fw-lib _id))
(define NSAccessibilitySelectedColumnsChangedNotification (get-ffi-obj 'NSAccessibilitySelectedColumnsChangedNotification _fw-lib _id))
(define NSAccessibilitySelectedRowsAttribute (get-ffi-obj 'NSAccessibilitySelectedRowsAttribute _fw-lib _id))
(define NSAccessibilitySelectedRowsChangedNotification (get-ffi-obj 'NSAccessibilitySelectedRowsChangedNotification _fw-lib _id))
(define NSAccessibilitySelectedTextAttribute (get-ffi-obj 'NSAccessibilitySelectedTextAttribute _fw-lib _id))
(define NSAccessibilitySelectedTextChangedNotification (get-ffi-obj 'NSAccessibilitySelectedTextChangedNotification _fw-lib _id))
(define NSAccessibilitySelectedTextRangeAttribute (get-ffi-obj 'NSAccessibilitySelectedTextRangeAttribute _fw-lib _id))
(define NSAccessibilitySelectedTextRangesAttribute (get-ffi-obj 'NSAccessibilitySelectedTextRangesAttribute _fw-lib _id))
(define NSAccessibilityServesAsTitleForUIElementsAttribute (get-ffi-obj 'NSAccessibilityServesAsTitleForUIElementsAttribute _fw-lib _id))
(define NSAccessibilityShadowTextAttribute (get-ffi-obj 'NSAccessibilityShadowTextAttribute _fw-lib _id))
(define NSAccessibilitySharedCharacterRangeAttribute (get-ffi-obj 'NSAccessibilitySharedCharacterRangeAttribute _fw-lib _id))
(define NSAccessibilitySharedFocusElementsAttribute (get-ffi-obj 'NSAccessibilitySharedFocusElementsAttribute _fw-lib _id))
(define NSAccessibilitySharedTextUIElementsAttribute (get-ffi-obj 'NSAccessibilitySharedTextUIElementsAttribute _fw-lib _id))
(define NSAccessibilitySheetCreatedNotification (get-ffi-obj 'NSAccessibilitySheetCreatedNotification _fw-lib _id))
(define NSAccessibilitySheetRole (get-ffi-obj 'NSAccessibilitySheetRole _fw-lib _id))
(define NSAccessibilityShowAlternateUIAction (get-ffi-obj 'NSAccessibilityShowAlternateUIAction _fw-lib _id))
(define NSAccessibilityShowDefaultUIAction (get-ffi-obj 'NSAccessibilityShowDefaultUIAction _fw-lib _id))
(define NSAccessibilityShowMenuAction (get-ffi-obj 'NSAccessibilityShowMenuAction _fw-lib _id))
(define NSAccessibilityShownMenuAttribute (get-ffi-obj 'NSAccessibilityShownMenuAttribute _fw-lib _id))
(define NSAccessibilitySizeAttribute (get-ffi-obj 'NSAccessibilitySizeAttribute _fw-lib _id))
(define NSAccessibilitySliderRole (get-ffi-obj 'NSAccessibilitySliderRole _fw-lib _id))
(define NSAccessibilitySortButtonRole (get-ffi-obj 'NSAccessibilitySortButtonRole _fw-lib _id))
(define NSAccessibilitySortButtonSubrole (get-ffi-obj 'NSAccessibilitySortButtonSubrole _fw-lib _id))
(define NSAccessibilitySortDirectionAttribute (get-ffi-obj 'NSAccessibilitySortDirectionAttribute _fw-lib _id))
(define NSAccessibilitySplitGroupRole (get-ffi-obj 'NSAccessibilitySplitGroupRole _fw-lib _id))
(define NSAccessibilitySplitterRole (get-ffi-obj 'NSAccessibilitySplitterRole _fw-lib _id))
(define NSAccessibilitySplittersAttribute (get-ffi-obj 'NSAccessibilitySplittersAttribute _fw-lib _id))
(define NSAccessibilityStandardWindowSubrole (get-ffi-obj 'NSAccessibilityStandardWindowSubrole _fw-lib _id))
(define NSAccessibilityStaticTextRole (get-ffi-obj 'NSAccessibilityStaticTextRole _fw-lib _id))
(define NSAccessibilityStaticTextSearchKey (get-ffi-obj 'NSAccessibilityStaticTextSearchKey _fw-lib _id))
(define NSAccessibilityStrikethroughColorTextAttribute (get-ffi-obj 'NSAccessibilityStrikethroughColorTextAttribute _fw-lib _id))
(define NSAccessibilityStrikethroughTextAttribute (get-ffi-obj 'NSAccessibilityStrikethroughTextAttribute _fw-lib _id))
(define NSAccessibilityStringForRangeParameterizedAttribute (get-ffi-obj 'NSAccessibilityStringForRangeParameterizedAttribute _fw-lib _id))
(define NSAccessibilityStyleChangeSearchKey (get-ffi-obj 'NSAccessibilityStyleChangeSearchKey _fw-lib _id))
(define NSAccessibilityStyleRangeForIndexParameterizedAttribute (get-ffi-obj 'NSAccessibilityStyleRangeForIndexParameterizedAttribute _fw-lib _id))
(define NSAccessibilitySubroleAttribute (get-ffi-obj 'NSAccessibilitySubroleAttribute _fw-lib _id))
(define NSAccessibilitySuggestionSubrole (get-ffi-obj 'NSAccessibilitySuggestionSubrole _fw-lib _id))
(define NSAccessibilitySuperscriptTextAttribute (get-ffi-obj 'NSAccessibilitySuperscriptTextAttribute _fw-lib _id))
(define NSAccessibilitySwitchSubrole (get-ffi-obj 'NSAccessibilitySwitchSubrole _fw-lib _id))
(define NSAccessibilitySystemDialogSubrole (get-ffi-obj 'NSAccessibilitySystemDialogSubrole _fw-lib _id))
(define NSAccessibilitySystemFloatingWindowSubrole (get-ffi-obj 'NSAccessibilitySystemFloatingWindowSubrole _fw-lib _id))
(define NSAccessibilitySystemWideRole (get-ffi-obj 'NSAccessibilitySystemWideRole _fw-lib _id))
(define NSAccessibilityTabButtonSubrole (get-ffi-obj 'NSAccessibilityTabButtonSubrole _fw-lib _id))
(define NSAccessibilityTabGroupRole (get-ffi-obj 'NSAccessibilityTabGroupRole _fw-lib _id))
(define NSAccessibilityTableRole (get-ffi-obj 'NSAccessibilityTableRole _fw-lib _id))
(define NSAccessibilityTableRowSubrole (get-ffi-obj 'NSAccessibilityTableRowSubrole _fw-lib _id))
(define NSAccessibilityTableSameLevelSearchKey (get-ffi-obj 'NSAccessibilityTableSameLevelSearchKey _fw-lib _id))
(define NSAccessibilityTableSearchKey (get-ffi-obj 'NSAccessibilityTableSearchKey _fw-lib _id))
(define NSAccessibilityTabsAttribute (get-ffi-obj 'NSAccessibilityTabsAttribute _fw-lib _id))
(define NSAccessibilityTailIndentMarkerTypeValue (get-ffi-obj 'NSAccessibilityTailIndentMarkerTypeValue _fw-lib _id))
(define NSAccessibilityTextAlignmentAttribute (get-ffi-obj 'NSAccessibilityTextAlignmentAttribute _fw-lib _id))
(define NSAccessibilityTextAreaRole (get-ffi-obj 'NSAccessibilityTextAreaRole _fw-lib _id))
(define NSAccessibilityTextAttachmentSubrole (get-ffi-obj 'NSAccessibilityTextAttachmentSubrole _fw-lib _id))
(define NSAccessibilityTextCompletionAttribute (get-ffi-obj 'NSAccessibilityTextCompletionAttribute _fw-lib _id))
(define NSAccessibilityTextFieldRole (get-ffi-obj 'NSAccessibilityTextFieldRole _fw-lib _id))
(define NSAccessibilityTextFieldSearchKey (get-ffi-obj 'NSAccessibilityTextFieldSearchKey _fw-lib _id))
(define NSAccessibilityTextInputMarkedRangeAttribute (get-ffi-obj 'NSAccessibilityTextInputMarkedRangeAttribute _fw-lib _id))
(define NSAccessibilityTextInputMarkingSessionBeganNotification (get-ffi-obj 'NSAccessibilityTextInputMarkingSessionBeganNotification _fw-lib _id))
(define NSAccessibilityTextInputMarkingSessionEndedNotification (get-ffi-obj 'NSAccessibilityTextInputMarkingSessionEndedNotification _fw-lib _id))
(define NSAccessibilityTextLinkSubrole (get-ffi-obj 'NSAccessibilityTextLinkSubrole _fw-lib _id))
(define NSAccessibilityTextStateChangeTypeKey (get-ffi-obj 'NSAccessibilityTextStateChangeTypeKey _fw-lib _id))
(define NSAccessibilityTextStateSyncKey (get-ffi-obj 'NSAccessibilityTextStateSyncKey _fw-lib _id))
(define NSAccessibilityTimelineSubrole (get-ffi-obj 'NSAccessibilityTimelineSubrole _fw-lib _id))
(define NSAccessibilityTitleAttribute (get-ffi-obj 'NSAccessibilityTitleAttribute _fw-lib _id))
(define NSAccessibilityTitleChangedNotification (get-ffi-obj 'NSAccessibilityTitleChangedNotification _fw-lib _id))
(define NSAccessibilityTitleUIElementAttribute (get-ffi-obj 'NSAccessibilityTitleUIElementAttribute _fw-lib _id))
(define NSAccessibilityToggleSubrole (get-ffi-obj 'NSAccessibilityToggleSubrole _fw-lib _id))
(define NSAccessibilityToolbarButtonAttribute (get-ffi-obj 'NSAccessibilityToolbarButtonAttribute _fw-lib _id))
(define NSAccessibilityToolbarButtonSubrole (get-ffi-obj 'NSAccessibilityToolbarButtonSubrole _fw-lib _id))
(define NSAccessibilityToolbarRole (get-ffi-obj 'NSAccessibilityToolbarRole _fw-lib _id))
(define NSAccessibilityTopLevelUIElementAttribute (get-ffi-obj 'NSAccessibilityTopLevelUIElementAttribute _fw-lib _id))
(define NSAccessibilityUIElementDestroyedNotification (get-ffi-obj 'NSAccessibilityUIElementDestroyedNotification _fw-lib _id))
(define NSAccessibilityUIElementsForSearchPredicateParameterizedAttribute (get-ffi-obj 'NSAccessibilityUIElementsForSearchPredicateParameterizedAttribute _fw-lib _id))
(define NSAccessibilityUIElementsKey (get-ffi-obj 'NSAccessibilityUIElementsKey _fw-lib _id))
(define NSAccessibilityURLAttribute (get-ffi-obj 'NSAccessibilityURLAttribute _fw-lib _id))
(define NSAccessibilityUnderlineColorTextAttribute (get-ffi-obj 'NSAccessibilityUnderlineColorTextAttribute _fw-lib _id))
(define NSAccessibilityUnderlineSearchKey (get-ffi-obj 'NSAccessibilityUnderlineSearchKey _fw-lib _id))
(define NSAccessibilityUnderlineTextAttribute (get-ffi-obj 'NSAccessibilityUnderlineTextAttribute _fw-lib _id))
(define NSAccessibilityUnitDescriptionAttribute (get-ffi-obj 'NSAccessibilityUnitDescriptionAttribute _fw-lib _id))
(define NSAccessibilityUnitsAttribute (get-ffi-obj 'NSAccessibilityUnitsAttribute _fw-lib _id))
(define NSAccessibilityUnitsChangedNotification (get-ffi-obj 'NSAccessibilityUnitsChangedNotification _fw-lib _id))
(define NSAccessibilityUnknownMarkerTypeValue (get-ffi-obj 'NSAccessibilityUnknownMarkerTypeValue _fw-lib _id))
(define NSAccessibilityUnknownOrientationValue (get-ffi-obj 'NSAccessibilityUnknownOrientationValue _fw-lib _id))
(define NSAccessibilityUnknownRole (get-ffi-obj 'NSAccessibilityUnknownRole _fw-lib _id))
(define NSAccessibilityUnknownSortDirectionValue (get-ffi-obj 'NSAccessibilityUnknownSortDirectionValue _fw-lib _id))
(define NSAccessibilityUnknownSubrole (get-ffi-obj 'NSAccessibilityUnknownSubrole _fw-lib _id))
(define NSAccessibilityUnknownUnitValue (get-ffi-obj 'NSAccessibilityUnknownUnitValue _fw-lib _id))
(define NSAccessibilityUnvisitedLinkSearchKey (get-ffi-obj 'NSAccessibilityUnvisitedLinkSearchKey _fw-lib _id))
(define NSAccessibilityValueAttribute (get-ffi-obj 'NSAccessibilityValueAttribute _fw-lib _id))
(define NSAccessibilityValueChangedNotification (get-ffi-obj 'NSAccessibilityValueChangedNotification _fw-lib _id))
(define NSAccessibilityValueDescriptionAttribute (get-ffi-obj 'NSAccessibilityValueDescriptionAttribute _fw-lib _id))
(define NSAccessibilityValueIndicatorRole (get-ffi-obj 'NSAccessibilityValueIndicatorRole _fw-lib _id))
(define NSAccessibilityVerticalOrientationValue (get-ffi-obj 'NSAccessibilityVerticalOrientationValue _fw-lib _id))
(define NSAccessibilityVerticalScrollBarAttribute (get-ffi-obj 'NSAccessibilityVerticalScrollBarAttribute _fw-lib _id))
(define NSAccessibilityVerticalUnitDescriptionAttribute (get-ffi-obj 'NSAccessibilityVerticalUnitDescriptionAttribute _fw-lib _id))
(define NSAccessibilityVerticalUnitsAttribute (get-ffi-obj 'NSAccessibilityVerticalUnitsAttribute _fw-lib _id))
(define NSAccessibilityVisibleCellsAttribute (get-ffi-obj 'NSAccessibilityVisibleCellsAttribute _fw-lib _id))
(define NSAccessibilityVisibleCharacterRangeAttribute (get-ffi-obj 'NSAccessibilityVisibleCharacterRangeAttribute _fw-lib _id))
(define NSAccessibilityVisibleChildrenAttribute (get-ffi-obj 'NSAccessibilityVisibleChildrenAttribute _fw-lib _id))
(define NSAccessibilityVisibleColumnsAttribute (get-ffi-obj 'NSAccessibilityVisibleColumnsAttribute _fw-lib _id))
(define NSAccessibilityVisibleNameKey (get-ffi-obj 'NSAccessibilityVisibleNameKey _fw-lib _id))
(define NSAccessibilityVisibleRowsAttribute (get-ffi-obj 'NSAccessibilityVisibleRowsAttribute _fw-lib _id))
(define NSAccessibilityVisitedAttribute (get-ffi-obj 'NSAccessibilityVisitedAttribute _fw-lib _id))
(define NSAccessibilityVisitedLinkSearchKey (get-ffi-obj 'NSAccessibilityVisitedLinkSearchKey _fw-lib _id))
(define NSAccessibilityWarningValueAttribute (get-ffi-obj 'NSAccessibilityWarningValueAttribute _fw-lib _id))
(define NSAccessibilityWebAreaRole (get-ffi-obj 'NSAccessibilityWebAreaRole _fw-lib _id))
(define NSAccessibilityWindowAttribute (get-ffi-obj 'NSAccessibilityWindowAttribute _fw-lib _id))
(define NSAccessibilityWindowCreatedNotification (get-ffi-obj 'NSAccessibilityWindowCreatedNotification _fw-lib _id))
(define NSAccessibilityWindowDeminiaturizedNotification (get-ffi-obj 'NSAccessibilityWindowDeminiaturizedNotification _fw-lib _id))
(define NSAccessibilityWindowMiniaturizedNotification (get-ffi-obj 'NSAccessibilityWindowMiniaturizedNotification _fw-lib _id))
(define NSAccessibilityWindowMovedNotification (get-ffi-obj 'NSAccessibilityWindowMovedNotification _fw-lib _id))
(define NSAccessibilityWindowResizedNotification (get-ffi-obj 'NSAccessibilityWindowResizedNotification _fw-lib _id))
(define NSAccessibilityWindowRole (get-ffi-obj 'NSAccessibilityWindowRole _fw-lib _id))
(define NSAccessibilityWindowsAttribute (get-ffi-obj 'NSAccessibilityWindowsAttribute _fw-lib _id))
(define NSAccessibilityZoomButtonAttribute (get-ffi-obj 'NSAccessibilityZoomButtonAttribute _fw-lib _id))
(define NSAccessibilityZoomButtonSubrole (get-ffi-obj 'NSAccessibilityZoomButtonSubrole _fw-lib _id))
(define NSAdaptiveImageGlyphAttributeName (get-ffi-obj 'NSAdaptiveImageGlyphAttributeName _fw-lib _id))
(define NSAlignmentBinding (get-ffi-obj 'NSAlignmentBinding _fw-lib _id))
(define NSAllRomanInputSourcesLocaleIdentifier (get-ffi-obj 'NSAllRomanInputSourcesLocaleIdentifier _fw-lib _id))
(define NSAllowsEditingMultipleValuesSelectionBindingOption (get-ffi-obj 'NSAllowsEditingMultipleValuesSelectionBindingOption _fw-lib _id))
(define NSAllowsNullArgumentBindingOption (get-ffi-obj 'NSAllowsNullArgumentBindingOption _fw-lib _id))
(define NSAlternateImageBinding (get-ffi-obj 'NSAlternateImageBinding _fw-lib _id))
(define NSAlternateTitleBinding (get-ffi-obj 'NSAlternateTitleBinding _fw-lib _id))
(define NSAlwaysPresentsApplicationModalAlertsBindingOption (get-ffi-obj 'NSAlwaysPresentsApplicationModalAlertsBindingOption _fw-lib _id))
(define NSAnimateBinding (get-ffi-obj 'NSAnimateBinding _fw-lib _id))
(define NSAnimationDelayBinding (get-ffi-obj 'NSAnimationDelayBinding _fw-lib _id))
(define NSAnimationProgressMark (get-ffi-obj 'NSAnimationProgressMark _fw-lib _id))
(define NSAnimationProgressMarkNotification (get-ffi-obj 'NSAnimationProgressMarkNotification _fw-lib _id))
(define NSAnimationTriggerOrderIn (get-ffi-obj 'NSAnimationTriggerOrderIn _fw-lib _id))
(define NSAnimationTriggerOrderOut (get-ffi-obj 'NSAnimationTriggerOrderOut _fw-lib _id))
(define NSAntialiasThresholdChangedNotification (get-ffi-obj 'NSAntialiasThresholdChangedNotification _fw-lib _id))
(define NSApp (get-ffi-obj 'NSApp _fw-lib _id))
(define NSAppKitIgnoredException (get-ffi-obj 'NSAppKitIgnoredException _fw-lib _id))
(define NSAppKitVersionNumber (get-ffi-obj 'NSAppKitVersionNumber _fw-lib _double))
(define NSAppKitVirtualMemoryException (get-ffi-obj 'NSAppKitVirtualMemoryException _fw-lib _id))
(define NSAppearanceDocumentAttribute (get-ffi-obj 'NSAppearanceDocumentAttribute _fw-lib _id))
(define NSAppearanceNameAccessibilityHighContrastAqua (get-ffi-obj 'NSAppearanceNameAccessibilityHighContrastAqua _fw-lib _id))
(define NSAppearanceNameAccessibilityHighContrastDarkAqua (get-ffi-obj 'NSAppearanceNameAccessibilityHighContrastDarkAqua _fw-lib _id))
(define NSAppearanceNameAccessibilityHighContrastVibrantDark (get-ffi-obj 'NSAppearanceNameAccessibilityHighContrastVibrantDark _fw-lib _id))
(define NSAppearanceNameAccessibilityHighContrastVibrantLight (get-ffi-obj 'NSAppearanceNameAccessibilityHighContrastVibrantLight _fw-lib _id))
(define NSAppearanceNameAqua (get-ffi-obj 'NSAppearanceNameAqua _fw-lib _id))
(define NSAppearanceNameDarkAqua (get-ffi-obj 'NSAppearanceNameDarkAqua _fw-lib _id))
(define NSAppearanceNameLightContent (get-ffi-obj 'NSAppearanceNameLightContent _fw-lib _id))
(define NSAppearanceNameVibrantDark (get-ffi-obj 'NSAppearanceNameVibrantDark _fw-lib _id))
(define NSAppearanceNameVibrantLight (get-ffi-obj 'NSAppearanceNameVibrantLight _fw-lib _id))
(define NSApplicationDidBecomeActiveNotification (get-ffi-obj 'NSApplicationDidBecomeActiveNotification _fw-lib _id))
(define NSApplicationDidChangeOcclusionStateNotification (get-ffi-obj 'NSApplicationDidChangeOcclusionStateNotification _fw-lib _id))
(define NSApplicationDidChangeScreenParametersNotification (get-ffi-obj 'NSApplicationDidChangeScreenParametersNotification _fw-lib _id))
(define NSApplicationDidFinishLaunchingNotification (get-ffi-obj 'NSApplicationDidFinishLaunchingNotification _fw-lib _id))
(define NSApplicationDidFinishRestoringWindowsNotification (get-ffi-obj 'NSApplicationDidFinishRestoringWindowsNotification _fw-lib _id))
(define NSApplicationDidHideNotification (get-ffi-obj 'NSApplicationDidHideNotification _fw-lib _id))
(define NSApplicationDidResignActiveNotification (get-ffi-obj 'NSApplicationDidResignActiveNotification _fw-lib _id))
(define NSApplicationDidUnhideNotification (get-ffi-obj 'NSApplicationDidUnhideNotification _fw-lib _id))
(define NSApplicationDidUpdateNotification (get-ffi-obj 'NSApplicationDidUpdateNotification _fw-lib _id))
(define NSApplicationFileType (get-ffi-obj 'NSApplicationFileType _fw-lib _id))
(define NSApplicationLaunchIsDefaultLaunchKey (get-ffi-obj 'NSApplicationLaunchIsDefaultLaunchKey _fw-lib _id))
(define NSApplicationLaunchRemoteNotificationKey (get-ffi-obj 'NSApplicationLaunchRemoteNotificationKey _fw-lib _id))
(define NSApplicationLaunchUserNotificationKey (get-ffi-obj 'NSApplicationLaunchUserNotificationKey _fw-lib _id))
(define NSApplicationProtectedDataDidBecomeAvailableNotification (get-ffi-obj 'NSApplicationProtectedDataDidBecomeAvailableNotification _fw-lib _id))
(define NSApplicationProtectedDataWillBecomeUnavailableNotification (get-ffi-obj 'NSApplicationProtectedDataWillBecomeUnavailableNotification _fw-lib _id))
(define NSApplicationShouldBeginSuppressingHighDynamicRangeContentNotification (get-ffi-obj 'NSApplicationShouldBeginSuppressingHighDynamicRangeContentNotification _fw-lib _id))
(define NSApplicationShouldEndSuppressingHighDynamicRangeContentNotification (get-ffi-obj 'NSApplicationShouldEndSuppressingHighDynamicRangeContentNotification _fw-lib _id))
(define NSApplicationWillBecomeActiveNotification (get-ffi-obj 'NSApplicationWillBecomeActiveNotification _fw-lib _id))
(define NSApplicationWillFinishLaunchingNotification (get-ffi-obj 'NSApplicationWillFinishLaunchingNotification _fw-lib _id))
(define NSApplicationWillHideNotification (get-ffi-obj 'NSApplicationWillHideNotification _fw-lib _id))
(define NSApplicationWillResignActiveNotification (get-ffi-obj 'NSApplicationWillResignActiveNotification _fw-lib _id))
(define NSApplicationWillTerminateNotification (get-ffi-obj 'NSApplicationWillTerminateNotification _fw-lib _id))
(define NSApplicationWillUnhideNotification (get-ffi-obj 'NSApplicationWillUnhideNotification _fw-lib _id))
(define NSApplicationWillUpdateNotification (get-ffi-obj 'NSApplicationWillUpdateNotification _fw-lib _id))
(define NSArgumentBinding (get-ffi-obj 'NSArgumentBinding _fw-lib _id))
(define NSAttachmentAttributeName (get-ffi-obj 'NSAttachmentAttributeName _fw-lib _id))
(define NSAttributedStringBinding (get-ffi-obj 'NSAttributedStringBinding _fw-lib _id))
(define NSAuthorDocumentAttribute (get-ffi-obj 'NSAuthorDocumentAttribute _fw-lib _id))
(define NSBackgroundColorAttributeName (get-ffi-obj 'NSBackgroundColorAttributeName _fw-lib _id))
(define NSBackgroundColorDocumentAttribute (get-ffi-obj 'NSBackgroundColorDocumentAttribute _fw-lib _id))
(define NSBackingPropertyOldColorSpaceKey (get-ffi-obj 'NSBackingPropertyOldColorSpaceKey _fw-lib _id))
(define NSBackingPropertyOldScaleFactorKey (get-ffi-obj 'NSBackingPropertyOldScaleFactorKey _fw-lib _id))
(define NSBadBitmapParametersException (get-ffi-obj 'NSBadBitmapParametersException _fw-lib _id))
(define NSBadComparisonException (get-ffi-obj 'NSBadComparisonException _fw-lib _id))
(define NSBadRTFColorTableException (get-ffi-obj 'NSBadRTFColorTableException _fw-lib _id))
(define NSBadRTFDirectiveException (get-ffi-obj 'NSBadRTFDirectiveException _fw-lib _id))
(define NSBadRTFFontTableException (get-ffi-obj 'NSBadRTFFontTableException _fw-lib _id))
(define NSBadRTFStyleSheetException (get-ffi-obj 'NSBadRTFStyleSheetException _fw-lib _id))
(define NSBaseURLDocumentOption (get-ffi-obj 'NSBaseURLDocumentOption _fw-lib _id))
(define NSBaselineOffsetAttributeName (get-ffi-obj 'NSBaselineOffsetAttributeName _fw-lib _id))
(define NSBlack (get-ffi-obj 'NSBlack _fw-lib _double))
(define NSBottomMarginDocumentAttribute (get-ffi-obj 'NSBottomMarginDocumentAttribute _fw-lib _id))
(define NSBrowserColumnConfigurationDidChangeNotification (get-ffi-obj 'NSBrowserColumnConfigurationDidChangeNotification _fw-lib _id))
(define NSBrowserIllegalDelegateException (get-ffi-obj 'NSBrowserIllegalDelegateException _fw-lib _id))
(define NSCalibratedBlackColorSpace (get-ffi-obj 'NSCalibratedBlackColorSpace _fw-lib _id))
(define NSCalibratedRGBColorSpace (get-ffi-obj 'NSCalibratedRGBColorSpace _fw-lib _id))
(define NSCalibratedWhiteColorSpace (get-ffi-obj 'NSCalibratedWhiteColorSpace _fw-lib _id))
(define NSCategoryDocumentAttribute (get-ffi-obj 'NSCategoryDocumentAttribute _fw-lib _id))
(define NSCharacterEncodingDocumentAttribute (get-ffi-obj 'NSCharacterEncodingDocumentAttribute _fw-lib _id))
(define NSCharacterEncodingDocumentOption (get-ffi-obj 'NSCharacterEncodingDocumentOption _fw-lib _id))
(define NSCharacterShapeAttributeName (get-ffi-obj 'NSCharacterShapeAttributeName _fw-lib _id))
(define NSCocoaVersionDocumentAttribute (get-ffi-obj 'NSCocoaVersionDocumentAttribute _fw-lib _id))
(define NSCollectionElementKindInterItemGapIndicator (get-ffi-obj 'NSCollectionElementKindInterItemGapIndicator _fw-lib _id))
(define NSCollectionElementKindSectionFooter (get-ffi-obj 'NSCollectionElementKindSectionFooter _fw-lib _id))
(define NSCollectionElementKindSectionHeader (get-ffi-obj 'NSCollectionElementKindSectionHeader _fw-lib _id))
(define NSColorListDidChangeNotification (get-ffi-obj 'NSColorListDidChangeNotification _fw-lib _id))
(define NSColorListIOException (get-ffi-obj 'NSColorListIOException _fw-lib _id))
(define NSColorListNotEditableException (get-ffi-obj 'NSColorListNotEditableException _fw-lib _id))
(define NSColorPanelColorDidChangeNotification (get-ffi-obj 'NSColorPanelColorDidChangeNotification _fw-lib _id))
(define NSColorPboardType (get-ffi-obj 'NSColorPboardType _fw-lib _id))
(define NSComboBoxSelectionDidChangeNotification (get-ffi-obj 'NSComboBoxSelectionDidChangeNotification _fw-lib _id))
(define NSComboBoxSelectionIsChangingNotification (get-ffi-obj 'NSComboBoxSelectionIsChangingNotification _fw-lib _id))
(define NSComboBoxWillDismissNotification (get-ffi-obj 'NSComboBoxWillDismissNotification _fw-lib _id))
(define NSComboBoxWillPopUpNotification (get-ffi-obj 'NSComboBoxWillPopUpNotification _fw-lib _id))
(define NSCommentDocumentAttribute (get-ffi-obj 'NSCommentDocumentAttribute _fw-lib _id))
(define NSCompanyDocumentAttribute (get-ffi-obj 'NSCompanyDocumentAttribute _fw-lib _id))
(define NSConditionallySetsEditableBindingOption (get-ffi-obj 'NSConditionallySetsEditableBindingOption _fw-lib _id))
(define NSConditionallySetsEnabledBindingOption (get-ffi-obj 'NSConditionallySetsEnabledBindingOption _fw-lib _id))
(define NSConditionallySetsHiddenBindingOption (get-ffi-obj 'NSConditionallySetsHiddenBindingOption _fw-lib _id))
(define NSContentArrayBinding (get-ffi-obj 'NSContentArrayBinding _fw-lib _id))
(define NSContentArrayForMultipleSelectionBinding (get-ffi-obj 'NSContentArrayForMultipleSelectionBinding _fw-lib _id))
(define NSContentBinding (get-ffi-obj 'NSContentBinding _fw-lib _id))
(define NSContentDictionaryBinding (get-ffi-obj 'NSContentDictionaryBinding _fw-lib _id))
(define NSContentHeightBinding (get-ffi-obj 'NSContentHeightBinding _fw-lib _id))
(define NSContentObjectBinding (get-ffi-obj 'NSContentObjectBinding _fw-lib _id))
(define NSContentObjectsBinding (get-ffi-obj 'NSContentObjectsBinding _fw-lib _id))
(define NSContentPlacementTagBindingOption (get-ffi-obj 'NSContentPlacementTagBindingOption _fw-lib _id))
(define NSContentSetBinding (get-ffi-obj 'NSContentSetBinding _fw-lib _id))
(define NSContentValuesBinding (get-ffi-obj 'NSContentValuesBinding _fw-lib _id))
(define NSContentWidthBinding (get-ffi-obj 'NSContentWidthBinding _fw-lib _id))
(define NSContextHelpModeDidActivateNotification (get-ffi-obj 'NSContextHelpModeDidActivateNotification _fw-lib _id))
(define NSContextHelpModeDidDeactivateNotification (get-ffi-obj 'NSContextHelpModeDidDeactivateNotification _fw-lib _id))
(define NSContinuouslyUpdatesValueBindingOption (get-ffi-obj 'NSContinuouslyUpdatesValueBindingOption _fw-lib _id))
(define NSControlTextDidBeginEditingNotification (get-ffi-obj 'NSControlTextDidBeginEditingNotification _fw-lib _id))
(define NSControlTextDidChangeNotification (get-ffi-obj 'NSControlTextDidChangeNotification _fw-lib _id))
(define NSControlTextDidEndEditingNotification (get-ffi-obj 'NSControlTextDidEndEditingNotification _fw-lib _id))
(define NSControlTintDidChangeNotification (get-ffi-obj 'NSControlTintDidChangeNotification _fw-lib _id))
(define NSConvertedDocumentAttribute (get-ffi-obj 'NSConvertedDocumentAttribute _fw-lib _id))
(define NSCopyrightDocumentAttribute (get-ffi-obj 'NSCopyrightDocumentAttribute _fw-lib _id))
(define NSCreatesSortDescriptorBindingOption (get-ffi-obj 'NSCreatesSortDescriptorBindingOption _fw-lib _id))
(define NSCreationTimeDocumentAttribute (get-ffi-obj 'NSCreationTimeDocumentAttribute _fw-lib _id))
(define NSCriticalValueBinding (get-ffi-obj 'NSCriticalValueBinding _fw-lib _id))
(define NSCursorAttributeName (get-ffi-obj 'NSCursorAttributeName _fw-lib _id))
(define NSCustomColorSpace (get-ffi-obj 'NSCustomColorSpace _fw-lib _id))
(define NSDarkGray (get-ffi-obj 'NSDarkGray _fw-lib _double))
(define NSDataBinding (get-ffi-obj 'NSDataBinding _fw-lib _id))
(define NSDefaultAttributesDocumentAttribute (get-ffi-obj 'NSDefaultAttributesDocumentAttribute _fw-lib _id))
(define NSDefaultAttributesDocumentOption (get-ffi-obj 'NSDefaultAttributesDocumentOption _fw-lib _id))
(define NSDefaultFontExcludedDocumentAttribute (get-ffi-obj 'NSDefaultFontExcludedDocumentAttribute _fw-lib _id))
(define NSDefaultTabIntervalDocumentAttribute (get-ffi-obj 'NSDefaultTabIntervalDocumentAttribute _fw-lib _id))
(define NSDefinitionPresentationTypeDictionaryApplication (get-ffi-obj 'NSDefinitionPresentationTypeDictionaryApplication _fw-lib _id))
(define NSDefinitionPresentationTypeKey (get-ffi-obj 'NSDefinitionPresentationTypeKey _fw-lib _id))
(define NSDefinitionPresentationTypeOverlay (get-ffi-obj 'NSDefinitionPresentationTypeOverlay _fw-lib _id))
(define NSDeletesObjectsOnRemoveBindingsOption (get-ffi-obj 'NSDeletesObjectsOnRemoveBindingsOption _fw-lib _id))
(define NSDeviceBitsPerSample (get-ffi-obj 'NSDeviceBitsPerSample _fw-lib _id))
(define NSDeviceBlackColorSpace (get-ffi-obj 'NSDeviceBlackColorSpace _fw-lib _id))
(define NSDeviceCMYKColorSpace (get-ffi-obj 'NSDeviceCMYKColorSpace _fw-lib _id))
(define NSDeviceColorSpaceName (get-ffi-obj 'NSDeviceColorSpaceName _fw-lib _id))
(define NSDeviceIsPrinter (get-ffi-obj 'NSDeviceIsPrinter _fw-lib _id))
(define NSDeviceIsScreen (get-ffi-obj 'NSDeviceIsScreen _fw-lib _id))
(define NSDeviceRGBColorSpace (get-ffi-obj 'NSDeviceRGBColorSpace _fw-lib _id))
(define NSDeviceResolution (get-ffi-obj 'NSDeviceResolution _fw-lib _id))
(define NSDeviceSize (get-ffi-obj 'NSDeviceSize _fw-lib _id))
(define NSDeviceWhiteColorSpace (get-ffi-obj 'NSDeviceWhiteColorSpace _fw-lib _id))
(define NSDirectionalEdgeInsetsZero (ffi-obj-ref 'NSDirectionalEdgeInsetsZero _fw-lib))
(define NSDirectoryFileType (get-ffi-obj 'NSDirectoryFileType _fw-lib _id))
(define NSDisplayNameBindingOption (get-ffi-obj 'NSDisplayNameBindingOption _fw-lib _id))
(define NSDisplayPatternBindingOption (get-ffi-obj 'NSDisplayPatternBindingOption _fw-lib _id))
(define NSDisplayPatternTitleBinding (get-ffi-obj 'NSDisplayPatternTitleBinding _fw-lib _id))
(define NSDisplayPatternValueBinding (get-ffi-obj 'NSDisplayPatternValueBinding _fw-lib _id))
(define NSDocFormatTextDocumentType (get-ffi-obj 'NSDocFormatTextDocumentType _fw-lib _id))
(define NSDocumentEditedBinding (get-ffi-obj 'NSDocumentEditedBinding _fw-lib _id))
(define NSDocumentTypeDocumentAttribute (get-ffi-obj 'NSDocumentTypeDocumentAttribute _fw-lib _id))
(define NSDocumentTypeDocumentOption (get-ffi-obj 'NSDocumentTypeDocumentOption _fw-lib _id))
(define NSDoubleClickArgumentBinding (get-ffi-obj 'NSDoubleClickArgumentBinding _fw-lib _id))
(define NSDoubleClickTargetBinding (get-ffi-obj 'NSDoubleClickTargetBinding _fw-lib _id))
(define NSDragPboard (get-ffi-obj 'NSDragPboard _fw-lib _id))
(define NSDraggingException (get-ffi-obj 'NSDraggingException _fw-lib _id))
(define NSDraggingImageComponentIconKey (get-ffi-obj 'NSDraggingImageComponentIconKey _fw-lib _id))
(define NSDraggingImageComponentLabelKey (get-ffi-obj 'NSDraggingImageComponentLabelKey _fw-lib _id))
(define NSDrawerDidCloseNotification (get-ffi-obj 'NSDrawerDidCloseNotification _fw-lib _id))
(define NSDrawerDidOpenNotification (get-ffi-obj 'NSDrawerDidOpenNotification _fw-lib _id))
(define NSDrawerWillCloseNotification (get-ffi-obj 'NSDrawerWillCloseNotification _fw-lib _id))
(define NSDrawerWillOpenNotification (get-ffi-obj 'NSDrawerWillOpenNotification _fw-lib _id))
(define NSEditableBinding (get-ffi-obj 'NSEditableBinding _fw-lib _id))
(define NSEditorDocumentAttribute (get-ffi-obj 'NSEditorDocumentAttribute _fw-lib _id))
(define NSEnabledBinding (get-ffi-obj 'NSEnabledBinding _fw-lib _id))
(define NSEventTrackingRunLoopMode (get-ffi-obj 'NSEventTrackingRunLoopMode _fw-lib _id))
(define NSExcludedElementsDocumentAttribute (get-ffi-obj 'NSExcludedElementsDocumentAttribute _fw-lib _id))
(define NSExcludedKeysBinding (get-ffi-obj 'NSExcludedKeysBinding _fw-lib _id))
(define NSExpansionAttributeName (get-ffi-obj 'NSExpansionAttributeName _fw-lib _id))
(define NSFileContentsPboardType (get-ffi-obj 'NSFileContentsPboardType _fw-lib _id))
(define NSFileTypeDocumentAttribute (get-ffi-obj 'NSFileTypeDocumentAttribute _fw-lib _id))
(define NSFileTypeDocumentOption (get-ffi-obj 'NSFileTypeDocumentOption _fw-lib _id))
(define NSFilenamesPboardType (get-ffi-obj 'NSFilenamesPboardType _fw-lib _id))
(define NSFilesPromisePboardType (get-ffi-obj 'NSFilesPromisePboardType _fw-lib _id))
(define NSFilesystemFileType (get-ffi-obj 'NSFilesystemFileType _fw-lib _id))
(define NSFilterPredicateBinding (get-ffi-obj 'NSFilterPredicateBinding _fw-lib _id))
(define NSFindPanelCaseInsensitiveSearch (get-ffi-obj 'NSFindPanelCaseInsensitiveSearch _fw-lib _id))
(define NSFindPanelSearchOptionsPboardType (get-ffi-obj 'NSFindPanelSearchOptionsPboardType _fw-lib _id))
(define NSFindPanelSubstringMatch (get-ffi-obj 'NSFindPanelSubstringMatch _fw-lib _id))
(define NSFindPboard (get-ffi-obj 'NSFindPboard _fw-lib _id))
(define NSFontAttributeName (get-ffi-obj 'NSFontAttributeName _fw-lib _id))
(define NSFontBinding (get-ffi-obj 'NSFontBinding _fw-lib _id))
(define NSFontBoldBinding (get-ffi-obj 'NSFontBoldBinding _fw-lib _id))
(define NSFontCascadeListAttribute (get-ffi-obj 'NSFontCascadeListAttribute _fw-lib _id))
(define NSFontCharacterSetAttribute (get-ffi-obj 'NSFontCharacterSetAttribute _fw-lib _id))
(define NSFontCollectionActionKey (get-ffi-obj 'NSFontCollectionActionKey _fw-lib _id))
(define NSFontCollectionAllFonts (get-ffi-obj 'NSFontCollectionAllFonts _fw-lib _id))
(define NSFontCollectionDidChangeNotification (get-ffi-obj 'NSFontCollectionDidChangeNotification _fw-lib _id))
(define NSFontCollectionDisallowAutoActivationOption (get-ffi-obj 'NSFontCollectionDisallowAutoActivationOption _fw-lib _id))
(define NSFontCollectionFavorites (get-ffi-obj 'NSFontCollectionFavorites _fw-lib _id))
(define NSFontCollectionIncludeDisabledFontsOption (get-ffi-obj 'NSFontCollectionIncludeDisabledFontsOption _fw-lib _id))
(define NSFontCollectionNameKey (get-ffi-obj 'NSFontCollectionNameKey _fw-lib _id))
(define NSFontCollectionOldNameKey (get-ffi-obj 'NSFontCollectionOldNameKey _fw-lib _id))
(define NSFontCollectionRecentlyUsed (get-ffi-obj 'NSFontCollectionRecentlyUsed _fw-lib _id))
(define NSFontCollectionRemoveDuplicatesOption (get-ffi-obj 'NSFontCollectionRemoveDuplicatesOption _fw-lib _id))
(define NSFontCollectionUser (get-ffi-obj 'NSFontCollectionUser _fw-lib _id))
(define NSFontCollectionVisibilityKey (get-ffi-obj 'NSFontCollectionVisibilityKey _fw-lib _id))
(define NSFontCollectionWasHidden (get-ffi-obj 'NSFontCollectionWasHidden _fw-lib _id))
(define NSFontCollectionWasRenamed (get-ffi-obj 'NSFontCollectionWasRenamed _fw-lib _id))
(define NSFontCollectionWasShown (get-ffi-obj 'NSFontCollectionWasShown _fw-lib _id))
(define NSFontColorAttribute (get-ffi-obj 'NSFontColorAttribute _fw-lib _id))
(define NSFontDescriptorSystemDesignDefault (get-ffi-obj 'NSFontDescriptorSystemDesignDefault _fw-lib _id))
(define NSFontDescriptorSystemDesignMonospaced (get-ffi-obj 'NSFontDescriptorSystemDesignMonospaced _fw-lib _id))
(define NSFontDescriptorSystemDesignRounded (get-ffi-obj 'NSFontDescriptorSystemDesignRounded _fw-lib _id))
(define NSFontDescriptorSystemDesignSerif (get-ffi-obj 'NSFontDescriptorSystemDesignSerif _fw-lib _id))
(define NSFontFaceAttribute (get-ffi-obj 'NSFontFaceAttribute _fw-lib _id))
(define NSFontFamilyAttribute (get-ffi-obj 'NSFontFamilyAttribute _fw-lib _id))
(define NSFontFamilyNameBinding (get-ffi-obj 'NSFontFamilyNameBinding _fw-lib _id))
(define NSFontFeatureSelectorIdentifierKey (get-ffi-obj 'NSFontFeatureSelectorIdentifierKey _fw-lib _id))
(define NSFontFeatureSettingsAttribute (get-ffi-obj 'NSFontFeatureSettingsAttribute _fw-lib _id))
(define NSFontFeatureTypeIdentifierKey (get-ffi-obj 'NSFontFeatureTypeIdentifierKey _fw-lib _id))
(define NSFontFixedAdvanceAttribute (get-ffi-obj 'NSFontFixedAdvanceAttribute _fw-lib _id))
(define NSFontIdentityMatrix (get-ffi-obj 'NSFontIdentityMatrix _fw-lib _pointer))
(define NSFontItalicBinding (get-ffi-obj 'NSFontItalicBinding _fw-lib _id))
(define NSFontMatrixAttribute (get-ffi-obj 'NSFontMatrixAttribute _fw-lib _id))
(define NSFontNameAttribute (get-ffi-obj 'NSFontNameAttribute _fw-lib _id))
(define NSFontNameBinding (get-ffi-obj 'NSFontNameBinding _fw-lib _id))
(define NSFontPboard (get-ffi-obj 'NSFontPboard _fw-lib _id))
(define NSFontPboardType (get-ffi-obj 'NSFontPboardType _fw-lib _id))
(define NSFontSetChangedNotification (get-ffi-obj 'NSFontSetChangedNotification _fw-lib _id))
(define NSFontSizeAttribute (get-ffi-obj 'NSFontSizeAttribute _fw-lib _id))
(define NSFontSizeBinding (get-ffi-obj 'NSFontSizeBinding _fw-lib _id))
(define NSFontSlantTrait (get-ffi-obj 'NSFontSlantTrait _fw-lib _id))
(define NSFontSymbolicTrait (get-ffi-obj 'NSFontSymbolicTrait _fw-lib _id))
(define NSFontTextStyleBody (get-ffi-obj 'NSFontTextStyleBody _fw-lib _id))
(define NSFontTextStyleCallout (get-ffi-obj 'NSFontTextStyleCallout _fw-lib _id))
(define NSFontTextStyleCaption1 (get-ffi-obj 'NSFontTextStyleCaption1 _fw-lib _id))
(define NSFontTextStyleCaption2 (get-ffi-obj 'NSFontTextStyleCaption2 _fw-lib _id))
(define NSFontTextStyleFootnote (get-ffi-obj 'NSFontTextStyleFootnote _fw-lib _id))
(define NSFontTextStyleHeadline (get-ffi-obj 'NSFontTextStyleHeadline _fw-lib _id))
(define NSFontTextStyleLargeTitle (get-ffi-obj 'NSFontTextStyleLargeTitle _fw-lib _id))
(define NSFontTextStyleSubheadline (get-ffi-obj 'NSFontTextStyleSubheadline _fw-lib _id))
(define NSFontTextStyleTitle1 (get-ffi-obj 'NSFontTextStyleTitle1 _fw-lib _id))
(define NSFontTextStyleTitle2 (get-ffi-obj 'NSFontTextStyleTitle2 _fw-lib _id))
(define NSFontTextStyleTitle3 (get-ffi-obj 'NSFontTextStyleTitle3 _fw-lib _id))
(define NSFontTraitsAttribute (get-ffi-obj 'NSFontTraitsAttribute _fw-lib _id))
(define NSFontUnavailableException (get-ffi-obj 'NSFontUnavailableException _fw-lib _id))
(define NSFontVariationAttribute (get-ffi-obj 'NSFontVariationAttribute _fw-lib _id))
(define NSFontVariationAxisDefaultValueKey (get-ffi-obj 'NSFontVariationAxisDefaultValueKey _fw-lib _id))
(define NSFontVariationAxisIdentifierKey (get-ffi-obj 'NSFontVariationAxisIdentifierKey _fw-lib _id))
(define NSFontVariationAxisMaximumValueKey (get-ffi-obj 'NSFontVariationAxisMaximumValueKey _fw-lib _id))
(define NSFontVariationAxisMinimumValueKey (get-ffi-obj 'NSFontVariationAxisMinimumValueKey _fw-lib _id))
(define NSFontVariationAxisNameKey (get-ffi-obj 'NSFontVariationAxisNameKey _fw-lib _id))
(define NSFontVisibleNameAttribute (get-ffi-obj 'NSFontVisibleNameAttribute _fw-lib _id))
(define NSFontWeightBlack (get-ffi-obj 'NSFontWeightBlack _fw-lib _double))
(define NSFontWeightBold (get-ffi-obj 'NSFontWeightBold _fw-lib _double))
(define NSFontWeightHeavy (get-ffi-obj 'NSFontWeightHeavy _fw-lib _double))
(define NSFontWeightLight (get-ffi-obj 'NSFontWeightLight _fw-lib _double))
(define NSFontWeightMedium (get-ffi-obj 'NSFontWeightMedium _fw-lib _double))
(define NSFontWeightRegular (get-ffi-obj 'NSFontWeightRegular _fw-lib _double))
(define NSFontWeightSemibold (get-ffi-obj 'NSFontWeightSemibold _fw-lib _double))
(define NSFontWeightThin (get-ffi-obj 'NSFontWeightThin _fw-lib _double))
(define NSFontWeightTrait (get-ffi-obj 'NSFontWeightTrait _fw-lib _id))
(define NSFontWeightUltraLight (get-ffi-obj 'NSFontWeightUltraLight _fw-lib _double))
(define NSFontWidthCompressed (get-ffi-obj 'NSFontWidthCompressed _fw-lib _double))
(define NSFontWidthCondensed (get-ffi-obj 'NSFontWidthCondensed _fw-lib _double))
(define NSFontWidthExpanded (get-ffi-obj 'NSFontWidthExpanded _fw-lib _double))
(define NSFontWidthStandard (get-ffi-obj 'NSFontWidthStandard _fw-lib _double))
(define NSFontWidthTrait (get-ffi-obj 'NSFontWidthTrait _fw-lib _id))
(define NSForegroundColorAttributeName (get-ffi-obj 'NSForegroundColorAttributeName _fw-lib _id))
(define NSFullScreenModeAllScreens (get-ffi-obj 'NSFullScreenModeAllScreens _fw-lib _id))
(define NSFullScreenModeApplicationPresentationOptions (get-ffi-obj 'NSFullScreenModeApplicationPresentationOptions _fw-lib _id))
(define NSFullScreenModeSetting (get-ffi-obj 'NSFullScreenModeSetting _fw-lib _id))
(define NSFullScreenModeWindowLevel (get-ffi-obj 'NSFullScreenModeWindowLevel _fw-lib _id))
(define NSGeneralPboard (get-ffi-obj 'NSGeneralPboard _fw-lib _id))
(define NSGlyphInfoAttributeName (get-ffi-obj 'NSGlyphInfoAttributeName _fw-lib _id))
(define NSGraphicsContextDestinationAttributeName (get-ffi-obj 'NSGraphicsContextDestinationAttributeName _fw-lib _id))
(define NSGraphicsContextPDFFormat (get-ffi-obj 'NSGraphicsContextPDFFormat _fw-lib _id))
(define NSGraphicsContextPSFormat (get-ffi-obj 'NSGraphicsContextPSFormat _fw-lib _id))
(define NSGraphicsContextRepresentationFormatAttributeName (get-ffi-obj 'NSGraphicsContextRepresentationFormatAttributeName _fw-lib _id))
(define NSGridViewSizeForContent (get-ffi-obj 'NSGridViewSizeForContent _fw-lib _double))
(define NSHTMLPboardType (get-ffi-obj 'NSHTMLPboardType _fw-lib _id))
(define NSHTMLTextDocumentType (get-ffi-obj 'NSHTMLTextDocumentType _fw-lib _id))
(define NSHandlesContentAsCompoundValueBindingOption (get-ffi-obj 'NSHandlesContentAsCompoundValueBindingOption _fw-lib _id))
(define NSHeaderTitleBinding (get-ffi-obj 'NSHeaderTitleBinding _fw-lib _id))
(define NSHiddenBinding (get-ffi-obj 'NSHiddenBinding _fw-lib _id))
(define NSHyphenationFactorDocumentAttribute (get-ffi-obj 'NSHyphenationFactorDocumentAttribute _fw-lib _id))
(define NSIllegalSelectorException (get-ffi-obj 'NSIllegalSelectorException _fw-lib _id))
(define NSImageBinding (get-ffi-obj 'NSImageBinding _fw-lib _id))
(define NSImageCacheException (get-ffi-obj 'NSImageCacheException _fw-lib _id))
(define NSImageColorSyncProfileData (get-ffi-obj 'NSImageColorSyncProfileData _fw-lib _id))
(define NSImageCompressionFactor (get-ffi-obj 'NSImageCompressionFactor _fw-lib _id))
(define NSImageCompressionMethod (get-ffi-obj 'NSImageCompressionMethod _fw-lib _id))
(define NSImageCurrentFrame (get-ffi-obj 'NSImageCurrentFrame _fw-lib _id))
(define NSImageCurrentFrameDuration (get-ffi-obj 'NSImageCurrentFrameDuration _fw-lib _id))
(define NSImageDitherTransparency (get-ffi-obj 'NSImageDitherTransparency _fw-lib _id))
(define NSImageEXIFData (get-ffi-obj 'NSImageEXIFData _fw-lib _id))
(define NSImageFallbackBackgroundColor (get-ffi-obj 'NSImageFallbackBackgroundColor _fw-lib _id))
(define NSImageFrameCount (get-ffi-obj 'NSImageFrameCount _fw-lib _id))
(define NSImageGamma (get-ffi-obj 'NSImageGamma _fw-lib _id))
(define NSImageHintCTM (get-ffi-obj 'NSImageHintCTM _fw-lib _id))
(define NSImageHintInterpolation (get-ffi-obj 'NSImageHintInterpolation _fw-lib _id))
(define NSImageHintUserInterfaceLayoutDirection (get-ffi-obj 'NSImageHintUserInterfaceLayoutDirection _fw-lib _id))
(define NSImageIPTCData (get-ffi-obj 'NSImageIPTCData _fw-lib _id))
(define NSImageInterlaced (get-ffi-obj 'NSImageInterlaced _fw-lib _id))
(define NSImageLoopCount (get-ffi-obj 'NSImageLoopCount _fw-lib _id))
(define NSImageNameActionTemplate (get-ffi-obj 'NSImageNameActionTemplate _fw-lib _id))
(define NSImageNameAddTemplate (get-ffi-obj 'NSImageNameAddTemplate _fw-lib _id))
(define NSImageNameAdvanced (get-ffi-obj 'NSImageNameAdvanced _fw-lib _id))
(define NSImageNameApplicationIcon (get-ffi-obj 'NSImageNameApplicationIcon _fw-lib _id))
(define NSImageNameBluetoothTemplate (get-ffi-obj 'NSImageNameBluetoothTemplate _fw-lib _id))
(define NSImageNameBonjour (get-ffi-obj 'NSImageNameBonjour _fw-lib _id))
(define NSImageNameBookmarksTemplate (get-ffi-obj 'NSImageNameBookmarksTemplate _fw-lib _id))
(define NSImageNameCaution (get-ffi-obj 'NSImageNameCaution _fw-lib _id))
(define NSImageNameColorPanel (get-ffi-obj 'NSImageNameColorPanel _fw-lib _id))
(define NSImageNameColumnViewTemplate (get-ffi-obj 'NSImageNameColumnViewTemplate _fw-lib _id))
(define NSImageNameComputer (get-ffi-obj 'NSImageNameComputer _fw-lib _id))
(define NSImageNameDotMac (get-ffi-obj 'NSImageNameDotMac _fw-lib _id))
(define NSImageNameEnterFullScreenTemplate (get-ffi-obj 'NSImageNameEnterFullScreenTemplate _fw-lib _id))
(define NSImageNameEveryone (get-ffi-obj 'NSImageNameEveryone _fw-lib _id))
(define NSImageNameExitFullScreenTemplate (get-ffi-obj 'NSImageNameExitFullScreenTemplate _fw-lib _id))
(define NSImageNameFlowViewTemplate (get-ffi-obj 'NSImageNameFlowViewTemplate _fw-lib _id))
(define NSImageNameFolder (get-ffi-obj 'NSImageNameFolder _fw-lib _id))
(define NSImageNameFolderBurnable (get-ffi-obj 'NSImageNameFolderBurnable _fw-lib _id))
(define NSImageNameFolderSmart (get-ffi-obj 'NSImageNameFolderSmart _fw-lib _id))
(define NSImageNameFollowLinkFreestandingTemplate (get-ffi-obj 'NSImageNameFollowLinkFreestandingTemplate _fw-lib _id))
(define NSImageNameFontPanel (get-ffi-obj 'NSImageNameFontPanel _fw-lib _id))
(define NSImageNameGoBackTemplate (get-ffi-obj 'NSImageNameGoBackTemplate _fw-lib _id))
(define NSImageNameGoForwardTemplate (get-ffi-obj 'NSImageNameGoForwardTemplate _fw-lib _id))
(define NSImageNameGoLeftTemplate (get-ffi-obj 'NSImageNameGoLeftTemplate _fw-lib _id))
(define NSImageNameGoRightTemplate (get-ffi-obj 'NSImageNameGoRightTemplate _fw-lib _id))
(define NSImageNameHomeTemplate (get-ffi-obj 'NSImageNameHomeTemplate _fw-lib _id))
(define NSImageNameIChatTheaterTemplate (get-ffi-obj 'NSImageNameIChatTheaterTemplate _fw-lib _id))
(define NSImageNameIconViewTemplate (get-ffi-obj 'NSImageNameIconViewTemplate _fw-lib _id))
(define NSImageNameInfo (get-ffi-obj 'NSImageNameInfo _fw-lib _id))
(define NSImageNameInvalidDataFreestandingTemplate (get-ffi-obj 'NSImageNameInvalidDataFreestandingTemplate _fw-lib _id))
(define NSImageNameLeftFacingTriangleTemplate (get-ffi-obj 'NSImageNameLeftFacingTriangleTemplate _fw-lib _id))
(define NSImageNameListViewTemplate (get-ffi-obj 'NSImageNameListViewTemplate _fw-lib _id))
(define NSImageNameLockLockedTemplate (get-ffi-obj 'NSImageNameLockLockedTemplate _fw-lib _id))
(define NSImageNameLockUnlockedTemplate (get-ffi-obj 'NSImageNameLockUnlockedTemplate _fw-lib _id))
(define NSImageNameMenuMixedStateTemplate (get-ffi-obj 'NSImageNameMenuMixedStateTemplate _fw-lib _id))
(define NSImageNameMenuOnStateTemplate (get-ffi-obj 'NSImageNameMenuOnStateTemplate _fw-lib _id))
(define NSImageNameMobileMe (get-ffi-obj 'NSImageNameMobileMe _fw-lib _id))
(define NSImageNameMultipleDocuments (get-ffi-obj 'NSImageNameMultipleDocuments _fw-lib _id))
(define NSImageNameNetwork (get-ffi-obj 'NSImageNameNetwork _fw-lib _id))
(define NSImageNamePathTemplate (get-ffi-obj 'NSImageNamePathTemplate _fw-lib _id))
(define NSImageNamePreferencesGeneral (get-ffi-obj 'NSImageNamePreferencesGeneral _fw-lib _id))
(define NSImageNameQuickLookTemplate (get-ffi-obj 'NSImageNameQuickLookTemplate _fw-lib _id))
(define NSImageNameRefreshFreestandingTemplate (get-ffi-obj 'NSImageNameRefreshFreestandingTemplate _fw-lib _id))
(define NSImageNameRefreshTemplate (get-ffi-obj 'NSImageNameRefreshTemplate _fw-lib _id))
(define NSImageNameRemoveTemplate (get-ffi-obj 'NSImageNameRemoveTemplate _fw-lib _id))
(define NSImageNameRevealFreestandingTemplate (get-ffi-obj 'NSImageNameRevealFreestandingTemplate _fw-lib _id))
(define NSImageNameRightFacingTriangleTemplate (get-ffi-obj 'NSImageNameRightFacingTriangleTemplate _fw-lib _id))
(define NSImageNameShareTemplate (get-ffi-obj 'NSImageNameShareTemplate _fw-lib _id))
(define NSImageNameSlideshowTemplate (get-ffi-obj 'NSImageNameSlideshowTemplate _fw-lib _id))
(define NSImageNameSmartBadgeTemplate (get-ffi-obj 'NSImageNameSmartBadgeTemplate _fw-lib _id))
(define NSImageNameStatusAvailable (get-ffi-obj 'NSImageNameStatusAvailable _fw-lib _id))
(define NSImageNameStatusNone (get-ffi-obj 'NSImageNameStatusNone _fw-lib _id))
(define NSImageNameStatusPartiallyAvailable (get-ffi-obj 'NSImageNameStatusPartiallyAvailable _fw-lib _id))
(define NSImageNameStatusUnavailable (get-ffi-obj 'NSImageNameStatusUnavailable _fw-lib _id))
(define NSImageNameStopProgressFreestandingTemplate (get-ffi-obj 'NSImageNameStopProgressFreestandingTemplate _fw-lib _id))
(define NSImageNameStopProgressTemplate (get-ffi-obj 'NSImageNameStopProgressTemplate _fw-lib _id))
(define NSImageNameTouchBarAddDetailTemplate (get-ffi-obj 'NSImageNameTouchBarAddDetailTemplate _fw-lib _id))
(define NSImageNameTouchBarAddTemplate (get-ffi-obj 'NSImageNameTouchBarAddTemplate _fw-lib _id))
(define NSImageNameTouchBarAlarmTemplate (get-ffi-obj 'NSImageNameTouchBarAlarmTemplate _fw-lib _id))
(define NSImageNameTouchBarAudioInputMuteTemplate (get-ffi-obj 'NSImageNameTouchBarAudioInputMuteTemplate _fw-lib _id))
(define NSImageNameTouchBarAudioInputTemplate (get-ffi-obj 'NSImageNameTouchBarAudioInputTemplate _fw-lib _id))
(define NSImageNameTouchBarAudioOutputMuteTemplate (get-ffi-obj 'NSImageNameTouchBarAudioOutputMuteTemplate _fw-lib _id))
(define NSImageNameTouchBarAudioOutputVolumeHighTemplate (get-ffi-obj 'NSImageNameTouchBarAudioOutputVolumeHighTemplate _fw-lib _id))
(define NSImageNameTouchBarAudioOutputVolumeLowTemplate (get-ffi-obj 'NSImageNameTouchBarAudioOutputVolumeLowTemplate _fw-lib _id))
(define NSImageNameTouchBarAudioOutputVolumeMediumTemplate (get-ffi-obj 'NSImageNameTouchBarAudioOutputVolumeMediumTemplate _fw-lib _id))
(define NSImageNameTouchBarAudioOutputVolumeOffTemplate (get-ffi-obj 'NSImageNameTouchBarAudioOutputVolumeOffTemplate _fw-lib _id))
(define NSImageNameTouchBarBookmarksTemplate (get-ffi-obj 'NSImageNameTouchBarBookmarksTemplate _fw-lib _id))
(define NSImageNameTouchBarColorPickerFill (get-ffi-obj 'NSImageNameTouchBarColorPickerFill _fw-lib _id))
(define NSImageNameTouchBarColorPickerFont (get-ffi-obj 'NSImageNameTouchBarColorPickerFont _fw-lib _id))
(define NSImageNameTouchBarColorPickerStroke (get-ffi-obj 'NSImageNameTouchBarColorPickerStroke _fw-lib _id))
(define NSImageNameTouchBarCommunicationAudioTemplate (get-ffi-obj 'NSImageNameTouchBarCommunicationAudioTemplate _fw-lib _id))
(define NSImageNameTouchBarCommunicationVideoTemplate (get-ffi-obj 'NSImageNameTouchBarCommunicationVideoTemplate _fw-lib _id))
(define NSImageNameTouchBarComposeTemplate (get-ffi-obj 'NSImageNameTouchBarComposeTemplate _fw-lib _id))
(define NSImageNameTouchBarDeleteTemplate (get-ffi-obj 'NSImageNameTouchBarDeleteTemplate _fw-lib _id))
(define NSImageNameTouchBarDownloadTemplate (get-ffi-obj 'NSImageNameTouchBarDownloadTemplate _fw-lib _id))
(define NSImageNameTouchBarEnterFullScreenTemplate (get-ffi-obj 'NSImageNameTouchBarEnterFullScreenTemplate _fw-lib _id))
(define NSImageNameTouchBarExitFullScreenTemplate (get-ffi-obj 'NSImageNameTouchBarExitFullScreenTemplate _fw-lib _id))
(define NSImageNameTouchBarFastForwardTemplate (get-ffi-obj 'NSImageNameTouchBarFastForwardTemplate _fw-lib _id))
(define NSImageNameTouchBarFolderCopyToTemplate (get-ffi-obj 'NSImageNameTouchBarFolderCopyToTemplate _fw-lib _id))
(define NSImageNameTouchBarFolderMoveToTemplate (get-ffi-obj 'NSImageNameTouchBarFolderMoveToTemplate _fw-lib _id))
(define NSImageNameTouchBarFolderTemplate (get-ffi-obj 'NSImageNameTouchBarFolderTemplate _fw-lib _id))
(define NSImageNameTouchBarGetInfoTemplate (get-ffi-obj 'NSImageNameTouchBarGetInfoTemplate _fw-lib _id))
(define NSImageNameTouchBarGoBackTemplate (get-ffi-obj 'NSImageNameTouchBarGoBackTemplate _fw-lib _id))
(define NSImageNameTouchBarGoDownTemplate (get-ffi-obj 'NSImageNameTouchBarGoDownTemplate _fw-lib _id))
(define NSImageNameTouchBarGoForwardTemplate (get-ffi-obj 'NSImageNameTouchBarGoForwardTemplate _fw-lib _id))
(define NSImageNameTouchBarGoUpTemplate (get-ffi-obj 'NSImageNameTouchBarGoUpTemplate _fw-lib _id))
(define NSImageNameTouchBarHistoryTemplate (get-ffi-obj 'NSImageNameTouchBarHistoryTemplate _fw-lib _id))
(define NSImageNameTouchBarIconViewTemplate (get-ffi-obj 'NSImageNameTouchBarIconViewTemplate _fw-lib _id))
(define NSImageNameTouchBarListViewTemplate (get-ffi-obj 'NSImageNameTouchBarListViewTemplate _fw-lib _id))
(define NSImageNameTouchBarMailTemplate (get-ffi-obj 'NSImageNameTouchBarMailTemplate _fw-lib _id))
(define NSImageNameTouchBarNewFolderTemplate (get-ffi-obj 'NSImageNameTouchBarNewFolderTemplate _fw-lib _id))
(define NSImageNameTouchBarNewMessageTemplate (get-ffi-obj 'NSImageNameTouchBarNewMessageTemplate _fw-lib _id))
(define NSImageNameTouchBarOpenInBrowserTemplate (get-ffi-obj 'NSImageNameTouchBarOpenInBrowserTemplate _fw-lib _id))
(define NSImageNameTouchBarPauseTemplate (get-ffi-obj 'NSImageNameTouchBarPauseTemplate _fw-lib _id))
(define NSImageNameTouchBarPlayPauseTemplate (get-ffi-obj 'NSImageNameTouchBarPlayPauseTemplate _fw-lib _id))
(define NSImageNameTouchBarPlayTemplate (get-ffi-obj 'NSImageNameTouchBarPlayTemplate _fw-lib _id))
(define NSImageNameTouchBarPlayheadTemplate (get-ffi-obj 'NSImageNameTouchBarPlayheadTemplate _fw-lib _id))
(define NSImageNameTouchBarQuickLookTemplate (get-ffi-obj 'NSImageNameTouchBarQuickLookTemplate _fw-lib _id))
(define NSImageNameTouchBarRecordStartTemplate (get-ffi-obj 'NSImageNameTouchBarRecordStartTemplate _fw-lib _id))
(define NSImageNameTouchBarRecordStopTemplate (get-ffi-obj 'NSImageNameTouchBarRecordStopTemplate _fw-lib _id))
(define NSImageNameTouchBarRefreshTemplate (get-ffi-obj 'NSImageNameTouchBarRefreshTemplate _fw-lib _id))
(define NSImageNameTouchBarRemoveTemplate (get-ffi-obj 'NSImageNameTouchBarRemoveTemplate _fw-lib _id))
(define NSImageNameTouchBarRewindTemplate (get-ffi-obj 'NSImageNameTouchBarRewindTemplate _fw-lib _id))
(define NSImageNameTouchBarRotateLeftTemplate (get-ffi-obj 'NSImageNameTouchBarRotateLeftTemplate _fw-lib _id))
(define NSImageNameTouchBarRotateRightTemplate (get-ffi-obj 'NSImageNameTouchBarRotateRightTemplate _fw-lib _id))
(define NSImageNameTouchBarSearchTemplate (get-ffi-obj 'NSImageNameTouchBarSearchTemplate _fw-lib _id))
(define NSImageNameTouchBarShareTemplate (get-ffi-obj 'NSImageNameTouchBarShareTemplate _fw-lib _id))
(define NSImageNameTouchBarSidebarTemplate (get-ffi-obj 'NSImageNameTouchBarSidebarTemplate _fw-lib _id))
(define NSImageNameTouchBarSkipAhead15SecondsTemplate (get-ffi-obj 'NSImageNameTouchBarSkipAhead15SecondsTemplate _fw-lib _id))
(define NSImageNameTouchBarSkipAhead30SecondsTemplate (get-ffi-obj 'NSImageNameTouchBarSkipAhead30SecondsTemplate _fw-lib _id))
(define NSImageNameTouchBarSkipAheadTemplate (get-ffi-obj 'NSImageNameTouchBarSkipAheadTemplate _fw-lib _id))
(define NSImageNameTouchBarSkipBack15SecondsTemplate (get-ffi-obj 'NSImageNameTouchBarSkipBack15SecondsTemplate _fw-lib _id))
(define NSImageNameTouchBarSkipBack30SecondsTemplate (get-ffi-obj 'NSImageNameTouchBarSkipBack30SecondsTemplate _fw-lib _id))
(define NSImageNameTouchBarSkipBackTemplate (get-ffi-obj 'NSImageNameTouchBarSkipBackTemplate _fw-lib _id))
(define NSImageNameTouchBarSkipToEndTemplate (get-ffi-obj 'NSImageNameTouchBarSkipToEndTemplate _fw-lib _id))
(define NSImageNameTouchBarSkipToStartTemplate (get-ffi-obj 'NSImageNameTouchBarSkipToStartTemplate _fw-lib _id))
(define NSImageNameTouchBarSlideshowTemplate (get-ffi-obj 'NSImageNameTouchBarSlideshowTemplate _fw-lib _id))
(define NSImageNameTouchBarTagIconTemplate (get-ffi-obj 'NSImageNameTouchBarTagIconTemplate _fw-lib _id))
(define NSImageNameTouchBarTextBoldTemplate (get-ffi-obj 'NSImageNameTouchBarTextBoldTemplate _fw-lib _id))
(define NSImageNameTouchBarTextBoxTemplate (get-ffi-obj 'NSImageNameTouchBarTextBoxTemplate _fw-lib _id))
(define NSImageNameTouchBarTextCenterAlignTemplate (get-ffi-obj 'NSImageNameTouchBarTextCenterAlignTemplate _fw-lib _id))
(define NSImageNameTouchBarTextItalicTemplate (get-ffi-obj 'NSImageNameTouchBarTextItalicTemplate _fw-lib _id))
(define NSImageNameTouchBarTextJustifiedAlignTemplate (get-ffi-obj 'NSImageNameTouchBarTextJustifiedAlignTemplate _fw-lib _id))
(define NSImageNameTouchBarTextLeftAlignTemplate (get-ffi-obj 'NSImageNameTouchBarTextLeftAlignTemplate _fw-lib _id))
(define NSImageNameTouchBarTextListTemplate (get-ffi-obj 'NSImageNameTouchBarTextListTemplate _fw-lib _id))
(define NSImageNameTouchBarTextRightAlignTemplate (get-ffi-obj 'NSImageNameTouchBarTextRightAlignTemplate _fw-lib _id))
(define NSImageNameTouchBarTextStrikethroughTemplate (get-ffi-obj 'NSImageNameTouchBarTextStrikethroughTemplate _fw-lib _id))
(define NSImageNameTouchBarTextUnderlineTemplate (get-ffi-obj 'NSImageNameTouchBarTextUnderlineTemplate _fw-lib _id))
(define NSImageNameTouchBarUserAddTemplate (get-ffi-obj 'NSImageNameTouchBarUserAddTemplate _fw-lib _id))
(define NSImageNameTouchBarUserGroupTemplate (get-ffi-obj 'NSImageNameTouchBarUserGroupTemplate _fw-lib _id))
(define NSImageNameTouchBarUserTemplate (get-ffi-obj 'NSImageNameTouchBarUserTemplate _fw-lib _id))
(define NSImageNameTouchBarVolumeDownTemplate (get-ffi-obj 'NSImageNameTouchBarVolumeDownTemplate _fw-lib _id))
(define NSImageNameTouchBarVolumeUpTemplate (get-ffi-obj 'NSImageNameTouchBarVolumeUpTemplate _fw-lib _id))
(define NSImageNameTrashEmpty (get-ffi-obj 'NSImageNameTrashEmpty _fw-lib _id))
(define NSImageNameTrashFull (get-ffi-obj 'NSImageNameTrashFull _fw-lib _id))
(define NSImageNameUser (get-ffi-obj 'NSImageNameUser _fw-lib _id))
(define NSImageNameUserAccounts (get-ffi-obj 'NSImageNameUserAccounts _fw-lib _id))
(define NSImageNameUserGroup (get-ffi-obj 'NSImageNameUserGroup _fw-lib _id))
(define NSImageNameUserGuest (get-ffi-obj 'NSImageNameUserGuest _fw-lib _id))
(define NSImageProgressive (get-ffi-obj 'NSImageProgressive _fw-lib _id))
(define NSImageRGBColorTable (get-ffi-obj 'NSImageRGBColorTable _fw-lib _id))
(define NSImageRepRegistryDidChangeNotification (get-ffi-obj 'NSImageRepRegistryDidChangeNotification _fw-lib _id))
(define NSIncludedKeysBinding (get-ffi-obj 'NSIncludedKeysBinding _fw-lib _id))
(define NSInitialKeyBinding (get-ffi-obj 'NSInitialKeyBinding _fw-lib _id))
(define NSInitialValueBinding (get-ffi-obj 'NSInitialValueBinding _fw-lib _id))
(define NSInkTextPboardType (get-ffi-obj 'NSInkTextPboardType _fw-lib _id))
(define NSInsertsNullPlaceholderBindingOption (get-ffi-obj 'NSInsertsNullPlaceholderBindingOption _fw-lib _id))
(define NSInterfaceStyleDefault (get-ffi-obj 'NSInterfaceStyleDefault _fw-lib _id))
(define NSInvokesSeparatelyWithArrayObjectsBindingOption (get-ffi-obj 'NSInvokesSeparatelyWithArrayObjectsBindingOption _fw-lib _id))
(define NSIsIndeterminateBinding (get-ffi-obj 'NSIsIndeterminateBinding _fw-lib _id))
(define NSKernAttributeName (get-ffi-obj 'NSKernAttributeName _fw-lib _id))
(define NSKeywordsDocumentAttribute (get-ffi-obj 'NSKeywordsDocumentAttribute _fw-lib _id))
(define NSLabelBinding (get-ffi-obj 'NSLabelBinding _fw-lib _id))
(define NSLeftMarginDocumentAttribute (get-ffi-obj 'NSLeftMarginDocumentAttribute _fw-lib _id))
(define NSLigatureAttributeName (get-ffi-obj 'NSLigatureAttributeName _fw-lib _id))
(define NSLightGray (get-ffi-obj 'NSLightGray _fw-lib _double))
(define NSLinkAttributeName (get-ffi-obj 'NSLinkAttributeName _fw-lib _id))
(define NSLocalizedKeyDictionaryBinding (get-ffi-obj 'NSLocalizedKeyDictionaryBinding _fw-lib _id))
(define NSMacSimpleTextDocumentType (get-ffi-obj 'NSMacSimpleTextDocumentType _fw-lib _id))
(define NSManagedObjectContextBinding (get-ffi-obj 'NSManagedObjectContextBinding _fw-lib _id))
(define NSManagerDocumentAttribute (get-ffi-obj 'NSManagerDocumentAttribute _fw-lib _id))
(define NSMarkedClauseSegmentAttributeName (get-ffi-obj 'NSMarkedClauseSegmentAttributeName _fw-lib _id))
(define NSMaxValueBinding (get-ffi-obj 'NSMaxValueBinding _fw-lib _id))
(define NSMaxWidthBinding (get-ffi-obj 'NSMaxWidthBinding _fw-lib _id))
(define NSMaximumRecentsBinding (get-ffi-obj 'NSMaximumRecentsBinding _fw-lib _id))
(define NSMenuDidAddItemNotification (get-ffi-obj 'NSMenuDidAddItemNotification _fw-lib _id))
(define NSMenuDidBeginTrackingNotification (get-ffi-obj 'NSMenuDidBeginTrackingNotification _fw-lib _id))
(define NSMenuDidChangeItemNotification (get-ffi-obj 'NSMenuDidChangeItemNotification _fw-lib _id))
(define NSMenuDidEndTrackingNotification (get-ffi-obj 'NSMenuDidEndTrackingNotification _fw-lib _id))
(define NSMenuDidRemoveItemNotification (get-ffi-obj 'NSMenuDidRemoveItemNotification _fw-lib _id))
(define NSMenuDidSendActionNotification (get-ffi-obj 'NSMenuDidSendActionNotification _fw-lib _id))
(define NSMenuItemImportFromDeviceIdentifier (get-ffi-obj 'NSMenuItemImportFromDeviceIdentifier _fw-lib _id))
(define NSMenuWillSendActionNotification (get-ffi-obj 'NSMenuWillSendActionNotification _fw-lib _id))
(define NSMinValueBinding (get-ffi-obj 'NSMinValueBinding _fw-lib _id))
(define NSMinWidthBinding (get-ffi-obj 'NSMinWidthBinding _fw-lib _id))
(define NSMixedStateImageBinding (get-ffi-obj 'NSMixedStateImageBinding _fw-lib _id))
(define NSModalPanelRunLoopMode (get-ffi-obj 'NSModalPanelRunLoopMode _fw-lib _id))
(define NSModificationTimeDocumentAttribute (get-ffi-obj 'NSModificationTimeDocumentAttribute _fw-lib _id))
(define NSMultipleTextSelectionPboardType (get-ffi-obj 'NSMultipleTextSelectionPboardType _fw-lib _id))
(define NSMultipleValuesMarker (get-ffi-obj 'NSMultipleValuesMarker _fw-lib _id))
(define NSMultipleValuesPlaceholderBindingOption (get-ffi-obj 'NSMultipleValuesPlaceholderBindingOption _fw-lib _id))
(define NSNamedColorSpace (get-ffi-obj 'NSNamedColorSpace _fw-lib _id))
(define NSNibLoadingException (get-ffi-obj 'NSNibLoadingException _fw-lib _id))
(define NSNibOwner (get-ffi-obj 'NSNibOwner _fw-lib _id))
(define NSNibTopLevelObjects (get-ffi-obj 'NSNibTopLevelObjects _fw-lib _id))
(define NSNoSelectionMarker (get-ffi-obj 'NSNoSelectionMarker _fw-lib _id))
(define NSNoSelectionPlaceholderBindingOption (get-ffi-obj 'NSNoSelectionPlaceholderBindingOption _fw-lib _id))
(define NSNotApplicableMarker (get-ffi-obj 'NSNotApplicableMarker _fw-lib _id))
(define NSNotApplicablePlaceholderBindingOption (get-ffi-obj 'NSNotApplicablePlaceholderBindingOption _fw-lib _id))
(define NSNullPlaceholderBindingOption (get-ffi-obj 'NSNullPlaceholderBindingOption _fw-lib _id))
(define NSObliquenessAttributeName (get-ffi-obj 'NSObliquenessAttributeName _fw-lib _id))
(define NSObservedKeyPathKey (get-ffi-obj 'NSObservedKeyPathKey _fw-lib _id))
(define NSObservedObjectKey (get-ffi-obj 'NSObservedObjectKey _fw-lib _id))
(define NSOffStateImageBinding (get-ffi-obj 'NSOffStateImageBinding _fw-lib _id))
(define NSOfficeOpenXMLTextDocumentType (get-ffi-obj 'NSOfficeOpenXMLTextDocumentType _fw-lib _id))
(define NSOnStateImageBinding (get-ffi-obj 'NSOnStateImageBinding _fw-lib _id))
(define NSOpenDocumentTextDocumentType (get-ffi-obj 'NSOpenDocumentTextDocumentType _fw-lib _id))
(define NSOptionsKey (get-ffi-obj 'NSOptionsKey _fw-lib _id))
(define NSOutlineViewColumnDidMoveNotification (get-ffi-obj 'NSOutlineViewColumnDidMoveNotification _fw-lib _id))
(define NSOutlineViewColumnDidResizeNotification (get-ffi-obj 'NSOutlineViewColumnDidResizeNotification _fw-lib _id))
(define NSOutlineViewDisclosureButtonKey (get-ffi-obj 'NSOutlineViewDisclosureButtonKey _fw-lib _id))
(define NSOutlineViewItemDidCollapseNotification (get-ffi-obj 'NSOutlineViewItemDidCollapseNotification _fw-lib _id))
(define NSOutlineViewItemDidExpandNotification (get-ffi-obj 'NSOutlineViewItemDidExpandNotification _fw-lib _id))
(define NSOutlineViewItemWillCollapseNotification (get-ffi-obj 'NSOutlineViewItemWillCollapseNotification _fw-lib _id))
(define NSOutlineViewItemWillExpandNotification (get-ffi-obj 'NSOutlineViewItemWillExpandNotification _fw-lib _id))
(define NSOutlineViewSelectionDidChangeNotification (get-ffi-obj 'NSOutlineViewSelectionDidChangeNotification _fw-lib _id))
(define NSOutlineViewSelectionIsChangingNotification (get-ffi-obj 'NSOutlineViewSelectionIsChangingNotification _fw-lib _id))
(define NSOutlineViewShowHideButtonKey (get-ffi-obj 'NSOutlineViewShowHideButtonKey _fw-lib _id))
(define NSPDFPboardType (get-ffi-obj 'NSPDFPboardType _fw-lib _id))
(define NSPICTPboardType (get-ffi-obj 'NSPICTPboardType _fw-lib _id))
(define NSPPDIncludeNotFoundException (get-ffi-obj 'NSPPDIncludeNotFoundException _fw-lib _id))
(define NSPPDIncludeStackOverflowException (get-ffi-obj 'NSPPDIncludeStackOverflowException _fw-lib _id))
(define NSPPDIncludeStackUnderflowException (get-ffi-obj 'NSPPDIncludeStackUnderflowException _fw-lib _id))
(define NSPPDParseException (get-ffi-obj 'NSPPDParseException _fw-lib _id))
(define NSPaperSizeDocumentAttribute (get-ffi-obj 'NSPaperSizeDocumentAttribute _fw-lib _id))
(define NSParagraphStyleAttributeName (get-ffi-obj 'NSParagraphStyleAttributeName _fw-lib _id))
(define NSPasteboardCommunicationException (get-ffi-obj 'NSPasteboardCommunicationException _fw-lib _id))
(define NSPasteboardDetectionPatternCalendarEvent (get-ffi-obj 'NSPasteboardDetectionPatternCalendarEvent _fw-lib _id))
(define NSPasteboardDetectionPatternEmailAddress (get-ffi-obj 'NSPasteboardDetectionPatternEmailAddress _fw-lib _id))
(define NSPasteboardDetectionPatternFlightNumber (get-ffi-obj 'NSPasteboardDetectionPatternFlightNumber _fw-lib _id))
(define NSPasteboardDetectionPatternLink (get-ffi-obj 'NSPasteboardDetectionPatternLink _fw-lib _id))
(define NSPasteboardDetectionPatternMoneyAmount (get-ffi-obj 'NSPasteboardDetectionPatternMoneyAmount _fw-lib _id))
(define NSPasteboardDetectionPatternNumber (get-ffi-obj 'NSPasteboardDetectionPatternNumber _fw-lib _id))
(define NSPasteboardDetectionPatternPhoneNumber (get-ffi-obj 'NSPasteboardDetectionPatternPhoneNumber _fw-lib _id))
(define NSPasteboardDetectionPatternPostalAddress (get-ffi-obj 'NSPasteboardDetectionPatternPostalAddress _fw-lib _id))
(define NSPasteboardDetectionPatternProbableWebSearch (get-ffi-obj 'NSPasteboardDetectionPatternProbableWebSearch _fw-lib _id))
(define NSPasteboardDetectionPatternProbableWebURL (get-ffi-obj 'NSPasteboardDetectionPatternProbableWebURL _fw-lib _id))
(define NSPasteboardDetectionPatternShipmentTrackingNumber (get-ffi-obj 'NSPasteboardDetectionPatternShipmentTrackingNumber _fw-lib _id))
(define NSPasteboardMetadataTypeContentType (get-ffi-obj 'NSPasteboardMetadataTypeContentType _fw-lib _id))
(define NSPasteboardNameDrag (get-ffi-obj 'NSPasteboardNameDrag _fw-lib _id))
(define NSPasteboardNameFind (get-ffi-obj 'NSPasteboardNameFind _fw-lib _id))
(define NSPasteboardNameFont (get-ffi-obj 'NSPasteboardNameFont _fw-lib _id))
(define NSPasteboardNameGeneral (get-ffi-obj 'NSPasteboardNameGeneral _fw-lib _id))
(define NSPasteboardNameRuler (get-ffi-obj 'NSPasteboardNameRuler _fw-lib _id))
(define NSPasteboardTypeColor (get-ffi-obj 'NSPasteboardTypeColor _fw-lib _id))
(define NSPasteboardTypeFileURL (get-ffi-obj 'NSPasteboardTypeFileURL _fw-lib _id))
(define NSPasteboardTypeFindPanelSearchOptions (get-ffi-obj 'NSPasteboardTypeFindPanelSearchOptions _fw-lib _id))
(define NSPasteboardTypeFont (get-ffi-obj 'NSPasteboardTypeFont _fw-lib _id))
(define NSPasteboardTypeHTML (get-ffi-obj 'NSPasteboardTypeHTML _fw-lib _id))
(define NSPasteboardTypeMultipleTextSelection (get-ffi-obj 'NSPasteboardTypeMultipleTextSelection _fw-lib _id))
(define NSPasteboardTypePDF (get-ffi-obj 'NSPasteboardTypePDF _fw-lib _id))
(define NSPasteboardTypePNG (get-ffi-obj 'NSPasteboardTypePNG _fw-lib _id))
(define NSPasteboardTypeRTF (get-ffi-obj 'NSPasteboardTypeRTF _fw-lib _id))
(define NSPasteboardTypeRTFD (get-ffi-obj 'NSPasteboardTypeRTFD _fw-lib _id))
(define NSPasteboardTypeRuler (get-ffi-obj 'NSPasteboardTypeRuler _fw-lib _id))
(define NSPasteboardTypeSound (get-ffi-obj 'NSPasteboardTypeSound _fw-lib _id))
(define NSPasteboardTypeString (get-ffi-obj 'NSPasteboardTypeString _fw-lib _id))
(define NSPasteboardTypeTIFF (get-ffi-obj 'NSPasteboardTypeTIFF _fw-lib _id))
(define NSPasteboardTypeTabularText (get-ffi-obj 'NSPasteboardTypeTabularText _fw-lib _id))
(define NSPasteboardTypeTextFinderOptions (get-ffi-obj 'NSPasteboardTypeTextFinderOptions _fw-lib _id))
(define NSPasteboardTypeURL (get-ffi-obj 'NSPasteboardTypeURL _fw-lib _id))
(define NSPasteboardURLReadingContentsConformToTypesKey (get-ffi-obj 'NSPasteboardURLReadingContentsConformToTypesKey _fw-lib _id))
(define NSPasteboardURLReadingFileURLsOnlyKey (get-ffi-obj 'NSPasteboardURLReadingFileURLsOnlyKey _fw-lib _id))
(define NSPatternColorSpace (get-ffi-obj 'NSPatternColorSpace _fw-lib _id))
(define NSPlainFileType (get-ffi-obj 'NSPlainFileType _fw-lib _id))
(define NSPlainTextDocumentType (get-ffi-obj 'NSPlainTextDocumentType _fw-lib _id))
(define NSPopUpButtonCellWillPopUpNotification (get-ffi-obj 'NSPopUpButtonCellWillPopUpNotification _fw-lib _id))
(define NSPopUpButtonWillPopUpNotification (get-ffi-obj 'NSPopUpButtonWillPopUpNotification _fw-lib _id))
(define NSPopoverCloseReasonDetachToWindow (get-ffi-obj 'NSPopoverCloseReasonDetachToWindow _fw-lib _id))
(define NSPopoverCloseReasonKey (get-ffi-obj 'NSPopoverCloseReasonKey _fw-lib _id))
(define NSPopoverCloseReasonStandard (get-ffi-obj 'NSPopoverCloseReasonStandard _fw-lib _id))
(define NSPopoverDidCloseNotification (get-ffi-obj 'NSPopoverDidCloseNotification _fw-lib _id))
(define NSPopoverDidShowNotification (get-ffi-obj 'NSPopoverDidShowNotification _fw-lib _id))
(define NSPopoverWillCloseNotification (get-ffi-obj 'NSPopoverWillCloseNotification _fw-lib _id))
(define NSPopoverWillShowNotification (get-ffi-obj 'NSPopoverWillShowNotification _fw-lib _id))
(define NSPositioningRectBinding (get-ffi-obj 'NSPositioningRectBinding _fw-lib _id))
(define NSPostScriptPboardType (get-ffi-obj 'NSPostScriptPboardType _fw-lib _id))
(define NSPredicateBinding (get-ffi-obj 'NSPredicateBinding _fw-lib _id))
(define NSPredicateFormatBindingOption (get-ffi-obj 'NSPredicateFormatBindingOption _fw-lib _id))
(define NSPreferredScrollerStyleDidChangeNotification (get-ffi-obj 'NSPreferredScrollerStyleDidChangeNotification _fw-lib _id))
(define NSPrefixSpacesDocumentAttribute (get-ffi-obj 'NSPrefixSpacesDocumentAttribute _fw-lib _id))
(define NSPrintAllPages (get-ffi-obj 'NSPrintAllPages _fw-lib _id))
(define NSPrintAllPresetsJobStyleHint (get-ffi-obj 'NSPrintAllPresetsJobStyleHint _fw-lib _id))
(define NSPrintBottomMargin (get-ffi-obj 'NSPrintBottomMargin _fw-lib _id))
(define NSPrintCancelJob (get-ffi-obj 'NSPrintCancelJob _fw-lib _id))
(define NSPrintCopies (get-ffi-obj 'NSPrintCopies _fw-lib _id))
(define NSPrintDetailedErrorReporting (get-ffi-obj 'NSPrintDetailedErrorReporting _fw-lib _id))
(define NSPrintFaxNumber (get-ffi-obj 'NSPrintFaxNumber _fw-lib _id))
(define NSPrintFirstPage (get-ffi-obj 'NSPrintFirstPage _fw-lib _id))
(define NSPrintFormName (get-ffi-obj 'NSPrintFormName _fw-lib _id))
(define NSPrintHeaderAndFooter (get-ffi-obj 'NSPrintHeaderAndFooter _fw-lib _id))
(define NSPrintHorizontalPagination (get-ffi-obj 'NSPrintHorizontalPagination _fw-lib _id))
(define NSPrintHorizontallyCentered (get-ffi-obj 'NSPrintHorizontallyCentered _fw-lib _id))
(define NSPrintJobDisposition (get-ffi-obj 'NSPrintJobDisposition _fw-lib _id))
(define NSPrintJobFeatures (get-ffi-obj 'NSPrintJobFeatures _fw-lib _id))
(define NSPrintJobSavingFileNameExtensionHidden (get-ffi-obj 'NSPrintJobSavingFileNameExtensionHidden _fw-lib _id))
(define NSPrintJobSavingURL (get-ffi-obj 'NSPrintJobSavingURL _fw-lib _id))
(define NSPrintLastPage (get-ffi-obj 'NSPrintLastPage _fw-lib _id))
(define NSPrintLeftMargin (get-ffi-obj 'NSPrintLeftMargin _fw-lib _id))
(define NSPrintManualFeed (get-ffi-obj 'NSPrintManualFeed _fw-lib _id))
(define NSPrintMustCollate (get-ffi-obj 'NSPrintMustCollate _fw-lib _id))
(define NSPrintNoPresetsJobStyleHint (get-ffi-obj 'NSPrintNoPresetsJobStyleHint _fw-lib _id))
(define NSPrintOperationExistsException (get-ffi-obj 'NSPrintOperationExistsException _fw-lib _id))
(define NSPrintOrientation (get-ffi-obj 'NSPrintOrientation _fw-lib _id))
(define NSPrintPackageException (get-ffi-obj 'NSPrintPackageException _fw-lib _id))
(define NSPrintPagesAcross (get-ffi-obj 'NSPrintPagesAcross _fw-lib _id))
(define NSPrintPagesDown (get-ffi-obj 'NSPrintPagesDown _fw-lib _id))
(define NSPrintPagesPerSheet (get-ffi-obj 'NSPrintPagesPerSheet _fw-lib _id))
(define NSPrintPanelAccessorySummaryItemDescriptionKey (get-ffi-obj 'NSPrintPanelAccessorySummaryItemDescriptionKey _fw-lib _id))
(define NSPrintPanelAccessorySummaryItemNameKey (get-ffi-obj 'NSPrintPanelAccessorySummaryItemNameKey _fw-lib _id))
(define NSPrintPaperFeed (get-ffi-obj 'NSPrintPaperFeed _fw-lib _id))
(define NSPrintPaperName (get-ffi-obj 'NSPrintPaperName _fw-lib _id))
(define NSPrintPaperSize (get-ffi-obj 'NSPrintPaperSize _fw-lib _id))
(define NSPrintPhotoJobStyleHint (get-ffi-obj 'NSPrintPhotoJobStyleHint _fw-lib _id))
(define NSPrintPreviewJob (get-ffi-obj 'NSPrintPreviewJob _fw-lib _id))
(define NSPrintPrinter (get-ffi-obj 'NSPrintPrinter _fw-lib _id))
(define NSPrintPrinterName (get-ffi-obj 'NSPrintPrinterName _fw-lib _id))
(define NSPrintReversePageOrder (get-ffi-obj 'NSPrintReversePageOrder _fw-lib _id))
(define NSPrintRightMargin (get-ffi-obj 'NSPrintRightMargin _fw-lib _id))
(define NSPrintSaveJob (get-ffi-obj 'NSPrintSaveJob _fw-lib _id))
(define NSPrintSavePath (get-ffi-obj 'NSPrintSavePath _fw-lib _id))
(define NSPrintScalingFactor (get-ffi-obj 'NSPrintScalingFactor _fw-lib _id))
(define NSPrintSelectionOnly (get-ffi-obj 'NSPrintSelectionOnly _fw-lib _id))
(define NSPrintSpoolJob (get-ffi-obj 'NSPrintSpoolJob _fw-lib _id))
(define NSPrintTime (get-ffi-obj 'NSPrintTime _fw-lib _id))
(define NSPrintTopMargin (get-ffi-obj 'NSPrintTopMargin _fw-lib _id))
(define NSPrintVerticalPagination (get-ffi-obj 'NSPrintVerticalPagination _fw-lib _id))
(define NSPrintVerticallyCentered (get-ffi-obj 'NSPrintVerticallyCentered _fw-lib _id))
(define NSPrintingCommunicationException (get-ffi-obj 'NSPrintingCommunicationException _fw-lib _id))
(define NSRTFDPboardType (get-ffi-obj 'NSRTFDPboardType _fw-lib _id))
(define NSRTFDTextDocumentType (get-ffi-obj 'NSRTFDTextDocumentType _fw-lib _id))
(define NSRTFPboardType (get-ffi-obj 'NSRTFPboardType _fw-lib _id))
(define NSRTFPropertyStackOverflowException (get-ffi-obj 'NSRTFPropertyStackOverflowException _fw-lib _id))
(define NSRTFTextDocumentType (get-ffi-obj 'NSRTFTextDocumentType _fw-lib _id))
(define NSRaisesForNotApplicableKeysBindingOption (get-ffi-obj 'NSRaisesForNotApplicableKeysBindingOption _fw-lib _id))
(define NSReadOnlyDocumentAttribute (get-ffi-obj 'NSReadOnlyDocumentAttribute _fw-lib _id))
(define NSRecentSearchesBinding (get-ffi-obj 'NSRecentSearchesBinding _fw-lib _id))
(define NSRepresentedFilenameBinding (get-ffi-obj 'NSRepresentedFilenameBinding _fw-lib _id))
(define NSRightMarginDocumentAttribute (get-ffi-obj 'NSRightMarginDocumentAttribute _fw-lib _id))
(define NSRowHeightBinding (get-ffi-obj 'NSRowHeightBinding _fw-lib _id))
(define NSRuleEditorPredicateComparisonModifier (get-ffi-obj 'NSRuleEditorPredicateComparisonModifier _fw-lib _id))
(define NSRuleEditorPredicateCompoundType (get-ffi-obj 'NSRuleEditorPredicateCompoundType _fw-lib _id))
(define NSRuleEditorPredicateCustomSelector (get-ffi-obj 'NSRuleEditorPredicateCustomSelector _fw-lib _id))
(define NSRuleEditorPredicateLeftExpression (get-ffi-obj 'NSRuleEditorPredicateLeftExpression _fw-lib _id))
(define NSRuleEditorPredicateOperatorType (get-ffi-obj 'NSRuleEditorPredicateOperatorType _fw-lib _id))
(define NSRuleEditorPredicateOptions (get-ffi-obj 'NSRuleEditorPredicateOptions _fw-lib _id))
(define NSRuleEditorPredicateRightExpression (get-ffi-obj 'NSRuleEditorPredicateRightExpression _fw-lib _id))
(define NSRuleEditorRowsDidChangeNotification (get-ffi-obj 'NSRuleEditorRowsDidChangeNotification _fw-lib _id))
(define NSRulerPboard (get-ffi-obj 'NSRulerPboard _fw-lib _id))
(define NSRulerPboardType (get-ffi-obj 'NSRulerPboardType _fw-lib _id))
(define NSRulerViewUnitCentimeters (get-ffi-obj 'NSRulerViewUnitCentimeters _fw-lib _id))
(define NSRulerViewUnitInches (get-ffi-obj 'NSRulerViewUnitInches _fw-lib _id))
(define NSRulerViewUnitPicas (get-ffi-obj 'NSRulerViewUnitPicas _fw-lib _id))
(define NSRulerViewUnitPoints (get-ffi-obj 'NSRulerViewUnitPoints _fw-lib _id))
(define NSScreenColorSpaceDidChangeNotification (get-ffi-obj 'NSScreenColorSpaceDidChangeNotification _fw-lib _id))
(define NSScrollViewDidEndLiveMagnifyNotification (get-ffi-obj 'NSScrollViewDidEndLiveMagnifyNotification _fw-lib _id))
(define NSScrollViewDidEndLiveScrollNotification (get-ffi-obj 'NSScrollViewDidEndLiveScrollNotification _fw-lib _id))
(define NSScrollViewDidLiveScrollNotification (get-ffi-obj 'NSScrollViewDidLiveScrollNotification _fw-lib _id))
(define NSScrollViewWillStartLiveMagnifyNotification (get-ffi-obj 'NSScrollViewWillStartLiveMagnifyNotification _fw-lib _id))
(define NSScrollViewWillStartLiveScrollNotification (get-ffi-obj 'NSScrollViewWillStartLiveScrollNotification _fw-lib _id))
(define NSSelectedIdentifierBinding (get-ffi-obj 'NSSelectedIdentifierBinding _fw-lib _id))
(define NSSelectedIndexBinding (get-ffi-obj 'NSSelectedIndexBinding _fw-lib _id))
(define NSSelectedLabelBinding (get-ffi-obj 'NSSelectedLabelBinding _fw-lib _id))
(define NSSelectedObjectBinding (get-ffi-obj 'NSSelectedObjectBinding _fw-lib _id))
(define NSSelectedObjectsBinding (get-ffi-obj 'NSSelectedObjectsBinding _fw-lib _id))
(define NSSelectedTagBinding (get-ffi-obj 'NSSelectedTagBinding _fw-lib _id))
(define NSSelectedValueBinding (get-ffi-obj 'NSSelectedValueBinding _fw-lib _id))
(define NSSelectedValuesBinding (get-ffi-obj 'NSSelectedValuesBinding _fw-lib _id))
(define NSSelectionIndexPathsBinding (get-ffi-obj 'NSSelectionIndexPathsBinding _fw-lib _id))
(define NSSelectionIndexesBinding (get-ffi-obj 'NSSelectionIndexesBinding _fw-lib _id))
(define NSSelectorNameBindingOption (get-ffi-obj 'NSSelectorNameBindingOption _fw-lib _id))
(define NSSelectsAllWhenSettingContentBindingOption (get-ffi-obj 'NSSelectsAllWhenSettingContentBindingOption _fw-lib _id))
(define NSShadowAttributeName (get-ffi-obj 'NSShadowAttributeName _fw-lib _id))
(define NSSharingServiceNameAddToAperture (get-ffi-obj 'NSSharingServiceNameAddToAperture _fw-lib _id))
(define NSSharingServiceNameAddToIPhoto (get-ffi-obj 'NSSharingServiceNameAddToIPhoto _fw-lib _id))
(define NSSharingServiceNameAddToSafariReadingList (get-ffi-obj 'NSSharingServiceNameAddToSafariReadingList _fw-lib _id))
(define NSSharingServiceNameCloudSharing (get-ffi-obj 'NSSharingServiceNameCloudSharing _fw-lib _id))
(define NSSharingServiceNameComposeEmail (get-ffi-obj 'NSSharingServiceNameComposeEmail _fw-lib _id))
(define NSSharingServiceNameComposeMessage (get-ffi-obj 'NSSharingServiceNameComposeMessage _fw-lib _id))
(define NSSharingServiceNamePostImageOnFlickr (get-ffi-obj 'NSSharingServiceNamePostImageOnFlickr _fw-lib _id))
(define NSSharingServiceNamePostOnFacebook (get-ffi-obj 'NSSharingServiceNamePostOnFacebook _fw-lib _id))
(define NSSharingServiceNamePostOnLinkedIn (get-ffi-obj 'NSSharingServiceNamePostOnLinkedIn _fw-lib _id))
(define NSSharingServiceNamePostOnSinaWeibo (get-ffi-obj 'NSSharingServiceNamePostOnSinaWeibo _fw-lib _id))
(define NSSharingServiceNamePostOnTencentWeibo (get-ffi-obj 'NSSharingServiceNamePostOnTencentWeibo _fw-lib _id))
(define NSSharingServiceNamePostOnTwitter (get-ffi-obj 'NSSharingServiceNamePostOnTwitter _fw-lib _id))
(define NSSharingServiceNamePostVideoOnTudou (get-ffi-obj 'NSSharingServiceNamePostVideoOnTudou _fw-lib _id))
(define NSSharingServiceNamePostVideoOnVimeo (get-ffi-obj 'NSSharingServiceNamePostVideoOnVimeo _fw-lib _id))
(define NSSharingServiceNamePostVideoOnYouku (get-ffi-obj 'NSSharingServiceNamePostVideoOnYouku _fw-lib _id))
(define NSSharingServiceNameSendViaAirDrop (get-ffi-obj 'NSSharingServiceNameSendViaAirDrop _fw-lib _id))
(define NSSharingServiceNameUseAsDesktopPicture (get-ffi-obj 'NSSharingServiceNameUseAsDesktopPicture _fw-lib _id))
(define NSSharingServiceNameUseAsFacebookProfileImage (get-ffi-obj 'NSSharingServiceNameUseAsFacebookProfileImage _fw-lib _id))
(define NSSharingServiceNameUseAsLinkedInProfileImage (get-ffi-obj 'NSSharingServiceNameUseAsLinkedInProfileImage _fw-lib _id))
(define NSSharingServiceNameUseAsTwitterProfileImage (get-ffi-obj 'NSSharingServiceNameUseAsTwitterProfileImage _fw-lib _id))
(define NSShellCommandFileType (get-ffi-obj 'NSShellCommandFileType _fw-lib _id))
(define NSSliderAccessoryWidthDefault (get-ffi-obj 'NSSliderAccessoryWidthDefault _fw-lib _double))
(define NSSliderAccessoryWidthWide (get-ffi-obj 'NSSliderAccessoryWidthWide _fw-lib _double))
(define NSSortDescriptorsBinding (get-ffi-obj 'NSSortDescriptorsBinding _fw-lib _id))
(define NSSoundPboardType (get-ffi-obj 'NSSoundPboardType _fw-lib _id))
(define NSSourceTextScalingDocumentAttribute (get-ffi-obj 'NSSourceTextScalingDocumentAttribute _fw-lib _id))
(define NSSourceTextScalingDocumentOption (get-ffi-obj 'NSSourceTextScalingDocumentOption _fw-lib _id))
(define NSSpeechCharacterModeProperty (get-ffi-obj 'NSSpeechCharacterModeProperty _fw-lib _id))
(define NSSpeechCommandDelimiterProperty (get-ffi-obj 'NSSpeechCommandDelimiterProperty _fw-lib _id))
(define NSSpeechCommandPrefix (get-ffi-obj 'NSSpeechCommandPrefix _fw-lib _id))
(define NSSpeechCommandSuffix (get-ffi-obj 'NSSpeechCommandSuffix _fw-lib _id))
(define NSSpeechCurrentVoiceProperty (get-ffi-obj 'NSSpeechCurrentVoiceProperty _fw-lib _id))
(define NSSpeechDictionaryAbbreviations (get-ffi-obj 'NSSpeechDictionaryAbbreviations _fw-lib _id))
(define NSSpeechDictionaryEntryPhonemes (get-ffi-obj 'NSSpeechDictionaryEntryPhonemes _fw-lib _id))
(define NSSpeechDictionaryEntrySpelling (get-ffi-obj 'NSSpeechDictionaryEntrySpelling _fw-lib _id))
(define NSSpeechDictionaryLocaleIdentifier (get-ffi-obj 'NSSpeechDictionaryLocaleIdentifier _fw-lib _id))
(define NSSpeechDictionaryModificationDate (get-ffi-obj 'NSSpeechDictionaryModificationDate _fw-lib _id))
(define NSSpeechDictionaryPronunciations (get-ffi-obj 'NSSpeechDictionaryPronunciations _fw-lib _id))
(define NSSpeechErrorCount (get-ffi-obj 'NSSpeechErrorCount _fw-lib _id))
(define NSSpeechErrorNewestCharacterOffset (get-ffi-obj 'NSSpeechErrorNewestCharacterOffset _fw-lib _id))
(define NSSpeechErrorNewestCode (get-ffi-obj 'NSSpeechErrorNewestCode _fw-lib _id))
(define NSSpeechErrorOldestCharacterOffset (get-ffi-obj 'NSSpeechErrorOldestCharacterOffset _fw-lib _id))
(define NSSpeechErrorOldestCode (get-ffi-obj 'NSSpeechErrorOldestCode _fw-lib _id))
(define NSSpeechErrorsProperty (get-ffi-obj 'NSSpeechErrorsProperty _fw-lib _id))
(define NSSpeechInputModeProperty (get-ffi-obj 'NSSpeechInputModeProperty _fw-lib _id))
(define NSSpeechModeLiteral (get-ffi-obj 'NSSpeechModeLiteral _fw-lib _id))
(define NSSpeechModeNormal (get-ffi-obj 'NSSpeechModeNormal _fw-lib _id))
(define NSSpeechModePhoneme (get-ffi-obj 'NSSpeechModePhoneme _fw-lib _id))
(define NSSpeechModeText (get-ffi-obj 'NSSpeechModeText _fw-lib _id))
(define NSSpeechNumberModeProperty (get-ffi-obj 'NSSpeechNumberModeProperty _fw-lib _id))
(define NSSpeechOutputToFileURLProperty (get-ffi-obj 'NSSpeechOutputToFileURLProperty _fw-lib _id))
(define NSSpeechPhonemeInfoExample (get-ffi-obj 'NSSpeechPhonemeInfoExample _fw-lib _id))
(define NSSpeechPhonemeInfoHiliteEnd (get-ffi-obj 'NSSpeechPhonemeInfoHiliteEnd _fw-lib _id))
(define NSSpeechPhonemeInfoHiliteStart (get-ffi-obj 'NSSpeechPhonemeInfoHiliteStart _fw-lib _id))
(define NSSpeechPhonemeInfoOpcode (get-ffi-obj 'NSSpeechPhonemeInfoOpcode _fw-lib _id))
(define NSSpeechPhonemeInfoSymbol (get-ffi-obj 'NSSpeechPhonemeInfoSymbol _fw-lib _id))
(define NSSpeechPhonemeSymbolsProperty (get-ffi-obj 'NSSpeechPhonemeSymbolsProperty _fw-lib _id))
(define NSSpeechPitchBaseProperty (get-ffi-obj 'NSSpeechPitchBaseProperty _fw-lib _id))
(define NSSpeechPitchModProperty (get-ffi-obj 'NSSpeechPitchModProperty _fw-lib _id))
(define NSSpeechRateProperty (get-ffi-obj 'NSSpeechRateProperty _fw-lib _id))
(define NSSpeechRecentSyncProperty (get-ffi-obj 'NSSpeechRecentSyncProperty _fw-lib _id))
(define NSSpeechResetProperty (get-ffi-obj 'NSSpeechResetProperty _fw-lib _id))
(define NSSpeechStatusNumberOfCharactersLeft (get-ffi-obj 'NSSpeechStatusNumberOfCharactersLeft _fw-lib _id))
(define NSSpeechStatusOutputBusy (get-ffi-obj 'NSSpeechStatusOutputBusy _fw-lib _id))
(define NSSpeechStatusOutputPaused (get-ffi-obj 'NSSpeechStatusOutputPaused _fw-lib _id))
(define NSSpeechStatusPhonemeCode (get-ffi-obj 'NSSpeechStatusPhonemeCode _fw-lib _id))
(define NSSpeechStatusProperty (get-ffi-obj 'NSSpeechStatusProperty _fw-lib _id))
(define NSSpeechSynthesizerInfoIdentifier (get-ffi-obj 'NSSpeechSynthesizerInfoIdentifier _fw-lib _id))
(define NSSpeechSynthesizerInfoProperty (get-ffi-obj 'NSSpeechSynthesizerInfoProperty _fw-lib _id))
(define NSSpeechSynthesizerInfoVersion (get-ffi-obj 'NSSpeechSynthesizerInfoVersion _fw-lib _id))
(define NSSpeechVolumeProperty (get-ffi-obj 'NSSpeechVolumeProperty _fw-lib _id))
(define NSSpellCheckerDidChangeAutomaticCapitalizationNotification (get-ffi-obj 'NSSpellCheckerDidChangeAutomaticCapitalizationNotification _fw-lib _id))
(define NSSpellCheckerDidChangeAutomaticDashSubstitutionNotification (get-ffi-obj 'NSSpellCheckerDidChangeAutomaticDashSubstitutionNotification _fw-lib _id))
(define NSSpellCheckerDidChangeAutomaticInlinePredictionNotification (get-ffi-obj 'NSSpellCheckerDidChangeAutomaticInlinePredictionNotification _fw-lib _id))
(define NSSpellCheckerDidChangeAutomaticPeriodSubstitutionNotification (get-ffi-obj 'NSSpellCheckerDidChangeAutomaticPeriodSubstitutionNotification _fw-lib _id))
(define NSSpellCheckerDidChangeAutomaticQuoteSubstitutionNotification (get-ffi-obj 'NSSpellCheckerDidChangeAutomaticQuoteSubstitutionNotification _fw-lib _id))
(define NSSpellCheckerDidChangeAutomaticSpellingCorrectionNotification (get-ffi-obj 'NSSpellCheckerDidChangeAutomaticSpellingCorrectionNotification _fw-lib _id))
(define NSSpellCheckerDidChangeAutomaticTextCompletionNotification (get-ffi-obj 'NSSpellCheckerDidChangeAutomaticTextCompletionNotification _fw-lib _id))
(define NSSpellCheckerDidChangeAutomaticTextReplacementNotification (get-ffi-obj 'NSSpellCheckerDidChangeAutomaticTextReplacementNotification _fw-lib _id))
(define NSSpellingStateAttributeName (get-ffi-obj 'NSSpellingStateAttributeName _fw-lib _id))
(define NSSplitViewControllerAutomaticDimension (get-ffi-obj 'NSSplitViewControllerAutomaticDimension _fw-lib _double))
(define NSSplitViewDidResizeSubviewsNotification (get-ffi-obj 'NSSplitViewDidResizeSubviewsNotification _fw-lib _id))
(define NSSplitViewItemUnspecifiedDimension (get-ffi-obj 'NSSplitViewItemUnspecifiedDimension _fw-lib _double))
(define NSSplitViewWillResizeSubviewsNotification (get-ffi-obj 'NSSplitViewWillResizeSubviewsNotification _fw-lib _id))
(define NSStrikethroughColorAttributeName (get-ffi-obj 'NSStrikethroughColorAttributeName _fw-lib _id))
(define NSStrikethroughStyleAttributeName (get-ffi-obj 'NSStrikethroughStyleAttributeName _fw-lib _id))
(define NSStringPboardType (get-ffi-obj 'NSStringPboardType _fw-lib _id))
(define NSStrokeColorAttributeName (get-ffi-obj 'NSStrokeColorAttributeName _fw-lib _id))
(define NSStrokeWidthAttributeName (get-ffi-obj 'NSStrokeWidthAttributeName _fw-lib _id))
(define NSSubjectDocumentAttribute (get-ffi-obj 'NSSubjectDocumentAttribute _fw-lib _id))
(define NSSuperscriptAttributeName (get-ffi-obj 'NSSuperscriptAttributeName _fw-lib _id))
(define NSSystemColorsDidChangeNotification (get-ffi-obj 'NSSystemColorsDidChangeNotification _fw-lib _id))
(define NSTIFFException (get-ffi-obj 'NSTIFFException _fw-lib _id))
(define NSTIFFPboardType (get-ffi-obj 'NSTIFFPboardType _fw-lib _id))
(define NSTabColumnTerminatorsAttributeName (get-ffi-obj 'NSTabColumnTerminatorsAttributeName _fw-lib _id))
(define NSTableViewColumnDidMoveNotification (get-ffi-obj 'NSTableViewColumnDidMoveNotification _fw-lib _id))
(define NSTableViewColumnDidResizeNotification (get-ffi-obj 'NSTableViewColumnDidResizeNotification _fw-lib _id))
(define NSTableViewRowViewKey (get-ffi-obj 'NSTableViewRowViewKey _fw-lib _id))
(define NSTableViewSelectionDidChangeNotification (get-ffi-obj 'NSTableViewSelectionDidChangeNotification _fw-lib _id))
(define NSTableViewSelectionIsChangingNotification (get-ffi-obj 'NSTableViewSelectionIsChangingNotification _fw-lib _id))
(define NSTabularTextPboardType (get-ffi-obj 'NSTabularTextPboardType _fw-lib _id))
(define NSTargetBinding (get-ffi-obj 'NSTargetBinding _fw-lib _id))
(define NSTargetTextScalingDocumentOption (get-ffi-obj 'NSTargetTextScalingDocumentOption _fw-lib _id))
(define NSTextAlternativesAttributeName (get-ffi-obj 'NSTextAlternativesAttributeName _fw-lib _id))
(define NSTextAlternativesSelectedAlternativeStringNotification (get-ffi-obj 'NSTextAlternativesSelectedAlternativeStringNotification _fw-lib _id))
(define NSTextCheckingDocumentAuthorKey (get-ffi-obj 'NSTextCheckingDocumentAuthorKey _fw-lib _id))
(define NSTextCheckingDocumentTitleKey (get-ffi-obj 'NSTextCheckingDocumentTitleKey _fw-lib _id))
(define NSTextCheckingDocumentURLKey (get-ffi-obj 'NSTextCheckingDocumentURLKey _fw-lib _id))
(define NSTextCheckingGenerateInlinePredictionsKey (get-ffi-obj 'NSTextCheckingGenerateInlinePredictionsKey _fw-lib _id))
(define NSTextCheckingOrthographyKey (get-ffi-obj 'NSTextCheckingOrthographyKey _fw-lib _id))
(define NSTextCheckingQuotesKey (get-ffi-obj 'NSTextCheckingQuotesKey _fw-lib _id))
(define NSTextCheckingReferenceDateKey (get-ffi-obj 'NSTextCheckingReferenceDateKey _fw-lib _id))
(define NSTextCheckingReferenceTimeZoneKey (get-ffi-obj 'NSTextCheckingReferenceTimeZoneKey _fw-lib _id))
(define NSTextCheckingRegularExpressionsKey (get-ffi-obj 'NSTextCheckingRegularExpressionsKey _fw-lib _id))
(define NSTextCheckingReplacementsKey (get-ffi-obj 'NSTextCheckingReplacementsKey _fw-lib _id))
(define NSTextCheckingSelectedRangeKey (get-ffi-obj 'NSTextCheckingSelectedRangeKey _fw-lib _id))
(define NSTextColorBinding (get-ffi-obj 'NSTextColorBinding _fw-lib _id))
(define NSTextContentStorageUnsupportedAttributeAddedNotification (get-ffi-obj 'NSTextContentStorageUnsupportedAttributeAddedNotification _fw-lib _id))
(define NSTextContentTypeAddressCity (get-ffi-obj 'NSTextContentTypeAddressCity _fw-lib _id))
(define NSTextContentTypeAddressCityAndState (get-ffi-obj 'NSTextContentTypeAddressCityAndState _fw-lib _id))
(define NSTextContentTypeAddressState (get-ffi-obj 'NSTextContentTypeAddressState _fw-lib _id))
(define NSTextContentTypeBirthdate (get-ffi-obj 'NSTextContentTypeBirthdate _fw-lib _id))
(define NSTextContentTypeBirthdateDay (get-ffi-obj 'NSTextContentTypeBirthdateDay _fw-lib _id))
(define NSTextContentTypeBirthdateMonth (get-ffi-obj 'NSTextContentTypeBirthdateMonth _fw-lib _id))
(define NSTextContentTypeBirthdateYear (get-ffi-obj 'NSTextContentTypeBirthdateYear _fw-lib _id))
(define NSTextContentTypeCountryName (get-ffi-obj 'NSTextContentTypeCountryName _fw-lib _id))
(define NSTextContentTypeCreditCardExpiration (get-ffi-obj 'NSTextContentTypeCreditCardExpiration _fw-lib _id))
(define NSTextContentTypeCreditCardExpirationMonth (get-ffi-obj 'NSTextContentTypeCreditCardExpirationMonth _fw-lib _id))
(define NSTextContentTypeCreditCardExpirationYear (get-ffi-obj 'NSTextContentTypeCreditCardExpirationYear _fw-lib _id))
(define NSTextContentTypeCreditCardFamilyName (get-ffi-obj 'NSTextContentTypeCreditCardFamilyName _fw-lib _id))
(define NSTextContentTypeCreditCardGivenName (get-ffi-obj 'NSTextContentTypeCreditCardGivenName _fw-lib _id))
(define NSTextContentTypeCreditCardMiddleName (get-ffi-obj 'NSTextContentTypeCreditCardMiddleName _fw-lib _id))
(define NSTextContentTypeCreditCardName (get-ffi-obj 'NSTextContentTypeCreditCardName _fw-lib _id))
(define NSTextContentTypeCreditCardNumber (get-ffi-obj 'NSTextContentTypeCreditCardNumber _fw-lib _id))
(define NSTextContentTypeCreditCardSecurityCode (get-ffi-obj 'NSTextContentTypeCreditCardSecurityCode _fw-lib _id))
(define NSTextContentTypeCreditCardType (get-ffi-obj 'NSTextContentTypeCreditCardType _fw-lib _id))
(define NSTextContentTypeDateTime (get-ffi-obj 'NSTextContentTypeDateTime _fw-lib _id))
(define NSTextContentTypeEmailAddress (get-ffi-obj 'NSTextContentTypeEmailAddress _fw-lib _id))
(define NSTextContentTypeFamilyName (get-ffi-obj 'NSTextContentTypeFamilyName _fw-lib _id))
(define NSTextContentTypeFlightNumber (get-ffi-obj 'NSTextContentTypeFlightNumber _fw-lib _id))
(define NSTextContentTypeFullStreetAddress (get-ffi-obj 'NSTextContentTypeFullStreetAddress _fw-lib _id))
(define NSTextContentTypeGivenName (get-ffi-obj 'NSTextContentTypeGivenName _fw-lib _id))
(define NSTextContentTypeJobTitle (get-ffi-obj 'NSTextContentTypeJobTitle _fw-lib _id))
(define NSTextContentTypeLocation (get-ffi-obj 'NSTextContentTypeLocation _fw-lib _id))
(define NSTextContentTypeMiddleName (get-ffi-obj 'NSTextContentTypeMiddleName _fw-lib _id))
(define NSTextContentTypeName (get-ffi-obj 'NSTextContentTypeName _fw-lib _id))
(define NSTextContentTypeNamePrefix (get-ffi-obj 'NSTextContentTypeNamePrefix _fw-lib _id))
(define NSTextContentTypeNameSuffix (get-ffi-obj 'NSTextContentTypeNameSuffix _fw-lib _id))
(define NSTextContentTypeNewPassword (get-ffi-obj 'NSTextContentTypeNewPassword _fw-lib _id))
(define NSTextContentTypeNickname (get-ffi-obj 'NSTextContentTypeNickname _fw-lib _id))
(define NSTextContentTypeOneTimeCode (get-ffi-obj 'NSTextContentTypeOneTimeCode _fw-lib _id))
(define NSTextContentTypeOrganizationName (get-ffi-obj 'NSTextContentTypeOrganizationName _fw-lib _id))
(define NSTextContentTypePassword (get-ffi-obj 'NSTextContentTypePassword _fw-lib _id))
(define NSTextContentTypePostalCode (get-ffi-obj 'NSTextContentTypePostalCode _fw-lib _id))
(define NSTextContentTypeShipmentTrackingNumber (get-ffi-obj 'NSTextContentTypeShipmentTrackingNumber _fw-lib _id))
(define NSTextContentTypeStreetAddressLine1 (get-ffi-obj 'NSTextContentTypeStreetAddressLine1 _fw-lib _id))
(define NSTextContentTypeStreetAddressLine2 (get-ffi-obj 'NSTextContentTypeStreetAddressLine2 _fw-lib _id))
(define NSTextContentTypeSublocality (get-ffi-obj 'NSTextContentTypeSublocality _fw-lib _id))
(define NSTextContentTypeTelephoneNumber (get-ffi-obj 'NSTextContentTypeTelephoneNumber _fw-lib _id))
(define NSTextContentTypeURL (get-ffi-obj 'NSTextContentTypeURL _fw-lib _id))
(define NSTextContentTypeUsername (get-ffi-obj 'NSTextContentTypeUsername _fw-lib _id))
(define NSTextDidBeginEditingNotification (get-ffi-obj 'NSTextDidBeginEditingNotification _fw-lib _id))
(define NSTextDidChangeNotification (get-ffi-obj 'NSTextDidChangeNotification _fw-lib _id))
(define NSTextDidEndEditingNotification (get-ffi-obj 'NSTextDidEndEditingNotification _fw-lib _id))
(define NSTextEffectAttributeName (get-ffi-obj 'NSTextEffectAttributeName _fw-lib _id))
(define NSTextEffectLetterpressStyle (get-ffi-obj 'NSTextEffectLetterpressStyle _fw-lib _id))
(define NSTextEncodingNameDocumentAttribute (get-ffi-obj 'NSTextEncodingNameDocumentAttribute _fw-lib _id))
(define NSTextEncodingNameDocumentOption (get-ffi-obj 'NSTextEncodingNameDocumentOption _fw-lib _id))
(define NSTextFinderCaseInsensitiveKey (get-ffi-obj 'NSTextFinderCaseInsensitiveKey _fw-lib _id))
(define NSTextFinderMatchingTypeKey (get-ffi-obj 'NSTextFinderMatchingTypeKey _fw-lib _id))
(define NSTextHighlightColorSchemeAttributeName (get-ffi-obj 'NSTextHighlightColorSchemeAttributeName _fw-lib _id))
(define NSTextHighlightColorSchemeBlue (get-ffi-obj 'NSTextHighlightColorSchemeBlue _fw-lib _id))
(define NSTextHighlightColorSchemeDefault (get-ffi-obj 'NSTextHighlightColorSchemeDefault _fw-lib _id))
(define NSTextHighlightColorSchemeMint (get-ffi-obj 'NSTextHighlightColorSchemeMint _fw-lib _id))
(define NSTextHighlightColorSchemeOrange (get-ffi-obj 'NSTextHighlightColorSchemeOrange _fw-lib _id))
(define NSTextHighlightColorSchemePink (get-ffi-obj 'NSTextHighlightColorSchemePink _fw-lib _id))
(define NSTextHighlightColorSchemePurple (get-ffi-obj 'NSTextHighlightColorSchemePurple _fw-lib _id))
(define NSTextHighlightStyleAttributeName (get-ffi-obj 'NSTextHighlightStyleAttributeName _fw-lib _id))
(define NSTextHighlightStyleDefault (get-ffi-obj 'NSTextHighlightStyleDefault _fw-lib _id))
(define NSTextInputContextKeyboardSelectionDidChangeNotification (get-ffi-obj 'NSTextInputContextKeyboardSelectionDidChangeNotification _fw-lib _id))
(define NSTextKit1ListMarkerFormatDocumentOption (get-ffi-obj 'NSTextKit1ListMarkerFormatDocumentOption _fw-lib _id))
(define NSTextLayoutSectionOrientation (get-ffi-obj 'NSTextLayoutSectionOrientation _fw-lib _id))
(define NSTextLayoutSectionRange (get-ffi-obj 'NSTextLayoutSectionRange _fw-lib _id))
(define NSTextLayoutSectionsAttribute (get-ffi-obj 'NSTextLayoutSectionsAttribute _fw-lib _id))
(define NSTextLineTooLongException (get-ffi-obj 'NSTextLineTooLongException _fw-lib _id))
(define NSTextListMarkerBox (get-ffi-obj 'NSTextListMarkerBox _fw-lib _id))
(define NSTextListMarkerCheck (get-ffi-obj 'NSTextListMarkerCheck _fw-lib _id))
(define NSTextListMarkerCircle (get-ffi-obj 'NSTextListMarkerCircle _fw-lib _id))
(define NSTextListMarkerDecimal (get-ffi-obj 'NSTextListMarkerDecimal _fw-lib _id))
(define NSTextListMarkerDiamond (get-ffi-obj 'NSTextListMarkerDiamond _fw-lib _id))
(define NSTextListMarkerDisc (get-ffi-obj 'NSTextListMarkerDisc _fw-lib _id))
(define NSTextListMarkerHyphen (get-ffi-obj 'NSTextListMarkerHyphen _fw-lib _id))
(define NSTextListMarkerLowercaseAlpha (get-ffi-obj 'NSTextListMarkerLowercaseAlpha _fw-lib _id))
(define NSTextListMarkerLowercaseHexadecimal (get-ffi-obj 'NSTextListMarkerLowercaseHexadecimal _fw-lib _id))
(define NSTextListMarkerLowercaseLatin (get-ffi-obj 'NSTextListMarkerLowercaseLatin _fw-lib _id))
(define NSTextListMarkerLowercaseRoman (get-ffi-obj 'NSTextListMarkerLowercaseRoman _fw-lib _id))
(define NSTextListMarkerOctal (get-ffi-obj 'NSTextListMarkerOctal _fw-lib _id))
(define NSTextListMarkerSquare (get-ffi-obj 'NSTextListMarkerSquare _fw-lib _id))
(define NSTextListMarkerUppercaseAlpha (get-ffi-obj 'NSTextListMarkerUppercaseAlpha _fw-lib _id))
(define NSTextListMarkerUppercaseHexadecimal (get-ffi-obj 'NSTextListMarkerUppercaseHexadecimal _fw-lib _id))
(define NSTextListMarkerUppercaseLatin (get-ffi-obj 'NSTextListMarkerUppercaseLatin _fw-lib _id))
(define NSTextListMarkerUppercaseRoman (get-ffi-obj 'NSTextListMarkerUppercaseRoman _fw-lib _id))
(define NSTextMovementUserInfoKey (get-ffi-obj 'NSTextMovementUserInfoKey _fw-lib _id))
(define NSTextNoSelectionException (get-ffi-obj 'NSTextNoSelectionException _fw-lib _id))
(define NSTextReadException (get-ffi-obj 'NSTextReadException _fw-lib _id))
(define NSTextScalingDocumentAttribute (get-ffi-obj 'NSTextScalingDocumentAttribute _fw-lib _id))
(define NSTextSizeMultiplierDocumentOption (get-ffi-obj 'NSTextSizeMultiplierDocumentOption _fw-lib _id))
(define NSTextStorageDidProcessEditingNotification (get-ffi-obj 'NSTextStorageDidProcessEditingNotification _fw-lib _id))
(define NSTextStorageWillProcessEditingNotification (get-ffi-obj 'NSTextStorageWillProcessEditingNotification _fw-lib _id))
(define NSTextViewDidChangeSelectionNotification (get-ffi-obj 'NSTextViewDidChangeSelectionNotification _fw-lib _id))
(define NSTextViewDidChangeTypingAttributesNotification (get-ffi-obj 'NSTextViewDidChangeTypingAttributesNotification _fw-lib _id))
(define NSTextViewDidSwitchToNSLayoutManagerNotification (get-ffi-obj 'NSTextViewDidSwitchToNSLayoutManagerNotification _fw-lib _id))
(define NSTextViewWillChangeNotifyingTextViewNotification (get-ffi-obj 'NSTextViewWillChangeNotifyingTextViewNotification _fw-lib _id))
(define NSTextViewWillSwitchToNSLayoutManagerNotification (get-ffi-obj 'NSTextViewWillSwitchToNSLayoutManagerNotification _fw-lib _id))
(define NSTextWriteException (get-ffi-obj 'NSTextWriteException _fw-lib _id))
(define NSTimeoutDocumentOption (get-ffi-obj 'NSTimeoutDocumentOption _fw-lib _id))
(define NSTitleBinding (get-ffi-obj 'NSTitleBinding _fw-lib _id))
(define NSTitleDocumentAttribute (get-ffi-obj 'NSTitleDocumentAttribute _fw-lib _id))
(define NSToolTipAttributeName (get-ffi-obj 'NSToolTipAttributeName _fw-lib _id))
(define NSToolTipBinding (get-ffi-obj 'NSToolTipBinding _fw-lib _id))
(define NSToolbarCloudSharingItemIdentifier (get-ffi-obj 'NSToolbarCloudSharingItemIdentifier _fw-lib _id))
(define NSToolbarCustomizeToolbarItemIdentifier (get-ffi-obj 'NSToolbarCustomizeToolbarItemIdentifier _fw-lib _id))
(define NSToolbarDidRemoveItemNotification (get-ffi-obj 'NSToolbarDidRemoveItemNotification _fw-lib _id))
(define NSToolbarFlexibleSpaceItemIdentifier (get-ffi-obj 'NSToolbarFlexibleSpaceItemIdentifier _fw-lib _id))
(define NSToolbarInspectorTrackingSeparatorItemIdentifier (get-ffi-obj 'NSToolbarInspectorTrackingSeparatorItemIdentifier _fw-lib _id))
(define NSToolbarItemKey (get-ffi-obj 'NSToolbarItemKey _fw-lib _id))
(define NSToolbarNewIndexKey (get-ffi-obj 'NSToolbarNewIndexKey _fw-lib _id))
(define NSToolbarPrintItemIdentifier (get-ffi-obj 'NSToolbarPrintItemIdentifier _fw-lib _id))
(define NSToolbarSeparatorItemIdentifier (get-ffi-obj 'NSToolbarSeparatorItemIdentifier _fw-lib _id))
(define NSToolbarShowColorsItemIdentifier (get-ffi-obj 'NSToolbarShowColorsItemIdentifier _fw-lib _id))
(define NSToolbarShowFontsItemIdentifier (get-ffi-obj 'NSToolbarShowFontsItemIdentifier _fw-lib _id))
(define NSToolbarSidebarTrackingSeparatorItemIdentifier (get-ffi-obj 'NSToolbarSidebarTrackingSeparatorItemIdentifier _fw-lib _id))
(define NSToolbarSpaceItemIdentifier (get-ffi-obj 'NSToolbarSpaceItemIdentifier _fw-lib _id))
(define NSToolbarToggleInspectorItemIdentifier (get-ffi-obj 'NSToolbarToggleInspectorItemIdentifier _fw-lib _id))
(define NSToolbarToggleSidebarItemIdentifier (get-ffi-obj 'NSToolbarToggleSidebarItemIdentifier _fw-lib _id))
(define NSToolbarWillAddItemNotification (get-ffi-obj 'NSToolbarWillAddItemNotification _fw-lib _id))
(define NSToolbarWritingToolsItemIdentifier (get-ffi-obj 'NSToolbarWritingToolsItemIdentifier _fw-lib _id))
(define NSTopMarginDocumentAttribute (get-ffi-obj 'NSTopMarginDocumentAttribute _fw-lib _id))
(define NSTouchBarItemIdentifierCandidateList (get-ffi-obj 'NSTouchBarItemIdentifierCandidateList _fw-lib _id))
(define NSTouchBarItemIdentifierCharacterPicker (get-ffi-obj 'NSTouchBarItemIdentifierCharacterPicker _fw-lib _id))
(define NSTouchBarItemIdentifierFixedSpaceLarge (get-ffi-obj 'NSTouchBarItemIdentifierFixedSpaceLarge _fw-lib _id))
(define NSTouchBarItemIdentifierFixedSpaceSmall (get-ffi-obj 'NSTouchBarItemIdentifierFixedSpaceSmall _fw-lib _id))
(define NSTouchBarItemIdentifierFlexibleSpace (get-ffi-obj 'NSTouchBarItemIdentifierFlexibleSpace _fw-lib _id))
(define NSTouchBarItemIdentifierOtherItemsProxy (get-ffi-obj 'NSTouchBarItemIdentifierOtherItemsProxy _fw-lib _id))
(define NSTouchBarItemIdentifierTextAlignment (get-ffi-obj 'NSTouchBarItemIdentifierTextAlignment _fw-lib _id))
(define NSTouchBarItemIdentifierTextColorPicker (get-ffi-obj 'NSTouchBarItemIdentifierTextColorPicker _fw-lib _id))
(define NSTouchBarItemIdentifierTextFormat (get-ffi-obj 'NSTouchBarItemIdentifierTextFormat _fw-lib _id))
(define NSTouchBarItemIdentifierTextList (get-ffi-obj 'NSTouchBarItemIdentifierTextList _fw-lib _id))
(define NSTouchBarItemIdentifierTextStyle (get-ffi-obj 'NSTouchBarItemIdentifierTextStyle _fw-lib _id))
(define NSTrackingAttributeName (get-ffi-obj 'NSTrackingAttributeName _fw-lib _id))
(define NSTransparentBinding (get-ffi-obj 'NSTransparentBinding _fw-lib _id))
(define NSTypeIdentifierAddressText (get-ffi-obj 'NSTypeIdentifierAddressText _fw-lib _id))
(define NSTypeIdentifierDateText (get-ffi-obj 'NSTypeIdentifierDateText _fw-lib _id))
(define NSTypeIdentifierPhoneNumberText (get-ffi-obj 'NSTypeIdentifierPhoneNumberText _fw-lib _id))
(define NSTypeIdentifierTransitInformationText (get-ffi-obj 'NSTypeIdentifierTransitInformationText _fw-lib _id))
(define NSTypedStreamVersionException (get-ffi-obj 'NSTypedStreamVersionException _fw-lib _id))
(define NSURLPboardType (get-ffi-obj 'NSURLPboardType _fw-lib _id))
(define NSUnderlineByWordMask (get-ffi-obj 'NSUnderlineByWordMask _fw-lib _uint64))
(define NSUnderlineColorAttributeName (get-ffi-obj 'NSUnderlineColorAttributeName _fw-lib _id))
(define NSUnderlineStrikethroughMask (get-ffi-obj 'NSUnderlineStrikethroughMask _fw-lib _uint64))
(define NSUnderlineStyleAttributeName (get-ffi-obj 'NSUnderlineStyleAttributeName _fw-lib _id))
(define NSUserActivityDocumentURLKey (get-ffi-obj 'NSUserActivityDocumentURLKey _fw-lib _id))
(define NSUsesScreenFontsDocumentAttribute (get-ffi-obj 'NSUsesScreenFontsDocumentAttribute _fw-lib _id))
(define NSVCardPboardType (get-ffi-obj 'NSVCardPboardType _fw-lib _id))
(define NSValidatesImmediatelyBindingOption (get-ffi-obj 'NSValidatesImmediatelyBindingOption _fw-lib _id))
(define NSValueBinding (get-ffi-obj 'NSValueBinding _fw-lib _id))
(define NSValuePathBinding (get-ffi-obj 'NSValuePathBinding _fw-lib _id))
(define NSValueTransformerBindingOption (get-ffi-obj 'NSValueTransformerBindingOption _fw-lib _id))
(define NSValueTransformerNameBindingOption (get-ffi-obj 'NSValueTransformerNameBindingOption _fw-lib _id))
(define NSValueURLBinding (get-ffi-obj 'NSValueURLBinding _fw-lib _id))
(define NSVerticalGlyphFormAttributeName (get-ffi-obj 'NSVerticalGlyphFormAttributeName _fw-lib _id))
(define NSViewAnimationEffectKey (get-ffi-obj 'NSViewAnimationEffectKey _fw-lib _id))
(define NSViewAnimationEndFrameKey (get-ffi-obj 'NSViewAnimationEndFrameKey _fw-lib _id))
(define NSViewAnimationFadeInEffect (get-ffi-obj 'NSViewAnimationFadeInEffect _fw-lib _id))
(define NSViewAnimationFadeOutEffect (get-ffi-obj 'NSViewAnimationFadeOutEffect _fw-lib _id))
(define NSViewAnimationStartFrameKey (get-ffi-obj 'NSViewAnimationStartFrameKey _fw-lib _id))
(define NSViewAnimationTargetKey (get-ffi-obj 'NSViewAnimationTargetKey _fw-lib _id))
(define NSViewBoundsDidChangeNotification (get-ffi-obj 'NSViewBoundsDidChangeNotification _fw-lib _id))
(define NSViewDidUpdateTrackingAreasNotification (get-ffi-obj 'NSViewDidUpdateTrackingAreasNotification _fw-lib _id))
(define NSViewFocusDidChangeNotification (get-ffi-obj 'NSViewFocusDidChangeNotification _fw-lib _id))
(define NSViewFrameDidChangeNotification (get-ffi-obj 'NSViewFrameDidChangeNotification _fw-lib _id))
(define NSViewGlobalFrameDidChangeNotification (get-ffi-obj 'NSViewGlobalFrameDidChangeNotification _fw-lib _id))
(define NSViewModeDocumentAttribute (get-ffi-obj 'NSViewModeDocumentAttribute _fw-lib _id))
(define NSViewNoInstrinsicMetric (get-ffi-obj 'NSViewNoInstrinsicMetric _fw-lib _double))
(define NSViewNoIntrinsicMetric (get-ffi-obj 'NSViewNoIntrinsicMetric _fw-lib _double))
(define NSViewSizeDocumentAttribute (get-ffi-obj 'NSViewSizeDocumentAttribute _fw-lib _id))
(define NSViewZoomDocumentAttribute (get-ffi-obj 'NSViewZoomDocumentAttribute _fw-lib _id))
(define NSVisibleBinding (get-ffi-obj 'NSVisibleBinding _fw-lib _id))
(define NSVoiceAge (get-ffi-obj 'NSVoiceAge _fw-lib _id))
(define NSVoiceDemoText (get-ffi-obj 'NSVoiceDemoText _fw-lib _id))
(define NSVoiceGender (get-ffi-obj 'NSVoiceGender _fw-lib _id))
(define NSVoiceGenderFemale (get-ffi-obj 'NSVoiceGenderFemale _fw-lib _id))
(define NSVoiceGenderMale (get-ffi-obj 'NSVoiceGenderMale _fw-lib _id))
(define NSVoiceGenderNeuter (get-ffi-obj 'NSVoiceGenderNeuter _fw-lib _id))
(define NSVoiceGenderNeutral (get-ffi-obj 'NSVoiceGenderNeutral _fw-lib _id))
(define NSVoiceIdentifier (get-ffi-obj 'NSVoiceIdentifier _fw-lib _id))
(define NSVoiceIndividuallySpokenCharacters (get-ffi-obj 'NSVoiceIndividuallySpokenCharacters _fw-lib _id))
(define NSVoiceLanguage (get-ffi-obj 'NSVoiceLanguage _fw-lib _id))
(define NSVoiceLocaleIdentifier (get-ffi-obj 'NSVoiceLocaleIdentifier _fw-lib _id))
(define NSVoiceName (get-ffi-obj 'NSVoiceName _fw-lib _id))
(define NSVoiceSupportedCharacters (get-ffi-obj 'NSVoiceSupportedCharacters _fw-lib _id))
(define NSWarningValueBinding (get-ffi-obj 'NSWarningValueBinding _fw-lib _id))
(define NSWebArchiveTextDocumentType (get-ffi-obj 'NSWebArchiveTextDocumentType _fw-lib _id))
(define NSWebPreferencesDocumentOption (get-ffi-obj 'NSWebPreferencesDocumentOption _fw-lib _id))
(define NSWebResourceLoadDelegateDocumentOption (get-ffi-obj 'NSWebResourceLoadDelegateDocumentOption _fw-lib _id))
(define NSWhite (get-ffi-obj 'NSWhite _fw-lib _double))
(define NSWidthBinding (get-ffi-obj 'NSWidthBinding _fw-lib _id))
(define NSWindowDidBecomeKeyNotification (get-ffi-obj 'NSWindowDidBecomeKeyNotification _fw-lib _id))
(define NSWindowDidBecomeMainNotification (get-ffi-obj 'NSWindowDidBecomeMainNotification _fw-lib _id))
(define NSWindowDidChangeBackingPropertiesNotification (get-ffi-obj 'NSWindowDidChangeBackingPropertiesNotification _fw-lib _id))
(define NSWindowDidChangeOcclusionStateNotification (get-ffi-obj 'NSWindowDidChangeOcclusionStateNotification _fw-lib _id))
(define NSWindowDidChangeScreenNotification (get-ffi-obj 'NSWindowDidChangeScreenNotification _fw-lib _id))
(define NSWindowDidChangeScreenProfileNotification (get-ffi-obj 'NSWindowDidChangeScreenProfileNotification _fw-lib _id))
(define NSWindowDidDeminiaturizeNotification (get-ffi-obj 'NSWindowDidDeminiaturizeNotification _fw-lib _id))
(define NSWindowDidEndLiveResizeNotification (get-ffi-obj 'NSWindowDidEndLiveResizeNotification _fw-lib _id))
(define NSWindowDidEndSheetNotification (get-ffi-obj 'NSWindowDidEndSheetNotification _fw-lib _id))
(define NSWindowDidEnterFullScreenNotification (get-ffi-obj 'NSWindowDidEnterFullScreenNotification _fw-lib _id))
(define NSWindowDidEnterVersionBrowserNotification (get-ffi-obj 'NSWindowDidEnterVersionBrowserNotification _fw-lib _id))
(define NSWindowDidExitFullScreenNotification (get-ffi-obj 'NSWindowDidExitFullScreenNotification _fw-lib _id))
(define NSWindowDidExitVersionBrowserNotification (get-ffi-obj 'NSWindowDidExitVersionBrowserNotification _fw-lib _id))
(define NSWindowDidExposeNotification (get-ffi-obj 'NSWindowDidExposeNotification _fw-lib _id))
(define NSWindowDidMiniaturizeNotification (get-ffi-obj 'NSWindowDidMiniaturizeNotification _fw-lib _id))
(define NSWindowDidMoveNotification (get-ffi-obj 'NSWindowDidMoveNotification _fw-lib _id))
(define NSWindowDidResignKeyNotification (get-ffi-obj 'NSWindowDidResignKeyNotification _fw-lib _id))
(define NSWindowDidResignMainNotification (get-ffi-obj 'NSWindowDidResignMainNotification _fw-lib _id))
(define NSWindowDidResizeNotification (get-ffi-obj 'NSWindowDidResizeNotification _fw-lib _id))
(define NSWindowDidUpdateNotification (get-ffi-obj 'NSWindowDidUpdateNotification _fw-lib _id))
(define NSWindowServerCommunicationException (get-ffi-obj 'NSWindowServerCommunicationException _fw-lib _id))
(define NSWindowWillBeginSheetNotification (get-ffi-obj 'NSWindowWillBeginSheetNotification _fw-lib _id))
(define NSWindowWillCloseNotification (get-ffi-obj 'NSWindowWillCloseNotification _fw-lib _id))
(define NSWindowWillEnterFullScreenNotification (get-ffi-obj 'NSWindowWillEnterFullScreenNotification _fw-lib _id))
(define NSWindowWillEnterVersionBrowserNotification (get-ffi-obj 'NSWindowWillEnterVersionBrowserNotification _fw-lib _id))
(define NSWindowWillExitFullScreenNotification (get-ffi-obj 'NSWindowWillExitFullScreenNotification _fw-lib _id))
(define NSWindowWillExitVersionBrowserNotification (get-ffi-obj 'NSWindowWillExitVersionBrowserNotification _fw-lib _id))
(define NSWindowWillMiniaturizeNotification (get-ffi-obj 'NSWindowWillMiniaturizeNotification _fw-lib _id))
(define NSWindowWillMoveNotification (get-ffi-obj 'NSWindowWillMoveNotification _fw-lib _id))
(define NSWindowWillStartLiveResizeNotification (get-ffi-obj 'NSWindowWillStartLiveResizeNotification _fw-lib _id))
(define NSWordMLTextDocumentType (get-ffi-obj 'NSWordMLTextDocumentType _fw-lib _id))
(define NSWordTablesReadException (get-ffi-obj 'NSWordTablesReadException _fw-lib _id))
(define NSWordTablesWriteException (get-ffi-obj 'NSWordTablesWriteException _fw-lib _id))
(define NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification (get-ffi-obj 'NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification _fw-lib _id))
(define NSWorkspaceActiveSpaceDidChangeNotification (get-ffi-obj 'NSWorkspaceActiveSpaceDidChangeNotification _fw-lib _id))
(define NSWorkspaceApplicationKey (get-ffi-obj 'NSWorkspaceApplicationKey _fw-lib _id))
(define NSWorkspaceCompressOperation (get-ffi-obj 'NSWorkspaceCompressOperation _fw-lib _id))
(define NSWorkspaceCopyOperation (get-ffi-obj 'NSWorkspaceCopyOperation _fw-lib _id))
(define NSWorkspaceDecompressOperation (get-ffi-obj 'NSWorkspaceDecompressOperation _fw-lib _id))
(define NSWorkspaceDecryptOperation (get-ffi-obj 'NSWorkspaceDecryptOperation _fw-lib _id))
(define NSWorkspaceDesktopImageAllowClippingKey (get-ffi-obj 'NSWorkspaceDesktopImageAllowClippingKey _fw-lib _id))
(define NSWorkspaceDesktopImageFillColorKey (get-ffi-obj 'NSWorkspaceDesktopImageFillColorKey _fw-lib _id))
(define NSWorkspaceDesktopImageScalingKey (get-ffi-obj 'NSWorkspaceDesktopImageScalingKey _fw-lib _id))
(define NSWorkspaceDestroyOperation (get-ffi-obj 'NSWorkspaceDestroyOperation _fw-lib _id))
(define NSWorkspaceDidActivateApplicationNotification (get-ffi-obj 'NSWorkspaceDidActivateApplicationNotification _fw-lib _id))
(define NSWorkspaceDidChangeFileLabelsNotification (get-ffi-obj 'NSWorkspaceDidChangeFileLabelsNotification _fw-lib _id))
(define NSWorkspaceDidDeactivateApplicationNotification (get-ffi-obj 'NSWorkspaceDidDeactivateApplicationNotification _fw-lib _id))
(define NSWorkspaceDidHideApplicationNotification (get-ffi-obj 'NSWorkspaceDidHideApplicationNotification _fw-lib _id))
(define NSWorkspaceDidLaunchApplicationNotification (get-ffi-obj 'NSWorkspaceDidLaunchApplicationNotification _fw-lib _id))
(define NSWorkspaceDidMountNotification (get-ffi-obj 'NSWorkspaceDidMountNotification _fw-lib _id))
(define NSWorkspaceDidPerformFileOperationNotification (get-ffi-obj 'NSWorkspaceDidPerformFileOperationNotification _fw-lib _id))
(define NSWorkspaceDidRenameVolumeNotification (get-ffi-obj 'NSWorkspaceDidRenameVolumeNotification _fw-lib _id))
(define NSWorkspaceDidTerminateApplicationNotification (get-ffi-obj 'NSWorkspaceDidTerminateApplicationNotification _fw-lib _id))
(define NSWorkspaceDidUnhideApplicationNotification (get-ffi-obj 'NSWorkspaceDidUnhideApplicationNotification _fw-lib _id))
(define NSWorkspaceDidUnmountNotification (get-ffi-obj 'NSWorkspaceDidUnmountNotification _fw-lib _id))
(define NSWorkspaceDidWakeNotification (get-ffi-obj 'NSWorkspaceDidWakeNotification _fw-lib _id))
(define NSWorkspaceDuplicateOperation (get-ffi-obj 'NSWorkspaceDuplicateOperation _fw-lib _id))
(define NSWorkspaceEncryptOperation (get-ffi-obj 'NSWorkspaceEncryptOperation _fw-lib _id))
(define NSWorkspaceLaunchConfigurationAppleEvent (get-ffi-obj 'NSWorkspaceLaunchConfigurationAppleEvent _fw-lib _id))
(define NSWorkspaceLaunchConfigurationArchitecture (get-ffi-obj 'NSWorkspaceLaunchConfigurationArchitecture _fw-lib _id))
(define NSWorkspaceLaunchConfigurationArguments (get-ffi-obj 'NSWorkspaceLaunchConfigurationArguments _fw-lib _id))
(define NSWorkspaceLaunchConfigurationEnvironment (get-ffi-obj 'NSWorkspaceLaunchConfigurationEnvironment _fw-lib _id))
(define NSWorkspaceLinkOperation (get-ffi-obj 'NSWorkspaceLinkOperation _fw-lib _id))
(define NSWorkspaceMoveOperation (get-ffi-obj 'NSWorkspaceMoveOperation _fw-lib _id))
(define NSWorkspaceRecycleOperation (get-ffi-obj 'NSWorkspaceRecycleOperation _fw-lib _id))
(define NSWorkspaceScreensDidSleepNotification (get-ffi-obj 'NSWorkspaceScreensDidSleepNotification _fw-lib _id))
(define NSWorkspaceScreensDidWakeNotification (get-ffi-obj 'NSWorkspaceScreensDidWakeNotification _fw-lib _id))
(define NSWorkspaceSessionDidBecomeActiveNotification (get-ffi-obj 'NSWorkspaceSessionDidBecomeActiveNotification _fw-lib _id))
(define NSWorkspaceSessionDidResignActiveNotification (get-ffi-obj 'NSWorkspaceSessionDidResignActiveNotification _fw-lib _id))
(define NSWorkspaceVolumeLocalizedNameKey (get-ffi-obj 'NSWorkspaceVolumeLocalizedNameKey _fw-lib _id))
(define NSWorkspaceVolumeOldLocalizedNameKey (get-ffi-obj 'NSWorkspaceVolumeOldLocalizedNameKey _fw-lib _id))
(define NSWorkspaceVolumeOldURLKey (get-ffi-obj 'NSWorkspaceVolumeOldURLKey _fw-lib _id))
(define NSWorkspaceVolumeURLKey (get-ffi-obj 'NSWorkspaceVolumeURLKey _fw-lib _id))
(define NSWorkspaceWillLaunchApplicationNotification (get-ffi-obj 'NSWorkspaceWillLaunchApplicationNotification _fw-lib _id))
(define NSWorkspaceWillPowerOffNotification (get-ffi-obj 'NSWorkspaceWillPowerOffNotification _fw-lib _id))
(define NSWorkspaceWillSleepNotification (get-ffi-obj 'NSWorkspaceWillSleepNotification _fw-lib _id))
(define NSWorkspaceWillUnmountNotification (get-ffi-obj 'NSWorkspaceWillUnmountNotification _fw-lib _id))
(define NSWritingDirectionAttributeName (get-ffi-obj 'NSWritingDirectionAttributeName _fw-lib _id))
(define NSWritingToolsExclusionAttributeName (get-ffi-obj 'NSWritingToolsExclusionAttributeName _fw-lib _id))
