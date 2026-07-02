# Mini Browser — live-VM run results

Durable record of the Tier-2 live run (`live-run-k121`, 2026-07-03): the forward-generated
`#lang app-spec` suite (`scenarios/`, 13 scenarios, leaf k120) replayed against the four built
impls in a macOS VM via TestAnyware, per the AppSpec run capability
(`AppSpec/capabilities/run/workflow.md`). Data home is here (ADR-0052/ADR-0013); the
toolkit-side record is AppSpec's workflow/validation docs.

## Run environment

- **Date:** 2026-07-03.
- **VM:** `testanyware vm start --platform macos` (golden `testanyware-golden-macos-tahoe`),
  framebuffer **1920×1080** (non-HiDPI), fresh clone, **zero build provisioning** — all four
  impls are self-contained `.app`s (k116–k119 builds; racket embeds its runtime per k76, sbcl
  vendors libzstd per k75).
- **The VM had live network — the offline reality had to be manufactured.** The k74-era
  "the VM has no network" assumption no longer holds: the first probe launch loaded
  `https://www.apple.com/` and emitted `[nav] finished title="Apple"`. Since the whole suite
  is authored against the §13 offline launch reality (every scenario's preamble dismisses the
  failing home load's alert; 02 asserts the failure boundary), the run disabled the guest's
  outbound network **in-guest, keeping the host↔guest control subnet alive** (exec/agent/VNC
  ride 192.168.64.0/24):
  1. IPv4 **reject routes** — `sudo route add -net 0.0.0.0/1 127.0.0.1 -reject` and the
     `128.0.0.0/1` twin: `connect()` fails immediately with EHOSTUNREACH; the /24 interface
     route is more specific, so control traffic is untouched.
  2. IPv6 **reject routes** — `sudo route add -inet6 ::/1 ::1 -reject` + `8000::/1` twin
     (without these, happy-eyeballs hangs on the v6 path to its full timeout — curl proved
     ~15ms failure with them vs 15s+ without).
  3. A **pf belt-and-braces ruleset** (`block return … to ! 192.168.64.0/24`) — note pf's
     `block return`/`return-rst` behaved as a silent *drop* on Tahoe (slow timeouts); the
     reject routes are what make failure fast.
  4. **WebKit cache wipe** for all four bundle ids (`~/Library/{Caches,WebKit,HTTPStorages}/
     com.linkuistics.mini-browser-<impl>`) — the pre-block apple.com success could otherwise
     be served from cache.
  DNS still resolves (the NAT gateway answers), so the failure fires at the connect step:
  **`[nav] failed phase=request message="Could not connect to the server."` on every impl**
  — the launch-failure `phase` the k113 spec left to-confirm is `request`, uniformly.
- **Fixtures:** `fixtures/{page-one,page-two}.html` uploaded to `/tmp/mini-browser/fixtures/`
  (single-shot `testanyware upload`); scenarios drive them by typing the `file://` URLs.
- **Runner:** `racket AppSpec/runner/main.rkt --impl <descriptor> --run-values <config>
  --vm <id> run scenarios/`, one full-suite invocation per impl (the canonical path), at
  AppSpec `611f73c` (quit escalation + per-scenario tailer epoch reset + deadline-guarded
  content polls — no runner change was needed this run).
- **Run-values:** measured live per impl (see *Coordinates*) — `run-values.rkt`
  (chez + gerbil + sbcl, pixel-identical), `run-values-racket.rkt` (compact 22px metrics).
- Standard Tahoe-golden provisioning: `EnableStandardClickToShowDesktop -bool false`.

## Outcomes (final suite, canonical invocations)

| scenario | racket | chez | gerbil | sbcl |
|---|---|---|---|---|
| 01 launch steady-state cluster (hard) | **FAIL → OCR-class**¹ | PASS | PASS | PASS |
| 02 offline failure boundary (hard) | **FAIL → OCR-class**¹ | **FAIL → OCR-class**¹ | **FAIL → OCR-class**¹ | **FAIL → OCR-class**¹ |
| 03 blank input no-op (hard) | PASS | PASS | PASS | PASS |
| 04 invalid-URL `recording:` | PASS (confirms) | **FAIL → OCR-class**¹ ² | **FAIL → OCR-class**¹ ² | **FAIL → OCR-class**¹ ² |
| 05 bare-word https:// prepend (hard) | PASS | PASS | PASS | PASS |
| 06 empty-history clicks no-op (hard) | **FAIL → OCR-class**¹ | **FAIL → OCR-class**¹ | **FAIL → OCR-class**¹ | **FAIL → OCR-class**¹ |
| 07 typed-URL fixture load (hard) | PASS | PASS | PASS | PASS |
| 08 fixture-renders OCR `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |
| 09 Go ≡ Return (hard) | **FAIL → driver race**³ | PASS | PASS | PASS |
| 10 history walk (hard) | PASS | PASS | PASS | PASS |
| 11 reload re-navigates (hard) | PASS | PASS | PASS | PASS |
| 12 Command-Q terminates (hard, mandated) | PASS | PASS | PASS | PASS |
| 13 close-button keep-running `recording:` | PASS (confirms) | PASS (confirms) | PASS (confirms) | PASS (confirms) |

¹ Run-mechanism (OCR small-text, k103 class) — adjudicated below; each obscured fact
independently confirmed via the AX artifact channel.
² The recording expectation itself is CONFIRMED (NSURL rejects; status prefix correct) —
live-green on racket, artifact-confirmed on the other three — and the k120-seeded suffix
ambiguity resolves to §6.2 "normalized" (see adjudication).
³ Run-mechanism (driver keyboard/mouse channel race) — racket only; adjudicated below.

## Adjudication

### 02/04/06 (+ racket 01) — OCR small-text class (k103), not an impl or spec defect

Every OCR-class red is one of the 11-pt whole-screen-OCR reads the k120 generation notes
pre-flagged as the suite's OCR-gated residue (`failed:` in 02/06, `Invalid URL` in 04,
plus 01's `https://` prefill read on racket). The runner's own failure dumps carry the
smoking gun — the engine *sees* the text and garbles it deterministically:

- 02/06 (chez, and gerbil/sbcl identically on the shared layout): `request failed: Could
  not connect to the server.` OCR'd as **`reguest talled: Could not connect to the
  server.`** (q→g, f→t) — the `failed:` substring can never match.
- 04 (chez/gerbil/sbcl): `Invalid URL: https://not a url` OCR'd as
  **`Invale UR hitos not a ur`**.
- racket (compact 22px metrics — different casualties, same class): the status line reads
  correctly except the **colon becomes a period** (`request failed.` — 02/06 still red),
  the address-field URL garbles (**`httos://www.annle.com`** — failing 01's `https://`
  read, which is green on the other three), while `Invalid URL` reads *cleanly* (04
  live-green on racket alone).

Plus the classic k103 dump signature: menu-bar icons as text (`Q`, `EN`), traffic lights as
`› • •`. The asserted facts are all TRUE via the AX artifact channel:

- 02: the failure artifact's `ax.json` carries the status text exactly —
  `request failed: Could not connect to the server.`; the screenshot shows it crisp.
- 04: `ax.json` carries `Invalid URL: https://not a url` and the events tail shows **no
  scenario-driven `[nav]` event** — the §6.2 no-op held.
- 06: events tail shows no `[nav]` event from the ◀/▶ clicks; the status text is unchanged
  in `ax.json`; `expect-running-app` passed before the OCR line.

Feedback to forward-gen (recorded, not applied — the suite is never patched from the run
loop): 03/07/09/11 prove the **status value→AXTitle fold** is the reliable channel for
deterministic status strings; 02's "stable substring" rationale for OCR (the phase word is
impl-realized) could instead ride a per-impl-agnostic AX pattern — but `expect-ax #:title`
is exact-match-only, so a substring-capable AX verb (or binding the full per-impl status
strings as run-values) is the regen-time option. Adjudicate-by-artifact remains the
standing practice meanwhile.

