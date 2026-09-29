# Access, pattern and fixture clauses

> **Purpose:** reference — look up access-path facts, [pattern](../glossary.md#pattern) bindings/laws and the synthetic fixture's clauses.
> **Reader:** reviewers, API authors and tool implementers checking an exact draft 0.1 fact.
> **Before this:** [Reaching the code](../explanation/model.md#access), [Entities that outlive a call](../explanation/model.md#entities), and [entry conventions](notation.md#entry-conventions).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L5`](../language.md#l5), [`L6`](../language.md#l6), [`A1–A5`](../profiles.md#a1) and [`F1`](../profiles.md#f1) are canonical. These entries are non-normative summaries.

Entries are alphabetical. Their forms use the generic [`clause` production](notation.md#clause)
inside [access](notation.md#access), [pattern/instance](notation.md#pattern)
or [nominal/callback declarations](declarations.md). The [applicability table](declarations.md#applicability)
locates each scope.

An [ABI entry](../glossary.md#abi-entry) supplies calling conventions and
representations; a [profile](../glossary.md#profile) defines access mechanisms,
mappings and additional vocabulary. An [access path](../glossary.md#access-path)
connects a [declaration](../glossary.md#declaration) to those providers in named environments. A
[pattern](../glossary.md#pattern) defines roles and laws, and an
[instance](../glossary.md#pattern-instance) binds their participants.
The examples use the abstract [`F1` catalogue](../profiles.md#f1), whose pins are
synthetic test tokens and whose facts establish no production language support.

In summary (non-normative; [`L5`](../language.md#l5), [`L6`](../language.md#l6),
[`A1`](../profiles.md#a1), [`C8`](../contracts.md#c8)): wrong scopes, unknown
vocabulary, duplicate singular clauses and missing applicable facts are rejected.
`bind` and `subject` repeat by role name; `law` repeats by its whole operand
tuple. Each selected access path preserves the entire declaration contract.

<a id="abi"></a>

## `abi`

**Expresses:** [Reaching the code](../explanation/model.md#access) — the [ABI](../glossary.md#abi) dependency and convention used by an access path.

**Form:** `abi(alias, "convention");` ([access grammar](notation.md#access)).

**Operands and types:** A local alias introduced by `use abi`, and a string naming one of that ABI entry's supported conventions.

**Applies to:** Access blocks on functions, globals and non-literal constants.

**Required and repeatability:** Required exactly once per access block, including source access.

**Default:** None; required.

**Meaning (non-normative; [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2)):** The [clause](../glossary.md#clause) selects a convention within a versioned ABI definition. That definition supplies the lowering and [representation](../glossary.md#representation) rules; the convention name alone is not the whole ABI. For source access, a compiler may realize the effective ABI dependency.

**Constraints:** The pinned entry supports the selected environments, convention, reachable types and complete contract. `F1` conventions are `c`, `object-message` and `source`, with the mechanism pairings shown under [`via`](#via) ([`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2), [`A3`](../profiles.md#a3), [`F1`](../profiles.md#f1)).

**Rejected when:** The alias is unresolved, its convention unsupported, or the selected [provider](../glossary.md#provider) cannot represent the boundary. `N23` substitutes `missing` for the ABI alias ([`L2`](../language.md#l2), [`A2`](../profiles.md#a2), [`A3`](../profiles.md#a3), [`N23`](README.md#n23)).

**Example.** Fragment — `Counter`'s message and source getter paths. The complete [objects package](../examples/objects.ail) supplies `F1`'s `native` ABI and `fixture` profile pins, `test`, `Counter` and the omitted contracts/publication facts.

<!-- ail-example: ../examples/rule-reading/providers.ail region=paths -->
```ail
package example::objects version "1" {
  fn read_count(receiver: Counter) -> u64 {
    available([test]);
    member(@Counter, instance);
    receiver($receiver);
    access objc_like in [test] {
      abi(native, "object-message");
      via(fixture, "message", "currentCount");
      mapping(identity);
      compatibility(stable);
    }
    access swift_like in [test] {
      abi(native, "source");
      via(fixture, "source-call", "Outer.Counter.currentCount.get");
      mapping(identity);
      compatibility(source, "fixture-build");
    }
    // Deprecation, input, effects and outcome omitted.
  }
  // Header, provider pins, environment, Counter and publication context omitted.
}
```

Both paths implement `read_count`. `native` selects the same synthetic ABI entry, while `object-message` and `source` select different conventions within it.

**Used by and see also:** [`via`](#via); [`callback_abi`](#callback_abi); [use](declarations.md#use); [access tutorial](../tutorial/05-access-and-change.md).

**Rationale:** [Reaching the code](../explanation/packages.md#reaching-the-code).

<a id="bind"></a>

## `bind`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the concrete participants fulfilling a pattern's roles.

**Form:** `bind(roleName, [@participant, ...]);`, including an empty list ([pattern grammar](notation.md#pattern)).

**Operands and types:** A role name declared by the instance's pattern, and a list of canonical identities of that role's kind: type, operation, [slot](../glossary.md#slot) or pattern instance.

**Applies to:** Pattern instances.

**Required and repeatability:** Exactly once for every declared role, including roles bound to no participants; repeatable by role name.

**Default:** None; optional/many roles still need explicit empty bindings when unused.

**Meaning (non-normative; [`L6`](../language.md#l6)):** The instance identifies the declarations, slots or pattern instances that participate in each role. Use the [role cardinality table](declarations.md#role) to check the number of participants in each binding.

**Constraints:** Participant kinds and counts agree with the role. Slot identities include their operation; a pattern participant names an instance. Participants have a nonempty intersection of [availability](../glossary.md#availability), composition is acyclic, and bound contracts satisfy the pattern's laws ([`L2`](../language.md#l2), [`L6`](../language.md#l6)).

**Rejected when:** A role is missing, bound twice or given the wrong kind/count, a participant is unresolved, availability has no shared [environment](../glossary.md#environment), or composition/laws are inconsistent. `N21` binds a type role to an operation; `N22` omits a binding ([`L5`](../language.md#l5), [`L6`](../language.md#l6); [`N21`](README.md#n21), [`N22`](README.md#n22)).

**Example.** Fragment — lifetime pattern and instance within `example::buffers` version `1`. The complete [buffers package](../examples/buffers.ail) supplies `Store`, its unique [lifecycle](../glossary.md#lifecycle), destroy's contract, environments and synthetic provider/publication facts.

<!-- ail-example: ../examples/buffers.ail lines=140-148 -->
```ail
  pattern lifetime {
    role resource_type: type one;
    role release: operation one;
    law(releases, release, resource_type);
  }
  instance store_lifetime: lifetime {
    bind(resource_type, [@Store]);
    bind(release, [@destroy]);
  }
```

`resource_type` selects `Store` and `release` selects destroy. The `releases` law checks that this operation is `Store`'s declared unique destructor. The [role examples](../language.md#l6) also show explicit empty bindings and full slot identities.

**Used by and see also:** [`law`](#law); [`subject`](#subject); [role](declarations.md#role); [instance](declarations.md#instance).

**Rationale:** [Patterns and laws](../explanation/contracts.md#patterns-and-laws).

<a id="callback_abi"></a>

## `callback_abi`

**Expresses:** [Reaching the code](../explanation/model.md#access) — the ABI convention for invoking a [callback](../glossary.md#callback) value.

**Form:** `callback_abi(abiAlias, "convention");` ([callable grammar](notation.md#callable)).

**Operands and types:** A local ABI dependency alias and a supported convention string.

**Applies to:** Callback declarations.

**Required and repeatability:** Required exactly once per callback declaration, alongside `representation`.

**Default:** None; required.

**Meaning (non-normative; [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2)):** The selected ABI entry supplies callback entry/lowering rules. The companion representation clause identifies how the [callable](../glossary.md#callable) value and captures are represented and managed.

**Constraints:** The convention and representation jointly support the signature and all callback obligations. `F1` callbacks use the selected convention with `representation(fixture, "closure")`, whose storage supports strong [retention](../glossary.md#retention)/release without a separately visible context argument ([`A2`](../profiles.md#a2), [`A3`](../profiles.md#a3), [`F1`](../profiles.md#f1)).

**Rejected when:** A required clause is absent, its alias/convention is unresolved, or the provider cannot implement the callback contract ([`L2`](../language.md#l2), [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2), [`C8`](../contracts.md#c8)).

**Example.** Fragment — `Handler` inside `example::callbacks` version `1`. The complete [callbacks package](../examples/callbacks.ail) supplies synthetic `native`/`fixture` pins, `test`, the registration and subscription lifetime, and publication facts.

<!-- ail-example: ../examples/callbacks.ail lines=19-37 -->
```ail
  callback Handler(value: u64) -> unit {
    available([test]);
    deprecated(no);
    sharing(shared);
    isolation(none);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    callback_abi(native, "c");
    representation(fixture, "closure");
    outcome handled {
      when(returned, any);
      meaning(success);
    }
  }
```

`Handler` receives a `u64` and returns `unit` under the fixture's `c` convention. Its declaration describes one invocation; the registration's [callback-use block](declarations.md#callback-use) separately describes when invocations occur.

**Used by and see also:** [`representation`](#representation); [`abi`](#abi); [callback](declarations.md#callback); [callback tutorial](../tutorial/04-callbacks.md).

**Rationale:** [Callbacks](../explanation/contracts.md#callbacks).

<a id="compatibility"></a>

## `compatibility`

**Expresses:** [Reaching the code](../explanation/model.md#access) — the domain in which a path's representations are compatible.

**Form:** `compatibility(stable);`, `compatibility(artifact, "build-id");` or `compatibility(source, "build-recipe-id");` ([access grammar](notation.md#access)).

**Operands and types:** The name `stable`; or `artifact` with a build-identity string; or `source` with a profile build-recipe identity string.

**Applies to:** Access blocks.

**Required and repeatability:** Required exactly once per access block.

**Default:** None; required.

**Meaning (non-normative; [`A4`](../profiles.md#a4)):** Use the mode to identify the domain within which this path's representations are compatible.

| Mode | Compatibility domain |
|---|---|
| `stable` | The ABI entry's guaranteed domain |
| `artifact` | A particular built artifact set |
| `source` | A fully specified source build recipe; its compiler establishes compatibility for that build |

**Constraints:** Stability covers all reachable types. Artifact IDs resolve to content identities, compiler/runtime requirements and a representation manifest. Source recipes pin dependencies, compiler/options, module/header interfaces and the adapter/build procedure. Compiler version alone is not artifact identity; source access does not assert independent binary stability. `F1`'s `fixture-build` requires exactly `fixture-compiler` version `1` and this [package](../glossary.md#package)'s source surface ([`A4`](../profiles.md#a4), [`F1`](../profiles.md#f1)).

**Rejected when:** The claimed domain is unsupported, a build identity is unresolved, or a source recipe is incomplete/unavailable in its manifest. `N26` substitutes a compiler name for a resolved artifact. A [consumer](../glossary.md#consumer) lacking a required compiler may instead refuse an otherwise valid path as a feasibility limitation ([`A4`](../profiles.md#a4), [`A5`](../profiles.md#a5), [`N26`](README.md#n26)).

**Example.** Fragment — `Counter`'s two getter alternatives. The complete [objects package](../examples/objects.ail) supplies the synthetic provider pins, `test` with its toolchain, `Counter` and omitted contracts/publication facts.

<!-- ail-example: ../examples/rule-reading/providers.ail region=paths -->
```ail
package example::objects version "1" {
  fn read_count(receiver: Counter) -> u64 {
    available([test]);
    member(@Counter, instance);
    receiver($receiver);
    access objc_like in [test] {
      abi(native, "object-message");
      via(fixture, "message", "currentCount");
      mapping(identity);
      compatibility(stable);
    }
    access swift_like in [test] {
      abi(native, "source");
      via(fixture, "source-call", "Outer.Counter.currentCount.get");
      mapping(identity);
      compatibility(source, "fixture-build");
    }
    // Deprecation, input, effects and outcome omitted.
  }
  // Header, provider pins, environment, Counter and publication context omitted.
}
```

The message path relies on `F1`'s stable fixture domain; the source path relies on `fixture-build`. Both retain the same semantic getter contract.

**Used by and see also:** [`mapping`](#mapping); [`toolchain`](clauses-package.md#toolchain); [compatibility domain](../glossary.md#compatibility-domain); [access tutorial](../tutorial/05-access-and-change.md).

**Rationale:** [Reaching the code](../explanation/packages.md#reaching-the-code).

<a id="fixture-actor"></a>

## `fixture::actor`

**Expresses:** [Where and when calls run](../explanation/model.md#execution) — the fixture's source actor identity alongside core [isolation](../glossary.md#isolation).

**Form:** `fixture::actor(none);` or `fixture::actor("name");` ([profile clause grammar](notation.md#clause)).

**Operands and types:** The name `none` or an actor-identity string. `fixture` is the package's alias for the `F1` profile.

**Applies to:** Objects, records, enums, flags and interfaces only.

**Required and repeatability:** Optional, singular per eligible declaration.

**Default:** No default is specified. Omission supplies no actor fact; explicit `none` records absence.

**Meaning (non-normative; [`F1`](../profiles.md#f1)):** The clause records a synthetic source actor identity. It asserts no actual Swift compiler conformance.

**Constraints:** `none` agrees with core `isolation(none)`; a named actor agrees with `isolation(executor(fixture, "name"))`. The pinned provider defines the profile vocabulary ([`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).

**Rejected when:** The clause occurs on another declaration kind, repeats, uses an unsupported operand or disagrees with core isolation ([`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1), [`C8`](../contracts.md#c8)).

**Example.** Fragment — a constructed actor fact on a record. A complete package also supplies the language header, synthetic `F1` dependency pins, environment, publication facts and `Point`'s availability/deprecation. This illustrates `F1`'s optional clause, not a production actor implementation.

<!-- ail-example: ../examples/rule-reading/providers.ail region=actor -->
```ail
package example::geometry version "1" {
  record Point {
    field x: i32;
    field y: i32;
    sharing(value);
    isolation(none);
    fixture::actor(none);
    // Availability and deprecation omitted.
  }
  // Header, F1 dependency pins, environment and publication context omitted.
}
```

`Point` explicitly has no source actor and no nominal isolation. A named actor would instead require the matching `executor(fixture, "name")` identity in its isolation clause.

**Used by and see also:** [`isolation`](clauses-package.md#isolation); [fixture::sendability](#fixture-sendability); [synthetic fixture](../explanation/packages.md#the-synthetic-fixture).

**Rationale:** [Extending the language with profiles](../explanation/contracts.md#extending-the-language-with-profiles).

<a id="fixture-sendability"></a>

## `fixture::sendability`

**Expresses:** [Where and when calls run](../explanation/model.md#execution) — a source compiler conformance fact distinct from permitted sharing.

**Form:** `fixture::sendability(available);`, `fixture::sendability(unavailable);` or `fixture::sendability(nonconforming);` ([profile clause grammar](notation.md#clause)).

**Operands and types:** One of the three conformance-state names. `fixture` is the `F1` profile alias.

**Applies to:** Objects, records, enums, flags and interfaces only.

**Required and repeatability:** Allowed once per eligible declaration; `F1` does not require it on every such declaration.

**Default:** No default is specified; omission supplies no conformance fact.

**Meaning (non-normative; [`F1`](../profiles.md#f1)):** The three values distinguish synthetic compiler conformance states independently of the core `sharing` contract. `F1` asserts no actual Swift compiler conformance.

**Constraints:** Core sharing, isolation and callable [concurrency](../glossary.md#concurrency) still govern use. A conformance fact does not establish safe concurrent mutation. The profile supplies the meaning of this namespaced vocabulary ([`C2`](../contracts.md#c2), [`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).

**Rejected when:** The clause appears on another kind, repeats or uses unknown profile vocabulary ([`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1), [`C8`](../contracts.md#c8)).

**Example.** Fragment — `Counter`'s source fact and core restrictions. The complete [objects package](../examples/objects.ail) supplies the `F1` pin, `Counter`'s lifecycle/relations, members, environment and publication facts.

<!-- ail-example: ../examples/rule-reading/providers.ail region=profile-facts -->
```ail
package example::objects version "1" {
  object Counter {
    sharing(confined);
    isolation(main);
    fixture::sendability(nonconforming);
    // Availability, lifecycle and nominal relations omitted.
  }
  // Header, fixture profile pin, environment and publication context omitted.
}
```

The conformance state is `nonconforming`; the independently stated `confined`/`main` pair governs where `Counter` can be used. Neither clause substitutes for the other.

**Used by and see also:** [`sharing`](clauses-package.md#sharing); [`isolation`](clauses-package.md#isolation); [fixture::actor](#fixture-actor).

**Rationale:** [Threads and sharing](../explanation/contracts.md#threads-and-sharing).

<a id="law"></a>

## `law`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — checked ordering or destruction relationships among pattern participants.

**Form:** `law(before, roleA, roleB);` or `law(releases, operationRole, typeRole);` ([pattern grammar](notation.md#pattern)).

**Operands and types:** A core law name and declared role names. `before` takes two `operation one` roles; `releases` takes an `operation one` role and a `type one` role bound to a resource.

**Applies to:** Pattern declarations; instances supply participants and any required subjects.

**Required and repeatability:** Optional; repeatable by the entire operand tuple. Identical duplicate laws are invalid.

**Default:** No law is inferred from documentation or a role's name.

**Meaning (non-normative; [`L6`](../language.md#l6)):** `before` requires successful [completion](../glossary.md#completion) of A before entry into B on every shared resource instance. `releases` requires the operation to be the resource's declared unique destructor. Both impose client obligations checked against the participating contracts.

**Constraints:** `before` requires corresponding instance `subject` clauses identifying reference parameters of the same nominal resource type. Ordering and pattern composition are acyclic. Other laws need a versioned profile defining typed operands, obligations and validation ([`L6`](../language.md#l6)).

**Rejected when:** Role names/kinds/cardinalities are wrong, required subjects are absent/incompatible, ordering cycles, or `releases` names an operation other than the unique destructor. Unknown law tokens and duplicate law tuples are invalid ([`L5`](../language.md#l5), [`L6`](../language.md#l6)).

**Example.** Fragment — the lifetime pattern inside `example::buffers` version `1`. The complete [buffers package](../examples/buffers.ail) supplies `Store`'s lifecycle, destroy's callable contract, availability and synthetic publication context.

<!-- ail-example: ../examples/buffers.ail lines=140-148 -->
```ail
  pattern lifetime {
    role resource_type: type one;
    role release: operation one;
    law(releases, release, resource_type);
  }
  instance store_lifetime: lifetime {
    bind(resource_type, [@Store]);
    bind(release, [@destroy]);
  }
```

The law checks the same destruction relation already recorded by `Store`'s lifecycle. The [subject entry](#subject) shows an ordering law over two operations using a `Session`.

**Used by and see also:** [`bind`](#bind); [`subject`](#subject); [`lifecycle`](clauses-package.md#lifecycle); [pattern](declarations.md#pattern).

**Rationale:** [Patterns and laws](../explanation/contracts.md#patterns-and-laws).

<a id="mapping"></a>

## `mapping`

**Expresses:** [Reaching the code](../explanation/model.md#access) — how the semantic declaration becomes the selected provider operation or data access.

**Form:** `mapping(identity);` or `mapping(profileAlias, "mapping-id");` ([access grammar](notation.md#access)).

**Operands and types:** The name `identity`, or a local profile alias and a string naming a versioned [mapping](../glossary.md#mapping) recipe defined by that profile.

**Applies to:** Access blocks.

**Required and repeatability:** Required exactly once per access block.

**Default:** None; required.

**Meaning (non-normative; [`A2`](../profiles.md#a2)):** A mapping accounts for each semantic parameter/result, auxiliary native argument and completion mode exactly once. `identity` is available when the access/ABI pair defines a total faithful lowering of the declared signature or data value.

**Constraints:** Input order follows the declaration. An explicit receiver remains in the semantic signature even when lowered to an implicit receiver. Recipes account for inserted contexts, error-out storage and ownership adjustments, preserving all client-visible distinctions. Register-level splitting does not change declaration identity; loss of a meaningful status does. Named mappings are provider recipes, not embedded code or prose ([`A2`](../profiles.md#a2)).

**Rejected when:** A mapping is missing, unresolved, partial or loses observable distinctions, or `identity` lacks a faithful provider lowering ([`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2), [`C8`](../contracts.md#c8)).

**Example.** Fragment — two faithful getter paths. The complete [objects package](../examples/objects.ail) supplies the synthetic providers/environment, `Counter` and omitted contracts/publication facts.

<!-- ail-example: ../examples/rule-reading/providers.ail region=paths -->
```ail
package example::objects version "1" {
  fn read_count(receiver: Counter) -> u64 {
    available([test]);
    member(@Counter, instance);
    receiver($receiver);
    access objc_like in [test] {
      abi(native, "object-message");
      via(fixture, "message", "currentCount");
      mapping(identity);
      compatibility(stable);
    }
    access swift_like in [test] {
      abi(native, "source");
      via(fixture, "source-call", "Outer.Counter.currentCount.get");
      mapping(identity);
      compatibility(source, "fixture-build");
    }
    // Deprecation, input, effects and outcome omitted.
  }
  // Header, provider pins, environment, Counter and publication context omitted.
}
```

`F1` defines `identity` for both mechanisms. The message mechanism makes the `Counter` receiver implicit while preserving the declared result and contract; identity mapping need not mean identical physical argument placement.

**Used by and see also:** [`via`](#via); [`abi`](#abi); [`receiver`](clauses-package.md#receiver); [access tutorial](../tutorial/05-access-and-change.md).

**Rationale:** [Reaching the code](../explanation/packages.md#reaching-the-code).

<a id="representation"></a>

## `representation`

**Expresses:** [Reaching the code](../explanation/model.md#access) — the provider-defined representation of a callback value.

**Form:** `representation(profileAlias, "kind");` ([callable grammar](notation.md#callable)).

**Operands and types:** A local profile alias and a string naming its supported callback representation kind.

**Applies to:** Callback declarations. Other nominal representation facts are supplied through ABI definitions, profile-controlled clauses or identified artifacts under `A3`; this core spelling supplies the callback companion required by `A2`.

**Required and repeatability:** Required exactly once per callback declaration, alongside `callback_abi`.

**Default:** None; required.

**Meaning (non-normative; [`A2`](../profiles.md#a2), [`C2`](../contracts.md#c2)):** The provider defines how the callable value is represented and supplies its retain/release operations. These support the callback's value/capture lifetime independently of its registration schedule.

**Constraints:** Tooling resolves one complete representation for each reachable nominal type at each boundary; absence or conflicting recipes fails. `F1` supports `"closure"`, strong retention/release and no separately visible context argument. Its callable entry is synchronous and non-throwing; owner-scoped asynchronous registration remains supported ([`A3`](../profiles.md#a3), [`C6`](../contracts.md#c6), [`F1`](../profiles.md#f1)).

**Rejected when:** The required representation is absent, unknown, conflicting or unable to implement the stored callback's obligations ([`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2), [`A3`](../profiles.md#a3), [`C8`](../contracts.md#c8)).

**Example.** Fragment — `Handler` within `example::callbacks` version `1`. The complete [callbacks package](../examples/callbacks.ail) supplies `F1` dependencies, `test`, `Subscription`'s lifecycle, registration/retention and publication context.

<!-- ail-example: ../examples/callbacks.ail lines=19-37 -->
```ail
  callback Handler(value: u64) -> unit {
    available([test]);
    deprecated(no);
    sharing(shared);
    isolation(none);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    callback_abi(native, "c");
    representation(fixture, "closure");
    outcome handled {
      when(returned, any);
      meaning(success);
    }
  }
```

`"closure"` supplies the fixture representation for this callable and its captured state. `callback_abi` selects invocation convention; the registration's `retain` and `scope` determine how long this particular supplied value is stored.

**Used by and see also:** [`callback_abi`](#callback_abi); [`retain`](clauses-callable.md#retain); [`scope`](clauses-outcomes.md#scope); [callback tutorial](../tutorial/04-callbacks.md).

**Rationale:** [Callbacks](../explanation/contracts.md#callbacks).

<a id="subject"></a>

## `subject`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — which resource parameter connects an operation to a pattern's ordering law.

**Form:** `subject(roleName, @operation::parameter);` ([pattern grammar](notation.md#pattern)).

**Operands and types:** An operation role name and the canonical reference to that operation's parameter slot. The two subjects of a `before` law have reference slots of the same nominal resource type.

**Applies to:** Pattern instances satisfying a `before` law.

**Required and repeatability:** Required for both operation roles of each `before` law; repeatable by role name, once per role.

**Default:** None; required for the ordering relation.

**Meaning (non-normative; [`L6`](../language.md#l6)):** The subjects identify the resource shared by the ordered operations. On each such resource instance, successful completion of the first operation precedes entry into the second.

**Constraints:** Role bindings select the corresponding operations, the slots resolve to their reference parameters with the same nominal resource type, and the ordering agrees with the contracts and is acyclic. The law adds a state precondition to the second operation ([`L2`](../language.md#l2), [`L6`](../language.md#l6)).

**Rejected when:** A required subject is missing or repeated, its slot/role does not resolve appropriately, its type is incompatible with the other subject, or the resulting order cycles ([`L5`](../language.md#l5), [`L6`](../language.md#l6)).

**Example.** Fragment — a constructed session protocol. A complete package also supplies `Session`'s resource/lifecycle, the header, publication facts and full callable contracts consistent with this ordering and shared availability.

<!-- ail-example: ../examples/rule-reading/patterns.ail region=ordering -->
```ail
package example::sessions version "1" {
  fn prepare(session: Session) -> unit {
    // Contracts establishing the prepared state omitted.
  }
  fn read(session: Session) -> u64 {
    // Contracts consistent with the ordering law omitted.
  }
  pattern prepared_use {
    role preparation: operation one;
    role use: operation one;
    law(before, preparation, use);
  }
  instance session_order: prepared_use {
    bind(preparation, [@prepare]);
    bind(use, [@read]);
    subject(preparation, @prepare::session);
    subject(use, @read::session);
  }
  // Header, resource Session, lifetime and publication context omitted.
}
```

The references identify each operation's `session` parameter. Their common type makes the law apply to the same `Session` instance; the matching parameter spellings alone do not establish that relationship.

**Used by and see also:** [`law`](#law); [`bind`](#bind); [slot references](notation.md#names); [instance](declarations.md#instance).

**Rationale:** [Patterns and laws](../explanation/contracts.md#patterns-and-laws).

<a id="via"></a>

## `via`

**Expresses:** [Reaching the code](../explanation/model.md#access) — the mechanism and exact identity used to reach an operation or data value.

**Form:** `via(profileAlias, "mechanism", "identity");` ([access grammar](notation.md#access)).

**Operands and types:** A local profile alias, a supported mechanism string and an identity string interpreted by that profile.

**Applies to:** Access blocks on functions, globals and non-literal constants.

**Required and repeatability:** Required exactly once per access block.

**Default:** None; source spelling and type spelling infer no mechanism.

**Meaning (non-normative; [`A2`](../profiles.md#a2), [`A3`](../profiles.md#a3)):** The profile specifies whether an identity is a linker symbol, selector, source callable or another supported access kind. For data, loading the stored value, taking a symbol's address and evaluating source are distinct mechanisms.

**Constraints:** The mechanism supports the declaration kind, ABI convention, environments and full contract. `F1` supplies the following closed set with faithful `mapping(identity)`; each mechanism determines what its identity denotes ([`A2`](../profiles.md#a2), [`A3`](../profiles.md#a3), [`F1`](../profiles.md#f1)).

| `F1` mechanism | Declaration and identity | Convention |
|---|---|---|
| `symbol` | Function; nonempty linker name; all parameters explicit | `c` |
| `message` | Function with object [member](../glossary.md#member)/receiver; selector; receiver becomes implicit and remaining parameter order is preserved | `object-message` |
| `source-call` | Nonempty source callable spelling; `fixture-build` pins the source-build context | `source` |
| `load` | Global/constant; linker name; load its declared stored value | `c` |
| `address` | Pointer-typed global/constant; linker name; take the address of pointee storage | `c` |

**Rejected when:** The alias, mechanism or identity is unsupported, the mechanism conflicts with the declaration/ABI, or the provider cannot preserve the contract. Macros, managed members and wire requests need their own defined mechanisms; their spelling alone creates no linker symbol ([`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2), [`A3`](../profiles.md#a3), [`F1`](../profiles.md#f1)).

**Example.** Fragment — two ways to obtain a pointer. The complete [objects package](../examples/objects.ail) supplies synthetic providers, `test`, the omitted output/lifetime clauses and publication context.

<!-- ail-example: ../examples/rule-reading/providers.ail region=data -->
```ail
package example::objects version "1" {
  constant fixed_bytes: ptr<u8> {
    access direct in [test] {
      abi(native, "c");
      via(fixture, "address", "fixture_fixed_bytes");
      mapping(identity);
      compatibility(stable);
    }
    // Availability, sharing/isolation and output contracts omitted.
  }
  global pointer_value: ptr<u8> {
    access direct in [test] {
      abi(native, "c");
      via(fixture, "load", "fixture_pointer_value");
      mapping(identity);
      compatibility(stable);
    }
    // Availability, mutability, sharing/isolation and output contracts omitted.
  }
  // Header, provider pins, environment and publication context omitted.
}
```

`fixed_bytes` takes the address of exported byte storage. `pointer_value` loads a pointer held in a variable. Both declarations yield `ptr<u8>`, so the type alone cannot choose between these operations.

**Used by and see also:** [`abi`](#abi); [`mapping`](#mapping); [`compatibility`](#compatibility); [global](declarations.md#global); [constant](declarations.md#constant); [access tutorial](../tutorial/05-access-and-change.md).

**Rationale:** [Reaching the code](../explanation/packages.md#reaching-the-code).
