;;; Generated gerbil-bindings global generics — do not edit
;; One :std/generic generic per distinct instance-surface selector across
;; every framework, declared ONCE so a selector shared by unrelated classes
;; is a single generic they all extend — not N colliding per-module generics
;; that clash at the framework facade.
(import (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod)))
(export
  abbreviation
  abbreviation-for-date
  abort-parsing
  absolute-path
  absolute-string
  absolute-url
  accept-input-for-mode-before-date
  acquire-function
  action-button-title
  activate
  activation-type
  active-processor-count
  activity-type
  actual-delivery-date
  adaptive
  add-attribute!
  add-barrier-block!
  add-characters-in-range!
  add-characters-in-string!
  add-child!
  add-child-with-pending-unit-count!
  add-dependency!
  add-execution-block!
  add-file-wrapper!
  add-index!
  add-indexes!
  add-indexes-in-range!
  add-namespace!
  add-object!
  add-observer-for-name-object-queue-using-block!
  add-observer-selector-name-object!
  add-observer-selector-name-object-suspension-behavior!
  add-operation!
  add-operation-with-block!
  add-operations-wait-until-finished!
  add-port-for-mode!
  add-regular-file-with-contents-preferred-filename!
  add-request-mode!
  add-run-loop!
  add-suite-named!
  add-timer-for-mode!
  add-user-info-entries-from-dictionary!
  additional-actions
  additional-actions!
  additional-activation-action
  additional-activation-action!
  address
  address!
  address-components
  addresses
  addresses!
  ae-desc
  aete-resource
  all-credentials
  all-header-fields
  all-http-header-fields
  all-keys
  all-languages
  all-objects
  all-scripts
  all-values
  allow-evaluation
  allow-evaluation-with-validator-error
  allowed-classes
  allowed-external-entity-ur-ls
  allowed-units
  allows-cellular-access
  allows-constrained-network-access
  allows-expensive-network-access
  allows-extended-attributes
  allows-floats
  allows-fractional-units
  allows-json5
  allows-keyed-coding
  allows-nonnumeric-formatting
  allows-persistent-dns
  allows-ultra-constrained-network-access
  alternate-quotation-begin-delimiter
  alternate-quotation-end-delimiter
  alternative-strings
  always-shows-decimal-separator
  am-symbol
  annotated-string-from-person-name-components
  any-object
  app-store-receipt-url
  append-transform
  apple-event
  apple-event-class-code
  apple-event-code
  apple-event-code-for-argument-with-name
  apple-event-code-for-key
  apple-event-code-for-return-type
  apple-event-code-for-suite
  applies-source-position-attributes
  archiver-data
  argument-names
  arguments
  arguments-retained
  array
  array-for-key
  ascending
  associated-index
  assumes-http3-capable
  assumes-top-level-dictionary
  asynchronous
  at-end
  attachments
  attribute
  attribute-declaration-for-name-element-name
  attribute-descriptor-for-keyword
  attribute-for-local-name-uri
  attribute-for-name
  attribute-keys
  attributed-content-text
  attributed-string-for-nil
  attributed-string-for-not-a-number
  attributed-string-for-object-value-with-default-attributes
  attributed-string-for-zero
  attributed-title
  attributes
  attributes-of-file-system-for-path-error
  attributes-of-item-at-path-error
  attribution
  audit-session-identifier
  authentication-method
  automatic-termination-support-enabled
  available-data
  base-specifier
  base-unit-value-from-value
  base-url
  become-current
  become-current-with-pending-unit-count
  begin-undo-grouping!
  bitmap-representation
  bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error
  bool-for-key
  bool-value
  boolean-value
  break-lock
  broadcast
  built-in-plug-ins-path
  built-in-plug-ins-url
  bundle-for-suite
  bundle-identifier
  bundle-path
  bundle-url
  bytes
  cache-policy
  cached-response
  cached-response-for-request
  calendar
  calendar-identifier
  call-stack-return-addresses
  call-stack-symbols
  can-be-converted-to-unit
  can-load-object-of-class
  can-redo
  can-undo
  cancel
  cancel-all-operations
  cancel-by-producing-resume-data
  cancel-request-with-error
  cancel-with-close-code-reason
  cancellable
  cancelled
  canonical-xml-string-preserving-comments
  capitalized-string
  capture-streams
  case-sensitive
  cellular
  certificates
  change-current-directory-path
  change-type
  char-value
  character-at-index
  character-encoding
  character-is-member
  characters-to-be-skipped
  checking-types
  child-at-index
  child-count
  child-specifier
  children
  class-description-for-key
  class-description-with-apple-event-code
  class-descriptions-in-suite
  class-name
  class-name-encoded-for-true-class-name
  class-named
  classes-for-selector-argument-index-of-reply
  client
  close!
  close-and-return-error!
  close-code
  close-code!
  close-read!
  close-reason
  close-reason!
  close-write!
  code
  coefficient
  coerce-to-descriptor-type
  coerce-value-to-class
  collapses-largest-unit
  collation-identifier
  collator-identifier
  collect-exhaustively
  collect-if-needed
  collection
  column
  column-alignments
  column-count
  column-number
  command-class-name
  command-description
  command-description-with-apple-event-class-and-apple-event-code
  command-descriptions-in-suite
  command-name
  comment
  comment-url
  compact
  compare
  compare-date-to-date-to-unit-granularity
  compare-object-to-object
  comparison-predicate-modifier
  compiled
  complete-request-returning-items-completion-handler
  completed-unit-count
  component-from-date
  components
  components-from-date
  components-from-date-components-to-date-components-options
  components-from-date-to-date-options
  components-in-time-zone-from-date
  components-to-display-for-path
  compound-predicate-type
  concurrent
  condition
  configuration
  conflict
  connect-end-date
  connect-start-date
  connection
  connection-for-proxy
  connection-proxy-dictionary
  constant
  constant-value
  constrained
  container-class-description
  container-is-object-being-tested
  container-is-range-container-object
  container-specifier
  container-url-for-security-application-group-identifier
  contains-date
  contains-index
  contains-indexes
  contains-indexes-in-range
  contains-object
  contains-value-for-key
  content-image
  contents-at-path
  contents-equal-at-path-and-path
  contents-of-directory-at-path-error
  contents-of-directory-at-url-including-properties-for-keys-options-error
  conversation
  converter
  cookie-accept-policy
  cookie-partition-identifier
  cookies
  cookies-for-url
  coordinate-access-with-intents-queue-by-accessor
  copy-item-at-path-to-path-error
  copy-item-at-url-to-url-error
  count
  count-for-object
  count-limit
  count-of-bytes-client-expects-to-receive
  count-of-bytes-client-expects-to-send
  count-of-bytes-expected-to-receive
  count-of-bytes-expected-to-send
  count-of-bytes-received
  count-of-bytes-sent
  count-of-indexes-in-range
  count-of-request-body-bytes-before-encoding
  count-of-request-body-bytes-sent
  count-of-request-header-bytes-sent
  count-of-response-body-bytes-after-decoding
  count-of-response-body-bytes-received
  count-of-response-header-bytes-received
  count-style
  country-code
  create-class-description
  create-command-instance
  create-directory-at-path-with-intermediate-directories-attributes-error
  create-directory-at-url-with-intermediate-directories-attributes-error
  create-file-at-path-contents-attributes
  create-symbolic-link-at-path-with-destination-path-error
  create-symbolic-link-at-url-with-destination-url-error
  credentials-for-protection-space
  currency-code
  currency-decimal-separator
  currency-grouping-separator
  currency-symbol
  current-apple-event
  current-directory-path
  current-directory-url
  current-disk-usage
  current-index
  current-memory-usage
  current-mode
  current-reply-apple-event
  current-request
  custom-mirror
  custom-playground-quick-look
  custom-selector
  data
  data-decoding-strategy
  data-encoding-strategy
  data-for-key
  data-representation
  data-task-with-request
  data-task-with-url
  date
  date-by-adding-components-to-date-options
  date-by-adding-unit-value-to-date-options
  date-by-setting-hour-minute-second-of-date-options
  date-by-setting-unit-value-of-date-options
  date-decoding-strategy
  date-encoding-strategy
  date-format
  date-from-components
  date-from-string
  date-matches-components
  date-style
  date-template
  date-time-style
  date-value
  date-with-era-year-for-week-of-year-week-of-year-weekday-hour-minute-second-nanosecond
  date-with-era-year-month-day-hour-minute-second-nanosecond
  day
  day-of-year
  daylight-saving-time
  daylight-saving-time-offset
  daylight-saving-time-offset-for-date
  dealloc
  debug-description
  decimal-number-by-adding
  decimal-number-by-adding-with-behavior
  decimal-number-by-dividing-by
  decimal-number-by-dividing-by-with-behavior
  decimal-number-by-multiplying-by
  decimal-number-by-multiplying-by-power-of10
  decimal-number-by-multiplying-by-power-of10-with-behavior
  decimal-number-by-multiplying-by-with-behavior
  decimal-number-by-raising-to-power
  decimal-number-by-raising-to-power-with-behavior
  decimal-number-by-rounding-according-to-behavior
  decimal-number-by-subtracting
  decimal-number-by-subtracting-with-behavior
  decimal-separator
  decode-bool-for-key
  decode-data-object
  decode-double-for-key
  decode-float-for-key
  decode-int-for-key
  decode-int32-for-key
  decode-int64-for-key
  decode-object-for-key
  decode-port-object
  decode-top-level-object
  decoding-failure-policy
  decomposed-string-with-canonical-mapping
  decomposed-string-with-compatibility-mapping
  default-credential-for-protection-space
  default-date
  default-name-server-port-number
  default-subcontainer-attribute-key
  definiteness
  delegate
  delegate-queue
  delete-cookie
  deletes-file-upon-failure
  deliver-notification
  delivered-notifications
  delivery-date
  delivery-repeat-interval
  delivery-time-zone
  dependencies
  dependent-morphology
  dequeue-notifications-matching-coalesce-mask
  description
  description-function
  description-in-strings-file-format
  description-with-locale
  descriptor
  descriptor-at-index
  descriptor-for-keyword
  descriptor-type
  destination-of-symbolic-link-at-path-error
  detach
  determination
  development-localization
  dictionary-for-key
  dictionary-representation
  difference-by-transforming-changes-with-block
  direct-parameter
  directory
  directory-attributes
  disable
  disable-automatic-termination
  disable-sudden-termination
  disable-undo-registration
  disable-updates
  discardable
  discretionary
  disk-capacity
  dispatch-with-components
  display-name-at-path!
  display-name-for-key-value!
  distinguished-names
  document-content-kind
  does-relative-date-formatting
  domain
  domain-lookup-end-date
  domain-lookup-start-date
  domain-resolution-protocol
  dominant-language
  dominant-script
  double-for-key
  double-value
  download-task-with-request
  download-task-with-resume-data
  download-task-with-url
  drain
  dtd
  dtd-kind
  duration
  earliest-begin-date
  edge-insets-value
  editing-string-for-object-value
  effective-group-identifier
  effective-user-identifier
  element-declaration-for-name
  elements-for-local-name-uri
  elements-for-name
  eligible-for-handoff
  eligible-for-public-indexing
  eligible-for-search
  enable
  enable-automatic-termination
  enable-multiple-threads
  enable-sudden-termination
  enable-undo-registration
  enable-updates
  enables-early-data
  encode-bool-for-key
  encode-class-name-into-class-name
  encode-conditional-object
  encode-conditional-object-for-key
  encode-data-object
  encode-double-for-key
  encode-float-for-key
  encode-int-for-key
  encode-int32-for-key
  encode-int64-for-key
  encode-object-for-key
  encode-port-object
  encode-root-object
  encode-xpc-object-for-key
  encoded-data
  encoded-host
  end-column
  end-column!
  end-date
  end-date!
  end-index
  end-line
  end-line!
  end-specifier
  end-specifier!
  end-subelement-identifier
  end-subelement-identifier!
  end-subelement-index
  end-subelement-index!
  end-undo-grouping!
  endpoint
  endpoint!
  enqueue-notification-posting-style
  enqueue-notification-posting-style-coalesce-mask-for-modes
  entity-declaration-for-name
  enum-code-value
  enumerate-dates-starting-after-date-matching-components-options-using-block
  enumerate-indexes-in-range-options-using-block
  enumerate-indexes-using-block
  enumerate-indexes-with-options-using-block
  enumerate-results-using-block
  enumerate-results-with-options-using-block
  enumerator-at-path
  enumerator-at-url-including-properties-for-keys-options-error-handler
  environment
  era
  era-symbols
  error
  estimated-time-remaining
  evaluate
  evaluate-with-object
  evaluate-with-object-substitution-variables
  evaluated-arguments
  evaluated-receivers
  evaluation-error-number
  evaluation-error-specifier
  event-class
  event-id
  evict-ubiquitous-item-at-url-error
  evicts-objects-with-discarded-content
  executable-architectures
  executable-path
  executable-url
  execute-command
  execute-with-apple-event-completion-handler
  execute-with-arguments-completion-handler
  execute-with-completion-handler
  execute-with-input-completion-handler
  executing
  execution-blocks
  exemplar-character-set
  expected-content-length
  expensive
  expiration-date
  expires-date
  exponent-symbol
  exported-interface
  exported-object
  expression-type
  expression-value-with-object-context
  external
  external-entity-resolving-policy
  failure-policy
  failure-response
  false-expression
  family-name
  fastest-encoding
  fetch-latest-remote-version-of-item-at-url-completion-handler
  fetch-start-date
  file-attributes
  file-completed-count
  file-descriptor
  file-exists-at-path
  file-handle-for-reading
  file-handle-for-writing
  file-operation-kind
  file-path-url
  file-reference-url
  file-system-representation
  file-system-representation-with-path
  file-total-count
  file-url
  file-url-value
  file-wrappers
  filename
  finalize
  finish-decoding
  finish-encoding
  finish-tasks-and-invalidate
  finished
  fire
  fire-date
  first-index
  first-object
  first-weekday
  float-for-key
  float-value
  flush-with-completion-handler
  for-food-energy-use
  for-person-height-use
  for-person-mass-use
  form-intersection-with-character-set
  form-union-with-character-set
  format
  format-options
  format-width
  formatter-behavior
  formatting-context
  forward-invocation
  fraction-completed
  fragment
  frame-length
  full-user-name
  function
  gathering
  generates-calendar-dates
  generates-decimal-numbers
  get-all-tasks-with-completion-handler
  get-argument-type-at-index
  get-continuation-streams-with-completion-handler
  get-file-provider-connection-with-completion-handler
  get-file-provider-services-for-item-at-url-completion-handler
  get-tasks-with-completion-handler
  given-name
  globally-unique-string
  grammar-details
  grammatical-case
  grammatical-gender
  grammatical-person
  gregorian-start-date
  grouped-results
  grouping-attributes
  grouping-level
  grouping-separator
  grouping-size
  groups-by-event
  has-action-button
  has-bytes-available
  has-changes
  has-directory-path
  has-item-conforming-to-type-identifier
  has-local-contents
  has-member-in-plane
  has-ordered-to-many-relationship-for-key
  has-password
  has-property-for-key
  has-readable-property-for-key
  has-reply-button
  has-representation-conforming-to-type-identifier-file-options
  has-space-available
  has-thousand-separators
  has-thumbnail
  has-writable-property-for-key
  hash
  hash-function
  header-level
  help-anchor
  home-directory-for-current-user
  host
  host-name
  hour
  http-additional-headers
  http-body
  http-body-stream
  http-cookie-accept-policy
  http-cookie-storage
  http-maximum-connections-per-host
  http-method
  http-only
  http-should-handle-cookies
  http-should-set-cookies
  http-should-use-pipelining
  i-os-app-on-mac
  i-os-app-on-vision
  identifier
  identity
  implementation-class-name
  includes-actual-byte-count
  includes-approximation-phrase
  includes-count
  includes-peer-to-peer
  includes-time-remaining-phrase
  includes-unit
  indentation-level
  independent-conversation-queueing
  indeterminate
  index
  index-at-position
  index-greater-than-index
  index-greater-than-or-equal-to-index
  index-in-range-options-passing-test
  index-less-than-index
  index-less-than-or-equal-to-index
  index-of-object
  index-of-result
  index-passing-test
  index-path-by-adding-index
  index-path-by-removing-last-index
  index-with-options-passing-test
  indexes-in-range-options-passing-test
  indexes-passing-test
  indexes-with-options-passing-test
  info-dictionary
  informative-text
  init-absolute-url-with-data-representation-relative-to-url
  init-and-test-with-tests
  init-directory-with-file-wrappers
  init-file-url-with-file-system-representation-is-directory-relative-to-url
  init-file-url-with-path
  init-file-url-with-path-is-directory
  init-file-url-with-path-is-directory-relative-to-url
  init-file-url-with-path-relative-to-url
  init-for-reading-from-data-error
  init-for-reading-with-data
  init-for-writing-with-mutable-data
  init-list-descriptor
  init-not-test-with-test
  init-or-test-with-tests
  init-record-descriptor
  init-regular-file-with-contents
  init-remote-with-protocol-family-socket-type-protocol-address
  init-remote-with-tcp-port-host
  init-requiring-secure-coding
  init-symbolic-link-with-destination-url
  init-to-memory
  input-items
  insert-child-at-index!
  insert-children-at-index!
  insert-descriptor-at-index!
  insert-object-at-index!
  insertion-container
  insertion-container!
  insertion-index
  insertion-index!
  insertion-key
  insertion-key!
  insertion-replaces
  insertion-replaces!
  insertions
  insertions!
  int-value
  int32-value
  integer-for-key
  integer-value
  intent-kind
  interface-for-selector-argument-index-of-reply
  international-currency-symbol
  interpreted-syntax
  interrupt
  intersect-hash-table
  intersection-with-date-interval
  intersects-date-interval
  intersects-hash-table
  intersects-indexes-in-range
  interval
  invalidate
  invalidate-and-cancel
  inverse-difference
  inverse-for-relationship-key
  invert
  inverted-set
  invocation
  invoke
  invoke-with-target
  is-adaptive
  is-asynchronous
  is-at-end
  is-bycopy
  is-byref
  is-cancellable
  is-cancelled
  is-cellular
  is-compiled
  is-concurrent
  is-conflict
  is-constrained
  is-date-equal-to-date-to-unit-granularity
  is-date-in-same-day-as-date
  is-date-in-today
  is-date-in-tomorrow
  is-date-in-weekend
  is-date-in-yesterday
  is-daylight-saving-time-for-date
  is-deletable-file-at-path
  is-directory
  is-discardable
  is-discretionary
  is-eligible-for-handoff
  is-eligible-for-public-indexing
  is-eligible-for-search
  is-enabled
  is-enumerating-directory-post-order
  is-equal-function
  is-equal-to-date-interval
  is-equal-to-hash-table
  is-equal-to-host
  is-equal-to-index-set
  is-equal-to-number
  is-equivalent-to-presentation-intent
  is-executable-file-at-path
  is-executing
  is-expensive
  is-external
  is-file-reference-url
  is-file-url
  is-finished
  is-for-food-energy-use
  is-for-person-height-use
  is-for-person-mass-use
  is-gathering
  is-http-only
  is-indeterminate
  is-leap-month
  is-lenient
  is-loaded
  is-location-required-to-create-for-key
  is-main-thread
  is-multipath
  is-old
  is-oneway
  is-optional-argument-with-name
  is-partial-string-validation-enabled
  is-pausable
  is-paused
  is-phonetic
  is-presented
  is-proxy
  is-proxy-connection
  is-readable-file-at-path
  is-ready
  is-record-descriptor
  is-redoing
  is-regular-file
  is-remote
  is-repeated-day
  is-resolved
  is-reused-connection
  is-running
  is-secure
  is-session-only
  is-standalone
  is-started
  is-stopped
  is-subset-of-hash-table
  is-superset-of-set
  is-suspended
  is-symbolic-link
  is-true
  is-ubiquitous-item-at-url
  is-undo-registration-enabled
  is-undoing
  is-valid
  is-valid-date
  is-valid-date-in-calendar
  is-well-formed
  is-word-in-user-dictionaries-case-sensitive
  is-writable-file-at-path
  item-at-url-did-change-ubiquity-attributes
  item-at-url-did-move-to-url
  item-at-url-will-move-to-url
  item-formatter
  key
  key-class-description
  key-decoding-strategy
  key-encoding-strategy
  key-enumerator
  key-for-file-wrapper
  key-path
  key-pointer-functions
  key-specifier
  key-with-apple-event-code
  keyword-for-descriptor-at-index
  keywords
  kind
  language-code
  language-hint
  language-identifier
  language-map
  last-index
  last-object
  last-path-component
  launch-and-return-error
  launch-path
  launch-requirement-data
  leap-month
  left-expression
  length
  lenient
  level
  levels-of-undo
  limit-date-for-mode
  line-number
  link-item-at-path-to-path-error
  link-item-at-url-to-url-error
  load
  load-and-return-error
  load-data-representation-for-type-identifier-completion-handler
  load-file-representation-for-type-identifier-completion-handler
  load-in-place-file-representation-for-type-identifier-completion-handler
  load-item-for-type-identifier-options-completion-handler
  load-object-of-class-completion-handler
  load-suite-with-dictionary-from-bundle
  load-suites-from-bundle
  loaded
  local-address
  local-name
  local-objects
  local-port
  locale
  locale-identifier
  localizations
  localized-additional-description
  localized-attributed-string-for-key-value-table
  localized-capitalized-string
  localized-description
  localized-failure-reason
  localized-info-dictionary
  localized-lowercase-string
  localized-name
  localized-name-of-saving-computer
  localized-recovery-options
  localized-recovery-suggestion
  localized-string-for-date-relative-to-date
  localized-string-for-key-value-table
  localized-string-for-key-value-table-localizations
  localized-string-from-date-components
  localized-string-from-time-interval
  localized-uppercase-string
  localizes-format
  lock-before-date
  lock-date
  lock-when-condition
  lock-when-condition-before-date
  long-character-is-member
  long-era-symbols
  long-long-for-key
  long-long-value
  long-value
  low-power-mode-enabled
  lowercase-string
  mac-catalyst-app
  mach-port
  main
  main-document-url
  make-iterator
  matches-apple-event-code
  matches-contents-of-url
  max-concurrent-operation-count
  maximum
  maximum-fraction-digits
  maximum-integer-digits
  maximum-message-size
  maximum-range-of-unit
  maximum-significant-digits
  maximum-unit-count
  measurement-by-adding-measurement
  measurement-by-converting-to-unit
  measurement-by-subtracting-measurement
  member
  memory-capacity
  method-return-length
  method-return-type
  method-signature
  method-signature-for-selector
  middle-name
  mime-type
  minimum
  minimum-days-in-first-week
  minimum-fraction-digits
  minimum-grouping-digits
  minimum-integer-digits
  minimum-range-of-unit
  minimum-significant-digits
  minimum-tolerance
  minus-hash-table
  minus-sign
  minute
  modification-date
  month
  month-symbols
  morphology
  mounted-volume-ur-ls-including-resource-values-for-keys-options
  move-item-at-path-to-path-error!
  move-item-at-url-to-url-error!
  msgid
  multipath
  multiple-threads-enabled
  multiplier
  mutable-bytes
  mutable-string
  name
  name-prefix
  name-suffix
  names
  namespace-for-prefix
  namespaces
  nanosecond
  needs-save
  negative-format
  negative-infinity-symbol
  negative-prefix
  negative-suffix
  negotiated-tls-cipher-suite
  negotiated-tls-protocol-version
  network-protocol-name
  network-service-type
  next-date-after-date-matching-components-options
  next-date-after-date-matching-hour-minute-second-options
  next-date-after-date-matching-unit-value-options
  next-daylight-saving-time-transition
  next-daylight-saving-time-transition-after-date
  next-node
  next-object
  next-sibling
  nickname
  nil-symbol
  nodes-for-x-path-error
  non-conforming-float-decoding-strategy
  non-conforming-float-encoding-strategy
  nonretained-object-value
  normalize-adjacent-text-nodes-preserving-cdata
  not-a-number-symbol
  notation-declaration-for-name
  notation-name
  notification-batching-interval
  now
  number
  number-formatter
  number-from-string
  number-of-arguments
  number-of-capture-groups
  number-of-items
  number-of-ranges
  number-style
  obj-c-type
  object
  object-at-index
  object-being-tested
  object-by-applying-xslt-arguments-error
  object-by-applying-xslt-at-url-arguments-error
  object-by-applying-xslt-string-arguments-error
  object-enumerator
  object-for-info-dictionary-key
  object-for-key
  object-form
  object-is-forced-for-key
  object-is-forced-for-key-in-domain
  object-specifier
  object-value
  objects-by-evaluating-specifier
  objects-by-evaluating-with-containers
  objects-for-x-query-constants-error
  objects-for-x-query-error
  offset
  offset-in-file
  old
  open
  open-url-completion-handler
  operand
  operating-system-version-string
  operation-count
  operation-queue
  operations
  options
  ordinal
  ordinality-of-unit-in-unit-for-date
  original-request
  originator-name-components
  orthography
  other-button-title
  output-format
  output-formatting
  padding-character
  padding-position
  param-descriptor-for-keyword
  parameter-string
  parent
  parent-intent
  parse
  parser-error
  part-of-speech
  partial-string-validation-enabled
  password
  path
  path-components
  path-extension
  path-for-auxiliary-executable
  path-for-resource-of-type
  path-for-resource-of-type-in-directory-for-localization
  paths-for-resources-of-type-in-directory-for-localization
  pattern
  pausable
  pause
  pause-sync-for-ubiquitous-item-at-url-completion-handler
  paused
  per-mill-symbol
  percent-encoded-fragment
  percent-encoded-host
  percent-encoded-password
  percent-encoded-path
  percent-encoded-query
  percent-encoded-query-items
  percent-encoded-user
  percent-symbol
  perform-as-current-with-pending-unit-count-using-block!
  perform-default-implementation!
  persistence
  persistent-domain-for-name
  persistent-identifier
  person-name-components-from-string
  phone-number
  phonetic
  phonetic-representation
  physical-memory
  plus-sign
  pm-symbol
  point-value
  pointer-functions
  pointer-value
  port
  port-for-name
  port-for-name-host
  port-for-name-host-name-server-port-number
  port-list
  position
  positive-format
  positive-infinity-symbol
  positive-prefix
  positive-suffix
  possessive-adjective-form
  possessive-form
  post-notification
  post-notification-name-object
  post-notification-name-object-user-info
  post-notification-name-object-user-info-deliver-immediately
  post-notification-name-object-user-info-options
  precomposed-string-with-canonical-mapping
  precomposed-string-with-compatibility-mapping
  predicate
  predicate-format
  predicate-operator-type
  predicate-with-substitution-variables
  preferred-filename
  preferred-localizations
  prefers-incremental-delivery
  prefix
  preflight-and-return-error
  prepare-with-invocation-target
  prepend-transform
  presented
  previous-failure-count
  previous-node
  previous-sibling
  principal-class
  priority
  private-frameworks-path
  private-frameworks-url
  process-identifier
  process-name
  processor-count
  progress
  pronoun
  pronoun-type
  pronouns
  properties
  property-for-key
  proposed-credential
  protection-space
  protocol
  protocol-classes
  protocol-family
  proxy-connection
  proxy-type
  public-id
  publish
  publish-with-options
  purpose-identifier
  quality-of-service
  quarter
  quarter-symbols
  query
  query-items
  queue-priority
  quotation-begin-delimiter
  quotation-end-delimiter
  raise
  range
  range-container-object
  range-in-string
  range-of-fragment
  range-of-host
  range-of-password
  range-of-path
  range-of-port
  range-of-query
  range-of-scheme
  range-of-unit-in-unit-for-date
  range-of-user
  range-value
  read-data-of-min-length-max-length-timeout-completion-handler
  read-data-to-end-of-file-and-return-error
  read-data-up-to-length-error
  read-from-url-options-error
  read-to-end
  ready
  realm
  reason
  receive
  receive-message-with-completion-handler
  receive-port
  receivers-specifier
  receives-credential-securely
  recovery-attempter
  rect-value
  redirect-count
  redo
  redo-action-is-discardable
  redo-action-name
  redo-action-user-info-value-for-key
  redo-count
  redo-menu-item-title
  redo-menu-title-for-undo-action-name
  redoing
  reference-date
  referrer-url
  reflexive-form
  region-code
  regions
  register-class-description
  register-coercer-selector-to-convert-from-class-to-class
  register-command-description
  register-data-representation-for-type-identifier-visibility-load-handler
  register-defaults
  register-file-representation-for-type-identifier-file-options-visibility-load-handler
  register-item-for-type-identifier-load-handler
  register-language-by-vendor
  register-name
  register-name-with-name-server
  register-object-of-class-visibility-load-handler
  register-object-visibility
  register-port-name
  register-port-name-name-server-port-number
  register-undo-with-target-handler
  register-undo-with-target-selector-object
  registered-type-identifiers
  registered-type-identifiers-with-file-options
  regular-expression
  regular-file
  regular-file-contents
  relative-path
  relative-position
  relative-string
  relinquish-function
  remote
  remote-address
  remote-object-interface
  remote-object-proxy
  remote-object-proxy-with-error-handler
  remote-objects
  remote-port
  removals
  remove-all-actions!
  remove-all-actions-with-target!
  remove-all-cached-resource-values!
  remove-all-cached-responses!
  remove-all-delivered-notifications!
  remove-all-indexes!
  remove-all-objects!
  remove-and-return-error!
  remove-attribute-for-name!
  remove-cached-resource-value-for-key!
  remove-cached-response-for-request!
  remove-cached-responses-since-date!
  remove-characters-in-range!
  remove-characters-in-string!
  remove-child-at-index!
  remove-cookies-since-date!
  remove-credential-for-protection-space!
  remove-credential-for-protection-space-options!
  remove-delivered-notification!
  remove-dependency!
  remove-descriptor-at-index!
  remove-descriptor-with-keyword!
  remove-event-handler-for-event-class-and-event-id!
  remove-file-wrapper!
  remove-from-run-loop-for-mode!
  remove-index!
  remove-indexes!
  remove-indexes-in-range!
  remove-item-at-path-error!
  remove-item-at-url-error!
  remove-last-object!
  remove-namespace-for-prefix!
  remove-object!
  remove-object-at-index!
  remove-object-for-key!
  remove-observer!
  remove-observer-name-object!
  remove-param-descriptor-with-keyword!
  remove-persistent-domain-for-name!
  remove-pointer-at-index!
  remove-port-for-mode!
  remove-port-for-name!
  remove-request-mode!
  remove-run-loop!
  remove-scheduled-notification!
  remove-suite-named!
  remove-volatile-domain-for-name!
  repeated-day
  repeats
  replace-characters-in-range-with-string!
  replace-child-at-index-with-node!
  replace-item-at-url-options-error!
  replace-object-at-index-with-object!
  replace-object-with-object!
  replacement-string
  reply-timeout
  reply-with-exception
  request
  request-cache-policy
  request-end-date
  request-modes
  request-start-date
  request-timeout
  required-user-info-keys
  requires-dnssec-validation
  requires-secure-coding
  reserved-space-length
  reset-with-completion-handler!
  resign-current
  resolve-namespace-for-name
  resolve-prefix-for-namespace-uri
  resolve-with-timeout
  resolved
  resolved-key-dictionary
  resource-fetch-type
  resource-path
  resource-specifier
  resource-url
  resource-values-for-keys-error
  response
  response-end-date
  response-placeholder
  response-start-date
  result
  result-at-index
  result-count
  result-type
  results
  resume
  resume-data
  resume-execution-with-result
  resume-sync-for-ubiquitous-item-at-url-with-behavior-completion-handler
  retain-arguments
  return-id
  return-type
  reused-connection
  reverse-transformed-value
  reversed-ordered-set
  reversed-sort-descriptor
  right-expression
  root-document
  root-element
  root-object
  root-proxy
  rotate-by-degrees
  rotate-by-radians
  rounding-behavior
  rounding-increment
  rounding-mode
  row
  run
  run-in-new-thread
  run-loop-modes
  running
  same-site-policy
  save-options
  scale-by
  scale-x-by-y-by
  scan-character
  scan-decimal
  scan-location
  schedule-in-run-loop-for-mode
  schedule-notification
  schedule-send-barrier-block
  schedule-with-block
  scheduled-notifications
  scheme
  script-code
  script-error-expected-type-descriptor
  script-error-number
  script-error-offending-object-descriptor
  script-error-string
  script-url
  search-for-browsable-domains
  search-for-registration-domains
  search-for-services-of-type-in-domain
  search-items
  search-scopes
  second
  secondary-grouping-size
  seconds-from-gmt
  seconds-from-gmt-for-date
  secure
  secure-connection-end-date
  secure-connection-start-date
  seek-to-end
  seek-to-offset-error
  selector
  selector-for-command
  send-before-date
  send-before-date-components-from-reserved
  send-before-date-msgid-components-from-reserved
  send-event-with-options-timeout-error
  send-message-completion-handler
  send-ping-with-pong-receive-handler
  send-port
  sender
  sentence-range-for-range
  serialized-representation
  server-trust
  service-name
  service-port-with-name
  session-description
  session-only
  session-sends-launch-events
  set
  set-acquire-function!
  set-action-button-title!
  set-action-is-discardable!
  set-action-name!
  set-action-user-info-value-for-key!
  set-adaptive!
  set-additional-actions!
  set-all-http-header-fields!
  set-allowed-external-entity-ur-ls!
  set-allowed-units!
  set-allows-cellular-access!
  set-allows-constrained-network-access!
  set-allows-expensive-network-access!
  set-allows-extended-attributes!
  set-allows-floats!
  set-allows-fractional-units!
  set-allows-json5!
  set-allows-nonnumeric-formatting!
  set-allows-persistent-dns!
  set-allows-ultra-constrained-network-access!
  set-always-shows-decimal-separator!
  set-am-symbol!
  set-applies-source-position-attributes!
  set-arguments!
  set-array-for-key!
  set-assumes-http3-capable!
  set-assumes-top-level-dictionary!
  set-attachments!
  set-attribute-descriptor-for-keyword!
  set-attributed-content-text!
  set-attributed-string-for-nil!
  set-attributed-string-for-not-a-number!
  set-attributed-string-for-zero!
  set-attributed-title!
  set-attributes!
  set-attributes-of-item-at-path-error!
  set-attributes-range!
  set-attributes-with-dictionary!
  set-attribution!
  set-automatic-termination-support-enabled!
  set-base-specifier!
  set-bool-for-key!
  set-cache-policy!
  set-calendar!
  set-cancellable!
  set-cancellation-handler!
  set-case-sensitive!
  set-character-encoding!
  set-characters-to-be-skipped!
  set-child-specifier!
  set-children!
  set-classes-for-selector-argument-index-of-reply!
  set-code-signing-requirement!
  set-collapses-largest-unit!
  set-completed-unit-count!
  set-completion-block!
  set-connection-code-signing-requirement!
  set-connection-proxy-dictionary!
  set-container-class-description!
  set-container-is-object-being-tested!
  set-container-is-range-container-object!
  set-container-specifier!
  set-content-image!
  set-cookie!
  set-cookie-accept-policy!
  set-cookie-partition-identifier!
  set-cookies-for-url-main-document-url!
  set-count!
  set-count-limit!
  set-count-of-bytes-client-expects-to-receive!
  set-count-of-bytes-client-expects-to-send!
  set-count-style!
  set-credential-for-protection-space!
  set-currency-code!
  set-currency-decimal-separator!
  set-currency-grouping-separator!
  set-currency-symbol!
  set-current-directory-path!
  set-current-directory-url!
  set-current-index!
  set-data-decoding-strategy!
  set-data-encoding-strategy!
  set-data-for-key!
  set-date-decoding-strategy!
  set-date-encoding-strategy!
  set-date-format!
  set-date-style!
  set-date-template!
  set-date-time-style!
  set-day!
  set-day-of-year!
  set-decimal-separator!
  set-decoding-failure-policy!
  set-default-credential-for-protection-space!
  set-default-date!
  set-default-name-server-port-number!
  set-definiteness!
  set-delegate!
  set-delegate-queue!
  set-deletes-file-upon-failure!
  set-delivery-date!
  set-delivery-repeat-interval!
  set-delivery-time-zone!
  set-description-function!
  set-descriptor-for-keyword!
  set-destination-allow-overwrite!
  set-determination!
  set-dictionary-for-key!
  set-direct-parameter!
  set-discardable!
  set-discretionary!
  set-disk-capacity!
  set-document-content-kind!
  set-does-relative-date-formatting!
  set-double-for-key!
  set-dtd!
  set-dtd-kind!
  set-earliest-begin-date!
  set-eligible-for-handoff!
  set-eligible-for-public-indexing!
  set-eligible-for-search!
  set-enables-early-data!
  set-encoded-host!
  set-end-specifier!
  set-end-subelement-identifier!
  set-end-subelement-index!
  set-environment!
  set-era!
  set-era-symbols!
  set-estimated-time-remaining!
  set-evaluation-error-number!
  set-event-handler-and-selector-for-event-class-and-event-id!
  set-evicts-objects-with-discarded-content!
  set-executable-url!
  set-expiration-date!
  set-exponent-symbol!
  set-exported-interface!
  set-exported-object!
  set-external-entity-resolving-policy!
  set-failure-policy!
  set-family-name!
  set-file-attributes!
  set-file-completed-count!
  set-file-operation-kind!
  set-file-total-count!
  set-file-url!
  set-filename!
  set-fire-date!
  set-first-weekday!
  set-float-for-key!
  set-for-food-energy-use!
  set-for-person-height-use!
  set-for-person-mass-use!
  set-format!
  set-format-options!
  set-format-width!
  set-formatter-behavior!
  set-formatting-context!
  set-fragment!
  set-generates-calendar-dates!
  set-generates-decimal-numbers!
  set-given-name!
  set-grammatical-case!
  set-grammatical-gender!
  set-grammatical-person!
  set-gregorian-start-date!
  set-grouping-attributes!
  set-grouping-separator!
  set-grouping-size!
  set-groups-by-event!
  set-has-action-button!
  set-has-reply-button!
  set-has-thousand-separators!
  set-hash-function!
  set-host!
  set-hour!
  set-http-additional-headers!
  set-http-body!
  set-http-body-stream!
  set-http-cookie-accept-policy!
  set-http-cookie-storage!
  set-http-maximum-connections-per-host!
  set-http-method!
  set-http-should-handle-cookies!
  set-http-should-set-cookies!
  set-http-should-use-pipelining!
  set-identifier!
  set-includes-actual-byte-count!
  set-includes-approximation-phrase!
  set-includes-count!
  set-includes-peer-to-peer!
  set-includes-time-remaining-phrase!
  set-includes-unit!
  set-independent-conversation-queueing!
  set-index!
  set-informative-text!
  set-insertion-class-description!
  set-integer-for-key!
  set-interface-for-selector-argument-index-of-reply!
  set-international-currency-symbol!
  set-interpreted-syntax!
  set-interruption-handler!
  set-interval!
  set-invalidation-handler!
  set-is-equal-function!
  set-item-formatter!
  set-key!
  set-key-decoding-strategy!
  set-key-encoding-strategy!
  set-keywords!
  set-kind!
  set-language-code!
  set-launch-path!
  set-launch-requirement-data!
  set-leap-month!
  set-length!
  set-lenient!
  set-levels-of-undo!
  set-locale!
  set-localized-additional-description!
  set-localized-date-format-from-template!
  set-localized-description!
  set-localizes-format!
  set-long-era-symbols!
  set-long-long-for-key!
  set-main-document-url!
  set-max-concurrent-operation-count!
  set-maximum!
  set-maximum-fraction-digits!
  set-maximum-integer-digits!
  set-maximum-message-size!
  set-maximum-significant-digits!
  set-maximum-unit-count!
  set-memory-capacity!
  set-middle-name!
  set-mime-type!
  set-minimum!
  set-minimum-days-in-first-week!
  set-minimum-fraction-digits!
  set-minimum-grouping-digits!
  set-minimum-integer-digits!
  set-minimum-significant-digits!
  set-minus-sign!
  set-minute!
  set-month!
  set-month-symbols!
  set-msgid!
  set-multiplier!
  set-name!
  set-name-prefix!
  set-name-suffix!
  set-namespaces!
  set-nanosecond!
  set-needs-save!
  set-negative-format!
  set-negative-infinity-symbol!
  set-negative-prefix!
  set-negative-suffix!
  set-network-service-type!
  set-nickname!
  set-nil-symbol!
  set-non-conforming-float-decoding-strategy!
  set-non-conforming-float-encoding-strategy!
  set-not-a-number-symbol!
  set-notation-name!
  set-notification-batching-interval!
  set-number!
  set-number-formatter!
  set-number-style!
  set-object-being-tested!
  set-object-for-key!
  set-object-for-key-cost!
  set-object-form!
  set-object-value!
  set-operation-queue!
  set-orthography-range!
  set-other-button-title!
  set-output-format!
  set-output-formatting!
  set-padding-character!
  set-padding-position!
  set-param-descriptor-for-keyword!
  set-part-of-speech!
  set-partial-string-validation-enabled!
  set-password!
  set-path!
  set-pausable!
  set-pausing-handler!
  set-per-mill-symbol!
  set-percent-encoded-fragment!
  set-percent-encoded-host!
  set-percent-encoded-password!
  set-percent-encoded-path!
  set-percent-encoded-query!
  set-percent-encoded-query-items!
  set-percent-encoded-user!
  set-percent-symbol!
  set-persistent-domain-for-name!
  set-persistent-identifier!
  set-phonetic!
  set-phonetic-representation!
  set-plus-sign!
  set-pm-symbol!
  set-port!
  set-positive-format!
  set-positive-infinity-symbol!
  set-positive-prefix!
  set-positive-suffix!
  set-possessive-adjective-form!
  set-possessive-form!
  set-predicate!
  set-preferred-filename!
  set-prefers-incremental-delivery!
  set-priority!
  set-process-name!
  set-pronoun-type!
  set-property-for-key!
  set-protocol!
  set-protocol-classes!
  set-protocol-for-proxy!
  set-public-id!
  set-purpose-identifier!
  set-quality-of-service!
  set-quarter!
  set-quarter-symbols!
  set-query!
  set-query-items!
  set-queue-priority!
  set-range-container-object!
  set-receivers-specifier!
  set-reference-date!
  set-referrer-url!
  set-reflexive-form!
  set-relative-position!
  set-relinquish-function!
  set-remote-object-interface!
  set-repeated-day!
  set-repeats!
  set-reply-timeout!
  set-representation
  set-representation!
  set-request-cache-policy!
  set-request-timeout!
  set-required-user-info-keys!
  set-requires-dnssec-validation!
  set-requires-secure-coding!
  set-resolved!
  set-resource-value-for-key-error!
  set-resource-values-error!
  set-response-placeholder!
  set-resuming-handler!
  set-root-element!
  set-root-object!
  set-rounding-behavior!
  set-rounding-increment!
  set-rounding-mode!
  set-run-loop-modes!
  set-scan-location!
  set-scheduled-notifications!
  set-scheme!
  set-script-error-expected-type-descriptor!
  set-script-error-number!
  set-script-error-offending-object-descriptor!
  set-script-error-string!
  set-search-items!
  set-search-scopes!
  set-second!
  set-secondary-grouping-size!
  set-selector!
  set-session-description!
  set-session-sends-launch-events!
  set-shared-container-identifier!
  set-short-month-symbols!
  set-short-quarter-symbols!
  set-short-standalone-month-symbols!
  set-short-standalone-quarter-symbols!
  set-short-standalone-weekday-symbols!
  set-short-weekday-symbols!
  set-should-process-namespaces!
  set-should-report-namespace-prefixes!
  set-should-resolve-external-entities!
  set-should-use-extended-background-idle-mode!
  set-size-function!
  set-sort-descriptors!
  set-sound-name!
  set-stack-size!
  set-standalone!
  set-standalone-month-symbols!
  set-standalone-quarter-symbols!
  set-standalone-weekday-symbols!
  set-standard-error!
  set-standard-input!
  set-standard-output!
  set-start-specifier!
  set-start-subelement-identifier!
  set-start-subelement-index!
  set-string!
  set-string-for-key!
  set-string-value!
  set-string-value-resolving-entities!
  set-style!
  set-subject-form!
  set-subtitle!
  set-suggested-name!
  set-supports-continuation-streams!
  set-suspended!
  set-system-id!
  set-target!
  set-target-content-identifier!
  set-task-description!
  set-temporary-resource-value-for-key!
  set-termination-handler!
  set-test!
  set-text-attributes-for-negative-infinity!
  set-text-attributes-for-negative-values!
  set-text-attributes-for-nil!
  set-text-attributes-for-not-a-number!
  set-text-attributes-for-positive-infinity!
  set-text-attributes-for-positive-values!
  set-text-attributes-for-zero!
  set-thousand-separator!
  set-thread-priority!
  set-throughput!
  set-time-style!
  set-time-zone!
  set-timeout-interval!
  set-timeout-interval-for-request!
  set-timeout-interval-for-resource!
  set-title!
  set-tls-maximum-supported-protocol!
  set-tls-maximum-supported-protocol-version!
  set-tls-minimum-supported-protocol!
  set-tls-minimum-supported-protocol-version!
  set-tolerance!
  set-top-level-object!
  set-total-cost-limit!
  set-total-unit-count!
  set-transform-struct!
  set-two-digit-start-date!
  set-txt-record-data!
  set-ubiquitous-item-at-url-destination-url-error!
  set-underlying-queue!
  set-unique-id!
  set-unit-options!
  set-unit-style!
  set-units-style!
  set-uri!
  set-url!
  set-url-cache!
  set-url-credential-storage!
  set-url-for-key!
  set-user!
  set-user-info!
  set-user-info-object-for-key!
  set-uses-classic-loading-mode!
  set-uses-grouping-separator!
  set-uses-significant-digits!
  set-uses-strong-write-barrier!
  set-uses-weak-read-and-write-barriers!
  set-value-for-component!
  set-value-list-attributes!
  set-variables!
  set-version!
  set-very-short-month-symbols!
  set-very-short-standalone-month-symbols!
  set-very-short-standalone-weekday-symbols!
  set-very-short-weekday-symbols!
  set-volatile-domain-for-name!
  set-waits-for-connectivity!
  set-webpage-url!
  set-week-of-month!
  set-week-of-year!
  set-weekday!
  set-weekday-ordinal!
  set-weekday-symbols!
  set-year!
  set-year-for-week-of-year!
  set-zero-formatting-behavior!
  set-zero-pads-fraction-digits!
  set-zero-symbol!
  shared-container-identifier
  shared-frameworks-path
  shared-frameworks-url
  shared-support-path
  shared-support-url
  shift-indexes-starting-at-index-by
  short-month-symbols
  short-quarter-symbols
  short-standalone-month-symbols
  short-standalone-quarter-symbols
  short-standalone-weekday-symbols
  short-value
  short-weekday-symbols
  should-defer
  should-process-namespaces
  should-report-namespace-prefixes
  should-resolve-external-entities
  should-use-extended-background-idle-mode
  signal
  size-function
  size-value
  skip-descendants
  skip-descendents
  smallest-encoding
  snapshot
  socket
  socket-type
  sort-descriptors
  sorted-array-hint
  sorted-cookies-using-descriptors
  sound-name
  source
  stack-size
  standalone
  standalone-month-symbols
  standalone-quarter-symbols
  standalone-weekday-symbols
  standard-error
  standard-input
  standard-output
  standardized-url
  start
  start-accessing-security-scoped-resource
  start-column
  start-date
  start-downloading-ubiquitous-item-at-url-error
  start-index
  start-line
  start-loading
  start-monitoring
  start-of-day-for-date
  start-query
  start-secure-connection
  start-specifier
  start-subelement-identifier
  start-subelement-index
  started
  state
  statistics
  status-code
  stop
  stop-accessing-security-scoped-resource
  stop-loading
  stop-monitoring
  stop-query
  stopped
  storage-policy
  store-cached-response-for-request
  stream-error
  stream-status
  stream-task-with-host-name-port
  stream-task-with-net-service
  string
  string-array-for-key
  string-by-abbreviating-with-tilde-in-path
  string-by-deleting-last-path-component
  string-by-deleting-path-extension
  string-by-expanding-tilde-in-path
  string-by-removing-percent-encoding
  string-by-resolving-symlinks-in-path
  string-by-standardizing-path
  string-edited-in-range-change-in-length
  string-for-key
  string-for-object-value
  string-from-byte-count
  string-from-date
  string-from-date-components
  string-from-date-interval
  string-from-date-to-date
  string-from-items
  string-from-joules
  string-from-kilograms
  string-from-measurement
  string-from-meters
  string-from-number
  string-from-person-name-components
  string-from-time-interval
  string-from-unit
  string-from-value-unit
  string-value
  string-with-file-system-representation-length
  style
  subgroups
  subject-form
  subpaths-at-path
  subpaths-of-directory-at-path-error
  subpredicates
  subtitle
  suggested-filename
  suggested-name
  suite-for-apple-event-code
  suite-name
  suite-names
  superclass-description
  supports-command
  supports-continuation-streams
  suspend
  suspend-execution
  suspended
  symbol
  symbolic-link
  symbolic-link-destination-url
  synchronize
  synchronize-and-return-error
  synchronous-remote-object-proxy-with-error-handler
  system-id
  system-uptime
  system-version
  tag-schemes
  target
  target-content-identifier
  task
  task-description
  task-identifier
  task-interval
  temporary-directory
  terminate
  termination-reason
  termination-status
  test
  text-attributes-for-negative-infinity
  text-attributes-for-negative-values
  text-attributes-for-nil
  text-attributes-for-not-a-number
  text-attributes-for-positive-infinity
  text-attributes-for-positive-values
  text-attributes-for-zero
  text-encoding-name
  thermal-state
  thousand-separator
  thread-dictionary
  thread-priority
  throughput
  time-interval
  time-interval-since-now
  time-interval-since-reference-date
  time-interval-since1970
  time-style
  time-zone
  timeout-interval
  timeout-interval-for-request
  timeout-interval-for-resource
  title
  tls-maximum-supported-protocol
  tls-maximum-supported-protocol-version
  tls-minimum-supported-protocol
  tls-minimum-supported-protocol-version
  to-many-relationship-keys
  to-one-relationship-keys
  token-range-at-index-unit
  tolerance
  top-level-object
  total-cost-limit
  total-unit-count
  transaction-id
  transaction-metrics
  transform-point
  transform-size
  transform-struct
  transformed-value
  translate-x-by-y-by
  true-expression
  truncate-at-offset-error
  try-lock
  try-lock-when-condition
  two-digit-start-date
  txt-record-data
  type
  type-code-value
  type-for-argument-with-name
  type-for-key
  ubiquity-identity-token
  underestimated-count
  underlying-errors
  underlying-queue
  undo
  undo-action-is-discardable
  undo-action-name
  undo-action-user-info-value-for-key
  undo-count
  undo-menu-item-title
  undo-menu-title-for-undo-action-name
  undo-nested-group
  undo-registration-enabled
  undoing
  union-hash-table
  unique-id
  unit
  unit-options
  unit-string-from-value-unit
  unit-style
  units-style
  unload
  unlock
  unlock-with-condition
  unmount-volume-at-url-options-completion-handler
  unpublish
  unschedule-from-run-loop-for-mode
  unsigned-char-value
  unsigned-int-value
  unsigned-integer-value
  unsigned-long-long-value
  unsigned-long-value
  unsigned-short-value
  unspecified
  upload-local-version-of-ubiquitous-item-at-url-with-conflict-resolution-policy-completion-handler
  upload-task-with-request-from-data
  upload-task-with-request-from-file
  upload-task-with-resume-data
  upload-task-with-streamed-request
  uppercase-string
  ur-ls-for-directory-in-domains
  ur-ls-for-resources-with-extension-subdirectory
  ur-ls-for-resources-with-extension-subdirectory-localization
  uri
  url
  url-by-deleting-last-path-component
  url-by-deleting-path-extension
  url-by-resolving-symlinks-in-path
  url-by-standardizing-path
  url-cache
  url-credential-storage
  url-for-auxiliary-executable
  url-for-directory-in-domain-appropriate-for-url-create-error
  url-for-key
  url-for-resource-with-extension
  url-for-resource-with-extension-subdirectory
  url-for-resource-with-extension-subdirectory-localization
  url-for-ubiquity-container-identifier
  url-relative-to-url
  user
  user-info
  user-name
  uses-classic-loading-mode
  uses-grouping-separator
  uses-metric-system
  uses-significant-digits
  uses-strong-write-barrier
  uses-weak-read-and-write-barriers
  utf8-string
  uuid-string
  valid
  valid-date
  validate-and-return-error
  value
  value-for-attribute
  value-for-component
  value-for-http-header-field
  value-from-base-unit-value
  value-list-attributes
  value-lists
  value-of-attribute-for-result-at-index
  value-pointer-functions
  values-for-attributes
  variable
  variables
  variant-code
  version
  version-for-class-name
  very-short-month-symbols
  very-short-standalone-month-symbols
  very-short-standalone-weekday-symbols
  very-short-weekday-symbols
  volatile-domain-for-name
  volatile-domain-names
  wait
  wait-until-all-operations-are-finished
  wait-until-date
  wait-until-finished
  waits-for-connectivity
  web-socket-task-with-request
  web-socket-task-with-url
  web-socket-task-with-url-protocols
  webpage-url
  week-of-month
  week-of-year
  weekday
  weekday-ordinal
  weekday-symbols
  well-formed
  write-data-error
  write-data-timeout-completion-handler
  write-to-url-options-original-contents-url-error
  x-path
  xml-data
  xml-data-with-options
  xml-string
  xml-string-with-options
  year
  year-for-week-of-year
  zero-formatting-behavior
  zero-pads-fraction-digits
  zero-symbol
  )

