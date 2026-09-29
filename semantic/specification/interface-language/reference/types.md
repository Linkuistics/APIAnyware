# Types

> **Purpose:** reference — look up value types, reference types and their contract consequences.
> **Reader:** language designers, API authors and tool implementers looking up draft 0.1.
> **Before this:** [Operations and their values](../explanation/model.md#operations); [reference conventions](notation.md#entry-conventions).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [L1](../language.md#l1), [L2](../language.md#l2), [L3](../language.md#l3), [L4](../language.md#l4), [L5](../language.md#l5), [L6](../language.md#l6), [C1](../contracts.md#c1), [C2](../contracts.md#c2), [C3](../contracts.md#c3), [C4](../contracts.md#c4), [C5](../contracts.md#c5), [C6](../contracts.md#c6), [C7](../contracts.md#c7), [A1](../profiles.md#a1), [A2](../profiles.md#a2), [A3](../profiles.md#a3) are canonical; this page is non-normative.

A type describes the value passed or stored. A [reference leaf](../glossary.md#reference-leaf)
also needs clauses describing ownership and validity. The entries below separate
the type's meaning from those obligations; an [access provider](../glossary.md#access-path)
supplies its native representation ([L4](../language.md#l4), [C1](../contracts.md#c1),
[A3](../profiles.md#a3)). [Type expressions](../grammar.ebnf) use `type` and
`type_argument`; [the notation reference](notation.md#callable) places them in signatures.

| Core form | Lookup |
|---|---|
| `unit` | [No result value](#unit) |
| `bool` | [Boolean](#bool) |
| `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64` | [Integers](#integers) |
| `f32`, `f64` | [Floating values](#floats) |
| `ptr<T>`, `mutptr<T>` | [Pointers](#pointers) |
| `nullable<T>` | [Nullable references](#nullable) |
| `array<T, N>` | [Fixed arrays](#array) |
| `complex<f32>`, `complex<f64>` | [Complex values](#complex) |
| Local or imported type name | [Declared types](#named-types) |
| `profileAlias::Type<...>` | [Profile types](#profile-types) |

<a id="unit"></a>

## `unit` — no result value

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `unit` (production `type`).

**Operands and types:** No operands.

**Applies to:** A callable result type.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L4](../language.md#l4)):** The call returns no value. Its completion and effects still have contracts.

**Constraints:** A field, parameter, array element or pointer pointee cannot have type `unit`. ([L4](../language.md#l4)).

**Rejected when:** `unit` is stored or pointed to. ([L4](../language.md#l4)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=unit -->
```ail
package example::canvas version "1" {
  fn inspect(canvas: Canvas) -> unit {
    // Callable contracts omitted.
  }
}
```

The result of `inspect` has no value slot requiring output state; the `Canvas` input still has reference obligations ([C3](../contracts.md#c3), [C5](../contracts.md#c5)).

**Used by and see also:** [Functions](declarations.md#fn); [reference/value distinction](#value-and-reference-types).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="bool"></a>

## `bool` — Boolean value

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `bool` (production `type`).

**Operands and types:** No operands.

**Applies to:** Fields, parameters, results and other value positions.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L4](../language.md#l4), [C5](../contracts.md#c5)):** A Boolean carries a logical truth value; the provider supplies its representation.

**Constraints:** Outcome equality may test a Boolean value, and the cases cover both values. ([L4](../language.md#l4), [C5](../contracts.md#c5)).

**Rejected when:** The type is used with arguments or an outcome partition omits a possible Boolean value. ([L4](../language.md#l4), [C5](../contracts.md#c5)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=bool -->
```ail
package example::geometry version "1" {
  record Samples {
    field enabled: bool;
    // Other fields and nominal contracts omitted.
  }
}
```

`enabled` records a value, with no independent release obligation.

**Used by and see also:** [Record fields](declarations.md#field); [outcomes](declarations.md#outcome).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="integers"></a>

## Fixed-width integers

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `i8`, `i16`, `i32`, `i64`; `u8`, `u16`, `u32`, `u64`.

**Operands and types:** No operands; the spelling fixes signedness and width.

**Applies to:** Value positions and enum/flags underlying types.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L1](../language.md#l1), [L4](../language.md#l4), [A3](../profiles.md#a3)):** These are fixed-width signed and unsigned integers. Decimal integer tokens have arbitrary precision during parsing; their use still has to fit the selected type.

**Constraints:** Enum cases fit their underlying core integer type. Array sizes use nonnegative integer arguments. ([L1](../language.md#l1), [L4](../language.md#l4), [A3](../profiles.md#a3)).

**Rejected when:** A case value is outside its underlying type or a core integer type is given arguments. ([L1](../language.md#l1), [L4](../language.md#l4), [A3](../profiles.md#a3)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/syntax.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=integers -->
```ail
package example::geometry version "1" {
  record Point { field x: i32; field y: i32; }
  // Nominal contracts omitted.
}
```

`x` and `y` each carry a signed 32-bit value. Their order is semantic; native offsets come from the representation provider.

**Used by and see also:** [Enums](declarations.md#enum); [arrays](#array); [record representation](declarations.md#record).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="floats"></a>

## Floating values

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `f32`, `f64`.

**Operands and types:** No operands; 32-bit or 64-bit IEEE binary floating value.

**Applies to:** Value positions, including complex components.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L4](../language.md#l4), [C5](../contracts.md#c5)):** These types record floating values independently of the selected native calling mechanism.

**Constraints:** The core outcome predicates do not compare floating values. ([L4](../language.md#l4), [C5](../contracts.md#c5)).

**Rejected when:** An outcome discriminator uses a floating comparison or the type has arguments. ([L4](../language.md#l4), [C5](../contracts.md#c5)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=floats -->
```ail
package example::geometry version "1" {
  record Measurement { field value: f64; }
  // Nominal contracts omitted.
}
```

This is a scalar adaptation of the teaching fragment’s `complex<f32>` field: a measurement carries one floating value.

**Used by and see also:** [Complex values](#complex); [outcome rules](../contracts.md#c5).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="pointers"></a>

## `ptr<T>` and `mutptr<T>` — storage access

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `ptr<T>` or `mutptr<T>` (one type argument).

**Operands and types:** `T` is the stored type.

**Applies to:** Pointer values at fields, parameters, results or nested type positions.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L4](../language.md#l4), [C1](../contracts.md#c1), [C3](../contracts.md#c3), [C4](../contracts.md#c4)):** Both forms are non-null references to readable storage; `mutptr` also permits writes. Ownership, validity, extent and contents are separate contracts.

**Constraints:** Every pointer leaf needs extent. Pointer parameters also need direction, aliasing and contents. Writable output storage uses `mutptr`; `ptr<Resource>` addresses storage holding a handle. ([L4](../language.md#l4), [C1](../contracts.md#c1), [C3](../contracts.md#c3), [C4](../contracts.md#c4)).

**Rejected when:** A pointer has the wrong arity, points to `unit`, lacks applicable contracts or uses `ptr` for `out`/`inout` storage (N13). ([L4](../language.md#l4), [C1](../contracts.md#c1), [C3](../contracts.md#c3), [C4](../contracts.md#c4)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=pointers -->
```ail
package example::canvas version "1" {
  fn inspect(canvas: Canvas, pixels: ptr<u8>, output: mutptr<u8>) -> unit {
    // Pointer and callable contracts omitted.
  }
}
```

`pixels` provides readable byte storage; `output` can provide writable byte storage. The parameter names do not establish their direction or sizes.

**Used by and see also:** [Storage](../explanation/model.md#storage); [places](notation.md#places); [buffers](../contracts.md#c4).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="nullable"></a>

## `nullable<T>` — reference or null

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `nullable<T>` (one type argument).

**Operands and types:** `T` is a pointer, object, resource, interface or callback reference type.

**Applies to:** Reference type positions.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L4](../language.md#l4), [C1](../contracts.md#c1), [C4](../contracts.md#c4), [C5](../contracts.md#c5)):** Null has no ownership obligation. The declaration’s outcomes determine whether null signals failure; nullability alone does not.

**Constraints:** Nested nullable is invalid. A null pointer has zero length and capacity. Contracts for nullable references apply when non-null. ([L4](../language.md#l4), [C1](../contracts.md#c1), [C4](../contracts.md#c4), [C5](../contracts.md#c5)).

**Rejected when:** `T` is a value type or nullable type, or a nullable discriminator’s outcomes are incomplete (N05). ([L4](../language.md#l4), [C1](../contracts.md#c1), [C4](../contracts.md#c4), [C5](../contracts.md#c5)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=nullable -->
```ail
package example::canvas version "1" {
  fn create() -> nullable<Canvas> {
    // Allocation outcomes and ownership contracts omitted.
  }
}
```

`create` can return a `Canvas` reference or null. The omitted outcomes state which case succeeded and what the caller receives.

**Used by and see also:** [Outcomes](declarations.md#outcome); [creation tutorial](../tutorial/01-lifetime.md#3-describe-creations-success-and-failure).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="array"></a>

## `array<T, N>` — fixed sequence

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `array<T, N>` (two arguments).

**Operands and types:** `T` is an element type; `N` is a nonnegative integer.

**Applies to:** By-value type positions.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L4](../language.md#l4), [C1](../contracts.md#c1), [C5](../contracts.md#c5)):** An array contains exactly `N` elements by value. A pointer with buffer extent instead refers to separately described storage.

**Constraints:** Elements cannot be `unit`. Reference-containing elements require recursive slot contracts; by-value recursion is invalid. ([L4](../language.md#l4), [C1](../contracts.md#c1), [C5](../contracts.md#c5)).

**Rejected when:** The count is negative, the arity is wrong or nested reference obligations are absent (N31). ([L4](../language.md#l4), [C1](../contracts.md#c1), [C5](../contracts.md#c5)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=array -->
```ail
package example::geometry version "1" {
  record Samples {
    field counts: array<u16, 4>;
    // Other fields and nominal contracts omitted.
  }
}
```

`counts` contains four unsigned 16-bit values within the record; no pointer extent is needed for this field.

**Used by and see also:** [Record fields](declarations.md#field); [aggregate obligations](../contracts.md#c1).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="complex"></a>

## `complex<f32>` and `complex<f64>`

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `complex<f32>` or `complex<f64>` (one argument).

**Operands and types:** The component type is `f32` or `f64`.

**Applies to:** By-value type positions.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L4](../language.md#l4), [A3](../profiles.md#a3)):** A complex value contains real and imaginary components; the provider defines native representation.

**Constraints:** The argument is one of the two core floating types. Semantic components do not establish a native layout. ([L4](../language.md#l4), [A3](../profiles.md#a3)).

**Rejected when:** The argument or arity is unsupported, or an access boundary lacks a complete representation. ([L4](../language.md#l4), [A3](../profiles.md#a3)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=complex -->
```ail
package example::geometry version "1" {
  record Samples {
    field signal: complex<f32>;
    // Other fields and nominal contracts omitted.
  }
}
```

`signal` records a pair of 32-bit floating components. How it crosses a native call boundary is a provider fact.

**Used by and see also:** [Floating values](#floats); [representations](../profiles.md#a3).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="named-types"></a>

## Declared types and transparent aliases

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the types of values an operation accepts, returns or stores.

**Form:** `Name` or `ImportAlias::Name` (production `type`).

**Operands and types:** A resolved local or imported nominal declaration, or an alias whose expansion is a type.

**Applies to:** Type positions, subject to the resolved type’s restrictions.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L2](../language.md#l2), [L4](../language.md#l4), [C2](../contracts.md#c2)):** A nominal type keeps its identity. An alias expands for semantic typing; `source` may preserve its source identity.

**Constraints:** Names resolve under L2 without `@`; no implicit package lookup occurs. Aliases agree with their expanded type and cannot form cycles. ([L2](../language.md#l2), [L4](../language.md#l4), [C2](../contracts.md#c2)).

**Rejected when:** A name is unresolved, a core name is shadowed (N04), or expansion forms a by-value/alias cycle. ([L2](../language.md#l2), [L4](../language.md#l4), [C2](../contracts.md#c2)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=named-types -->
```ail
package example::geometry version "1" {
  alias Coordinate = i32 {
    // Nominal contracts omitted.
  }
  record Point { field x: Coordinate; }
  // Remaining fields and nominal contracts omitted.
}
```

`Coordinate` has the semantic type `i32`; it does not create a distinct handle. The [import example](declarations.md#import) shows a qualified imported type.

**Used by and see also:** [Aliases](declarations.md#alias); [local and imported references](notation.md#names).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="value-and-reference-types"></a>

## Value types and reference types

In summary (non-normative; [L4](../language.md#l4), [C1](../contracts.md#c1)):
records, enums, flags, arrays and complex types are value types; objects,
resources, interfaces and callbacks are reference types. Pointers are also
reference leaves for contract checking. An aggregate's value classification
does not erase reference obligations in its fields or elements.

Compare `array<u16, 4>` above with `ptr<Canvas>` in the
[pointer teaching example](../language.md#l4): the array holds scalar values,
while the pointer addresses storage containing a resource handle. Copying that
storage does not create a second owned handle. Recursive contracts state what
happens to each reference leaf ([C1](../contracts.md#c1), [C3](../contracts.md#c3)).

<a id="profile-types"></a>

## Profile-defined types

**Expresses:** [Reaching the code](../explanation/model.md#access) — the types of values an operation accepts, returns or stores.

**Form:** `profileAlias::Type<...>` (production `type`).

**Operands and types:** A declared profile alias, its type name and provider-defined arguments.

**Applies to:** The positions admitted by that profile’s type schema.

**Required and repeatability:** Each type occurrence selects one type; constructor arity is exact.

**Default:** None; the occurrence states its type.

**Meaning (non-normative; [L2](../language.md#l2), [L4](../language.md#l4), [A1](../profiles.md#a1), [A3](../profiles.md#a3), [F1](../profiles.md#f1)):** A profile supplies additional types, their representations and contract applicability. Core AIL assigns no implicit meaning to a familiar source-language type spelling.

**Constraints:** The package pins the profile; its manifest closes and types the vocabulary and supplies all required semantics. ([L2](../language.md#l2), [L4](../language.md#l4), [A1](../profiles.md#a1), [A3](../profiles.md#a3), [F1](../profiles.md#f1)).

**Rejected when:** The profile is unresolved or unsupported, the schema is violated or required representation/contract rules are absent. ([L2](../language.md#l2), [L4](../language.md#l4), [A1](../profiles.md#a1), [A3](../profiles.md#a3), [F1](../profiles.md#f1)).

**Example.** Fragment — an invented API, adapted from the
[teaching fragments](../examples/rule-reading/types.ail). The header, publication
context and unshown declarations and contracts are omitted.

<!-- ail-example: ../examples/reference/types.ail region=profile-types -->
```ail
package example::collections version "1" {
  alias Points = collections::Sequence<i32> {
    // Provider schema and all contracts omitted.
  }
  // The collections profile pin is omitted.
}
```

`collections::Sequence` is a hypothetical provider type from the teaching fragments. It is not a supplied provider; the synthetic fixture profile defines no additional types.

**Used by and see also:** [Provider dependencies](declarations.md#use); [fixture limits](../profiles.md#f1).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

