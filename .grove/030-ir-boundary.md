# 030-ir-boundary

**Kind:** design (grill, then likely decompose into design+build)

## Goal

Make the **direct-vs-trampoline boundary explicit in the shared IR** — the
`collect → analyse` half that all targets consume (ADR-0011 shared analysis). Turn
today's *accidental* boundary (everything emits `objc_msgSend`; `source` is dead
metadata) into a *designed* one, and **stop silently dropping** the residual we
intend to bind.

## Context — perimeter (from root BRIEF Notes)

- **Drop:** only top-level `s:` `Func`/`Var` → `skipped_symbols`
  (`declaration_mapping.rs:164-175`, applied `:72-100`).
- **Dead metadata:** `DeclarationSource` (`provenance.rs`) written in collection,
  **read nowhere** downstream.
- **Un-walked entirely:** `Macro`, `TypeAlias`, `AssociatedType` ABI nodes.
- **Retained-but-unbindable:** Swift value types/enums/protocols flow to emitters
  already (enum has sentinel `enum_type`; structs lack a usable ctor path).

## Open design questions (grill)

1. **How is reachability represented?** Computed IR field (e.g.
   `Direct | Trampoline`) defaulted in `analyse/` from `source`+USR+type-shape+
   pointer-ness, vs emitters deriving it locally. Reachability is *analysis* (shared)
   in principle but per-target in the limit — carry the **facts**, default a shared
   classification. ADR-worthy (hard to reverse: schema consumed by all targets).
2. **Recover the dropped residual.** Stop routing top-level `s:` funcs/constants to
   `skipped_symbols`; retain them flagged trampoline-residual.
3. **Pointer-valued constants** → classified trampoline-residual (D1 scope), the
   rest stay direct literals. Define the detection rule.
4. **Disposition of un-walked kinds + retained-but-unbindable types** — explicitly
   mark unbindable (no broken emission) vs recover. D1 = minimal now; design so the
   frontier extends leaf-by-leaf.

## Done when

- Reachability/boundary representation decided (ADR + spec); residual recovery +
  pointer-constant rule specified; emitter contract for direct-vs-trampoline defined.
- Tree grown if build is large enough to split from design.

## Notes

- This is the only **shared-pipeline** change; downstream of it everything is
  per-target. Get the contract right before 040.
