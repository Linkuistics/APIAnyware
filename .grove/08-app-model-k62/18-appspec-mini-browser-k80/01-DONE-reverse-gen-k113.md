# reverse-gen-k113

**Kind:** work

## Goal

Reverse-gen the projection-free, replication-grade **mini-browser spec** from the
four VM-verified impls, per the AppSpec reverse-gen workflow
(`~/Development/AppSpec/capabilities/reverse-gen/{workflow,prompt}.md`): dispatch the
read-only subagent, validate its modeling notes (anchor order: app-kind contract >
impl behaviour > human prose), and write the accepted spec to
`apps/macos/mini-browser/docs/spec.md` (replacing the precursor prose — the lowest
anchor). The commit is the propose→review→accept boundary (ADR-0050/0052).

## Context

- Inputs: impls at `targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/
  mini-browser/` (sbcl carries extra build/run/dump scripts + a README); app-kind
  contract `platforms/macos/app-kinds/gui-app/kind.apiw`; precursor prose
  `apps/macos/mini-browser/docs/{spec,learnings,test-strategy}.md` (all three
  precursors exist — the full lowest-anchor set); portfolio catalogue
  `apps/macos/docs/_index.md` (complexity = portfolio rank); pattern-kind registry
  `semantic/pattern-kinds/`; closed verb set `~/Development/AppSpec/app-spec/main.rkt`.
- Templates: `apps/macos/hello-window/docs/spec.md` (the k64 exemplar — H1 = display
  name for the bundlers; provenance line; §1 structural facts; behavioural-exemplar
  final § mapped to the closed scenario-verb set) and
  `apps/macos/scenekit-viewer/docs/spec.md` (the k104 precedent — the
  unobservable-content + per-behaviour-verifiability shape).
- Watch for stale-prose risks (the k86/k95/k104 lesson: precursor claims that match
  *no* impl get cut) — verify every URL-entry / navigation / back-forward /
  title-tracking claim against what the impls actually realize.
- **App-specific:** the VM has **no network** — every navigation claim must be
  checked for what it means against a `file://` / local-fixture load (WKWebView may
  treat local loads differently: `loadFileURL:` vs `loadRequest:`, and any
  http(s)-only behaviour is unrunnable in-VM). WKWebView loads are asynchronous —
  note per impl how (or whether) navigation completion is observed (navigation
  delegate `didFinish`, KVO on `title`/`URL`/`canGoBack`, or polling) and how the
  URL field / title / button enablement are updated — that grounds the contract +
  suite children. The rendered page is a WKWebView subtree — per-behaviour in-VM
  verifiability (AX web-area exposure vs OCR vs log events) is itself spec-quality
  output.

## Done when

`apps/macos/mini-browser/docs/spec.md` is the validated reverse-gen spec (first H1
bundler-safe — the display name), committed with the modeling notes reviewed;
unsupported claims grounded or cut, gaps honestly marked `(to confirm in-VM)`.

## Notes

The behavioural-exemplar section is the forward-gen input for the later suite child —
it should enumerate URL entry + load, back/forward (enablement + effect), reload,
and title tracking as observable assertions where in-VM-verifiable, not just
launch/quit ([[sample_apps_perfect]]). Where a navigation behaviour has no observable
witness (or is network-only), that gap is a finding, not a failure.

## Status — done 2026-07-03 (validated & accepted)

Subagent dispatched per the AppSpec workflow; modeling notes worked; load-bearing
witnesses mechanically re-verified against all four sources (window 800×600 / min
500×400 / resizable mask ×4; toolbar stack 12,556,776,32 / spacing 8 / firstBaseline /
order ◀▶·Reload·field·Go ×4; status vocabulary Ready/Loading*/Done/Enter-a-URL/
Invalid-URL/`failed:` ×4; 4-selector nav delegate + weak `setNavigationDelegate:` ×4;
NSAlert `alertWithError:` warning + `runModal` with nil-error→no-alert ×4; normalization
trim/scheme-scan/https-prepend ×4; guarded back/forward, unconditional reload ×4;
`install-standard-app-menu!` helper bodies verified directly — racket `app-menu.rkt`,
chez `cocoa.sls:133-149`, gerbil `cocoa.ss:117` — all `"Quit " + name` / `terminate:` /
key `q`; sbcl inline Quit-only). Key acceptances:

- **The no-network launch reality is the spec's load-bearing finding:** every impl's
  home URL is a live `https` URL (racket/chez `www.apple.com`, gerbil/sbcl
  `example.com` — anti-unified to a per-impl home-URL hole), so in the k74 no-network
  VM the initial load FAILS → the §7.3 modal `NSAlert` is the expected launch-time
  observable; offline scenarios must dismiss it before driving chrome. Whether
  `loadRequest:` renders `file://` is an honest gap (to confirm in-VM) that gates the
  offline success path — seeded to the conformance/instrument children (a local
  fixture + possibly `loadFileURL:`-style instrumentation or log events to make
  success-chrome assertable offline).
- **Exemplar split network-independent vs network-required** — the success-path
  contract (Done, canonicalization, history walk, reload, title tracking) is
  network-gated and retained from the impls' earlier networked VM runs; the runnable
  offline surface is launch/AX-structure/boundary-errors/quit.
- **Precursor over-claims cut:** "clicking links navigates" (no witness in any impl —
  WKWebView default, no policy hooks; §12 states the absence); status-on-complete
  "shows page URL" (impls show `Done`, URL goes to the address field); `<`/`>` glyphs
  (impls ◀/▶); toolbar order (Reload is third, not last); `URLWithString:`/
  `requestWithURL:` (impls use `initWithString:`/`initWithURL:`); catalogue
  `NSProgressIndicator` (no impl has one). Complexity corrected 6/7 → **4/7** (the
  catalogue rank; precursor rejected).
- **Title-lag accepted as spec prose** (§7.2): `title` is often empty at
  `didFinishNavigation:` on first load (gerbil/sbcl learnings, "matches all targets")
  — title assertions must ride a second/back navigation.
- **Driver guidance folded into §13** from sbcl VM learnings: triple-click to
  select-all (Cmd-A unreliable over VNC); ◀/▶ history via the AX `enabled` flag;
  address-field text via OCR (its AX value reads empty — the k96 enabled-flag-gap
  sibling caveat); `example.{com,net,org}` all serve the same page, so the address bar
  is the navigation discriminator.
- **Common-mode flags stand** (modal-alert-on-every-failure; chrome-refresh-only-at-
  didFinish) — both to confirm in the live run; delegate-weakly-held discharged
  against `delegate.apiw`'s law.
- **Classifications confirmed:** complexity 4/7 against the catalogue row;
  `delegate` + `target-action` + `parent-child` against the registry (delegate
  genuinely applies here — `setNavigationDelegate:` ×4 — unlike scenekit).
- **Handoff to conformance/instrument children:** launch-line prefixes diverge
  (racket/chez/gerbil `Mini Browser running.` vs sbcl `Mini Browser opened.`) — the
  logging contract must pick the prefix rule or align wording; loading-text
  (`...` vs `…`) and failure-phase capitalization (`load/request` vs `Load/Request`)
  are the same class of contract-alignment candidates; navigation completion needs a
  contract log event (`didFinish`-family) to be assertable without OCR timing races.
