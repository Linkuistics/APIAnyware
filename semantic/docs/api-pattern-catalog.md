# API Pattern Catalog

Version: 1.0
Last updated: 2026-03-26

This catalog documents the stereotypical multi-method behavioral contracts found in macOS frameworks. Each stereotype describes a recurring pattern of cooperating API calls, the constraints that govern them, and how emitters should translate them into idiomatic target-language constructs.

The catalog is the contract between the analysis phase (which detects pattern instances) and the generation phase (which emits idiomatic bindings).

## Stereotypes

### 1. Resource Lifecycle

**Shape:** open/create -> use/operate* -> close/release

A resource is acquired, used through a sequence of operations, and then released. The caller owns the resource between open and close. Failing to close leaks the resource.

**Detection rules:**
- Heuristic: `Create`/`Release` function pairs with matching type prefixes (e.g., `CGPathCreateMutable`/`CGPathRelease`)
- Heuristic: `begin`/`end` method pairs on the same class (e.g., `beginEditing`/`endEditing`)
- LLM: Programming guides describe the create-use-release lifecycle

**Canonical macOS examples:**

| Framework | Open | Operations | Close | Guide |
|---|---|---|---|---|
| CoreGraphics | `CGPathCreateMutable()` | `CGPathMoveToPoint`, `CGPathAddLineToPoint`, `CGPathAddArc`, `CGPathCloseSubpath` | `CGPathRelease()` | Quartz 2D Programming Guide > Paths |
| CoreGraphics | `CGContextSaveGState()` | drawing operations | `CGContextRestoreGState()` | Quartz 2D Programming Guide > Graphics States |
| CoreGraphics | `CGContextBeginPath()` | `CGContextMoveToPoint`, `CGContextAddLineToPoint` | `CGContextStrokePath()`/`CGContextFillPath()` | Quartz 2D Programming Guide > Paths |
| Foundation | `NSMutableAttributedString.beginEditing()` | `addAttribute:`, `replaceCharacters:` | `endEditing()` | Attributed String Programming Guide |
| CoreFoundation | `CFReadStreamOpen()` | `CFReadStreamRead()` | `CFReadStreamClose()` | CFNetwork Programming Guide |

**Constraints:**
- Ordering: open must precede all operations; close must follow all operations
- Thread safety: typically not thread-safe; all calls must be on same thread
- Ownership: caller owns the resource from open to close
- Error handling: close must be called even if operations fail (bracket semantics)

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | `with-*` macro | `(with-path p (move-to p 0 0) (line-to p 100 100))` |
| Haskell | `bracket` | `withCGPath $ \p -> moveTo p 0 0 >> lineTo p 100 100` |
| Zig | RAII-like `defer` | `const path = CGPathCreateMutable(); defer CGPathRelease(path);` |
| Smalltalk | `ensure:` block | `path := CGPath createMutable. [path moveTo: 0@0] ensure: [path release]` |
| OCaml | `Fun.protect` | `Fun.protect ~finally:(fun () -> release path) (fun () -> move_to path 0 0)` |

---

### 2. Builder Sequence

**Shape:** create mutable -> configure* -> finalize/copy to immutable

A mutable object is created, configured through a series of setter calls, and then either used directly or copied to an immutable version.

**Detection rules:**
- Heuristic: `NSMutable*`/`NS*` class pairs (mutable variant has extra setters)
- Heuristic: class has many `set*:` methods and a `copy` method
- LLM: Documentation shows step-by-step configuration patterns

**Canonical macOS examples:**

| Framework | Create | Configure | Finalize | Guide |
|---|---|---|---|---|
| Foundation | `NSMutableURLRequest(url:)` | `setHTTPMethod:`, `setValue:forHTTPHeaderField:`, `setHTTPBody:` | `copy` -> `NSURLRequest` | URL Loading System Programming Guide |
| Foundation | `NSMutableParagraphStyle()` | `setAlignment:`, `setLineSpacing:`, `setFirstLineHeadIndent:` | `copy` -> `NSParagraphStyle` | Text System Overview |
| AppKit | `NSMutableAttributedString(string:)` | `addAttribute:value:range:`, `setAttributes:range:` | use directly or `copy` | Attributed String Programming Guide |

**Constraints:**
- Ordering: create before configure; finalize after all configuration
- Thread safety: mutable objects are typically not thread-safe during configuration
- Ownership: mutable builder is temporary; final product may outlive it

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | `let`-pipeline or builder DSL | `(url-request url #:method "POST" #:headers '(("Content-Type" . "json")))` |
| Haskell | builder pattern with record syntax | `defaultRequest & method .~ "POST" & header "Content-Type" .~ "json"` |
| OCaml | builder module with `|>` | `Request.create url |> Request.method "POST" |> Request.header "Content-Type" "json"` |