### racket 09 — the type→click driver race (NEW run-mechanism class, solo-confirmed deterministic)

`wait-for-log: [nav] started url="file:…page-two.html" did not appear` — but the events
tail shows the impl **did navigate, to a truncated URL**:
`[nav] started url="file:///tmp/mini-browser/fixtures/pa"` →
`[nav] failed phase=request message="The requested URL was not found on this server."`
(in-suite; the solo re-run reproduced it at `…fixtures/p` — ~36 of 48 typed characters
delivered before the Go click landed). Mechanism: 09 is the suite's only **`type` followed
immediately by a mouse click** (Go); the VNC mouse event overtakes the tail of the
keyboard stream, so Go fires on a half-typed field. Return-submitted scenarios are immune
by construction (Return rides the same keyboard channel — racket 07/10/11 all green,
including two 48-char typed URLs in 10), and 11's Reload click follows a *completed* load,
not a pending type. Only racket exposes the race — its per-keystroke main-thread dispatch
is slower than the other three runtimes' — and it does so deterministically.

**Not an impl defect:** the impl navigated to exactly its field content and failed with
the correct not-found event; §6.3's Go≡Return sharing is witnessed even in the red (Go
fired the same `[nav]` pipeline), and the behaviour is green on the other three impls.
**Feedback recorded (suite not patched):** (a) to reverse-gen — a §13 driver-guidance
line: *after `type`, settle before clicking a button; Return-submits are race-free*;
(b) to forward-gen — the realization rule mirroring the existing click-sequence-break
waits; (c) candidate TestAnyware/AppSpec driver fix — serialize mouse events behind the
pending keyboard queue. Until one lands, racket 09 stays red by design (the gallery-03 /
scenekit-07 stays-red-until-regen precedent).

