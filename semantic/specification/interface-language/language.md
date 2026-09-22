# Language and publication rules

Normative draft 0.1. **MUST**, **MUST NOT**, **SHOULD** and **MAY** express
requirements, prohibitions, recommendations and permissions in this draft.
Rules have stable identifiers for diagnostics; wording can change during review.

## L1. Text and syntax

A document MUST be valid UTF-8 without a byte-order mark. Identifiers contain
ASCII letters, digits and underscores, begin with a letter or underscore, and
are case-sensitive. Integers are decimal, have arbitrary mathematical precision
while parsing, and have no leading zero except `0`; `-0` is forbidden. A string
uses JSON double-quoted string syntax, including escapes; lone surrogate escapes
are invalid. Strings retain their decoded Unicode sequence without normalization.
Whitespace is space, tab, CR or LF. `//` comments end at a line break or EOF;
`/* ... */` comments do not nest. Comments have no semantics. Tokens use longest
match. Punctuation in [the grammar](grammar.ebnf) is literal.

Grammar keywords are contextual: their production determines their meaning;
the same spelling may name a clause or a declaration where a name is expected.
`true` and `false` are Boolean tokens, never identifiers. A constructor and bare name in a
value are distinguished by the following `(`. No evaluation, interpolation,
conditional compilation, includes or executable annotations occur during parsing.

The header MUST be `language "0.1";`. A parser may accept the general grammar
before diagnosing unsupported versions. Clause syntax is deliberately uniform;
its vocabulary is closed and typed by this document, [contracts](contracts.md)
and [profiles](profiles.md). Parseable does not imply valid. An unknown clause,
constructor or enum value is an error, except inside a recognised profile's
namespace. A profile's vocabulary MUST be equally closed and typed.

## L2. Identity and dependencies

A package has a qualified name and an opaque, nonempty version string. Its
canonical identity is `(package name, package version, declaration name)`.
Members are top-level declarations with a `member` clause; they are not nested
inside a nominal type. All local declaration names are unique, including
overloads. External/source names do not determine identity.

An import pins a package name, version and digest and introduces an alias.
`@Alias::name` addresses an imported declaration; `@name` addresses a local one.
`@operation::parameter` and `@operation::result` address slots; `receiver` is an
ordinary explicitly named parameter. A callback's slots use the same convention.
Import aliases and local declarations MUST NOT collide. Bare type names resolve
identically without `@`. No implicit package lookup or overload resolution occurs.
The names `result`, `exception` and `completion` cannot be parameter names.
Parameter names MUST be unique within a callable; outcome names MUST also be
unique within that callable. All core type and type-constructor names in L4 are
reserved against declaration/import/environment/provider aliases. They cannot be
shadowed; `u8` always denotes the core unsigned eight-bit type.

Digests use `sha256:` followed by 64 lowercase hexadecimal digits. Package
digests identify exact document bytes; catalogue digests identify exact provider
manifest bytes. Imports MUST form an acyclic graph. Every dependency MUST be
present in an explicitly supplied resolution set and match its digest. Validation
MUST NOT fetch dependencies or execute provider code implicitly. Installation and
trust decisions belong to tooling outside the language.
Throughout the full resolution closure, each package name/version MUST resolve
to exactly one digest. The same rule applies separately to each profile and ABI
identifier/version. Conflicting pins are an error before name resolution, even
when different import aliases are used.

`use profile` and `use abi` introduce distinct catalogue aliases with pinned
identifier, version and digest. Their names share the local namespace with
imports, environments and declarations. A provider reference always names its
declared alias; an arbitrary string cannot masquerade as an installed provider.

## L3. Publication and environments

Exactly one package clause `surface("description")` MUST describe what API
subset and release this package claims to specify. `exports([@a, @b])` MUST list
the public roots, without duplicates. All referenced declarations must exist;
private support declarations remain part of the authoritative closure. Omitting
an unrelated API from a declared subset is legitimate. Omitting a dependency or
a required behaviour of an exported declaration is not.

At least one `environment` is required. Each has exactly one `target("triple")`
and one `platform("name", "exact version")`; optional `toolchain("id", "version")`,
`runtime("id", "version")` and repeated `feature("name", true|false)` refine it.
All strings are nonempty; duplicate feature names are forbidden. These are exact
configuration values interpreted by the selected providers, not ranges or guesses.
Two environments MUST NOT describe the same configuration. Unlisted configurations
are outside the package's claims, not assertions of API absence there.

