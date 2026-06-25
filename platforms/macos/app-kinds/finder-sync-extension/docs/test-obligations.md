# finder-sync-extension — test obligations

The `kind.apiw` declares two `test-obligation` references — `extension-bundle` and
`sync-badging`. These are **forward pointers**: the obligation *bodies* (the
projection-free, target-independent expectation declarations) are authored later in
`platforms/macos/tests/app-kinds/finder-sync-extension.apiw` (workstream 4 child 3,
`platform-tests`), and they are *executed* against a built extension by the testing
architecture (workstream 9; ADR-0046 declare-now / execute-later seam, node brief
D3). This file records what each obligation will assert, in prose.

## `extension-bundle`

Checks the on-disk `.appex` is a well-formed, loadable app extension:

- the bundle has `Contents/Info.plist`, `Contents/MacOS/<CFBundleExecutable>`, and
  `CFBundlePackageType` is `XPC!`;
- the `NSExtension` dictionary declares `NSExtensionPointIdentifier`
  `com.apple.FinderSync` and an `NSExtensionPrincipalClass`;
- the principal class resolves to an `FIFinderSync` subclass and loads when the Finder
  instantiates it.

## `sync-badging`

Drives the extension's actual job against a watched folder:

- the extension registers a directory as a watched/sync folder (via
  `FIFinderSyncController`) and the Finder begins routing that folder's events to it;
- when an item in the watched folder is displayed, the extension sets the expected
  badge overlay on it;
- the extension supplies its toolbar / context-menu items for a selection, and the
  host invokes the corresponding action when chosen.

## Boundary

This kind owns only the *declaration* of these obligations — what a
`finder-sync-extension` must satisfy. It owns neither the fixtures-and-runner that
execute them (workstream 9) nor any target-specific hook that builds the extension
under test (workstream 6). The host-process constraints on extension code (host-owned
lifetime, sandboxed, no process of its own) are the same hosted-process facts
described for the importer kind. The obligation names here are the stable handles
those later layers resolve against.
