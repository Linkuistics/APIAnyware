# schema-validation-k149

**Kind:** planning

## Goal

Open **workstream 8 — schemas + validation** (root BRIEF decomposition #8:
`schemas/` — "formal validation of every artifact"). Grill the scope, sharpen
`CONTEXT.md`, and **grow the ws8 node** (via `leaf-decompose` when the shape is
clear) with ordered child leaves. The deliverable is *more tree*, not code — do
only the first child this session if one is obvious, else stop at the decomposition.

This session does **not** open ws9 (testing architecture); that is grown after ws8
retires (lazy materialization — do not pre-spawn).

## Context (pointers beyond the brief chain)

The root BRIEF is the charter; read its **Seams for the remaining workstreams**
subsections — every prior workstream (ws2–ws7) deferred a concrete slice to ws8.
Synthesized, the standing ws8 seam is:

- **Machine JSON Schema for the derived IR.** ws2–ws6 each authored their `.apiw`
  **KDL-Schema** + a *focused in-crate validator*, but explicitly left ws8 the
  **machine JSON Schema** for `extracted.json` / `resolved.json` (the JSON IR that
  survived the k17 KDL-serde NO-GO) + JSON Schema for any derived machine report.
  ws5 specifically: the `resolved.json` serde grew the full provenance ladder +
  `superseded-by`; its machine JSON Schema is ws8's.
- **Validation tooling/CI.** Today validation is per-artifact, in-crate. ws8 owns
  unifying it into validation **tooling** + **CI gating** ("formal validation of
  *every* artifact"). Note `Makefile` already has `lint-annotations` (ws5) and
  `validate_apiw` (ws2) — ws8 rationalizes these into one story.
- **AppSpec is explicitly NOT ws8's (ws7 D1, ADR-0052).** `#lang app-spec` is the
  external AppSpec project's format; **AppSpec owns its own reader/validation**. The
  "ws8 owns the machine JSON Schema" seam does **not** extend to AppSpec data — there
  is no grove-authored AppSpec artifact for ws8 to schema. Do not reintroduce it.

State to read before grilling:

- `schemas/` tree — **all** the `.apiw` KDL-Schemas already exist
  (`spec-format/{target,capability,idioms,policy,adapter-spec,conformance,platform,
  app-kind,app-kind-tests,api-semantics,pattern-kinds,annotations}.kdl-schema`) +
  `schemas/README.md` + `schemas/docs/`. ws8 is **not** re-authoring these — it adds
  the machine-JSON layer + the validation mechanism + a coherent `schemas/` home.
- `REFACTOR.md` §45 criterion 13 (structural "obvious place for schemas … and tests"
  — already met) and §47 end-state; the machine-IR-is-gitignored / recomputable
  facts (constraint 4) in `CONTEXT.md`.
- The k17 KDL-serde NO-GO (ADR-0047 / spec-format outcomes) — why the machine IR is
  JSON, not KDL.

## Grilling agenda (open questions — decide *with* the user, don't pre-answer)

1. **Does "formal validation of every artifact" want a machine JSON Schema at all?**
   The authored `.apiw` artifacts already have in-crate KDL-Schema validators; the
   machine IR (`extracted.json`/`resolved.json`) is **derived + gitignored**
   (recomputable). What does validating a derived artifact buy — a contract for
   external consumers, a regression guard, or nothing beyond the goldens? WDYT.
2. **Where does validation *run* — CI gate, pre-commit, pipeline step?** Unify
   `validate_apiw` + `lint-annotations` into one `apianyware-validate`-style story, or
   leave them federated?
3. **Is `schemas/` a passive catalogue or an active tool home?** (Crate-home
   convention: a `schemas/tools/` crate vs. validators staying in each producing crate.)
4. **Derived-report schemas** — does any machine report (conformance coverage,
   capability/representability derivation) get committed + schema'd, or stay
   on-demand (ws6/ws7 kept coverage derived, index points at it)?

## Done when

The ws8 node is grown: `10-schema-validation-k149.md` is `leaf-decompose`d into
`10-schema-validation-k149/` with a `BRIEF.md` charter + ordered child leaves that
carve ws8 into buildable increments (skeleton-first, golden-neutral by default —
match the ws2–ws7 cadence). `CONTEXT.md` updated inline for any resolved term; an
ADR raised only if a decision is hard-to-reverse/surprising/a real trade-off; a PRD
only at a genuine agreement point. First child done this session only if obvious.

## Notes

- Kin cadence: ws2–ws7 each began as a root leaf whose planning session grilled then
  `leaf-decompose`d into a node (`spec-format-k16`, `semantic-model-k27`, …). Follow it.
- Golden-invariance has held across every workstream (emit goldens unmoved). ws8 is
  tooling/schema — it should stay golden-neutral; flag loudly if any decision moves goldens.
- After ws8 retires, **ws9 (testing architecture)** is the last workstream, then the
  grove-finish cycle (this branch is ~236 commits ahead of main; the physical
  `APIAnyware-MacOS` → `APIAnyware` rename is a post-merge manual step per `MIGRATION.md`).
