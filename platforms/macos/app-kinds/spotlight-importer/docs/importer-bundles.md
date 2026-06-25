# spotlight-importer — importer bundles

A `spotlight-importer` ships as a `.mdimporter` **CFPlugIn** bundle. This documents
that bundle shape and the keys the kind *requires*, as platform truth. It does not
say how any target's bundler writes them (that is `targets/`, workstream 6).

## The `.mdimporter` CFPlugIn

A Spotlight importer is a *plug-in*, not an application: the indexing host loads it
into its own process to extract metadata. It uses the classic **CFPlugIn**
mechanism — a loadable bundle that registers a C **factory function**, not an
Objective-C principal class. This is why the kind carries no `principal-class-key`:
there is no principal class to name; the entry point is a factory the host looks up
through the CFPlugIn type/factory tables.

```text
MyKindImporter.mdimporter/
  Contents/
    Info.plist            # CFPlugIn factory + type registration (below)
    MacOS/
      MyKindImporter      # the CFBundleExecutable — the loadable Mach-O
    Resources/            # schema.xml, schema.strings, localizations
    _CodeSignature/
```

The host (`mdworker` / the Spotlight indexing machinery) discovers importers by
their declared content types, loads the matching `.mdimporter`, and calls its
factory to obtain the importer interface for a file. The importer is loaded and
unloaded by the host — it has no run loop or lifetime of its own.

## Required Info.plist keys

The `bundle.info-plist` block of `kind.apiw` lists the keys a `spotlight-importer`
requires. Each is platform truth — without it the host cannot load or dispatch the
plug-in:

| key | role |
| --- | --- |
| `CFBundleIdentifier` | the reverse-DNS bundle id — the importer's identity |
| `CFBundleExecutable` | the loadable Mach-O under `Contents/MacOS/` |
| `CFPlugInFactories` | maps a factory **UUID** to the C factory function name |
| `CFPlugInTypes` | maps the Spotlight importer **type UUID** to the factory UUID(s) — this is what marks the bundle as an importer the host will load |

The bundle must also declare **which content types** it imports — historically via
`CFBundleDocumentTypes` / `LSItemContentTypes` (the UTIs the importer claims) — so
the host routes the right files to it. The exact spelling of that declaration is an
importer-design detail layered on top of the kind's required CFPlugIn floor; a
concrete importer (`apps/macos/<app>/`, workstream 7) supplies it.

Note there is **no `CFBundlePackageType` of `APPL`** and **no `NSPrincipalClass`** —
this is a loadable CFPlugIn, not an application and not an NSExtension-style appex.
The modern alternative, a Core Spotlight `com.apple.spotlight.import` app extension,
is a *different* shape (a `.appex`); this kind models the classic `.mdimporter`
that the `mdimporter` bundle type names.
