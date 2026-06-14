# Mini Browser

**Complexity:** 6/7
**Key features exercised:** Cross-framework (WebKit), WKWebView, async delegate protocols, URL handling

## Purpose

A minimal web browser with an address bar, back/forward navigation, and a web view. Demonstrates cross-framework usage (AppKit + WebKit), async delegate protocols (navigation callbacks), and URL/string handling.

## Window Layout

- **Window:**
  - Title: Updates to show current page title (e.g., "Apple - Mini Browser")
  - Size: 800 x 600 points
  - Position: centered on screen
  - Style: titled, closable, miniaturizable, resizable
  - Minimum size: 500 x 400

- **Navigation bar** (top of content view, horizontal layout):
  - **Back button:** "<" (enabled when history allows)
  - **Forward button:** ">" (enabled when history allows)
  - **Address bar:** `NSTextField` showing current URL, editable
  - **Go button:** Navigates to the URL in the address bar
  - **Reload button:** Reloads current page

- **Web view** (fills remaining space):
  - `WKWebView` displaying web content
  - Initial URL: `https://www.apple.com`

- **Status bar** (bottom of window):
  - Loading indicator: shows "Loading..." during page loads, page URL when complete

## Behavior

1. App launches and loads `https://www.apple.com`
2. Address bar shows the current URL
3. Window title shows the page title
4. Clicking links navigates within the web view
5. Back/Forward buttons navigate browser history
6. Typing a URL in the address bar and pressing Enter (or clicking Go) navigates to it
7. URLs without scheme get "https://" prepended
8. Loading state shown in status bar
9. Reload button refreshes the current page
10. Back/Forward buttons enable/disable based on history availability

## API Surface

| API | Usage |
|-----|-------|
| `WKWebView` | Web content display |
| `WKWebView.initWithFrame:configuration:` | Create web view |
| `WKWebView.loadRequest:` | Load a URL |
| `WKWebView.reload` | Reload page |
| `WKWebView.goBack` | Navigate back |
| `WKWebView.goForward` | Navigate forward |
| `WKWebView.canGoBack` | Check history availability |
| `WKWebView.canGoForward` | Check history availability |
| `WKWebView.title` | Get page title |
| `WKWebView.URL` | Get current URL |
| `WKWebViewConfiguration` | Web view configuration |
| `WKNavigationDelegate` | Navigation event callbacks |
| `didStartProvisionalNavigation:` | Loading started |
| `didFinishNavigation:` | Loading finished |
| `didFailNavigation:withError:` | Loading failed |
| `NSURL.URLWithString:` | Create URL from string |
| `NSURLRequest.requestWithURL:` | Create URL request |

## Patterns Exercised

- **Cross-framework usage:** AppKit (window, controls) + WebKit (web view, delegates)
- **Async delegate protocols:** `WKNavigationDelegate` methods called asynchronously during page loads
- **Delegate bridging:** Creating an ObjC delegate object that dispatches to language callbacks
- **URL handling:** NSURL construction, string manipulation for URL normalization
- **Property observation:** Monitoring `title`, `URL`, `canGoBack`, `canGoForward` for UI updates
- **Conditional UI state:** Enabling/disabling buttons based on navigation state

## Success Criteria

- Web page loads and displays on launch
- Address bar shows current URL
- Window title reflects page title
- Back/Forward navigation works
- Typing URL + Enter navigates to new page
- Loading state visible in status bar
- Back/Forward buttons correctly enable/disable
- No crashes on invalid URLs (graceful error handling)