Every declaration except patterns and pattern instances MUST have exactly one
`available([env, ...])`, with a nonempty, duplicate-free set of local environment
names. References MUST resolve to declarations available in every environment in
which the referencing use is available. Imports are matched by configuration
values, not environment aliases. Environment-dependent signatures or contracts
require distinct declarations with disjoint availability or distinct identities;
there are no implicit conditional clauses.

Complete means all applicable core and profile obligations hold throughout this
declared scope. `unknown`, unresolved evidence, confidence and “to be inferred”
are not contract values. A producer MUST resolve conflicting inputs before
publication. Known absence is explicit where required. For example,
`isolation(none)` does not mean isolation analysis was omitted. Validation checks
internal consistency and completeness, not whether a binary actually honours
the author's assertions.

## L4. Type expressions

These are the core types. Type constructors have exactly the listed arity.

| Type | Meaning |
|---|---|
| `unit` | No value; only a result type, never stored or pointed to. |
| `bool`; `i8/i16/i32/i64`; `u8/u16/u32/u64`; `f32/f64` | Logical Boolean; fixed-width integers; IEEE binary floating values. Native representations require an access provider. |
| A declared name | Its nominal type, or expansion of its alias. |
| `ptr<T>`, `mutptr<T>` | Non-null pointers to readable, or readable/writable, storage of `T`. Ownership and extent are separate contracts. |
| `nullable<T>` | `T` or null. Only pointer, object, resource, interface or callback reference types qualify. Nested nullable is invalid. |
| `array<T, N>` | By-value fixed-length sequence; nonnegative integer `N`. |
| `complex<f32>`, `complex<f64>` | By-value pair of real and imaginary components; provider defines native representation. |

Records, enums, flags, arrays and complex types are value types. Objects,
resources, interfaces and callbacks are reference types. A `resource` is already
an opaque handle; `ptr<Resource>` means storage containing that handle, not
another spelling of the handle. Records have named, ordered fields; only records
may contain `field` declarations. Fields have distinct names and non-unit types.
By-value recursive types and alias cycles are invalid. Recursion through pointers
or references is legal. Reference-containing aggregates require recursive slot
contracts; aggregation never silently copies an ownership obligation.

An alias is transparent for semantic typing, retaining source identity via
`source`. A genuinely distinct handle MUST be a resource or object. An opaque
resource exposes no dereferenceable layout. An unrecorded pointer pointee MUST
NOT be converted into an opaque resource without authority for that contract.

An enum/flags underlying type MUST be a core integer type. Cases have distinct
names and values representable in that type. Numeric aliases require a profile;
duplicate values are rejected by the core. `values(closed|open)` is mandatory.
A closed enum permits exactly its declared values. Closed flags permit all
bitwise combinations of the declared single-bit positive case values, including
zero; each case must have exactly one bit set. Open enum/flags permit any value
of the underlying type, including unnamed values. Empty closed enums are invalid.

Profile types use `profileAlias::Type<...>` and require a provider-defined type
schema, representation and contract applicability rules. This is the extension
point for generics, existential objects, metatypes, receiver-dependent types,
selectors and other source constructs; no such type has an implicit core meaning.

## L5. Declarations and common clauses

Unless marked repeatable, clauses are singular in their stated scope. A duplicate
is invalid even if its values are equal. A clause outside its scope is invalid.
`@T` denotes a type reference below; “list” is the grammar's `[...]` value.

The slot clauses `input`, `retain`, `valid`, `direction`, `aliasing`, `extent`,
`contents`, `state`, `give` and `invalidated_by` are repeatable **by place**: exactly
one instance of each applicable clause per slot in its scope. Aggregate `state`
applies recursively, except that explicit child state is forbidden rather than
overriding its parent. Other slot clauses apply to the exact addressed leaf, so
an aggregate does not duplicate its children's ownership authority. `bind` and
`subject` are repeatable by role name, one per role. `law` is repeatable by its
whole operand tuple; identical duplicate laws are invalid. `requires`, `link`
and `source` follow their explicit repeatability rules below. Environment
`feature` is repeatable by feature name. No other core clause is repeatable.

