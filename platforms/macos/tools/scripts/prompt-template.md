# macOS API Annotation & Pattern Recognition Prompt

You are analyzing macOS framework APIs for a code generation system. Your job is twofold:

1. **Per-method annotations** — classify individual methods by their ownership, threading, error handling, and block invocation semantics
2. **API pattern recognition** — identify multi-method behavioral contracts that documentation describes implicitly through usage guidance, lifecycle descriptions, and code examples

Both outputs are critical: annotations tell the emitter how to handle each method individually, while patterns tell it how groups of methods work together and what idiomatic construct to emit in the target language.

---

## Part 1: Per-Method Annotations

### Input

You will receive a list of classes and methods from a macOS framework. For each method, determine the annotations below.

### Block Invocation Style (`block_parameters`)

For each parameter with block/closure type, classify how the receiver invokes it:

| Style | When to use | Examples |
|---|---|---|
| `synchronous` | Block is called during the method and NOT copied. Caller must free it after return. | `enumerateObjectsUsingBlock:`, `sortedArrayUsingComparator:`, `filteredArrayUsingPredicate:` |
| `async_copied` | Block is copied (`Block_copy`) for later async invocation. ObjC runtime manages lifecycle. | `dataTaskWithURL:completionHandler:`, `performSelector:withObject:afterDelay:` |
| `stored` | Block is stored by the receiver for repeated invocation. Similar to async_copied but may fire multiple times. | `addObserverForName:object:queue:usingBlock:`, `setCompletionBlock:` |

**Default assumption:** If unsure, use `async_copied` (safest — ensures the block is copied).

### Parameter Ownership (`parameter_ownership`)

For each non-block object parameter, classify the receiver's ownership:

| Ownership | When to use | Examples |
|---|---|---|
| `weak` | Receiver does NOT retain. Caller must keep alive. Common for delegates, data sources, targets. | `setDelegate:`, `setDataSource:`, `setTarget:` |
| `copy` | Receiver copies the value. Common for strings and value types. | Block parameters (handled separately), NSString properties |
| `strong` | Receiver retains (default). **Do not annotate** — this is the default. | Most object parameters |
| `unsafe_unretained` | Raw pointer, no ownership. Rare, only for C-level APIs. | `CFRetain`/`CFRelease` bridged APIs |

**Only annotate non-default (non-strong) ownership.**

### Threading Constraints (`threading`)

| Constraint | When to use |
|---|---|
| `main_thread_only` | Must be called on the main thread. All AppKit/UIKit view and window classes. |
| `any_thread` | Explicitly documented as thread-safe. |

**Only annotate if determinable from documentation.** Most Foundation classes are thread-safe for reading but not writing — do not annotate unless Apple docs explicitly state threading requirements.

### Error Patterns (`error_pattern`)

| Pattern | When to use |
|---|---|
| `error_out_param` | Last parameter is `NSError**`. Method returns `nil`/`NO` on failure. |
| `throws_exception` | Method throws an ObjC exception (rare in modern Cocoa). |
| `nil_on_failure` | Returns `nil` on failure but has no error parameter. |

---

## Part 2: API Pattern Recognition

This is the harder and more valuable part. Apple documentation rarely names patterns explicitly — it instead describes them through usage examples, lifecycle guidance, and "how to" narratives. Your task is to recognize these implicit patterns and classify them.

### How to recognize patterns

Patterns are revealed by documentation that:

1. **Describes a sequence of calls** — "First create X, then call Y, then Z, and finally release X." This implies a resource lifecycle pattern even though the word "lifecycle" may never appear.

2. **Pairs methods together** — "Call `addObserver:` to register and `removeObserver:` when done." The pairing implies a bracket/scoped pattern.

3. **Shows code examples with setup/teardown** — Code samples in programming guides that show `begin`/`end` or `lock`/`unlock` patterns, even when the text doesn't name them as patterns.

4. **Describes ownership contracts** — "The delegate is not retained" or "You must balance every retain with a release" reveals ownership patterns.

5. **Groups methods by role** — "Use `setHTTPMethod:`, `setValue:forHTTPHeaderField:`, and `setHTTPBody:` to configure the request" reveals a builder pattern.

6. **Describes constraints** — "Must be called on the main thread", "Must be called in pairs", "Must precede X" reveals ordering and threading constraints.

### Pattern Stereotype Catalog

When you identify a pattern, classify it as one of these stereotypes. These are well-known Cocoa idioms — your job is to find instances of them in the API you're analyzing.

#### Resource Lifecycle
**What it looks like in docs:** "Create a mutable X with `Create*`. Add elements with `Add*`. When finished, release with `Release*`." Or: "Call `beginEditing` before making changes and `endEditing` when done."
**Key signal:** A create/acquire method, one or more operation methods, and a release/finalize method that must be called.
**Participants:** `open` (create/begin), `operations` (use methods), `close` (release/end)

