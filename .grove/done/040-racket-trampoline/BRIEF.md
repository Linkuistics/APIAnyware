# 040-racket-trampoline — brief

**Kind:** node (design done; build remains)

## Goal

Make the recovered Swift-native residual actually bindable end-to-end on the
**racket** pioneer: extend `libAPIAnywareRacket` to **vend C-ABI trampolines**
for it, and have the racket emitter bind them. Scope is **complete marshalling to
the limit of the C ABI** (user directive: "defer nothing"), not a depth-0 slice.

## Design — settled this session (grilling 2026-06-15)

Recorded in **ADR-0027** + **`docs/specs/2026-06-15-racket-trampoline.md`**.
Three load-bearing forks resolved with the user:

1. **Call mechanism — call by name, import the module.** Generated `@_cdecl`
   Swift wrappers `import <Framework>` and call the API by reconstructed
   name+labels; swiftc type-checks. (Rejected: binding the mangled `s:` symbol via
   `@_silgen_name`/dlsym — hand-replicating the Swift ABI is brittle.)
2. **Depth — complete, defer nothing.** Bridge every value type via its
   Foundation rep **reusing the existing runtime** (String→NSString etc.);
   non-bridged structs/payload-enums → **opaque handles** with accessor+free
   trampolines; class/existential/`some P` → opaque retained handles; `async` →
   callback bridge; `throws` → error out-param. Only **generic free functions**
   are unbindable — recorded + count surfaced, never silently dropped.
3. **Value marshalling — bridge through Foundation reps, reuse the runtime.**
   `StringConversion.swift` / `CollectionMarshal.swift` / `StructMarshal.swift`
   already exist; only the box/handle/async/throws infra is new.

## Done when (whole node)

- `libAPIAnywareRacket` vends a C-ABI trampoline per trampolinable residual decl;
  the racket emitter binds them (`_aw-lib`, not `_fw-lib`); pointer-valued Swift
  constants via their trampoline. Unbindable generics recorded + counted.
- Builds green (`swift build` + `cargo test --workspace`, snapshots updated); a
  real Swift-native function + a real pointer constant resolve and run.

## Children

- **010-native-marshalling-runtime** — Swift native-lib layer the codegen binds
  to: box/handle (struct/payload-enum/class/existential) + `async` + `throws`
  infra + any missing value bridges (Set→list). Reuses existing String/Collection/
  Struct marshal + GC/will lifetime machinery.
- **020-trampoline-codegen-and-emitter** — the global trampoline pass writing
  `Generated/Trampolines.swift` (call-by-name `@_cdecl` per residual), emitter
  wiring (`emit_functions`/`emit_constants` branch on `objc_exposed`), racket-side
  coercers, unbindable-generic recording+count, TestKit fixture exemplars +
  snapshot goldens.
- **030-smoke-verify** — ✅ pick real recovered residual; prove a real Swift-native
  function + a real pointer constant resolve through `libAPIAnywareRacket` and run
  from racket; whole build green. (Full rerun + VM-verify is 050.) Exemplars:
  `CreateML.timestampSeed`, `CreateML.MLCreateErrorDomain` (spec §6a).
- **040-deferred-residual** (node) — wire the two non-hard deferred buckets the
  smoke regen quantified: `deferred_nonbridged_struct_param` (69) and
  `deferred_async`. `unbindable_generic_free_function` (34) stays a hard limit,
  out of scope. *(The `deferred_async` free-function bucket measured **empty** —
  spec §5b; 040/040/020 fixed the latent async-detection bug and spun async to
  050 below.)*
- **050-async-methods** (planning, frontier) — async is a *method/actor* effect,
  outside the free-function residual; bring async APIs into the binding via async
  *method* recovery + the idle `AsyncBridge.swift` runtime. Scope to be grilled
  (may extend per-target or become its own grove). Grown by 040/040/020.

## Notes

- Racket-only (ADR-0011). chez (060) / gerbil (070) get their own trampoline
  ADRs; the per-target-vs-shared-source question stays deferred unless duplication
  bites.
- If the build reveals the spec underspecified, kick back to update the spec
  rather than guessing (the 030 pattern).
