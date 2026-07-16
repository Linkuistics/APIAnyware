# The TypeScript (Node) trampoline structure: call-by-name napi-callback re-export

Decides the **per-target** mechanism by which `APIAnywareTypeScript.node` vends the
Swift-native residual (`objc_exposed == false`) the emitter cannot dispatch directly, and how
the TS emitter binds it. The TS/N-API analogue of **ADR-0027** (racket), governed by **ADR-0011**
(the trampoline layer is per-target), refining **ADR-0025** (trampoline elision) and extending
**ADR-0054 §2** (the one Swift-native N-API addon carries the residual). It reuses the
generated-typed-dispatch discipline of **ADR-0013/0054 §1** on a second problem.

A `objc_exposed == false` free function has **no C symbol** — it is reachable only across the
Swift ABI (ADR-0025). The four Lisp targets each decided this per-target (racket ADR-0027, chez
ADR-0028, gerbil ADR-0029, sbcl ADR-0038); this is the TS decision.

## Context

The IR marks the direct-vs-trampoline boundary with `objc_exposed` (ADR-0026): an ObjC/C
function (`c:`/`So` USR) dispatches directly through the emitter's `aw_ts_fn_<name>` entry
(the trampoline-elided limit for a named C export), while a Swift-native (`s:` USR) function
carries `swift_fn` metadata and reaches the emitter *retained*, not dropped. What the IR gives a
residual function: the bare Swift name + argument labels, digester-normalized param/return
`TypeRef`s, the owning **module** (from the enclosing `Framework.name`), and the `swift_fn` flags
(`throwing` / `is_async` / `is_generic`). Name yes, module-by-context — enough to reconstruct a
by-name call, not enough to hand-cast the mangled symbol.

**`TypeRefKind::Class` is overloaded in a residual signature.** A `.swiftinterface`-sourced
declaration lowers *every* Swift nominal type to `kind: "class"`, so the residual's `TypeRef`s name
Swift structs and tuples with the same kind that names an ObjC class: `CoreGraphics.hypot` is
`(Class{CGFloat}, Class{CGFloat}) -> Class{CGFloat}`, and `lgamma`/`remquo` return `Class{Tuple}`,
while CoreGraphics's IR `classes` array declares exactly eight, none of them either. The classifier
therefore cannot read "is this an object?" off the `TypeRefKind` alone — §3 says how it does read it.

## Decision

### 1. Generated napi-callback trampolines, **called by name**

`emit-typescript` generates, per residual function, a **napi-callback** that `import`s the
owning framework module and calls the API by its reconstructed Swift name + argument labels,
letting swiftc type-check the call and own Swift-ABI correctness:

```swift
import CoreGraphics

func aw_ts_swift_CoreGraphics_hypot(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
  let a = napiCallbackArgs(env, info, 2)
  let a0 = napiReadDouble(env, a[0])
  let a1 = napiReadDouble(env, a[1])
  return napiMakeDouble(env, Double((CoreGraphics.hypot(CGFloat(a0), CGFloat(a1))) as CGFloat))
}
```

**Rejected — bind the mangled `s:` symbol** via `@_silgen_name`/`dlsym` and a hand-cast
`@convention(c)` shape (the `objc_msgSend` dispatch trick). It avoids needing a valid Swift
source expression but forces hand-replicating the Swift calling convention per signature (self /
error register, indirect returns, ownership) with no compiler check — brittle and unverifiable.
Call-by-name lets swiftc own the ABI; we own only the napi boundary.

### 2. Registered in the **exports object**, not an exported `@_cdecl` symbol (the TS divergence)

The addon exposes every entry through its **exports object** (`napiDefine` →
`napi_create_function` in `napi_register_module_v1`), which the runtime's `__installDispatch`
binds. So a residual trampoline is a plain napi callback registered under its
`aw_ts_swift_<Module>_<name>` key — **not** an exported `@_cdecl` C symbol the way racket's
trampolines are (racket `dlsym`s them; the `.node` never does, and an `@_cdecl` here duplicates
the symbol). The entry key is **content-addressed by module + symbol** (a bare name collides
across modules — `nan` in CoreGraphics and _DarwinFoundation1), computed identically by the `.ts`
call site (`crate::native_dispatch::swift_function_entry_name`) and the generated Swift, so the
two agree with no shared counter. This is the sole structural difference from ADR-0027; the
call-by-name mechanism, the `Generated/Trampolines.swift`-style global pass, and the
`generate → build` order are the same.

