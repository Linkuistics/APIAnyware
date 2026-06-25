# spotlight-importer — indexing tests

The `kind.apiw` declares two `test-obligation` references — `importer-bundle` and
`indexing`. These are **forward pointers**: the obligation *bodies* (the
projection-free, target-independent expectation declarations) are authored later in
`platforms/macos/tests/app-kinds/spotlight-importer.apiw` (workstream 4 child 3,
`platform-tests`), and they are *executed* against a built importer by the testing
architecture (workstream 9; ADR-0046 declare-now / execute-later seam, node brief
D3). This file records what each obligation will assert, in prose. The raw inputs —
sample documents to import — come from `platforms/macos/tests/fixtures/spotlight/`.

## `importer-bundle`

Checks the on-disk `.mdimporter` is a well-formed, loadable CFPlugIn:

- the bundle has `Contents/Info.plist`, `Contents/MacOS/<CFBundleExecutable>`, and a
  `Resources/` directory;
- the Info.plist registers a CFPlugIn factory (`CFPlugInFactories`) and the Spotlight
  importer type (`CFPlugInTypes`), so the host recognizes it as an importer;
- it declares the content types (UTIs) it imports, so the host routes matching files
  to it;
- the bundle loads into a host process and its factory yields the importer interface.

## `indexing`

Drives the importer's actual job against a fixture document:

- given a sample file of a declared content type (from the `spotlight/` fixtures),
  the host loads the importer and invokes it for that file;
- the importer returns an attribute dictionary populated with the expected
  `kMDItem…` keys (e.g. a title, text content, author) extracted from the document;
- the extracted values match the fixture's known metadata — the importer reads the
  document correctly, not just structurally.

Verification can use the importer test harness (`mdimport -t -d` against the built
bundle) — the platform-truth assertion is "this importer yields these attributes for
this document," independent of how any target built the bundle.

## Boundary

This kind owns only the *declaration* of these obligations — what a
`spotlight-importer` must satisfy. It owns neither the fixtures-and-runner that
execute them (workstream 9) nor any target-specific hook that builds the importer
under test (workstream 6). The obligation names here are the stable handles those
later layers resolve against. See `host-process-constraints.md` for the constraints
the host imposes on importer code.
