# quicklook-extension — test obligations

The `kind.apiw` declares two `test-obligation` references — `extension-bundle` and
`preview`. These are **forward pointers**: the obligation *bodies* (the
projection-free, target-independent expectation declarations) are authored later in
`platforms/macos/tests/app-kinds/quicklook-extension.apiw` (workstream 4 child 3,
`platform-tests`), and they are *executed* against a built extension by the testing
architecture (workstream 9; ADR-0046 declare-now / execute-later seam, node brief
D3). This file records what each obligation will assert, in prose. The raw inputs —
documents to preview — come from `platforms/macos/tests/fixtures/sample-documents/`.

## `extension-bundle`

Checks the on-disk `.appex` is a well-formed, loadable app extension:

- the bundle has `Contents/Info.plist`, `Contents/MacOS/<CFBundleExecutable>`, and
  `CFBundlePackageType` is `XPC!`;
- the `NSExtension` dictionary declares `NSExtensionPointIdentifier`
  `com.apple.quicklook.preview` and an `NSExtensionPrincipalClass`;
- the principal class resolves and loads when the host instantiates it;
- the extension declares the content types it supports, so the host routes matching
  documents to it.

## `preview`

Drives the extension's actual job against a fixture document:

- given a sample document of a supported content type (from the `sample-documents/`
  fixtures), the Quick Look host loads the extension and asks it to prepare a preview;
- the principal class produces a preview without error (a rendered view / preview
  representation for the document);
- the preview reflects the document's content — the host-driven, `host-controlled`
  lifecycle completes and the extension is torn down cleanly.

## Boundary

This kind owns only the *declaration* of these obligations — what a
`quicklook-extension` must satisfy. It owns neither the fixtures-and-runner that
execute them (workstream 9) nor any target-specific hook that builds the extension
under test (workstream 6). The host-process constraints on extension code (no UI of
its own beyond the preview surface, sandboxed, host-owned lifetime) are the same
hosted-process facts described for the importer kind. The obligation names here are
the stable handles those later layers resolve against.