#### Builder Sequence
**What it looks like in docs:** Documentation shows a series of configuration calls on a mutable object, then the object is used or copied to immutable. Often the "Overview" section shows step-by-step construction.
**Key signal:** A mutable class with many `set*:` methods and a `copy` method or use-in-place pattern.
**Participants:** `create` (init/alloc), `configure` (setter methods), `finalize` (copy/use)

#### Observer Pair
**What it looks like in docs:** "Register for notifications with `addObserver:...`" paired with "Remove the observer with `removeObserver:...`" — often with a warning about memory leaks if not removed.
**Key signal:** register/unregister method pair, often with a token or reference for removal.
**Participants:** `register` (add/subscribe), `callback` (the notification/observation method), `unregister` (remove/unsubscribe)

#### Transaction Bracket
**What it looks like in docs:** "Call `begin` to start a transaction. Make changes. Call `commit` to apply them." Often with notes about nesting and atomicity.
**Key signal:** begin/commit or begin/end pairs that batch mutations.
**Participants:** `begin`, `mutations` (the changes), `commit`/`rollback`

#### Enumeration
**What it looks like in docs:** Methods described as "iterating over" or "enumerating" elements of a collection.
**Key signal:** Block-taking methods with "enumerate", "sort", "filter" in the name.
**Participants:** `container` (the collection), `iterate` (the enumeration method), `element_processor` (the block)

#### Error-Out
**What it looks like in docs:** "Returns nil and sets the error parameter on failure" or "On success returns YES; on failure returns NO and populates the error."
**Key signal:** `NSError**` last parameter, paired with a return value that indicates success/failure.
**Participants:** `call` (the method), `error_param` (the NSError**), `return_check` (nil/NO check)

#### Delegate Protocol
**What it looks like in docs:** "Set the delegate to receive callbacks" or "Implement the delegate protocol to customize behavior."
**Key signal:** `setDelegate:` with a corresponding `*Delegate` protocol.
**Participants:** `setter` (setDelegate:), `protocol` (the delegate protocol), `callbacks` (protocol methods)

#### Target-Action
**What it looks like in docs:** "Set the target and action to handle user interaction" or "When the user clicks the button, the action message is sent to the target."
**Key signal:** `target`/`action` property pair, typically on `NSControl` subclasses.
**Participants:** `target_setter`, `action_setter`, `trigger` (user interaction)

#### Paired State
**What it looks like in docs:** "Call `lock` before accessing the resource and `unlock` when done" or "Balance every `beginEditing` with an `endEditing`."
**Key signal:** Complementary verb pairs: lock/unlock, show/hide, enable/disable, suspend/resume, begin/end.
**Participants:** `enable` (the first call), `disable` (the second call)

#### Factory Cluster
**What it looks like in docs:** "NSNumber is a class cluster" or factory methods that return `instancetype` without typical alloc/init usage. Documentation may mention that "the actual class may differ from the one you requested."
**Key signal:** Abstract superclass with factory class methods, concrete subclasses are private.
**Participants:** `abstract_class`, `factory_methods`, `concrete_classes` (usually hidden)

### How to describe a pattern instance

For each pattern you find, provide:

1. **stereotype** — which of the 10 stereotypes above it matches
2. **name** — a short descriptive name (e.g., "CGPath construction", "NSLock critical section")
3. **participants** — the specific methods/functions/classes that play each role
4. **constraints** — ordering requirements, threading constraints, ownership implications
5. **doc_ref** — where in Apple's documentation this pattern is described or implied (programming guide name and section, or API reference URL)

---

## Output Format

### Method Annotations

```json
{
  "framework": "FrameworkName",
  "classes": [
    {
      "class_name": "NSClassName",
      "methods": [
        {
          "selector": "methodName:withParam:",
          "is_instance": true,
          "parameter_ownership": [{"param_index": 0, "ownership": "weak"}],
          "block_parameters": [{"param_index": 1, "invocation": "async_copied"}],
          "threading": "main_thread_only",
          "error_pattern": "error_out_param",
          "source": "llm"
        }
      ]
    }
  ],
  "api_patterns": [
    {
      "stereotype": "resource_lifecycle",
      "name": "descriptive pattern name",
      "participants": {
        "open": {"class": "NSFoo", "selector": "beginOperation"},
        "operations": [
          {"class": "NSFoo", "selector": "addItem:"},
          {"class": "NSFoo", "selector": "removeItem:"}
        ],
        "close": {"class": "NSFoo", "selector": "endOperation"}
      },
      "constraints": {
        "ordering": "open must precede operations; close must follow all operations",
        "thread_safety": "not thread-safe",
        "ownership": "caller responsible for close even on error"
      },
      "source": "llm",
      "doc_ref": "Programming Guide Name > Section Name"
    }
  ]
}
```

