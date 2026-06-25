# sbcl macOS binding — API coverage (§22)

What the sbcl binding covers, and how faithfully. The **numbers are derived, never frozen here**
(constraint 4 — a hand-copied count would rot against SDK and binding drift). This page explains
*how to get* the coverage for the live SDK and *how to read* it; the authored judgment behind it is
[`../../../conformance/macos.apiw`](../../../conformance/macos.apiw).

## Get the report

The derived §37 conformance report — the per-API representability histogram **and** the common
app-implementation status — is rendered by the `apianyware-conformance` CLI (run from the repo root):

```
apianyware-conformance --target sbcl            # human-readable text report
apianyware-conformance --target sbcl --json      # machine-readable, one stable record
apianyware-conformance --target sbcl --check      # exit 1 if an authored claim contradicts derived reality (CI gate)
```

The report combines two slices for sbcl:

1. **Authored judgment** — the §37 per-app-kind support call, unsupported features, research items,
   and known issues, from [`../../../conformance/macos.apiw`](../../../conformance/macos.apiw).
2. **Derived** (recomputed every run) — the representability coverage histogram (sbcl's capability
   profile floored against the platform's §30 weird-API surface) and the app-implementation status
   (scanned from [`../../../app-implementations/`](../../../app-implementations/) + their VM-verify
   [`reports/`](../reports/)). The CLI then cross-checks the authored exemplar claims against that
   derived reality (`--check`).

## How to read the coverage

- **Most of the ObjC surface is `exact-static`** — fully represented. The `thin-direct` projection
  posture reaches directly-dispatched ObjC with no special handling, so an API carrying no §30
  weirdness lands at the top rung (the **trampoline-elision limit**). The histogram's long tail at
  the bottom rungs is the *weird / Swift-native residual*, not the common case. The ladder and the
  floor are explained in [`../../../docs/representability.md`](../../../docs/representability.md).
- **sbcl sits a rung *below* chez on thread re-entrancy** (and level with racket/gerbil). An API whose
  only weirdness demands `foreign-thread-callbacks` floors to `idiomatic-conventional` for sbcl (the
  main-thread **bounce**, ADR-0035) where it would be `exact-runtime` for chez (thread *activation*).
  (SBCL's compensating strength — safe concurrent `sb-thread` background compute — does not show up in
  this per-API histogram; it is an app-authoring richness, not a representability rung.)
- **The Swift-native residual** (`s:` USRs — `async`, `throws`, value returns, opaque handles) is
  routed through the sole-native-unit `libAPIAnywareSbcl` dylib rather than reached directly; see
  [`../../../docs/ffi-model.md`](../../../docs/ffi-model.md).
- **`KNOWN_UNBINDABLE`** members (notably Swift actor-isolation, which the digester emits no signal
  for) are recorded as `unsupported` in the authored slice — surfaced, never silently dropped.

## App-kind coverage at a glance

The authored §37 call (grounded in the §36 app-form capability rungs + VM-verify reality, and
cross-checked by the CLI) — see [`../../../conformance/macos.apiw`](../../../conformance/macos.apiw)
for the rationale per kind:

| app-kind | status | note |
|---|---|---|
| `cli-tool` | pass | SBCL runs headless trivially; no dedicated CLI sample ships |
| `gui-app` | pass | dumped-image `.app` (ADR-0041); **seven** GUI sample apps VM-verified (hello-window, drawing-canvas, mini-browser, note-editor, pdfkit-viewer, scenekit-viewer, ui-controls-gallery) |
| `menu-bar-daemon` | partial | feasible as an `LSUIElement` `.app` over the proven dumped-image bundle; no dedicated sample yet |
| `launch-agent` | partial | launchd plist over the dumped-image executable; not demonstrated end-to-end |
| `spotlight-importer` | research | hosting a dumped SBCL image inside an `.mdimporter` loadable bundle is unestablished (and especially hard — §36 hard case) |
| `quicklook-extension` | research | loadable-bundle hosting of a dumped image is unestablished |
| `finder-sync-extension` | research | app-extension + App Sandbox unestablished |

(`pass`/`partial`/`research` is the authored stance; the *derived* per-app status — which sample apps
actually have green VM-verify reports — comes from the CLI run, and `--check` flags any disagreement.)

## Research items worth flagging up front

The authored conformance slice records two `research` items — current gaps surfaced honestly rather
than overclaimed:

- **Swift-native *method* coverage.** The `swift-native-probe` (functions / constants / initializers)
  is VM-verified, but the **receiver-handle Swift-native *method* trampolines** shipped for
  racket/chez/gerbil are **not yet ported** to sbcl — there is no `swift-native-method-probe`
  app-implementation. So sbcl's method-level Swift-native coverage is unproven end-to-end. (The §6d
  residual *shape* is invariant across the family — 51 fn + 7 const + 576 init + 554 method
  trampolines — but a shape is not a VM-verified method probe.)
- **App Sandbox.** App Sandbox entitlements have not been exercised for any sbcl app
  (`app-form sandboxing = research`).

## A known issue worth flagging up front

**`native-runtime-embedding` is unproven.** The dumped image **is** the executable, and
`libAPIAnywareSbcl` is the sole *separate* native unit (ADR-0038), so embedding the runtime into a
foreign host process (`capability native-runtime-embedding = research`) has no path yet. Recorded as a
`known-issue` in the authored conformance slice so it surfaces in the report. (This is a packaging
limit, not a per-API one — every per-API binding works in the dumped-image `.app`.)

## See also

- [`../../../docs/representability.md`](../../../docs/representability.md) — the ladder + derivation.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching what the binding doesn't model.
- The CLI source of truth: `targets/_shared/tools/conformance-cli/`.
