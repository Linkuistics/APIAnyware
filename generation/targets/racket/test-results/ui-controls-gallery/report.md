# UI Controls Gallery — Racket Test Report

**Date:** 2026-03-30
**Status:** Pass-with-fixes

## Steps Completed
- [x] Launch app — window appears with correct title "UI Controls Gallery"
- [x] Window is resizable
- [x] Text Fields section: editable field and password field visible
- [x] Buttons section: push button, checkbox, radio buttons visible
- [x] Sliders section: horizontal slider and value label visible, drag updates label live (50→87→17→71)
- [x] Popup & Combo section: dropdown (Small) and combo box visible
- [x] Date Picker section: textual date picker with stepper visible
- [x] Progress Indicators: determinate bar (~65%), indeterminate spinner visible
- [x] Stepper section: stepper control visible, clicks update label live (5→4→7)
- [x] Color & Image: blue color well visible
- [x] Scrolling works across all sections
- [x] Native macOS appearance (standard AppKit controls)

## Issues Found

### Issue 1: Duplicate property emission
- **Category:** Emitter bug
- **Description:** `nsslider-vertical` and `nsdate-time-interval-since-reference-date` were emitted twice, causing Racket `module: identifier already defined` error
- **Fix:** Added deduplication in collection phase (`extract_declarations.rs`: filter category properties by name before extending) and emitter phase (`emit_class.rs`: deduplicate `effective_methods` and `effective_properties` by selector/name using HashSet)

### Issue 2: Wrong FFI type for typedef aliases
- **Category:** Emitter bug (collection + type mapping)
- **Description:** `nsimage-image-named` parameter `NSImageName` (typedef NSString *) was mapped to `_uint64` instead of `_id`, causing runtime type mismatch error
- **Fix:** Resolved typedef aliases to their canonical types at collection time (`type_mapping.rs`): ObjC object pointer aliases → resolve to id/class, primitive aliases → resolve to primitive, enum/struct aliases → keep as Alias

### Issue 3: NSStepper target-action requires setContinuous
- **Category:** App bug (macOS behavior)
- **Description:** NSStepper changes its internal intValue on click, but does NOT fire its target-action by default. Requires `setContinuous: YES`.
- **Fix:** Added `(nsstepper-set-continuous! stepper #t)` to the app.

### Issue 4: NSStepper inside container NSView doesn't receive clicks in NSStackView
- **Category:** App bug (layout)
- **Description:** When the stepper was inside a plain NSView container added to NSStackView, clicks didn't reach the stepper. Removing the container and adding the stepper directly to the stack view fixed it.
- **Fix:** Replaced container approach with direct stack view arrangement.

### Issue 5: NSEdgeInsets struct type not supported
- **Category:** Known limitation
- **Description:** `nsstackview-set-edge-insets!` uses `_uint64` typed msg-send instead of the NSEdgeInsets struct type. Omitted from app rather than crashing.
- **Fix:** Not fixed — edge insets omitted. The stack view works without explicit insets.

## Notes
- Racket module compilation is very slow on first run (~5+ minutes for 20 generated modules). Subsequent runs use compiled cache.
- VirtioFS shared filesystem can serve stale files after host edits; restarting the VM or copying to local storage resolves this.
- Radio button mutual exclusion requires manual target-action (deprecated NSMatrix not used).
