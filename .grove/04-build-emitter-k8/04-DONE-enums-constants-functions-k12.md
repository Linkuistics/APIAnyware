# enums-constants-functions-k12

**Kind:** work

The three non-class top-level construct emitters (smaller individually; grouped):

- **`emit_enums.rs`** — emit enums as `ns:` constants / a CL idiom (peer
  `emit-gerbil/emit_enums.rs`). Use the `underlying_primitive` width/signedness
  (the enum-typedef fix, see the enum-underlying-width memory). Enums are
  `objc_exposed`-irrelevant (compile-time literals).
- **`emit_constants.rs`** — the **constant sub-rule** (ADR-0026 §3, independent of
  `objc_exposed`): *literal-able* (scalar `Primitive` excl. `void`, or enum-typed
  `Alias` with `underlying_primitive`) → emit a literal; *pointer-valued*
  (`Class|Id|Pointer|CString|Block|FunctionPointer|Selector|ClassRef|Instancetype|
  Struct`, or `Alias` resolving to one) → runtime address read via `dlsym`
  (`sb-alien` `extern-alien` / `foreign-symbol-sap`); `objc_exposed == false` →
  trampoline (collect for 050, the §6d `7 const`). Peer
  `emit-gerbil/emit_constants.rs`.
- **`emit_functions.rs`** — top-level C/Swift functions. `objc_exposed == true` →
  direct `sb-alien` `define-alien-routine`/`alien-funcall`; `objc_exposed == false`
  → trampoline (collect for 050, the §6d `51 fn`); unrepresentable → skip. Peer
  `emit-gerbil/emit_functions.rs`. Variadic/edge cases per the racket spec taxonomy.

## Context

ADR-0026 §3 (the constant sub-rule + the direct/trampoline/skip decision tree) is
the governing contract. SBCL design spec §4 (the residual taxonomy = racket spec
§3/§8/§9, unchanged through the IR). Reference:
`emit-gerbil/src/{emit_enums.rs,emit_constants.rs,emit_functions.rs}` and
`emit-gerbil/examples/dump_foundation_{constants,functions}.rs` (handy
cross-checks). Enum width memory + the shared `emit::ffi_type_mapping`.

## Done when

- The three emitters produce enums/constants/functions for a fixture framework;
  snapshot tests pass.
- Constant sub-rule verified: a literal-able const → literal; a pointer-valued
  const → dlsym read; an `objc_exposed == false` const/func → collected residual.

## Notes

- The residual lists (const + fn) collected here feed 050's global pass; keep the
  collection shape consistent with the method/init residual from 020.