---

### 3. Observer Pair

**Shape:** register observer -> (callbacks)* -> unregister observer

An observer is registered for notifications, receives callbacks, and must eventually be unregistered to avoid leaks or dangling references.

**Detection rules:**
- Heuristic: `addObserver:`/`removeObserver:` method pairs
- Heuristic: `addObserverForName:object:queue:usingBlock:` returning a token for removal
- LLM: KVO Programming Guide, NSNotificationCenter documentation

**Canonical macOS examples:**

| Framework | Register | Callbacks | Unregister | Guide |
|---|---|---|---|---|
| Foundation | `NSNotificationCenter.addObserver:selector:name:object:` | selector callbacks | `removeObserver:` | Notification Programming Topics |
| Foundation | `NSNotificationCenter.addObserverForName:object:queue:usingBlock:` | block invocations | `removeObserver:` (with returned token) | Notification Programming Topics |
| Foundation | `addObserver:forKeyPath:options:context:` (KVO) | `observeValueForKeyPath:ofObject:change:context:` | `removeObserver:forKeyPath:` | KVO Programming Guide |
| AppKit | `NSEvent.addLocalMonitorForEventsMatchingMask:handler:` | handler block | `removeMonitor:` | Cocoa Event Handling Guide |

**Constraints:**
- Pairing: every register must have a matching unregister
- Lifetime: observer must be unregistered before deallocation
- Thread safety: register/unregister typically thread-safe; callbacks may arrive on any thread or specified queue

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | scoped observer / `dynamic-wind` | `(with-observer center name (lambda (notif) ...))` |
| Haskell | `bracket` / scoped | `withObserver center name $ \notif -> ...` |
| Zig | `defer removeObserver` | `const obs = center.addObserver(...); defer center.removeObserver(obs);` |
| Smalltalk | `ensure:` | `[center addObserver: ...] ensure: [center removeObserver: self]` |

---

### 4. Transaction Bracket

**Shape:** begin -> mutate* -> commit/rollback

A transaction brackets a series of mutations. Mutations are batched and applied atomically on commit.

**Detection rules:**
- Heuristic: `begin`/`commit` or `begin`/`end` method pairs (excluding resource lifecycle)
- LLM: Core Animation Programming Guide (CATransaction), Core Data documentation

**Canonical macOS examples:**

| Framework | Begin | Mutations | End | Guide |
|---|---|---|---|---|
| QuartzCore | `CATransaction.begin()` | `CALayer` property changes | `CATransaction.commit()` | Core Animation Programming Guide |
| CoreData | `NSUndoManager.beginUndoGrouping()` | recorded changes | `endUndoGrouping()` | Undo Architecture |
| AppKit | `NSAnimationContext.beginGrouping()` | animation changes | `endGrouping()` | Animation Programming Guide |

**Constraints:**
- Nesting: transactions may nest (each begin needs matching commit)
- Atomicity: mutations take effect only on commit
- Error handling: rollback on failure (if supported)

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | `with-transaction` | `(with-ca-transaction (set-position layer 100 200))` |
| Haskell | `atomically` / bracket | `withTransaction $ setPosition layer (100, 200)` |
| OCaml | `with_transaction` | `CATransaction.with_transaction (fun () -> set_position layer 100 200)` |

---

### 5. Enumeration

**Shape:** container -> iterate -> process elements

A container provides an iteration interface for processing its elements.

**Detection rules:**
- Heuristic: `enumerateObjectsUsingBlock:` and similar block-based iteration
- Heuristic: `NSFastEnumeration` protocol conformance
- Heuristic: `objectEnumerator`/`reverseObjectEnumerator` methods

**Canonical macOS examples:**

| Framework | Container | Iteration Method | Guide |
|---|---|---|---|
| Foundation | `NSArray` | `enumerateObjectsUsingBlock:`, `enumerateObjectsWithOptions:usingBlock:` | Collections Programming Topics |
| Foundation | `NSDictionary` | `enumerateKeysAndObjectsUsingBlock:` | Collections Programming Topics |
| Foundation | `NSSet` | `enumerateObjectsUsingBlock:` | Collections Programming Topics |
| Foundation | `NSIndexSet` | `enumerateIndexesUsingBlock:` | Collections Programming Topics |

**Constraints:**
- Block is synchronous (called during iteration, not copied)
- Mutation during enumeration is undefined behavior (unless using concurrent option)
- Concurrent enumeration option available via `NSEnumerationConcurrent`

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | `for-each` / `map` / `fold` | `(for-each (lambda (obj) ...) array)` |
| Haskell | `Foldable` / `Traversable` | `mapM_ processItem array` |
| OCaml | `iter` / `map` / `fold` | `NSArray.iter (fun obj -> ...) array` |
| Zig | iterator pattern | `for (array.items()) |item| { ... }` |

