# Hello Window — TestAnyware Validation

## Prerequisites
- App binary built and located in shared directory
- macOS VM booted and TestAnyware server running

## Validation Steps

### 1. Launch and Window Appearance
- [ ] Launch the app
- [ ] Verify a window appears on screen
- [ ] Verify window title contains "Hello from"
- [ ] Verify window is approximately 400x200 points
- [ ] Verify window is centered on screen (roughly)

### 2. Label Content
- [ ] Verify "Hello, macOS!" text is visible in the window
- [ ] Verify text appears centered (not clipped at edges)
- [ ] Verify text is large enough to read easily (24pt equivalent)

### 3. Window Interaction
- [ ] Verify window can be moved by dragging title bar
- [ ] Verify window close button is present and clickable
- [ ] Close the window and verify the app terminates

### 4. Visual Quality
- [ ] No rendering artifacts or garbled text
- [ ] No overlapping or clipped UI elements
- [ ] Window background is standard system color (not black or white)
