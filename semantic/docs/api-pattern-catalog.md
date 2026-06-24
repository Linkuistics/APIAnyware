# API pattern-kind catalogue

This is the roster of **authored pattern-kinds** under
[`../pattern-kinds/`](../pattern-kinds/) — the first-class, framework- and
target-independent definitions of the recurring shapes found in macOS APIs. Each
kind is one `.apiw` file: a set of *roles* and *laws* (and, for behavioral kinds,
an *ordering*). For the model behind these — what roles, laws, and ordering mean
— read [`pattern-model.md`](pattern-model.md) first.

> **This supersedes the v1.0 "API Pattern Catalog."** That earlier document
> framed patterns as a **closed `PatternStereotype` enum** of 10 stereotypes and
> called itself "the contract between the analysis phase (which detects pattern
> instances) and the generation phase (which emits idiomatic bindings)." Both
> framings are retired (ADR-0048):
>
> - The 10 stereotypes are now an **open authored data registry**, not a closed
>   Rust enum — adding a kind is authoring a file. The roster below has grown to
>   16, including the §31 structural relationships that the enum could not
>   express, and folded the old "transaction bracket" stereotype into
>   `bracket`/`paired-state`.
> - "Analysis detects / generation emits" is replaced by the **kind/instance**
>   split (a kind is universal vocabulary in `semantic/`; an instance is macOS
>   knowledge in the platform triad) and the **three provenance tiers**
>   (convention / llm / manual). *Detection* is one tier, not the contract.
> - **Projection** (how a kind renders in a target language) is a *target*
>   concern (ws6), not catalogued here. The old "idiomatic translations" tables
>   have therefore been dropped from this document; this catalogue describes the
>   *meaning*, not its rendering.
>
> The **canonical macOS examples** from v1.0 survive below as *illustrations* of
> what a kind's instances look like — they are example instances, which formally
> live in `platforms/macos/api/<Framework>/resolved.json`, shown here only to
> make each kind concrete.

## The roster

| Kind | Class | Recurring shape |
|---|---|---|
| `bracket` | behavioral | acquire → operation\* → release; release runs even on failure |
| `builder` | behavioral | create mutable → configure\* → finalize (often copy-to-immutable) |
| `observer` | behavioral | register → callback\* → unregister |
| `delegate` | behavioral | set a delegate conforming to a protocol; it receives callbacks |
| `target-action` | behavioral | a control sends an action to a (weakly held) target |
| `paired-state` | behavioral | two complementary ops toggle a state (lock/unlock, begin/end) |
| `factory-cluster` | behavioral | factory ops select an opaque concrete subclass |
| `enumeration` | behavioral | a container exposes block/iterator element traversal |
| `error-out` | behavioral | trailing error out-param, valid only on failure |
| `two-call-sizing` | behavioral | size call → allocate → data call |
| `buffer-fill` | behavioral | caller provides a buffer; callee fills it, no transfer |
| `typestate` | behavioral | object moves through states; ops valid only in some |
| `subscription` | hybrid | register returns a lifetime-controlling token; teardown may ref a relationship |
| `parent-child` | structural | an ownership edge between two object types |
| `callback-destroy-notifier` | structural | callback + user-data + destroy-notifier on one operation |
| `collection-element-ownership` | structural | a collection owns/borrows its element type |

The `binds` of each role places a kind on the behavioral↔structural spectrum:
operation-roles + ordering ⇒ behavioral; type-/parameter-roles + ownership laws,
no ordering ⇒ structural (a §31 relationship); a mix ⇒ hybrid.

---

## Behavioral kinds

### `bracket` — resource lifecycle

Acquire a resource, operate on it, then release it; the release runs even when an
operation fails (bracket totality).

- **Roles:** `acquire` (op, 1) → `operation` (op, \*) → `release` (op, 1).
- **Laws:** `error: cleanup-required-after-partial-failure`;
  `lifetime: scope-lifetime`.

| Framework | acquire | operation\* | release |
|---|---|---|---|
| CoreGraphics | `CGPathCreateMutable()` | `CGPathMoveToPoint`, `CGPathAddLineToPoint`, `CGPathAddArc` | `CGPathRelease()` |
| CoreGraphics | `CGContextSaveGState()` | drawing operations | `CGContextRestoreGState()` |
| Foundation | `beginEditing()` | `addAttribute:`, `replaceCharacters:` | `endEditing()` |
| CoreFoundation | `CFReadStreamOpen()` | `CFReadStreamRead()` | `CFReadStreamClose()` |

The v1.0 "transaction bracket" stereotype (`CATransaction.begin`/`commit`,
`beginGrouping`/`endGrouping`) is a `bracket` (or `paired-state`) instance, not a
separate kind.

### `builder` — configure-then-finalize

Create a mutable object, configure it through a sequence of setters, then
finalize it (often by copying to an immutable form).

- **Roles:** `create` (op, 1) → `configure` (op, \*) → `finalize` (op, ?).
- **Laws:** `threading: thread-confined` (the mutable builder is not thread-safe
  while configured).

