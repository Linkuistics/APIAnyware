# chez macOS binding — API coverage (§22)

What the chez binding covers, and how faithfully. The **numbers are derived, never frozen here**
(constraint 4 — a hand-copied count would rot against SDK and binding drift). This page explains
*how to get* the coverage for the live SDK and *how to read* it; the authored judgment behind it is
[`../../../conformance/macos.apiw`](../../../conformance/macos.apiw).

## Get the report

The derived §37 conformance report — the per-API representability histogram **and** the common
app-implementation status — is rendered by the `apianyware-conformance` CLI (run from the repo
root):

```
apianyware-conformance --target chez             # human-readable text report
apianyware-conformance --target chez --json       # machine-readable, one stable record
apianyware-conformance --target chez --check       # exit 1 if an authored claim contradicts derived reality (CI gate)
```

The report combines two slices for chez:

1. **Authored judgment** — the §37 per-app-kind support call, unsupported features, research items,
   and known issues, from [`../../../conformance/macos.apiw`](../../../conformance/macos.apiw).
2. **Derived** (recomputed every run) — the representability coverage histogram (chez's capability
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
- **Chez sits a rung above racket on thread re-entrancy.** An API whose only weirdness demands
  `foreign-thread-callbacks` floors to `exact-runtime` for chez (thread *activation*, ADR-0016)
  where it would be `idiomatic-conventional` for the bounce-based targets — so chez's histogram
  carries slightly more weight at `exact-runtime`.
- **The Swift-native residual** (`s:` USRs — `async`, `throws`, value returns, opaque handles) is
  routed through the `APIAnywareChez` adapter rather than reached directly; see
  [`../../../docs/ffi-model.md`](../../../docs/ffi-model.md).
- **`KNOWN_UNBINDABLE`** members (notably Swift actor-isolation, which the digester emits no signal
  for) are recorded as `unsupported` in the authored slice — surfaced, never silently dropped.

## App-kind coverage at a glance

The authored §37 call (grounded in the §36 app-form capability rungs + VM-verify reality, and
cross-checked by the CLI) — see [`../../../conformance/macos.apiw`](../../../conformance/macos.apiw)
for the rationale per kind:

| app-kind | status | note |
|---|---|---|
| `cli-tool` | pass | chez runs headless trivially; no dedicated CLI sample ships |
| `gui-app` | pass | open-world standalone `.app` (ADR-0009); **seven** GUI sample apps VM-verified |
| `menu-bar-daemon` | partial | feasible as an `LSUIElement` `.app` over the proven standalone bundle; no dedicated sample yet |
| `launch-agent` | partial | launchd plist over the self-contained executable; not demonstrated end-to-end |
| `spotlight-importer` | research | loading the chez runtime into an `.mdimporter` is unestablished |
| `quicklook-extension` | research | loadable-bundle hosting of the runtime is unestablished |
| `finder-sync-extension` | research | app-extension + App Sandbox unestablished |

(`pass`/`partial`/`research` is the authored stance; the *derived* per-app status — which sample
apps actually have green VM-verify reports — comes from the CLI run, and `--check` flags any
disagreement.)

## A known issue worth flagging up front

The open-world standalone build pays a **one-time whole-program compile at build time (~160 s)**;
the shipped bundle launches in **~0.29 s** (ADR-0009). It is a build-time cost, not a runtime one —
recorded as a `known-issue` in the authored conformance slice so it surfaces in the report.

## See also

- [`../../../docs/representability.md`](../../../docs/representability.md) — the ladder + derivation.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching what the binding doesn't model.
- The CLI source of truth: `targets/_shared/tools/conformance-cli/`.
