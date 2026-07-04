# build-plan-k151

**Kind:** planning

## Goal

With the spike (`01-machine-format-spike-k150`) done and the user's go/no-go on the numbers in
hand, **fix the machine-IR format decision**, raise the ADR that supersedes the ADR-0046 k17
Update, resolve the questions the node BRIEF deferred here, and **grow the concrete ws8 build
leaves**. Deliverable is *more tree* (+ the format ADR); do only an obvious first build child this
session if one is clear, else stop at the decomposition.

## Context

The node BRIEF carries the running log (D1/D2), the deferred open questions, and the current-tree
state — read it. This leaf exists because the whole build shape forks on the spike outcome, so it
could not be planned before `01` ran. Read `01`'s spike report + recommendation before grilling.

## Grilling agenda (decide *with* the user; the branch depends on the spike outcome)

Foundational: **confirm the machine-IR format** (KDL if the spike cleared the user's bar, else
JSON) and **raise the format ADR**. Then, by branch:

- **If KDL (spike passed):** the machine IR migrates to KDL and validation unifies to one schema
  language. Likely build leaves: the codec/pipeline cutover (golden-neutral at the emit layer);
  the **machine-KDL-Schema** over the IR reusing `validate_against_schema`; the unified validation
  mechanism; the `schemas/docs/` prose. Update `CONTEXT.md` "Spec format" (retire the machine-IR-is-
  JSON _Avoid_ note; the "KDL everywhere" that k17 forbade is now — measuredly — back for the
  machine side).
- **If JSON (spike failed):** apply the ws7 D3 test — does a **real external/cross-language consumer
  of the machine IR exist**? If no (the likely answer), **defer** the machine JSON Schema and record
  the trigger; ws8 shrinks to the unified mechanism + prose over the already-comprehensive authored
  validation.

Then the branch-independent questions (node BRIEF): **where validation runs** (CI is net-new — is it
in scope? unify `validate_apiw` + `lint-annotations` into one command?); **`schemas/` passive
catalogue vs active tool home**; **derived-report schemas** (commit + schema, or stay on-demand like
ws6/ws7 coverage). Each is a WDYT with a recommended answer.

## Done when

The format ADR is raised; `CONTEXT.md` updated inline for any resolved term; the ws8 build leaves
are grown as ordered children of the `schema-validation-k149` node (skeleton-first, golden-neutral by
default); a PRD only if a genuine agreement point is reached.

## Notes

- Externalize, don't absorb: this is a planning leaf — grow leaves, don't build. If a build child is
  obvious *and* small, do only the first.
- Keep the mechanism lean (mirror ws5's "lean mechanism over git + the pipeline, not a subsystem"):
  the engine + comprehensive per-crate registry tests already exist; prefer unifying/wiring what's
  there over new machinery.