### Rules

- Only include methods with at least one non-default annotation
- Set `source` to `"llm"` for all annotations and patterns
- Sort classes alphabetically by `class_name`, methods by `selector`
- Omit empty arrays and null fields
- `is_instance` is `true` for instance methods (`-`), `false` for class methods (`+`)
- For patterns, use function-level participants (with `function` key) for C functions, and class+selector for ObjC methods

---

## What to Consult

### Primary source: Programming guides

**Programming guides are the single most important source for pattern recognition.** API reference documentation describes individual methods in isolation — it tells you what a method does but not how it relates to other methods. Programming guides describe the *context*: how methods work together, what order to call them in, what constraints exist, and what the intended lifecycle is.

When reading a programming guide, look for:

- **Step-by-step instructions** — "First, create X. Then call Y. Finally, release X." These reveal resource lifecycle and builder patterns.
- **"Must" and "should" statements** — "You must remove the observer before the object is deallocated." These reveal constraints and pairing requirements.
- **Code examples showing setup/teardown** — Even if the text doesn't name it as a pattern, a code sample showing `begin`/`end` or `lock`/`unlock` reveals a bracket pattern.
- **Warnings about consequences** — "Failing to call `endEditing` may result in inconsistent state." These reveal critical pairing constraints.
- **Sections about threading** — "This class is not thread-safe. Access it only from the main thread." These reveal threading constraints.
- **Sections about memory management** — "The delegate is not retained." These reveal ownership patterns.
- **Multi-paragraph narratives** — A guide explaining how to use KVO won't say "this is an observer pair pattern". Instead it will walk through `addObserver:forKeyPath:`, explain what happens, then later mention `removeObserver:forKeyPath:`. The pattern is *implicit in the narrative*.

#### Key programming guides by framework

| Framework | Guide | Patterns to find |
|---|---|---|
| Foundation | Memory Management Programming Guide | Ownership, retain/release contracts |
| Foundation | Threading Programming Guide | Lock patterns, thread safety, paired state |
| Foundation | Key-Value Observing Programming Guide | Observer lifecycle, registration/removal pairs |
| Foundation | Collections Programming Topics | Enumeration, factory clusters, mutation constraints |
| Foundation | Error Handling Programming Guide | NSError** contracts, error-out pattern |
| Foundation | Notification Programming Topics | Observer pairs, notification lifecycle |
| Foundation | Attributed String Programming Guide | Editing sessions (resource lifecycle) |
| Foundation | URL Loading System | Builder sequence (NSMutableURLRequest), delegate protocols |
| CoreGraphics | Quartz 2D Programming Guide | CGPath/CGContext resource lifecycles, state save/restore |
| QuartzCore | Core Animation Programming Guide | CATransaction brackets, layer tree |
| AppKit | Cocoa Drawing Guide | Drawing state save/restore, focus stack |
| AppKit | Window Programming Guide | Delegate protocols, window lifecycle |
| AppKit | Table View Programming Guide | Delegate + data source patterns |
| AppKit | Cocoa Event Handling Guide | Target-action, responder chain |

### Secondary sources

2. **API reference docs** at `https://developer.apple.com/documentation/{framework}/{classname}` — useful for individual method semantics (block invocation, error patterns, threading notes), but NOT the primary source for pattern recognition
3. **Header comments** — sometimes contain explicit threading or ownership notes not in the reference docs
4. **Code samples** — Apple's sample code projects show patterns in action

## Priority

### For method annotations:
1. Block parameters where the invocation style is ambiguous from the name alone
2. Parameters that are weak references but don't have "delegate" or "dataSource" in the name
3. Threading constraints for classes that aren't obvious UI classes
4. Error patterns beyond the simple `NSError**` out-param pattern

### For pattern recognition:
1. **Resource lifecycle patterns** — most critical for safe bindings (memory leaks if missed). Look for create/release pairs, begin/end sessions, open/close resources.
2. **Observer pairs** — second most critical (dangling observers crash). Look for register/unregister, add/remove, subscribe/unsubscribe.
3. **Paired state** — important for scoped constructs (deadlocks, inconsistent state). Look for lock/unlock, begin/end, will/did, enable/disable.
4. **Delegate protocols** — shape the emitted API surface. Every `*Delegate` protocol is a pattern instance.
5. **Builder sequences** — improve API ergonomics. Look for mutable objects with many setters that get copied/frozen.
6. **Factory clusters** — immutable/mutable class pairs. Look for `NSMutable*` variants.
7. **Transaction brackets** — batched mutation patterns. Look for begin/commit, begin/end grouping.
8. **Enumeration** — already well-detected by heuristics, but confirm invocation style.
9. **Target-action** — AppKit-specific, shape event handling.
10. **Error-out** — already well-detected by heuristics (NSError** signature).
