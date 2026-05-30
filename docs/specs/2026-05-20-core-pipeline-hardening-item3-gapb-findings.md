# Core Pipeline Hardening — Item 3 Gap B Findings: Integer-Contract Investigation

**Date:** 2026-05-21
**Status:** DONE
**Task:** 9 of the Core Pipeline Hardening plan ([INVESTIGATION-GATED])

---

## 1. Executive Summary

Design Item 3 Gap B stated that `NSInteger`/`NSUInteger` integer-typed parameters
and returns "fall through to `any/c`" in `map_contract`'s **primitive** arm
(`generation/crates/emit-racket/src/emit_functions.rs:34-49`), citing the
golden `[tkbutton-tag (c-> objc-object? any/c)]` as evidence.

The investigation **refutes that premise** and finds a different, larger real
gap:

1. **The primitive arm has no real-pipeline gap.** Every integer primitive in
   the collected/resolved/enriched IR is already a canonical fixed-width name
   (`int8/16/32/64`, `uint8/16/32/64`) that `map_contract` recognises and maps
   to `exact-integer?` / `exact-nonnegative-integer?`. The ObjC extractor
   canonicalises `NSInteger`→`int64` and `NSUInteger`→`uint64` at extraction
   time (`collection/crates/extract-objc/src/type_mapping.rs:262-270`).

2. **The golden `tkbutton-tag any/c` is a test-fixture bug.**
   `generation/crates/emit/src/test_fixtures.rs::type_int()` hand-codes the raw,
   un-canonical primitive name `"NSInteger"`, which the real extractor never
   emits. `normalize_primitive("NSInteger")` → `"nsinteger"`, unrecognised →
   `any/c`. The fixture misrepresents extractor output.

3. **The real gap is in `map_contract`'s `Alias` arm** (lines 73-83): every
   framework-prefixed alias maps unconditionally to
   `exact-nonnegative-integer?`. **716 distinct *signed* enum typedefs**
   (`NSComparisonResult`, `NSTextAlignment`, `NSWritingDirection`, …, all
   `int64`/`int32`-backed) hit that arm, so their contracts reject legitimate
   negative cases — e.g. `NSComparisonResult.orderedAscending = -1`. The
   `underlying_primitive` field that carries the signedness (added 2026-04-18)
   is parsed and present but **ignored by the contract mapper**.

---

## 2. Method

A Python pass over `analysis/ir/resolved/*.json` (284 frameworks) enumerated
every `{"kind":"primitive","name":…}` node, and a second pass over
`analysis/ir/enriched/*.json` classified each by the JSON key it sits under
(`param_type` / `return_type` / `property_type` / `constant_type` —
the positions that reach `map_contract` — versus `type`, the `Enum.enum_type`
field).

---

## 3. Q1 — Which integer primitives reach `map_contract`'s `any/c` fallthrough?

**None.** The distinct `Primitive` names across all 284 resolved frameworks:

| name | count | recognised by `map_contract`? |
|---|---|---|
| `void` | 157788 | yes |
| `bool` | 50323 | yes |
| `int64` | 14610 | yes → `exact-integer?` |
| `uint64` | 13334 | yes → `exact-nonnegative-integer?` |
| `double` | 12591 | yes |
| `int32` | 10631 | yes → `exact-integer?` |
| `uint32` | 6623 | yes → `exact-nonnegative-integer?` |
| `float` | 5437 | yes |
| `uint16` | 1483 | yes |
| `uint8` | 1336 | yes |
| `int16` | 450 | yes |
| `swift_enum` | 266 | **no** — but never reaches `map_contract` (see Q2) |
| `int8` | 81 | yes |

Every primitive in a `param_type` / `return_type` / `property_type` /
`constant_type` position is canonical. The real generated output confirms it:
`NSControl.tag` (an `NSInteger` property) emits
`[nscontrol-tag (c-> objc-object? exact-integer?)]`.

## 4. Q2 — `swift_enum`

`swift_enum` is the sentinel `enum_type` of `ir::Enum` declarations
(`collection/crates/extract-swift/src/declaration_mapping.rs:500`) — Swift enums
do not expose an underlying integer type in the ABI JSON. All 266 occurrences
sit under the `Enum.enum_type` field; `emit_enums.rs` handles enum declarations
and never passes `enum_type` to `map_contract`. So `swift_enum` does not reach
the contract mapper and is not a contract gap today.

## 5. Q3 — The real gap: signed enum typedefs in the `Alias` arm

`map_contract`'s `Alias` arm classifies framework-prefixed aliases (enum
typedefs such as `NSComparisonResult`) as integers but emits
`exact-nonnegative-integer?` for **all** of them, signed or not. The enriched IR
has **716 distinct alias names** with a *signed* `underlying_primitive`
(`int32`/`int64`) appearing in param/return/property positions, including:

| alias | underlying | uses | has negative cases |
|---|---|---|---|
| `NSComparisonResult` | int64 | 167 | yes (`orderedAscending = -1`) |
| `NSTextAlignment` | int64 | 73 | — |
| `NSWritingDirection` | int64 | 70 | yes (`natural = -1`) |
| `NSAccessibilityUnits` | int64 | 450 | — |
| … (716 distinct names total) | | | |

For these, `exact-nonnegative-integer?` is an **incorrect, over-tight** contract
that rejects valid negative enum values at the boundary.

## 6. Q4 — The chosen fix

Per the orchestrator's decision (investigation-gated redirection of Task 9),
all three of:

1. **Fix the test fixture.** `test_fixtures.rs::type_int()` →
   `Primitive { name: "int64" }`, matching what the real ObjC extractor emits
   for `NSInteger`. Golden `tag` contracts become `exact-integer?` and their
   `_fun` FFI types become `_int64` (previously the `_pointer` fallback).

2. **Fix the `Alias` arm.** `map_contract`'s `Alias` arm consults
   `underlying_primitive`: a signed (`int*`) underlying width emits
   `exact-integer?`; unsigned (`uint*`) or absent keeps
   `exact-nonnegative-integer?` (the historical default). This closes the
   716-typedef gap.

3. **Defence-in-depth on the primitive arm.** Add `nsinteger`/`nsuinteger`
   arms to `map_contract` (→ `exact-integer?` / `exact-nonnegative-integer?`)
   and mirror them in `ffi_type_mapping.rs::racket_ffi_type_for_primitive`
   (→ `_int64` / `_uint64`) so the contract mapper and the FFI type mapper stay
   in lockstep. The investigation shows these names are currently unreachable;
   the arms guarantee correct, consistent handling should any future extraction
   path emit a raw `NSInteger`/`NSUInteger` primitive name.

The primitive arm itself was **not** the source of a real gap — but it is
hardened so the contract mapper and FFI mapper recognise the same set.

## 7. Scope note

Task 9 as originally written targeted `emit_functions.rs:34-49` only. The
investigation expands it to three files — `emit_functions.rs` (`map_contract`),
`emit/src/ffi_type_mapping.rs` (`racket_ffi_type_for_primitive`), and
`emit/src/test_fixtures.rs` (`type_int`) — which is the minimal set that closes
the real gap and removes the misleading fixture.
