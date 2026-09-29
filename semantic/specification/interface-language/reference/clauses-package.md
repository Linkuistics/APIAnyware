# Package, environment and declaration clauses

> **Purpose:** reference — look up publication, [environment](../glossary.md#environment), common [declaration](../glossary.md#declaration) and nominal clauses.
> **Reader:** reviewers, API authors and tool implementers checking an exact draft 0.1 fact.
> **Before this:** [The published description](../explanation/model.md#description), [declarations and blocks](declarations.md), and [entry conventions](notation.md#entry-conventions).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L1–L5`](../language.md#l1), [`C2`](../contracts.md#c2), [`C3`](../contracts.md#c3), [`C7`](../contracts.md#c7) and the cited [provider rules](../profiles.md) are canonical. These entries are non-normative summaries.

Entries are alphabetical. Use the [applicability table](declarations.md#applicability)
to start from a declaration kind, or the [model-concept index](README.md#model-concepts)
to start from the fact you need to record. Each form below uses the
[`clause` production](notation.md#clause); the [lifecycle](../glossary.md#lifecycle) form of `runtime`
uses the nested `constructor` production. [Environment syntax](notation.md#environment)
locates configuration clauses.

A [member](../glossary.md#member) is a top-level declaration associated with
a nominal owner. [Names and references](notation.md#names) and the
[language-containment view](declarations.md) distinguish local declarations,
imported declarations and [callable](../glossary.md#callable) slots. A [profile](../glossary.md#profile)
supplies the additional meanings explicitly identified in an entry.
`F1` is a [synthetic fixture catalogue](../profiles.md#f1); hypothetical
environment refinements below require their own [provider](../glossary.md#provider) definitions.

In summary (non-normative; [`L1`](../language.md#l1), [`L5`](../language.md#l5),
[`C8`](../contracts.md#c8)): clauses use closed, typed vocabulary and are
singular unless explicitly repeatable. A duplicate singular [clause](../glossary.md#clause) is invalid
even when its values match; a clause outside its stated scope is invalid.
The rejection fields below add each entry's specific checks. Mutation IDs
refer to the [conformance corpus](../conformance.md#rejection-mutations);
entries without an applicable numbered mutation still cite their rules.
An optional clause's absence supplies only what its rule states.

<a id="accessors"></a>

## `accessors`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the operations that read and write a property.

**Form:** `accessors(@get, @set);` or `accessors(@get, none);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** `@get` and `@set` are declaration references to full functions; `none` states that there is no setter.

**Applies to:** Properties.

**Required and repeatability:** Required exactly once per property.

**Default:** None; required.

**Meaning (non-normative; [`L5`](../language.md#l5), [`C3`](../contracts.md#c3)):** The property presents its getter and optional setter as one named value. The functions carry the actual callable contracts.

**Constraints:** Accessors have the property's member owner/kind and [availability](../glossary.md#availability). The getter takes only the receiver, if any, and returns the property type. The setter additionally takes one parameter named `value` of that type and returns `unit` ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3)).

**Rejected when:** The getter or a named setter cannot resolve, an accessor has an incompatible owner, kind, availability or signature, or its contract conflicts with the property's storage assertion. An explicit `none` setter is permitted ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3)).

**Example.** Fragment — the synthetic object fixture's property. The header, provider pins, publication context, `Counter` and full accessor functions are omitted; see the [complete object example](../examples/objects.ail).

<!-- ail-example: ../examples/reference/clauses-package.ail region=property -->
```ail
package example::objects version "1" {
  property count: u64 {
    member(@Counter, instance);
    accessors(@read_count, @write_count);
    storage(value);
    // Availability and deprecation omitted.
  }
  // Counter and the full read_count/write_count functions omitted.
  // Getter: (receiver: Counter) -> u64.
  // Setter: (receiver: Counter, value: u64) -> unit.
}
```

`count` reads through `read_count` and writes through `write_count`. Both functions belong to `Counter` as instance members. Their `u64` result and `value` parameter match the property's type.

**Used by and see also:** [Property](declarations.md#property); [`storage`](#storage); [`member`](#member).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="available"></a>

## `available`

**Expresses:** [The published description](../explanation/model.md#description) — the configurations in which a declaration's contract holds.

**Form:** `available([env, ...]);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A nonempty list of local environment names, written as bare names.

**Applies to:** Every declaration except patterns and [pattern](../glossary.md#pattern) instances.

**Required and repeatability:** Required exactly once in its applicable scope.

**Default:** None; environments are explicit.

**Meaning (non-normative; [`L3`](../language.md#l3)):** Availability selects the [package](../glossary.md#package) configurations for which this declaration is authoritative. Imported dependencies are matched by configuration values.

**Constraints:** The list has no duplicates. Referenced declarations are available everywhere the referencing use is available. Environment-dependent signatures or contracts need distinct declarations with disjoint availability or distinct identities ([`L3`](../language.md#l3)).

**Rejected when:** The list is empty, repeats a name, names a missing local environment, or uses a dependency unavailable in a selected configuration ([`L3`](../language.md#l3)).

**Example.** Fragment — an invented point declaration in `F1`'s synthetic test environment. Header, provider pins and other publication/nominal facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=availability -->
```ail
package example::geometry version "1" {
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
  record Point {
    available([test]);
    deprecated(no);
    field x: i32;
    field y: i32;
    // Remaining nominal contracts omitted.
  }
  // Header, provider pins and publication context omitted.
}
```

`test` is the local name of the exact fixture configuration. `Point` is available there; a different package may use a different environment name for the same configuration.

**Used by and see also:** [Environment](declarations.md#environment); [`deprecated`](#deprecated); [`exports`](#exports).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="base"></a>

## `base`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — an object's single inherited object type.

**Form:** `base(@T);` or `base(none);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** An object declaration reference, or the bare value `none`.

**Applies to:** Objects.

**Required and repeatability:** Required exactly once per object.

**Default:** None; `base(none)` explicitly states that there is no base.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)):** The object names its direct base or declares that it has none.

**Constraints:** The referenced type is an object and the single-inheritance relation is acyclic. Availability of the reference follows `L3` ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Rejected when:** The base is unresolved, is not an object, creates an inheritance cycle, or is unavailable where the derived object is used ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Example.** Fragment — the existing nominal-relation teaching sketch. Header, provider support, member implementations, lifetimes and publication facts are omitted; this is not a complete conformance claim.

<!-- ail-example: ../examples/reference/clauses-package.ail region=relations -->
```ail
package example::drawing version "1" {
  interface Drawable {
    extends([]);
    // Nominal contracts omitted.
  }
  object Shape {
    base(none);
    implements([]);
    // Nominal contracts omitted.
  }
  object Dot {
    base(@Shape);
    implements([@Drawable]);
    // Nominal contracts omitted.
  }
  // Header, providers, members and publication context omitted.
}
```

`Shape` has no base. `Dot` names `Shape` as its base and separately records conformance to `Drawable`.

**Used by and see also:** [Object](declarations.md#object); [`implements`](#implements); [`overrides`](#overrides).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="deprecated"></a>

## `deprecated`

**Expresses:** [The published description](../explanation/model.md#description) — advice about continued use of a public declaration.

**Form:** `deprecated(no);`, `deprecated(since("version"), "message");` or `deprecated(unversioned, "message");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** `no` marks no deprecation. `since` takes a version string and the clause then takes a message string; `unversioned` takes only the message.

**Applies to:** Declarations other than patterns and pattern instances; required on public declarations.

**Required and repeatability:** Exactly once on each public declaration in scope. Singular when supplied elsewhere.

**Default:** No inferred value on a public declaration; use `no` explicitly when appropriate.

**Meaning (non-normative; [`L1`](../language.md#l1), [`L5`](../language.md#l5)):** Deprecation is advisory. The selected environments and `available` determine actual availability.

**Constraints:** Public roots and every member associated with a public nominal type count as public for this requirement. The versioned and unversioned forms keep their distinct operands ([`L1`](../language.md#l1), [`L5`](../language.md#l5)).

**Rejected when:** A public declaration lacks the clause, it repeats, or its value/constructor does not have one of the defined forms ([`L1`](../language.md#l1), [`L5`](../language.md#l5)).

**Example.** Fragment — the point teaching sketch with versioned advice. Header, replacement declaration, fields, availability and nominal contracts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=deprecated -->
```ail
package example::geometry version "2" {
  record Point {
    deprecated(since("2"), "Use Position instead.");
    // Fields, availability and nominal contracts omitted.
  }
  // Header, Position and publication context omitted.
}
```

The message advises using `Position` from version `2`. It does not remove `Point` from any environment.

**Used by and see also:** [`available`](#available); [`exports`](#exports); [`member`](#member).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="doc"></a>

## `doc`

**Expresses:** [The published description](../explanation/model.md#description) — human-readable explanation accompanying published facts.

**Form:** `doc("text");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One string containing the description.

**Applies to:** Any declaration, an [outcome](../glossary.md#outcome), or the package. A pattern role is documented on its containing pattern.

**Required and repeatability:** Optional and singular in each scope.

**Default:** No description is supplied when absent.

**Meaning (non-normative; [`L5`](../language.md#l5), [`L6`](../language.md#l6), [`A5`](../profiles.md#a5), [`C8`](../contracts.md#c8)):** The text explains a declaration or contract for readers; applicable contract clauses still supply the authoritative facts.

**Constraints:** Documentation cannot replace a required contract or create a pattern law. Navigation and documentation survive a lossless authoring round trip even though they are excluded from semantic equality ([`L5`](../language.md#l5), [`L6`](../language.md#l6), [`A5`](../profiles.md#a5), [`C8`](../contracts.md#c8)).

**Rejected when:** The clause repeats in a scope, appears outside its allowed scopes, or a package relies on prose in place of a required contract ([`L5`](../language.md#l5), [`L6`](../language.md#l6), [`A5`](../profiles.md#a5), [`C8`](../contracts.md#c8)).

**Example.** Fragment — the existing navigation teaching sketch. Header, fixture profile pin, fields and publication/nominal facts are omitted. The URL is illustrative.

<!-- ail-example: ../examples/reference/clauses-package.ail region=navigation -->
```ail
package example::geometry version "1" {
  doc("Coordinates used by the invented drawing API.");
  link("https://example.invalid/geometry");
  record Point {
    source(fixture, "Geometry.Point");
    doc("A position measured along two axes.");
    // Fields, availability and nominal contracts omitted.
  }
  // Header, fixture pin and publication context omitted.
}
```

The package text introduces the drawing API; the `Point` text explains what its coordinates mean. Each description belongs to a different scope.

**Used by and see also:** [Package](declarations.md#package); [`link`](#link); [`source`](#source).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="exports"></a>

## `exports`

**Expresses:** [The published description](../explanation/model.md#description) — the public roots of a package's API subset.

**Form:** `exports([@a, @b]);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A list of declaration references.

**Applies to:** Package body.

**Required and repeatability:** Required and singular.

**Default:** None; public roots are explicit.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)):** The listed roots identify the public API. Referenced support declarations remain part of the authoritative [dependency closure](../glossary.md#dependency-closure).

**Constraints:** Roots contain no duplicates and referenced declarations exist. A declared subset may omit unrelated APIs, while retaining the dependencies and required behaviour of its exported declarations ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Rejected when:** The clause is missing or duplicated, a root repeats or cannot resolve, or an exported declaration's required dependency or behaviour is omitted ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Example.** Fragment — the invented point package. Header, environments, provider pins and remaining nominal/publication facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=publication -->
```ail
package example::geometry version "1" {
  surface("An invented point API, release 1.");
  exports([@Point]);
  record Point {
    field x: i32;
    field y: i32;
    // Availability and nominal contracts omitted.
  }
  // Header, environments and provider pins omitted.
}
```

`Point` is the public root. Its required dependencies remain authoritative even if they are not additional roots in this list.

**Used by and see also:** [Package](declarations.md#package); [`surface`](#surface); [`deprecated`](#deprecated).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="extends"></a>

## `extends`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the interfaces inherited by an interface.

**Form:** `extends([@I, ...]);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A list of interface declaration references, possibly empty.

**Applies to:** Interfaces.

**Required and repeatability:** Required exactly once per interface.

**Default:** None; an empty list explicitly records no inherited interfaces.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)):** The interface names the interfaces from which it inherits.

**Constraints:** Interface inheritance is acyclic. Each reference resolves to an interface available where it is used; duplicate set members are invalid ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)).

**Rejected when:** A reference is unresolved, has the wrong kind or availability, repeats in the set, or creates an interface-inheritance cycle ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)).

**Example.** Fragment — the nominal-relation teaching sketch. Header, providers, members, lifetimes and publication facts are omitted; completing it requires compatible implementations and provider support.

<!-- ail-example: ../examples/reference/clauses-package.ail region=relations -->
```ail
package example::drawing version "1" {
  interface Drawable {
    extends([]);
    // Nominal contracts omitted.
  }
  object Shape {
    base(none);
    implements([]);
    // Nominal contracts omitted.
  }
  object Dot {
    base(@Shape);
    implements([@Drawable]);
    // Nominal contracts omitted.
  }
  // Header, providers, members and publication context omitted.
}
```

`Drawable` inherits no other interface. The object `Dot` records its separate conformance through `implements`.

**Used by and see also:** [Interface](declarations.md#interface); [`implements`](#implements); [`requirement`](#requirement).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="extension"></a>

## `extension`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the source extension or category contributing a member.

**Form:** `extension(profileAlias, "name", "origin");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A declared profile alias and two strings naming the source extension/category and its origin.

**Applies to:** Members contributed by a source extension or category.

**Required and repeatability:** Optional and singular.

**Default:** No extension/category provenance is stated when absent.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A1`](../profiles.md#a1), [`C8`](../contracts.md#c8)):** The clause records the member's source extension/category. The package declaring the member owns its identity.

**Constraints:** The receiver type may be imported. The profile defines the source interpretation, and ordinary member, receiver and dependency requirements still apply ([`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A1`](../profiles.md#a1), [`C8`](../contracts.md#c8)).

**Rejected when:** The clause is used outside its member scope, repeats, names an unresolved provider, or requires unsupported profile semantics ([`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A1`](../profiles.md#a1), [`C8`](../contracts.md#c8)).

**Example.** Fragment — the existing imported-member teaching sketch. Header, pinned `Drawing` import, fixture alias, publication facts and callable contracts are omitted; it does not demonstrate a complete `F1`-supported package.

<!-- ail-example: ../examples/reference/clauses-package.ail region=extension -->
```ail
package example::canvas_extras version "1" {
  fn refresh(canvas: Drawing::Canvas) -> unit {
    member(@Drawing::Canvas, instance);
    receiver($canvas);
    extension(fixture, "Refresh", "CanvasExtras");
    // Callable contracts omitted.
  }
  // Header, Drawing import, fixture pin and publication context omitted.
}
```

`refresh` belongs to `example::canvas_extras`. Its receiver type is `Canvas` from the imported `Drawing` package; `Refresh` and `CanvasExtras` describe source provenance.

**Used by and see also:** [Import](declarations.md#import); [`member`](#member); [`receiver`](#receiver); [`source`](#source).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="feature"></a>

## `feature`

**Expresses:** [The published description](../explanation/model.md#description) — an exact provider-interpreted configuration switch.

**Form:** `feature("name", true);` or `feature("name", false);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A nonempty feature-name string and a Boolean.

**Applies to:** Environment bodies.

**Required and repeatability:** Optional; repeatable by feature name, with each name appearing at most once.

**Default:** No implicit feature value is specified by the core.

**Meaning (non-normative; [`L1`](../language.md#l1), [`L3`](../language.md#l3), [`C8`](../contracts.md#c8)):** Each stated switch refines the environment's exact configuration.

**Constraints:** Selected providers interpret the configuration values. Feature names cannot repeat, even with the same Boolean. Two environments cannot describe the same configuration ([`L1`](../language.md#l1), [`L3`](../language.md#l3), [`C8`](../contracts.md#c8)).

**Rejected when:** A name is empty or repeated, a value is not Boolean, configurations duplicate each other, or required provider semantics are unsupported ([`L1`](../language.md#l1), [`L3`](../language.md#l3), [`C8`](../contracts.md#c8)).

**Example.** Fragment — a constructed refinement of the environment teaching form. All strings are hypothetical provider values, not additions to `F1`. Header, capable provider pins, declarations and other publication facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=environment -->
```ail
package example::configuration version "1" {
  environment selected {
    target("example64");
    platform("example-os", "3");
    toolchain("example-compiler", "2");
    runtime("example-runtime", "5");
    feature("tracing", true);
    feature("vector", false);
  }
  // Header, capable provider pins, declarations and publication context omitted.
}
```

This configuration explicitly enables `tracing` and disables `vector`. The selected provider would define what those names mean; omission supplies no core-inferred Boolean.

**Used by and see also:** [Environment](declarations.md#environment); [`target`](#target); [`runtime`](#runtime).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="implements"></a>

## `implements`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the interfaces a nominal type conforms to.

**Form:** `implements([@I, ...]);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A list of interface declaration references, possibly empty.

**Applies to:** Objects, records and resources.

**Required and repeatability:** Required exactly once in each applicable declaration.

**Default:** None; an empty list explicitly states no interface conformances.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)):** The type records its interface conformances, whose required members need implementations.

**Constraints:** Every required interface member has an implementation; optional members may be absent. A profile defines external implementations not represented by local `satisfies` relations. Names and source spellings alone do not establish conformance. References obey availability; duplicate set members are invalid ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)).

**Rejected when:** A referenced interface is unresolved or unavailable, a required implementation is absent, or a claimed external implementation lacks a defining profile ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)).

**Example.** Fragment — the nominal-relation teaching sketch. Header, providers, full member implementations, lifetimes and publication facts are omitted; the shown relation alone is not a complete conformance proof.

<!-- ail-example: ../examples/reference/clauses-package.ail region=relations -->
```ail
package example::drawing version "1" {
  interface Drawable {
    extends([]);
    // Nominal contracts omitted.
  }
  object Shape {
    base(none);
    implements([]);
    // Nominal contracts omitted.
  }
  object Dot {
    base(@Shape);
    implements([@Drawable]);
    // Nominal contracts omitted.
  }
  // Header, providers, members and publication context omitted.
}
```

`Shape` states no conformances. `Dot` claims `Drawable` and therefore needs implementations of that interface's required members.

**Used by and see also:** [Object](declarations.md#object); [record](declarations.md#record); [resource](declarations.md#resource); [`satisfies`](#satisfies).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="isolation"></a>

## `isolation`

**Expresses:** [Where and when calls run](../explanation/model.md#execution) — the [executor](../glossary.md#executor) restricting use of a nominal value or global.

**Form:** `isolation(none);`, `isolation(main);` or `isolation(executor(profileAlias, "identity"));` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** The bare value `none` or `main`, or an `executor` constructor taking a declared profile alias and an executor-identity string.

**Applies to:** Records, resources, objects, interfaces, enums, flags, aliases and [callback](../glossary.md#callback) declarations; globals and constants with access paths follow `C7`'s output rules.

**Required and repeatability:** Required and singular in the applicable scopes.

**Default:** None; `none` explicitly records known absence of nominal [isolation](../glossary.md#isolation).

**Meaning (non-normative; [`C2`](../contracts.md#c2), [`C7`](../contracts.md#c7)):** Isolation states an executor restriction. For callbacks it governs the callback value and captured state; callable entry has its own `executor` contract.

**Constraints:** `sharing(confined)` needs a non-`none` executor. Confinement covers use through free functions, retain/release and destruction as well as member entry, unless a profile defines a specific legal transfer protocol or permitted exception. Aliases agree with their expanded types ([`C2`](../contracts.md#c2), [`C7`](../contracts.md#c7)).

**Rejected when:** A confined value has `isolation(none)` (`N19`), an operation violates the required executor without a defined exception, or an alias contradicts its expanded type ([`C2`](../contracts.md#c2), [`C7`](../contracts.md#c7)).

**Example.** Fragment — `Counter`'s lifetime and isolation from the synthetic object fixture. Header, fixture pin, members and remaining declaration/publication facts are omitted; see the [complete object example](../examples/objects.ail).

<!-- ail-example: ../examples/reference/clauses-package.ail region=isolation -->
```ail
package example::objects version "1" {
  object Counter {
    lifecycle(refcounted, runtime(fixture, "retain"), runtime(fixture, "release"));
    sharing(confined);
    isolation(main);
    // Base, interfaces, availability and deprecation omitted.
  }
  // Header, fixture pin, members and publication context omitted.
}
```

`Counter` use and its retain/release lifecycle are confined to the main executor. Its members therefore state compatible callable entry requirements.

**Used by and see also:** [`sharing`](#sharing); [`lifecycle`](#lifecycle); [callback](declarations.md#callback); [global](declarations.md#global); [`N19`](../conformance.md#rejection-mutations).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="lifecycle"></a>

## `lifecycle`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — how an owned [handle](../glossary.md#handle) or reference is released.

**Form:** `lifecycle(unique, @destroy);` or `lifecycle(refcounted, runtime(profileAlias, "retain"), runtime(profileAlias, "release"));` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** `unique` takes a destructor function reference. `refcounted` takes two `runtime` constructors, each naming a declared profile and an exact primitive identity string.

**Applies to:** Resources, objects and interfaces; `unique` is resource-only.

**Required and repeatability:** Required exactly once per applicable declaration.

**Default:** None; an owned value's release protocol is explicit.

**Meaning (non-normative; [`C2`](../contracts.md#c2), [`C8`](../contracts.md#c8)):** A unique owned handle carries one destruction duty. A reference-counted owned reference carries one release duty; retaining it creates another.

**Constraints:** A unique destructor has one non-null parameter of that resource type, consumes it at entry, returns `unit`, and has only a successful returned outcome. Destruction invalidates dependent borrows before return. Reference-counted lifecycles use provider-defined runtime primitives, destruction and finalization ([`C2`](../contracts.md#c2), [`C8`](../contracts.md#c8)).

**Rejected when:** Lifecycle is absent (`N09`), a unique destructor's signature or consumption is wrong (`N10`), `unique` is used on a non-resource, or runtime semantics are unresolved or unsupported ([`C2`](../contracts.md#c2), [`C8`](../contracts.md#c8)).

**Example.** Fragment — the existing unique-resource teaching sketch. Header, publication facts, full effects, outcome and access are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=lifecycle -->
```ail
package example::buffers version "1" {
  resource Store {
    lifecycle(unique, @destroy);
    sharing(transferable);
    isolation(none);
    // Availability, deprecation and implements omitted.
  }
  fn destroy(store: Store) -> unit {
    input($store, consume);
    retain($store, none);
    // Effects, successful returned outcome and access omitted.
  }
  // Header and publication context omitted.
}
```

The caller releases an owned `Store` through `destroy`; `input($store, consume)` transfers that duty at entry. Reference counting uses the separate [runtime form](#runtime).

**Used by and see also:** [Resource](declarations.md#resource); [`runtime`](#runtime); [`isolation`](#isolation); [`N09`/`N10`](../conformance.md#rejection-mutations); review tasks: [Author a complete call contract](../review/tasks.md#author).

See also [Release responsibility](../explanation/model.md#responsibility) for which calls take, keep or hand back the release duty.

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="link"></a>

## `link`

**Expresses:** [The published description](../explanation/model.md#description) — navigation accompanying the published description.

**Form:** `link("URI");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One URI string.

**Applies to:** Declarations and the package.

**Required and repeatability:** Optional and explicitly repeatable.

**Default:** No navigation link is supplied when absent.

**Meaning (non-normative; [`L1`](../language.md#l1), [`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)):** The URI leads readers to related material. It carries no imported contract authority.

**Constraints:** Use pinned dependencies for imported authority. `L5` gives `link` no per-URI uniqueness key; its explicit repeatability differs from singular clauses. Navigation survives a lossless authoring round trip ([`L1`](../language.md#l1), [`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)).

**Rejected when:** The operand is not a string, the clause is outside declaration/package scope, or it is used in place of a required dependency or contract ([`L1`](../language.md#l1), [`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)).

**Example.** Fragment — the existing navigation teaching sketch. The URL is illustrative; header, fixture pin, fields and remaining contracts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=navigation -->
```ail
package example::geometry version "1" {
  doc("Coordinates used by the invented drawing API.");
  link("https://example.invalid/geometry");
  record Point {
    source(fixture, "Geometry.Point");
    doc("A position measured along two axes.");
    // Fields, availability and nominal contracts omitted.
  }
  // Header, fixture pin and publication context omitted.
}
```

The package link points readers to background material. `source(fixture, "Geometry.Point")` separately supplies provider-interpreted identity.

**Used by and see also:** [`doc`](#doc); [`source`](#source); [import](declarations.md#import).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="literal"></a>

## `literal`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the value denoted by a constant.

**Form:** `literal(integer);`, `literal(true);`, `literal(false);` or `literal("string");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One integer, Boolean or string literal. Integers/Booleans match the constant's type; strings need a profile type.

**Applies to:** Constants.

**Required and repeatability:** Exactly one literal clause or one or more access paths; the alternatives are exclusive.

**Default:** No inferred value; a constant supplies a literal or access paths.

**Meaning (non-normative; [`L5`](../language.md#l5), [`C7`](../contracts.md#c7), [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2)):** A literal states the constant's value directly.

**Constraints:** Core integer and Boolean literals have matching types. String literals require a profile-defined type; a core pointer is not implicitly a string. Literal scalar constants need no ownership clauses ([`L5`](../language.md#l5), [`C7`](../contracts.md#c7), [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2)).

**Rejected when:** Literal and access paths are both supplied or both absent, the literal has the wrong type, or a string lacks a supporting profile type ([`L5`](../language.md#l5), [`C7`](../contracts.md#c7), [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2)).

**Example.** Fragment — the existing settings teaching sketch. Header, availability, deprecation and publication context are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=literal -->
```ail
package example::settings version "1" {
  constant default_limit: u32 {
    literal(16);
    // Availability and deprecation omitted.
  }
  // Header and publication context omitted.
}
```

`default_limit` denotes the `u32` value 16. Reading mutable settings instead uses the [global form](#mutable).

**Used by and see also:** [Constant](declarations.md#constant); [`mutable`](#mutable); [access](declarations.md#access).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="member"></a>

## `member`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the nominal owner associated with an operation or property.

**Form:** `member(@T, instance);`, `member(@T, static);` or `member(@T, initializer);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A nominal owner declaration reference and one member-kind value.

**Applies to:** Functions and properties.

**Required and repeatability:** Optional and singular; present when the declaration is a member.

**Default:** Without this association, the declaration has no member owner.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)):** The member stays a top-level declaration in its package and names its owner separately. `initializer` records source semantics.

**Constraints:** Instance and initializer functions have an explicit receiver; static and free functions forbid it. The owner may be local or imported and references obey availability. Initializer membership does not establish allocation or [ownership transfer](../glossary.md#ownership-transfer). Interface members need `requirement` ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Rejected when:** The owner cannot resolve, the clause appears outside functions/properties, a required receiver is missing, or a static/free function supplies a receiver ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Example.** Fragment — the canvas/geometry teaching example. Header, local `Canvas`, pinned `Geometry` import, publication facts and callable contracts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=member -->
```ail
package example::canvas version "1" {
  fn position(canvas: Canvas) -> Geometry::Point {
    member(@Canvas, instance);
    receiver($canvas);
    // Callable contracts omitted.
  }
  // Header, Canvas, Geometry import and publication context omitted.
}
```

`position` and `Canvas` are siblings in the canvas package. `@Canvas` is the local owner, while `Geometry::Point` names the imported result type. The [language-containment view](declarations.md) locates these relationships.

**Used by and see also:** [Function](declarations.md#fn); [property](declarations.md#property); [`receiver`](#receiver); [`extension`](#extension); [names](notation.md#names); review tasks: [Trace names and members](../review/tasks.md#trace).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="mutable"></a>

## `mutable`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — whether global storage can be written.

**Form:** `mutable(true);` or `mutable(false);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One Boolean.

**Applies to:** Globals.

**Required and repeatability:** Required exactly once per global.

**Default:** None; mutability is explicit.

**Meaning (non-normative; [`L5`](../language.md#l5), [`C7`](../contracts.md#c7), [`A2`](../profiles.md#a2)):** The global denotes storage whether it is writable or read-only. A constant instead denotes a value.

**Constraints:** Core mutable value globals use `sharing(confined)` and non-`none` isolation. Mutable reference globals and ownership-changing reads/writes need a profile or explicit accessor functions; atomics also need a profile. Global access paths and applicable output contracts remain required ([`L5`](../language.md#l5), [`C7`](../contracts.md#c7), [`A2`](../profiles.md#a2)).

**Rejected when:** Mutability is missing, a core mutable value global lacks confinement, or mutable-reference/atomic behaviour lacks a defining profile or explicit accessor model ([`L5`](../language.md#l5), [`C7`](../contracts.md#c7), [`A2`](../profiles.md#a2)).

**Example.** Fragment — the settings teaching sketch with the required core confinement. Header, access and remaining publication facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=mutable -->
```ail
package example::settings version "1" {
  global current_limit: u32 {
    mutable(true);
    sharing(confined);
    isolation(main);
    // Access, availability and deprecation omitted.
  }
  // Header and publication context omitted.
}
```

`current_limit` stores a `u32` that can change. Its main-executor isolation governs access to that mutable storage.

**Used by and see also:** [Global](declarations.md#global); [`literal`](#literal); [`sharing`](#sharing); [`isolation`](#isolation).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="overrides"></a>

## `overrides`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the member function an implementation overrides.

**Form:** `overrides(@fn);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A reference to the overridden member function.

**Applies to:** Functions.

**Required and repeatability:** Optional and singular.

**Default:** No override relation is asserted when absent.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)):** The function identifies the member whose implementation it overrides.

**Constraints:** The referenced member has a compatible signature, ownership and behaviour. The overriding function adds no stronger preconditions and supplies no weaker postconditions; dependency availability still applies ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Rejected when:** The target is unresolved or not a compatible member function, or the overriding contract strengthens preconditions or weakens postconditions ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Example.** Fragment — the existing member-relation sketch. Header, `Drawable`/`Shape`/`Dot` declarations, providers and full contracts are omitted; compatibility still needs to be established.

<!-- ail-example: ../examples/reference/clauses-package.ail region=function_relations -->
```ail
package example::drawing version "1" {
  fn required_draw(item: Drawable) -> unit {
    member(@Drawable, instance);
    receiver($item);
    requirement(required);
    // Callable contracts omitted.
  }
  fn shape_draw(item: Shape) -> unit {
    member(@Shape, instance);
    receiver($item);
    // Callable contracts omitted.
  }
  fn dot_draw(item: Dot) -> unit {
    member(@Dot, instance);
    receiver($item);
    overrides(@shape_draw);
    satisfies([@required_draw]);
    // Compatible signatures, ownership and behaviours required.
  }
  // Header, nominal declarations, providers and publication context omitted.
}
```

`dot_draw` identifies `shape_draw` as the overridden member and separately satisfies `required_draw`. The relation names alone do not demonstrate compatible contracts.

**Used by and see also:** [`base`](#base); [`member`](#member); [`satisfies`](#satisfies).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="platform"></a>

## `platform`

**Expresses:** [The published description](../explanation/model.md#description) — the exact platform release in an environment.

**Form:** `platform("name", "exact version");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** Two nonempty strings: platform name and exact version.

**Applies to:** Environment bodies.

**Required and repeatability:** Required exactly once per environment.

**Default:** None; required.

**Meaning (non-normative; [`L3`](../language.md#l3), [`A1`](../profiles.md#a1)):** The platform clause contributes exact configuration values interpreted by the selected providers.

**Constraints:** The version is exact, not a range. Environment configurations are distinct; imports match by configuration values rather than local names. Unlisted configurations lie outside the package's claims ([`L3`](../language.md#l3), [`A1`](../profiles.md#a1)).

**Rejected when:** The clause is missing or duplicated, a string is empty, the configuration duplicates another environment, or a required provider cannot support it ([`L3`](../language.md#l3), [`A1`](../profiles.md#a1)).

**Example.** Fragment — an invented declaration in `F1`'s synthetic configuration. Header, provider pins and remaining publication/nominal facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=availability -->
```ail
package example::geometry version "1" {
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
  record Point {
    available([test]);
    deprecated(no);
    field x: i32;
    field y: i32;
    // Remaining nominal contracts omitted.
  }
  // Header, provider pins and publication context omitted.
}
```

`platform("fixture", "1")` selects version 1 of the synthetic fixture platform. It states no fact about a real host operating system.

**Used by and see also:** [Environment](declarations.md#environment); [`target`](#target); [`available`](#available).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="receiver"></a>

## `receiver`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the parameter supplying a member function's owner value.

**Form:** `receiver($p);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A callable-local place naming an ordinary, explicitly named non-null parameter.

**Applies to:** Functions; required for instance and initializer members, forbidden on static and free functions.

**Required and repeatability:** Exactly once where required; never implicit.

**Default:** None; the receiver parameter is explicit.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)):** The parameter supplies the owner value for this invocation and remains part of the semantic signature even when an access provider lowers it to an implicit receiver.

**Constraints:** The parameter's type denotes the member owner or a provider-defined receiver type. It is non-null and carries the applicable input contracts. Property accessors follow their matching member kind ([`L2`](../language.md#l2), [`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)).

**Rejected when:** The receiver is missing where required, present on a static/free function, nullable, unresolved, or of an incompatible type ([`L2`](../language.md#l2), [`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)).

**Example.** Fragment — the canvas/geometry teaching example. Header, `Canvas`, `Geometry` import and full callable/publication contracts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=member -->
```ail
package example::canvas version "1" {
  fn position(canvas: Canvas) -> Geometry::Point {
    member(@Canvas, instance);
    receiver($canvas);
    // Callable contracts omitted.
  }
  // Header, Canvas, Geometry import and publication context omitted.
}
```

`$canvas` is the receiver value inside `position`; `@position::canvas` identifies that parameter [slot](../glossary.md#slot) from a declaration-reference argument. The parameter's type is written `Canvas`, without `@`.

**Used by and see also:** [`member`](#member); [`accessors`](#accessors); [names and references](notation.md#names); [places](notation.md#places); review tasks: [Trace names and members](../review/tasks.md#trace).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="requirement"></a>

## `requirement`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — whether an interface member needs an implementation.

**Form:** `requirement(required);` or `requirement(optional);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One bare member-requirement value: `required` or `optional`.

**Applies to:** Members of an interface; forbidden elsewhere.

**Required and repeatability:** Required exactly once for every interface member.

**Default:** None; the interface states each member's requirement.

**Meaning (non-normative; [`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)):** Conformance supplies every required member. An optional member may be absent on a particular receiver.

**Constraints:** Calling an optional member requires a profile-defined capability test for that receiver. Platform availability alone cannot establish that this receiver implements the member. `F1` does not support optional interface members ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)).

**Rejected when:** An interface member omits the clause, a non-interface member supplies it, a required implementation is absent, or an optional call lacks supported capability semantics ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)).

**Example.** Fragment — the member-relation teaching sketch. Header, interfaces/objects, providers and full callable/publication contracts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=function_relations -->
```ail
package example::drawing version "1" {
  fn required_draw(item: Drawable) -> unit {
    member(@Drawable, instance);
    receiver($item);
    requirement(required);
    // Callable contracts omitted.
  }
  fn shape_draw(item: Shape) -> unit {
    member(@Shape, instance);
    receiver($item);
    // Callable contracts omitted.
  }
  fn dot_draw(item: Dot) -> unit {
    member(@Dot, instance);
    receiver($item);
    overrides(@shape_draw);
    satisfies([@required_draw]);
    // Compatible signatures, ownership and behaviours required.
  }
  // Header, nominal declarations, providers and publication context omitted.
}
```

`required_draw` is a required member of `Drawable`. The `satisfies` relation identifies `dot_draw` as an implementation, whose contract must also be compatible.

**Used by and see also:** [Interface](declarations.md#interface); [`implements`](#implements); [`satisfies`](#satisfies); [capability preconditions](../contracts.md#c3).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="runtime"></a>

## `runtime`

**Expresses:** [The published description](../explanation/model.md#description) — a selected runtime in an environment; the lifecycle form also states [release responsibility](../explanation/model.md#responsibility).

**Form:** Environment clause: `runtime("id", "version");`. Lifecycle constructor: `runtime(profileAlias, "primitive")` inside `lifecycle(refcounted, ..., ...);`. ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** Use the enclosing scope to distinguish the two operand lists.

| Use of `runtime` | First operand | Second operand |
|---|---|---|
| Environment clause | Nonempty runtime identifier string | Nonempty version string |
| Lifecycle constructor | Declared profile alias | Primitive-identity string interpreted by that provider |

**Applies to:** The clause appears in environments; the constructor appears as the retain and release operands of reference-counted resource/object/interface lifecycles.

**Required and repeatability:** Environment: optional and singular. Reference-counted lifecycle: two runtime constructors, one per retain/release role.

**Default:** No runtime selection is inferred in an environment. A reference-counted lifecycle has no implicit retain/release primitives.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L3`](../language.md#l3), [`C2`](../contracts.md#c2), [`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)):** In an environment, `runtime` refines the exact configuration. In a lifecycle, it identifies the operations implementing reference counting.

**Constraints:** Environment strings are nonempty and the providers interpret the exact values. A lifecycle provider specifies the primitives, destruction and finalization. The two forms differ in scope and first-operand type; the profile alias is not a runtime identifier string ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`C2`](../contracts.md#c2), [`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).

**Rejected when:** An environment string is empty, the environment clause repeats, a lifecycle alias cannot resolve, or required runtime semantics are unsupported ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`C2`](../contracts.md#c2), [`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).

**Example.** Fragment — a hypothetical environment refining the existing teaching form. Its values require a provider beyond `F1`; header, provider pins, declarations and publication facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=environment -->
```ail
package example::configuration version "1" {
  environment selected {
    target("example64");
    platform("example-os", "3");
    toolchain("example-compiler", "2");
    runtime("example-runtime", "5");
    feature("tracing", true);
    feature("vector", false);
  }
  // Header, capable provider pins, declarations and publication context omitted.
}
```

Here `runtime` selects `example-runtime` version `5`. In the separate lifecycle example below, `fixture` is a profile alias and the strings name its reference-counting primitives.

**Example.** Fragment — the synthetic `Counter` lifecycle from the object fixture. Header, fixture pin, members and other declaration/publication facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=isolation -->
```ail
package example::objects version "1" {
  object Counter {
    lifecycle(refcounted, runtime(fixture, "retain"), runtime(fixture, "release"));
    sharing(confined);
    isolation(main);
    // Base, interfaces, availability and deprecation omitted.
  }
  // Header, fixture pin, members and publication context omitted.
}
```

`F1` defines `retain` and `release` for these synthetic object references. These constructors select operations; they do not add an environment runtime field.

**Used by and see also:** [Environment](declarations.md#environment); [`lifecycle`](#lifecycle); [provider dependencies](declarations.md#use).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="satisfies"></a>

## `satisfies`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — the interface member functions implemented by a function.

**Form:** `satisfies([@fn, ...]);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A list of member-function declaration references.

**Applies to:** Functions.

**Required and repeatability:** Optional and singular; the list contains the relations asserted by that function.

**Default:** No local satisfaction relation is asserted when absent; interface conformance obligations remain.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)):** The function identifies the interface members it implements.

**Constraints:** Signatures, ownership and behaviours are compatible, with no stronger preconditions or weaker postconditions. Each required interface member has an implementation; a profile defines external implementations not represented by local relations. References obey availability and set members do not duplicate ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)).

**Rejected when:** A target is unresolved or incompatible, contracts violate substitutability, or required interface members lack implementations ([`L2`](../language.md#l2), [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`A5`](../profiles.md#a5)).

**Example.** Fragment — the member-relation teaching sketch. Header, nominal declarations, providers, availability and complete contracts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=function_relations -->
```ail
package example::drawing version "1" {
  fn required_draw(item: Drawable) -> unit {
    member(@Drawable, instance);
    receiver($item);
    requirement(required);
    // Callable contracts omitted.
  }
  fn shape_draw(item: Shape) -> unit {
    member(@Shape, instance);
    receiver($item);
    // Callable contracts omitted.
  }
  fn dot_draw(item: Dot) -> unit {
    member(@Dot, instance);
    receiver($item);
    overrides(@shape_draw);
    satisfies([@required_draw]);
    // Compatible signatures, ownership and behaviours required.
  }
  // Header, nominal declarations, providers and publication context omitted.
}
```

`dot_draw` supplies an implementation of `required_draw`. Its separate override of `shape_draw` records a different relationship.

**Used by and see also:** [`implements`](#implements); [`requirement`](#requirement); [`overrides`](#overrides).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="sharing"></a>

## `sharing`

**Expresses:** [Where and when calls run](../explanation/model.md#execution) — how values or references may move between executors.

**Form:** `sharing(value);`, `sharing(transferable);`, `sharing(shared);` or `sharing(confined);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One sharing-mode value.

**Applies to:** Records, resources, objects, interfaces, enums, flags, aliases and callback declarations; globals and constants with access paths follow `C7`'s output rules.

**Required and repeatability:** Required and singular in its applicable scopes.

**Default:** None; enums/flags normally state `value` explicitly.

**Meaning (non-normative; [`C2`](../contracts.md#c2), [`C7`](../contracts.md#c7)):** Compare the modes to determine how a value or reference may cross executor boundaries.

| Mode | Permission |
|---|---|
| `value` | Freely copy scalar/value aggregates without reference obligations |
| `transferable` | Move sole ownership across executors, without concurrent access |
| `shared` | Pass references across executors; [concurrency](../glossary.md#concurrency) is governed per operation |
| `confined` | Use the value only on its declared executor |

**Constraints:** A record with reference leaves cannot use `value`. Aliases agree with their expanded type. Callback sharing covers the callback value and every capture. `confined` requires non-`none` isolation, including retain/release, destruction and free-function use. Core mutable value globals require confinement; shared references do not imply safe concurrent mutation ([`C2`](../contracts.md#c2), [`C7`](../contracts.md#c7)).

**Rejected when:** A reference-containing record claims `value`, an alias disagrees with its type, captures cannot support the callback type's permitted uses, or confinement lacks an executor (`N19`) ([`C2`](../contracts.md#c2), [`C7`](../contracts.md#c7)).

**Example.** Fragment — the unique `Store` teaching sketch. Header, availability, implements, full destructor contracts and publication context are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=lifecycle -->
```ail
package example::buffers version "1" {
  resource Store {
    lifecycle(unique, @destroy);
    sharing(transferable);
    isolation(none);
    // Availability, deprecation and implements omitted.
  }
  fn destroy(store: Store) -> unit {
    input($store, consume);
    retain($store, none);
    // Effects, successful returned outcome and access omitted.
  }
  // Header and publication context omitted.
}
```

`Store` permits transfer of sole ownership across executors. `Counter` in the [isolation example](#isolation) instead requires main-executor confinement.

**Used by and see also:** [`isolation`](#isolation); [`lifecycle`](#lifecycle); [callback](declarations.md#callback); [`N19`](../conformance.md#rejection-mutations).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="source"></a>

## `source`

**Expresses:** [The published description](../explanation/model.md#description) — a declaration's identity in a source system.

**Form:** `source(profileAlias, "identity");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** A declared profile alias and an exact source-identity string.

**Applies to:** Declarations.

**Required and repeatability:** Optional; repeatable by profile alias, with one identity per alias on the declaration.

**Default:** No source identity is inferred from the declaration name.

**Meaning (non-normative; [`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2), [`F1`](../profiles.md#f1)):** The provider interprets the source identity, including any nested naming. Canonical AIL identity still uses package name, package version and declaration name.

**Constraints:** The alias resolves to a pinned profile defining the identity's interpretation. Under `F1`, identities are nonempty exact strings with no further name resolution. Source spelling supplies neither interface conformance nor an [access path](../glossary.md#access-path) ([`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2), [`F1`](../profiles.md#f1)).

**Rejected when:** A profile alias is unresolved or repeated on the declaration, or the identity violates its provider's schema ([`L2`](../language.md#l2), [`L5`](../language.md#l5), [`A1`](../profiles.md#a1), [`A2`](../profiles.md#a2), [`F1`](../profiles.md#f1)).

**Example.** Fragment — the navigation teaching sketch. Header, fixture pin, fields and other publication/nominal facts are omitted; the URL is illustrative.

<!-- ail-example: ../examples/reference/clauses-package.ail region=navigation -->
```ail
package example::geometry version "1" {
  doc("Coordinates used by the invented drawing API.");
  link("https://example.invalid/geometry");
  record Point {
    source(fixture, "Geometry.Point");
    doc("A position measured along two axes.");
    // Fields, availability and nominal contracts omitted.
  }
  // Header, fixture pin and publication context omitted.
}
```

`Geometry.Point` is `F1`'s exact source string for the local `Point` declaration. It is separate from the declaration's AIL identity.

**Used by and see also:** [`doc`](#doc); [`link`](#link); [`extension`](#extension); [access](declarations.md#access); [names](notation.md#names).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="storage"></a>

## `storage`

**Expresses:** [Entities that outlive a call](../explanation/model.md#entities) — a property's storage policy as checked against its accessors.

**Form:** `storage(strong);`, `storage(weak);`, `storage(copy);`, `storage(unretained);` or `storage(value);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One property-storage value.

**Applies to:** Properties.

**Required and repeatability:** Required exactly once per property.

**Default:** None; required.

**Meaning (non-normative; [`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)):** The clause asserts a policy consistent with the setter's [retention](../glossary.md#retention) and getter's ownership. Those callable contracts determine the actual obligations.

**Constraints:** `strong`, `weak`, `copy` and `unretained` agree with the respective retention behaviour; copying requires profile semantics. `weak` requires zeroing and nullable reads after referent death. Value storage agrees with the property's value type and accessor contracts ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)).

**Rejected when:** The clause is missing or contradicts accessor contracts, weak reads cannot yield null after referent death, or a copying policy lacks provider support ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)).

**Example.** Fragment — the synthetic object's value property. Header, provider pins, `Counter`, full accessor functions and remaining publication facts are omitted; see the [complete object example](../examples/objects.ail).

<!-- ail-example: ../examples/reference/clauses-package.ail region=property -->
```ail
package example::objects version "1" {
  property count: u64 {
    member(@Counter, instance);
    accessors(@read_count, @write_count);
    storage(value);
    // Availability and deprecation omitted.
  }
  // Counter and the full read_count/write_count functions omitted.
  // Getter: (receiver: Counter) -> u64.
  // Setter: (receiver: Counter, value: u64) -> unit.
}
```

The `u64` property uses `storage(value)`. Reading it creates no reference-release duty; its full getter and setter describe the allowed operations.

**Used by and see also:** [Property](declarations.md#property); [`accessors`](#accessors); [retention contracts](../contracts.md#c3).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).

<a id="surface"></a>

## `surface`

**Expresses:** [The published description](../explanation/model.md#description) — the API subset and release a package claims to describe.

**Form:** `surface("description");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One description string.

**Applies to:** Package body.

**Required and repeatability:** Required exactly once.

**Default:** None; the publication scope is explicit.

**Meaning (non-normative; [`L3`](../language.md#l3), [`L5`](../language.md#l5)):** The description identifies which API subset and release the package specifies.

**Constraints:** Omitting an unrelated API from the declared subset is legitimate. Dependencies and required behaviour of exported declarations remain part of the complete description ([`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Rejected when:** The clause is absent or duplicated, or the claimed subset omits a required dependency or behaviour of an exported declaration ([`L3`](../language.md#l3), [`L5`](../language.md#l5)).

**Example.** Fragment — the invented point package. Header, environments, provider pins and remaining declaration facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=publication -->
```ail
package example::geometry version "1" {
  surface("An invented point API, release 1.");
  exports([@Point]);
  record Point {
    field x: i32;
    field y: i32;
    // Availability and nominal contracts omitted.
  }
  // Header, environments and provider pins omitted.
}
```

The surface describes release 1 of an invented point API; `exports` names the `Point` root within that scope.

**Used by and see also:** [Package](declarations.md#package); [`exports`](#exports); [`available`](#available).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="target"></a>

## `target`

**Expresses:** [The published description](../explanation/model.md#description) — the target configuration an environment selects.

**Form:** `target("triple");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One nonempty target string interpreted by selected providers.

**Applies to:** Environment bodies.

**Required and repeatability:** Required exactly once per environment.

**Default:** None; required.

**Meaning (non-normative; [`L3`](../language.md#l3), [`A1`](../profiles.md#a1)):** The target contributes an exact configuration value used by the providers to interpret the package.

**Constraints:** Each environment also has exactly one platform clause. Configurations are exact and distinct; the string alone does not define native [representation](../glossary.md#representation) or an [ABI](../glossary.md#abi) ([`L3`](../language.md#l3), [`A1`](../profiles.md#a1)).

**Rejected when:** The clause is absent or duplicated, its string is empty, the environment duplicates another configuration, or a required provider does not support it ([`L3`](../language.md#l3), [`A1`](../profiles.md#a1)).

**Example.** Fragment — a declaration in the synthetic fixture environment. Header, provider pins and other publication/nominal facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=availability -->
```ail
package example::geometry version "1" {
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
  record Point {
    available([test]);
    deprecated(no);
    field x: i32;
    field y: i32;
    // Remaining nominal contracts omitted.
  }
  // Header, provider pins and publication context omitted.
}
```

`fixture64` is `F1`'s supported target token. Its representation rules come from the synthetic providers, not from interpreting `64` as a complete ABI description.

**Used by and see also:** [Environment](declarations.md#environment); [`platform`](#platform); [provider dependencies](declarations.md#use).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="toolchain"></a>

## `toolchain`

**Expresses:** [The published description](../explanation/model.md#description) — the exact toolchain refining an environment.

**Form:** `toolchain("id", "version");` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** Two nonempty strings: toolchain identifier and exact version.

**Applies to:** Environment bodies.

**Required and repeatability:** Optional and singular.

**Default:** No toolchain value is inferred by the core.

**Meaning (non-normative; [`L3`](../language.md#l3), [`A1`](../profiles.md#a1), [`A4`](../profiles.md#a4), [`F1`](../profiles.md#f1)):** The clause refines a configuration with an identified compiler/toolchain release, interpreted by the providers.

**Constraints:** Values are exact, not ranges; duplicate configurations are invalid. A toolchain version alone is not an artifact identity or proof of reproducible layout. A source compatibility recipe defines its required compiler and other build inputs ([`L3`](../language.md#l3), [`A1`](../profiles.md#a1), [`A4`](../profiles.md#a4), [`F1`](../profiles.md#f1)).

**Rejected when:** A string is empty, the clause repeats, the configuration duplicates another environment, or the selected path's provider/build recipe requirements are not satisfied ([`L3`](../language.md#l3), [`A1`](../profiles.md#a1), [`A4`](../profiles.md#a4), [`F1`](../profiles.md#f1)).

**Example.** Fragment — the environment from the synthetic object fixture, shortened to its configuration. Header, fixture/native pins, declarations and publication facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=toolchain -->
```ail
package example::objects version "1" {
  environment test {
    target("fixture64");
    platform("fixture", "1");
    toolchain("fixture-compiler", "1");
  }
  // Header, fixture/native pins, declarations and publication context omitted.
}
```

The fixture's source-call recipe requires exactly `fixture-compiler` version `1`. The complete object fixture uses that environment for its source getter path.

**Used by and see also:** [Environment](declarations.md#environment); [`runtime`](#runtime); [access](declarations.md#access); [compatibility rules](../profiles.md#a4).

**Rationale:** [Packages, environments and access paths](../explanation/packages.md).

<a id="values"></a>

## `values`

**Expresses:** [Operations and their values](../explanation/model.md#operations) — the permitted values of an enum or flags type.

**Form:** `values(closed);` or `values(open);` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** One domain value: `closed` or `open`.

**Applies to:** Enums and flags.

**Required and repeatability:** Required exactly once.

**Default:** None; the value domain is explicit.

**Meaning (non-normative; [`L4`](../language.md#l4), [`L5`](../language.md#l5), [`C5`](../contracts.md#c5)):** Use the declaration kind and domain together to determine which values an outcome partition must cover.

| Declaration and domain | Permitted values |
|---|---|
| Enum with `closed` | Exactly the declared values |
| Flags with `closed` | Every bitwise combination of the declared positive single-bit cases, including zero |
| Enum or flags with `open` | Every value of the underlying integer type |

**Constraints:** The underlying type is a core integer type. Case names are distinct and values fit it; the core rejects duplicate values, with numeric aliases requiring a profile. Closed enums are nonempty; closed-flags cases each have exactly one bit set. Outcome coverage uses this domain ([`L4`](../language.md#l4), [`L5`](../language.md#l5), [`C5`](../contracts.md#c5)).

**Rejected when:** The domain clause is missing or unknown, cases violate the underlying type or uniqueness, a closed enum is empty, or a closed-flags case is not positive and single-bit ([`L4`](../language.md#l4), [`L5`](../language.md#l5), [`C5`](../contracts.md#c5)).

**Example.** Fragment — an invented enum using the existing type teaching form. Header, availability, deprecation, sharing, isolation and publication facts are omitted.

<!-- ail-example: ../examples/reference/clauses-package.ail region=values -->
```ail
package example::geometry version "1" {
  enum Axis: u8 {
    case horizontal = 0;
    case vertical = 1;
    values(closed);
    // Availability, deprecation, sharing and isolation omitted.
  }
  // Header and publication context omitted.
}
```

`Axis` permits only 0 and 1. With `values(open)`, the same underlying `u8` would also permit its unnamed values; outcome partitions would then cover that larger domain.

**Used by and see also:** [Enum](declarations.md#enum); [flags](declarations.md#flags); [outcome](declarations.md#outcome).

**Rationale:** [How AIL states a contract](../explanation/contracts.md).
