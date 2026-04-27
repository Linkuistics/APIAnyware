# racket-oo — Target Learnings

## Runtime
- Racket's GC is precise — the runtime must prevent GC of ObjC objects, C callbacks, and block structs via the `active-blocks` hash and `swift-gc-handles` registry
- `coerce-arg` auto-converts Racket strings to NSString for convenience
- TypedMsgSend methods (`_msg-N` bindings) expect raw pointers for id-type parameters, not wrapped `objc-object` structs
- `with-autorelease-pool` uses `begin0` internally, so `define` forms inside it are invalid — use `let`/`let*`
- Racket module compilation is very slow on first run (~5+ minutes for apps importing many generated modules); cached in `compiled/` after

## Emitter
- Emitter ports cleanly from POC with three IR type changes: `Enum.enum_type` is `TypeRef`, `EnumValue.value` is `i64`, Method has `source`/`provenance`/`doc_refs`
- Swift-style selectors (containing `(`) must be filtered from emission
- `coerce-arg` must cast `objc-object-ptr` to `_id` via `(cast ptr _pointer _id)` for `tell` macro compatibility
- Category property merging must deduplicate by name; emitter must also deduplicate effective_methods by selector
- Runtime paths: `../../../runtime/` for class files, `../../../../runtime/` for protocol files (generated/{style}/ adds a level)

## Sample app bundling

Racket OO sample apps must be packaged as proper `.app` bundles to display
the right menu-bar app name (`CFBundleName` from `Info.plist`) and to get
per-app TCC permission identity. `NSProcessInfo setProcessName:` is
filtered by modern macOS — bundling is the only working path.

The bundling story is two crates:

- **`apianyware-macos-stub-launcher`** (language-agnostic) — generates
  the Swift stub binary, `Info.plist`, and `.app` skeleton.
- **`apianyware-macos-bundle-racket-oo`** (this language) — walks the
  entry script's transitive `(require ...)` tree, copies the discovered
  files into `Resources/racket-app/<rel>` mirroring the source layout
  so relative requires resolve at runtime, and copies the optional
  Swift helper dylib if present.

Build a sample-app bundle with:

```sh
cargo run --example bundle_app -p apianyware-macos-bundle-racket-oo -- file-lister
```

Output: `apps/<name>/build/<App Name>.app` (gitignored). The display
name is derived from the kebab-case script name (`file-lister` →
`File Lister`); the bundle id is `com.linkuistics.<NoSpaceTitle>`.

Layout convention inside `Resources/racket-app/` mirrors the source
tree: `apps/<name>/<name>.rkt` for the entry, sibling `runtime/`,
`generated/oo/<framework>/`, and optional `lib/` directories. The
walker's bundle output only contains files actually reachable from
the entry script's static requires — frameworks the script doesn't
import never enter the bundle.

## Layout caveats for delegate callbacks

NSTableViewDataSource's `numberOfRowsInTableView:` returns NSInteger,
which the `runtime/delegate.rkt` trampoline doesn't speak natively
(it only supports `'void`, `'bool`, `'id` returns). Workaround
(originally surfaced while building the retired file-lister sample
app, 2026-04-15): declare the method `'id` and return `(ptr-add #f
count)` — on arm64 both NSInteger and id ride in `x0` so the bit
pattern survives the lying type encoding. The ObjC caller (NSTableView)
reads `x0` as NSInteger via the compile-time-known protocol signature
and never consults the runtime method encoding.

For the `tableView:objectValueForTableColumn:row:` callback the same
type-bypass applies in reverse: the row index arrives as a cpointer
whose address bits are the integer, extracted via `(cast row-ptr
_pointer _int64)`. Column-identity introspection on raw cpointer
arguments has to bypass the wrapper functions' strict `objc-object?`
self contract — call `tell` directly:

```racket
(let ([id-ptr (tell (cast col-ptr _pointer _id) identifier)])
  (nsstring->string id-ptr))
```

## Toolbar baseline alignment

NSButton text and NSTextField text don't share a baseline by default
because the controls compute their text origin differently (button has
a bezel inset; field uses NSTextFieldCell vertical centering). Manual
y-coordinate fiddling will land within ~1 px but not perfect across
font sizes. Use `NSStackView` with horizontal orientation and
`NSLayoutAttributeFirstBaseline` (= 12) alignment instead — Auto Layout
pins the children's `firstBaselineAnchor`s together, exactly. Pattern
originally surfaced while building the retired file-lister sample app
(2026-04-15).

## Dated Discoveries

**2026-03-31:**
- 🔴 delegate bridge requires prevent-gc! on target object or it gets collected mid-session
- 🔴 typedef aliases must be resolved to canonical types at collection time or FFI mapper defaults to _uint64
- 🔴 NSEdgeInsets not in geometry struct alias list — omit from apps until fixed
- 🟡 Dylib name is `libAPIAnywareRacket`, only `swift-helpers.rkt` references it
- 🟡 NSStepper requires `setContinuous: YES` to fire target-action
- 🟡 NSStepper inside plain NSView in NSStackView may not receive clicks — add directly as arranged subview
- 🟡 Radio button mutual exclusion requires manual target-action delegate

**2026-04-15 (file-lister + bundling):**
- 🔴 `NSProcessInfo setProcessName:` is filtered by modern macOS — bundling is the only working menu-bar app name fix
- 🔴 NSTableViewDataSource's NSInteger return needs the arm64 x0-smuggle workaround (`(ptr-add #f count)`) until the delegate runtime grows `'int` returns
- 🟡 Strict `objc-object?` self contract on wrapper functions collides with delegate-callback ergonomics — raw cpointer args from the trampoline must go through `tell` directly, not the wrapper layer
- 🟡 Cell-based NSTableView's row alignment looks "off" at the default 17pt height; explicit 20pt row height + `setEditable: NO` per column gives a clean read-only list
- 🟡 NSStackView + `NSLayoutAttributeFirstBaseline` alignment is the right tool for button/label baseline alignment; manual y offsets are fragile
- 🟡 Default scroll-view bezel border looks wrong on a flush-to-window list — set `setBorderType: NSNoBorder` (= 0)
- 🟡 minimal-racket from Homebrew does NOT include `raco make` — that's in the `compiler-lib` package. For ad-hoc sample-app runs, just `racket file.rkt` directly
