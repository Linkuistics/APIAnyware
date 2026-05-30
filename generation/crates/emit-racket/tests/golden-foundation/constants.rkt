#lang racket/base
;; Generated constant definitions for Foundation

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->]))

(provide/contract
  [NSAMPMDesignation cpointer?]
  [NSAlternateDescriptionAttributeName cpointer?]
  [NSAppleEventManagerWillProcessFirstEventNotification cpointer?]
  [NSAppleEventTimeOutDefault real?]
  [NSAppleEventTimeOutNone real?]
  [NSAppleScriptErrorAppName cpointer?]
  [NSAppleScriptErrorBriefMessage cpointer?]
  [NSAppleScriptErrorMessage cpointer?]
  [NSAppleScriptErrorNumber cpointer?]
  [NSAppleScriptErrorRange cpointer?]
  [NSArgumentDomain cpointer?]
  [NSAssertionHandlerKey cpointer?]
  [NSAverageKeyValueOperator cpointer?]
  [NSBuddhistCalendar cpointer?]
  [NSBundleDidLoadNotification cpointer?]
  [NSCalendarDayChangedNotification cpointer?]
  [NSCalendarIdentifierBangla cpointer?]
  [NSCalendarIdentifierBuddhist cpointer?]
  [NSCalendarIdentifierChinese cpointer?]
  [NSCalendarIdentifierCoptic cpointer?]
  [NSCalendarIdentifierDangi cpointer?]
  [NSCalendarIdentifierEthiopicAmeteAlem cpointer?]
  [NSCalendarIdentifierEthiopicAmeteMihret cpointer?]
  [NSCalendarIdentifierGregorian cpointer?]
  [NSCalendarIdentifierGujarati cpointer?]
  [NSCalendarIdentifierHebrew cpointer?]
  [NSCalendarIdentifierISO8601 cpointer?]
  [NSCalendarIdentifierIndian cpointer?]
  [NSCalendarIdentifierIslamic cpointer?]
  [NSCalendarIdentifierIslamicCivil cpointer?]
  [NSCalendarIdentifierIslamicTabular cpointer?]
  [NSCalendarIdentifierIslamicUmmAlQura cpointer?]
  [NSCalendarIdentifierJapanese cpointer?]
  [NSCalendarIdentifierKannada cpointer?]
  [NSCalendarIdentifierMalayalam cpointer?]
  [NSCalendarIdentifierMarathi cpointer?]
  [NSCalendarIdentifierOdia cpointer?]
  [NSCalendarIdentifierPersian cpointer?]
  [NSCalendarIdentifierRepublicOfChina cpointer?]
  [NSCalendarIdentifierTamil cpointer?]
  [NSCalendarIdentifierTelugu cpointer?]
  [NSCalendarIdentifierVietnamese cpointer?]
  [NSCalendarIdentifierVikram cpointer?]
  [NSCharacterConversionException cpointer?]
  [NSChineseCalendar cpointer?]
  [NSClassDescriptionNeededForClassNotification cpointer?]
  [NSCocoaErrorDomain cpointer?]
  [NSConnectionDidDieNotification cpointer?]
  [NSConnectionDidInitializeNotification cpointer?]
  [NSConnectionReplyMode cpointer?]
  [NSCountKeyValueOperator cpointer?]
  [NSCurrencySymbol cpointer?]
  [NSCurrentLocaleDidChangeNotification cpointer?]
  [NSDateFormatString cpointer?]
  [NSDateTimeOrdering cpointer?]
  [NSDebugDescriptionErrorKey cpointer?]
  [NSDecimalDigits cpointer?]
  [NSDecimalNumberDivideByZeroException cpointer?]
  [NSDecimalNumberExactnessException cpointer?]
  [NSDecimalNumberOverflowException cpointer?]
  [NSDecimalNumberUnderflowException cpointer?]
  [NSDecimalSeparator cpointer?]
  [NSDefaultRunLoopMode cpointer?]
  [NSDestinationInvalidException cpointer?]
  [NSDidBecomeSingleThreadedNotification cpointer?]
  [NSDistinctUnionOfArraysKeyValueOperator cpointer?]
  [NSDistinctUnionOfObjectsKeyValueOperator cpointer?]
  [NSDistinctUnionOfSetsKeyValueOperator cpointer?]
  [NSEarlierTimeDesignations cpointer?]
  [NSEdgeInsetsZero cpointer?]
  [NSErrorFailingURLStringKey cpointer?]
  [NSExtensionItemAttachmentsKey cpointer?]
  [NSExtensionItemAttributedContentTextKey cpointer?]
  [NSExtensionItemAttributedTitleKey cpointer?]
  [NSExtensionItemsAndErrorsKey cpointer?]
  [NSExtensionJavaScriptPreprocessingResultsKey cpointer?]
  [NSFTPPropertyActiveTransferModeKey cpointer?]
  [NSFTPPropertyFTPProxy cpointer?]
  [NSFTPPropertyFileOffsetKey cpointer?]
  [NSFTPPropertyUserLoginKey cpointer?]
  [NSFTPPropertyUserPasswordKey cpointer?]
  [NSFailedAuthenticationException cpointer?]
  [NSFileAppendOnly cpointer?]
  [NSFileBusy cpointer?]
  [NSFileCreationDate cpointer?]
  [NSFileDeviceIdentifier cpointer?]
  [NSFileExtensionHidden cpointer?]
  [NSFileGroupOwnerAccountID cpointer?]
  [NSFileGroupOwnerAccountName cpointer?]
  [NSFileHFSCreatorCode cpointer?]
  [NSFileHFSTypeCode cpointer?]
  [NSFileHandleConnectionAcceptedNotification cpointer?]
  [NSFileHandleDataAvailableNotification cpointer?]
  [NSFileHandleNotificationDataItem cpointer?]
  [NSFileHandleNotificationFileHandleItem cpointer?]
  [NSFileHandleNotificationMonitorModes cpointer?]
  [NSFileHandleOperationException cpointer?]
  [NSFileHandleReadCompletionNotification cpointer?]
  [NSFileHandleReadToEndOfFileCompletionNotification cpointer?]
  [NSFileImmutable cpointer?]
  [NSFileManagerUnmountDissentingProcessIdentifierErrorKey cpointer?]
  [NSFileModificationDate cpointer?]
  [NSFileOwnerAccountID cpointer?]
  [NSFileOwnerAccountName cpointer?]
  [NSFilePathErrorKey cpointer?]
  [NSFilePosixPermissions cpointer?]
  [NSFileProtectionComplete cpointer?]
  [NSFileProtectionCompleteUnlessOpen cpointer?]
  [NSFileProtectionCompleteUntilFirstUserAuthentication cpointer?]
  [NSFileProtectionKey cpointer?]
  [NSFileProtectionNone cpointer?]
  [NSFileReferenceCount cpointer?]
  [NSFileSize cpointer?]
  [NSFileSystemFileNumber cpointer?]
  [NSFileSystemFreeNodes cpointer?]
  [NSFileSystemFreeSize cpointer?]
  [NSFileSystemNodes cpointer?]
  [NSFileSystemNumber cpointer?]
  [NSFileSystemSize cpointer?]
  [NSFileType cpointer?]
  [NSFileTypeBlockSpecial cpointer?]
  [NSFileTypeCharacterSpecial cpointer?]
  [NSFileTypeDirectory cpointer?]
  [NSFileTypeRegular cpointer?]
  [NSFileTypeSocket cpointer?]
  [NSFileTypeSymbolicLink cpointer?]
  [NSFileTypeUnknown cpointer?]
  [NSFoundationVersionNumber real?]
  [NSGenericException cpointer?]
  [NSGlobalDomain cpointer?]
  [NSGrammarCorrections cpointer?]
  [NSGrammarRange cpointer?]
  [NSGrammarUserDescription cpointer?]
  [NSGregorianCalendar cpointer?]
  [NSHTTPCookieComment cpointer?]
  [NSHTTPCookieCommentURL cpointer?]
  [NSHTTPCookieDiscard cpointer?]
  [NSHTTPCookieDomain cpointer?]
  [NSHTTPCookieExpires cpointer?]
  [NSHTTPCookieManagerAcceptPolicyChangedNotification cpointer?]
  [NSHTTPCookieManagerCookiesChangedNotification cpointer?]
  [NSHTTPCookieMaximumAge cpointer?]
  [NSHTTPCookieName cpointer?]
  [NSHTTPCookieOriginURL cpointer?]
  [NSHTTPCookiePath cpointer?]
  [NSHTTPCookiePort cpointer?]
  [NSHTTPCookieSameSiteLax cpointer?]
  [NSHTTPCookieSameSitePolicy cpointer?]
  [NSHTTPCookieSameSiteStrict cpointer?]
  [NSHTTPCookieSecure cpointer?]
  [NSHTTPCookieSetByJavaScript cpointer?]
  [NSHTTPCookieValue cpointer?]
  [NSHTTPCookieVersion cpointer?]
  [NSHTTPPropertyErrorPageDataKey cpointer?]
  [NSHTTPPropertyHTTPProxy cpointer?]
  [NSHTTPPropertyRedirectionHeadersKey cpointer?]
  [NSHTTPPropertyServerHTTPVersionKey cpointer?]
  [NSHTTPPropertyStatusCodeKey cpointer?]
  [NSHTTPPropertyStatusReasonKey cpointer?]
  [NSHebrewCalendar cpointer?]
  [NSHelpAnchorErrorKey cpointer?]
  [NSHourNameDesignations cpointer?]
  [NSISO8601Calendar cpointer?]
  [NSImageURLAttributeName cpointer?]
  [NSInconsistentArchiveException cpointer?]
  [NSIndianCalendar cpointer?]
  [NSInflectionAgreementArgumentAttributeName cpointer?]
  [NSInflectionAgreementConceptAttributeName cpointer?]
  [NSInflectionAlternativeAttributeName cpointer?]
  [NSInflectionConceptsKey cpointer?]
  [NSInflectionReferentConceptAttributeName cpointer?]
  [NSInflectionRuleAttributeName cpointer?]
  [NSInlinePresentationIntentAttributeName cpointer?]
  [NSIntHashCallBacks cpointer?]
  [NSIntMapKeyCallBacks cpointer?]
  [NSIntMapValueCallBacks cpointer?]
  [NSIntegerHashCallBacks cpointer?]
  [NSIntegerMapKeyCallBacks cpointer?]
  [NSIntegerMapValueCallBacks cpointer?]
  [NSInternalInconsistencyException cpointer?]
  [NSInternationalCurrencyString cpointer?]
  [NSInvalidArchiveOperationException cpointer?]
  [NSInvalidArgumentException cpointer?]
  [NSInvalidReceivePortException cpointer?]
  [NSInvalidSendPortException cpointer?]
  [NSInvalidUnarchiveOperationException cpointer?]
  [NSInvocationOperationCancelledException cpointer?]
  [NSInvocationOperationVoidResultException cpointer?]
  [NSIsNilTransformerName cpointer?]
  [NSIsNotNilTransformerName cpointer?]
  [NSIslamicCalendar cpointer?]
  [NSIslamicCivilCalendar cpointer?]
  [NSItemProviderErrorDomain cpointer?]
  [NSItemProviderPreferredImageSizeKey cpointer?]
  [NSJapaneseCalendar cpointer?]
  [NSKeyValueChangeIndexesKey cpointer?]
  [NSKeyValueChangeKindKey cpointer?]
  [NSKeyValueChangeNewKey cpointer?]
  [NSKeyValueChangeNotificationIsPriorKey cpointer?]
  [NSKeyValueChangeOldKey cpointer?]
  [NSKeyedArchiveRootObjectKey cpointer?]
  [NSKeyedUnarchiveFromDataTransformerName cpointer?]
  [NSLanguageIdentifierAttributeName cpointer?]
  [NSLaterTimeDesignations cpointer?]
  [NSLinguisticTagAdjective cpointer?]
  [NSLinguisticTagAdverb cpointer?]
  [NSLinguisticTagClassifier cpointer?]
  [NSLinguisticTagCloseParenthesis cpointer?]
  [NSLinguisticTagCloseQuote cpointer?]
  [NSLinguisticTagConjunction cpointer?]
  [NSLinguisticTagDash cpointer?]
  [NSLinguisticTagDeterminer cpointer?]
  [NSLinguisticTagIdiom cpointer?]
  [NSLinguisticTagInterjection cpointer?]
  [NSLinguisticTagNoun cpointer?]
  [NSLinguisticTagNumber cpointer?]
  [NSLinguisticTagOpenParenthesis cpointer?]
  [NSLinguisticTagOpenQuote cpointer?]
  [NSLinguisticTagOrganizationName cpointer?]
  [NSLinguisticTagOther cpointer?]
  [NSLinguisticTagOtherPunctuation cpointer?]
  [NSLinguisticTagOtherWhitespace cpointer?]
  [NSLinguisticTagOtherWord cpointer?]
  [NSLinguisticTagParagraphBreak cpointer?]
  [NSLinguisticTagParticle cpointer?]
  [NSLinguisticTagPersonalName cpointer?]
  [NSLinguisticTagPlaceName cpointer?]
  [NSLinguisticTagPreposition cpointer?]
  [NSLinguisticTagPronoun cpointer?]
  [NSLinguisticTagPunctuation cpointer?]
  [NSLinguisticTagSchemeLanguage cpointer?]
  [NSLinguisticTagSchemeLemma cpointer?]
  [NSLinguisticTagSchemeLexicalClass cpointer?]
  [NSLinguisticTagSchemeNameType cpointer?]
  [NSLinguisticTagSchemeNameTypeOrLexicalClass cpointer?]
  [NSLinguisticTagSchemeScript cpointer?]
  [NSLinguisticTagSchemeTokenType cpointer?]
  [NSLinguisticTagSentenceTerminator cpointer?]
  [NSLinguisticTagVerb cpointer?]
  [NSLinguisticTagWhitespace cpointer?]
  [NSLinguisticTagWord cpointer?]
  [NSLinguisticTagWordJoiner cpointer?]
  [NSListItemDelimiterAttributeName cpointer?]
  [NSLoadedClasses cpointer?]
  [NSLocalNotificationCenterType cpointer?]
  [NSLocaleAlternateQuotationBeginDelimiterKey cpointer?]
  [NSLocaleAlternateQuotationEndDelimiterKey cpointer?]
  [NSLocaleCalendar cpointer?]
  [NSLocaleCollationIdentifier cpointer?]
  [NSLocaleCollatorIdentifier cpointer?]
  [NSLocaleCountryCode cpointer?]
  [NSLocaleCurrencyCode cpointer?]
  [NSLocaleCurrencySymbol cpointer?]
  [NSLocaleDecimalSeparator cpointer?]
  [NSLocaleExemplarCharacterSet cpointer?]
  [NSLocaleGroupingSeparator cpointer?]
  [NSLocaleIdentifier cpointer?]
  [NSLocaleLanguageCode cpointer?]
  [NSLocaleMeasurementSystem cpointer?]
  [NSLocaleQuotationBeginDelimiterKey cpointer?]
  [NSLocaleQuotationEndDelimiterKey cpointer?]
  [NSLocaleScriptCode cpointer?]
  [NSLocaleUsesMetricSystem cpointer?]
  [NSLocaleVariantCode cpointer?]
  [NSLocalizedDescriptionKey cpointer?]
  [NSLocalizedFailureErrorKey cpointer?]
  [NSLocalizedFailureReasonErrorKey cpointer?]
  [NSLocalizedNumberFormatAttributeName cpointer?]
  [NSLocalizedRecoveryOptionsErrorKey cpointer?]
  [NSLocalizedRecoverySuggestionErrorKey cpointer?]
  [NSMachErrorDomain cpointer?]
  [NSMallocException cpointer?]
  [NSMarkdownSourcePositionAttributeName cpointer?]
  [NSMaximumKeyValueOperator cpointer?]
  [NSMetadataItemAcquisitionMakeKey cpointer?]
  [NSMetadataItemAcquisitionModelKey cpointer?]
  [NSMetadataItemAlbumKey cpointer?]
  [NSMetadataItemAltitudeKey cpointer?]
  [NSMetadataItemApertureKey cpointer?]
  [NSMetadataItemAppleLoopDescriptorsKey cpointer?]
  [NSMetadataItemAppleLoopsKeyFilterTypeKey cpointer?]
  [NSMetadataItemAppleLoopsLoopModeKey cpointer?]
  [NSMetadataItemAppleLoopsRootKeyKey cpointer?]
  [NSMetadataItemApplicationCategoriesKey cpointer?]
  [NSMetadataItemAttributeChangeDateKey cpointer?]
  [NSMetadataItemAudiencesKey cpointer?]
  [NSMetadataItemAudioBitRateKey cpointer?]
  [NSMetadataItemAudioChannelCountKey cpointer?]
  [NSMetadataItemAudioEncodingApplicationKey cpointer?]
  [NSMetadataItemAudioSampleRateKey cpointer?]
  [NSMetadataItemAudioTrackNumberKey cpointer?]
  [NSMetadataItemAuthorAddressesKey cpointer?]
  [NSMetadataItemAuthorEmailAddressesKey cpointer?]
  [NSMetadataItemAuthorsKey cpointer?]
  [NSMetadataItemBitsPerSampleKey cpointer?]
  [NSMetadataItemCFBundleIdentifierKey cpointer?]
  [NSMetadataItemCameraOwnerKey cpointer?]
  [NSMetadataItemCityKey cpointer?]
  [NSMetadataItemCodecsKey cpointer?]
  [NSMetadataItemColorSpaceKey cpointer?]
  [NSMetadataItemCommentKey cpointer?]
  [NSMetadataItemComposerKey cpointer?]
  [NSMetadataItemContactKeywordsKey cpointer?]
  [NSMetadataItemContentCreationDateKey cpointer?]
  [NSMetadataItemContentModificationDateKey cpointer?]
  [NSMetadataItemContentTypeKey cpointer?]
  [NSMetadataItemContentTypeTreeKey cpointer?]
  [NSMetadataItemContributorsKey cpointer?]
  [NSMetadataItemCopyrightKey cpointer?]
  [NSMetadataItemCountryKey cpointer?]
  [NSMetadataItemCoverageKey cpointer?]
  [NSMetadataItemCreatorKey cpointer?]
  [NSMetadataItemDateAddedKey cpointer?]
  [NSMetadataItemDeliveryTypeKey cpointer?]
  [NSMetadataItemDescriptionKey cpointer?]
  [NSMetadataItemDirectorKey cpointer?]
  [NSMetadataItemDisplayNameKey cpointer?]
  [NSMetadataItemDownloadedDateKey cpointer?]
  [NSMetadataItemDueDateKey cpointer?]
  [NSMetadataItemDurationSecondsKey cpointer?]
  [NSMetadataItemEXIFGPSVersionKey cpointer?]
  [NSMetadataItemEXIFVersionKey cpointer?]
  [NSMetadataItemEditorsKey cpointer?]
  [NSMetadataItemEmailAddressesKey cpointer?]
  [NSMetadataItemEncodingApplicationsKey cpointer?]
  [NSMetadataItemExecutableArchitecturesKey cpointer?]
  [NSMetadataItemExecutablePlatformKey cpointer?]
  [NSMetadataItemExposureModeKey cpointer?]
  [NSMetadataItemExposureProgramKey cpointer?]
  [NSMetadataItemExposureTimeSecondsKey cpointer?]
  [NSMetadataItemExposureTimeStringKey cpointer?]
  [NSMetadataItemFNumberKey cpointer?]
  [NSMetadataItemFSContentChangeDateKey cpointer?]
  [NSMetadataItemFSCreationDateKey cpointer?]
  [NSMetadataItemFSNameKey cpointer?]
  [NSMetadataItemFSSizeKey cpointer?]
  [NSMetadataItemFinderCommentKey cpointer?]
  [NSMetadataItemFlashOnOffKey cpointer?]
  [NSMetadataItemFocalLength35mmKey cpointer?]
  [NSMetadataItemFocalLengthKey cpointer?]
  [NSMetadataItemFontsKey cpointer?]
  [NSMetadataItemGPSAreaInformationKey cpointer?]
  [NSMetadataItemGPSDOPKey cpointer?]
  [NSMetadataItemGPSDateStampKey cpointer?]
  [NSMetadataItemGPSDestBearingKey cpointer?]
  [NSMetadataItemGPSDestDistanceKey cpointer?]
  [NSMetadataItemGPSDestLatitudeKey cpointer?]
  [NSMetadataItemGPSDestLongitudeKey cpointer?]
  [NSMetadataItemGPSDifferentalKey cpointer?]
  [NSMetadataItemGPSMapDatumKey cpointer?]
  [NSMetadataItemGPSMeasureModeKey cpointer?]
  [NSMetadataItemGPSProcessingMethodKey cpointer?]
  [NSMetadataItemGPSStatusKey cpointer?]
  [NSMetadataItemGPSTrackKey cpointer?]
  [NSMetadataItemGenreKey cpointer?]
  [NSMetadataItemHasAlphaChannelKey cpointer?]
  [NSMetadataItemHeadlineKey cpointer?]
  [NSMetadataItemISOSpeedKey cpointer?]
  [NSMetadataItemIdentifierKey cpointer?]
  [NSMetadataItemImageDirectionKey cpointer?]
  [NSMetadataItemInformationKey cpointer?]
  [NSMetadataItemInstantMessageAddressesKey cpointer?]
  [NSMetadataItemInstructionsKey cpointer?]
  [NSMetadataItemIsApplicationManagedKey cpointer?]
  [NSMetadataItemIsGeneralMIDISequenceKey cpointer?]
  [NSMetadataItemIsLikelyJunkKey cpointer?]
  [NSMetadataItemIsUbiquitousKey cpointer?]
  [NSMetadataItemKeySignatureKey cpointer?]
  [NSMetadataItemKeywordsKey cpointer?]
  [NSMetadataItemKindKey cpointer?]
  [NSMetadataItemLanguagesKey cpointer?]
  [NSMetadataItemLastUsedDateKey cpointer?]
  [NSMetadataItemLatitudeKey cpointer?]
  [NSMetadataItemLayerNamesKey cpointer?]
  [NSMetadataItemLensModelKey cpointer?]
  [NSMetadataItemLongitudeKey cpointer?]
  [NSMetadataItemLyricistKey cpointer?]
  [NSMetadataItemMaxApertureKey cpointer?]
  [NSMetadataItemMediaTypesKey cpointer?]
  [NSMetadataItemMeteringModeKey cpointer?]
  [NSMetadataItemMusicalGenreKey cpointer?]
  [NSMetadataItemMusicalInstrumentCategoryKey cpointer?]
  [NSMetadataItemMusicalInstrumentNameKey cpointer?]
  [NSMetadataItemNamedLocationKey cpointer?]
  [NSMetadataItemNumberOfPagesKey cpointer?]
  [NSMetadataItemOrganizationsKey cpointer?]
  [NSMetadataItemOrientationKey cpointer?]
  [NSMetadataItemOriginalFormatKey cpointer?]
  [NSMetadataItemOriginalSourceKey cpointer?]
  [NSMetadataItemPageHeightKey cpointer?]
  [NSMetadataItemPageWidthKey cpointer?]
  [NSMetadataItemParticipantsKey cpointer?]
  [NSMetadataItemPathKey cpointer?]
  [NSMetadataItemPerformersKey cpointer?]
  [NSMetadataItemPhoneNumbersKey cpointer?]
  [NSMetadataItemPixelCountKey cpointer?]
  [NSMetadataItemPixelHeightKey cpointer?]
  [NSMetadataItemPixelWidthKey cpointer?]
  [NSMetadataItemProducerKey cpointer?]
  [NSMetadataItemProfileNameKey cpointer?]
  [NSMetadataItemProjectsKey cpointer?]
  [NSMetadataItemPublishersKey cpointer?]
  [NSMetadataItemRecipientAddressesKey cpointer?]
  [NSMetadataItemRecipientEmailAddressesKey cpointer?]
  [NSMetadataItemRecipientsKey cpointer?]
  [NSMetadataItemRecordingDateKey cpointer?]
  [NSMetadataItemRecordingYearKey cpointer?]
  [NSMetadataItemRedEyeOnOffKey cpointer?]
  [NSMetadataItemResolutionHeightDPIKey cpointer?]
  [NSMetadataItemResolutionWidthDPIKey cpointer?]
  [NSMetadataItemRightsKey cpointer?]
  [NSMetadataItemSecurityMethodKey cpointer?]
  [NSMetadataItemSpeedKey cpointer?]
  [NSMetadataItemStarRatingKey cpointer?]
  [NSMetadataItemStateOrProvinceKey cpointer?]
  [NSMetadataItemStreamableKey cpointer?]
  [NSMetadataItemSubjectKey cpointer?]
  [NSMetadataItemTempoKey cpointer?]
  [NSMetadataItemTextContentKey cpointer?]
  [NSMetadataItemThemeKey cpointer?]
  [NSMetadataItemTimeSignatureKey cpointer?]
  [NSMetadataItemTimestampKey cpointer?]
  [NSMetadataItemTitleKey cpointer?]
  [NSMetadataItemTotalBitRateKey cpointer?]
  [NSMetadataItemURLKey cpointer?]
  [NSMetadataItemVersionKey cpointer?]
  [NSMetadataItemVideoBitRateKey cpointer?]
  [NSMetadataItemWhereFromsKey cpointer?]
  [NSMetadataItemWhiteBalanceKey cpointer?]
  [NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope cpointer?]
  [NSMetadataQueryDidFinishGatheringNotification cpointer?]
  [NSMetadataQueryDidStartGatheringNotification cpointer?]
  [NSMetadataQueryDidUpdateNotification cpointer?]
  [NSMetadataQueryGatheringProgressNotification cpointer?]
  [NSMetadataQueryIndexedLocalComputerScope cpointer?]
  [NSMetadataQueryIndexedNetworkScope cpointer?]
  [NSMetadataQueryLocalComputerScope cpointer?]
  [NSMetadataQueryNetworkScope cpointer?]
  [NSMetadataQueryResultContentRelevanceAttribute cpointer?]
  [NSMetadataQueryUbiquitousDataScope cpointer?]
  [NSMetadataQueryUbiquitousDocumentsScope cpointer?]
  [NSMetadataQueryUpdateAddedItemsKey cpointer?]
  [NSMetadataQueryUpdateChangedItemsKey cpointer?]
  [NSMetadataQueryUpdateRemovedItemsKey cpointer?]
  [NSMetadataQueryUserHomeScope cpointer?]
  [NSMetadataUbiquitousItemContainerDisplayNameKey cpointer?]
  [NSMetadataUbiquitousItemDownloadRequestedKey cpointer?]
  [NSMetadataUbiquitousItemDownloadingErrorKey cpointer?]
  [NSMetadataUbiquitousItemDownloadingStatusCurrent cpointer?]
  [NSMetadataUbiquitousItemDownloadingStatusDownloaded cpointer?]
  [NSMetadataUbiquitousItemDownloadingStatusKey cpointer?]
  [NSMetadataUbiquitousItemDownloadingStatusNotDownloaded cpointer?]
  [NSMetadataUbiquitousItemHasUnresolvedConflictsKey cpointer?]
  [NSMetadataUbiquitousItemIsDownloadedKey cpointer?]
  [NSMetadataUbiquitousItemIsDownloadingKey cpointer?]
  [NSMetadataUbiquitousItemIsExternalDocumentKey cpointer?]
  [NSMetadataUbiquitousItemIsSharedKey cpointer?]
  [NSMetadataUbiquitousItemIsUploadedKey cpointer?]
  [NSMetadataUbiquitousItemIsUploadingKey cpointer?]
  [NSMetadataUbiquitousItemPercentDownloadedKey cpointer?]
  [NSMetadataUbiquitousItemPercentUploadedKey cpointer?]
  [NSMetadataUbiquitousItemURLInLocalContainerKey cpointer?]
  [NSMetadataUbiquitousItemUploadingErrorKey cpointer?]
  [NSMetadataUbiquitousSharedItemCurrentUserPermissionsKey cpointer?]
  [NSMetadataUbiquitousSharedItemCurrentUserRoleKey cpointer?]
  [NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKey cpointer?]
  [NSMetadataUbiquitousSharedItemOwnerNameComponentsKey cpointer?]
  [NSMetadataUbiquitousSharedItemPermissionsReadOnly cpointer?]
  [NSMetadataUbiquitousSharedItemPermissionsReadWrite cpointer?]
  [NSMetadataUbiquitousSharedItemRoleOwner cpointer?]
  [NSMetadataUbiquitousSharedItemRoleParticipant cpointer?]
  [NSMinimumKeyValueOperator cpointer?]
  [NSMonthNameArray cpointer?]
  [NSMorphologyAttributeName cpointer?]
  [NSMultipleUnderlyingErrorsKey cpointer?]
  [NSNegateBooleanTransformerName cpointer?]
  [NSNegativeCurrencyFormatString cpointer?]
  [NSNetServicesErrorCode cpointer?]
  [NSNetServicesErrorDomain cpointer?]
  [NSNextDayDesignations cpointer?]
  [NSNextNextDayDesignations cpointer?]
  [NSNonOwnedPointerHashCallBacks cpointer?]
  [NSNonOwnedPointerMapKeyCallBacks cpointer?]
  [NSNonOwnedPointerMapValueCallBacks cpointer?]
  [NSNonOwnedPointerOrNullMapKeyCallBacks cpointer?]
  [NSNonRetainedObjectHashCallBacks cpointer?]
  [NSNonRetainedObjectMapKeyCallBacks cpointer?]
  [NSNonRetainedObjectMapValueCallBacks cpointer?]
  [NSOSStatusErrorDomain cpointer?]
  [NSObjectHashCallBacks cpointer?]
  [NSObjectInaccessibleException cpointer?]
  [NSObjectMapKeyCallBacks cpointer?]
  [NSObjectMapValueCallBacks cpointer?]
  [NSObjectNotAvailableException cpointer?]
  [NSOldStyleException cpointer?]
  [NSOperationNotSupportedForKeyException cpointer?]
  [NSOwnedObjectIdentityHashCallBacks cpointer?]
  [NSOwnedPointerHashCallBacks cpointer?]
  [NSOwnedPointerMapKeyCallBacks cpointer?]
  [NSOwnedPointerMapValueCallBacks cpointer?]
  [NSPOSIXErrorDomain cpointer?]
  [NSParseErrorException cpointer?]
  [NSPersianCalendar cpointer?]
  [NSPersonNameComponentDelimiter cpointer?]
  [NSPersonNameComponentFamilyName cpointer?]
  [NSPersonNameComponentGivenName cpointer?]
  [NSPersonNameComponentKey cpointer?]
  [NSPersonNameComponentMiddleName cpointer?]
  [NSPersonNameComponentNickname cpointer?]
  [NSPersonNameComponentPrefix cpointer?]
  [NSPersonNameComponentSuffix cpointer?]
  [NSPointerToStructHashCallBacks cpointer?]
  [NSPortDidBecomeInvalidNotification cpointer?]
  [NSPortReceiveException cpointer?]
  [NSPortSendException cpointer?]
  [NSPortTimeoutException cpointer?]
  [NSPositiveCurrencyFormatString cpointer?]
  [NSPresentationIntentAttributeName cpointer?]
  [NSPriorDayDesignations cpointer?]
  [NSProcessInfoPowerStateDidChangeNotification cpointer?]
  [NSProcessInfoThermalStateDidChangeNotification cpointer?]
  [NSProgressEstimatedTimeRemainingKey cpointer?]
  [NSProgressFileAnimationImageKey cpointer?]
  [NSProgressFileAnimationImageOriginalRectKey cpointer?]
  [NSProgressFileCompletedCountKey cpointer?]
  [NSProgressFileIconKey cpointer?]
  [NSProgressFileOperationKindCopying cpointer?]
  [NSProgressFileOperationKindDecompressingAfterDownloading cpointer?]
  [NSProgressFileOperationKindDownloading cpointer?]
  [NSProgressFileOperationKindDuplicating cpointer?]
  [NSProgressFileOperationKindKey cpointer?]
  [NSProgressFileOperationKindReceiving cpointer?]
  [NSProgressFileOperationKindUploading cpointer?]
  [NSProgressFileTotalCountKey cpointer?]
  [NSProgressFileURLKey cpointer?]
  [NSProgressKindFile cpointer?]
  [NSProgressThroughputKey cpointer?]
  [NSRangeException cpointer?]
  [NSRecoveryAttempterErrorKey cpointer?]
  [NSRegistrationDomain cpointer?]
  [NSReplacementIndexAttributeName cpointer?]
  [NSRepublicOfChinaCalendar cpointer?]
  [NSRunLoopCommonModes cpointer?]
  [NSSecureUnarchiveFromDataTransformerName cpointer?]
  [NSShortDateFormatString cpointer?]
  [NSShortMonthNameArray cpointer?]
  [NSShortTimeDateFormatString cpointer?]
  [NSShortWeekDayNameArray cpointer?]
  [NSStreamDataWrittenToMemoryStreamKey cpointer?]
  [NSStreamFileCurrentOffsetKey cpointer?]
  [NSStreamNetworkServiceType cpointer?]
  [NSStreamNetworkServiceTypeBackground cpointer?]
  [NSStreamNetworkServiceTypeCallSignaling cpointer?]
  [NSStreamNetworkServiceTypeVideo cpointer?]
  [NSStreamNetworkServiceTypeVoIP cpointer?]
  [NSStreamNetworkServiceTypeVoice cpointer?]
  [NSStreamSOCKSErrorDomain cpointer?]
  [NSStreamSOCKSProxyConfigurationKey cpointer?]
  [NSStreamSOCKSProxyHostKey cpointer?]
  [NSStreamSOCKSProxyPasswordKey cpointer?]
  [NSStreamSOCKSProxyPortKey cpointer?]
  [NSStreamSOCKSProxyUserKey cpointer?]
  [NSStreamSOCKSProxyVersion4 cpointer?]
  [NSStreamSOCKSProxyVersion5 cpointer?]
  [NSStreamSOCKSProxyVersionKey cpointer?]
  [NSStreamSocketSSLErrorDomain cpointer?]
  [NSStreamSocketSecurityLevelKey cpointer?]
  [NSStreamSocketSecurityLevelNegotiatedSSL cpointer?]
  [NSStreamSocketSecurityLevelNone cpointer?]
  [NSStreamSocketSecurityLevelSSLv2 cpointer?]
  [NSStreamSocketSecurityLevelSSLv3 cpointer?]
  [NSStreamSocketSecurityLevelTLSv1 cpointer?]
  [NSStringEncodingDetectionAllowLossyKey cpointer?]
  [NSStringEncodingDetectionDisallowedEncodingsKey cpointer?]
  [NSStringEncodingDetectionFromWindowsKey cpointer?]
  [NSStringEncodingDetectionLikelyLanguageKey cpointer?]
  [NSStringEncodingDetectionLossySubstitutionKey cpointer?]
  [NSStringEncodingDetectionSuggestedEncodingsKey cpointer?]
  [NSStringEncodingDetectionUseOnlySuggestedEncodingsKey cpointer?]
  [NSStringEncodingErrorKey cpointer?]
  [NSStringTransformFullwidthToHalfwidth cpointer?]
  [NSStringTransformHiraganaToKatakana cpointer?]
  [NSStringTransformLatinToArabic cpointer?]
  [NSStringTransformLatinToCyrillic cpointer?]
  [NSStringTransformLatinToGreek cpointer?]
  [NSStringTransformLatinToHangul cpointer?]
  [NSStringTransformLatinToHebrew cpointer?]
  [NSStringTransformLatinToHiragana cpointer?]
  [NSStringTransformLatinToKatakana cpointer?]
  [NSStringTransformLatinToThai cpointer?]
  [NSStringTransformMandarinToLatin cpointer?]
  [NSStringTransformStripCombiningMarks cpointer?]
  [NSStringTransformStripDiacritics cpointer?]
  [NSStringTransformToLatin cpointer?]
  [NSStringTransformToUnicodeName cpointer?]
  [NSStringTransformToXMLHex cpointer?]
  [NSSumKeyValueOperator cpointer?]
  [NSSystemClockDidChangeNotification cpointer?]
  [NSSystemTimeZoneDidChangeNotification cpointer?]
  [NSTaskDidTerminateNotification cpointer?]
  [NSTextCheckingAirlineKey cpointer?]
  [NSTextCheckingCityKey cpointer?]
  [NSTextCheckingCountryKey cpointer?]
  [NSTextCheckingFlightKey cpointer?]
  [NSTextCheckingJobTitleKey cpointer?]
  [NSTextCheckingNameKey cpointer?]
  [NSTextCheckingOrganizationKey cpointer?]
  [NSTextCheckingPhoneKey cpointer?]
  [NSTextCheckingStateKey cpointer?]
  [NSTextCheckingStreetKey cpointer?]
  [NSTextCheckingZIPKey cpointer?]
  [NSThisDayDesignations cpointer?]
  [NSThousandsSeparator cpointer?]
  [NSThreadWillExitNotification cpointer?]
  [NSThumbnail1024x1024SizeKey cpointer?]
  [NSTimeDateFormatString cpointer?]
  [NSTimeFormatString cpointer?]
  [NSURLAddedToDirectoryDateKey cpointer?]
  [NSURLApplicationIsScriptableKey cpointer?]
  [NSURLAttributeModificationDateKey cpointer?]
  [NSURLAuthenticationMethodClientCertificate cpointer?]
  [NSURLAuthenticationMethodDefault cpointer?]
  [NSURLAuthenticationMethodHTMLForm cpointer?]
  [NSURLAuthenticationMethodHTTPBasic cpointer?]
  [NSURLAuthenticationMethodHTTPDigest cpointer?]
  [NSURLAuthenticationMethodNTLM cpointer?]
  [NSURLAuthenticationMethodNegotiate cpointer?]
  [NSURLAuthenticationMethodServerTrust cpointer?]
  [NSURLCanonicalPathKey cpointer?]
  [NSURLContentAccessDateKey cpointer?]
  [NSURLContentModificationDateKey cpointer?]
  [NSURLContentTypeKey cpointer?]
  [NSURLCreationDateKey cpointer?]
  [NSURLCredentialStorageChangedNotification cpointer?]
  [NSURLCredentialStorageRemoveSynchronizableCredentials cpointer?]
  [NSURLCustomIconKey cpointer?]
  [NSURLDirectoryEntryCountKey cpointer?]
  [NSURLDocumentIdentifierKey cpointer?]
  [NSURLEffectiveIconKey cpointer?]
  [NSURLErrorBackgroundTaskCancelledReasonKey cpointer?]
  [NSURLErrorDomain cpointer?]
  [NSURLErrorFailingURLErrorKey cpointer?]
  [NSURLErrorFailingURLPeerTrustErrorKey cpointer?]
  [NSURLErrorFailingURLStringErrorKey cpointer?]
  [NSURLErrorKey cpointer?]
  [NSURLErrorNetworkUnavailableReasonKey cpointer?]
  [NSURLFileAllocatedSizeKey cpointer?]
  [NSURLFileContentIdentifierKey cpointer?]
  [NSURLFileIdentifierKey cpointer?]
  [NSURLFileProtectionComplete cpointer?]
  [NSURLFileProtectionCompleteUnlessOpen cpointer?]
  [NSURLFileProtectionCompleteUntilFirstUserAuthentication cpointer?]
  [NSURLFileProtectionKey cpointer?]
  [NSURLFileProtectionNone cpointer?]
  [NSURLFileResourceIdentifierKey cpointer?]
  [NSURLFileResourceTypeBlockSpecial cpointer?]
  [NSURLFileResourceTypeCharacterSpecial cpointer?]
  [NSURLFileResourceTypeDirectory cpointer?]
  [NSURLFileResourceTypeKey cpointer?]
  [NSURLFileResourceTypeNamedPipe cpointer?]
  [NSURLFileResourceTypeRegular cpointer?]
  [NSURLFileResourceTypeSocket cpointer?]
  [NSURLFileResourceTypeSymbolicLink cpointer?]
  [NSURLFileResourceTypeUnknown cpointer?]
  [NSURLFileScheme cpointer?]
  [NSURLFileSecurityKey cpointer?]
  [NSURLFileSizeKey cpointer?]
  [NSURLGenerationIdentifierKey cpointer?]
  [NSURLHasHiddenExtensionKey cpointer?]
  [NSURLIsAliasFileKey cpointer?]
  [NSURLIsApplicationKey cpointer?]
  [NSURLIsDirectoryKey cpointer?]
  [NSURLIsExcludedFromBackupKey cpointer?]
  [NSURLIsExecutableKey cpointer?]
  [NSURLIsHiddenKey cpointer?]
  [NSURLIsMountTriggerKey cpointer?]
  [NSURLIsPackageKey cpointer?]
  [NSURLIsPurgeableKey cpointer?]
  [NSURLIsReadableKey cpointer?]
  [NSURLIsRegularFileKey cpointer?]
  [NSURLIsSparseKey cpointer?]
  [NSURLIsSymbolicLinkKey cpointer?]
  [NSURLIsSystemImmutableKey cpointer?]
  [NSURLIsUbiquitousItemKey cpointer?]
  [NSURLIsUserImmutableKey cpointer?]
  [NSURLIsVolumeKey cpointer?]
  [NSURLIsWritableKey cpointer?]
  [NSURLKeysOfUnsetValuesKey cpointer?]
  [NSURLLabelColorKey cpointer?]
  [NSURLLabelNumberKey cpointer?]
  [NSURLLinkCountKey cpointer?]
  [NSURLLocalizedLabelKey cpointer?]
  [NSURLLocalizedNameKey cpointer?]
  [NSURLLocalizedTypeDescriptionKey cpointer?]
  [NSURLMayHaveExtendedAttributesKey cpointer?]
  [NSURLMayShareFileContentKey cpointer?]
  [NSURLNameKey cpointer?]
  [NSURLParentDirectoryURLKey cpointer?]
  [NSURLPathKey cpointer?]
  [NSURLPreferredIOBlockSizeKey cpointer?]
  [NSURLProtectionSpaceFTP cpointer?]
  [NSURLProtectionSpaceFTPProxy cpointer?]
  [NSURLProtectionSpaceHTTP cpointer?]
  [NSURLProtectionSpaceHTTPProxy cpointer?]
  [NSURLProtectionSpaceHTTPS cpointer?]
  [NSURLProtectionSpaceHTTPSProxy cpointer?]
  [NSURLProtectionSpaceSOCKSProxy cpointer?]
  [NSURLQuarantinePropertiesKey cpointer?]
  [NSURLSessionDownloadTaskResumeData cpointer?]
  [NSURLSessionTaskPriorityDefault real?]
  [NSURLSessionTaskPriorityHigh real?]
  [NSURLSessionTaskPriorityLow real?]
  [NSURLSessionTransferSizeUnknown exact-integer?]
  [NSURLSessionUploadTaskResumeData cpointer?]
  [NSURLTagNamesKey cpointer?]
  [NSURLThumbnailDictionaryKey cpointer?]
  [NSURLThumbnailKey cpointer?]
  [NSURLTotalFileAllocatedSizeKey cpointer?]
  [NSURLTotalFileSizeKey cpointer?]
  [NSURLTypeIdentifierKey cpointer?]
  [NSURLUbiquitousItemContainerDisplayNameKey cpointer?]
  [NSURLUbiquitousItemDownloadRequestedKey cpointer?]
  [NSURLUbiquitousItemDownloadingErrorKey cpointer?]
  [NSURLUbiquitousItemDownloadingStatusCurrent cpointer?]
  [NSURLUbiquitousItemDownloadingStatusDownloaded cpointer?]
  [NSURLUbiquitousItemDownloadingStatusKey cpointer?]
  [NSURLUbiquitousItemDownloadingStatusNotDownloaded cpointer?]
  [NSURLUbiquitousItemHasUnresolvedConflictsKey cpointer?]
  [NSURLUbiquitousItemIsDownloadedKey cpointer?]
  [NSURLUbiquitousItemIsDownloadingKey cpointer?]
  [NSURLUbiquitousItemIsExcludedFromSyncKey cpointer?]
  [NSURLUbiquitousItemIsSharedKey cpointer?]
  [NSURLUbiquitousItemIsSyncPausedKey cpointer?]
  [NSURLUbiquitousItemIsUploadedKey cpointer?]
  [NSURLUbiquitousItemIsUploadingKey cpointer?]
  [NSURLUbiquitousItemPercentDownloadedKey cpointer?]
  [NSURLUbiquitousItemPercentUploadedKey cpointer?]
  [NSURLUbiquitousItemSupportedSyncControlsKey cpointer?]
  [NSURLUbiquitousItemUploadingErrorKey cpointer?]
  [NSURLUbiquitousSharedItemCurrentUserPermissionsKey cpointer?]
  [NSURLUbiquitousSharedItemCurrentUserRoleKey cpointer?]
  [NSURLUbiquitousSharedItemMostRecentEditorNameComponentsKey cpointer?]
  [NSURLUbiquitousSharedItemOwnerNameComponentsKey cpointer?]
  [NSURLUbiquitousSharedItemPermissionsReadOnly cpointer?]
  [NSURLUbiquitousSharedItemPermissionsReadWrite cpointer?]
  [NSURLUbiquitousSharedItemRoleOwner cpointer?]
  [NSURLUbiquitousSharedItemRoleParticipant cpointer?]
  [NSURLVolumeAvailableCapacityForImportantUsageKey cpointer?]
  [NSURLVolumeAvailableCapacityForOpportunisticUsageKey cpointer?]
  [NSURLVolumeAvailableCapacityKey cpointer?]
  [NSURLVolumeCreationDateKey cpointer?]
  [NSURLVolumeIdentifierKey cpointer?]
  [NSURLVolumeIsAutomountedKey cpointer?]
  [NSURLVolumeIsBrowsableKey cpointer?]
  [NSURLVolumeIsEjectableKey cpointer?]
  [NSURLVolumeIsEncryptedKey cpointer?]
  [NSURLVolumeIsInternalKey cpointer?]
  [NSURLVolumeIsJournalingKey cpointer?]
  [NSURLVolumeIsLocalKey cpointer?]
  [NSURLVolumeIsReadOnlyKey cpointer?]
  [NSURLVolumeIsRemovableKey cpointer?]
  [NSURLVolumeIsRootFileSystemKey cpointer?]
  [NSURLVolumeLocalizedFormatDescriptionKey cpointer?]
  [NSURLVolumeLocalizedNameKey cpointer?]
  [NSURLVolumeMaximumFileSizeKey cpointer?]
  [NSURLVolumeMountFromLocationKey cpointer?]
  [NSURLVolumeNameKey cpointer?]
  [NSURLVolumeResourceCountKey cpointer?]
  [NSURLVolumeSubtypeKey cpointer?]
  [NSURLVolumeSupportsAccessPermissionsKey cpointer?]
  [NSURLVolumeSupportsAdvisoryFileLockingKey cpointer?]
  [NSURLVolumeSupportsCasePreservedNamesKey cpointer?]
  [NSURLVolumeSupportsCaseSensitiveNamesKey cpointer?]
  [NSURLVolumeSupportsCompressionKey cpointer?]
  [NSURLVolumeSupportsExclusiveRenamingKey cpointer?]
  [NSURLVolumeSupportsExtendedSecurityKey cpointer?]
  [NSURLVolumeSupportsFileCloningKey cpointer?]
  [NSURLVolumeSupportsFileProtectionKey cpointer?]
  [NSURLVolumeSupportsHardLinksKey cpointer?]
  [NSURLVolumeSupportsImmutableFilesKey cpointer?]
  [NSURLVolumeSupportsJournalingKey cpointer?]
  [NSURLVolumeSupportsPersistentIDsKey cpointer?]
  [NSURLVolumeSupportsRenamingKey cpointer?]
  [NSURLVolumeSupportsRootDirectoryDatesKey cpointer?]
  [NSURLVolumeSupportsSparseFilesKey cpointer?]
  [NSURLVolumeSupportsSwapRenamingKey cpointer?]
  [NSURLVolumeSupportsSymbolicLinksKey cpointer?]
  [NSURLVolumeSupportsVolumeSizesKey cpointer?]
  [NSURLVolumeSupportsZeroRunsKey cpointer?]
  [NSURLVolumeTotalCapacityKey cpointer?]
  [NSURLVolumeTypeNameKey cpointer?]
  [NSURLVolumeURLForRemountingKey cpointer?]
  [NSURLVolumeURLKey cpointer?]
  [NSURLVolumeUUIDStringKey cpointer?]
  [NSUbiquitousKeyValueStoreChangeReasonKey cpointer?]
  [NSUbiquitousKeyValueStoreChangedKeysKey cpointer?]
  [NSUbiquitousKeyValueStoreDidChangeExternallyNotification cpointer?]
  [NSUbiquityIdentityDidChangeNotification cpointer?]
  [NSUnarchiveFromDataTransformerName cpointer?]
  [NSUndefinedKeyException cpointer?]
  [NSUnderlyingErrorKey cpointer?]
  [NSUndoManagerCheckpointNotification cpointer?]
  [NSUndoManagerDidCloseUndoGroupNotification cpointer?]
  [NSUndoManagerDidOpenUndoGroupNotification cpointer?]
  [NSUndoManagerDidRedoChangeNotification cpointer?]
  [NSUndoManagerDidUndoChangeNotification cpointer?]
  [NSUndoManagerGroupIsDiscardableKey cpointer?]
  [NSUndoManagerWillCloseUndoGroupNotification cpointer?]
  [NSUndoManagerWillRedoChangeNotification cpointer?]
  [NSUndoManagerWillUndoChangeNotification cpointer?]
  [NSUnionOfArraysKeyValueOperator cpointer?]
  [NSUnionOfObjectsKeyValueOperator cpointer?]
  [NSUnionOfSetsKeyValueOperator cpointer?]
  [NSUserActivityTypeBrowsingWeb cpointer?]
  [NSUserDefaultsDidChangeNotification cpointer?]
  [NSUserNotificationDefaultSoundName cpointer?]
  [NSWeekDayNameArray cpointer?]
  [NSWillBecomeMultiThreadedNotification cpointer?]
  [NSXMLParserErrorDomain cpointer?]
  [NSYearMonthWeekDesignations cpointer?]
  [NSZeroPoint cpointer?]
  [NSZeroRect cpointer?]
  [NSZeroSize cpointer?]
  )

