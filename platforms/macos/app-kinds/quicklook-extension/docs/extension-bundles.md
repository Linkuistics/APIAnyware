# quicklook-extension — extension bundles

A `quicklook-extension` ships as a `.appex` **app-extension** bundle. This documents
that bundle shape and the keys the kind *requires*, as platform truth. It does not
say how any target's bundler writes them (that is `targets/`, workstream 6).

## The `.appex` app extension

An app extension is a `.appex` bundle the system loads into a host-managed process to
perform a focused task — here, rendering a Quick Look preview. Unlike the legacy
CFPlugIn `.mdimporter`, an appex uses the **NSExtension** mechanism: it declares an
*extension point* it plugs into and a *principal class* the host instantiates.

```text
MyPreview.appex/
  Contents/
    Info.plist            # NSExtension declaration (below); CFBundlePackageType=XPC!
    MacOS/
      MyPreview           # the CFBundleExecutable — the extension's Mach-O
    Resources/
    _CodeSignature/
```

An app extension is not launched directly and is not installed on its own: it is
**embedded inside a containing app** (`Contents/PlugIns/` of a host `.app`,
workstream 7's app-spec concern) and discovered by the system from there. The Quick
Look host loads the appex, instantiates its principal class, and drives it to produce
a preview for a document — the host owns the process, the run loop, and termination.

## Extension point — `com.apple.quicklook.preview`

This kind plugs into `com.apple.quicklook.preview`: the principal class is a
`QLPreviewingController` (a preview view controller the host presents for a
document). The space-bar / Finder column preview is rendered by this extension point.

The sibling **thumbnail** role is a *separate* extension point —
`com.apple.quicklook.thumbnail`, whose principal class is a `QLThumbnailProvider` —
and would be its own `.appex` (and, if modeled, its own app-kind). This kind models
the preview shape, the one the `quicklook-extension` name most directly denotes.

## Required Info.plist keys

The `bundle.info-plist` block of `kind.apiw` lists the keys a `quicklook-extension`
requires. Each is platform truth — without it the host cannot load or dispatch the
extension:

| key | role |
| --- | --- |
| `CFBundleIdentifier` | the reverse-DNS bundle id — the extension's identity |
| `CFBundleExecutable` | the extension's Mach-O under `Contents/MacOS/` |
| `CFBundlePackageType` | `XPC!` — marks the bundle as an app extension |
| `NSExtension` | the extension dictionary: the `NSExtensionPointIdentifier` (`com.apple.quicklook.preview`) and the `NSExtensionPrincipalClass` (the `principal-class-key`) the host instantiates |

`CFBundlePackageType` is `XPC!`, not `APPL` — an extension is loaded by a host, not
launched as an application. The `NSExtensionPointIdentifier` and
`NSExtensionPrincipalClass` live *inside* the `NSExtension` dictionary; the kind
records the extension point via its `extension-point` node and the principal-class
key via `principal-class-key`, and requires the top-level `NSExtension` key that
carries them. Which content types the preview handles
(`NSExtensionAttributes` → `QLSupportedContentTypes`) is an importer-design detail a
concrete extension (`apps/macos/<app>/`, workstream 7) supplies on top of this floor.
