# gerbil macOS binding — API coverage (§22)

What the gerbil binding covers, and how faithfully. The **numbers are derived, never frozen here**
(constraint 4 — a hand-copied count would rot against SDK and binding drift). This page explains
*how to get* the coverage for the live SDK and *how to read* it; the authored judgment behind it is
[`../../../conformance/macos.apiw`](../../../conformance/macos.apiw).

## Get the report

The derived §37 conformance report — the per-API representability histogram **and** the common
app-implementation status — is rendered by the `apianyware-conformance` CLI (run from the repo
root):

```
apianyware-conformance --target gerbil            # human-readable text report
apianyware-conformance --target gerbil --json      # machine-readable, one stable record
apianyware-conformance --target gerbil --check      # exit 1 if an authored claim contradicts derived reality (CI gate)
```

The report combines two slices for gerbil:

1. **Authored judgment** — the §37 per-app-kind support call, unsupported features, research items,
   and known issues, from [`../../../conformance/macos.apiw`](../../../conformance/macos.apiw).
2. **Derived** (recomputed every run) — the representability coverage histogram (gerbil's capability
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
- **Gerbil sits a rung *below* chez on thread re-entrancy** (and level with racket). An API whose
  only weirdness demands `foreign-thread-callbacks` floors to `idiomatic-conventional` for gerbil
  (the main-thread **bounce**, ADR-0022) where it would be `exact-runtime` for chez (thread
  *activation*) — so gerbil's histogram carries slightly more weight at `idiomatic-conventional` and
  less at `exact-runtime` than chez's. This is the only place the two Schemes' histograms diverge.
- **The Swift-native residual** (`s:` USRs — `async`, `throws`, value returns, opaque handles) is
  routed through the trampoline-only `APIAnywareGerbil` dylib rather than reached directly; see
  [`../../../docs/ffi-model.md`](../../../docs/ffi-model.md).
- **`KNOWN_UNBINDABLE`** members (notably Swift actor-isolation, which the digester emits no signal
  for) are recorded as `unsupported` in the authored slice — surfaced, never silently dropped.

## App-kind coverage at a glance

The authored §37 call (grounded in the §36 app-form capability rungs + VM-verify reality, and
cross-checked by the CLI) — see [`../../../conformance/macos.apiw`](../../../conformance/macos.apiw)
for the rationale per kind:

| app-kind | status | note |
|---|---|---|
| `cli-tool` | pass | gerbil runs headless trivially; no dedicated CLI sample ships |
| `gui-app` | pass | self-contained static-executable `.app` (ADR-0021); **seven** GUI sample apps VM-verified |
| `menu-bar-daemon` | partial | feasible as an `LSUIElement` `.app` over the proven bundle path; no dedicated sample yet |
| `launch-agent` | partial | launchd plist over the self-contained executable; not demonstrated end-to-end |
| `spotlight-importer` | research | loading the gerbil runtime into an `.mdimporter` is unestablished |
| `quicklook-extension` | research | loadable-bundle / app-extension hosting of the runtime is unestablished |
| `finder-sync-extension` | research | app-extension + App Sandbox unestablished |

(`pass`/`partial`/`research` is the authored stance; the *derived* per-app status — which sample
apps actually have green VM-verify reports — comes from the CLI run, and `--check` flags any
disagreement.)

## A known issue worth flagging up front

The ADR-0021 **bottle toolchain hardcodes gcc-15** for `gxc`; a build host carrying only gcc-16
needs the `/tmp/aw-gcc15-shim` symlink, or `gxc` fails with `gcc-15: command not found`. It is a
**build-host** issue, recorded as a `known-issue` in the authored conformance slice so it surfaces
in the report. (The cold build is also long — the sharded, parallel `generics.ss` compilation,
ADR-0023, brings it to ~8.4 min — but that is a build-time cost paid once, not a runtime one.)

## See also

- [`../../../docs/representability.md`](../../../docs/representability.md) — the ladder + derivation.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching what the binding doesn't model.
- The CLI source of truth: `targets/_shared/tools/conformance-cli/`.