(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))

(define NSAMPMDesignation (get-ffi-obj 'NSAMPMDesignation _fw-lib _id))
(define NSAlternateDescriptionAttributeName (get-ffi-obj 'NSAlternateDescriptionAttributeName _fw-lib _id))
(define NSAppleEventManagerWillProcessFirstEventNotification (get-ffi-obj 'NSAppleEventManagerWillProcessFirstEventNotification _fw-lib _id))
(define NSAppleEventTimeOutDefault (get-ffi-obj 'NSAppleEventTimeOutDefault _fw-lib _double))
(define NSAppleEventTimeOutNone (get-ffi-obj 'NSAppleEventTimeOutNone _fw-lib _double))
(define NSAppleScriptErrorAppName (get-ffi-obj 'NSAppleScriptErrorAppName _fw-lib _id))
(define NSAppleScriptErrorBriefMessage (get-ffi-obj 'NSAppleScriptErrorBriefMessage _fw-lib _id))
(define NSAppleScriptErrorMessage (get-ffi-obj 'NSAppleScriptErrorMessage _fw-lib _id))
(define NSAppleScriptErrorNumber (get-ffi-obj 'NSAppleScriptErrorNumber _fw-lib _id))
(define NSAppleScriptErrorRange (get-ffi-obj 'NSAppleScriptErrorRange _fw-lib _id))
(define NSArgumentDomain (get-ffi-obj 'NSArgumentDomain _fw-lib _id))
(define NSAssertionHandlerKey (get-ffi-obj 'NSAssertionHandlerKey _fw-lib _id))
(define NSAverageKeyValueOperator (get-ffi-obj 'NSAverageKeyValueOperator _fw-lib _id))
(define NSBuddhistCalendar (get-ffi-obj 'NSBuddhistCalendar _fw-lib _id))
(define NSBundleDidLoadNotification (get-ffi-obj 'NSBundleDidLoadNotification _fw-lib _id))
(define NSCalendarDayChangedNotification (get-ffi-obj 'NSCalendarDayChangedNotification _fw-lib _id))
(define NSCalendarIdentifierBangla (get-ffi-obj 'NSCalendarIdentifierBangla _fw-lib _id))
(define NSCalendarIdentifierBuddhist (get-ffi-obj 'NSCalendarIdentifierBuddhist _fw-lib _id))
(define NSCalendarIdentifierChinese (get-ffi-obj 'NSCalendarIdentifierChinese _fw-lib _id))
(define NSCalendarIdentifierCoptic (get-ffi-obj 'NSCalendarIdentifierCoptic _fw-lib _id))
(define NSCalendarIdentifierDangi (get-ffi-obj 'NSCalendarIdentifierDangi _fw-lib _id))
(define NSCalendarIdentifierEthiopicAmeteAlem (get-ffi-obj 'NSCalendarIdentifierEthiopicAmeteAlem _fw-lib _id))
(define NSCalendarIdentifierEthiopicAmeteMihret (get-ffi-obj 'NSCalendarIdentifierEthiopicAmeteMihret _fw-lib _id))
(define NSCalendarIdentifierGregorian (get-ffi-obj 'NSCalendarIdentifierGregorian _fw-lib _id))
(define NSCalendarIdentifierGujarati (get-ffi-obj 'NSCalendarIdentifierGujarati _fw-lib _id))
(define NSCalendarIdentifierHebrew (get-ffi-obj 'NSCalendarIdentifierHebrew _fw-lib _id))
(define NSCalendarIdentifierISO8601 (get-ffi-obj 'NSCalendarIdentifierISO8601 _fw-lib _id))
(define NSCalendarIdentifierIndian (get-ffi-obj 'NSCalendarIdentifierIndian _fw-lib _id))
(define NSCalendarIdentifierIslamic (get-ffi-obj 'NSCalendarIdentifierIslamic _fw-lib _id))
(define NSCalendarIdentifierIslamicCivil (get-ffi-obj 'NSCalendarIdentifierIslamicCivil _fw-lib _id))
(define NSCalendarIdentifierIslamicTabular (get-ffi-obj 'NSCalendarIdentifierIslamicTabular _fw-lib _id))
(define NSCalendarIdentifierIslamicUmmAlQura (get-ffi-obj 'NSCalendarIdentifierIslamicUmmAlQura _fw-lib _id))
(define NSCalendarIdentifierJapanese (get-ffi-obj 'NSCalendarIdentifierJapanese _fw-lib _id))
(define NSCalendarIdentifierKannada (get-ffi-obj 'NSCalendarIdentifierKannada _fw-lib _id))
(define NSCalendarIdentifierMalayalam (get-ffi-obj 'NSCalendarIdentifierMalayalam _fw-lib _id))
(define NSCalendarIdentifierMarathi (get-ffi-obj 'NSCalendarIdentifierMarathi _fw-lib _id))
(define NSCalendarIdentifierOdia (get-ffi-obj 'NSCalendarIdentifierOdia _fw-lib _id))
(define NSCalendarIdentifierPersian (get-ffi-obj 'NSCalendarIdentifierPersian _fw-lib _id))
(define NSCalendarIdentifierRepublicOfChina (get-ffi-obj 'NSCalendarIdentifierRepublicOfChina _fw-lib _id))
(define NSCalendarIdentifierTamil (get-ffi-obj 'NSCalendarIdentifierTamil _fw-lib _id))
(define NSCalendarIdentifierTelugu (get-ffi-obj 'NSCalendarIdentifierTelugu _fw-lib _id))
(define NSCalendarIdentifierVietnamese (get-ffi-obj 'NSCalendarIdentifierVietnamese _fw-lib _id))
(define NSCalendarIdentifierVikram (get-ffi-obj 'NSCalendarIdentifierVikram _fw-lib _id))
(define NSCharacterConversionException (get-ffi-obj 'NSCharacterConversionException _fw-lib _id))
(define NSChineseCalendar (get-ffi-obj 'NSChineseCalendar _fw-lib _id))
(define NSClassDescriptionNeededForClassNotification (get-ffi-obj 'NSClassDescriptionNeededForClassNotification _fw-lib _id))
(define NSCocoaErrorDomain (get-ffi-obj 'NSCocoaErrorDomain _fw-lib _id))
(define NSConnectionDidDieNotification (get-ffi-obj 'NSConnectionDidDieNotification _fw-lib _id))
(define NSConnectionDidInitializeNotification (get-ffi-obj 'NSConnectionDidInitializeNotification _fw-lib _id))
(define NSConnectionReplyMode (get-ffi-obj 'NSConnectionReplyMode _fw-lib _id))
(define NSCountKeyValueOperator (get-ffi-obj 'NSCountKeyValueOperator _fw-lib _id))
(define NSCurrencySymbol (get-ffi-obj 'NSCurrencySymbol _fw-lib _id))
(define NSCurrentLocaleDidChangeNotification (get-ffi-obj 'NSCurrentLocaleDidChangeNotification _fw-lib _id))
(define NSDateFormatString (get-ffi-obj 'NSDateFormatString _fw-lib _id))
(define NSDateTimeOrdering (get-ffi-obj 'NSDateTimeOrdering _fw-lib _id))
(define NSDebugDescriptionErrorKey (get-ffi-obj 'NSDebugDescriptionErrorKey _fw-lib _id))
(define NSDecimalDigits (get-ffi-obj 'NSDecimalDigits _fw-lib _id))
(define NSDecimalNumberDivideByZeroException (get-ffi-obj 'NSDecimalNumberDivideByZeroException _fw-lib _id))
(define NSDecimalNumberExactnessException (get-ffi-obj 'NSDecimalNumberExactnessException _fw-lib _id))
(define NSDecimalNumberOverflowException (get-ffi-obj 'NSDecimalNumberOverflowException _fw-lib _id))
(define NSDecimalNumberUnderflowException (get-ffi-obj 'NSDecimalNumberUnderflowException _fw-lib _id))
(define NSDecimalSeparator (get-ffi-obj 'NSDecimalSeparator _fw-lib _id))
(define NSDefaultRunLoopMode (get-ffi-obj 'NSDefaultRunLoopMode _fw-lib _id))
(define NSDestinationInvalidException (get-ffi-obj 'NSDestinationInvalidException _fw-lib _id))
(define NSDidBecomeSingleThreadedNotification (get-ffi-obj 'NSDidBecomeSingleThreadedNotification _fw-lib _id))
(define NSDistinctUnionOfArraysKeyValueOperator (get-ffi-obj 'NSDistinctUnionOfArraysKeyValueOperator _fw-lib _id))
(define NSDistinctUnionOfObjectsKeyValueOperator (get-ffi-obj 'NSDistinctUnionOfObjectsKeyValueOperator _fw-lib _id))
(define NSDistinctUnionOfSetsKeyValueOperator (get-ffi-obj 'NSDistinctUnionOfSetsKeyValueOperator _fw-lib _id))
(define NSEarlierTimeDesignations (get-ffi-obj 'NSEarlierTimeDesignations _fw-lib _id))
(define NSEdgeInsetsZero (ffi-obj-ref 'NSEdgeInsetsZero _fw-lib))
(define NSErrorFailingURLStringKey (get-ffi-obj 'NSErrorFailingURLStringKey _fw-lib _id))
(define NSExtensionItemAttachmentsKey (get-ffi-obj 'NSExtensionItemAttachmentsKey _fw-lib _id))
(define NSExtensionItemAttributedContentTextKey (get-ffi-obj 'NSExtensionItemAttributedContentTextKey _fw-lib _id))
(define NSExtensionItemAttributedTitleKey (get-ffi-obj 'NSExtensionItemAttributedTitleKey _fw-lib _id))
(define NSExtensionItemsAndErrorsKey (get-ffi-obj 'NSExtensionItemsAndErrorsKey _fw-lib _id))
(define NSExtensionJavaScriptPreprocessingResultsKey (get-ffi-obj 'NSExtensionJavaScriptPreprocessingResultsKey _fw-lib _id))
(define NSFTPPropertyActiveTransferModeKey (get-ffi-obj 'NSFTPPropertyActiveTransferModeKey _fw-lib _id))
(define NSFTPPropertyFTPProxy (get-ffi-obj 'NSFTPPropertyFTPProxy _fw-lib _id))
(define NSFTPPropertyFileOffsetKey (get-ffi-obj 'NSFTPPropertyFileOffsetKey _fw-lib _id))
(define NSFTPPropertyUserLoginKey (get-ffi-obj 'NSFTPPropertyUserLoginKey _fw-lib _id))
(define NSFTPPropertyUserPasswordKey (get-ffi-obj 'NSFTPPropertyUserPasswordKey _fw-lib _id))
(define NSFailedAuthenticationException (get-ffi-obj 'NSFailedAuthenticationException _fw-lib _id))
(define NSFileAppendOnly (get-ffi-obj 'NSFileAppendOnly _fw-lib _id))
(define NSFileBusy (get-ffi-obj 'NSFileBusy _fw-lib _id))
(define NSFileCreationDate (get-ffi-obj 'NSFileCreationDate _fw-lib _id))
(define NSFileDeviceIdentifier (get-ffi-obj 'NSFileDeviceIdentifier _fw-lib _id))
(define NSFileExtensionHidden (get-ffi-obj 'NSFileExtensionHidden _fw-lib _id))
(define NSFileGroupOwnerAccountID (get-ffi-obj 'NSFileGroupOwnerAccountID _fw-lib _id))
(define NSFileGroupOwnerAccountName (get-ffi-obj 'NSFileGroupOwnerAccountName _fw-lib _id))
(define NSFileHFSCreatorCode (get-ffi-obj 'NSFileHFSCreatorCode _fw-lib _id))
(define NSFileHFSTypeCode (get-ffi-obj 'NSFileHFSTypeCode _fw-lib _id))
(define NSFileHandleConnectionAcceptedNotification (get-ffi-obj 'NSFileHandleConnectionAcceptedNotification _fw-lib _id))
(define NSFileHandleDataAvailableNotification (get-ffi-obj 'NSFileHandleDataAvailableNotification _fw-lib _id))
(define NSFileHandleNotificationDataItem (get-ffi-obj 'NSFileHandleNotificationDataItem _fw-lib _id))
(define NSFileHandleNotificationFileHandleItem (get-ffi-obj 'NSFileHandleNotificationFileHandleItem _fw-lib _id))
(define NSFileHandleNotificationMonitorModes (get-ffi-obj 'NSFileHandleNotificationMonitorModes _fw-lib _id))
(define NSFileHandleOperationException (get-ffi-obj 'NSFileHandleOperationException _fw-lib _id))
(define NSFileHandleReadCompletionNotification (get-ffi-obj 'NSFileHandleReadCompletionNotification _fw-lib _id))
(define NSFileHandleReadToEndOfFileCompletionNotification (get-ffi-obj 'NSFileHandleReadToEndOfFileCompletionNotification _fw-lib _id))
(define NSFileImmutable (get-ffi-obj 'NSFileImmutable _fw-lib _id))
(define NSFileManagerUnmountDissentingProcessIdentifierErrorKey (get-ffi-obj 'NSFileManagerUnmountDissentingProcessIdentifierErrorKey _fw-lib _id))
(define NSFileModificationDate (get-ffi-obj 'NSFileModificationDate _fw-lib _id))
(define NSFileOwnerAccountID (get-ffi-obj 'NSFileOwnerAccountID _fw-lib _id))
(define NSFileOwnerAccountName (get-ffi-obj 'NSFileOwnerAccountName _fw-lib _id))
(define NSFilePathErrorKey (get-ffi-obj 'NSFilePathErrorKey _fw-lib _id))
(define NSFilePosixPermissions (get-ffi-obj 'NSFilePosixPermissions _fw-lib _id))
(define NSFileProtectionComplete (get-ffi-obj 'NSFileProtectionComplete _fw-lib _id))
(define NSFileProtectionCompleteUnlessOpen (get-ffi-obj 'NSFileProtectionCompleteUnlessOpen _fw-lib _id))
(define NSFileProtectionCompleteUntilFirstUserAuthentication (get-ffi-obj 'NSFileProtectionCompleteUntilFirstUserAuthentication _fw-lib _id))
(define NSFileProtectionKey (get-ffi-obj 'NSFileProtectionKey _fw-lib _id))
(define NSFileProtectionNone (get-ffi-obj 'NSFileProtectionNone _fw-lib _id))
(define NSFileReferenceCount (get-ffi-obj 'NSFileReferenceCount _fw-lib _id))
(define NSFileSize (get-ffi-obj 'NSFileSize _fw-lib _id))
(define NSFileSystemFileNumber (get-ffi-obj 'NSFileSystemFileNumber _fw-lib _id))
(define NSFileSystemFreeNodes (get-ffi-obj 'NSFileSystemFreeNodes _fw-lib _id))
(define NSFileSystemFreeSize (get-ffi-obj 'NSFileSystemFreeSize _fw-lib _id))
(define NSFileSystemNodes (get-ffi-obj 'NSFileSystemNodes _fw-lib _id))
(define NSFileSystemNumber (get-ffi-obj 'NSFileSystemNumber _fw-lib _id))
(define NSFileSystemSize (get-ffi-obj 'NSFileSystemSize _fw-lib _id))
(define NSFileType (get-ffi-obj 'NSFileType _fw-lib _id))
(define NSFileTypeBlockSpecial (get-ffi-obj 'NSFileTypeBlockSpecial _fw-lib _id))
(define NSFileTypeCharacterSpecial (get-ffi-obj 'NSFileTypeCharacterSpecial _fw-lib _id))
(define NSFileTypeDirectory (get-ffi-obj 'NSFileTypeDirectory _fw-lib _id))
(define NSFileTypeRegular (get-ffi-obj 'NSFileTypeRegular _fw-lib _id))
(define NSFileTypeSocket (get-ffi-obj 'NSFileTypeSocket _fw-lib _id))
(define NSFileTypeSymbolicLink (get-ffi-obj 'NSFileTypeSymbolicLink _fw-lib _id))
(define NSFileTypeUnknown (get-ffi-obj 'NSFileTypeUnknown _fw-lib _id))
(define NSFoundationVersionNumber (get-ffi-obj 'NSFoundationVersionNumber _fw-lib _double))
(define NSGenericException (get-ffi-obj 'NSGenericException _fw-lib _id))
(define NSGlobalDomain (get-ffi-obj 'NSGlobalDomain _fw-lib _id))
(define NSGrammarCorrections (get-ffi-obj 'NSGrammarCorrections _fw-lib _id))
(define NSGrammarRange (get-ffi-obj 'NSGrammarRange _fw-lib _id))
(define NSGrammarUserDescription (get-ffi-obj 'NSGrammarUserDescription _fw-lib _id))
(define NSGregorianCalendar (get-ffi-obj 'NSGregorianCalendar _fw-lib _id))
(define NSHTTPCookieComment (get-ffi-obj 'NSHTTPCookieComment _fw-lib _id))
(define NSHTTPCookieCommentURL (get-ffi-obj 'NSHTTPCookieCommentURL _fw-lib _id))
(define NSHTTPCookieDiscard (get-ffi-obj 'NSHTTPCookieDiscard _fw-lib _id))
(define NSHTTPCookieDomain (get-ffi-obj 'NSHTTPCookieDomain _fw-lib _id))
(define NSHTTPCookieExpires (get-ffi-obj 'NSHTTPCookieExpires _fw-lib _id))
(define NSHTTPCookieManagerAcceptPolicyChangedNotification (get-ffi-obj 'NSHTTPCookieManagerAcceptPolicyChangedNotification _fw-lib _id))
(define NSHTTPCookieManagerCookiesChangedNotification (get-ffi-obj 'NSHTTPCookieManagerCookiesChangedNotification _fw-lib _id))
(define NSHTTPCookieMaximumAge (get-ffi-obj 'NSHTTPCookieMaximumAge _fw-lib _id))
(define NSHTTPCookieName (get-ffi-obj 'NSHTTPCookieName _fw-lib _id))
(define NSHTTPCookieOriginURL (get-ffi-obj 'NSHTTPCookieOriginURL _fw-lib _id))
(define NSHTTPCookiePath (get-ffi-obj 'NSHTTPCookiePath _fw-lib _id))
(define NSHTTPCookiePort (get-ffi-obj 'NSHTTPCookiePort _fw-lib _id))
(define NSHTTPCookieSameSiteLax (get-ffi-obj 'NSHTTPCookieSameSiteLax _fw-lib _id))
(define NSHTTPCookieSameSitePolicy (get-ffi-obj 'NSHTTPCookieSameSitePolicy _fw-lib _id))
(define NSHTTPCookieSameSiteStrict (get-ffi-obj 'NSHTTPCookieSameSiteStrict _fw-lib _id))
(define NSHTTPCookieSecure (get-ffi-obj 'NSHTTPCookieSecure _fw-lib _id))
(define NSHTTPCookieSetByJavaScript (get-ffi-obj 'NSHTTPCookieSetByJavaScript _fw-lib _id))
(define NSHTTPCookieValue (get-ffi-obj 'NSHTTPCookieValue _fw-lib _id))
(define NSHTTPCookieVersion (get-ffi-obj 'NSHTTPCookieVersion _fw-lib _id))
(define NSHTTPPropertyErrorPageDataKey (get-ffi-obj 'NSHTTPPropertyErrorPageDataKey _fw-lib _id))
(define NSHTTPPropertyHTTPProxy (get-ffi-obj 'NSHTTPPropertyHTTPProxy _fw-lib _id))
(define NSHTTPPropertyRedirectionHeadersKey (get-ffi-obj 'NSHTTPPropertyRedirectionHeadersKey _fw-lib _id))
(define NSHTTPPropertyServerHTTPVersionKey (get-ffi-obj 'NSHTTPPropertyServerHTTPVersionKey _fw-lib _id))
(define NSHTTPPropertyStatusCodeKey (get-ffi-obj 'NSHTTPPropertyStatusCodeKey _fw-lib _id))
(define NSHTTPPropertyStatusReasonKey (get-ffi-obj 'NSHTTPPropertyStatusReasonKey _fw-lib _id))
(define NSHebrewCalendar (get-ffi-obj 'NSHebrewCalendar _fw-lib _id))
(define NSHelpAnchorErrorKey (get-ffi-obj 'NSHelpAnchorErrorKey _fw-lib _id))
(define NSHourNameDesignations (get-ffi-obj 'NSHourNameDesignations _fw-lib _id))
(define NSISO8601Calendar (get-ffi-obj 'NSISO8601Calendar _fw-lib _id))
(define NSImageURLAttributeName (get-ffi-obj 'NSImageURLAttributeName _fw-lib _id))
(define NSInconsistentArchiveException (get-ffi-obj 'NSInconsistentArchiveException _fw-lib _id))
(define NSIndianCalendar (get-ffi-obj 'NSIndianCalendar _fw-lib _id))
(define NSInflectionAgreementArgumentAttributeName (get-ffi-obj 'NSInflectionAgreementArgumentAttributeName _fw-lib _id))
(define NSInflectionAgreementConceptAttributeName (get-ffi-obj 'NSInflectionAgreementConceptAttributeName _fw-lib _id))
(define NSInflectionAlternativeAttributeName (get-ffi-obj 'NSInflectionAlternativeAttributeName _fw-lib _id))
(define NSInflectionConceptsKey (get-ffi-obj 'NSInflectionConceptsKey _fw-lib _id))
(define NSInflectionReferentConceptAttributeName (get-ffi-obj 'NSInflectionReferentConceptAttributeName _fw-lib _id))
(define NSInflectionRuleAttributeName (get-ffi-obj 'NSInflectionRuleAttributeName _fw-lib _id))
(define NSInlinePresentationIntentAttributeName (get-ffi-obj 'NSInlinePresentationIntentAttributeName _fw-lib _id))
(define NSIntHashCallBacks (ffi-obj-ref 'NSIntHashCallBacks _fw-lib))
(define NSIntMapKeyCallBacks (ffi-obj-ref 'NSIntMapKeyCallBacks _fw-lib))
(define NSIntMapValueCallBacks (ffi-obj-ref 'NSIntMapValueCallBacks _fw-lib))
(define NSIntegerHashCallBacks (ffi-obj-ref 'NSIntegerHashCallBacks _fw-lib))
(define NSIntegerMapKeyCallBacks (ffi-obj-ref 'NSIntegerMapKeyCallBacks _fw-lib))
(define NSIntegerMapValueCallBacks (ffi-obj-ref 'NSIntegerMapValueCallBacks _fw-lib))
(define NSInternalInconsistencyException (get-ffi-obj 'NSInternalInconsistencyException _fw-lib _id))
(define NSInternationalCurrencyString (get-ffi-obj 'NSInternationalCurrencyString _fw-lib _id))
(define NSInvalidArchiveOperationException (get-ffi-obj 'NSInvalidArchiveOperationException _fw-lib _id))
(define NSInvalidArgumentException (get-ffi-obj 'NSInvalidArgumentException _fw-lib _id))
(define NSInvalidReceivePortException (get-ffi-obj 'NSInvalidReceivePortException _fw-lib _id))
(define NSInvalidSendPortException (get-ffi-obj 'NSInvalidSendPortException _fw-lib _id))
(define NSInvalidUnarchiveOperationException (get-ffi-obj 'NSInvalidUnarchiveOperationException _fw-lib _id))
(define NSInvocationOperationCancelledException (get-ffi-obj 'NSInvocationOperationCancelledException _fw-lib _id))
(define NSInvocationOperationVoidResultException (get-ffi-obj 'NSInvocationOperationVoidResultException _fw-lib _id))
(define NSIsNilTransformerName (get-ffi-obj 'NSIsNilTransformerName _fw-lib _id))
(define NSIsNotNilTransformerName (get-ffi-obj 'NSIsNotNilTransformerName _fw-lib _id))
(define NSIslamicCalendar (get-ffi-obj 'NSIslamicCalendar _fw-lib _id))
(define NSIslamicCivilCalendar (get-ffi-obj 'NSIslamicCivilCalendar _fw-lib _id))
(define NSItemProviderErrorDomain (get-ffi-obj 'NSItemProviderErrorDomain _fw-lib _id))
(define NSItemProviderPreferredImageSizeKey (get-ffi-obj 'NSItemProviderPreferredImageSizeKey _fw-lib _id))
(define NSJapaneseCalendar (get-ffi-obj 'NSJapaneseCalendar _fw-lib _id))
(define NSKeyValueChangeIndexesKey (get-ffi-obj 'NSKeyValueChangeIndexesKey _fw-lib _id))
(define NSKeyValueChangeKindKey (get-ffi-obj 'NSKeyValueChangeKindKey _fw-lib _id))
(define NSKeyValueChangeNewKey (get-ffi-obj 'NSKeyValueChangeNewKey _fw-lib _id))
(define NSKeyValueChangeNotificationIsPriorKey (get-ffi-obj 'NSKeyValueChangeNotificationIsPriorKey _fw-lib _id))
(define NSKeyValueChangeOldKey (get-ffi-obj 'NSKeyValueChangeOldKey _fw-lib _id))
(define NSKeyedArchiveRootObjectKey (get-ffi-obj 'NSKeyedArchiveRootObjectKey _fw-lib _id))
(define NSKeyedUnarchiveFromDataTransformerName (get-ffi-obj 'NSKeyedUnarchiveFromDataTransformerName _fw-lib _id))
(define NSLanguageIdentifierAttributeName (get-ffi-obj 'NSLanguageIdentifierAttributeName _fw-lib _id))
(define NSLaterTimeDesignations (get-ffi-obj 'NSLaterTimeDesignations _fw-lib _id))
(define NSLinguisticTagAdjective (get-ffi-obj 'NSLinguisticTagAdjective _fw-lib _id))
(define NSLinguisticTagAdverb (get-ffi-obj 'NSLinguisticTagAdverb _fw-lib _id))
(define NSLinguisticTagClassifier (get-ffi-obj 'NSLinguisticTagClassifier _fw-lib _id))
(define NSLinguisticTagCloseParenthesis (get-ffi-obj 'NSLinguisticTagCloseParenthesis _fw-lib _id))
(define NSLinguisticTagCloseQuote (get-ffi-obj 'NSLinguisticTagCloseQuote _fw-lib _id))
(define NSLinguisticTagConjunction (get-ffi-obj 'NSLinguisticTagConjunction _fw-lib _id))
(define NSLinguisticTagDash (get-ffi-obj 'NSLinguisticTagDash _fw-lib _id))
(define NSLinguisticTagDeterminer (get-ffi-obj 'NSLinguisticTagDeterminer _fw-lib _id))
(define NSLinguisticTagIdiom (get-ffi-obj 'NSLinguisticTagIdiom _fw-lib _id))
(define NSLinguisticTagInterjection (get-ffi-obj 'NSLinguisticTagInterjection _fw-lib _id))
(define NSLinguisticTagNoun (get-ffi-obj 'NSLinguisticTagNoun _fw-lib _id))
(define NSLinguisticTagNumber (get-ffi-obj 'NSLinguisticTagNumber _fw-lib _id))
(define NSLinguisticTagOpenParenthesis (get-ffi-obj 'NSLinguisticTagOpenParenthesis _fw-lib _id))
(define NSLinguisticTagOpenQuote (get-ffi-obj 'NSLinguisticTagOpenQuote _fw-lib _id))
(define NSLinguisticTagOrganizationName (get-ffi-obj 'NSLinguisticTagOrganizationName _fw-lib _id))
(define NSLinguisticTagOther (get-ffi-obj 'NSLinguisticTagOther _fw-lib _id))
(define NSLinguisticTagOtherPunctuation (get-ffi-obj 'NSLinguisticTagOtherPunctuation _fw-lib _id))
(define NSLinguisticTagOtherWhitespace (get-ffi-obj 'NSLinguisticTagOtherWhitespace _fw-lib _id))
(define NSLinguisticTagOtherWord (get-ffi-obj 'NSLinguisticTagOtherWord _fw-lib _id))
(define NSLinguisticTagParagraphBreak (get-ffi-obj 'NSLinguisticTagParagraphBreak _fw-lib _id))
(define NSLinguisticTagParticle (get-ffi-obj 'NSLinguisticTagParticle _fw-lib _id))
(define NSLinguisticTagPersonalName (get-ffi-obj 'NSLinguisticTagPersonalName _fw-lib _id))
(define NSLinguisticTagPlaceName (get-ffi-obj 'NSLinguisticTagPlaceName _fw-lib _id))
(define NSLinguisticTagPreposition (get-ffi-obj 'NSLinguisticTagPreposition _fw-lib _id))
(define NSLinguisticTagPronoun (get-ffi-obj 'NSLinguisticTagPronoun _fw-lib _id))
(define NSLinguisticTagPunctuation (get-ffi-obj 'NSLinguisticTagPunctuation _fw-lib _id))
(define NSLinguisticTagSchemeLanguage (get-ffi-obj 'NSLinguisticTagSchemeLanguage _fw-lib _id))
(define NSLinguisticTagSchemeLemma (get-ffi-obj 'NSLinguisticTagSchemeLemma _fw-lib _id))
(define NSLinguisticTagSchemeLexicalClass (get-ffi-obj 'NSLinguisticTagSchemeLexicalClass _fw-lib _id))
(define NSLinguisticTagSchemeNameType (get-ffi-obj 'NSLinguisticTagSchemeNameType _fw-lib _id))
(define NSLinguisticTagSchemeNameTypeOrLexicalClass (get-ffi-obj 'NSLinguisticTagSchemeNameTypeOrLexicalClass _fw-lib _id))
(define NSLinguisticTagSchemeScript (get-ffi-obj 'NSLinguisticTagSchemeScript _fw-lib _id))
(define NSLinguisticTagSchemeTokenType (get-ffi-obj 'NSLinguisticTagSchemeTokenType _fw-lib _id))
(define NSLinguisticTagSentenceTerminator (get-ffi-obj 'NSLinguisticTagSentenceTerminator _fw-lib _id))
(define NSLinguisticTagVerb (get-ffi-obj 'NSLinguisticTagVerb _fw-lib _id))
(define NSLinguisticTagWhitespace (get-ffi-obj 'NSLinguisticTagWhitespace _fw-lib _id))
(define NSLinguisticTagWord (get-ffi-obj 'NSLinguisticTagWord _fw-lib _id))
(define NSLinguisticTagWordJoiner (get-ffi-obj 'NSLinguisticTagWordJoiner _fw-lib _id))
(define NSListItemDelimiterAttributeName (get-ffi-obj 'NSListItemDelimiterAttributeName _fw-lib _id))
(define NSLoadedClasses (get-ffi-obj 'NSLoadedClasses _fw-lib _id))
(define NSLocalNotificationCenterType (get-ffi-obj 'NSLocalNotificationCenterType _fw-lib _id))
(define NSLocaleAlternateQuotationBeginDelimiterKey (get-ffi-obj 'NSLocaleAlternateQuotationBeginDelimiterKey _fw-lib _id))
(define NSLocaleAlternateQuotationEndDelimiterKey (get-ffi-obj 'NSLocaleAlternateQuotationEndDelimiterKey _fw-lib _id))
(define NSLocaleCalendar (get-ffi-obj 'NSLocaleCalendar _fw-lib _id))
(define NSLocaleCollationIdentifier (get-ffi-obj 'NSLocaleCollationIdentifier _fw-lib _id))
(define NSLocaleCollatorIdentifier (get-ffi-obj 'NSLocaleCollatorIdentifier _fw-lib _id))
(define NSLocaleCountryCode (get-ffi-obj 'NSLocaleCountryCode _fw-lib _id))
(define NSLocaleCurrencyCode (get-ffi-obj 'NSLocaleCurrencyCode _fw-lib _id))
(define NSLocaleCurrencySymbol (get-ffi-obj 'NSLocaleCurrencySymbol _fw-lib _id))
(define NSLocaleDecimalSeparator (get-ffi-obj 'NSLocaleDecimalSeparator _fw-lib _id))
(define NSLocaleExemplarCharacterSet (get-ffi-obj 'NSLocaleExemplarCharacterSet _fw-lib _id))
(define NSLocaleGroupingSeparator (get-ffi-obj 'NSLocaleGroupingSeparator _fw-lib _id))
(define NSLocaleIdentifier (get-ffi-obj 'NSLocaleIdentifier _fw-lib _id))
(define NSLocaleLanguageCode (get-ffi-obj 'NSLocaleLanguageCode _fw-lib _id))
(define NSLocaleMeasurementSystem (get-ffi-obj 'NSLocaleMeasurementSystem _fw-lib _id))
(define NSLocaleQuotationBeginDelimiterKey (get-ffi-obj 'NSLocaleQuotationBeginDelimiterKey _fw-lib _id))
(define NSLocaleQuotationEndDelimiterKey (get-ffi-obj 'NSLocaleQuotationEndDelimiterKey _fw-lib _id))
(define NSLocaleScriptCode (get-ffi-obj 'NSLocaleScriptCode _fw-lib _id))
(define NSLocaleUsesMetricSystem (get-ffi-obj 'NSLocaleUsesMetricSystem _fw-lib _id))
(define NSLocaleVariantCode (get-ffi-obj 'NSLocaleVariantCode _fw-lib _id))
(define NSLocalizedDescriptionKey (get-ffi-obj 'NSLocalizedDescriptionKey _fw-lib _id))
(define NSLocalizedFailureErrorKey (get-ffi-obj 'NSLocalizedFailureErrorKey _fw-lib _id))
(define NSLocalizedFailureReasonErrorKey (get-ffi-obj 'NSLocalizedFailureReasonErrorKey _fw-lib _id))
(define NSLocalizedNumberFormatAttributeName (get-ffi-obj 'NSLocalizedNumberFormatAttributeName _fw-lib _id))
(define NSLocalizedRecoveryOptionsErrorKey (get-ffi-obj 'NSLocalizedRecoveryOptionsErrorKey _fw-lib _id))
(define NSLocalizedRecoverySuggestionErrorKey (get-ffi-obj 'NSLocalizedRecoverySuggestionErrorKey _fw-lib _id))
(define NSMachErrorDomain (get-ffi-obj 'NSMachErrorDomain _fw-lib _id))
(define NSMallocException (get-ffi-obj 'NSMallocException _fw-lib _id))
(define NSMarkdownSourcePositionAttributeName (get-ffi-obj 'NSMarkdownSourcePositionAttributeName _fw-lib _id))
(define NSMaximumKeyValueOperator (get-ffi-obj 'NSMaximumKeyValueOperator _fw-lib _id))
(define NSMetadataItemAcquisitionMakeKey (get-ffi-obj 'NSMetadataItemAcquisitionMakeKey _fw-lib _id))
(define NSMetadataItemAcquisitionModelKey (get-ffi-obj 'NSMetadataItemAcquisitionModelKey _fw-lib _id))
(define NSMetadataItemAlbumKey (get-ffi-obj 'NSMetadataItemAlbumKey _fw-lib _id))
(define NSMetadataItemAltitudeKey (get-ffi-obj 'NSMetadataItemAltitudeKey _fw-lib _id))
(define NSMetadataItemApertureKey (get-ffi-obj 'NSMetadataItemApertureKey _fw-lib _id))
(define NSMetadataItemAppleLoopDescriptorsKey (get-ffi-obj 'NSMetadataItemAppleLoopDescriptorsKey _fw-lib _id))
(define NSMetadataItemAppleLoopsKeyFilterTypeKey (get-ffi-obj 'NSMetadataItemAppleLoopsKeyFilterTypeKey _fw-lib _id))
(define NSMetadataItemAppleLoopsLoopModeKey (get-ffi-obj 'NSMetadataItemAppleLoopsLoopModeKey _fw-lib _id))
(define NSMetadataItemAppleLoopsRootKeyKey (get-ffi-obj 'NSMetadataItemAppleLoopsRootKeyKey _fw-lib _id))
(define NSMetadataItemApplicationCategoriesKey (get-ffi-obj 'NSMetadataItemApplicationCategoriesKey _fw-lib _id))
(define NSMetadataItemAttributeChangeDateKey (get-ffi-obj 'NSMetadataItemAttributeChangeDateKey _fw-lib _id))
(define NSMetadataItemAudiencesKey (get-ffi-obj 'NSMetadataItemAudiencesKey _fw-lib _id))
(define NSMetadataItemAudioBitRateKey (get-ffi-obj 'NSMetadataItemAudioBitRateKey _fw-lib _id))
(define NSMetadataItemAudioChannelCountKey (get-ffi-obj 'NSMetadataItemAudioChannelCountKey _fw-lib _id))
(define NSMetadataItemAudioEncodingApplicationKey (get-ffi-obj 'NSMetadataItemAudioEncodingApplicationKey _fw-lib _id))
(define NSMetadataItemAudioSampleRateKey (get-ffi-obj 'NSMetadataItemAudioSampleRateKey _fw-lib _id))
(define NSMetadataItemAudioTrackNumberKey (get-ffi-obj 'NSMetadataItemAudioTrackNumberKey _fw-lib _id))
(define NSMetadataItemAuthorAddressesKey (get-ffi-obj 'NSMetadataItemAuthorAddressesKey _fw-lib _id))
(define NSMetadataItemAuthorEmailAddressesKey (get-ffi-obj 'NSMetadataItemAuthorEmailAddressesKey _fw-lib _id))
(define NSMetadataItemAuthorsKey (get-ffi-obj 'NSMetadataItemAuthorsKey _fw-lib _id))
(define NSMetadataItemBitsPerSampleKey (get-ffi-obj 'NSMetadataItemBitsPerSampleKey _fw-lib _id))
(define NSMetadataItemCFBundleIdentifierKey (get-ffi-obj 'NSMetadataItemCFBundleIdentifierKey _fw-lib _id))
(define NSMetadataItemCameraOwnerKey (get-ffi-obj 'NSMetadataItemCameraOwnerKey _fw-lib _id))
(define NSMetadataItemCityKey (get-ffi-obj 'NSMetadataItemCityKey _fw-lib _id))
(define NSMetadataItemCodecsKey (get-ffi-obj 'NSMetadataItemCodecsKey _fw-lib _id))
(define NSMetadataItemColorSpaceKey (get-ffi-obj 'NSMetadataItemColorSpaceKey _fw-lib _id))
(define NSMetadataItemCommentKey (get-ffi-obj 'NSMetadataItemCommentKey _fw-lib _id))
(define NSMetadataItemComposerKey (get-ffi-obj 'NSMetadataItemComposerKey _fw-lib _id))
(define NSMetadataItemContactKeywordsKey (get-ffi-obj 'NSMetadataItemContactKeywordsKey _fw-lib _id))
(define NSMetadataItemContentCreationDateKey (get-ffi-obj 'NSMetadataItemContentCreationDateKey _fw-lib _id))
(define NSMetadataItemContentModificationDateKey (get-ffi-obj 'NSMetadataItemContentModificationDateKey _fw-lib _id))
(define NSMetadataItemContentTypeKey (get-ffi-obj 'NSMetadataItemContentTypeKey _fw-lib _id))
(define NSMetadataItemContentTypeTreeKey (get-ffi-obj 'NSMetadataItemContentTypeTreeKey _fw-lib _id))
(define NSMetadataItemContributorsKey (get-ffi-obj 'NSMetadataItemContributorsKey _fw-lib _id))
(define NSMetadataItemCopyrightKey (get-ffi-obj 'NSMetadataItemCopyrightKey _fw-lib _id))
(define NSMetadataItemCountryKey (get-ffi-obj 'NSMetadataItemCountryKey _fw-lib _id))
(define NSMetadataItemCoverageKey (get-ffi-obj 'NSMetadataItemCoverageKey _fw-lib _id))
(define NSMetadataItemCreatorKey (get-ffi-obj 'NSMetadataItemCreatorKey _fw-lib _id))
(define NSMetadataItemDateAddedKey (get-ffi-obj 'NSMetadataItemDateAddedKey _fw-lib _id))
(define NSMetadataItemDeliveryTypeKey (get-ffi-obj 'NSMetadataItemDeliveryTypeKey _fw-lib _id))
(define NSMetadataItemDescriptionKey (get-ffi-obj 'NSMetadataItemDescriptionKey _fw-lib _id))
(define NSMetadataItemDirectorKey (get-ffi-obj 'NSMetadataItemDirectorKey _fw-lib _id))
(define NSMetadataItemDisplayNameKey (get-ffi-obj 'NSMetadataItemDisplayNameKey _fw-lib _id))
(define NSMetadataItemDownloadedDateKey (get-ffi-obj 'NSMetadataItemDownloadedDateKey _fw-lib _id))
(define NSMetadataItemDueDateKey (get-ffi-obj 'NSMetadataItemDueDateKey _fw-lib _id))
(define NSMetadataItemDurationSecondsKey (get-ffi-obj 'NSMetadataItemDurationSecondsKey _fw-lib _id))
(define NSMetadataItemEXIFGPSVersionKey (get-ffi-obj 'NSMetadataItemEXIFGPSVersionKey _fw-lib _id))
(define NSMetadataItemEXIFVersionKey (get-ffi-obj 'NSMetadataItemEXIFVersionKey _fw-lib _id))
(define NSMetadataItemEditorsKey (get-ffi-obj 'NSMetadataItemEditorsKey _fw-lib _id))
(define NSMetadataItemEmailAddressesKey (get-ffi-obj 'NSMetadataItemEmailAddressesKey _fw-lib _id))
(define NSMetadataItemEncodingApplicationsKey (get-ffi-obj 'NSMetadataItemEncodingApplicationsKey _fw-lib _id))
(define NSMetadataItemExecutableArchitecturesKey (get-ffi-obj 'NSMetadataItemExecutableArchitecturesKey _fw-lib _id))
(define NSMetadataItemExecutablePlatformKey (get-ffi-obj 'NSMetadataItemExecutablePlatformKey _fw-lib _id))
(define NSMetadataItemExposureModeKey (get-ffi-obj 'NSMetadataItemExposureModeKey _fw-lib _id))
(define NSMetadataItemExposureProgramKey (get-ffi-obj 'NSMetadataItemExposureProgramKey _fw-lib _id))
(define NSMetadataItemExposureTimeSecondsKey (get-ffi-obj 'NSMetadataItemExposureTimeSecondsKey _fw-lib _id))
(define NSMetadataItemExposureTimeStringKey (get-ffi-obj 'NSMetadataItemExposureTimeStringKey _fw-lib _id))
(define NSMetadataItemFNumberKey (get-ffi-obj 'NSMetadataItemFNumberKey _fw-lib _id))
(define NSMetadataItemFSContentChangeDateKey (get-ffi-obj 'NSMetadataItemFSContentChangeDateKey _fw-lib _id))
(define NSMetadataItemFSCreationDateKey (get-ffi-obj 'NSMetadataItemFSCreationDateKey _fw-lib _id))
(define NSMetadataItemFSNameKey (get-ffi-obj 'NSMetadataItemFSNameKey _fw-lib _id))
(define NSMetadataItemFSSizeKey (get-ffi-obj 'NSMetadataItemFSSizeKey _fw-lib _id))
(define NSMetadataItemFinderCommentKey (get-ffi-obj 'NSMetadataItemFinderCommentKey _fw-lib _id))
(define NSMetadataItemFlashOnOffKey (get-ffi-obj 'NSMetadataItemFlashOnOffKey _fw-lib _id))
(define NSMetadataItemFocalLength35mmKey (get-ffi-obj 'NSMetadataItemFocalLength35mmKey _fw-lib _id))
(define NSMetadataItemFocalLengthKey (get-ffi-obj 'NSMetadataItemFocalLengthKey _fw-lib _id))
(define NSMetadataItemFontsKey (get-ffi-obj 'NSMetadataItemFontsKey _fw-lib _id))
(define NSMetadataItemGPSAreaInformationKey (get-ffi-obj 'NSMetadataItemGPSAreaInformationKey _fw-lib _id))
(define NSMetadataItemGPSDOPKey (get-ffi-obj 'NSMetadataItemGPSDOPKey _fw-lib _id))
(define NSMetadataItemGPSDateStampKey (get-ffi-obj 'NSMetadataItemGPSDateStampKey _fw-lib _id))
(define NSMetadataItemGPSDestBearingKey (get-ffi-obj 'NSMetadataItemGPSDestBearingKey _fw-lib _id))
(define NSMetadataItemGPSDestDistanceKey (get-ffi-obj 'NSMetadataItemGPSDestDistanceKey _fw-lib _id))
(define NSMetadataItemGPSDestLatitudeKey (get-ffi-obj 'NSMetadataItemGPSDestLatitudeKey _fw-lib _id))
(define NSMetadataItemGPSDestLongitudeKey (get-ffi-obj 'NSMetadataItemGPSDestLongitudeKey _fw-lib _id))
(define NSMetadataItemGPSDifferentalKey (get-ffi-obj 'NSMetadataItemGPSDifferentalKey _fw-lib _id))
(define NSMetadataItemGPSMapDatumKey (get-ffi-obj 'NSMetadataItemGPSMapDatumKey _fw-lib _id))
(define NSMetadataItemGPSMeasureModeKey (get-ffi-obj 'NSMetadataItemGPSMeasureModeKey _fw-lib _id))
(define NSMetadataItemGPSProcessingMethodKey (get-ffi-obj 'NSMetadataItemGPSProcessingMethodKey _fw-lib _id))
(define NSMetadataItemGPSStatusKey (get-ffi-obj 'NSMetadataItemGPSStatusKey _fw-lib _id))
(define NSMetadataItemGPSTrackKey (get-ffi-obj 'NSMetadataItemGPSTrackKey _fw-lib _id))
(define NSMetadataItemGenreKey (get-ffi-obj 'NSMetadataItemGenreKey _fw-lib _id))
(define NSMetadataItemHasAlphaChannelKey (get-ffi-obj 'NSMetadataItemHasAlphaChannelKey _fw-lib _id))
(define NSMetadataItemHeadlineKey (get-ffi-obj 'NSMetadataItemHeadlineKey _fw-lib _id))
(define NSMetadataItemISOSpeedKey (get-ffi-obj 'NSMetadataItemISOSpeedKey _fw-lib _id))
(define NSMetadataItemIdentifierKey (get-ffi-obj 'NSMetadataItemIdentifierKey _fw-lib _id))
(define NSMetadataItemImageDirectionKey (get-ffi-obj 'NSMetadataItemImageDirectionKey _fw-lib _id))
(define NSMetadataItemInformationKey (get-ffi-obj 'NSMetadataItemInformationKey _fw-lib _id))
(define NSMetadataItemInstantMessageAddressesKey (get-ffi-obj 'NSMetadataItemInstantMessageAddressesKey _fw-lib _id))
(define NSMetadataItemInstructionsKey (get-ffi-obj 'NSMetadataItemInstructionsKey _fw-lib _id))
(define NSMetadataItemIsApplicationManagedKey (get-ffi-obj 'NSMetadataItemIsApplicationManagedKey _fw-lib _id))
(define NSMetadataItemIsGeneralMIDISequenceKey (get-ffi-obj 'NSMetadataItemIsGeneralMIDISequenceKey _fw-lib _id))
(define NSMetadataItemIsLikelyJunkKey (get-ffi-obj 'NSMetadataItemIsLikelyJunkKey _fw-lib _id))
(define NSMetadataItemIsUbiquitousKey (get-ffi-obj 'NSMetadataItemIsUbiquitousKey _fw-lib _id))
(define NSMetadataItemKeySignatureKey (get-ffi-obj 'NSMetadataItemKeySignatureKey _fw-lib _id))
(define NSMetadataItemKeywordsKey (get-ffi-obj 'NSMetadataItemKeywordsKey _fw-lib _id))
(define NSMetadataItemKindKey (get-ffi-obj 'NSMetadataItemKindKey _fw-lib _id))
(define NSMetadataItemLanguagesKey (get-ffi-obj 'NSMetadataItemLanguagesKey _fw-lib _id))
(define NSMetadataItemLastUsedDateKey (get-ffi-obj 'NSMetadataItemLastUsedDateKey _fw-lib _id))
(define NSMetadataItemLatitudeKey (get-ffi-obj 'NSMetadataItemLatitudeKey _fw-lib _id))
(define NSMetadataItemLayerNamesKey (get-ffi-obj 'NSMetadataItemLayerNamesKey _fw-lib _id))
(define NSMetadataItemLensModelKey (get-ffi-obj 'NSMetadataItemLensModelKey _fw-lib _id))
(define NSMetadataItemLongitudeKey (get-ffi-obj 'NSMetadataItemLongitudeKey _fw-lib _id))
(define NSMetadataItemLyricistKey (get-ffi-obj 'NSMetadataItemLyricistKey _fw-lib _id))
(define NSMetadataItemMaxApertureKey (get-ffi-obj 'NSMetadataItemMaxApertureKey _fw-lib _id))
(define NSMetadataItemMediaTypesKey (get-ffi-obj 'NSMetadataItemMediaTypesKey _fw-lib _id))
(define NSMetadataItemMeteringModeKey (get-ffi-obj 'NSMetadataItemMeteringModeKey _fw-lib _id))
(define NSMetadataItemMusicalGenreKey (get-ffi-obj 'NSMetadataItemMusicalGenreKey _fw-lib _id))
(define NSMetadataItemMusicalInstrumentCategoryKey (get-ffi-obj 'NSMetadataItemMusicalInstrumentCategoryKey _fw-lib _id))
(define NSMetadataItemMusicalInstrumentNameKey (get-ffi-obj 'NSMetadataItemMusicalInstrumentNameKey _fw-lib _id))
(define NSMetadataItemNamedLocationKey (get-ffi-obj 'NSMetadataItemNamedLocationKey _fw-lib _id))
(define NSMetadataItemNumberOfPagesKey (get-ffi-obj 'NSMetadataItemNumberOfPagesKey _fw-lib _id))
(define NSMetadataItemOrganizationsKey (get-ffi-obj 'NSMetadataItemOrganizationsKey _fw-lib _id))
(define NSMetadataItemOrientationKey (get-ffi-obj 'NSMetadataItemOrientationKey _fw-lib _id))
(define NSMetadataItemOriginalFormatKey (get-ffi-obj 'NSMetadataItemOriginalFormatKey _fw-lib _id))
(define NSMetadataItemOriginalSourceKey (get-ffi-obj 'NSMetadataItemOriginalSourceKey _fw-lib _id))
(define NSMetadataItemPageHeightKey (get-ffi-obj 'NSMetadataItemPageHeightKey _fw-lib _id))
(define NSMetadataItemPageWidthKey (get-ffi-obj 'NSMetadataItemPageWidthKey _fw-lib _id))
(define NSMetadataItemParticipantsKey (get-ffi-obj 'NSMetadataItemParticipantsKey _fw-lib _id))
(define NSMetadataItemPathKey (get-ffi-obj 'NSMetadataItemPathKey _fw-lib _id))
(define NSMetadataItemPerformersKey (get-ffi-obj 'NSMetadataItemPerformersKey _fw-lib _id))
(define NSMetadataItemPhoneNumbersKey (get-ffi-obj 'NSMetadataItemPhoneNumbersKey _fw-lib _id))
(define NSMetadataItemPixelCountKey (get-ffi-obj 'NSMetadataItemPixelCountKey _fw-lib _id))
(define NSMetadataItemPixelHeightKey (get-ffi-obj 'NSMetadataItemPixelHeightKey _fw-lib _id))
(define NSMetadataItemPixelWidthKey (get-ffi-obj 'NSMetadataItemPixelWidthKey _fw-lib _id))
(define NSMetadataItemProducerKey (get-ffi-obj 'NSMetadataItemProducerKey _fw-lib _id))
(define NSMetadataItemProfileNameKey (get-ffi-obj 'NSMetadataItemProfileNameKey _fw-lib _id))
(define NSMetadataItemProjectsKey (get-ffi-obj 'NSMetadataItemProjectsKey _fw-lib _id))
(define NSMetadataItemPublishersKey (get-ffi-obj 'NSMetadataItemPublishersKey _fw-lib _id))
(define NSMetadataItemRecipientAddressesKey (get-ffi-obj 'NSMetadataItemRecipientAddressesKey _fw-lib _id))
(define NSMetadataItemRecipientEmailAddressesKey (get-ffi-obj 'NSMetadataItemRecipientEmailAddressesKey _fw-lib _id))
(define NSMetadataItemRecipientsKey (get-ffi-obj 'NSMetadataItemRecipientsKey _fw-lib _id))
(define NSMetadataItemRecordingDateKey (get-ffi-obj 'NSMetadataItemRecordingDateKey _fw-lib _id))
(define NSMetadataItemRecordingYearKey (get-ffi-obj 'NSMetadataItemRecordingYearKey _fw-lib _id))
(define NSMetadataItemRedEyeOnOffKey (get-ffi-obj 'NSMetadataItemRedEyeOnOffKey _fw-lib _id))
(define NSMetadataItemResolutionHeightDPIKey (get-ffi-obj 'NSMetadataItemResolutionHeightDPIKey _fw-lib _id))
(define NSMetadataItemResolutionWidthDPIKey (get-ffi-obj 'NSMetadataItemResolutionWidthDPIKey _fw-lib _id))
(define NSMetadataItemRightsKey (get-ffi-obj 'NSMetadataItemRightsKey _fw-lib _id))
(define NSMetadataItemSecurityMethodKey (get-ffi-obj 'NSMetadataItemSecurityMethodKey _fw-lib _id))
(define NSMetadataItemSpeedKey (get-ffi-obj 'NSMetadataItemSpeedKey _fw-lib _id))
(define NSMetadataItemStarRatingKey (get-ffi-obj 'NSMetadataItemStarRatingKey _fw-lib _id))
(define NSMetadataItemStateOrProvinceKey (get-ffi-obj 'NSMetadataItemStateOrProvinceKey _fw-lib _id))
(define NSMetadataItemStreamableKey (get-ffi-obj 'NSMetadataItemStreamableKey _fw-lib _id))
(define NSMetadataItemSubjectKey (get-ffi-obj 'NSMetadataItemSubjectKey _fw-lib _id))
(define NSMetadataItemTempoKey (get-ffi-obj 'NSMetadataItemTempoKey _fw-lib _id))
(define NSMetadataItemTextContentKey (get-ffi-obj 'NSMetadataItemTextContentKey _fw-lib _id))
(define NSMetadataItemThemeKey (get-ffi-obj 'NSMetadataItemThemeKey _fw-lib _id))
(define NSMetadataItemTimeSignatureKey (get-ffi-obj 'NSMetadataItemTimeSignatureKey _fw-lib _id))
(define NSMetadataItemTimestampKey (get-ffi-obj 'NSMetadataItemTimestampKey _fw-lib _id))
(define NSMetadataItemTitleKey (get-ffi-obj 'NSMetadataItemTitleKey _fw-lib _id))
(define NSMetadataItemTotalBitRateKey (get-ffi-obj 'NSMetadataItemTotalBitRateKey _fw-lib _id))
(define NSMetadataItemURLKey (get-ffi-obj 'NSMetadataItemURLKey _fw-lib _id))
(define NSMetadataItemVersionKey (get-ffi-obj 'NSMetadataItemVersionKey _fw-lib _id))
(define NSMetadataItemVideoBitRateKey (get-ffi-obj 'NSMetadataItemVideoBitRateKey _fw-lib _id))
(define NSMetadataItemWhereFromsKey (get-ffi-obj 'NSMetadataItemWhereFromsKey _fw-lib _id))
(define NSMetadataItemWhiteBalanceKey (get-ffi-obj 'NSMetadataItemWhiteBalanceKey _fw-lib _id))
(define NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope (get-ffi-obj 'NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope _fw-lib _id))
(define NSMetadataQueryDidFinishGatheringNotification (get-ffi-obj 'NSMetadataQueryDidFinishGatheringNotification _fw-lib _id))
(define NSMetadataQueryDidStartGatheringNotification (get-ffi-obj 'NSMetadataQueryDidStartGatheringNotification _fw-lib _id))
(define NSMetadataQueryDidUpdateNotification (get-ffi-obj 'NSMetadataQueryDidUpdateNotification _fw-lib _id))
(define NSMetadataQueryGatheringProgressNotification (get-ffi-obj 'NSMetadataQueryGatheringProgressNotification _fw-lib _id))
(define NSMetadataQueryIndexedLocalComputerScope (get-ffi-obj 'NSMetadataQueryIndexedLocalComputerScope _fw-lib _id))
(define NSMetadataQueryIndexedNetworkScope (get-ffi-obj 'NSMetadataQueryIndexedNetworkScope _fw-lib _id))
(define NSMetadataQueryLocalComputerScope (get-ffi-obj 'NSMetadataQueryLocalComputerScope _fw-lib _id))
(define NSMetadataQueryNetworkScope (get-ffi-obj 'NSMetadataQueryNetworkScope _fw-lib _id))
(define NSMetadataQueryResultContentRelevanceAttribute (get-ffi-obj 'NSMetadataQueryResultContentRelevanceAttribute _fw-lib _id))
(define NSMetadataQueryUbiquitousDataScope (get-ffi-obj 'NSMetadataQueryUbiquitousDataScope _fw-lib _id))
(define NSMetadataQueryUbiquitousDocumentsScope (get-ffi-obj 'NSMetadataQueryUbiquitousDocumentsScope _fw-lib _id))
(define NSMetadataQueryUpdateAddedItemsKey (get-ffi-obj 'NSMetadataQueryUpdateAddedItemsKey _fw-lib _id))
(define NSMetadataQueryUpdateChangedItemsKey (get-ffi-obj 'NSMetadataQueryUpdateChangedItemsKey _fw-lib _id))
(define NSMetadataQueryUpdateRemovedItemsKey (get-ffi-obj 'NSMetadataQueryUpdateRemovedItemsKey _fw-lib _id))
(define NSMetadataQueryUserHomeScope (get-ffi-obj 'NSMetadataQueryUserHomeScope _fw-lib _id))
(define NSMetadataUbiquitousItemContainerDisplayNameKey (get-ffi-obj 'NSMetadataUbiquitousItemContainerDisplayNameKey _fw-lib _id))
(define NSMetadataUbiquitousItemDownloadRequestedKey (get-ffi-obj 'NSMetadataUbiquitousItemDownloadRequestedKey _fw-lib _id))
(define NSMetadataUbiquitousItemDownloadingErrorKey (get-ffi-obj 'NSMetadataUbiquitousItemDownloadingErrorKey _fw-lib _id))
(define NSMetadataUbiquitousItemDownloadingStatusCurrent (get-ffi-obj 'NSMetadataUbiquitousItemDownloadingStatusCurrent _fw-lib _id))
(define NSMetadataUbiquitousItemDownloadingStatusDownloaded (get-ffi-obj 'NSMetadataUbiquitousItemDownloadingStatusDownloaded _fw-lib _id))
(define NSMetadataUbiquitousItemDownloadingStatusKey (get-ffi-obj 'NSMetadataUbiquitousItemDownloadingStatusKey _fw-lib _id))
(define NSMetadataUbiquitousItemDownloadingStatusNotDownloaded (get-ffi-obj 'NSMetadataUbiquitousItemDownloadingStatusNotDownloaded _fw-lib _id))
(define NSMetadataUbiquitousItemHasUnresolvedConflictsKey (get-ffi-obj 'NSMetadataUbiquitousItemHasUnresolvedConflictsKey _fw-lib _id))
(define NSMetadataUbiquitousItemIsDownloadedKey (get-ffi-obj 'NSMetadataUbiquitousItemIsDownloadedKey _fw-lib _id))
(define NSMetadataUbiquitousItemIsDownloadingKey (get-ffi-obj 'NSMetadataUbiquitousItemIsDownloadingKey _fw-lib _id))
(define NSMetadataUbiquitousItemIsExternalDocumentKey (get-ffi-obj 'NSMetadataUbiquitousItemIsExternalDocumentKey _fw-lib _id))
(define NSMetadataUbiquitousItemIsSharedKey (get-ffi-obj 'NSMetadataUbiquitousItemIsSharedKey _fw-lib _id))
(define NSMetadataUbiquitousItemIsUploadedKey (get-ffi-obj 'NSMetadataUbiquitousItemIsUploadedKey _fw-lib _id))
(define NSMetadataUbiquitousItemIsUploadingKey (get-ffi-obj 'NSMetadataUbiquitousItemIsUploadingKey _fw-lib _id))
(define NSMetadataUbiquitousItemPercentDownloadedKey (get-ffi-obj 'NSMetadataUbiquitousItemPercentDownloadedKey _fw-lib _id))
(define NSMetadataUbiquitousItemPercentUploadedKey (get-ffi-obj 'NSMetadataUbiquitousItemPercentUploadedKey _fw-lib _id))
(define NSMetadataUbiquitousItemURLInLocalContainerKey (get-ffi-obj 'NSMetadataUbiquitousItemURLInLocalContainerKey _fw-lib _id))
(define NSMetadataUbiquitousItemUploadingErrorKey (get-ffi-obj 'NSMetadataUbiquitousItemUploadingErrorKey _fw-lib _id))
(define NSMetadataUbiquitousSharedItemCurrentUserPermissionsKey (get-ffi-obj 'NSMetadataUbiquitousSharedItemCurrentUserPermissionsKey _fw-lib _id))
(define NSMetadataUbiquitousSharedItemCurrentUserRoleKey (get-ffi-obj 'NSMetadataUbiquitousSharedItemCurrentUserRoleKey _fw-lib _id))
(define NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKey (get-ffi-obj 'NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKey _fw-lib _id))
(define NSMetadataUbiquitousSharedItemOwnerNameComponentsKey (get-ffi-obj 'NSMetadataUbiquitousSharedItemOwnerNameComponentsKey _fw-lib _id))
(define NSMetadataUbiquitousSharedItemPermissionsReadOnly (get-ffi-obj 'NSMetadataUbiquitousSharedItemPermissionsReadOnly _fw-lib _id))
(define NSMetadataUbiquitousSharedItemPermissionsReadWrite (get-ffi-obj 'NSMetadataUbiquitousSharedItemPermissionsReadWrite _fw-lib _id))
(define NSMetadataUbiquitousSharedItemRoleOwner (get-ffi-obj 'NSMetadataUbiquitousSharedItemRoleOwner _fw-lib _id))
(define NSMetadataUbiquitousSharedItemRoleParticipant (get-ffi-obj 'NSMetadataUbiquitousSharedItemRoleParticipant _fw-lib _id))
(define NSMinimumKeyValueOperator (get-ffi-obj 'NSMinimumKeyValueOperator _fw-lib _id))
(define NSMonthNameArray (get-ffi-obj 'NSMonthNameArray _fw-lib _id))
(define NSMorphologyAttributeName (get-ffi-obj 'NSMorphologyAttributeName _fw-lib _id))
(define NSMultipleUnderlyingErrorsKey (get-ffi-obj 'NSMultipleUnderlyingErrorsKey _fw-lib _id))
(define NSNegateBooleanTransformerName (get-ffi-obj 'NSNegateBooleanTransformerName _fw-lib _id))
(define NSNegativeCurrencyFormatString (get-ffi-obj 'NSNegativeCurrencyFormatString _fw-lib _id))
(define NSNetServicesErrorCode (get-ffi-obj 'NSNetServicesErrorCode _fw-lib _id))
(define NSNetServicesErrorDomain (get-ffi-obj 'NSNetServicesErrorDomain _fw-lib _id))
(define NSNextDayDesignations (get-ffi-obj 'NSNextDayDesignations _fw-lib _id))
(define NSNextNextDayDesignations (get-ffi-obj 'NSNextNextDayDesignations _fw-lib _id))
(define NSNonOwnedPointerHashCallBacks (ffi-obj-ref 'NSNonOwnedPointerHashCallBacks _fw-lib))
(define NSNonOwnedPointerMapKeyCallBacks (ffi-obj-ref 'NSNonOwnedPointerMapKeyCallBacks _fw-lib))
(define NSNonOwnedPointerMapValueCallBacks (ffi-obj-ref 'NSNonOwnedPointerMapValueCallBacks _fw-lib))
(define NSNonOwnedPointerOrNullMapKeyCallBacks (ffi-obj-ref 'NSNonOwnedPointerOrNullMapKeyCallBacks _fw-lib))
(define NSNonRetainedObjectHashCallBacks (ffi-obj-ref 'NSNonRetainedObjectHashCallBacks _fw-lib))
(define NSNonRetainedObjectMapKeyCallBacks (ffi-obj-ref 'NSNonRetainedObjectMapKeyCallBacks _fw-lib))
(define NSNonRetainedObjectMapValueCallBacks (ffi-obj-ref 'NSNonRetainedObjectMapValueCallBacks _fw-lib))
(define NSOSStatusErrorDomain (get-ffi-obj 'NSOSStatusErrorDomain _fw-lib _id))
(define NSObjectHashCallBacks (ffi-obj-ref 'NSObjectHashCallBacks _fw-lib))
(define NSObjectInaccessibleException (get-ffi-obj 'NSObjectInaccessibleException _fw-lib _id))
(define NSObjectMapKeyCallBacks (ffi-obj-ref 'NSObjectMapKeyCallBacks _fw-lib))
(define NSObjectMapValueCallBacks (ffi-obj-ref 'NSObjectMapValueCallBacks _fw-lib))
(define NSObjectNotAvailableException (get-ffi-obj 'NSObjectNotAvailableException _fw-lib _id))
(define NSOldStyleException (get-ffi-obj 'NSOldStyleException _fw-lib _id))
(define NSOperationNotSupportedForKeyException (get-ffi-obj 'NSOperationNotSupportedForKeyException _fw-lib _id))
(define NSOwnedObjectIdentityHashCallBacks (ffi-obj-ref 'NSOwnedObjectIdentityHashCallBacks _fw-lib))
(define NSOwnedPointerHashCallBacks (ffi-obj-ref 'NSOwnedPointerHashCallBacks _fw-lib))
(define NSOwnedPointerMapKeyCallBacks (ffi-obj-ref 'NSOwnedPointerMapKeyCallBacks _fw-lib))
(define NSOwnedPointerMapValueCallBacks (ffi-obj-ref 'NSOwnedPointerMapValueCallBacks _fw-lib))
(define NSPOSIXErrorDomain (get-ffi-obj 'NSPOSIXErrorDomain _fw-lib _id))
(define NSParseErrorException (get-ffi-obj 'NSParseErrorException _fw-lib _id))
(define NSPersianCalendar (get-ffi-obj 'NSPersianCalendar _fw-lib _id))
(define NSPersonNameComponentDelimiter (get-ffi-obj 'NSPersonNameComponentDelimiter _fw-lib _id))
(define NSPersonNameComponentFamilyName (get-ffi-obj 'NSPersonNameComponentFamilyName _fw-lib _id))
(define NSPersonNameComponentGivenName (get-ffi-obj 'NSPersonNameComponentGivenName _fw-lib _id))
(define NSPersonNameComponentKey (get-ffi-obj 'NSPersonNameComponentKey _fw-lib _id))
(define NSPersonNameComponentMiddleName (get-ffi-obj 'NSPersonNameComponentMiddleName _fw-lib _id))
(define NSPersonNameComponentNickname (get-ffi-obj 'NSPersonNameComponentNickname _fw-lib _id))
(define NSPersonNameComponentPrefix (get-ffi-obj 'NSPersonNameComponentPrefix _fw-lib _id))
(define NSPersonNameComponentSuffix (get-ffi-obj 'NSPersonNameComponentSuffix _fw-lib _id))
(define NSPointerToStructHashCallBacks (ffi-obj-ref 'NSPointerToStructHashCallBacks _fw-lib))
(define NSPortDidBecomeInvalidNotification (get-ffi-obj 'NSPortDidBecomeInvalidNotification _fw-lib _id))
(define NSPortReceiveException (get-ffi-obj 'NSPortReceiveException _fw-lib _id))
(define NSPortSendException (get-ffi-obj 'NSPortSendException _fw-lib _id))
(define NSPortTimeoutException (get-ffi-obj 'NSPortTimeoutException _fw-lib _id))
(define NSPositiveCurrencyFormatString (get-ffi-obj 'NSPositiveCurrencyFormatString _fw-lib _id))
(define NSPresentationIntentAttributeName (get-ffi-obj 'NSPresentationIntentAttributeName _fw-lib _id))
(define NSPriorDayDesignations (get-ffi-obj 'NSPriorDayDesignations _fw-lib _id))
(define NSProcessInfoPowerStateDidChangeNotification (get-ffi-obj 'NSProcessInfoPowerStateDidChangeNotification _fw-lib _id))
(define NSProcessInfoThermalStateDidChangeNotification (get-ffi-obj 'NSProcessInfoThermalStateDidChangeNotification _fw-lib _id))
(define NSProgressEstimatedTimeRemainingKey (get-ffi-obj 'NSProgressEstimatedTimeRemainingKey _fw-lib _id))
(define NSProgressFileAnimationImageKey (get-ffi-obj 'NSProgressFileAnimationImageKey _fw-lib _id))
(define NSProgressFileAnimationImageOriginalRectKey (get-ffi-obj 'NSProgressFileAnimationImageOriginalRectKey _fw-lib _id))
(define NSProgressFileCompletedCountKey (get-ffi-obj 'NSProgressFileCompletedCountKey _fw-lib _id))
(define NSProgressFileIconKey (get-ffi-obj 'NSProgressFileIconKey _fw-lib _id))
(define NSProgressFileOperationKindCopying (get-ffi-obj 'NSProgressFileOperationKindCopying _fw-lib _id))
(define NSProgressFileOperationKindDecompressingAfterDownloading (get-ffi-obj 'NSProgressFileOperationKindDecompressingAfterDownloading _fw-lib _id))
(define NSProgressFileOperationKindDownloading (get-ffi-obj 'NSProgressFileOperationKindDownloading _fw-lib _id))
(define NSProgressFileOperationKindDuplicating (get-ffi-obj 'NSProgressFileOperationKindDuplicating _fw-lib _id))
(define NSProgressFileOperationKindKey (get-ffi-obj 'NSProgressFileOperationKindKey _fw-lib _id))
(define NSProgressFileOperationKindReceiving (get-ffi-obj 'NSProgressFileOperationKindReceiving _fw-lib _id))
(define NSProgressFileOperationKindUploading (get-ffi-obj 'NSProgressFileOperationKindUploading _fw-lib _id))
(define NSProgressFileTotalCountKey (get-ffi-obj 'NSProgressFileTotalCountKey _fw-lib _id))
(define NSProgressFileURLKey (get-ffi-obj 'NSProgressFileURLKey _fw-lib _id))
(define NSProgressKindFile (get-ffi-obj 'NSProgressKindFile _fw-lib _id))
(define NSProgressThroughputKey (get-ffi-obj 'NSProgressThroughputKey _fw-lib _id))
(define NSRangeException (get-ffi-obj 'NSRangeException _fw-lib _id))
(define NSRecoveryAttempterErrorKey (get-ffi-obj 'NSRecoveryAttempterErrorKey _fw-lib _id))
(define NSRegistrationDomain (get-ffi-obj 'NSRegistrationDomain _fw-lib _id))
(define NSReplacementIndexAttributeName (get-ffi-obj 'NSReplacementIndexAttributeName _fw-lib _id))
(define NSRepublicOfChinaCalendar (get-ffi-obj 'NSRepublicOfChinaCalendar _fw-lib _id))
(define NSRunLoopCommonModes (get-ffi-obj 'NSRunLoopCommonModes _fw-lib _id))
(define NSSecureUnarchiveFromDataTransformerName (get-ffi-obj 'NSSecureUnarchiveFromDataTransformerName _fw-lib _id))
(define NSShortDateFormatString (get-ffi-obj 'NSShortDateFormatString _fw-lib _id))
(define NSShortMonthNameArray (get-ffi-obj 'NSShortMonthNameArray _fw-lib _id))
(define NSShortTimeDateFormatString (get-ffi-obj 'NSShortTimeDateFormatString _fw-lib _id))
(define NSShortWeekDayNameArray (get-ffi-obj 'NSShortWeekDayNameArray _fw-lib _id))
(define NSStreamDataWrittenToMemoryStreamKey (get-ffi-obj 'NSStreamDataWrittenToMemoryStreamKey _fw-lib _id))
(define NSStreamFileCurrentOffsetKey (get-ffi-obj 'NSStreamFileCurrentOffsetKey _fw-lib _id))
(define NSStreamNetworkServiceType (get-ffi-obj 'NSStreamNetworkServiceType _fw-lib _id))
(define NSStreamNetworkServiceTypeBackground (get-ffi-obj 'NSStreamNetworkServiceTypeBackground _fw-lib _id))
(define NSStreamNetworkServiceTypeCallSignaling (get-ffi-obj 'NSStreamNetworkServiceTypeCallSignaling _fw-lib _id))
(define NSStreamNetworkServiceTypeVideo (get-ffi-obj 'NSStreamNetworkServiceTypeVideo _fw-lib _id))
(define NSStreamNetworkServiceTypeVoIP (get-ffi-obj 'NSStreamNetworkServiceTypeVoIP _fw-lib _id))
(define NSStreamNetworkServiceTypeVoice (get-ffi-obj 'NSStreamNetworkServiceTypeVoice _fw-lib _id))
(define NSStreamSOCKSErrorDomain (get-ffi-obj 'NSStreamSOCKSErrorDomain _fw-lib _id))
(define NSStreamSOCKSProxyConfigurationKey (get-ffi-obj 'NSStreamSOCKSProxyConfigurationKey _fw-lib _id))
(define NSStreamSOCKSProxyHostKey (get-ffi-obj 'NSStreamSOCKSProxyHostKey _fw-lib _id))
(define NSStreamSOCKSProxyPasswordKey (get-ffi-obj 'NSStreamSOCKSProxyPasswordKey _fw-lib _id))
(define NSStreamSOCKSProxyPortKey (get-ffi-obj 'NSStreamSOCKSProxyPortKey _fw-lib _id))
(define NSStreamSOCKSProxyUserKey (get-ffi-obj 'NSStreamSOCKSProxyUserKey _fw-lib _id))
(define NSStreamSOCKSProxyVersion4 (get-ffi-obj 'NSStreamSOCKSProxyVersion4 _fw-lib _id))
(define NSStreamSOCKSProxyVersion5 (get-ffi-obj 'NSStreamSOCKSProxyVersion5 _fw-lib _id))
(define NSStreamSOCKSProxyVersionKey (get-ffi-obj 'NSStreamSOCKSProxyVersionKey _fw-lib _id))
(define NSStreamSocketSSLErrorDomain (get-ffi-obj 'NSStreamSocketSSLErrorDomain _fw-lib _id))
(define NSStreamSocketSecurityLevelKey (get-ffi-obj 'NSStreamSocketSecurityLevelKey _fw-lib _id))
(define NSStreamSocketSecurityLevelNegotiatedSSL (get-ffi-obj 'NSStreamSocketSecurityLevelNegotiatedSSL _fw-lib _id))
(define NSStreamSocketSecurityLevelNone (get-ffi-obj 'NSStreamSocketSecurityLevelNone _fw-lib _id))
(define NSStreamSocketSecurityLevelSSLv2 (get-ffi-obj 'NSStreamSocketSecurityLevelSSLv2 _fw-lib _id))
(define NSStreamSocketSecurityLevelSSLv3 (get-ffi-obj 'NSStreamSocketSecurityLevelSSLv3 _fw-lib _id))
(define NSStreamSocketSecurityLevelTLSv1 (get-ffi-obj 'NSStreamSocketSecurityLevelTLSv1 _fw-lib _id))
(define NSStringEncodingDetectionAllowLossyKey (get-ffi-obj 'NSStringEncodingDetectionAllowLossyKey _fw-lib _id))
(define NSStringEncodingDetectionDisallowedEncodingsKey (get-ffi-obj 'NSStringEncodingDetectionDisallowedEncodingsKey _fw-lib _id))
(define NSStringEncodingDetectionFromWindowsKey (get-ffi-obj 'NSStringEncodingDetectionFromWindowsKey _fw-lib _id))
(define NSStringEncodingDetectionLikelyLanguageKey (get-ffi-obj 'NSStringEncodingDetectionLikelyLanguageKey _fw-lib _id))
(define NSStringEncodingDetectionLossySubstitutionKey (get-ffi-obj 'NSStringEncodingDetectionLossySubstitutionKey _fw-lib _id))
(define NSStringEncodingDetectionSuggestedEncodingsKey (get-ffi-obj 'NSStringEncodingDetectionSuggestedEncodingsKey _fw-lib _id))
(define NSStringEncodingDetectionUseOnlySuggestedEncodingsKey (get-ffi-obj 'NSStringEncodingDetectionUseOnlySuggestedEncodingsKey _fw-lib _id))
(define NSStringEncodingErrorKey (get-ffi-obj 'NSStringEncodingErrorKey _fw-lib _id))
(define NSStringTransformFullwidthToHalfwidth (get-ffi-obj 'NSStringTransformFullwidthToHalfwidth _fw-lib _id))
(define NSStringTransformHiraganaToKatakana (get-ffi-obj 'NSStringTransformHiraganaToKatakana _fw-lib _id))
(define NSStringTransformLatinToArabic (get-ffi-obj 'NSStringTransformLatinToArabic _fw-lib _id))
(define NSStringTransformLatinToCyrillic (get-ffi-obj 'NSStringTransformLatinToCyrillic _fw-lib _id))
(define NSStringTransformLatinToGreek (get-ffi-obj 'NSStringTransformLatinToGreek _fw-lib _id))
(define NSStringTransformLatinToHangul (get-ffi-obj 'NSStringTransformLatinToHangul _fw-lib _id))
(define NSStringTransformLatinToHebrew (get-ffi-obj 'NSStringTransformLatinToHebrew _fw-lib _id))
(define NSStringTransformLatinToHiragana (get-ffi-obj 'NSStringTransformLatinToHiragana _fw-lib _id))
(define NSStringTransformLatinToKatakana (get-ffi-obj 'NSStringTransformLatinToKatakana _fw-lib _id))
(define NSStringTransformLatinToThai (get-ffi-obj 'NSStringTransformLatinToThai _fw-lib _id))
(define NSStringTransformMandarinToLatin (get-ffi-obj 'NSStringTransformMandarinToLatin _fw-lib _id))
(define NSStringTransformStripCombiningMarks (get-ffi-obj 'NSStringTransformStripCombiningMarks _fw-lib _id))
(define NSStringTransformStripDiacritics (get-ffi-obj 'NSStringTransformStripDiacritics _fw-lib _id))
(define NSStringTransformToLatin (get-ffi-obj 'NSStringTransformToLatin _fw-lib _id))
(define NSStringTransformToUnicodeName (get-ffi-obj 'NSStringTransformToUnicodeName _fw-lib _id))
(define NSStringTransformToXMLHex (get-ffi-obj 'NSStringTransformToXMLHex _fw-lib _id))
(define NSSumKeyValueOperator (get-ffi-obj 'NSSumKeyValueOperator _fw-lib _id))
(define NSSystemClockDidChangeNotification (get-ffi-obj 'NSSystemClockDidChangeNotification _fw-lib _id))
(define NSSystemTimeZoneDidChangeNotification (get-ffi-obj 'NSSystemTimeZoneDidChangeNotification _fw-lib _id))
(define NSTaskDidTerminateNotification (get-ffi-obj 'NSTaskDidTerminateNotification _fw-lib _id))
(define NSTextCheckingAirlineKey (get-ffi-obj 'NSTextCheckingAirlineKey _fw-lib _id))
(define NSTextCheckingCityKey (get-ffi-obj 'NSTextCheckingCityKey _fw-lib _id))
(define NSTextCheckingCountryKey (get-ffi-obj 'NSTextCheckingCountryKey _fw-lib _id))
(define NSTextCheckingFlightKey (get-ffi-obj 'NSTextCheckingFlightKey _fw-lib _id))
(define NSTextCheckingJobTitleKey (get-ffi-obj 'NSTextCheckingJobTitleKey _fw-lib _id))
(define NSTextCheckingNameKey (get-ffi-obj 'NSTextCheckingNameKey _fw-lib _id))
(define NSTextCheckingOrganizationKey (get-ffi-obj 'NSTextCheckingOrganizationKey _fw-lib _id))
(define NSTextCheckingPhoneKey (get-ffi-obj 'NSTextCheckingPhoneKey _fw-lib _id))
(define NSTextCheckingStateKey (get-ffi-obj 'NSTextCheckingStateKey _fw-lib _id))
(define NSTextCheckingStreetKey (get-ffi-obj 'NSTextCheckingStreetKey _fw-lib _id))
(define NSTextCheckingZIPKey (get-ffi-obj 'NSTextCheckingZIPKey _fw-lib _id))
(define NSThisDayDesignations (get-ffi-obj 'NSThisDayDesignations _fw-lib _id))
(define NSThousandsSeparator (get-ffi-obj 'NSThousandsSeparator _fw-lib _id))
(define NSThreadWillExitNotification (get-ffi-obj 'NSThreadWillExitNotification _fw-lib _id))
(define NSThumbnail1024x1024SizeKey (get-ffi-obj 'NSThumbnail1024x1024SizeKey _fw-lib _id))
(define NSTimeDateFormatString (get-ffi-obj 'NSTimeDateFormatString _fw-lib _id))
(define NSTimeFormatString (get-ffi-obj 'NSTimeFormatString _fw-lib _id))
(define NSURLAddedToDirectoryDateKey (get-ffi-obj 'NSURLAddedToDirectoryDateKey _fw-lib _id))
(define NSURLApplicationIsScriptableKey (get-ffi-obj 'NSURLApplicationIsScriptableKey _fw-lib _id))
(define NSURLAttributeModificationDateKey (get-ffi-obj 'NSURLAttributeModificationDateKey _fw-lib _id))
(define NSURLAuthenticationMethodClientCertificate (get-ffi-obj 'NSURLAuthenticationMethodClientCertificate _fw-lib _id))
(define NSURLAuthenticationMethodDefault (get-ffi-obj 'NSURLAuthenticationMethodDefault _fw-lib _id))
(define NSURLAuthenticationMethodHTMLForm (get-ffi-obj 'NSURLAuthenticationMethodHTMLForm _fw-lib _id))
(define NSURLAuthenticationMethodHTTPBasic (get-ffi-obj 'NSURLAuthenticationMethodHTTPBasic _fw-lib _id))
(define NSURLAuthenticationMethodHTTPDigest (get-ffi-obj 'NSURLAuthenticationMethodHTTPDigest _fw-lib _id))
(define NSURLAuthenticationMethodNTLM (get-ffi-obj 'NSURLAuthenticationMethodNTLM _fw-lib _id))
(define NSURLAuthenticationMethodNegotiate (get-ffi-obj 'NSURLAuthenticationMethodNegotiate _fw-lib _id))
(define NSURLAuthenticationMethodServerTrust (get-ffi-obj 'NSURLAuthenticationMethodServerTrust _fw-lib _id))
(define NSURLCanonicalPathKey (get-ffi-obj 'NSURLCanonicalPathKey _fw-lib _id))
(define NSURLContentAccessDateKey (get-ffi-obj 'NSURLContentAccessDateKey _fw-lib _id))
(define NSURLContentModificationDateKey (get-ffi-obj 'NSURLContentModificationDateKey _fw-lib _id))
(define NSURLContentTypeKey (get-ffi-obj 'NSURLContentTypeKey _fw-lib _id))
(define NSURLCreationDateKey (get-ffi-obj 'NSURLCreationDateKey _fw-lib _id))
(define NSURLCredentialStorageChangedNotification (get-ffi-obj 'NSURLCredentialStorageChangedNotification _fw-lib _id))
(define NSURLCredentialStorageRemoveSynchronizableCredentials (get-ffi-obj 'NSURLCredentialStorageRemoveSynchronizableCredentials _fw-lib _id))
(define NSURLCustomIconKey (get-ffi-obj 'NSURLCustomIconKey _fw-lib _id))
(define NSURLDirectoryEntryCountKey (get-ffi-obj 'NSURLDirectoryEntryCountKey _fw-lib _id))
(define NSURLDocumentIdentifierKey (get-ffi-obj 'NSURLDocumentIdentifierKey _fw-lib _id))
(define NSURLEffectiveIconKey (get-ffi-obj 'NSURLEffectiveIconKey _fw-lib _id))
(define NSURLErrorBackgroundTaskCancelledReasonKey (get-ffi-obj 'NSURLErrorBackgroundTaskCancelledReasonKey _fw-lib _id))
(define NSURLErrorDomain (get-ffi-obj 'NSURLErrorDomain _fw-lib _id))
(define NSURLErrorFailingURLErrorKey (get-ffi-obj 'NSURLErrorFailingURLErrorKey _fw-lib _id))
(define NSURLErrorFailingURLPeerTrustErrorKey (get-ffi-obj 'NSURLErrorFailingURLPeerTrustErrorKey _fw-lib _id))
(define NSURLErrorFailingURLStringErrorKey (get-ffi-obj 'NSURLErrorFailingURLStringErrorKey _fw-lib _id))
(define NSURLErrorKey (get-ffi-obj 'NSURLErrorKey _fw-lib _id))
(define NSURLErrorNetworkUnavailableReasonKey (get-ffi-obj 'NSURLErrorNetworkUnavailableReasonKey _fw-lib _id))
(define NSURLFileAllocatedSizeKey (get-ffi-obj 'NSURLFileAllocatedSizeKey _fw-lib _id))
(define NSURLFileContentIdentifierKey (get-ffi-obj 'NSURLFileContentIdentifierKey _fw-lib _id))
(define NSURLFileIdentifierKey (get-ffi-obj 'NSURLFileIdentifierKey _fw-lib _id))
(define NSURLFileProtectionComplete (get-ffi-obj 'NSURLFileProtectionComplete _fw-lib _id))
(define NSURLFileProtectionCompleteUnlessOpen (get-ffi-obj 'NSURLFileProtectionCompleteUnlessOpen _fw-lib _id))
(define NSURLFileProtectionCompleteUntilFirstUserAuthentication (get-ffi-obj 'NSURLFileProtectionCompleteUntilFirstUserAuthentication _fw-lib _id))
(define NSURLFileProtectionKey (get-ffi-obj 'NSURLFileProtectionKey _fw-lib _id))
(define NSURLFileProtectionNone (get-ffi-obj 'NSURLFileProtectionNone _fw-lib _id))
(define NSURLFileResourceIdentifierKey (get-ffi-obj 'NSURLFileResourceIdentifierKey _fw-lib _id))
(define NSURLFileResourceTypeBlockSpecial (get-ffi-obj 'NSURLFileResourceTypeBlockSpecial _fw-lib _id))
(define NSURLFileResourceTypeCharacterSpecial (get-ffi-obj 'NSURLFileResourceTypeCharacterSpecial _fw-lib _id))
(define NSURLFileResourceTypeDirectory (get-ffi-obj 'NSURLFileResourceTypeDirectory _fw-lib _id))
(define NSURLFileResourceTypeKey (get-ffi-obj 'NSURLFileResourceTypeKey _fw-lib _id))
(define NSURLFileResourceTypeNamedPipe (get-ffi-obj 'NSURLFileResourceTypeNamedPipe _fw-lib _id))
(define NSURLFileResourceTypeRegular (get-ffi-obj 'NSURLFileResourceTypeRegular _fw-lib _id))
(define NSURLFileResourceTypeSocket (get-ffi-obj 'NSURLFileResourceTypeSocket _fw-lib _id))
(define NSURLFileResourceTypeSymbolicLink (get-ffi-obj 'NSURLFileResourceTypeSymbolicLink _fw-lib _id))
(define NSURLFileResourceTypeUnknown (get-ffi-obj 'NSURLFileResourceTypeUnknown _fw-lib _id))
(define NSURLFileScheme (get-ffi-obj 'NSURLFileScheme _fw-lib _id))
(define NSURLFileSecurityKey (get-ffi-obj 'NSURLFileSecurityKey _fw-lib _id))
(define NSURLFileSizeKey (get-ffi-obj 'NSURLFileSizeKey _fw-lib _id))
(define NSURLGenerationIdentifierKey (get-ffi-obj 'NSURLGenerationIdentifierKey _fw-lib _id))
(define NSURLHasHiddenExtensionKey (get-ffi-obj 'NSURLHasHiddenExtensionKey _fw-lib _id))
(define NSURLIsAliasFileKey (get-ffi-obj 'NSURLIsAliasFileKey _fw-lib _id))
(define NSURLIsApplicationKey (get-ffi-obj 'NSURLIsApplicationKey _fw-lib _id))
(define NSURLIsDirectoryKey (get-ffi-obj 'NSURLIsDirectoryKey _fw-lib _id))
(define NSURLIsExcludedFromBackupKey (get-ffi-obj 'NSURLIsExcludedFromBackupKey _fw-lib _id))
(define NSURLIsExecutableKey (get-ffi-obj 'NSURLIsExecutableKey _fw-lib _id))
(define NSURLIsHiddenKey (get-ffi-obj 'NSURLIsHiddenKey _fw-lib _id))
(define NSURLIsMountTriggerKey (get-ffi-obj 'NSURLIsMountTriggerKey _fw-lib _id))
(define NSURLIsPackageKey (get-ffi-obj 'NSURLIsPackageKey _fw-lib _id))
(define NSURLIsPurgeableKey (get-ffi-obj 'NSURLIsPurgeableKey _fw-lib _id))
(define NSURLIsReadableKey (get-ffi-obj 'NSURLIsReadableKey _fw-lib _id))
(define NSURLIsRegularFileKey (get-ffi-obj 'NSURLIsRegularFileKey _fw-lib _id))
(define NSURLIsSparseKey (get-ffi-obj 'NSURLIsSparseKey _fw-lib _id))
(define NSURLIsSymbolicLinkKey (get-ffi-obj 'NSURLIsSymbolicLinkKey _fw-lib _id))
(define NSURLIsSystemImmutableKey (get-ffi-obj 'NSURLIsSystemImmutableKey _fw-lib _id))
(define NSURLIsUbiquitousItemKey (get-ffi-obj 'NSURLIsUbiquitousItemKey _fw-lib _id))
(define NSURLIsUserImmutableKey (get-ffi-obj 'NSURLIsUserImmutableKey _fw-lib _id))
(define NSURLIsVolumeKey (get-ffi-obj 'NSURLIsVolumeKey _fw-lib _id))
(define NSURLIsWritableKey (get-ffi-obj 'NSURLIsWritableKey _fw-lib _id))
(define NSURLKeysOfUnsetValuesKey (get-ffi-obj 'NSURLKeysOfUnsetValuesKey _fw-lib _id))
(define NSURLLabelColorKey (get-ffi-obj 'NSURLLabelColorKey _fw-lib _id))
(define NSURLLabelNumberKey (get-ffi-obj 'NSURLLabelNumberKey _fw-lib _id))
(define NSURLLinkCountKey (get-ffi-obj 'NSURLLinkCountKey _fw-lib _id))
(define NSURLLocalizedLabelKey (get-ffi-obj 'NSURLLocalizedLabelKey _fw-lib _id))
(define NSURLLocalizedNameKey (get-ffi-obj 'NSURLLocalizedNameKey _fw-lib _id))
(define NSURLLocalizedTypeDescriptionKey (get-ffi-obj 'NSURLLocalizedTypeDescriptionKey _fw-lib _id))
(define NSURLMayHaveExtendedAttributesKey (get-ffi-obj 'NSURLMayHaveExtendedAttributesKey _fw-lib _id))
(define NSURLMayShareFileContentKey (get-ffi-obj 'NSURLMayShareFileContentKey _fw-lib _id))
(define NSURLNameKey (get-ffi-obj 'NSURLNameKey _fw-lib _id))
(define NSURLParentDirectoryURLKey (get-ffi-obj 'NSURLParentDirectoryURLKey _fw-lib _id))
(define NSURLPathKey (get-ffi-obj 'NSURLPathKey _fw-lib _id))
(define NSURLPreferredIOBlockSizeKey (get-ffi-obj 'NSURLPreferredIOBlockSizeKey _fw-lib _id))
(define NSURLProtectionSpaceFTP (get-ffi-obj 'NSURLProtectionSpaceFTP _fw-lib _id))
(define NSURLProtectionSpaceFTPProxy (get-ffi-obj 'NSURLProtectionSpaceFTPProxy _fw-lib _id))
(define NSURLProtectionSpaceHTTP (get-ffi-obj 'NSURLProtectionSpaceHTTP _fw-lib _id))
(define NSURLProtectionSpaceHTTPProxy (get-ffi-obj 'NSURLProtectionSpaceHTTPProxy _fw-lib _id))
(define NSURLProtectionSpaceHTTPS (get-ffi-obj 'NSURLProtectionSpaceHTTPS _fw-lib _id))
(define NSURLProtectionSpaceHTTPSProxy (get-ffi-obj 'NSURLProtectionSpaceHTTPSProxy _fw-lib _id))
(define NSURLProtectionSpaceSOCKSProxy (get-ffi-obj 'NSURLProtectionSpaceSOCKSProxy _fw-lib _id))
(define NSURLQuarantinePropertiesKey (get-ffi-obj 'NSURLQuarantinePropertiesKey _fw-lib _id))
(define NSURLSessionDownloadTaskResumeData (get-ffi-obj 'NSURLSessionDownloadTaskResumeData _fw-lib _id))
(define NSURLSessionTaskPriorityDefault (get-ffi-obj 'NSURLSessionTaskPriorityDefault _fw-lib _float))
(define NSURLSessionTaskPriorityHigh (get-ffi-obj 'NSURLSessionTaskPriorityHigh _fw-lib _float))
(define NSURLSessionTaskPriorityLow (get-ffi-obj 'NSURLSessionTaskPriorityLow _fw-lib _float))
(define NSURLSessionTransferSizeUnknown (get-ffi-obj 'NSURLSessionTransferSizeUnknown _fw-lib _int64))
(define NSURLSessionUploadTaskResumeData (get-ffi-obj 'NSURLSessionUploadTaskResumeData _fw-lib _id))
(define NSURLTagNamesKey (get-ffi-obj 'NSURLTagNamesKey _fw-lib _id))
(define NSURLThumbnailDictionaryKey (get-ffi-obj 'NSURLThumbnailDictionaryKey _fw-lib _id))
(define NSURLThumbnailKey (get-ffi-obj 'NSURLThumbnailKey _fw-lib _id))
(define NSURLTotalFileAllocatedSizeKey (get-ffi-obj 'NSURLTotalFileAllocatedSizeKey _fw-lib _id))
(define NSURLTotalFileSizeKey (get-ffi-obj 'NSURLTotalFileSizeKey _fw-lib _id))
(define NSURLTypeIdentifierKey (get-ffi-obj 'NSURLTypeIdentifierKey _fw-lib _id))
(define NSURLUbiquitousItemContainerDisplayNameKey (get-ffi-obj 'NSURLUbiquitousItemContainerDisplayNameKey _fw-lib _id))
(define NSURLUbiquitousItemDownloadRequestedKey (get-ffi-obj 'NSURLUbiquitousItemDownloadRequestedKey _fw-lib _id))
(define NSURLUbiquitousItemDownloadingErrorKey (get-ffi-obj 'NSURLUbiquitousItemDownloadingErrorKey _fw-lib _id))
(define NSURLUbiquitousItemDownloadingStatusCurrent (get-ffi-obj 'NSURLUbiquitousItemDownloadingStatusCurrent _fw-lib _id))
(define NSURLUbiquitousItemDownloadingStatusDownloaded (get-ffi-obj 'NSURLUbiquitousItemDownloadingStatusDownloaded _fw-lib _id))
(define NSURLUbiquitousItemDownloadingStatusKey (get-ffi-obj 'NSURLUbiquitousItemDownloadingStatusKey _fw-lib _id))
(define NSURLUbiquitousItemDownloadingStatusNotDownloaded (get-ffi-obj 'NSURLUbiquitousItemDownloadingStatusNotDownloaded _fw-lib _id))
(define NSURLUbiquitousItemHasUnresolvedConflictsKey (get-ffi-obj 'NSURLUbiquitousItemHasUnresolvedConflictsKey _fw-lib _id))
(define NSURLUbiquitousItemIsDownloadedKey (get-ffi-obj 'NSURLUbiquitousItemIsDownloadedKey _fw-lib _id))
(define NSURLUbiquitousItemIsDownloadingKey (get-ffi-obj 'NSURLUbiquitousItemIsDownloadingKey _fw-lib _id))
(define NSURLUbiquitousItemIsExcludedFromSyncKey (get-ffi-obj 'NSURLUbiquitousItemIsExcludedFromSyncKey _fw-lib _id))
(define NSURLUbiquitousItemIsSharedKey (get-ffi-obj 'NSURLUbiquitousItemIsSharedKey _fw-lib _id))
(define NSURLUbiquitousItemIsSyncPausedKey (get-ffi-obj 'NSURLUbiquitousItemIsSyncPausedKey _fw-lib _id))
(define NSURLUbiquitousItemIsUploadedKey (get-ffi-obj 'NSURLUbiquitousItemIsUploadedKey _fw-lib _id))
(define NSURLUbiquitousItemIsUploadingKey (get-ffi-obj 'NSURLUbiquitousItemIsUploadingKey _fw-lib _id))
(define NSURLUbiquitousItemPercentDownloadedKey (get-ffi-obj 'NSURLUbiquitousItemPercentDownloadedKey _fw-lib _id))
(define NSURLUbiquitousItemPercentUploadedKey (get-ffi-obj 'NSURLUbiquitousItemPercentUploadedKey _fw-lib _id))
(define NSURLUbiquitousItemSupportedSyncControlsKey (get-ffi-obj 'NSURLUbiquitousItemSupportedSyncControlsKey _fw-lib _id))
(define NSURLUbiquitousItemUploadingErrorKey (get-ffi-obj 'NSURLUbiquitousItemUploadingErrorKey _fw-lib _id))
(define NSURLUbiquitousSharedItemCurrentUserPermissionsKey (get-ffi-obj 'NSURLUbiquitousSharedItemCurrentUserPermissionsKey _fw-lib _id))
(define NSURLUbiquitousSharedItemCurrentUserRoleKey (get-ffi-obj 'NSURLUbiquitousSharedItemCurrentUserRoleKey _fw-lib _id))
(define NSURLUbiquitousSharedItemMostRecentEditorNameComponentsKey (get-ffi-obj 'NSURLUbiquitousSharedItemMostRecentEditorNameComponentsKey _fw-lib _id))
(define NSURLUbiquitousSharedItemOwnerNameComponentsKey (get-ffi-obj 'NSURLUbiquitousSharedItemOwnerNameComponentsKey _fw-lib _id))
(define NSURLUbiquitousSharedItemPermissionsReadOnly (get-ffi-obj 'NSURLUbiquitousSharedItemPermissionsReadOnly _fw-lib _id))
(define NSURLUbiquitousSharedItemPermissionsReadWrite (get-ffi-obj 'NSURLUbiquitousSharedItemPermissionsReadWrite _fw-lib _id))
(define NSURLUbiquitousSharedItemRoleOwner (get-ffi-obj 'NSURLUbiquitousSharedItemRoleOwner _fw-lib _id))
(define NSURLUbiquitousSharedItemRoleParticipant (get-ffi-obj 'NSURLUbiquitousSharedItemRoleParticipant _fw-lib _id))
(define NSURLVolumeAvailableCapacityForImportantUsageKey (get-ffi-obj 'NSURLVolumeAvailableCapacityForImportantUsageKey _fw-lib _id))
(define NSURLVolumeAvailableCapacityForOpportunisticUsageKey (get-ffi-obj 'NSURLVolumeAvailableCapacityForOpportunisticUsageKey _fw-lib _id))
(define NSURLVolumeAvailableCapacityKey (get-ffi-obj 'NSURLVolumeAvailableCapacityKey _fw-lib _id))
(define NSURLVolumeCreationDateKey (get-ffi-obj 'NSURLVolumeCreationDateKey _fw-lib _id))
(define NSURLVolumeIdentifierKey (get-ffi-obj 'NSURLVolumeIdentifierKey _fw-lib _id))
(define NSURLVolumeIsAutomountedKey (get-ffi-obj 'NSURLVolumeIsAutomountedKey _fw-lib _id))
(define NSURLVolumeIsBrowsableKey (get-ffi-obj 'NSURLVolumeIsBrowsableKey _fw-lib _id))
(define NSURLVolumeIsEjectableKey (get-ffi-obj 'NSURLVolumeIsEjectableKey _fw-lib _id))
(define NSURLVolumeIsEncryptedKey (get-ffi-obj 'NSURLVolumeIsEncryptedKey _fw-lib _id))
(define NSURLVolumeIsInternalKey (get-ffi-obj 'NSURLVolumeIsInternalKey _fw-lib _id))
(define NSURLVolumeIsJournalingKey (get-ffi-obj 'NSURLVolumeIsJournalingKey _fw-lib _id))
(define NSURLVolumeIsLocalKey (get-ffi-obj 'NSURLVolumeIsLocalKey _fw-lib _id))
(define NSURLVolumeIsReadOnlyKey (get-ffi-obj 'NSURLVolumeIsReadOnlyKey _fw-lib _id))
(define NSURLVolumeIsRemovableKey (get-ffi-obj 'NSURLVolumeIsRemovableKey _fw-lib _id))
(define NSURLVolumeIsRootFileSystemKey (get-ffi-obj 'NSURLVolumeIsRootFileSystemKey _fw-lib _id))
(define NSURLVolumeLocalizedFormatDescriptionKey (get-ffi-obj 'NSURLVolumeLocalizedFormatDescriptionKey _fw-lib _id))
(define NSURLVolumeLocalizedNameKey (get-ffi-obj 'NSURLVolumeLocalizedNameKey _fw-lib _id))
(define NSURLVolumeMaximumFileSizeKey (get-ffi-obj 'NSURLVolumeMaximumFileSizeKey _fw-lib _id))
(define NSURLVolumeMountFromLocationKey (get-ffi-obj 'NSURLVolumeMountFromLocationKey _fw-lib _id))
(define NSURLVolumeNameKey (get-ffi-obj 'NSURLVolumeNameKey _fw-lib _id))
(define NSURLVolumeResourceCountKey (get-ffi-obj 'NSURLVolumeResourceCountKey _fw-lib _id))
(define NSURLVolumeSubtypeKey (get-ffi-obj 'NSURLVolumeSubtypeKey _fw-lib _id))
(define NSURLVolumeSupportsAccessPermissionsKey (get-ffi-obj 'NSURLVolumeSupportsAccessPermissionsKey _fw-lib _id))
(define NSURLVolumeSupportsAdvisoryFileLockingKey (get-ffi-obj 'NSURLVolumeSupportsAdvisoryFileLockingKey _fw-lib _id))
(define NSURLVolumeSupportsCasePreservedNamesKey (get-ffi-obj 'NSURLVolumeSupportsCasePreservedNamesKey _fw-lib _id))
(define NSURLVolumeSupportsCaseSensitiveNamesKey (get-ffi-obj 'NSURLVolumeSupportsCaseSensitiveNamesKey _fw-lib _id))
(define NSURLVolumeSupportsCompressionKey (get-ffi-obj 'NSURLVolumeSupportsCompressionKey _fw-lib _id))
(define NSURLVolumeSupportsExclusiveRenamingKey (get-ffi-obj 'NSURLVolumeSupportsExclusiveRenamingKey _fw-lib _id))
(define NSURLVolumeSupportsExtendedSecurityKey (get-ffi-obj 'NSURLVolumeSupportsExtendedSecurityKey _fw-lib _id))
(define NSURLVolumeSupportsFileCloningKey (get-ffi-obj 'NSURLVolumeSupportsFileCloningKey _fw-lib _id))
(define NSURLVolumeSupportsFileProtectionKey (get-ffi-obj 'NSURLVolumeSupportsFileProtectionKey _fw-lib _id))
(define NSURLVolumeSupportsHardLinksKey (get-ffi-obj 'NSURLVolumeSupportsHardLinksKey _fw-lib _id))
(define NSURLVolumeSupportsImmutableFilesKey (get-ffi-obj 'NSURLVolumeSupportsImmutableFilesKey _fw-lib _id))
(define NSURLVolumeSupportsJournalingKey (get-ffi-obj 'NSURLVolumeSupportsJournalingKey _fw-lib _id))
(define NSURLVolumeSupportsPersistentIDsKey (get-ffi-obj 'NSURLVolumeSupportsPersistentIDsKey _fw-lib _id))
(define NSURLVolumeSupportsRenamingKey (get-ffi-obj 'NSURLVolumeSupportsRenamingKey _fw-lib _id))
(define NSURLVolumeSupportsRootDirectoryDatesKey (get-ffi-obj 'NSURLVolumeSupportsRootDirectoryDatesKey _fw-lib _id))
(define NSURLVolumeSupportsSparseFilesKey (get-ffi-obj 'NSURLVolumeSupportsSparseFilesKey _fw-lib _id))
(define NSURLVolumeSupportsSwapRenamingKey (get-ffi-obj 'NSURLVolumeSupportsSwapRenamingKey _fw-lib _id))
(define NSURLVolumeSupportsSymbolicLinksKey (get-ffi-obj 'NSURLVolumeSupportsSymbolicLinksKey _fw-lib _id))
(define NSURLVolumeSupportsVolumeSizesKey (get-ffi-obj 'NSURLVolumeSupportsVolumeSizesKey _fw-lib _id))
(define NSURLVolumeSupportsZeroRunsKey (get-ffi-obj 'NSURLVolumeSupportsZeroRunsKey _fw-lib _id))
(define NSURLVolumeTotalCapacityKey (get-ffi-obj 'NSURLVolumeTotalCapacityKey _fw-lib _id))
(define NSURLVolumeTypeNameKey (get-ffi-obj 'NSURLVolumeTypeNameKey _fw-lib _id))
(define NSURLVolumeURLForRemountingKey (get-ffi-obj 'NSURLVolumeURLForRemountingKey _fw-lib _id))
(define NSURLVolumeURLKey (get-ffi-obj 'NSURLVolumeURLKey _fw-lib _id))
(define NSURLVolumeUUIDStringKey (get-ffi-obj 'NSURLVolumeUUIDStringKey _fw-lib _id))
(define NSUbiquitousKeyValueStoreChangeReasonKey (get-ffi-obj 'NSUbiquitousKeyValueStoreChangeReasonKey _fw-lib _id))
(define NSUbiquitousKeyValueStoreChangedKeysKey (get-ffi-obj 'NSUbiquitousKeyValueStoreChangedKeysKey _fw-lib _id))
(define NSUbiquitousKeyValueStoreDidChangeExternallyNotification (get-ffi-obj 'NSUbiquitousKeyValueStoreDidChangeExternallyNotification _fw-lib _id))
(define NSUbiquityIdentityDidChangeNotification (get-ffi-obj 'NSUbiquityIdentityDidChangeNotification _fw-lib _id))
(define NSUnarchiveFromDataTransformerName (get-ffi-obj 'NSUnarchiveFromDataTransformerName _fw-lib _id))
(define NSUndefinedKeyException (get-ffi-obj 'NSUndefinedKeyException _fw-lib _id))
(define NSUnderlyingErrorKey (get-ffi-obj 'NSUnderlyingErrorKey _fw-lib _id))
(define NSUndoManagerCheckpointNotification (get-ffi-obj 'NSUndoManagerCheckpointNotification _fw-lib _id))
(define NSUndoManagerDidCloseUndoGroupNotification (get-ffi-obj 'NSUndoManagerDidCloseUndoGroupNotification _fw-lib _id))
(define NSUndoManagerDidOpenUndoGroupNotification (get-ffi-obj 'NSUndoManagerDidOpenUndoGroupNotification _fw-lib _id))
(define NSUndoManagerDidRedoChangeNotification (get-ffi-obj 'NSUndoManagerDidRedoChangeNotification _fw-lib _id))
(define NSUndoManagerDidUndoChangeNotification (get-ffi-obj 'NSUndoManagerDidUndoChangeNotification _fw-lib _id))
(define NSUndoManagerGroupIsDiscardableKey (get-ffi-obj 'NSUndoManagerGroupIsDiscardableKey _fw-lib _id))
(define NSUndoManagerWillCloseUndoGroupNotification (get-ffi-obj 'NSUndoManagerWillCloseUndoGroupNotification _fw-lib _id))
(define NSUndoManagerWillRedoChangeNotification (get-ffi-obj 'NSUndoManagerWillRedoChangeNotification _fw-lib _id))
(define NSUndoManagerWillUndoChangeNotification (get-ffi-obj 'NSUndoManagerWillUndoChangeNotification _fw-lib _id))
(define NSUnionOfArraysKeyValueOperator (get-ffi-obj 'NSUnionOfArraysKeyValueOperator _fw-lib _id))
(define NSUnionOfObjectsKeyValueOperator (get-ffi-obj 'NSUnionOfObjectsKeyValueOperator _fw-lib _id))
(define NSUnionOfSetsKeyValueOperator (get-ffi-obj 'NSUnionOfSetsKeyValueOperator _fw-lib _id))
(define NSUserActivityTypeBrowsingWeb (get-ffi-obj 'NSUserActivityTypeBrowsingWeb _fw-lib _id))
(define NSUserDefaultsDidChangeNotification (get-ffi-obj 'NSUserDefaultsDidChangeNotification _fw-lib _id))
(define NSUserNotificationDefaultSoundName (get-ffi-obj 'NSUserNotificationDefaultSoundName _fw-lib _id))
(define NSWeekDayNameArray (get-ffi-obj 'NSWeekDayNameArray _fw-lib _id))
(define NSWillBecomeMultiThreadedNotification (get-ffi-obj 'NSWillBecomeMultiThreadedNotification _fw-lib _id))
(define NSXMLParserErrorDomain (get-ffi-obj 'NSXMLParserErrorDomain _fw-lib _id))
(define NSYearMonthWeekDesignations (get-ffi-obj 'NSYearMonthWeekDesignations _fw-lib _id))
(define NSZeroPoint (ffi-obj-ref 'NSZeroPoint _fw-lib))
(define NSZeroRect (ffi-obj-ref 'NSZeroRect _fw-lib))
(define NSZeroSize (ffi-obj-ref 'NSZeroSize _fw-lib))