(g:defgeneric abbreviation)
(g:defgeneric abbreviation-for-date)
(g:defgeneric abort-parsing)
(g:defgeneric absolute-path)
(g:defgeneric absolute-string)
(g:defgeneric absolute-url)
(g:defgeneric accept-input-for-mode-before-date)
(g:defgeneric acquire-function)
(g:defgeneric action-button-title)
(g:defgeneric activate)
(g:defgeneric activation-type)
(g:defgeneric active-processor-count)
(g:defgeneric activity-type)
(g:defgeneric actual-delivery-date)
(g:defgeneric adaptive)
(g:defgeneric add-attribute!)
(g:defgeneric add-barrier-block!)
(g:defgeneric add-characters-in-range!)
(g:defgeneric add-characters-in-string!)
(g:defgeneric add-child!)
(g:defgeneric add-child-with-pending-unit-count!)
(g:defgeneric add-dependency!)
(g:defgeneric add-execution-block!)
(g:defgeneric add-file-wrapper!)
(g:defgeneric add-index!)
(g:defgeneric add-indexes!)
(g:defgeneric add-indexes-in-range!)
(g:defgeneric add-namespace!)
(g:defgeneric add-object!)
(g:defgeneric add-observer-for-name-object-queue-using-block!)
(g:defgeneric add-observer-selector-name-object!)
(g:defgeneric add-observer-selector-name-object-suspension-behavior!)
(g:defgeneric add-operation!)
(g:defgeneric add-operation-with-block!)
(g:defgeneric add-operations-wait-until-finished!)
(g:defgeneric add-port-for-mode!)
(g:defgeneric add-regular-file-with-contents-preferred-filename!)
(g:defgeneric add-request-mode!)
(g:defgeneric add-run-loop!)
(g:defgeneric add-suite-named!)
(g:defgeneric add-timer-for-mode!)
(g:defgeneric add-user-info-entries-from-dictionary!)
(g:defgeneric additional-actions)
(g:defgeneric additional-actions!)
(g:defgeneric additional-activation-action)
(g:defgeneric additional-activation-action!)
(g:defgeneric address)
(g:defgeneric address!)
(g:defgeneric address-components)
(g:defgeneric addresses)
(g:defgeneric addresses!)
(g:defgeneric ae-desc)
(g:defgeneric aete-resource)
(g:defgeneric all-credentials)
(g:defgeneric all-header-fields)
(g:defgeneric all-http-header-fields)
(g:defgeneric all-keys)
(g:defgeneric all-languages)
(g:defgeneric all-objects)
(g:defgeneric all-scripts)
(g:defgeneric all-values)
(g:defgeneric allow-evaluation)
(g:defgeneric allow-evaluation-with-validator-error)
(g:defgeneric allowed-classes)
(g:defgeneric allowed-external-entity-ur-ls)
(g:defgeneric allowed-units)
(g:defgeneric allows-cellular-access)
(g:defgeneric allows-constrained-network-access)
(g:defgeneric allows-expensive-network-access)
(g:defgeneric allows-extended-attributes)
(g:defgeneric allows-floats)
(g:defgeneric allows-fractional-units)
(g:defgeneric allows-json5)
(g:defgeneric allows-keyed-coding)
(g:defgeneric allows-nonnumeric-formatting)
(g:defgeneric allows-persistent-dns)
(g:defgeneric allows-ultra-constrained-network-access)
(g:defgeneric alternate-quotation-begin-delimiter)
(g:defgeneric alternate-quotation-end-delimiter)
(g:defgeneric alternative-strings)
(g:defgeneric always-shows-decimal-separator)
(g:defgeneric am-symbol)
(g:defgeneric annotated-string-from-person-name-components)
(g:defgeneric any-object)
(g:defgeneric app-store-receipt-url)
(g:defgeneric append-transform)
(g:defgeneric apple-event)
(g:defgeneric apple-event-class-code)
(g:defgeneric apple-event-code)
(g:defgeneric apple-event-code-for-argument-with-name)
(g:defgeneric apple-event-code-for-key)
(g:defgeneric apple-event-code-for-return-type)
(g:defgeneric apple-event-code-for-suite)
(g:defgeneric applies-source-position-attributes)
(g:defgeneric archiver-data)
(g:defgeneric argument-names)
(g:defgeneric arguments)
(g:defgeneric arguments-retained)
(g:defgeneric array)
(g:defgeneric array-for-key)
(g:defgeneric ascending)
(g:defgeneric associated-index)
(g:defgeneric assumes-http3-capable)
(g:defgeneric assumes-top-level-dictionary)
(g:defgeneric asynchronous)
(g:defgeneric at-end)
(g:defgeneric attachments)
(g:defgeneric attribute)
(g:defgeneric attribute-declaration-for-name-element-name)
(g:defgeneric attribute-descriptor-for-keyword)
(g:defgeneric attribute-for-local-name-uri)
(g:defgeneric attribute-for-name)
(g:defgeneric attribute-keys)
(g:defgeneric attributed-content-text)
(g:defgeneric attributed-string-for-nil)
(g:defgeneric attributed-string-for-not-a-number)
(g:defgeneric attributed-string-for-object-value-with-default-attributes)
(g:defgeneric attributed-string-for-zero)
(g:defgeneric attributed-title)
(g:defgeneric attributes)
(g:defgeneric attributes-of-file-system-for-path-error)
(g:defgeneric attributes-of-item-at-path-error)
(g:defgeneric attribution)
(g:defgeneric audit-session-identifier)
(g:defgeneric authentication-method)
(g:defgeneric automatic-termination-support-enabled)
(g:defgeneric available-data)
(g:defgeneric base-specifier)
(g:defgeneric base-unit-value-from-value)
(g:defgeneric base-url)
(g:defgeneric become-current)
(g:defgeneric become-current-with-pending-unit-count)
(g:defgeneric begin-undo-grouping!)
(g:defgeneric bitmap-representation)
(g:defgeneric bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error)
(g:defgeneric bool-for-key)
(g:defgeneric bool-value)
(g:defgeneric boolean-value)
(g:defgeneric break-lock)
(g:defgeneric broadcast)
(g:defgeneric built-in-plug-ins-path)
(g:defgeneric built-in-plug-ins-url)
(g:defgeneric bundle-for-suite)
(g:defgeneric bundle-identifier)
(g:defgeneric bundle-path)
(g:defgeneric bundle-url)
(g:defgeneric bytes)
(g:defgeneric cache-policy)
(g:defgeneric cached-response)
(g:defgeneric cached-response-for-request)
(g:defgeneric calendar)
(g:defgeneric calendar-identifier)
(g:defgeneric call-stack-return-addresses)
(g:defgeneric call-stack-symbols)
(g:defgeneric can-be-converted-to-unit)
(g:defgeneric can-load-object-of-class)
(g:defgeneric can-redo)
(g:defgeneric can-undo)
(g:defgeneric cancel)
(g:defgeneric cancel-all-operations)
(g:defgeneric cancel-by-producing-resume-data)
(g:defgeneric cancel-request-with-error)
(g:defgeneric cancel-with-close-code-reason)
(g:defgeneric cancellable)
(g:defgeneric cancelled)
(g:defgeneric canonical-xml-string-preserving-comments)
(g:defgeneric capitalized-string)
(g:defgeneric capture-streams)
(g:defgeneric case-sensitive)
(g:defgeneric cellular)
(g:defgeneric certificates)
(g:defgeneric change-current-directory-path)
(g:defgeneric change-type)
(g:defgeneric char-value)
(g:defgeneric character-at-index)
(g:defgeneric character-encoding)
(g:defgeneric character-is-member)
(g:defgeneric characters-to-be-skipped)
(g:defgeneric checking-types)
(g:defgeneric child-at-index)
(g:defgeneric child-count)
(g:defgeneric child-specifier)
(g:defgeneric children)
(g:defgeneric class-description-for-key)
(g:defgeneric class-description-with-apple-event-code)
(g:defgeneric class-descriptions-in-suite)
(g:defgeneric class-name)
(g:defgeneric class-name-encoded-for-true-class-name)
(g:defgeneric class-named)
(g:defgeneric classes-for-selector-argument-index-of-reply)
(g:defgeneric client)
(g:defgeneric close!)
(g:defgeneric close-and-return-error!)
(g:defgeneric close-code)
(g:defgeneric close-code!)
(g:defgeneric close-read!)
(g:defgeneric close-reason)
(g:defgeneric close-reason!)
(g:defgeneric close-write!)
(g:defgeneric code)
(g:defgeneric coefficient)
(g:defgeneric coerce-to-descriptor-type)
(g:defgeneric coerce-value-to-class)
(g:defgeneric collapses-largest-unit)
(g:defgeneric collation-identifier)
(g:defgeneric collator-identifier)
(g:defgeneric collect-exhaustively)
(g:defgeneric collect-if-needed)
(g:defgeneric collection)
(g:defgeneric column)
(g:defgeneric column-alignments)
(g:defgeneric column-count)
(g:defgeneric column-number)
(g:defgeneric command-class-name)
(g:defgeneric command-description)
(g:defgeneric command-description-with-apple-event-class-and-apple-event-code)
(g:defgeneric command-descriptions-in-suite)
(g:defgeneric command-name)
(g:defgeneric comment)
(g:defgeneric comment-url)
(g:defgeneric compact)
(g:defgeneric compare)
(g:defgeneric compare-date-to-date-to-unit-granularity)
(g:defgeneric compare-object-to-object)
(g:defgeneric comparison-predicate-modifier)
(g:defgeneric compiled)
(g:defgeneric complete-request-returning-items-completion-handler)
(g:defgeneric completed-unit-count)
(g:defgeneric component-from-date)
(g:defgeneric components)
(g:defgeneric components-from-date)
(g:defgeneric components-from-date-components-to-date-components-options)
(g:defgeneric components-from-date-to-date-options)
(g:defgeneric components-in-time-zone-from-date)
(g:defgeneric components-to-display-for-path)
(g:defgeneric compound-predicate-type)
(g:defgeneric concurrent)
(g:defgeneric condition)
(g:defgeneric configuration)
(g:defgeneric conflict)
(g:defgeneric connect-end-date)
(g:defgeneric connect-start-date)
(g:defgeneric connection)
(g:defgeneric connection-for-proxy)
(g:defgeneric connection-proxy-dictionary)
(g:defgeneric constant)
(g:defgeneric constant-value)
(g:defgeneric constrained)
(g:defgeneric container-class-description)
(g:defgeneric container-is-object-being-tested)
(g:defgeneric container-is-range-container-object)
(g:defgeneric container-specifier)
(g:defgeneric container-url-for-security-application-group-identifier)
(g:defgeneric contains-date)
(g:defgeneric contains-index)
(g:defgeneric contains-indexes)
(g:defgeneric contains-indexes-in-range)
(g:defgeneric contains-object)
(g:defgeneric contains-value-for-key)
(g:defgeneric content-image)
(g:defgeneric contents-at-path)
(g:defgeneric contents-equal-at-path-and-path)
(g:defgeneric contents-of-directory-at-path-error)
(g:defgeneric contents-of-directory-at-url-including-properties-for-keys-options-error)
(g:defgeneric conversation)
(g:defgeneric converter)
(g:defgeneric cookie-accept-policy)
(g:defgeneric cookie-partition-identifier)
(g:defgeneric cookies)
(g:defgeneric cookies-for-url)
(g:defgeneric coordinate-access-with-intents-queue-by-accessor)
(g:defgeneric copy-item-at-path-to-path-error)
(g:defgeneric copy-item-at-url-to-url-error)
(g:defgeneric count)
(g:defgeneric count-for-object)
(g:defgeneric count-limit)
(g:defgeneric count-of-bytes-client-expects-to-receive)
(g:defgeneric count-of-bytes-client-expects-to-send)
(g:defgeneric count-of-bytes-expected-to-receive)
(g:defgeneric count-of-bytes-expected-to-send)
(g:defgeneric count-of-bytes-received)
(g:defgeneric count-of-bytes-sent)
(g:defgeneric count-of-indexes-in-range)
(g:defgeneric count-of-request-body-bytes-before-encoding)
(g:defgeneric count-of-request-body-bytes-sent)
(g:defgeneric count-of-request-header-bytes-sent)
(g:defgeneric count-of-response-body-bytes-after-decoding)
(g:defgeneric count-of-response-body-bytes-received)
(g:defgeneric count-of-response-header-bytes-received)
(g:defgeneric count-style)
(g:defgeneric country-code)
(g:defgeneric create-class-description)
(g:defgeneric create-command-instance)
(g:defgeneric create-directory-at-path-with-intermediate-directories-attributes-error)
(g:defgeneric create-directory-at-url-with-intermediate-directories-attributes-error)
(g:defgeneric create-file-at-path-contents-attributes)
(g:defgeneric create-symbolic-link-at-path-with-destination-path-error)
(g:defgeneric create-symbolic-link-at-url-with-destination-url-error)
(g:defgeneric credentials-for-protection-space)
(g:defgeneric currency-code)
(g:defgeneric currency-decimal-separator)
(g:defgeneric currency-grouping-separator)
(g:defgeneric currency-symbol)
(g:defgeneric current-apple-event)
(g:defgeneric current-directory-path)
(g:defgeneric current-directory-url)
(g:defgeneric current-disk-usage)
(g:defgeneric current-index)
(g:defgeneric current-memory-usage)
(g:defgeneric current-mode)
(g:defgeneric current-reply-apple-event)
(g:defgeneric current-request)
(g:defgeneric custom-mirror)
(g:defgeneric custom-playground-quick-look)
(g:defgeneric custom-selector)
(g:defgeneric data)
(g:defgeneric data-decoding-strategy)
(g:defgeneric data-encoding-strategy)
(g:defgeneric data-for-key)
(g:defgeneric data-representation)
(g:defgeneric data-task-with-request)
(g:defgeneric data-task-with-url)
(g:defgeneric date)
(g:defgeneric date-by-adding-components-to-date-options)
(g:defgeneric date-by-adding-unit-value-to-date-options)
(g:defgeneric date-by-setting-hour-minute-second-of-date-options)
(g:defgeneric date-by-setting-unit-value-of-date-options)
(g:defgeneric date-decoding-strategy)
(g:defgeneric date-encoding-strategy)
(g:defgeneric date-format)
(g:defgeneric date-from-components)
(g:defgeneric date-from-string)
(g:defgeneric date-matches-components)
(g:defgeneric date-style)
(g:defgeneric date-template)
(g:defgeneric date-time-style)
(g:defgeneric date-value)
(g:defgeneric date-with-era-year-for-week-of-year-week-of-year-weekday-hour-minute-second-nanosecond)
(g:defgeneric date-with-era-year-month-day-hour-minute-second-nanosecond)
(g:defgeneric day)
(g:defgeneric day-of-year)
(g:defgeneric daylight-saving-time)
(g:defgeneric daylight-saving-time-offset)
(g:defgeneric daylight-saving-time-offset-for-date)
(g:defgeneric dealloc)
(g:defgeneric debug-description)
(g:defgeneric decimal-number-by-adding)
(g:defgeneric decimal-number-by-adding-with-behavior)
(g:defgeneric decimal-number-by-dividing-by)
(g:defgeneric decimal-number-by-dividing-by-with-behavior)
(g:defgeneric decimal-number-by-multiplying-by)
(g:defgeneric decimal-number-by-multiplying-by-power-of10)
(g:defgeneric decimal-number-by-multiplying-by-power-of10-with-behavior)
(g:defgeneric decimal-number-by-multiplying-by-with-behavior)
(g:defgeneric decimal-number-by-raising-to-power)
(g:defgeneric decimal-number-by-raising-to-power-with-behavior)
(g:defgeneric decimal-number-by-rounding-according-to-behavior)
(g:defgeneric decimal-number-by-subtracting)
(g:defgeneric decimal-number-by-subtracting-with-behavior)
(g:defgeneric decimal-separator)
(g:defgeneric decode-bool-for-key)
(g:defgeneric decode-data-object)
(g:defgeneric decode-double-for-key)
(g:defgeneric decode-float-for-key)
(g:defgeneric decode-int-for-key)
(g:defgeneric decode-int32-for-key)
(g:defgeneric decode-int64-for-key)
(g:defgeneric decode-object-for-key)
(g:defgeneric decode-port-object)
(g:defgeneric decode-top-level-object)
(g:defgeneric decoding-failure-policy)
(g:defgeneric decomposed-string-with-canonical-mapping)
(g:defgeneric decomposed-string-with-compatibility-mapping)
(g:defgeneric default-credential-for-protection-space)
(g:defgeneric default-date)
(g:defgeneric default-name-server-port-number)
(g:defgeneric default-subcontainer-attribute-key)
(g:defgeneric definiteness)
(g:defgeneric delegate)
(g:defgeneric delegate-queue)
(g:defgeneric delete-cookie)
(g:defgeneric deletes-file-upon-failure)
(g:defgeneric deliver-notification)
(g:defgeneric delivered-notifications)
(g:defgeneric delivery-date)
(g:defgeneric delivery-repeat-interval)
(g:defgeneric delivery-time-zone)
(g:defgeneric dependencies)
(g:defgeneric dependent-morphology)
(g:defgeneric dequeue-notifications-matching-coalesce-mask)
(g:defgeneric description)
(g:defgeneric description-function)
(g:defgeneric description-in-strings-file-format)
(g:defgeneric description-with-locale)
(g:defgeneric descriptor)
(g:defgeneric descriptor-at-index)
(g:defgeneric descriptor-for-keyword)
(g:defgeneric descriptor-type)
(g:defgeneric destination-of-symbolic-link-at-path-error)
(g:defgeneric detach)
(g:defgeneric determination)
(g:defgeneric development-localization)
(g:defgeneric dictionary-for-key)
(g:defgeneric dictionary-representation)
(g:defgeneric difference-by-transforming-changes-with-block)
(g:defgeneric direct-parameter)
(g:defgeneric directory)
(g:defgeneric directory-attributes)
(g:defgeneric disable)
(g:defgeneric disable-automatic-termination)
(g:defgeneric disable-sudden-termination)
(g:defgeneric disable-undo-registration)
(g:defgeneric disable-updates)
(g:defgeneric discardable)
(g:defgeneric discretionary)
(g:defgeneric disk-capacity)
(g:defgeneric dispatch-with-components)
(g:defgeneric display-name-at-path!)
(g:defgeneric display-name-for-key-value!)
(g:defgeneric distinguished-names)
(g:defgeneric document-content-kind)
(g:defgeneric does-relative-date-formatting)
(g:defgeneric domain)
(g:defgeneric domain-lookup-end-date)
(g:defgeneric domain-lookup-start-date)
(g:defgeneric domain-resolution-protocol)
(g:defgeneric dominant-language)
(g:defgeneric dominant-script)
(g:defgeneric double-for-key)
(g:defgeneric double-value)
(g:defgeneric download-task-with-request)
(g:defgeneric download-task-with-resume-data)
(g:defgeneric download-task-with-url)
(g:defgeneric drain)
(g:defgeneric dtd)
(g:defgeneric dtd-kind)
(g:defgeneric duration)
(g:defgeneric earliest-begin-date)
(g:defgeneric edge-insets-value)
(g:defgeneric editing-string-for-object-value)
(g:defgeneric effective-group-identifier)
(g:defgeneric effective-user-identifier)
(g:defgeneric element-declaration-for-name)
(g:defgeneric elements-for-local-name-uri)
(g:defgeneric elements-for-name)
(g:defgeneric eligible-for-handoff)
(g:defgeneric eligible-for-public-indexing)
(g:defgeneric eligible-for-search)
(g:defgeneric enable)
(g:defgeneric enable-automatic-termination)
(g:defgeneric enable-multiple-threads)
(g:defgeneric enable-sudden-termination)
(g:defgeneric enable-undo-registration)
(g:defgeneric enable-updates)
(g:defgeneric enables-early-data)
(g:defgeneric encode-bool-for-key)
(g:defgeneric encode-class-name-into-class-name)
(g:defgeneric encode-conditional-object)
(g:defgeneric encode-conditional-object-for-key)
(g:defgeneric encode-data-object)
(g:defgeneric encode-double-for-key)
(g:defgeneric encode-float-for-key)
(g:defgeneric encode-int-for-key)
(g:defgeneric encode-int32-for-key)
(g:defgeneric encode-int64-for-key)
(g:defgeneric encode-object-for-key)
(g:defgeneric encode-port-object)
(g:defgeneric encode-root-object)
(g:defgeneric encode-xpc-object-for-key)
(g:defgeneric encoded-data)
(g:defgeneric encoded-host)
(g:defgeneric end-column)
(g:defgeneric end-column!)
(g:defgeneric end-date)
(g:defgeneric end-date!)
(g:defgeneric end-index)
(g:defgeneric end-line)
(g:defgeneric end-line!)
(g:defgeneric end-specifier)
(g:defgeneric end-specifier!)
(g:defgeneric end-subelement-identifier)
(g:defgeneric end-subelement-identifier!)
(g:defgeneric end-subelement-index)
(g:defgeneric end-subelement-index!)
(g:defgeneric end-undo-grouping!)
(g:defgeneric endpoint)
(g:defgeneric endpoint!)
(g:defgeneric enqueue-notification-posting-style)
(g:defgeneric enqueue-notification-posting-style-coalesce-mask-for-modes)
(g:defgeneric entity-declaration-for-name)
(g:defgeneric enum-code-value)
(g:defgeneric enumerate-dates-starting-after-date-matching-components-options-using-block)
(g:defgeneric enumerate-indexes-in-range-options-using-block)
(g:defgeneric enumerate-indexes-using-block)
(g:defgeneric enumerate-indexes-with-options-using-block)
(g:defgeneric enumerate-results-using-block)
(g:defgeneric enumerate-results-with-options-using-block)
(g:defgeneric enumerator-at-path)
(g:defgeneric enumerator-at-url-including-properties-for-keys-options-error-handler)
(g:defgeneric environment)
(g:defgeneric era)
(g:defgeneric era-symbols)
(g:defgeneric error)
(g:defgeneric estimated-time-remaining)
(g:defgeneric evaluate)
(g:defgeneric evaluate-with-object)
(g:defgeneric evaluate-with-object-substitution-variables)
(g:defgeneric evaluated-arguments)
(g:defgeneric evaluated-receivers)
(g:defgeneric evaluation-error-number)
(g:defgeneric evaluation-error-specifier)
(g:defgeneric event-class)
(g:defgeneric event-id)
(g:defgeneric evict-ubiquitous-item-at-url-error)
(g:defgeneric evicts-objects-with-discarded-content)
(g:defgeneric executable-architectures)
(g:defgeneric executable-path)
(g:defgeneric executable-url)
(g:defgeneric execute-command)
(g:defgeneric execute-with-apple-event-completion-handler)
(g:defgeneric execute-with-arguments-completion-handler)
(g:defgeneric execute-with-completion-handler)
(g:defgeneric execute-with-input-completion-handler)
(g:defgeneric executing)
(g:defgeneric execution-blocks)
(g:defgeneric exemplar-character-set)
(g:defgeneric expected-content-length)
(g:defgeneric expensive)
(g:defgeneric expiration-date)
(g:defgeneric expires-date)
(g:defgeneric exponent-symbol)
(g:defgeneric exported-interface)
(g:defgeneric exported-object)
(g:defgeneric expression-type)
(g:defgeneric expression-value-with-object-context)
(g:defgeneric external)
(g:defgeneric external-entity-resolving-policy)
(g:defgeneric failure-policy)
(g:defgeneric failure-response)
(g:defgeneric false-expression)
(g:defgeneric family-name)
(g:defgeneric fastest-encoding)
(g:defgeneric fetch-latest-remote-version-of-item-at-url-completion-handler)
(g:defgeneric fetch-start-date)
(g:defgeneric file-attributes)
(g:defgeneric file-completed-count)
(g:defgeneric file-descriptor)
(g:defgeneric file-exists-at-path)
(g:defgeneric file-handle-for-reading)
(g:defgeneric file-handle-for-writing)
(g:defgeneric file-operation-kind)
(g:defgeneric file-path-url)
(g:defgeneric file-reference-url)
(g:defgeneric file-system-representation)
(g:defgeneric file-system-representation-with-path)
(g:defgeneric file-total-count)
(g:defgeneric file-url)
(g:defgeneric file-url-value)
(g:defgeneric file-wrappers)
(g:defgeneric filename)
(g:defgeneric finalize)
(g:defgeneric finish-decoding)
(g:defgeneric finish-encoding)
(g:defgeneric finish-tasks-and-invalidate)
(g:defgeneric finished)
(g:defgeneric fire)
(g:defgeneric fire-date)
(g:defgeneric first-index)
(g:defgeneric first-object)
(g:defgeneric first-weekday)
(g:defgeneric float-for-key)
(g:defgeneric float-value)
(g:defgeneric flush-with-completion-handler)
(g:defgeneric for-food-energy-use)
(g:defgeneric for-person-height-use)
(g:defgeneric for-person-mass-use)
(g:defgeneric form-intersection-with-character-set)
(g:defgeneric form-union-with-character-set)
(g:defgeneric format)
(g:defgeneric format-options)
(g:defgeneric format-width)
(g:defgeneric formatter-behavior)
(g:defgeneric formatting-context)
(g:defgeneric forward-invocation)
(g:defgeneric fraction-completed)
(g:defgeneric fragment)
(g:defgeneric frame-length)
(g:defgeneric full-user-name)
(g:defgeneric function)
(g:defgeneric gathering)
(g:defgeneric generates-calendar-dates)
(g:defgeneric generates-decimal-numbers)
(g:defgeneric get-all-tasks-with-completion-handler)
(g:defgeneric get-argument-type-at-index)
(g:defgeneric get-continuation-streams-with-completion-handler)
(g:defgeneric get-file-provider-connection-with-completion-handler)
(g:defgeneric get-file-provider-services-for-item-at-url-completion-handler)
(g:defgeneric get-tasks-with-completion-handler)
(g:defgeneric given-name)
(g:defgeneric globally-unique-string)
(g:defgeneric grammar-details)
(g:defgeneric grammatical-case)
(g:defgeneric grammatical-gender)
(g:defgeneric grammatical-person)
(g:defgeneric gregorian-start-date)
(g:defgeneric grouped-results)
(g:defgeneric grouping-attributes)
(g:defgeneric grouping-level)
(g:defgeneric grouping-separator)
(g:defgeneric grouping-size)
(g:defgeneric groups-by-event)
(g:defgeneric has-action-button)
(g:defgeneric has-bytes-available)
(g:defgeneric has-changes)
(g:defgeneric has-directory-path)
(g:defgeneric has-item-conforming-to-type-identifier)
(g:defgeneric has-local-contents)
(g:defgeneric has-member-in-plane)
(g:defgeneric has-ordered-to-many-relationship-for-key)
(g:defgeneric has-password)
(g:defgeneric has-property-for-key)
(g:defgeneric has-readable-property-for-key)
(g:defgeneric has-reply-button)
(g:defgeneric has-representation-conforming-to-type-identifier-file-options)
(g:defgeneric has-space-available)
(g:defgeneric has-thousand-separators)
(g:defgeneric has-thumbnail)
(g:defgeneric has-writable-property-for-key)
(g:defgeneric hash)
(g:defgeneric hash-function)
(g:defgeneric header-level)
(g:defgeneric help-anchor)
(g:defgeneric home-directory-for-current-user)
(g:defgeneric host)
(g:defgeneric host-name)
(g:defgeneric hour)
(g:defgeneric http-additional-headers)
(g:defgeneric http-body)
(g:defgeneric http-body-stream)
(g:defgeneric http-cookie-accept-policy)
(g:defgeneric http-cookie-storage)
(g:defgeneric http-maximum-connections-per-host)
(g:defgeneric http-method)
(g:defgeneric http-only)
(g:defgeneric http-should-handle-cookies)
(g:defgeneric http-should-set-cookies)
(g:defgeneric http-should-use-pipelining)
(g:defgeneric i-os-app-on-mac)
(g:defgeneric i-os-app-on-vision)
(g:defgeneric identifier)
(g:defgeneric identity)
(g:defgeneric implementation-class-name)
(g:defgeneric includes-actual-byte-count)
(g:defgeneric includes-approximation-phrase)
(g:defgeneric includes-count)
(g:defgeneric includes-peer-to-peer)
(g:defgeneric includes-time-remaining-phrase)
(g:defgeneric includes-unit)
(g:defgeneric indentation-level)
(g:defgeneric independent-conversation-queueing)
(g:defgeneric indeterminate)
(g:defgeneric index)
(g:defgeneric index-at-position)
(g:defgeneric index-greater-than-index)
(g:defgeneric index-greater-than-or-equal-to-index)
(g:defgeneric index-in-range-options-passing-test)
(g:defgeneric index-less-than-index)
(g:defgeneric index-less-than-or-equal-to-index)
(g:defgeneric index-of-object)
(g:defgeneric index-of-result)
(g:defgeneric index-passing-test)
(g:defgeneric index-path-by-adding-index)
(g:defgeneric index-path-by-removing-last-index)
(g:defgeneric index-with-options-passing-test)
(g:defgeneric indexes-in-range-options-passing-test)
(g:defgeneric indexes-passing-test)
(g:defgeneric indexes-with-options-passing-test)
(g:defgeneric info-dictionary)
(g:defgeneric informative-text)
(g:defgeneric init-absolute-url-with-data-representation-relative-to-url)
(g:defgeneric init-and-test-with-tests)
(g:defgeneric init-directory-with-file-wrappers)
(g:defgeneric init-file-url-with-file-system-representation-is-directory-relative-to-url)
(g:defgeneric init-file-url-with-path)
(g:defgeneric init-file-url-with-path-is-directory)
(g:defgeneric init-file-url-with-path-is-directory-relative-to-url)
(g:defgeneric init-file-url-with-path-relative-to-url)
(g:defgeneric init-for-reading-from-data-error)
(g:defgeneric init-for-reading-with-data)
(g:defgeneric init-for-writing-with-mutable-data)
(g:defgeneric init-list-descriptor)
(g:defgeneric init-not-test-with-test)
(g:defgeneric init-or-test-with-tests)
(g:defgeneric init-record-descriptor)
(g:defgeneric init-regular-file-with-contents)
(g:defgeneric init-remote-with-protocol-family-socket-type-protocol-address)
(g:defgeneric init-remote-with-tcp-port-host)
(g:defgeneric init-requiring-secure-coding)
(g:defgeneric init-symbolic-link-with-destination-url)
(g:defgeneric init-to-memory)
(g:defgeneric input-items)
(g:defgeneric insert-child-at-index!)
(g:defgeneric insert-children-at-index!)
(g:defgeneric insert-descriptor-at-index!)
(g:defgeneric insert-object-at-index!)
(g:defgeneric insertion-container)
(g:defgeneric insertion-container!)
(g:defgeneric insertion-index)
(g:defgeneric insertion-index!)
(g:defgeneric insertion-key)
(g:defgeneric insertion-key!)
(g:defgeneric insertion-replaces)
(g:defgeneric insertion-replaces!)
(g:defgeneric insertions)
(g:defgeneric insertions!)
(g:defgeneric int-value)
(g:defgeneric int32-value)
(g:defgeneric integer-for-key)
(g:defgeneric integer-value)
(g:defgeneric intent-kind)
(g:defgeneric interface-for-selector-argument-index-of-reply)
(g:defgeneric international-currency-symbol)
(g:defgeneric interpreted-syntax)
(g:defgeneric interrupt)
(g:defgeneric intersect-hash-table)
(g:defgeneric intersection-with-date-interval)
(g:defgeneric intersects-date-interval)
(g:defgeneric intersects-hash-table)
(g:defgeneric intersects-indexes-in-range)
(g:defgeneric interval)
(g:defgeneric invalidate)
(g:defgeneric invalidate-and-cancel)
(g:defgeneric inverse-difference)
(g:defgeneric inverse-for-relationship-key)
(g:defgeneric invert)
(g:defgeneric inverted-set)
(g:defgeneric invocation)
(g:defgeneric invoke)
(g:defgeneric invoke-with-target)
(g:defgeneric is-adaptive)
(g:defgeneric is-asynchronous)
(g:defgeneric is-at-end)
(g:defgeneric is-bycopy)
(g:defgeneric is-byref)
(g:defgeneric is-cancellable)
(g:defgeneric is-cancelled)
(g:defgeneric is-cellular)
(g:defgeneric is-compiled)
(g:defgeneric is-concurrent)
(g:defgeneric is-conflict)
(g:defgeneric is-constrained)
(g:defgeneric is-date-equal-to-date-to-unit-granularity)
(g:defgeneric is-date-in-same-day-as-date)
(g:defgeneric is-date-in-today)
(g:defgeneric is-date-in-tomorrow)
(g:defgeneric is-date-in-weekend)
(g:defgeneric is-date-in-yesterday)
(g:defgeneric is-daylight-saving-time-for-date)
(g:defgeneric is-deletable-file-at-path)
(g:defgeneric is-directory)
(g:defgeneric is-discardable)
(g:defgeneric is-discretionary)
(g:defgeneric is-eligible-for-handoff)
(g:defgeneric is-eligible-for-public-indexing)
(g:defgeneric is-eligible-for-search)
(g:defgeneric is-enabled)
(g:defgeneric is-enumerating-directory-post-order)
(g:defgeneric is-equal-function)
(g:defgeneric is-equal-to-date-interval)
(g:defgeneric is-equal-to-hash-table)
(g:defgeneric is-equal-to-host)
(g:defgeneric is-equal-to-index-set)
(g:defgeneric is-equal-to-number)
(g:defgeneric is-equivalent-to-presentation-intent)
(g:defgeneric is-executable-file-at-path)
(g:defgeneric is-executing)
(g:defgeneric is-expensive)
(g:defgeneric is-external)
(g:defgeneric is-file-reference-url)
(g:defgeneric is-file-url)
(g:defgeneric is-finished)
(g:defgeneric is-for-food-energy-use)
(g:defgeneric is-for-person-height-use)
(g:defgeneric is-for-person-mass-use)
(g:defgeneric is-gathering)
(g:defgeneric is-http-only)
(g:defgeneric is-indeterminate)
(g:defgeneric is-leap-month)
(g:defgeneric is-lenient)
(g:defgeneric is-loaded)
(g:defgeneric is-location-required-to-create-for-key)
(g:defgeneric is-main-thread)
(g:defgeneric is-multipath)
(g:defgeneric is-old)
(g:defgeneric is-oneway)
(g:defgeneric is-optional-argument-with-name)
(g:defgeneric is-partial-string-validation-enabled)
(g:defgeneric is-pausable)
(g:defgeneric is-paused)
(g:defgeneric is-phonetic)
(g:defgeneric is-presented)
(g:defgeneric is-proxy)
(g:defgeneric is-proxy-connection)
(g:defgeneric is-readable-file-at-path)
(g:defgeneric is-ready)
(g:defgeneric is-record-descriptor)
(g:defgeneric is-redoing)
(g:defgeneric is-regular-file)
(g:defgeneric is-remote)
(g:defgeneric is-repeated-day)
(g:defgeneric is-resolved)
(g:defgeneric is-reused-connection)
(g:defgeneric is-running)
(g:defgeneric is-secure)
(g:defgeneric is-session-only)
(g:defgeneric is-standalone)
(g:defgeneric is-started)
(g:defgeneric is-stopped)
(g:defgeneric is-subset-of-hash-table)
(g:defgeneric is-superset-of-set)
(g:defgeneric is-suspended)
(g:defgeneric is-symbolic-link)
(g:defgeneric is-true)
(g:defgeneric is-ubiquitous-item-at-url)
(g:defgeneric is-undo-registration-enabled)
(g:defgeneric is-undoing)
(g:defgeneric is-valid)
(g:defgeneric is-valid-date)
(g:defgeneric is-valid-date-in-calendar)
(g:defgeneric is-well-formed)
(g:defgeneric is-word-in-user-dictionaries-case-sensitive)
(g:defgeneric is-writable-file-at-path)
(g:defgeneric item-at-url-did-change-ubiquity-attributes)
(g:defgeneric item-at-url-did-move-to-url)
(g:defgeneric item-at-url-will-move-to-url)
(g:defgeneric item-formatter)
(g:defgeneric key)
(g:defgeneric key-class-description)
(g:defgeneric key-decoding-strategy)
(g:defgeneric key-encoding-strategy)
(g:defgeneric key-enumerator)
(g:defgeneric key-for-file-wrapper)
(g:defgeneric key-path)
(g:defgeneric key-pointer-functions)
(g:defgeneric key-specifier)
(g:defgeneric key-with-apple-event-code)
(g:defgeneric keyword-for-descriptor-at-index)
(g:defgeneric keywords)
(g:defgeneric kind)
(g:defgeneric language-code)
(g:defgeneric language-hint)
(g:defgeneric language-identifier)
(g:defgeneric language-map)
(g:defgeneric last-index)
(g:defgeneric last-object)
(g:defgeneric last-path-component)
(g:defgeneric launch-and-return-error)
(g:defgeneric launch-path)
(g:defgeneric launch-requirement-data)
(g:defgeneric leap-month)
(g:defgeneric left-expression)
(g:defgeneric length)
(g:defgeneric lenient)
(g:defgeneric level)
(g:defgeneric levels-of-undo)
(g:defgeneric limit-date-for-mode)
(g:defgeneric line-number)
(g:defgeneric link-item-at-path-to-path-error)
(g:defgeneric link-item-at-url-to-url-error)
(g:defgeneric load)
(g:defgeneric load-and-return-error)
(g:defgeneric load-data-representation-for-type-identifier-completion-handler)
(g:defgeneric load-file-representation-for-type-identifier-completion-handler)
(g:defgeneric load-in-place-file-representation-for-type-identifier-completion-handler)
(g:defgeneric load-item-for-type-identifier-options-completion-handler)
(g:defgeneric load-object-of-class-completion-handler)
(g:defgeneric load-suite-with-dictionary-from-bundle)
(g:defgeneric load-suites-from-bundle)
(g:defgeneric loaded)
(g:defgeneric local-address)
(g:defgeneric local-name)
(g:defgeneric local-objects)
(g:defgeneric local-port)
(g:defgeneric locale)
(g:defgeneric locale-identifier)
(g:defgeneric localizations)
(g:defgeneric localized-additional-description)
(g:defgeneric localized-attributed-string-for-key-value-table)
(g:defgeneric localized-capitalized-string)
(g:defgeneric localized-description)
(g:defgeneric localized-failure-reason)
(g:defgeneric localized-info-dictionary)
(g:defgeneric localized-lowercase-string)
(g:defgeneric localized-name)
(g:defgeneric localized-name-of-saving-computer)
(g:defgeneric localized-recovery-options)
(g:defgeneric localized-recovery-suggestion)
(g:defgeneric localized-string-for-date-relative-to-date)
(g:defgeneric localized-string-for-key-value-table)
(g:defgeneric localized-string-for-key-value-table-localizations)
(g:defgeneric localized-string-from-date-components)
(g:defgeneric localized-string-from-time-interval)
(g:defgeneric localized-uppercase-string)
(g:defgeneric localizes-format)
(g:defgeneric lock-before-date)
(g:defgeneric lock-date)
(g:defgeneric lock-when-condition)
(g:defgeneric lock-when-condition-before-date)
(g:defgeneric long-character-is-member)
(g:defgeneric long-era-symbols)
(g:defgeneric long-long-for-key)
(g:defgeneric long-long-value)
(g:defgeneric long-value)
(g:defgeneric low-power-mode-enabled)
(g:defgeneric lowercase-string)
(g:defgeneric mac-catalyst-app)
(g:defgeneric mach-port)
(g:defgeneric main)
(g:defgeneric main-document-url)
(g:defgeneric make-iterator)
(g:defgeneric matches-apple-event-code)
(g:defgeneric matches-contents-of-url)
(g:defgeneric max-concurrent-operation-count)
(g:defgeneric maximum)
(g:defgeneric maximum-fraction-digits)
(g:defgeneric maximum-integer-digits)
(g:defgeneric maximum-message-size)
(g:defgeneric maximum-range-of-unit)
(g:defgeneric maximum-significant-digits)
(g:defgeneric maximum-unit-count)
(g:defgeneric measurement-by-adding-measurement)
(g:defgeneric measurement-by-converting-to-unit)
(g:defgeneric measurement-by-subtracting-measurement)
(g:defgeneric member)
(g:defgeneric memory-capacity)
(g:defgeneric method-return-length)
(g:defgeneric method-return-type)
(g:defgeneric method-signature)
(g:defgeneric method-signature-for-selector)
(g:defgeneric middle-name)
(g:defgeneric mime-type)
(g:defgeneric minimum)
(g:defgeneric minimum-days-in-first-week)
(g:defgeneric minimum-fraction-digits)
(g:defgeneric minimum-grouping-digits)
(g:defgeneric minimum-integer-digits)
(g:defgeneric minimum-range-of-unit)
(g:defgeneric minimum-significant-digits)
(g:defgeneric minimum-tolerance)
(g:defgeneric minus-hash-table)
(g:defgeneric minus-sign)
(g:defgeneric minute)
(g:defgeneric modification-date)
(g:defgeneric month)
(g:defgeneric month-symbols)
(g:defgeneric morphology)
(g:defgeneric mounted-volume-ur-ls-including-resource-values-for-keys-options)
(g:defgeneric move-item-at-path-to-path-error!)
(g:defgeneric move-item-at-url-to-url-error!)
(g:defgeneric msgid)
(g:defgeneric multipath)
(g:defgeneric multiple-threads-enabled)
(g:defgeneric multiplier)
(g:defgeneric mutable-bytes)
(g:defgeneric mutable-string)
(g:defgeneric name)
(g:defgeneric name-prefix)
(g:defgeneric name-suffix)
(g:defgeneric names)
(g:defgeneric namespace-for-prefix)
(g:defgeneric namespaces)
(g:defgeneric nanosecond)
(g:defgeneric needs-save)
(g:defgeneric negative-format)
(g:defgeneric negative-infinity-symbol)
(g:defgeneric negative-prefix)
(g:defgeneric negative-suffix)
(g:defgeneric negotiated-tls-cipher-suite)
(g:defgeneric negotiated-tls-protocol-version)
(g:defgeneric network-protocol-name)
(g:defgeneric network-service-type)
(g:defgeneric next-date-after-date-matching-components-options)
(g:defgeneric next-date-after-date-matching-hour-minute-second-options)
(g:defgeneric next-date-after-date-matching-unit-value-options)
(g:defgeneric next-daylight-saving-time-transition)
(g:defgeneric next-daylight-saving-time-transition-after-date)
(g:defgeneric next-node)
(g:defgeneric next-object)
(g:defgeneric next-sibling)
(g:defgeneric nickname)
(g:defgeneric nil-symbol)
(g:defgeneric nodes-for-x-path-error)
(g:defgeneric non-conforming-float-decoding-strategy)
(g:defgeneric non-conforming-float-encoding-strategy)
(g:defgeneric nonretained-object-value)
(g:defgeneric normalize-adjacent-text-nodes-preserving-cdata)
(g:defgeneric not-a-number-symbol)
(g:defgeneric notation-declaration-for-name)
(g:defgeneric notation-name)
(g:defgeneric notification-batching-interval)
(g:defgeneric now)
(g:defgeneric number)
(g:defgeneric number-formatter)
(g:defgeneric number-from-string)
(g:defgeneric number-of-arguments)
(g:defgeneric number-of-capture-groups)
(g:defgeneric number-of-items)
(g:defgeneric number-of-ranges)
(g:defgeneric number-style)
(g:defgeneric obj-c-type)
(g:defgeneric object)
(g:defgeneric object-at-index)
(g:defgeneric object-being-tested)
(g:defgeneric object-by-applying-xslt-arguments-error)
(g:defgeneric object-by-applying-xslt-at-url-arguments-error)
(g:defgeneric object-by-applying-xslt-string-arguments-error)
(g:defgeneric object-enumerator)
(g:defgeneric object-for-info-dictionary-key)
(g:defgeneric object-for-key)
(g:defgeneric object-form)
(g:defgeneric object-is-forced-for-key)
(g:defgeneric object-is-forced-for-key-in-domain)
(g:defgeneric object-specifier)
(g:defgeneric object-value)
(g:defgeneric objects-by-evaluating-specifier)
(g:defgeneric objects-by-evaluating-with-containers)
(g:defgeneric objects-for-x-query-constants-error)
(g:defgeneric objects-for-x-query-error)
(g:defgeneric offset)
(g:defgeneric offset-in-file)
(g:defgeneric old)
(g:defgeneric open)
(g:defgeneric open-url-completion-handler)
(g:defgeneric operand)
(g:defgeneric operating-system-version-string)
(g:defgeneric operation-count)
(g:defgeneric operation-queue)
(g:defgeneric operations)
(g:defgeneric options)
(g:defgeneric ordinal)
(g:defgeneric ordinality-of-unit-in-unit-for-date)
(g:defgeneric original-request)
(g:defgeneric originator-name-components)
(g:defgeneric orthography)
(g:defgeneric other-button-title)
(g:defgeneric output-format)
(g:defgeneric output-formatting)
(g:defgeneric padding-character)
(g:defgeneric padding-position)
(g:defgeneric param-descriptor-for-keyword)
(g:defgeneric parameter-string)
(g:defgeneric parent)
(g:defgeneric parent-intent)
(g:defgeneric parse)
(g:defgeneric parser-error)
(g:defgeneric part-of-speech)
(g:defgeneric partial-string-validation-enabled)
(g:defgeneric password)
(g:defgeneric path)
(g:defgeneric path-components)
(g:defgeneric path-extension)
(g:defgeneric path-for-auxiliary-executable)
(g:defgeneric path-for-resource-of-type)
(g:defgeneric path-for-resource-of-type-in-directory-for-localization)
(g:defgeneric paths-for-resources-of-type-in-directory-for-localization)
(g:defgeneric pattern)
(g:defgeneric pausable)
(g:defgeneric pause)
(g:defgeneric pause-sync-for-ubiquitous-item-at-url-completion-handler)
(g:defgeneric paused)
(g:defgeneric per-mill-symbol)
(g:defgeneric percent-encoded-fragment)
(g:defgeneric percent-encoded-host)
(g:defgeneric percent-encoded-password)
(g:defgeneric percent-encoded-path)
(g:defgeneric percent-encoded-query)
(g:defgeneric percent-encoded-query-items)
(g:defgeneric percent-encoded-user)
(g:defgeneric percent-symbol)
(g:defgeneric perform-as-current-with-pending-unit-count-using-block!)
(g:defgeneric perform-default-implementation!)
(g:defgeneric persistence)
(g:defgeneric persistent-domain-for-name)
(g:defgeneric persistent-identifier)
(g:defgeneric person-name-components-from-string)
(g:defgeneric phone-number)
(g:defgeneric phonetic)
(g:defgeneric phonetic-representation)
(g:defgeneric physical-memory)
(g:defgeneric plus-sign)
(g:defgeneric pm-symbol)
(g:defgeneric point-value)
(g:defgeneric pointer-functions)
(g:defgeneric pointer-value)
(g:defgeneric port)
(g:defgeneric port-for-name)
(g:defgeneric port-for-name-host)
(g:defgeneric port-for-name-host-name-server-port-number)
(g:defgeneric port-list)
(g:defgeneric position)
(g:defgeneric positive-format)
(g:defgeneric positive-infinity-symbol)
(g:defgeneric positive-prefix)
(g:defgeneric positive-suffix)
(g:defgeneric possessive-adjective-form)
(g:defgeneric possessive-form)
(g:defgeneric post-notification)
(g:defgeneric post-notification-name-object)
(g:defgeneric post-notification-name-object-user-info)
(g:defgeneric post-notification-name-object-user-info-deliver-immediately)
(g:defgeneric post-notification-name-object-user-info-options)
(g:defgeneric precomposed-string-with-canonical-mapping)
(g:defgeneric precomposed-string-with-compatibility-mapping)
(g:defgeneric predicate)
(g:defgeneric predicate-format)
(g:defgeneric predicate-operator-type)
(g:defgeneric predicate-with-substitution-variables)
(g:defgeneric preferred-filename)
(g:defgeneric preferred-localizations)
(g:defgeneric prefers-incremental-delivery)
(g:defgeneric prefix)
(g:defgeneric preflight-and-return-error)
(g:defgeneric prepare-with-invocation-target)
(g:defgeneric prepend-transform)
(g:defgeneric presented)
(g:defgeneric previous-failure-count)
(g:defgeneric previous-node)
(g:defgeneric previous-sibling)
(g:defgeneric principal-class)
(g:defgeneric priority)
(g:defgeneric private-frameworks-path)
(g:defgeneric private-frameworks-url)
(g:defgeneric process-identifier)
(g:defgeneric process-name)
(g:defgeneric processor-count)
(g:defgeneric progress)
(g:defgeneric pronoun)
(g:defgeneric pronoun-type)
(g:defgeneric pronouns)
(g:defgeneric properties)
(g:defgeneric property-for-key)
(g:defgeneric proposed-credential)
(g:defgeneric protection-space)
(g:defgeneric protocol)
(g:defgeneric protocol-classes)
(g:defgeneric protocol-family)
(g:defgeneric proxy-connection)
(g:defgeneric proxy-type)
(g:defgeneric public-id)
(g:defgeneric publish)
(g:defgeneric publish-with-options)
(g:defgeneric purpose-identifier)
(g:defgeneric quality-of-service)
(g:defgeneric quarter)
(g:defgeneric quarter-symbols)
(g:defgeneric query)
(g:defgeneric query-items)
(g:defgeneric queue-priority)
(g:defgeneric quotation-begin-delimiter)
(g:defgeneric quotation-end-delimiter)
(g:defgeneric raise)
(g:defgeneric range)
(g:defgeneric range-container-object)
(g:defgeneric range-in-string)
(g:defgeneric range-of-fragment)
(g:defgeneric range-of-host)
(g:defgeneric range-of-password)
(g:defgeneric range-of-path)
(g:defgeneric range-of-port)
(g:defgeneric range-of-query)
(g:defgeneric range-of-scheme)
(g:defgeneric range-of-unit-in-unit-for-date)
(g:defgeneric range-of-user)
(g:defgeneric range-value)
(g:defgeneric read-data-of-min-length-max-length-timeout-completion-handler)
(g:defgeneric read-data-to-end-of-file-and-return-error)
(g:defgeneric read-data-up-to-length-error)
(g:defgeneric read-from-url-options-error)
(g:defgeneric read-to-end)
(g:defgeneric ready)
(g:defgeneric realm)
(g:defgeneric reason)
(g:defgeneric receive)
(g:defgeneric receive-message-with-completion-handler)
(g:defgeneric receive-port)
(g:defgeneric receivers-specifier)
(g:defgeneric receives-credential-securely)
(g:defgeneric recovery-attempter)
(g:defgeneric rect-value)
(g:defgeneric redirect-count)
(g:defgeneric redo)
(g:defgeneric redo-action-is-discardable)
(g:defgeneric redo-action-name)
(g:defgeneric redo-action-user-info-value-for-key)
(g:defgeneric redo-count)
(g:defgeneric redo-menu-item-title)
(g:defgeneric redo-menu-title-for-undo-action-name)
(g:defgeneric redoing)
(g:defgeneric reference-date)
(g:defgeneric referrer-url)
(g:defgeneric reflexive-form)
(g:defgeneric region-code)
(g:defgeneric regions)
(g:defgeneric register-class-description)
(g:defgeneric register-coercer-selector-to-convert-from-class-to-class)
(g:defgeneric register-command-description)
(g:defgeneric register-data-representation-for-type-identifier-visibility-load-handler)
(g:defgeneric register-defaults)
(g:defgeneric register-file-representation-for-type-identifier-file-options-visibility-load-handler)
(g:defgeneric register-item-for-type-identifier-load-handler)
(g:defgeneric register-language-by-vendor)
(g:defgeneric register-name)
(g:defgeneric register-name-with-name-server)
(g:defgeneric register-object-of-class-visibility-load-handler)
(g:defgeneric register-object-visibility)
(g:defgeneric register-port-name)
(g:defgeneric register-port-name-name-server-port-number)
(g:defgeneric register-undo-with-target-handler)
(g:defgeneric register-undo-with-target-selector-object)
(g:defgeneric registered-type-identifiers)
(g:defgeneric registered-type-identifiers-with-file-options)
(g:defgeneric regular-expression)
(g:defgeneric regular-file)
(g:defgeneric regular-file-contents)
(g:defgeneric relative-path)
(g:defgeneric relative-position)
(g:defgeneric relative-string)
(g:defgeneric relinquish-function)
(g:defgeneric remote)
(g:defgeneric remote-address)
(g:defgeneric remote-object-interface)
(g:defgeneric remote-object-proxy)
(g:defgeneric remote-object-proxy-with-error-handler)
(g:defgeneric remote-objects)
(g:defgeneric remote-port)
(g:defgeneric removals)
(g:defgeneric remove-all-actions!)
(g:defgeneric remove-all-actions-with-target!)
(g:defgeneric remove-all-cached-resource-values!)
(g:defgeneric remove-all-cached-responses!)
(g:defgeneric remove-all-delivered-notifications!)
(g:defgeneric remove-all-indexes!)
(g:defgeneric remove-all-objects!)
(g:defgeneric remove-and-return-error!)
(g:defgeneric remove-attribute-for-name!)
(g:defgeneric remove-cached-resource-value-for-key!)
(g:defgeneric remove-cached-response-for-request!)
(g:defgeneric remove-cached-responses-since-date!)
(g:defgeneric remove-characters-in-range!)
(g:defgeneric remove-characters-in-string!)
(g:defgeneric remove-child-at-index!)
(g:defgeneric remove-cookies-since-date!)
(g:defgeneric remove-credential-for-protection-space!)
(g:defgeneric remove-credential-for-protection-space-options!)
(g:defgeneric remove-delivered-notification!)
(g:defgeneric remove-dependency!)
(g:defgeneric remove-descriptor-at-index!)
(g:defgeneric remove-descriptor-with-keyword!)
(g:defgeneric remove-event-handler-for-event-class-and-event-id!)
(g:defgeneric remove-file-wrapper!)
(g:defgeneric remove-from-run-loop-for-mode!)
(g:defgeneric remove-index!)
(g:defgeneric remove-indexes!)
(g:defgeneric remove-indexes-in-range!)
(g:defgeneric remove-item-at-path-error!)
(g:defgeneric remove-item-at-url-error!)
(g:defgeneric remove-last-object!)
(g:defgeneric remove-namespace-for-prefix!)
(g:defgeneric remove-object!)
(g:defgeneric remove-object-at-index!)
(g:defgeneric remove-object-for-key!)
(g:defgeneric remove-observer!)
(g:defgeneric remove-observer-name-object!)
(g:defgeneric remove-param-descriptor-with-keyword!)
(g:defgeneric remove-persistent-domain-for-name!)
(g:defgeneric remove-pointer-at-index!)
(g:defgeneric remove-port-for-mode!)
(g:defgeneric remove-port-for-name!)
(g:defgeneric remove-request-mode!)
(g:defgeneric remove-run-loop!)
(g:defgeneric remove-scheduled-notification!)
(g:defgeneric remove-suite-named!)
(g:defgeneric remove-volatile-domain-for-name!)
(g:defgeneric repeated-day)
(g:defgeneric repeats)
(g:defgeneric replace-characters-in-range-with-string!)
(g:defgeneric replace-child-at-index-with-node!)
(g:defgeneric replace-item-at-url-options-error!)
(g:defgeneric replace-object-at-index-with-object!)
(g:defgeneric replace-object-with-object!)
(g:defgeneric replacement-string)
(g:defgeneric reply-timeout)
(g:defgeneric reply-with-exception)
(g:defgeneric request)
(g:defgeneric request-cache-policy)
(g:defgeneric request-end-date)
(g:defgeneric request-modes)
(g:defgeneric request-start-date)
(g:defgeneric request-timeout)
(g:defgeneric required-user-info-keys)
(g:defgeneric requires-dnssec-validation)
(g:defgeneric requires-secure-coding)
(g:defgeneric reserved-space-length)
(g:defgeneric reset-with-completion-handler!)
(g:defgeneric resign-current)
(g:defgeneric resolve-namespace-for-name)
(g:defgeneric resolve-prefix-for-namespace-uri)
(g:defgeneric resolve-with-timeout)
(g:defgeneric resolved)
(g:defgeneric resolved-key-dictionary)
(g:defgeneric resource-fetch-type)
(g:defgeneric resource-path)
(g:defgeneric resource-specifier)
(g:defgeneric resource-url)
(g:defgeneric resource-values-for-keys-error)
(g:defgeneric response)
(g:defgeneric response-end-date)
(g:defgeneric response-placeholder)
(g:defgeneric response-start-date)
(g:defgeneric result)
(g:defgeneric result-at-index)
(g:defgeneric result-count)
(g:defgeneric result-type)
(g:defgeneric results)
(g:defgeneric resume)
(g:defgeneric resume-data)
(g:defgeneric resume-execution-with-result)
(g:defgeneric resume-sync-for-ubiquitous-item-at-url-with-behavior-completion-handler)
(g:defgeneric retain-arguments)
(g:defgeneric return-id)
(g:defgeneric return-type)
(g:defgeneric reused-connection)
(g:defgeneric reverse-transformed-value)
(g:defgeneric reversed-ordered-set)
(g:defgeneric reversed-sort-descriptor)
(g:defgeneric right-expression)
(g:defgeneric root-document)
(g:defgeneric root-element)
(g:defgeneric root-object)
(g:defgeneric root-proxy)
(g:defgeneric rotate-by-degrees)
(g:defgeneric rotate-by-radians)
(g:defgeneric rounding-behavior)
(g:defgeneric rounding-increment)
(g:defgeneric rounding-mode)
(g:defgeneric row)
(g:defgeneric run)
(g:defgeneric run-in-new-thread)
(g:defgeneric run-loop-modes)
(g:defgeneric running)
(g:defgeneric same-site-policy)
(g:defgeneric save-options)
(g:defgeneric scale-by)
(g:defgeneric scale-x-by-y-by)
(g:defgeneric scan-character)
(g:defgeneric scan-decimal)
(g:defgeneric scan-location)
(g:defgeneric schedule-in-run-loop-for-mode)
(g:defgeneric schedule-notification)
(g:defgeneric schedule-send-barrier-block)
(g:defgeneric schedule-with-block)
(g:defgeneric scheduled-notifications)
(g:defgeneric scheme)
(g:defgeneric script-code)
(g:defgeneric script-error-expected-type-descriptor)
(g:defgeneric script-error-number)
(g:defgeneric script-error-offending-object-descriptor)
(g:defgeneric script-error-string)
(g:defgeneric script-url)
(g:defgeneric search-for-browsable-domains)
(g:defgeneric search-for-registration-domains)
(g:defgeneric search-for-services-of-type-in-domain)
(g:defgeneric search-items)
(g:defgeneric search-scopes)
(g:defgeneric second)
(g:defgeneric secondary-grouping-size)
(g:defgeneric seconds-from-gmt)
(g:defgeneric seconds-from-gmt-for-date)
(g:defgeneric secure)
(g:defgeneric secure-connection-end-date)
(g:defgeneric secure-connection-start-date)
(g:defgeneric seek-to-end)
(g:defgeneric seek-to-offset-error)
(g:defgeneric selector)
(g:defgeneric selector-for-command)
(g:defgeneric send-before-date)
(g:defgeneric send-before-date-components-from-reserved)
(g:defgeneric send-before-date-msgid-components-from-reserved)
(g:defgeneric send-event-with-options-timeout-error)
(g:defgeneric send-message-completion-handler)
(g:defgeneric send-ping-with-pong-receive-handler)
(g:defgeneric send-port)
(g:defgeneric sender)
(g:defgeneric sentence-range-for-range)
(g:defgeneric serialized-representation)
(g:defgeneric server-trust)
(g:defgeneric service-name)
(g:defgeneric service-port-with-name)
(g:defgeneric session-description)
(g:defgeneric session-only)
(g:defgeneric session-sends-launch-events)
(g:defgeneric set)
(g:defgeneric set-acquire-function!)
(g:defgeneric set-action-button-title!)
(g:defgeneric set-action-is-discardable!)
(g:defgeneric set-action-name!)
(g:defgeneric set-action-user-info-value-for-key!)
(g:defgeneric set-adaptive!)
(g:defgeneric set-additional-actions!)
(g:defgeneric set-all-http-header-fields!)
(g:defgeneric set-allowed-external-entity-ur-ls!)
(g:defgeneric set-allowed-units!)
(g:defgeneric set-allows-cellular-access!)
(g:defgeneric set-allows-constrained-network-access!)
(g:defgeneric set-allows-expensive-network-access!)
(g:defgeneric set-allows-extended-attributes!)
(g:defgeneric set-allows-floats!)
(g:defgeneric set-allows-fractional-units!)
(g:defgeneric set-allows-json5!)
(g:defgeneric set-allows-nonnumeric-formatting!)
(g:defgeneric set-allows-persistent-dns!)
(g:defgeneric set-allows-ultra-constrained-network-access!)
(g:defgeneric set-always-shows-decimal-separator!)
(g:defgeneric set-am-symbol!)
(g:defgeneric set-applies-source-position-attributes!)
(g:defgeneric set-arguments!)
(g:defgeneric set-array-for-key!)
(g:defgeneric set-assumes-http3-capable!)
(g:defgeneric set-assumes-top-level-dictionary!)
(g:defgeneric set-attachments!)
(g:defgeneric set-attribute-descriptor-for-keyword!)
(g:defgeneric set-attributed-content-text!)
(g:defgeneric set-attributed-string-for-nil!)
(g:defgeneric set-attributed-string-for-not-a-number!)
(g:defgeneric set-attributed-string-for-zero!)
(g:defgeneric set-attributed-title!)
(g:defgeneric set-attributes!)
(g:defgeneric set-attributes-of-item-at-path-error!)
(g:defgeneric set-attributes-range!)
(g:defgeneric set-attributes-with-dictionary!)
(g:defgeneric set-attribution!)
(g:defgeneric set-automatic-termination-support-enabled!)
(g:defgeneric set-base-specifier!)
(g:defgeneric set-bool-for-key!)
(g:defgeneric set-cache-policy!)
(g:defgeneric set-calendar!)
(g:defgeneric set-cancellable!)
(g:defgeneric set-cancellation-handler!)
(g:defgeneric set-case-sensitive!)
(g:defgeneric set-character-encoding!)
(g:defgeneric set-characters-to-be-skipped!)
(g:defgeneric set-child-specifier!)
(g:defgeneric set-children!)
(g:defgeneric set-classes-for-selector-argument-index-of-reply!)
(g:defgeneric set-code-signing-requirement!)
(g:defgeneric set-collapses-largest-unit!)
(g:defgeneric set-completed-unit-count!)
(g:defgeneric set-completion-block!)
(g:defgeneric set-connection-code-signing-requirement!)
(g:defgeneric set-connection-proxy-dictionary!)
(g:defgeneric set-container-class-description!)
(g:defgeneric set-container-is-object-being-tested!)
(g:defgeneric set-container-is-range-container-object!)
(g:defgeneric set-container-specifier!)
(g:defgeneric set-content-image!)
(g:defgeneric set-cookie!)
(g:defgeneric set-cookie-accept-policy!)
(g:defgeneric set-cookie-partition-identifier!)
(g:defgeneric set-cookies-for-url-main-document-url!)
(g:defgeneric set-count!)
(g:defgeneric set-count-limit!)
(g:defgeneric set-count-of-bytes-client-expects-to-receive!)
(g:defgeneric set-count-of-bytes-client-expects-to-send!)
(g:defgeneric set-count-style!)
(g:defgeneric set-credential-for-protection-space!)
(g:defgeneric set-currency-code!)
(g:defgeneric set-currency-decimal-separator!)
(g:defgeneric set-currency-grouping-separator!)
(g:defgeneric set-currency-symbol!)
(g:defgeneric set-current-directory-path!)
(g:defgeneric set-current-directory-url!)
(g:defgeneric set-current-index!)
(g:defgeneric set-data-decoding-strategy!)
(g:defgeneric set-data-encoding-strategy!)
(g:defgeneric set-data-for-key!)
(g:defgeneric set-date-decoding-strategy!)
(g:defgeneric set-date-encoding-strategy!)
(g:defgeneric set-date-format!)
(g:defgeneric set-date-style!)
(g:defgeneric set-date-template!)
(g:defgeneric set-date-time-style!)
(g:defgeneric set-day!)
(g:defgeneric set-day-of-year!)
(g:defgeneric set-decimal-separator!)
(g:defgeneric set-decoding-failure-policy!)
(g:defgeneric set-default-credential-for-protection-space!)
(g:defgeneric set-default-date!)
(g:defgeneric set-default-name-server-port-number!)
(g:defgeneric set-definiteness!)
(g:defgeneric set-delegate!)
(g:defgeneric set-delegate-queue!)
(g:defgeneric set-deletes-file-upon-failure!)
(g:defgeneric set-delivery-date!)
(g:defgeneric set-delivery-repeat-interval!)
(g:defgeneric set-delivery-time-zone!)
(g:defgeneric set-description-function!)
(g:defgeneric set-descriptor-for-keyword!)
(g:defgeneric set-destination-allow-overwrite!)
(g:defgeneric set-determination!)
(g:defgeneric set-dictionary-for-key!)
(g:defgeneric set-direct-parameter!)
(g:defgeneric set-discardable!)
(g:defgeneric set-discretionary!)
(g:defgeneric set-disk-capacity!)
(g:defgeneric set-document-content-kind!)
(g:defgeneric set-does-relative-date-formatting!)
(g:defgeneric set-double-for-key!)
(g:defgeneric set-dtd!)
(g:defgeneric set-dtd-kind!)
(g:defgeneric set-earliest-begin-date!)
(g:defgeneric set-eligible-for-handoff!)
(g:defgeneric set-eligible-for-public-indexing!)
(g:defgeneric set-eligible-for-search!)
(g:defgeneric set-enables-early-data!)
(g:defgeneric set-encoded-host!)
(g:defgeneric set-end-specifier!)
(g:defgeneric set-end-subelement-identifier!)
(g:defgeneric set-end-subelement-index!)
(g:defgeneric set-environment!)
(g:defgeneric set-era!)
(g:defgeneric set-era-symbols!)
(g:defgeneric set-estimated-time-remaining!)
(g:defgeneric set-evaluation-error-number!)
(g:defgeneric set-event-handler-and-selector-for-event-class-and-event-id!)
(g:defgeneric set-evicts-objects-with-discarded-content!)
(g:defgeneric set-executable-url!)
(g:defgeneric set-expiration-date!)
(g:defgeneric set-exponent-symbol!)
(g:defgeneric set-exported-interface!)
(g:defgeneric set-exported-object!)
(g:defgeneric set-external-entity-resolving-policy!)
(g:defgeneric set-failure-policy!)
(g:defgeneric set-family-name!)
(g:defgeneric set-file-attributes!)
(g:defgeneric set-file-completed-count!)
(g:defgeneric set-file-operation-kind!)
(g:defgeneric set-file-total-count!)
(g:defgeneric set-file-url!)
(g:defgeneric set-filename!)
(g:defgeneric set-fire-date!)
(g:defgeneric set-first-weekday!)
(g:defgeneric set-float-for-key!)
(g:defgeneric set-for-food-energy-use!)
(g:defgeneric set-for-person-height-use!)
(g:defgeneric set-for-person-mass-use!)
(g:defgeneric set-format!)
(g:defgeneric set-format-options!)
(g:defgeneric set-format-width!)
(g:defgeneric set-formatter-behavior!)
(g:defgeneric set-formatting-context!)
(g:defgeneric set-fragment!)
(g:defgeneric set-generates-calendar-dates!)
(g:defgeneric set-generates-decimal-numbers!)
(g:defgeneric set-given-name!)
(g:defgeneric set-grammatical-case!)
(g:defgeneric set-grammatical-gender!)
(g:defgeneric set-grammatical-person!)
(g:defgeneric set-gregorian-start-date!)
(g:defgeneric set-grouping-attributes!)
(g:defgeneric set-grouping-separator!)
(g:defgeneric set-grouping-size!)
(g:defgeneric set-groups-by-event!)
(g:defgeneric set-has-action-button!)
(g:defgeneric set-has-reply-button!)
(g:defgeneric set-has-thousand-separators!)
(g:defgeneric set-hash-function!)
(g:defgeneric set-host!)
(g:defgeneric set-hour!)
(g:defgeneric set-http-additional-headers!)
(g:defgeneric set-http-body!)
(g:defgeneric set-http-body-stream!)
(g:defgeneric set-http-cookie-accept-policy!)
(g:defgeneric set-http-cookie-storage!)
(g:defgeneric set-http-maximum-connections-per-host!)
(g:defgeneric set-http-method!)
(g:defgeneric set-http-should-handle-cookies!)
(g:defgeneric set-http-should-set-cookies!)
(g:defgeneric set-http-should-use-pipelining!)
(g:defgeneric set-identifier!)
(g:defgeneric set-includes-actual-byte-count!)
(g:defgeneric set-includes-approximation-phrase!)
(g:defgeneric set-includes-count!)
(g:defgeneric set-includes-peer-to-peer!)
(g:defgeneric set-includes-time-remaining-phrase!)
(g:defgeneric set-includes-unit!)
(g:defgeneric set-independent-conversation-queueing!)
(g:defgeneric set-index!)
(g:defgeneric set-informative-text!)
(g:defgeneric set-insertion-class-description!)
(g:defgeneric set-integer-for-key!)
(g:defgeneric set-interface-for-selector-argument-index-of-reply!)
(g:defgeneric set-international-currency-symbol!)
(g:defgeneric set-interpreted-syntax!)
(g:defgeneric set-interruption-handler!)
(g:defgeneric set-interval!)
(g:defgeneric set-invalidation-handler!)
(g:defgeneric set-is-equal-function!)
(g:defgeneric set-item-formatter!)
(g:defgeneric set-key!)
(g:defgeneric set-key-decoding-strategy!)
(g:defgeneric set-key-encoding-strategy!)
(g:defgeneric set-keywords!)
(g:defgeneric set-kind!)
(g:defgeneric set-language-code!)
(g:defgeneric set-launch-path!)
(g:defgeneric set-launch-requirement-data!)
(g:defgeneric set-leap-month!)
(g:defgeneric set-length!)
(g:defgeneric set-lenient!)
(g:defgeneric set-levels-of-undo!)
(g:defgeneric set-locale!)
(g:defgeneric set-localized-additional-description!)
(g:defgeneric set-localized-date-format-from-template!)
(g:defgeneric set-localized-description!)
(g:defgeneric set-localizes-format!)
(g:defgeneric set-long-era-symbols!)
(g:defgeneric set-long-long-for-key!)
(g:defgeneric set-main-document-url!)
(g:defgeneric set-max-concurrent-operation-count!)
(g:defgeneric set-maximum!)
(g:defgeneric set-maximum-fraction-digits!)
(g:defgeneric set-maximum-integer-digits!)
(g:defgeneric set-maximum-message-size!)
(g:defgeneric set-maximum-significant-digits!)
(g:defgeneric set-maximum-unit-count!)
(g:defgeneric set-memory-capacity!)
(g:defgeneric set-middle-name!)
(g:defgeneric set-mime-type!)
(g:defgeneric set-minimum!)
(g:defgeneric set-minimum-days-in-first-week!)
(g:defgeneric set-minimum-fraction-digits!)
(g:defgeneric set-minimum-grouping-digits!)
(g:defgeneric set-minimum-integer-digits!)
(g:defgeneric set-minimum-significant-digits!)
(g:defgeneric set-minus-sign!)
(g:defgeneric set-minute!)
(g:defgeneric set-month!)
(g:defgeneric set-month-symbols!)
(g:defgeneric set-msgid!)
(g:defgeneric set-multiplier!)
(g:defgeneric set-name!)
(g:defgeneric set-name-prefix!)
(g:defgeneric set-name-suffix!)
(g:defgeneric set-namespaces!)
(g:defgeneric set-nanosecond!)
(g:defgeneric set-needs-save!)
(g:defgeneric set-negative-format!)
(g:defgeneric set-negative-infinity-symbol!)
(g:defgeneric set-negative-prefix!)
(g:defgeneric set-negative-suffix!)
(g:defgeneric set-network-service-type!)
(g:defgeneric set-nickname!)
(g:defgeneric set-nil-symbol!)
(g:defgeneric set-non-conforming-float-decoding-strategy!)
(g:defgeneric set-non-conforming-float-encoding-strategy!)
(g:defgeneric set-not-a-number-symbol!)
(g:defgeneric set-notation-name!)
(g:defgeneric set-notification-batching-interval!)
(g:defgeneric set-number!)
(g:defgeneric set-number-formatter!)
(g:defgeneric set-number-style!)
(g:defgeneric set-object-being-tested!)
(g:defgeneric set-object-for-key!)
(g:defgeneric set-object-for-key-cost!)
(g:defgeneric set-object-form!)
(g:defgeneric set-object-value!)
(g:defgeneric set-operation-queue!)
(g:defgeneric set-orthography-range!)
(g:defgeneric set-other-button-title!)
(g:defgeneric set-output-format!)
(g:defgeneric set-output-formatting!)
(g:defgeneric set-padding-character!)
(g:defgeneric set-padding-position!)
(g:defgeneric set-param-descriptor-for-keyword!)
(g:defgeneric set-part-of-speech!)
(g:defgeneric set-partial-string-validation-enabled!)
(g:defgeneric set-password!)
(g:defgeneric set-path!)
(g:defgeneric set-pausable!)
(g:defgeneric set-pausing-handler!)
(g:defgeneric set-per-mill-symbol!)
(g:defgeneric set-percent-encoded-fragment!)
(g:defgeneric set-percent-encoded-host!)
(g:defgeneric set-percent-encoded-password!)
(g:defgeneric set-percent-encoded-path!)
(g:defgeneric set-percent-encoded-query!)
(g:defgeneric set-percent-encoded-query-items!)
(g:defgeneric set-percent-encoded-user!)
(g:defgeneric set-percent-symbol!)
(g:defgeneric set-persistent-domain-for-name!)
(g:defgeneric set-persistent-identifier!)
(g:defgeneric set-phonetic!)
(g:defgeneric set-phonetic-representation!)
(g:defgeneric set-plus-sign!)
(g:defgeneric set-pm-symbol!)
(g:defgeneric set-port!)
(g:defgeneric set-positive-format!)
(g:defgeneric set-positive-infinity-symbol!)
(g:defgeneric set-positive-prefix!)
(g:defgeneric set-positive-suffix!)
(g:defgeneric set-possessive-adjective-form!)
(g:defgeneric set-possessive-form!)
(g:defgeneric set-predicate!)
(g:defgeneric set-preferred-filename!)
(g:defgeneric set-prefers-incremental-delivery!)
(g:defgeneric set-priority!)
(g:defgeneric set-process-name!)
(g:defgeneric set-pronoun-type!)
(g:defgeneric set-property-for-key!)
(g:defgeneric set-protocol!)
(g:defgeneric set-protocol-classes!)
(g:defgeneric set-protocol-for-proxy!)
(g:defgeneric set-public-id!)
(g:defgeneric set-purpose-identifier!)
(g:defgeneric set-quality-of-service!)
(g:defgeneric set-quarter!)
(g:defgeneric set-quarter-symbols!)
(g:defgeneric set-query!)
(g:defgeneric set-query-items!)
(g:defgeneric set-queue-priority!)
(g:defgeneric set-range-container-object!)
(g:defgeneric set-receivers-specifier!)
(g:defgeneric set-reference-date!)
(g:defgeneric set-referrer-url!)
(g:defgeneric set-reflexive-form!)
(g:defgeneric set-relative-position!)
(g:defgeneric set-relinquish-function!)
(g:defgeneric set-remote-object-interface!)
(g:defgeneric set-repeated-day!)
(g:defgeneric set-repeats!)
(g:defgeneric set-reply-timeout!)
(g:defgeneric set-representation)
(g:defgeneric set-representation!)
(g:defgeneric set-request-cache-policy!)
(g:defgeneric set-request-timeout!)
(g:defgeneric set-required-user-info-keys!)
(g:defgeneric set-requires-dnssec-validation!)
(g:defgeneric set-requires-secure-coding!)
(g:defgeneric set-resolved!)
(g:defgeneric set-resource-value-for-key-error!)
(g:defgeneric set-resource-values-error!)
(g:defgeneric set-response-placeholder!)
(g:defgeneric set-resuming-handler!)
(g:defgeneric set-root-element!)
(g:defgeneric set-root-object!)
(g:defgeneric set-rounding-behavior!)
(g:defgeneric set-rounding-increment!)
(g:defgeneric set-rounding-mode!)
(g:defgeneric set-run-loop-modes!)
(g:defgeneric set-scan-location!)
(g:defgeneric set-scheduled-notifications!)
(g:defgeneric set-scheme!)
(g:defgeneric set-script-error-expected-type-descriptor!)
(g:defgeneric set-script-error-number!)
(g:defgeneric set-script-error-offending-object-descriptor!)
(g:defgeneric set-script-error-string!)
(g:defgeneric set-search-items!)
(g:defgeneric set-search-scopes!)
(g:defgeneric set-second!)
(g:defgeneric set-secondary-grouping-size!)
(g:defgeneric set-selector!)
(g:defgeneric set-session-description!)
(g:defgeneric set-session-sends-launch-events!)
(g:defgeneric set-shared-container-identifier!)
(g:defgeneric set-short-month-symbols!)
(g:defgeneric set-short-quarter-symbols!)
(g:defgeneric set-short-standalone-month-symbols!)
(g:defgeneric set-short-standalone-quarter-symbols!)
(g:defgeneric set-short-standalone-weekday-symbols!)
(g:defgeneric set-short-weekday-symbols!)
(g:defgeneric set-should-process-namespaces!)
(g:defgeneric set-should-report-namespace-prefixes!)
(g:defgeneric set-should-resolve-external-entities!)
(g:defgeneric set-should-use-extended-background-idle-mode!)
(g:defgeneric set-size-function!)
(g:defgeneric set-sort-descriptors!)
(g:defgeneric set-sound-name!)
(g:defgeneric set-stack-size!)
(g:defgeneric set-standalone!)
(g:defgeneric set-standalone-month-symbols!)
(g:defgeneric set-standalone-quarter-symbols!)
(g:defgeneric set-standalone-weekday-symbols!)
(g:defgeneric set-standard-error!)
(g:defgeneric set-standard-input!)
(g:defgeneric set-standard-output!)
(g:defgeneric set-start-specifier!)
(g:defgeneric set-start-subelement-identifier!)
(g:defgeneric set-start-subelement-index!)
(g:defgeneric set-string!)
(g:defgeneric set-string-for-key!)
(g:defgeneric set-string-value!)
(g:defgeneric set-string-value-resolving-entities!)
(g:defgeneric set-style!)
(g:defgeneric set-subject-form!)
(g:defgeneric set-subtitle!)
(g:defgeneric set-suggested-name!)
(g:defgeneric set-supports-continuation-streams!)
(g:defgeneric set-suspended!)
(g:defgeneric set-system-id!)
(g:defgeneric set-target!)
(g:defgeneric set-target-content-identifier!)
(g:defgeneric set-task-description!)
(g:defgeneric set-temporary-resource-value-for-key!)
(g:defgeneric set-termination-handler!)
(g:defgeneric set-test!)
(g:defgeneric set-text-attributes-for-negative-infinity!)
(g:defgeneric set-text-attributes-for-negative-values!)
(g:defgeneric set-text-attributes-for-nil!)
(g:defgeneric set-text-attributes-for-not-a-number!)
(g:defgeneric set-text-attributes-for-positive-infinity!)
(g:defgeneric set-text-attributes-for-positive-values!)
(g:defgeneric set-text-attributes-for-zero!)
(g:defgeneric set-thousand-separator!)
(g:defgeneric set-thread-priority!)
(g:defgeneric set-throughput!)
(g:defgeneric set-time-style!)
(g:defgeneric set-time-zone!)
(g:defgeneric set-timeout-interval!)
(g:defgeneric set-timeout-interval-for-request!)
(g:defgeneric set-timeout-interval-for-resource!)
(g:defgeneric set-title!)
(g:defgeneric set-tls-maximum-supported-protocol!)
(g:defgeneric set-tls-maximum-supported-protocol-version!)
(g:defgeneric set-tls-minimum-supported-protocol!)
(g:defgeneric set-tls-minimum-supported-protocol-version!)
(g:defgeneric set-tolerance!)
(g:defgeneric set-top-level-object!)
(g:defgeneric set-total-cost-limit!)
(g:defgeneric set-total-unit-count!)
(g:defgeneric set-transform-struct!)
(g:defgeneric set-two-digit-start-date!)
(g:defgeneric set-txt-record-data!)
(g:defgeneric set-ubiquitous-item-at-url-destination-url-error!)
(g:defgeneric set-underlying-queue!)
(g:defgeneric set-unique-id!)
(g:defgeneric set-unit-options!)
(g:defgeneric set-unit-style!)
(g:defgeneric set-units-style!)
(g:defgeneric set-uri!)
(g:defgeneric set-url!)
(g:defgeneric set-url-cache!)
(g:defgeneric set-url-credential-storage!)
(g:defgeneric set-url-for-key!)
(g:defgeneric set-user!)
(g:defgeneric set-user-info!)
(g:defgeneric set-user-info-object-for-key!)
(g:defgeneric set-uses-classic-loading-mode!)
(g:defgeneric set-uses-grouping-separator!)
(g:defgeneric set-uses-significant-digits!)
(g:defgeneric set-uses-strong-write-barrier!)
(g:defgeneric set-uses-weak-read-and-write-barriers!)
(g:defgeneric set-value-for-component!)
(g:defgeneric set-value-list-attributes!)
(g:defgeneric set-variables!)
(g:defgeneric set-version!)
(g:defgeneric set-very-short-month-symbols!)
(g:defgeneric set-very-short-standalone-month-symbols!)
(g:defgeneric set-very-short-standalone-weekday-symbols!)
(g:defgeneric set-very-short-weekday-symbols!)
(g:defgeneric set-volatile-domain-for-name!)
(g:defgeneric set-waits-for-connectivity!)
(g:defgeneric set-webpage-url!)
(g:defgeneric set-week-of-month!)
(g:defgeneric set-week-of-year!)
(g:defgeneric set-weekday!)
(g:defgeneric set-weekday-ordinal!)
(g:defgeneric set-weekday-symbols!)
(g:defgeneric set-year!)
(g:defgeneric set-year-for-week-of-year!)
(g:defgeneric set-zero-formatting-behavior!)
(g:defgeneric set-zero-pads-fraction-digits!)
(g:defgeneric set-zero-symbol!)
(g:defgeneric shared-container-identifier)
(g:defgeneric shared-frameworks-path)
(g:defgeneric shared-frameworks-url)
(g:defgeneric shared-support-path)
(g:defgeneric shared-support-url)
(g:defgeneric shift-indexes-starting-at-index-by)
(g:defgeneric short-month-symbols)
(g:defgeneric short-quarter-symbols)
(g:defgeneric short-standalone-month-symbols)
(g:defgeneric short-standalone-quarter-symbols)
(g:defgeneric short-standalone-weekday-symbols)
(g:defgeneric short-value)
(g:defgeneric short-weekday-symbols)
(g:defgeneric should-defer)
(g:defgeneric should-process-namespaces)
(g:defgeneric should-report-namespace-prefixes)
(g:defgeneric should-resolve-external-entities)
(g:defgeneric should-use-extended-background-idle-mode)
(g:defgeneric signal)
(g:defgeneric size-function)
(g:defgeneric size-value)
(g:defgeneric skip-descendants)
(g:defgeneric skip-descendents)
(g:defgeneric smallest-encoding)
(g:defgeneric snapshot)
(g:defgeneric socket)
(g:defgeneric socket-type)
(g:defgeneric sort-descriptors)
(g:defgeneric sorted-array-hint)
(g:defgeneric sorted-cookies-using-descriptors)
(g:defgeneric sound-name)
(g:defgeneric source)
(g:defgeneric stack-size)
(g:defgeneric standalone)
(g:defgeneric standalone-month-symbols)
(g:defgeneric standalone-quarter-symbols)
(g:defgeneric standalone-weekday-symbols)
(g:defgeneric standard-error)
(g:defgeneric standard-input)
(g:defgeneric standard-output)
(g:defgeneric standardized-url)
(g:defgeneric start)
(g:defgeneric start-accessing-security-scoped-resource)
(g:defgeneric start-column)
(g:defgeneric start-date)
(g:defgeneric start-downloading-ubiquitous-item-at-url-error)
(g:defgeneric start-index)
(g:defgeneric start-line)
(g:defgeneric start-loading)
(g:defgeneric start-monitoring)
(g:defgeneric start-of-day-for-date)
(g:defgeneric start-query)
(g:defgeneric start-secure-connection)
(g:defgeneric start-specifier)
(g:defgeneric start-subelement-identifier)
(g:defgeneric start-subelement-index)
(g:defgeneric started)
(g:defgeneric state)
(g:defgeneric statistics)
(g:defgeneric status-code)
(g:defgeneric stop)
(g:defgeneric stop-accessing-security-scoped-resource)
(g:defgeneric stop-loading)
(g:defgeneric stop-monitoring)
(g:defgeneric stop-query)
(g:defgeneric stopped)
(g:defgeneric storage-policy)
(g:defgeneric store-cached-response-for-request)
(g:defgeneric stream-error)
(g:defgeneric stream-status)
(g:defgeneric stream-task-with-host-name-port)
(g:defgeneric stream-task-with-net-service)
(g:defgeneric string)
(g:defgeneric string-array-for-key)
(g:defgeneric string-by-abbreviating-with-tilde-in-path)
(g:defgeneric string-by-deleting-last-path-component)
(g:defgeneric string-by-deleting-path-extension)
(g:defgeneric string-by-expanding-tilde-in-path)
(g:defgeneric string-by-removing-percent-encoding)
(g:defgeneric string-by-resolving-symlinks-in-path)
(g:defgeneric string-by-standardizing-path)
(g:defgeneric string-edited-in-range-change-in-length)
(g:defgeneric string-for-key)
(g:defgeneric string-for-object-value)
(g:defgeneric string-from-byte-count)
(g:defgeneric string-from-date)
(g:defgeneric string-from-date-components)
(g:defgeneric string-from-date-interval)
(g:defgeneric string-from-date-to-date)
(g:defgeneric string-from-items)
(g:defgeneric string-from-joules)
(g:defgeneric string-from-kilograms)
(g:defgeneric string-from-measurement)
(g:defgeneric string-from-meters)
(g:defgeneric string-from-number)
(g:defgeneric string-from-person-name-components)
(g:defgeneric string-from-time-interval)
(g:defgeneric string-from-unit)
(g:defgeneric string-from-value-unit)
(g:defgeneric string-value)
(g:defgeneric string-with-file-system-representation-length)
(g:defgeneric style)
(g:defgeneric subgroups)
(g:defgeneric subject-form)
(g:defgeneric subpaths-at-path)
(g:defgeneric subpaths-of-directory-at-path-error)
(g:defgeneric subpredicates)
(g:defgeneric subtitle)
(g:defgeneric suggested-filename)
(g:defgeneric suggested-name)
(g:defgeneric suite-for-apple-event-code)
(g:defgeneric suite-name)
(g:defgeneric suite-names)
(g:defgeneric superclass-description)
(g:defgeneric supports-command)
(g:defgeneric supports-continuation-streams)
(g:defgeneric suspend)
(g:defgeneric suspend-execution)
(g:defgeneric suspended)
(g:defgeneric symbol)
(g:defgeneric symbolic-link)
(g:defgeneric symbolic-link-destination-url)
(g:defgeneric synchronize)
(g:defgeneric synchronize-and-return-error)
(g:defgeneric synchronous-remote-object-proxy-with-error-handler)
(g:defgeneric system-id)
(g:defgeneric system-uptime)
(g:defgeneric system-version)
(g:defgeneric tag-schemes)
(g:defgeneric target)
(g:defgeneric target-content-identifier)
(g:defgeneric task)
(g:defgeneric task-description)
(g:defgeneric task-identifier)
(g:defgeneric task-interval)
(g:defgeneric temporary-directory)
(g:defgeneric terminate)
(g:defgeneric termination-reason)
(g:defgeneric termination-status)
(g:defgeneric test)
(g:defgeneric text-attributes-for-negative-infinity)
(g:defgeneric text-attributes-for-negative-values)
(g:defgeneric text-attributes-for-nil)
(g:defgeneric text-attributes-for-not-a-number)
(g:defgeneric text-attributes-for-positive-infinity)
(g:defgeneric text-attributes-for-positive-values)
(g:defgeneric text-attributes-for-zero)
(g:defgeneric text-encoding-name)
(g:defgeneric thermal-state)
(g:defgeneric thousand-separator)
(g:defgeneric thread-dictionary)
(g:defgeneric thread-priority)
(g:defgeneric throughput)
(g:defgeneric time-interval)
(g:defgeneric time-interval-since-now)
(g:defgeneric time-interval-since-reference-date)
(g:defgeneric time-interval-since1970)
(g:defgeneric time-style)
(g:defgeneric time-zone)
(g:defgeneric timeout-interval)
(g:defgeneric timeout-interval-for-request)
(g:defgeneric timeout-interval-for-resource)
(g:defgeneric title)
(g:defgeneric tls-maximum-supported-protocol)
(g:defgeneric tls-maximum-supported-protocol-version)
(g:defgeneric tls-minimum-supported-protocol)
(g:defgeneric tls-minimum-supported-protocol-version)
(g:defgeneric to-many-relationship-keys)
(g:defgeneric to-one-relationship-keys)
(g:defgeneric token-range-at-index-unit)
(g:defgeneric tolerance)
(g:defgeneric top-level-object)
(g:defgeneric total-cost-limit)
(g:defgeneric total-unit-count)
(g:defgeneric transaction-id)
(g:defgeneric transaction-metrics)
(g:defgeneric transform-point)
(g:defgeneric transform-size)
(g:defgeneric transform-struct)
(g:defgeneric transformed-value)
(g:defgeneric translate-x-by-y-by)
(g:defgeneric true-expression)
(g:defgeneric truncate-at-offset-error)
(g:defgeneric try-lock)
(g:defgeneric try-lock-when-condition)
(g:defgeneric two-digit-start-date)
(g:defgeneric txt-record-data)
(g:defgeneric type)
(g:defgeneric type-code-value)
(g:defgeneric type-for-argument-with-name)
(g:defgeneric type-for-key)
(g:defgeneric ubiquity-identity-token)
(g:defgeneric underestimated-count)
(g:defgeneric underlying-errors)
(g:defgeneric underlying-queue)
(g:defgeneric undo)
(g:defgeneric undo-action-is-discardable)
(g:defgeneric undo-action-name)
(g:defgeneric undo-action-user-info-value-for-key)
(g:defgeneric undo-count)
(g:defgeneric undo-menu-item-title)
(g:defgeneric undo-menu-title-for-undo-action-name)
(g:defgeneric undo-nested-group)
(g:defgeneric undo-registration-enabled)
(g:defgeneric undoing)
(g:defgeneric union-hash-table)
(g:defgeneric unique-id)
(g:defgeneric unit)
(g:defgeneric unit-options)
(g:defgeneric unit-string-from-value-unit)
(g:defgeneric unit-style)
(g:defgeneric units-style)
(g:defgeneric unload)
(g:defgeneric unlock)
(g:defgeneric unlock-with-condition)
(g:defgeneric unmount-volume-at-url-options-completion-handler)
(g:defgeneric unpublish)
(g:defgeneric unschedule-from-run-loop-for-mode)
(g:defgeneric unsigned-char-value)
(g:defgeneric unsigned-int-value)
(g:defgeneric unsigned-integer-value)
(g:defgeneric unsigned-long-long-value)
(g:defgeneric unsigned-long-value)
(g:defgeneric unsigned-short-value)
(g:defgeneric unspecified)
(g:defgeneric upload-local-version-of-ubiquitous-item-at-url-with-conflict-resolution-policy-completion-handler)
(g:defgeneric upload-task-with-request-from-data)
(g:defgeneric upload-task-with-request-from-file)
(g:defgeneric upload-task-with-resume-data)
(g:defgeneric upload-task-with-streamed-request)
(g:defgeneric uppercase-string)
(g:defgeneric ur-ls-for-directory-in-domains)
(g:defgeneric ur-ls-for-resources-with-extension-subdirectory)
(g:defgeneric ur-ls-for-resources-with-extension-subdirectory-localization)
(g:defgeneric uri)
(g:defgeneric url)
(g:defgeneric url-by-deleting-last-path-component)
(g:defgeneric url-by-deleting-path-extension)
(g:defgeneric url-by-resolving-symlinks-in-path)
(g:defgeneric url-by-standardizing-path)
(g:defgeneric url-cache)
(g:defgeneric url-credential-storage)
(g:defgeneric url-for-auxiliary-executable)
(g:defgeneric url-for-directory-in-domain-appropriate-for-url-create-error)
(g:defgeneric url-for-key)
(g:defgeneric url-for-resource-with-extension)
(g:defgeneric url-for-resource-with-extension-subdirectory)
(g:defgeneric url-for-resource-with-extension-subdirectory-localization)
(g:defgeneric url-for-ubiquity-container-identifier)
(g:defgeneric url-relative-to-url)
(g:defgeneric user)
(g:defgeneric user-info)
(g:defgeneric user-name)
(g:defgeneric uses-classic-loading-mode)
(g:defgeneric uses-grouping-separator)
(g:defgeneric uses-metric-system)
(g:defgeneric uses-significant-digits)
(g:defgeneric uses-strong-write-barrier)
(g:defgeneric uses-weak-read-and-write-barriers)
(g:defgeneric utf8-string)
(g:defgeneric uuid-string)
(g:defgeneric valid)
(g:defgeneric valid-date)
(g:defgeneric validate-and-return-error)
(g:defgeneric value)
(g:defgeneric value-for-attribute)
(g:defgeneric value-for-component)
(g:defgeneric value-for-http-header-field)
(g:defgeneric value-from-base-unit-value)
(g:defgeneric value-list-attributes)
(g:defgeneric value-lists)
(g:defgeneric value-of-attribute-for-result-at-index)
(g:defgeneric value-pointer-functions)
(g:defgeneric values-for-attributes)
(g:defgeneric variable)
(g:defgeneric variables)
(g:defgeneric variant-code)
(g:defgeneric version)
(g:defgeneric version-for-class-name)
(g:defgeneric very-short-month-symbols)
(g:defgeneric very-short-standalone-month-symbols)
(g:defgeneric very-short-standalone-weekday-symbols)
(g:defgeneric very-short-weekday-symbols)
(g:defgeneric volatile-domain-for-name)
(g:defgeneric volatile-domain-names)
(g:defgeneric wait)
(g:defgeneric wait-until-all-operations-are-finished)
(g:defgeneric wait-until-date)
(g:defgeneric wait-until-finished)
(g:defgeneric waits-for-connectivity)
(g:defgeneric web-socket-task-with-request)
(g:defgeneric web-socket-task-with-url)
(g:defgeneric web-socket-task-with-url-protocols)
(g:defgeneric webpage-url)
(g:defgeneric week-of-month)
(g:defgeneric week-of-year)
(g:defgeneric weekday)
(g:defgeneric weekday-ordinal)
(g:defgeneric weekday-symbols)
(g:defgeneric well-formed)
(g:defgeneric write-data-error)
(g:defgeneric write-data-timeout-completion-handler)
(g:defgeneric write-to-url-options-original-contents-url-error)
(g:defgeneric x-path)
(g:defgeneric xml-data)
(g:defgeneric xml-data-with-options)
(g:defgeneric xml-string)
(g:defgeneric xml-string-with-options)
(g:defgeneric year)
(g:defgeneric year-for-week-of-year)
(g:defgeneric zero-formatting-behavior)
(g:defgeneric zero-pads-fraction-digits)
(g:defgeneric zero-symbol)