---

### 6. Error-Out

**Shape:** call with error param -> check return value -> handle error

Method takes an `NSError**` out-parameter. Returns `nil`/`NO` on failure with error populated.

**Detection rules:**
- Heuristic: last parameter named `error` with pointer type
- Heuristic: return type is `BOOL` or nullable object
- LLM: Error Handling Programming Guide

**Canonical macOS examples:**

| Framework | Method | Return on failure | Guide |
|---|---|---|---|
| Foundation | `NSFileManager.contentsOfDirectoryAtPath:error:` | `nil` | File System Programming Guide |
| Foundation | `NSData.dataWithContentsOfFile:options:error:` | `nil` | Data Programming Guide |
| Foundation | `NSJSONSerialization.JSONObjectWithData:options:error:` | `nil` | JSON Programming Guide |
| Foundation | `NSString.writeToFile:atomically:encoding:error:` | `NO` | String Programming Guide |

**Constraints:**
- Error parameter is only valid when method returns failure indicator
- Caller must not examine error on success (undefined)
- Error is autoreleased (caller does not own it)

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | condition system / `exn` | `(with-handlers ([exn:fail? handle]) (file-contents path))` |
| Haskell | `Either` / `ExceptT` | `contents <- contentsOfDirectory path -- returns Either NSError [String]` |
| OCaml | `result` type | `match contents_of_directory path with Ok files -> ... \| Error e -> ...` |
| Zig | error union | `const files = try fileManager.contentsOfDirectory(path);` |

---

### 7. Delegate Protocol

**Shape:** object.setDelegate(delegate) -> delegate receives callbacks

An object delegates behavior decisions to a separate delegate object that conforms to a protocol.

**Detection rules:**
- Heuristic: `setDelegate:` method with weak ownership
- Heuristic: corresponding `*Delegate` protocol with optional methods
- LLM: Cocoa Design Patterns documentation

**Canonical macOS examples:**

| Framework | Class | Delegate Protocol | Key Callbacks | Guide |
|---|---|---|---|---|
| AppKit | `NSWindow` | `NSWindowDelegate` | `windowShouldClose:`, `windowWillResize:toSize:` | Window Programming Guide |
| AppKit | `NSTableView` | `NSTableViewDelegate` | `tableView:viewForTableColumn:row:` | Table View Programming Guide |
| AppKit | `NSTableView` | `NSTableViewDataSource` | `numberOfRowsInTableView:`, `tableView:objectValueForTableColumn:row:` | Table View Programming Guide |
| Foundation | `NSURLSession` | `NSURLSessionDelegate` | `URLSession:didBecomeInvalidWithError:` | URL Loading System |

**Constraints:**
- Delegate is weak reference (no retain cycle)
- Delegate methods are typically optional
- Delegate must remain alive while set (weak, not zeroing in older APIs)

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | protocol/interface implementation | `(define my-delegate (new ns-window-delegate% ...))` |
| Haskell | typeclass instance | `instance NSWindowDelegate MyDelegate where ...` |
| OCaml | module signature / object type | `module MyDelegate : NSWindowDelegate = struct ... end` |
| Smalltalk | message-based protocol | `window delegate: myDelegate` |

---

### 8. Target-Action

**Shape:** control.setTarget(target) + control.setAction(selector) -> target receives action

A control sends a message (action) to a target object when triggered.

**Detection rules:**
- Heuristic: `setTarget:` + `setAction:` method pair on `NSControl` subclasses
- Heuristic: `target` and `action` properties
- LLM: Cocoa Event Handling Guide

**Canonical macOS examples:**

| Framework | Class | Target Property | Action Property | Guide |
|---|---|---|---|---|
| AppKit | `NSButton` | `target` | `action` | Cocoa Event Handling Guide |
| AppKit | `NSMenuItem` | `target` | `action` | Application Menus and Pop-up Lists |
| AppKit | `NSControl` | `target` | `action` | Control and Cell Programming Topics |
| AppKit | `NSGestureRecognizer` | `target` | `action` | Cocoa Event Handling Guide |

**Constraints:**
- Target is weak (unretained)
- Action is a selector (SEL) — must match `(id)sender` or `(id)sender event:(NSEvent*)event` signature
- Nil target sends action up the responder chain

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | event handler / callback | `(send button set-action! (lambda (sender) ...))` |
| Haskell | event handler | `button & onClick .~ Just (\sender -> ...)` |
| OCaml | callback | `NSButton.on_click button (fun sender -> ...)` |
| Zig | function pointer | `button.setAction(struct { fn handle(sender: id) void { ... } }.handle);` |

---

### 9. Paired State

**Shape:** enable/disable, lock/unlock, show/hide, suspend/resume

Two complementary methods that toggle a binary state. The scoped form ensures the state is restored.

