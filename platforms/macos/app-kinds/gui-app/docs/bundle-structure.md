# gui-app — bundle structure

A `gui-app` ships as a `.app` **bundle** — a directory the system treats as one
opaque application object. This documents the bundle shape and the Info.plist keys
the kind *requires*, as platform truth. It does not say how any target's bundler
writes them (that is `targets/`, workstream 6).

## The `.app` bundle

```text
HelloWindow.app/
  Contents/
    Info.plist            # the bundle's identity + launch metadata (below)
    MacOS/
      HelloWindow         # the CFBundleExecutable — the Mach-O the loader runs
    Resources/            # nibs, asset catalogs, icons, localizations
    _CodeSignature/       # the code-signing seal (added at signing time)
```

The bundle is launched by Launch Services, not by exec'ing the inner executable
directly: the OS reads `Contents/Info.plist`, applies its launch policy, and only
then starts `Contents/MacOS/<CFBundleExecutable>`. `CFBundlePackageType` is `APPL`
— the four-character OSType that marks the bundle as an application (distinct from a
loadable `BNDL`/`appex`/`mdimporter`).

## Required Info.plist keys

The `bundle.info-plist` block of `kind.apiw` lists the keys a `gui-app` requires.
Each is platform truth — without it the bundle is malformed or mislaunched:

| key | role |
| --- | --- |
| `CFBundleName` | the short display name (menu bar, About box) |
| `CFBundleIdentifier` | the reverse-DNS bundle id — the system's identity key for the app |
| `CFBundleExecutable` | the inner executable to run, under `Contents/MacOS/` |
| `CFBundlePackageType` | `APPL` — marks the bundle as an application |
| `CFBundleInfoDictionaryVersion` | the Info.plist format version (`6.0`) |
| `LSMinimumSystemVersion` | the floor macOS version the app declares it runs on |

These mirror the keys the project's bundlers actually emit (the shared
`stub-launcher` Info.plist template). Optional, app-specific keys
(`NSHighResolutionCapable`, `NSSupportsAutomaticGraphicsSwitching`, custom
`CFBundleURLTypes`, usage-description strings) are *not* part of the kind's required
floor — they are choices a concrete app-spec (`apps/macos/<app>/`, workstream 7)
makes, layered on top of this kind.

## Principal class

`NSPrincipalClass` is the Info.plist key naming the application object AppKit
instantiates at launch (the `principal-class-key`). For an ordinary `gui-app` it
resolves to `NSApplication`; an app that subclasses `NSApplication` names its
subclass here. The kind fixes the *key*, not the value — the value is an
app-spec/target detail.
