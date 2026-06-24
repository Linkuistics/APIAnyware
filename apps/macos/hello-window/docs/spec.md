# Hello Window

**Complexity:** 1/7 (simplest)
**Key features exercised:** Object lifecycle, property setters, NSWindow creation, NSApplication setup

## Purpose

Minimal macOS GUI app that creates a window with a title and displays a label. Proves the bindings can create AppKit objects, set properties, and run an event loop.

## Window Layout

- **Window:**
  - Title: "Hello from {Language}"  (e.g., "Hello from Racket")
  - Size: 400 x 200 points
  - Position: centered on screen
  - Style: titled, closable, miniaturizable
  - Background: default (system window background)

- **Label:**
  - Text: "Hello, macOS!"
  - Font: system font, 24pt
  - Alignment: centered
  - Position: centered in the window (both horizontally and vertically)

## Behavior

1. App launches and shows the window
2. Window appears centered on screen
3. Label is visible and legible
4. Closing the window terminates the app
5. No menus required beyond the default application menu

## API Surface

| API | Usage |
|-----|-------|
| `NSApplication.sharedApplication` | Get/create the app instance |
| `NSApplication.setActivationPolicy:` | Set to `.regular` for dock icon |
| `NSApplication.activateIgnoringOtherApps:` | Bring app to front |
| `NSApplication.run` | Start event loop |
| `NSWindow.initWithContentRect:styleMask:backing:defer:` | Create window |
| `NSWindow.setTitle:` | Set window title |
| `NSWindow.center` | Center on screen |
| `NSWindow.makeKeyAndOrderFront:` | Show window |
| `NSTextField` (label mode) | Create non-editable text field |
| `NSTextField.setStringValue:` | Set label text |
| `NSTextField.setFont:` | Set font |
| `NSTextField.setAlignment:` | Center text |
| `NSView.addSubview:` | Add label to window content view |

## Patterns Exercised

- **Object lifecycle:** alloc/init → configure → use → release (if manual memory management)
- **Property setters:** calling `setTitle:`, `setStringValue:`, etc.
- **Class method dispatch:** `NSApplication.sharedApplication`, `NSFont.systemFontOfSize:`
- **Frame geometry:** `NSMakeRect` for window and label positioning

## Success Criteria

- Window appears on screen with correct title
- Label text is visible and centered
- App responds to window close by terminating
- No crashes or memory leaks during lifecycle
