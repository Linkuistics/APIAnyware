# Mini Browser — TestAnyware Validation

## Prerequisites
- App binary built and located in shared directory
- macOS VM booted with network access and TestAnyware server running

## Validation Steps

### 1. Launch and Initial Load
- [ ] Launch the app
- [ ] Verify a window appears with navigation bar, web view, and status bar
- [ ] Verify initial page (apple.com) begins loading
- [ ] Verify status bar shows loading state
- [ ] Wait for page to finish loading
- [ ] Verify web content is visible (not blank)
- [ ] Verify window title shows page title (e.g., "Apple")
- [ ] Verify address bar shows URL

### 2. Navigation Controls
- [ ] Verify Back button is disabled (no history yet)
- [ ] Verify Forward button is disabled
- [ ] Click a link on the page
- [ ] Verify page navigates and address bar updates
- [ ] Verify Back button is now enabled
- [ ] Click Back — verify previous page loads
- [ ] Verify Forward button is now enabled
- [ ] Click Forward — verify navigates forward again

### 3. Address Bar Navigation
- [ ] Clear address bar and type "https://www.example.com"
- [ ] Press Enter (or click Go)
- [ ] Verify example.com loads
- [ ] Verify address bar shows the URL
- [ ] Type "example.org" (no scheme) and navigate
- [ ] Verify "https://" is prepended and page loads

### 4. Reload
- [ ] Click Reload button
- [ ] Verify page reloads (loading indicator appears then completes)

### 5. Status Bar
- [ ] During page load, verify "Loading..." (or similar) appears in status bar
- [ ] After load completes, verify status shows page URL or "Done"

### 6. Error Handling
- [ ] Type an invalid URL (e.g., "not-a-url") and navigate
- [ ] Verify the app does not crash
- [ ] Verify some error indication (status bar message or page error)

### 7. Visual Quality
- [ ] Navigation bar controls are properly aligned
- [ ] Web view fills the available space
- [ ] Buttons have appropriate appearance (< > for back/forward)
- [ ] Window resizing works, web view resizes with it