| Framework | create | configure\* | finalize |
|---|---|---|---|
| Foundation | `NSMutableURLRequest(url:)` | `setHTTPMethod:`, `setValue:forHTTPHeaderField:` | `copy` → `NSURLRequest` |
| Foundation | `NSMutableParagraphStyle()` | `setAlignment:`, `setLineSpacing:` | `copy` → `NSParagraphStyle` |

### `observer` — register / callback / unregister

Register an observer for notifications, receive callbacks, then unregister to
avoid leaks or dangling references; every register is balanced by an unregister.

- **Roles:** `subject` (type, 1), `register` (op, 1) → `callback` (op, \*) →
  `unregister` (op, 1).
- **Laws:** `relationship: observer-strongly-retained`;
  `threading: callback-thread-unspecified`.

| Framework | register | callback | unregister |
|---|---|---|---|
| Foundation | `addObserver:selector:name:object:` | selector callbacks | `removeObserver:` |
| Foundation | `addObserverForName:object:queue:usingBlock:` | block invocations | `removeObserver:` (token) |
| Foundation (KVO) | `addObserver:forKeyPath:options:context:` | `observeValueForKeyPath:…` | `removeObserver:forKeyPath:` |

### `delegate` — protocol delegation

An object delegates behavior decisions to a separate delegate object conforming
to a protocol; the delegate is weakly held.

- **Roles:** `delegator` (type, 1), `protocol` (type, 1), `set-delegate` (op, 1),
  `callback` (op, \*).
- **Laws:** `relationship: delegate-weakly-held`.

| Framework | delegator | protocol | key callbacks |
|---|---|---|---|
| AppKit | `NSWindow` | `NSWindowDelegate` | `windowShouldClose:`, `windowWillResize:toSize:` |
| AppKit | `NSTableView` | `NSTableViewDataSource` | `numberOfRowsInTableView:` |
| Foundation | `NSURLSession` | `NSURLSessionDelegate` | `URLSession:didBecomeInvalidWithError:` |

### `target-action` — control sends action to target

A control sends an action message to a target object when triggered; the target
is held weakly, and a nil target sends the action up the responder chain.

- **Roles:** `control` (type, 1), `target` (type, 1), `set-target` (op, 1),
  `set-action` (op, 1).
- **Laws:** `ownership: weak`.

| Framework | control | set-target / set-action |
|---|---|---|
| AppKit | `NSButton`, `NSMenuItem`, `NSControl`, `NSGestureRecognizer` | `target` / `action` |

### `paired-state` — complementary toggle

Two complementary operations toggle a binary state (lock/unlock, show/hide,
begin/end); the scoped form restores the state even on failure.

- **Roles:** `enter` (op, 1) → `exit` (op, 1).
- **Laws:** `error: cleanup-required-after-partial-failure`.

| Framework | enter | exit |
|---|---|---|
| Foundation | `NSLock.lock()` | `unlock()` |
| Foundation | `beginActivity(options:reason:)` | `endActivity(_:)` |
| AppKit | `NSCursor.hide()` | `unhide()` |
| Foundation (KVO) | `willChangeValue(forKey:)` | `didChangeValue(forKey:)` |

### `factory-cluster` — class cluster

A class cluster hides private concrete subclasses behind a public abstract
superclass; factory operations select the concrete class.

- **Roles:** `abstract-type` (type, 1), `factory` (op, +), `concrete-type`
  (type, \*).
- **Laws:** `ownership: conditional-transfer` (retained/autoreleased per Cocoa
  naming; the concrete class is opaque — never named in a binding).

| Framework | abstract-type | factory ops |
|---|---|---|
| Foundation | `NSNumber` | `numberWithInt:`, `numberWithBool:` |
| Foundation | `NSString` | `stringWithFormat:`, `stringWithUTF8String:` |
| Foundation | `NSArray` | `arrayWithObjects:count:` |

### `enumeration` — element traversal

A container exposes a block- or iterator-based interface for processing its
elements; the block is invoked synchronously during iteration.

- **Roles:** `container` (type, 1), `enumerate` (op, 1), `element` (type, ?).
- **Laws:** `callback: synchronous-callback`;
  `relationship: iterator-invalidated-by-mutation`.

| Framework | container | enumerate |
|---|---|---|
| Foundation | `NSArray` | `enumerateObjectsUsingBlock:` |
| Foundation | `NSDictionary` | `enumerateKeysAndObjectsUsingBlock:` |
| Foundation | `NSIndexSet` | `enumerateIndexesUsingBlock:` |

### `error-out` — trailing error out-parameter

An operation takes a trailing error out-parameter and signals failure by its
return value; the out-error is valid only on failure.

- **Roles:** `operation` (op, 1), `error-param` (parameter, 1).
- **Laws:** `error: nserror-out-param, out-error-valid-only-when-failure`.

| Framework | operation | failure indicator |
|---|---|---|
| Foundation | `contentsOfDirectoryAtPath:error:` | `nil` |
| Foundation | `JSONObjectWithData:options:error:` | `nil` |
| Foundation | `writeToFile:atomically:encoding:error:` | `NO` |