### 3. Complete marshalling to the C-ABI limit — staged, never silently narrowed

The residual is realised in dependency-ordered slices; each slice binds what it can and **records
every deferral with a reason** (the ADR-0027 §2 "defer nothing, but say what truly can't be
bound" discipline), so the pass is honest about what remains.

**Two guards precede the object arm** (`swift-residual-cli-pass-k65`), because of the `Class`
overload §Context describes. (a) A **scalar-backed value type** — a named type that is one C scalar
at the ABI, currently `CGFloat` — marshals **by value** whatever `TypeRefKind` carries its name. (b)
An **object return binds only for a name in the ObjC-class recognition set**: the classes the IR
declares, unioned across every framework. The collector and the `.ts` emitter derive that set
identically, so their bind-or-defer decisions cannot diverge. Without (a) a generated `hypot` would
`passRetained` a `__SwiftValue` box instead of returning a `Double`; without (b) `remquo` would
bridge a Swift tuple through `as AnyObject?`. The same overload afflicts the *method* type surface —
scoped out, its own concern.

- **The scalar free-function slice is realised** (`fn-trampoline-spine-k53`): scalar / `CGFloat`
  params → scalar / `CGFloat` / void return, dispatched by name. A `CGFloat` marshals by value as
  its underlying `Double` (the dominant scalar residual), pinned `as CGFloat` so the by-name call
  binds the real overload. The emitter binds the `.ts` call site iff the classifier
  (`crate::trampoline`) binds the trampoline, so binding and deferral always agree.
- **The object / Foundation-bridged value / string return slice is realised**
  (`object-bridged-returns-k55`): the call result bridges to an `id` (`as AnyObject?` — `String`→
  `NSString`, `Array`→`NSArray`, or identity for a class instance) and the trampoline hands JS a
  **+1** handle (`Unmanaged.passRetained`, `napiMakeRetainedObject`) the runtime's `__wrapOwned`
  takes (ADR-0057 §4 uniform +1). The `.ts` emitter already wraps object returns; a **Swift-native
  residual return is always `__wrapOwned`** (the trampoline's own +1) — *not* the CF-Create-Rule
  name heuristic the direct-C path uses (a Swift `String`/factory return carries no `Create`/`Copy`
  convention). **Measured ~empty:** an SDK survey (all macOS `.swiftinterface` top-level Swift free
  functions) found *no* headless, non-throwing, object-returning Swift-native free function — the
  object residual lives at the **method** level (§4). So this realises the *mechanism* (ADR-0027 §2
  taxonomy completeness, reused by the §4 method-frontier grove), proven headless by an object-return
  marshalling **probe** (`trampolines.swift` `aw_ts_swift_probe_objectReturn`) + the goldens, not a
  by-name-reach exemplar the way `hypot` proves the scalar reach.
- **Deferred with a recorded reason — the free-function residual is now complete.** An SDK survey
  (all macOS `.swiftinterface` top-level Swift free functions, 2026-07-09) found the remaining
  widening slices **measured ~empty**: `throws` ≈3 non-headless free functions, the wider-scalar
  alphabet (`Bool`/`Float`/narrow/unsigned) ≈0, object returns ≈0 (mechanism realised regardless).
  So the scalar spine + object-return mechanism cover the *real* free-function residual, and the
  remaining slices are **recorded-deferred, not built** (user decision, 2026-07-09): the `throws` →
  ADR-0058 `Result` channel already exists for `NSError**` *methods* and is the natural extension if a
  real throwing free function ever appears; `async` is 0 (a method/actor effect, not a top-level `s:`
  `Func`). An **object/string param** (the ARC-on-`unsafeBitCast` trap + the *Object-ref* curated
  set) and any **non-bridged value-struct / receiver-handle** surface are the **method-frontier**
  residual — §4's follow-up grove, outside this target's free-function scope.
- **Two hard floors, not one.** The **generic free function** (`@_cdecl` cannot be generic; 21 in the
  corpus) is the classic one. The second is the Swift **operator declaration** (`+`, `-`, `*`, `/`,
  `&&`, `||`, `!`; 13, in `TabularData` and `RealityFoundation`): its name is not a TS identifier, so
  no emitted call site could ever reach it, *and* the entry-name sanitiser folds every
  non-alphanumeric to `_`, so `TabularData./`'s four overloads would collide on one entry. It is
  checked **first** — without a nameable entry no other deferral reason is actionable — and sharing
  that check with the emitter's admission gate is what makes the mirror invariant exact.
- **Pointer-valued and scalar constants** are read by the sibling `aw_ts_const_<code>` mechanism
  (ADR-0055 §6, `constants-k51`), already realised — the constant half of the residual.
- **The whole-corpus pass is wired** (`swift-residual-cli-pass-k65`): `apianyware-generate --target
  typescript` renders `src/Generated/TrampolineTable.swift` — **43 entries** (44 CoreGraphics math
  functions less the two `Tuple`-returning ones, plus `CreateML.timestampSeed`) with a generated
  `awRegisterGeneratedTrampolines`; `build.sh` compiles it into the `.node`. A unit asserts the
  **strong mirror invariant** — the collected entry set equals the set of `aw_ts_swift_*` tokens the
  rendered `.ts` references — and the deferral counts ride the pass log *and* the generated file.

### 4. The method / init / value-struct residual is a recorded follow-up-grove deferral

Swift-native **methods, initializers, and value-struct** surfaces (the receiver-handle frontier)
are **out of scope for this grove's v1**, recorded here, not silently dropped. This mirrors the
racket target exactly: racket shipped its initial target with the free-function + constant slice
(this ADR's analogue) and built the method/init/value-struct coverage in a **separate later
grove** (`add-swift-native-method-coverage`), with a per-target `swift-native-method-probe` that
is not a portfolio app. The Node TS `swift-native-probe` is viable on the realised
**function + constant** coverage set (the racket/chez/gerbil coverage), so the method/init residual
does not block the sample-app milestone.

## Consequences

- **The emitter acts on `objc_exposed` for free functions** (`emit_functions.rs`): a Swift-native
  scalar function binds to `aw_ts_swift_<Module>_<name>`; the plain-C `aw_ts_fn_<name>` path is
  separate — its per-symbol registration and lazy symbol resolution are ADR-0054 §1a, and its object
  returns follow the **CF Create Rule** where a residual's are a uniform +1 (§3). The classification
  + generated-Swift pass live in `crate::trampoline`, golden- and
  unit-tested against synthetic fixtures (no IR pipeline needed — the ADR-0011 pure-codegen seam).
- **A residual function's TS surface comes from the classifier's plan, not the type mapper.** The
  mapper reads `TypeRefKind::Class{CGFloat}` as an object (correctly, for an ObjC-header type); the
  plan knows it is one scalar. So the `.ts` header, body and imports are all rendered off the plan —
  otherwise the emitted binding `__unwrap`s a number, `__wrapOwned`s a double, and imports a name no
  module exports. A **fixture that spells `CGFloat` as `TypeRefKind::Alias` does not exercise this**;
  the real-IR `Class` spelling must be in the unit tests.
- **A generated Swift artifact**, written by `generate` before the addon `build.sh` compiles it
  into the hermetic `.node` (ADR-0011), under a **distinct file stem** from the hand-written
  `src/trampolines.swift` (object-file stems collide). The hand-written file keeps only the
  object-return marshalling probe — *fixed machinery*, not a per-symbol entry.
- **Node-target-scoped.** The JSC TS target (a separate future grove) reaches Swift-native APIs
  directly through its all-Swift core and needs no such trampoline layer.
- **Hard to reverse:** the `aw_ts_swift_*` entry family, the napi-callback-in-exports shape, and
  the emitter↔native content-addressing are load-bearing across three files that must agree.

See `CONTEXT.md` (*Trampoline*, *Trampoline elision*, *Unbindable residual*), ADR-0025 (the model
this fills the residual of), ADR-0026 (the `objc_exposed` fact it consumes), ADR-0027 (the racket
precedent it ports), ADR-0054 §2 (the addon that carries it), and ADR-0055 §6 (the sibling
constant reads).