**Detection rules:**
- Heuristic: method pairs with complementary verbs: `lock`/`unlock`, `enable`/`disable`, `show`/`hide`, `suspend`/`resume`, `start`/`stop`
- Heuristic: matching method signatures (both take no arguments or same arguments)

**Canonical macOS examples:**

| Framework | Enable | Disable | Guide |
|---|---|---|---|
| Foundation | `NSLock.lock()` | `NSLock.unlock()` | Threading Programming Guide |
| Foundation | `NSRecursiveLock.lock()` | `NSRecursiveLock.unlock()` | Threading Programming Guide |
| Foundation | `ProcessInfo.beginActivity(options:reason:)` | `endActivity(_:)` | Energy Efficiency Guide |
| AppKit | `NSCursor.hide()` | `NSCursor.unhide()` | Cursor Management |
| Foundation | `NSObject.willChangeValue(forKey:)` | `didChangeValue(forKey:)` | KVO Programming Guide |

**Constraints:**
- Pairing: every enable must have matching disable (especially locks)
- Nesting: some pairs nest (recursive locks), others don't
- Error handling: disable/unlock must execute even on error (bracket semantics)

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | `with-lock` / `dynamic-wind` | `(with-lock my-lock (critical-section))` |
| Haskell | `withMVar` / bracket | `withLock lock $ criticalSection` |
| Zig | `defer unlock` | `lock.lock(); defer lock.unlock();` |
| OCaml | `Mutex.protect` | `Mutex.protect lock (fun () -> critical_section)` |

---

### 10. Factory Cluster

**Shape:** abstract class -> concrete subclass selected by factory method

A class cluster hides multiple private subclasses behind a public abstract superclass. Factory methods select the appropriate concrete class.

**Detection rules:**
- Heuristic: class has factory class methods returning `instancetype`/`id` but no `alloc`/`init` usage expected
- Heuristic: mutable/immutable class pairs (`NSString`/`NSMutableString`, `NSArray`/`NSMutableArray`)
- LLM: Cocoa Core Competencies > Class Clusters

**Canonical macOS examples:**

| Framework | Abstract Class | Factory Methods | Concrete Classes | Guide |
|---|---|---|---|---|
| Foundation | `NSNumber` | `numberWithInt:`, `numberWithFloat:`, `numberWithBool:` | `__NSCFNumber`, `__NSCFBoolean` | Cocoa Core Competencies |
| Foundation | `NSString` | `stringWithFormat:`, `stringWithUTF8String:` | `__NSCFConstantString`, `NSTaggedPointerString` | Cocoa Core Competencies |
| Foundation | `NSArray` | `arrayWithObjects:count:` | `__NSArrayI`, `__NSSingleObjectArrayI` | Cocoa Core Competencies |
| Foundation | `NSDictionary` | `dictionaryWithObjects:forKeys:count:` | `__NSDictionaryI` | Cocoa Core Competencies |

**Constraints:**
- Concrete class is opaque (never name it in bindings)
- Factory methods return retained or autoreleased depending on naming convention
- Mutable/immutable copies must preserve cluster membership

**Idiomatic translations:**

| Language family | Construct | Example |
|---|---|---|
| Scheme/Lisp | smart constructor | `(ns-number 42)` dispatches to appropriate backing |
| Haskell | `from`/`into` | `fromInteger 42 :: NSNumber` |
| OCaml | module constructor | `NSNumber.of_int 42` |
| Zig | `from` function | `const n = NSNumber.from(i32, 42);` |

---

## Pattern Detection Summary

| Stereotype | Heuristic detectable? | LLM needed? | Primary detection signal |
|---|---|---|---|
| Resource lifecycle | Partial (create/release pairs) | Yes (guides show lifecycle) | Function name pairs + guides |
| Builder sequence | Partial (mutable/immutable pairs) | Yes (configuration patterns) | Class name pairs + setter count |
| Observer pair | Yes (addObserver/removeObserver) | For edge cases | Selector naming |
| Transaction bracket | Partial (begin/commit pairs) | Yes (nesting semantics) | Method name pairs |
| Enumeration | Yes (enumerateObjects*) | No | Selector naming + block param |
| Error-out | Yes (NSError** last param) | No | Parameter type + name |
| Delegate protocol | Yes (setDelegate: + protocol) | For non-obvious delegates | Selector + protocol matching |
| Target-action | Yes (target + action properties) | No | Property pair on NSControl |
| Paired state | Yes (lock/unlock, show/hide) | For non-obvious pairs | Complementary verb pairs |
| Factory cluster | Partial (mutable/immutable) | Yes (cluster membership) | Class name patterns |

## Version History

- **1.0** (2026-03-26): Initial catalog with 10 stereotypes, detection rules, and translation templates.