### `two-call-sizing` — size then fill

A first call reports the required buffer size, the caller allocates, and a second
call fills the buffer.

- **Roles:** `size-call` (op, 1) → `data-call` (op, 1), `buffer` (parameter, 1).
- **Laws:** `buffer: two-call-sizing-pattern, caller-provides-buffer,
  callee-writes-required-size`.

Common in CoreFoundation/Carbon-era C APIs that return a length on a first call
(`…GetBytes` with a null buffer) before the caller allocates and calls again.

### `buffer-fill` — caller-provided buffer

The caller provides a buffer and the callee fills it; the written length may be
reported separately, and ownership of the buffer never transfers.

- **Roles:** `operation` (op, 1), `buffer` (parameter, 1).
- **Laws:** `buffer: caller-provides-buffer, callee-fills-buffer`.

### `typestate` — state-gated operations

An object moves through a sequence of states; operations are valid only in
particular states and drive transitions between them. A transition may invalidate
the prior state.

- **Roles:** `state` (type, +), `transition` (op, +).
- **Laws:** `lifetime: until-object-invalidation`.

---

## Hybrid kinds

### `subscription` — token-controlled lifetime, composing a relationship

Registering returns a token whose lifetime controls the subscription; tearing
down may *reference* a `callback-destroy-notifier` relationship-instance. The
`destroy` role binds to **another pattern** — the composition case (ADR-0048 D5,
§32's "compose operations *plus relationships*").

- **Roles:** `register` (op, 1), `token` (type, ?), `destroy` (pattern, ?).
- **Laws:** `relationship: subscription-token-controls-lifetime`;
  `callback: callback-lifetime-tied-to-subscription-token`.

| Framework | register | token |
|---|---|---|
| Foundation | `addObserverForName:object:queue:usingBlock:` | the returned opaque observer token |
| AppKit | `addLocalMonitorForEventsMatchingMask:handler:` | the returned monitor object |

---

## Structural kinds (§31 relationships)

A relationship is the **degenerate pattern-kind**: typed roles + ownership /
lifetime / invalidation laws, no operation sequence. Each marks a `primary` role,
which determines the cross-framework home of an instance (ADR-0048 DP3).

### `parent-child` — ownership edge

An ownership edge between two object types: a parent and a child it contains.

- **Roles:** `parent` (type, 1, **primary**), `child` (type, 1).
- **Laws:** `relationship: parent-owns-child, child-borrows-parent` (the parent
  strongly retains the child; the child references the parent weakly; removing
  the child ends the relationship — instances may override the direction).

| Framework | parent | child |
|---|---|---|
| AppKit | `NSView` | subview `NSView` |
| AppKit | `NSWindow` | `contentView` |

### `callback-destroy-notifier` — single-operation lifetime relationship

A single registration operation takes a callback, a user-data pointer, and a
destroy-notifier; the user data is valid until the destroy-notifier is called.
All three roles bind to **parameters of one operation** — the doubt-pass DP2
case, a relationship scoped to a single call.

- **Roles:** `callback` (parameter, 1), `user-data` (parameter, 1), `destroy`
  (parameter, 1).
- **Laws:** `callback: callback-with-destroy-notifier,
  callback-with-user-data-pointer`; `lifetime: until-object-invalidation`.

Common in CoreFoundation/C callback registration that accepts a context pointer
and a release callback (`CFAllocatorContext`-style `(info, retain, release)`
trios, `CGDataProvider` callbacks).

### `collection-element-ownership` — container/element ownership

A collection type owns or borrows its element type; element lifetime may be tied
to the collection.

- **Roles:** `collection` (type, 1, **primary**), `element` (type, 1).
- **Laws:** `relationship: collection-owns-elements,
  element-lifetime-tied-to-collection` (instances may switch to borrowed
  elements).

| Framework | collection | element |
|---|---|---|
| Foundation | `NSArray` | its objects |
| Foundation | `NSDictionary` | its values |

---

## How instances of these kinds arise

A *kind* above is universal; a concrete *instance* (CGPath's `bracket`,
`NSView`'s `parent-child`) is detected or authored into
`platforms/macos/api/<Framework>/resolved.json` by one of three provenance tiers,
resolved `manual > llm > convention > extraction`:

- **convention** — `ascent` datalog over the extracted facts
  ([`apianyware-pattern-detection`](../../platforms/macos/tools/pattern-detection));
  five detectors (factory-cluster, observer, paired-state, delegate, bracket)
  currently bind these kinds' roles and stamp `source=convention:<rule>`.
- **llm** — guide-derived, for what naming conventions cannot reveal.
- **manual** — an authored override in `annotations.apiw`.

See [`overview.md`](overview.md) for the tiers and the kind/instance split, and
[`pattern-model.md`](pattern-model.md) for the role/law/ordering model. How any
of these projects into a target language is ws6's concern, not this catalogue's.
