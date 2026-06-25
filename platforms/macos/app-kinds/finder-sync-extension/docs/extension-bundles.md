# finder-sync-extension — extension bundles

A `finder-sync-extension` ships as a `.appex` **app-extension** bundle. This
documents that bundle shape and the keys the kind *requires*, as platform truth. It
does not say how any target's bundler writes them (that is `targets/`, workstream 6).

## The `.appex` app extension

A Finder Sync extension is a `.appex` the Finder loads to badge files, add toolbar
and context-menu items, and react to changes in directories the user has registered
as *sync folders* (the mechanism cloud-storage clients use for status overlays). Like
the Quick Look extension it uses the **NSExtension** mechanism — an extension point
plus a principal class — and is hosted, not launched.

```text
MySync.appex/
  Contents/
    Info.plist            # NSExtension declaration (below); CFBundlePackageType=XPC!
    MacOS/
      MySync              # the CFBundleExecutable — the extension's Mach-O
    Resources/
    _CodeSignature/
```

The extension is **embedded inside a containing app** (`Contents/PlugIns/` of a host
`.app`, workstream 7's app-spec concern); the user enables it in System Settings ›
Login Items & Extensions. The Finder then loads the appex, instantiates its principal
class, and drives it — the host owns the process, the run loop, and termination.

## Extension point — `com.apple.FinderSync`

This kind plugs into `com.apple.FinderSync`: the principal class is an `FIFinderSync`
subclass. The host calls it to set badge images on items, to supply toolbar and
context-menu items for the selection, and to notify it when the contents of a watched
directory change. The set of directories the extension watches is established at
runtime via `FIFinderSyncController` — a behaviour of the principal class, not a
bundle key.

## Required Info.plist keys

The `bundle.info-plist` block of `kind.apiw` lists the keys a
`finder-sync-extension` requires. Each is platform truth — without it the Finder
cannot load or dispatch the extension:

| key | role |
| --- | --- |
| `CFBundleIdentifier` | the reverse-DNS bundle id — the extension's identity |
| `CFBundleExecutable` | the extension's Mach-O under `Contents/MacOS/` |
| `CFBundlePackageType` | `XPC!` — marks the bundle as an app extension |
| `NSExtension` | the extension dictionary: the `NSExtensionPointIdentifier` (`com.apple.FinderSync`) and the `NSExtensionPrincipalClass` (the `principal-class-key`) the Finder instantiates |

`CFBundlePackageType` is `XPC!`, not `APPL` — an extension is loaded by a host, not
launched as an application. The `NSExtensionPointIdentifier` and
`NSExtensionPrincipalClass` live *inside* the `NSExtension` dictionary; the kind
records the extension point via its `extension-point` node and the principal-class
key via `principal-class-key`, and requires the top-level `NSExtension` key that
carries them.
