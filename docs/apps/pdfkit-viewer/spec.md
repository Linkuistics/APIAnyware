# PDFKit Viewer

PDF viewer with page navigation. First sample app to exercise a non-AppKit,
non-WebKit, non-SceneKit generated framework (PDFKit) end-to-end, and the
first to observe an Apple-framework `NSNotification`.

## Layout

- Window 720 × 540, titled / closable / miniaturizable / resizable, min 480 × 360.
- Toolbar (top, 32pt): "Open…" button, "◀" prev-page button, "▶" next-page
  button, page-label `NSTextField` ("Page n of N" or "No PDF loaded"), all
  baseline-aligned inside an `NSStackView` pinned to the window top.
- `PDFView` fills the remaining area, autoresizing in both directions.
  `auto-scales = #t` so the PDF scales with the window.

## Interactions

1. Launch → empty `PDFView`, page label reads "No PDF loaded", both nav
   buttons disabled.
2. Open… → `NSOpenPanel` modally, filtered to `.pdf`. On OK:
   - Build `PDFDocument` from the chosen file URL.
   - Assign it to the `PDFView` via `setDocument:`.
   - Sync the page label and nav-button enable state.
3. ◀ / ▶ → `goToPreviousPage:` / `goToNextPage:`. The page label refreshes
   via the `PDFViewPageChangedNotification` observer.
4. Page label text derives from `currentPage` → `indexForPage:` + `pageCount`,
   so it stays correct whether the page changes via the nav buttons or via
   `PDFView`'s own gesture / scroll handling.

## API surface

| API | Usage |
|-----|-------|
| `PDFView` | Embedded viewer; `setDocument:`, `setAutoScales:`, `goToNext/PreviousPage:`, `canGoToNext/PreviousPage`, `currentPage` |
| `PDFDocument` | Built via `initWithURL:`; used for `pageCount`, `indexForPage:` |
| `PDFPage` | Return type of `currentPage`; identity-only |
| `PDFViewPageChangedNotification` | Name constant observed via `NSNotificationCenter` |
| `NSNotificationCenter` | `defaultCenter` + `addObserver:selector:name:object:` |
| `NSOpenPanel` | Modal file picker, filtered via `setAllowedFileTypes:` |
| `NSArray` | `list->nsarray` to build the single-element file-type filter |

## Novel patterns

- **First use of `NSNotificationCenter`** in a sample app. The observer is
  a `make-delegate` wrapper (just like `NSOpenPanel` completion / table
  data source callbacks in other apps). The notification-name constant
  (`PDFViewPageChangedNotification`) comes from PDFKit's generated
  `constants.rkt` as a raw `_id`-typed cpointer — wrap via
  `borrow-objc-object` to satisfy the observer method's `objc-object?`
  contract.
- **First use of PDFKit's generated bindings end-to-end.** Verifies the
  generator pipeline for a mid-tier framework (neither Foundation nor
  AppKit) reaches the "loads cleanly + actually works" bar set by the
  runtime-load harness.
- **File-type filter via `setAllowedFileTypes:`.** `list->nsarray` of a
  single `string->nsstring` element — no central `nsarray-from-strings`
  helper exists, and `arrayWithObjects:` is variadic so isn't emitted.

## VM test strategy

1. Launch → window appears, page label reads "No PDF loaded", both nav
   buttons disabled.
2. Open… → `NSOpenPanel` appears, filtered to `.pdf`. Pick a PDF → page 1
   of N renders, page label updates, ▶ becomes enabled.
3. Click ▶ → view advances to page 2, label updates to "Page 2 of N".
4. Keyboard navigation (arrow keys inside `PDFView`) also fires
   `PDFViewPageChangedNotification`, so the label stays in sync even when
   the user navigates without the toolbar buttons.