### 04 — the k120-seeded spec ambiguity RESOLVES: the suffix is the normalized text

The `Invalid URL: <text>` suffix question (§6.2 "normalized" vs observable-state "typed")
is answered by the artifact: the status reads `Invalid URL: https://not a url` — the
**https://-prepended, normalized** input — while the address field still shows the raw
typed `not a url`. §6.2's wording is correct; the observable-state map's "typed" is the
error. **Feedback to reverse-gen** on regeneration (with the artifact as evidence).

### Recording passes — confirmations (signal recorded, no spec edited as a side effect)

- **08 —** WKWebView-rendered fixture text **is OCR-observable in-VM**: the 72px ALL-CAPS
  `FIXTURE ONE` marker read cleanly after the driven load. The observable-state provisional
  row firms; reverse-gen may add/harden a §13 rendering-outcome line (closing the "no
  rendering line" spec-quality gap k120 recorded).
- **13 —** close hides the window, the gui-app keeps running (the fifth app to confirm the
  §3.9 expectation; reverse-gen may drop the `(to confirm in-VM)` marker).

## Coordinates — measured live (per-impl geometry practice)

Measured per impl from `agent snapshot --window "Mini Browser" --json` (AX position+size →
element centre, framebuffer px), **two-launch determinism diff before binding** — all four
impls byte-identical across relaunches (no gallery-style ambiguous-layout defect; the
toolbar is an intrinsically-sized horizontal stack):

- **chez + gerbil + sbcl pixel-identical** (window (560,115) 800×632, 26px control metrics,
  toolbar centre-line fb y 171): ◀ (590,171), ▶ (632,171), Reload (691,171), address field
  (1015,170), Go (1327,171), close (576,131). Share `run-values.rkt`. (The share-set matches
  pdfkit's, not the gallery's or scenekit's — measured, never assumed.)
- **racket** (`run-values-racket.rkt`): compact 22px metrics — window (560,116) 800×628,
  centre-line y 167: ◀ (587,167), ▶ (625,167), Reload (678,167), address (1009,166),
  Go (1330,167), close (574,130); 12px traffic lights.
- The k120 **provisional estimates all landed within their control bounds** (close-button
  exact; worst was Reload, 6px off-centre) — the spec-derived geometry projection
  (window-frame + [NSWindow center] bias + intrinsic stack sizing) is validated as a
  provisional-coordinate method for this window shape.

## To-confirm rows firmed at live-run

- **Launch-failure phase is `request`** on all four impls (`[nav] failed phase=request
  message="Could not connect to the server."`) — 01/02's loose matchers can firm on regen.
- **The failure alert's AX shape** (chez, launch1): window role `dialog` titled `alert`,
  260×176, children: image "Mini Browser alert", static text `Could not connect to the
  server.` (the event's message verbatim), empty static text, **button OK `[focused]`** —
  Return dismisses without a focus dance.
- **◀/▶ `enabled` flags at empty state:** `false`/`false` in raw
  `agent snapshot --mode layout` on every impl (the k96 adjudication channel; the
  `expect-ax #:enabled?` AppSpec backlog item remains the closer).
- **The address field's AX value is READABLE in raw snapshots** (`value:
  "https://www.apple.com"`, and the typed text in 04's artifact) — sharper than k113's
  "AX value reads back empty" caveat: the *raw agent snapshot* channel carries the value;
  whichever driver-path read produced the k113 caveat, artifact-time AX is a working
  channel for field content.
- **WKWebView AX exposure:** post-failure the web view surfaces as an (empty)
  `scroll-area` — no `AXWebArea` subtree in the layout snapshot on any impl at the
  post-dismissal steady state. Fixture-DOM AX observability stays unprobed (OCR carried
  08); a spec-quality note for reverse-gen.
- **Post-dismissal status spelling (chez):** `request failed: Could not connect to the
  server.` — the `<phase> failed: <message>` shape with the phase word lowercase.
- **Post-dismissal focus (chez):** focus lands on Reload after the alert's Return
  dismissal.

## Per-impl notes

### chez — 10/13, all three reds OCR-class

Canonical invocation, no solo re-runs needed; no runner defect; no impl defect. The three
reds adjudicate to the k103 OCR small-text class (above); every hard behavioural assertion
that rides log/AX channels is green, including the full history walk (10 — the ordered
`(?s:)` chain matchers held) and the reload chain (11).

### gerbil — 10/13, verdict vector identical to chez

Canonical invocation; no impl defect. 02/04/06 red on the same OCR reads with the same
deterministic garble (`reguest talled: …` over the `https://example.com` prefill — the
gerbil home URL differing from chez's changes nothing; the pixels of the 11-pt status
line garble identically on the shared layout). All hard log/AX assertions green,
including the history walk and reload chains. The k116 gerbil-only `string-length`
shadowing fix is exercised throughout (every scenario's address-field text handling).

### sbcl — 10/13, verdict vector identical to chez/gerbil

Canonical invocation; no impl defect. 02/04/06 red on the same OCR class (sbcl shares the
chez/gerbil pixel-identical layout and the `example.com` home URL with gerbil). The
`opened.`-prefix launch line divergence is invisible to the suite by construction (01
asserts only the `Mini Browser` prefix — the logging-contract prefix rule earning its
keep). All hard log/AX assertions green, including the history walk and reload chains.

### racket — 9/13; three OCR-class reds + the type→click driver race

Canonical invocation + a solo 09 re-run; no impl defect. Divergences from the other three:

- **01 red / 04 green — the OCR garble is layout-dependent.** On racket's compact 22px
  metrics the engine reads the *status line* mostly right but drops the colon
  (`request failed.` — so 02/06's `failed:` still never matches) and garbles the *address
  field* (`httos://www.annle.com` — so 01's `https://` read fails, the assertion that is
  green on the other three). Conversely `Invalid URL` reads cleanly on racket — 04 is a
  live OCR-channel green here where the other three needed artifact adjudication. Same
  k103 class, different casualties per layout.
- **09 red — the driver keyboard→mouse channel race (solo-confirmed deterministic).** See
  adjudication below.

## Spec-quality findings for the next reverse-gen regeneration

Carried from k120's seeds, updated with run evidence:

1. **`Invalid URL:` suffix** — RESOLVED: normalized (§6.2 correct, observable-state
   "typed" wrong); artifact evidence in hand.
2. **§13 lacks a rendering-outcome line** — 08's pass shows a firm line is now writable
   (72px marker OCR is reliable); promote from the observable-state provisional row.
3. **`[nav] failed` carries no `url` key** — unchanged; a second failure is still
   indistinguishable from the launch failure in the buffer (05 works around it by not
   waiting on the failure at all). Candidate contract enrichment.
4. **Window-title tracking is offline-unassertable** (the k116 title-lag platform fact) —
   confirmed; stays network-gated.
5. **Launch-failure phase** — firmable to `request` (uniform across impls).
6. **Status-line OCR reads are unreliable at 11pt** — 02/04/06's channel (and 01's
   `https://` on racket); regen should prefer AX where possible (see adjudication).
7. **NEW — `type` → button-click needs a settle** (the racket 09 race): a §13
   driver-guidance line "after `type`, settle before clicking a button; Return-submits
   are race-free", and the matching forward-gen realization rule. Candidate
   TestAnyware/AppSpec driver fix: serialize mouse events behind the pending keyboard
   queue.

## Acceptance inputs (for the toolkit-side verdict)

Condition (c) of the run workflow's cross-impl acceptance review, folded:

- **No impl defect on any of the four impls.** Final tallies: racket 9/13, chez 10/13,
  gerbil 10/13, sbcl 10/13. Every red adjudicates to a run-mechanism class — the k103 OCR
  small-text channel (02/04/06 everywhere; 01 on racket) or the new type→click driver race
  (09, racket only) — and every behavioural fact behind a red is independently proven
  through a second channel (AX artifacts for the status/prefill facts; the other impls'
  greens plus the truncated-URL event trace for Go≡Return).
- **The mandated invariant held everywhere:** 12 (Command-Q terminates,
  `shutdown reason=menu` + process-gone) green on all four impls.
- **The behavioural core is green on all four impls on the log/AX channels:** launch
  steady-state (AX cluster), blank/invalid-input no-ops, the https:// prepend witness, the
  fixture success path, fixture rendering (OCR marker), Go≡Return (three impls live, the
  fourth by event-trace + cross-impl), the full history walk (enablement booleans, back,
  forward, address reverts), reload, close-button keep-running.
- **All three `recording:` scenarios confirm their expectations** (04 NSURL rejection —
  live on racket, artifact-confirmed on the rest; 08 rendered-text OCR observability;
  13 close-button keep-running) — reverse-gen may act on the drop-the-marker signals on
  regeneration.
- The OCR-class and driver-race reds stay red by design until a regeneration folds the
  corrected channels/choreography in (the gallery-03 / pdfkit-07 / scenekit-07 precedent);
  they are recorded findings, not acceptance blockers.