| Clause | Scope and meaning |
|---|---|
| `doc("text")` | Optional on any declaration, pattern role's containing pattern, outcome or package. Human-readable description; cannot replace a required contract. |
| `link("URI")` | Repeatable on declarations/package, non-normative navigation. Does not import authority. |
| `source(profileAlias, "identity")` | Repeatable on declarations; unique per profile alias. Provider interprets exact source identity, including nested names. |
| `deprecated(no)` or `deprecated(since("version"), "message")` or `deprecated(unversioned, "message")` | Required on public declarations except patterns/instances. Marks advisory deprecation; environment selection determines actual availability. |
| `base(@T)` or `base(none)` | Required on objects; `T` must be an object. Single acyclic inheritance. |
| `implements([@I, ...])` | Required on objects/records/resources; interfaces they conform to, possibly empty. |
| `extends([@I, ...])` | Required on interfaces; acyclic interface inheritance. |
| `member(@T, instance\|static\|initializer)` | Optional on functions/properties; associates a declaration with a nominal owner. Instance/initializer functions require `receiver($p)`; static/free functions forbid it. Initializer describes source semantics, not an assumed allocation rule. |
| `receiver($p)` | Function only; names a non-null parameter whose type denotes the owner, or a provider-defined receiver type. |
| `requirement(required\|optional)` | Required on members of an interface; forbidden elsewhere. Optional call requires a capability test defined in contracts. |
| `overrides(@fn)`; `satisfies([@fn, ...])` | Optional function relations. Referenced members must have compatible signatures, ownership and behaviours; no stronger preconditions or weaker postconditions. |
| `extension(profileAlias, "name", "origin")` | Optional on members contributed by a source extension/category. The declaring package owns the member; the receiver type can be imported. |
| `accessors(@get, @set)` or `accessors(@get, none)` | Required on properties. Accessors are full functions, have the same member owner/kind and availability, and use the declared property type. Getter has only the receiver if any; setter additionally has one `value` parameter and returns `unit`. |
| `storage(strong\|weak\|copy\|unretained\|value)` | Required on properties. A consistency assertion about their accessor contracts, not a second ownership authority. |
| `literal(integer\|true\|false\|"string")` | Constant only; exactly one of literal or access paths. Core supports integer/Boolean literals of matching types; strings require a profile type. |
| `mutable(true\|false)` | Required on globals. A global is storage, even when immutable; a constant denotes a value. |

Every public root and every member associated with a public nominal type counts
as public for deprecation. Inherited lookup, property sugar and flattened member
lists are derived views. Each declaration and signature has one source of truth.
Interface conformance requires an implementation of every required member;
optional members may be absent. A profile must define external implementations
that are not represented by local `satisfies` relations. A type name or source
spelling alone does not establish conformance.

## L6. Patterns

A pattern declares typed roles with cardinalities `one` (1), `optional` (0..1),
`many` (0..unbounded), or `some` (1..unbounded). Every role has a unique name.
An instance references its pattern and binds **every** role, including empty
ones, exactly once with `bind(roleName, [@participant, ...])`. Type, operation,
slot and pattern roles accept only the respective canonical identities. A
pattern participant references a pattern instance, not a pattern declaration.
Slot identity includes its operation, avoiding ambiguous parameter names.

The core law forms inside a pattern are `law(before, roleA, roleB)` and
`law(releases, operationRole, typeRole)`. All operands must name declared roles.
`before` requires operation roles of cardinality `one`; it asserts that on every
resource instance shared by the two operations, a successful completion of A
precedes entry into B. The instance MUST also supply
`subject(roleA, @operation::parameter)` and `subject(roleB, @operation::parameter)`;
these must be reference slots of the same nominal resource type. Cyclic order is
invalid. `releases` requires a `one` operation and a `one` resource type; the
operation must be that type's declared unique destructor. Both laws are checked
against the referenced contracts and impose real client obligations. A `before`
law adds the corresponding state precondition to B; it cannot merely describe a
typical sequence. Instances inherit the intersection of participants' availability,
which MUST be nonempty. Pattern composition must be acyclic.

Other laws require a versioned profile defining typed operands, obligations and
validation, not free tokens or normative prose. A pattern's `doc` may explain a
law but cannot create one. Content hashes, instance placement and primary-role
heuristics are tooling choices; they do not duplicate explicit declaration identity.
