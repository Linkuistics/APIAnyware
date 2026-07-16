//! The **generated inbound IMP trampoline table** (`inbound-imp-table-k61`, realising
//! ADR-0059 §1 at corpus scale — the inbound dual of [`crate::dispatch_table`]).
//!
//! Every ObjC-side inbound entry the subclass/delegate surfaces install — an overridden
//! selector's IMP, a protocol method's forwarding IMP — is a typed `@convention(c)`
//! trampoline, **one per distinct inbound ABI signature**, rendered into the addon's
//! `src/Generated/InboundTable.swift` by the generate CLI's global pass. The runtime
//! keys installation by **ObjC type-encoding string** (`"q@:@"` — the string it hands
//! `defineSubclass`/`defineForwarder`, which the native side both looks up the IMP by
//! *and* passes to `class_addMethod` as the types string), so the generated map is
//! `awGeneratedInboundIMP(forEncoding:)`, consulted by inbound.swift's
//! `trampoline(forEncoding:)`.
//!
//! ## The mirror invariant (frontier form)
//!
//! No emitted `.ts` call site references an inbound entry yet (blocks are still
//! method_filter-deferred; delegate specs are not yet emitted), so the k58 call-site
//! mirror takes its **frontier** form here: [`collect_inbound_table`] walks *exactly*
//! (a) the [`bound_methods`] **instance** frontier the `.ts`/`.d.ts` class emitters walk
//! (an overridable method is a bound instance method; statics are not installable IMPs),
//! and (b) the [`bound_protocol_methods`] frontier the protocol `interface` emitter
//! walks. The future delegate-spec/block emitters must derive their encodings from
//! [`InboundSig`] here — one source, no drift. Racket's rule carries over: err toward
//! **over-collection** (an unused trampoline is dead code in the map; a missing one is a
//! delegate method that silently never fires — `respondsToSelector:` answers NO).
//!
//! ## The inbound alphabet (and what defers)
//!
//! Params/returns cover pointer-likes, `BOOL`, the integer scalars, and `float`/`double`
//! — the shapes the hand-written delivery core (generalised at k61) can carry across
//! the on-thread-0 *and* bounce paths. Plus, **params only**, the closed 9-member POD
//! geometry family (`inbound-struct-arg-surface-k123`, ADR-0055 §5a) — `drawRect:`'s
//! `CGRect` and its seven-type-mapper siblings. Collapses/deferrals, all deliberate:
//!
//! - **`Int8` collapses into `Bool`** — ObjC encodes both as `c` (`BOOL` is
//!   historically `signed char`), so the encoding-keyed map cannot tell them apart; the
//!   trampoline delivers/reads a JS boolean (the hand-written `c@:@` convention).
//! - **A struct-typed RETURN still defers, recorded** ([`DeferredInbound`], the k58
//!   honesty posture — never silent): the delivery core's single-`UInt64`-slot return
//!   model (`BounceReturnKind`) cannot yet carry a multi-word struct payload. Nothing in
//!   the sample-app portfolio demands one yet (`drawRect:`/mouse selectors are all
//!   `void`); widen it the same demand-driven way if that changes.
//! - **A C string (param or return) still defers, recorded** — unaffected by this widening.
//!
//! ## The block maker tables (`block-maker-tables-k62`, ADR-0059 §2)
//!
//! A block's invoke is the third inbound surface — but a block is built by a **maker**
//! (`makeBlock` noescape / `makeEscapingBlock` escaping), keyed by **signature-code
//! string**, not installed by encoding. The same [`InboundSig`] model carries it:
//! [`InboundSig::code_string`] is THE single inbound code alphabet (the IMP identifier is
//! `aw_ts_inb_<code>`; the maker switches key on `<code>` — the hand-written makers'
//! drifted codes, `PQb_v`/`_v`/`P_B`, canonicalise to `PQP_v`/`0_v`/`P_b`: a `BOOL*`
//! out-pointer is a pointer `P`, an empty param list is `0`, a `BOOL` return is `b`).
//!
//! **The block frontier is the *future* frontier**: block-carrying methods are still
//! [`crate::method_filter`]-deferred (no emitted call site names a block signature yet),
//! so [`collect_inbound_table`] walks the block-typed params of **all** class + protocol
//! methods — the exact set the emitter will admit when the block frontier opens. Racket's
//! over-collection rule again: an unused maker is a dead switch case; a missing one is a
//! future `makeBlock` returning `0` (a hard runtime error). Block-typed *returns* and
//! block-typed protocol *properties* are out of scope (externalized if they surface —
//! k62 brief). Struct/C-string shapes inside a block defer, recorded, like everything
//! else in the alphabet.
//!
//! ## The super-send table (`super-send-table-k63`, ADR-0059 §4)
//!
//! The fourth inbound surface, and the only one that is an *outbound* call shape: a JS
//! override reaches the implementation it shadows through `this.$super.sel_(…)`, which
//! dispatches `objc_msgSendSuper` from the emitted parent's `__cls` (so lookup begins at
//! the base and skips the override — the ADR-0034 `call-next-method` trap native `super.`
//! would hit). These are **napi callbacks** registered on the exports object
//! (`aw_ts_super_<code>`), the `$super` analogue of the outbound `aw_ts_msg_*` table —
//! not `@convention(c)` IMPs.
//!
//! Two facts make this table nearly free:
//!
//! - **The super frontier IS the IMP frontier.** A super-send exists exactly where an
//!   override can, and an override installs only for signatures in the IMP alphabet. So
//!   [`collect_inbound_table`] grows [`SuperEntry`] on the *same* walk, from the *same*
//!   [`InboundSig`], with the *same* deferral records ([`DeferredInbound`]) — no second
//!   walk, no super-specific alphabet or deferral vec.
//! - **The one extra axis is the retain axis** — borrowed from the outbound table. A
//!   super-send's *return* crosses to JS exactly as an outbound return does (the JS side
//!   needs the value now, on thread 0), so it carries the ADR-0057 §4 **three-state**
//!   axis: a `+0` object return folds `objcRetain` into the entry, a `+1` return (an
//!   overridden `init`/`copy` reached through `$super`) routes to the non-folding `…_o`
//!   sibling, and a pointer return that is *no object* (`SEL`, the `Class` metatype)
//!   routes to the non-folding, non-wrapping `…_n` sibling (k70/k71). The gate is the
//!   *identical* [`method_retain_axis`] predicate [`crate::dispatch_table`]'s collection
//!   and `emit_body`'s wrap-primitive pick read — one predicate, never a re-derived
//!   conjunction. There is no `…_e` axis: a super-send is a plain typed recast + call,
//!   and an `NSError**` cell is just a pointer argument at this ABI.

use std::collections::BTreeSet;

use apianyware_emit::enrichment::class_error_selectors;
use apianyware_types::ir::{Framework, Method};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_graph::declared_classes;
use crate::class_surface::bound_methods;
use crate::emit_class::method_retain_axis;
use crate::emit_protocol::bound_protocol_methods;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::native_dispatch::{AbiType, GeoStruct, NativeSig, RetainAxis};
use crate::protocol_graph::ProtocolRegistry;
use crate::swift_abi::{geo_helper_stem, geo_swift_type};

/// The Swift-identifier prefix every generated inbound trampoline carries — the inbound
/// dual of [`crate::native_dispatch::ENTRY_PREFIX`]. Shares the `aw_ts_` namespace
/// `APIAnywareTypeScript` owns (ADR-0011).
pub const INBOUND_IMP_PREFIX: &str = "aw_ts_inb_";

/// The exported-name prefix every generated super-send entry carries (module doc: the
/// super-send table) — the `$super` analogue of `aw_ts_msg_`.
pub const SUPER_ENTRY_PREFIX: &str = "aw_ts_super_";

/// One inbound-ABI shape — the [`AbiType`] alphabet restricted to what the inbound
/// delivery core carries (module doc): pointer-likes, `Bool` (absorbing `Int8`), the
/// remaining integer scalars, and the floats. Structs/C-strings have no variant — they
/// defer at collection.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum InboundType {
    Ptr,
    Bool,
    UInt8,
    Int16,
    UInt16,
    Int32,
    UInt32,
    Int64,
    UInt64,
    Float,
    Double,
    /// A by-value POD geometry struct (module doc) — **param-only**; never constructed for a
    /// return (`from_abi`'s `is_param` gate).
    Struct(GeoStruct),
}

/// The real `@encode()` string for one geometry struct (verified empirically against the live
/// `AppKit`/`Foundation`/`CoreGraphics` frameworks on the build machine — not guessed from
/// memory; `NSRange` in particular is `{_NSRange=QQ}`, not `{_NSRange=LL}` as `NSUInteger →
/// unsigned long` would suggest). `class_addMethod`'s types string is advisory, not ABI-critical
/// (module doc / `inbound-struct-arg-surface-k123`'s own Context measured this directly:
/// `NSResponder.mouseDown:`'s real encoding is `v24@0:8@16`, yet this target's existing
/// simplified `v@:@` rendering already dispatches correctly, VM-verified) — so these strings
/// deliberately omit byte offsets/frame size, matching the existing simplification level, while
/// still using the *correct* field layout rather than a placeholder.
fn objc_struct_encoding(g: GeoStruct) -> &'static str {
    match g {
        GeoStruct::CGRect => "{CGRect={CGPoint=dd}{CGSize=dd}}",
        GeoStruct::CGPoint => "{CGPoint=dd}",
        GeoStruct::CGSize => "{CGSize=dd}",
        GeoStruct::NSRange => "{_NSRange=QQ}",
        GeoStruct::NSEdgeInsets => "{NSEdgeInsets=dddd}",
        GeoStruct::NSDirectionalEdgeInsets => "{NSDirectionalEdgeInsets=dddd}",
        GeoStruct::NSAffineTransformStruct => "{?=dddddd}",
        GeoStruct::CGAffineTransform => "{CGAffineTransform=dddddd}",
        GeoStruct::CGVector => "{CGVector=dd}",
    }
}

/// The `BounceArg`/`napiFromBounceArgs` case name for one geometry struct (`bounce.swift`) —
/// `geo_helper_stem`'s stem with a lower-cased first letter (`Rect` → `rect`), so the Swift case
/// name matches the existing `napiMake<Stem>` naming by construction, no second naming choice.
fn bounce_case_name(g: GeoStruct) -> String {
    let stem = geo_helper_stem(g);
    let mut chars = stem.chars();
    match chars.next() {
        Some(c) => c.to_lowercase().collect::<String>() + chars.as_str(),
        None => String::new(),
    }
}

impl InboundType {
    /// Restrict an outbound [`AbiType`] to the inbound alphabet, or `None` for a shape
    /// the inbound delivery core cannot carry yet (a struct return / C string /
    /// `Void`-as-param). `is_param` gates the one asymmetry: a struct is admitted as a
    /// **parameter** (`inbound-struct-arg-surface-k123`) but still defers as a **return**
    /// (module doc — the single-slot delivery-core limitation).
    fn from_abi(t: AbiType, is_param: bool) -> Option<InboundType> {
        Some(match t {
            AbiType::Ptr => InboundType::Ptr,
            // ObjC encodes BOOL and signed char identically (`c`), so the encoding-keyed
            // map cannot distinguish them — collapse to the hand-written Bool convention.
            AbiType::Bool | AbiType::Int8 => InboundType::Bool,
            AbiType::UInt8 => InboundType::UInt8,
            AbiType::Int16 => InboundType::Int16,
            AbiType::UInt16 => InboundType::UInt16,
            AbiType::Int32 => InboundType::Int32,
            AbiType::UInt32 => InboundType::UInt32,
            AbiType::Int64 => InboundType::Int64,
            AbiType::UInt64 => InboundType::UInt64,
            AbiType::Float => InboundType::Float,
            AbiType::Double => InboundType::Double,
            AbiType::Struct(g) if is_param => InboundType::Struct(g),
            AbiType::CStr | AbiType::Struct(_) | AbiType::Void => return None,
        })
    }

    /// The ObjC type-encoding character — the runtime-facing content-address alphabet
    /// (matching the hand-written `q@:@`/`c@:@` conventions: every pointer-like is `@`).
    /// Never called for `Struct` (a struct is param-only; only [`InboundSig::type_encoding`]'s
    /// **return** arm calls this, and a struct is never a return, `from_abi`'s gate) —
    /// [`encoding_str`](Self::encoding_str) is the param-position sibling that does handle it.
    fn encoding_char(self) -> char {
        match self {
            InboundType::Ptr => '@',
            InboundType::Bool => 'c',
            InboundType::UInt8 => 'C',
            InboundType::Int16 => 's',
            InboundType::UInt16 => 'S',
            InboundType::Int32 => 'i',
            InboundType::UInt32 => 'I',
            InboundType::Int64 => 'q',
            InboundType::UInt64 => 'Q',
            InboundType::Float => 'f',
            InboundType::Double => 'd',
            InboundType::Struct(_) => unreachable!("a struct InboundType is never a return"),
        }
    }

    /// The ObjC type-encoding STRING for one param position — a struct's real (offset-free)
    /// bracket encoding ([`objc_struct_encoding`]), or every other shape's single
    /// [`encoding_char`](Self::encoding_char). The param-position sibling `type_encoding` needs
    /// because a struct encoding is not one character.
    fn encoding_str(self) -> String {
        match self {
            InboundType::Struct(g) => objc_struct_encoding(g).to_string(),
            other => other.encoding_char().to_string(),
        }
    }

    /// The single-char code in the generated Swift identifier — the outbound
    /// [`AbiType`] code alphabet (`P` for pointer-likes, `b` for the Bool collapse), or a
    /// geometry struct's own [`GeoStruct::code`] (`R`/`O`/`Z`/`G`/`E`/`D`/`A`/`T`/`V` —
    /// the same letters the outbound table already reserves for these nine, so the two
    /// alphabets read consistently side by side).
    fn code(self) -> char {
        match self {
            InboundType::Ptr => 'P',
            InboundType::Bool => 'b',
            InboundType::UInt8 => 'C',
            InboundType::Int16 => 's',
            InboundType::UInt16 => 'S',
            InboundType::Int32 => 'i',
            InboundType::UInt32 => 'I',
            InboundType::Int64 => 'q',
            InboundType::UInt64 => 'Q',
            InboundType::Float => 'f',
            InboundType::Double => 'd',
            InboundType::Struct(g) => g.code(),
        }
    }
}

/// A full inbound method ABI signature: the receiver and `_cmd` are the two implicit
/// leading pointers (as in [`NativeSig`]), so `params` holds only the visible arguments.
/// Unlike the outbound side there is no `_o`/`_e` axis — an inbound trampoline never
/// retains its return (a `+0` passthrough, the framework owns it for the call) and the
/// `NSError**` cell of a fallible *override* is just a pointer argument at the IMP ABI.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct InboundSig {
    pub params: Vec<InboundType>,
    /// `None` is a `void` return (a fire-and-forget delegate method / target-action).
    pub ret: Option<InboundType>,
}

impl InboundSig {
    /// The inbound signature of a method's visible params + return, or `None` when any
    /// shape falls outside the inbound alphabet (struct / C string / non-routable) —
    /// the caller records the deferral. Full params: for a fallible `…error:` method the
    /// trailing `NSError**` cell stays (at the IMP ABI it is a plain pointer the
    /// override receives), unlike the outbound `_e` entry that synthesises it.
    pub fn from_method(method: &Method) -> Option<InboundSig> {
        let native = NativeSig::from_method(method)?;
        let mut params = Vec::with_capacity(native.params.len());
        for p in native.params {
            params.push(InboundType::from_abi(p, true)?);
        }
        let ret = match native.ret {
            AbiType::Void => None,
            other => Some(InboundType::from_abi(other, false)?),
        };
        Some(InboundSig { params, ret })
    }

    /// The inbound signature of a **block**'s declared params + return (module doc:
    /// the block maker tables), or `None` when any shape falls outside the inbound
    /// alphabet (struct / C string / `void` in a param position) — the caller records
    /// the deferral. A block param that is itself a block/pointer classifies as `Ptr`
    /// (it crosses to JS as a raw handle — the `BOOL* stop` of
    /// `enumerateObjectsUsingBlock:` rides this, forward-compatible).
    pub fn from_block(params: &[TypeRef], return_type: &TypeRef) -> Option<InboundSig> {
        // Blocks are deliberately OUT of scope for the struct-param widening
        // (`inbound-struct-arg-surface-k123`'s own Context — nothing in the portfolio needs a
        // struct-typed block parameter yet) — `is_param: false` keeps a struct deferred here
        // even though it is a param position, matching the pre-widening behaviour exactly.
        let mut ps = Vec::with_capacity(params.len());
        for p in params {
            let abi = AbiType::from_type_ref(p)?;
            if abi == AbiType::Void {
                return None;
            }
            ps.push(InboundType::from_abi(abi, false)?);
        }
        let ret = match AbiType::from_type_ref(return_type)? {
            AbiType::Void => None,
            other => Some(InboundType::from_abi(other, false)?),
        };
        Some(InboundSig { params: ps, ret })
    }

    /// The ObjC type-encoding string — return, the implicit `@:` (self + `_cmd`), then
    /// the params: `(id) -> NSInteger` → `q@:@`. This is the string the runtime hands
    /// `defineSubclass`/`defineForwarder` (and on to `class_addMethod`), so it is the
    /// generated map's switch key; the future delegate-spec emitter must compute it
    /// from here (one source, no drift).
    pub fn type_encoding(&self) -> String {
        let mut s = String::new();
        s.push(self.ret.map_or('v', |t| t.encoding_char()));
        s.push_str("@:");
        for p in &self.params {
            s.push_str(&p.encoding_str());
        }
        s
    }

    /// The content-addressed signature-code string, `<param-codes>_<ret-code>` with `0`
    /// for an empty param list (the outbound naming style): `(id) -> NSInteger` →
    /// `P_q`, `void (^)(void)` → `0_v`, `BOOL (^)(id)` → `P_b`. **THE single inbound
    /// code alphabet**: [`imp_name`](Self::imp_name) is `aw_ts_inb_<code>`, the block
    /// maker switches key on `<code>`, and the runtime / future block emitter's
    /// signature strings must come from here — no second alphabet (the drift the
    /// hand-written makers had is what this function retires).
    pub fn code_string(&self) -> String {
        let params: String = if self.params.is_empty() {
            "0".to_string()
        } else {
            self.params.iter().map(|t| t.code()).collect()
        };
        format!("{params}_{}", self.ret.map_or('v', |t| t.code()))
    }

    /// The generated trampoline's Swift identifier, `aw_ts_inb_<code-string>`:
    /// `(id) -> NSInteger` → `aw_ts_inb_P_q`. Content-addressed, no shared counter.
    pub fn imp_name(&self) -> String {
        format!("{INBOUND_IMP_PREFIX}{}", self.code_string())
    }
}

/// One generated super-send entry (module doc: the super-send table): an inbound ABI
/// signature plus the retain-convention axis (`Some(Owned)` → the non-folding `…_o`
/// sibling; `Some(NoWrap)` → the non-folding, non-wrapping `…_n` sibling for a pointer
/// return that is no object, ADR-0057 §4 / k70/k71; `Some` exactly when the return is
/// `Ptr`-shaped). Ordered so a `BTreeSet` renders deterministically.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct SuperEntry {
    pub sig: InboundSig,
    pub axis: Option<RetainAxis>,
}

impl SuperEntry {
    /// The entry's exported name, `aw_ts_super_<code-string>` (+ `_o` owned / `_n`
    /// non-object pointer, mirroring [`NativeSig::entry_name`]): `(id) -> BOOL` →
    /// `aw_ts_super_P_b`. Keyed by the **same** [`InboundSig::code_string`] that names
    /// the IMP trampolines and the block makers — no new alphabet (which is what retires
    /// the hand-written pair's drifted `P_B`).
    pub fn name(&self) -> String {
        debug_assert_eq!(
            self.axis.is_some(),
            self.sig.ret == Some(InboundType::Ptr),
            "the retain axis exists exactly for a pointer (Ptr) return"
        );
        let mut name = format!("{SUPER_ENTRY_PREFIX}{}", self.sig.code_string());
        match self.axis {
            Some(RetainAxis::Owned) => name.push_str("_o"),
            Some(RetainAxis::NoWrap) => name.push_str("_n"),
            Some(RetainAxis::FoldRetain) | None => {}
        }
        name
    }
}

/// A frontier method whose signature falls outside the inbound alphabet (a geometry
/// struct / C string in the signature) — deferred, recorded, never silent (the k58
/// posture). `owner` is the class or protocol name. Shared by the IMP and super tables:
/// they walk one frontier through one alphabet, so a deferral is one record, not two.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DeferredInbound {
    pub owner: String,
    pub selector: String,
}

/// The whole-corpus inbound table: the deduplicated IMP signature set, the deduplicated
/// block-maker signature set (module doc: the block maker tables), and the recorded
/// deferrals of each.
#[derive(Debug, Clone, Default)]
pub struct InboundTable {
    pub entries: BTreeSet<InboundSig>,
    pub deferred: Vec<DeferredInbound>,
    /// Every distinct block-invoke signature over the block-typed params of all class +
    /// protocol methods — one noescape + one escaping maker each.
    pub block_entries: BTreeSet<InboundSig>,
    /// Block params whose invoke shape falls outside the inbound alphabet (a struct /
    /// C string among the block's params or return) — deferred, recorded, never silent.
    pub deferred_blocks: Vec<DeferredInbound>,
    /// The super-send entries (module doc): the same [`entries`](Self::entries)
    /// signatures fanned out over the three-state retain-convention axis. Same
    /// frontier, same alphabet, same [`deferred`](Self::deferred) records.
    pub super_entries: BTreeSet<SuperEntry>,
}

impl InboundTable {
    /// `(plain, owned, no_wrap)` super-send counts for the pass log — the `_o`/`_n`
    /// fan-out is the only way `super_entries` can outnumber `entries`.
    pub fn super_axis_counts(&self) -> (usize, usize, usize) {
        let owned = self
            .super_entries
            .iter()
            .filter(|e| e.axis == Some(RetainAxis::Owned))
            .count();
        let no_wrap = self
            .super_entries
            .iter()
            .filter(|e| e.axis == Some(RetainAxis::NoWrap))
            .count();
        (self.super_entries.len() - owned - no_wrap, owned, no_wrap)
    }
}

/// Collect the global, deduplicated inbound signature sets across all frameworks — the
/// table [`generate_inbound_swift`] renders. **IMPs**: walks the [`bound_methods`]
/// **instance** frontier per class (subclass-overridable — the identical frontier the
/// `.ts`/`.d.ts` emitters walk; statics are not installable instance IMPs) and the
/// [`bound_protocol_methods`] frontier per protocol (delegate methods — the identical
/// frontier the protocol `interface` emitter walks), so the trampoline map and every
/// surface that will hand encodings to `defineSubclass`/`defineForwarder` agree by
/// construction. **Super-sends**: the *same* frontier as the IMPs — a super-send exists
/// exactly where an override can — fanned out over the `owned` axis (module doc).
/// **Block makers**: walks the block-typed params of **all** class (incl. category) +
/// protocol methods — the *future* frontier, since block-carrying methods are still
/// method_filter-deferred (module doc).
pub fn collect_inbound_table(frameworks: &[Framework]) -> InboundTable {
    // The class recognition set is **admission-relevant** (a method naming a Swift nominal type
    // defers, `class_binding`), so the collector must carry the *identical* whole-program set the
    // emitters do or the two would walk different frontiers and break the mirror invariant. Enums
    // are not: they only change rendered type names, never admission or the ABI shape.
    let mapper = TsFfiTypeMapper::with_known_classes(declared_classes(frameworks));
    // Whole-program protocol registry, built the same way [`crate::emit_framework`] does — so
    // this table's conformed-protocol required-method flattening ([`bound_methods`]) walks the
    // identical frontier the emitted call sites do (`protocol-required-method-flattening-k102`).
    let protocol_registry = ProtocolRegistry::from_frameworks(frameworks);
    let mut table = InboundTable::default();
    for fw in frameworks {
        for cls in &fw.classes {
            let error_selectors = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
            let (_statics, instances) =
                bound_methods(cls, &mapper, &error_selectors, &protocol_registry);
            for m in instances {
                add_method(&mut table, &cls.name, m, &mapper);
            }
            let category_methods = cls.category_methods.iter().flat_map(|g| &g.methods);
            for m in cls.methods.iter().chain(category_methods) {
                add_block_params(&mut table, &cls.name, m);
            }
        }
        for proto in &fw.protocols {
            for m in bound_protocol_methods(proto, &mapper) {
                add_method(&mut table, &proto.name, m, &mapper);
            }
            for m in proto.required_methods.iter().chain(&proto.optional_methods) {
                add_block_params(&mut table, &proto.name, m);
            }
        }
    }
    table
}

/// Add one frontier method to the IMP set **and** the super set — one signature, one
/// deferral record. The super entry adds only the retain axis, computed by the SAME
/// [`method_retain_axis`] predicate `dispatch_table`'s collection and `emit_body`'s
/// wrap-primitive pick read (k70/k71), so an entry's name and its fold cannot disagree.
fn add_method(table: &mut InboundTable, owner: &str, method: &Method, mapper: &TsFfiTypeMapper) {
    match InboundSig::from_method(method) {
        Some(sig) => {
            let axis = method_retain_axis(method, mapper);
            table.super_entries.insert(SuperEntry {
                sig: sig.clone(),
                axis,
            });
            table.entries.insert(sig);
        }
        None => table.deferred.push(DeferredInbound {
            owner: owner.to_string(),
            selector: method.selector.clone(),
        }),
    }
}

/// Collect every block-typed param of `method` into the block-maker set (one deferral
/// record per unroutable block param — a method can carry more than one block).
fn add_block_params(table: &mut InboundTable, owner: &str, method: &Method) {
    for p in &method.params {
        let TypeRefKind::Block {
            params,
            return_type,
        } = &p.param_type.kind
        else {
            continue;
        };
        match InboundSig::from_block(params, return_type) {
            Some(sig) => {
                table.block_entries.insert(sig);
            }
            None => table.deferred_blocks.push(DeferredInbound {
                owner: owner.to_string(),
                selector: method.selector.clone(),
            }),
        }
    }
}

// ---------------------------------------------------------------------------
// Swift codegen
// ---------------------------------------------------------------------------

/// The Swift type in the `@convention(c)` closure for one inbound shape — the real IMP
/// ABI the ObjC runtime calls (raw ids stay `UInt`, the inbound.swift discipline).
fn swift_c_type(t: InboundType) -> &'static str {
    match t {
        InboundType::Ptr => "UInt",
        InboundType::Bool => "Bool",
        InboundType::UInt8 => "UInt8",
        InboundType::Int16 => "Int16",
        InboundType::UInt16 => "UInt16",
        InboundType::Int32 => "Int32",
        InboundType::UInt32 => "UInt32",
        InboundType::Int64 => "Int64",
        InboundType::UInt64 => "UInt64",
        InboundType::Float => "Float",
        InboundType::Double => "Double",
        // The real Swift geometry type (CoreGraphics/Foundation, guaranteed C layout) — the
        // same rendering the outbound tables use (`swift_abi::geo_swift_type`), so a
        // `@convention(c)` closure declaring this type gets the correct arm64 struct-passing
        // ABI from the Swift compiler itself, matching what AppKit's own compiled caller expects.
        InboundType::Struct(g) => geo_swift_type(g),
    }
}

/// The `BounceArg` expression carrying one visible arg across the delivery core (raw —
/// thread-agnostic; marshalled to napi on thread 0 by `napiFromBounceArgs`).
fn bounce_arg_expr(t: InboundType, name: &str) -> String {
    match t {
        InboundType::Ptr => format!(".handle({name})"),
        InboundType::Bool => format!(".bool({name})"),
        InboundType::Int64 => format!(".int64({name})"),
        InboundType::Int16 | InboundType::Int32 => format!(".int64(Int64({name}))"),
        InboundType::UInt64 => format!(".uint64({name})"),
        InboundType::UInt8 | InboundType::UInt16 | InboundType::UInt32 => {
            format!(".uint64(UInt64({name}))")
        }
        InboundType::Double => format!(".double({name})"),
        InboundType::Float => format!(".double(Double({name}))"),
        // One `BounceArg` case per geometry struct (`bounce.swift`) — carries the real Swift
        // struct value across the bg→main bounce exactly as `.handle`/`.double`/etc. do for
        // their shapes; `napiFromBounceArgs` is the one place that turns it into a JS object.
        InboundType::Struct(g) => format!(".{}({name})", bounce_case_name(g)),
    }
}

/// The `BounceReturnKind` the delivery core reads the JS return with (and the bounce
/// slot travels as) for one value return.
fn ret_kind(t: InboundType) -> &'static str {
    match t {
        InboundType::Ptr => ".handle",
        InboundType::Bool => ".bool",
        InboundType::Int16 | InboundType::Int32 | InboundType::Int64 => ".int64",
        InboundType::UInt8 | InboundType::UInt16 | InboundType::UInt32 | InboundType::UInt64 => {
            ".uint64"
        }
        InboundType::Float | InboundType::Double => ".double",
        InboundType::Struct(_) => unreachable!("a struct InboundType is never a return"),
    }
}

/// Reinterpret the delivery core's raw `UInt64` slot as the trampoline's typed C-ABI
/// return (the caller-side dual of `postCallbackCompletion`'s slot writes).
fn ret_expr(t: InboundType) -> &'static str {
    match t {
        InboundType::Ptr => "UInt(truncatingIfNeeded: slot)",
        InboundType::Bool => "slot != 0",
        InboundType::Int16 => "Int16(truncatingIfNeeded: Int64(bitPattern: slot))",
        InboundType::Int32 => "Int32(truncatingIfNeeded: Int64(bitPattern: slot))",
        InboundType::Int64 => "Int64(bitPattern: slot)",
        InboundType::UInt8 => "UInt8(truncatingIfNeeded: slot)",
        InboundType::UInt16 => "UInt16(truncatingIfNeeded: slot)",
        InboundType::UInt32 => "UInt32(truncatingIfNeeded: slot)",
        InboundType::UInt64 => "slot",
        InboundType::Float => "Float(Double(bitPattern: slot))",
        InboundType::Double => "Double(bitPattern: slot)",
        InboundType::Struct(_) => unreachable!("a struct InboundType is never a return"),
    }
}

/// The one-line doc summary for a trampoline — the signature in ObjC/Swift-ABI terms
/// plus its encoding key.
fn entry_doc(sig: &InboundSig) -> String {
    let params: String = sig
        .params
        .iter()
        .map(|p| format!(", {}", swift_c_type(*p)))
        .collect();
    let ret = sig.ret.map_or("Void", |t| swift_c_type(t));
    format!(
        "/// `(id self, SEL _cmd{params}) -> {ret}` — encoding `{}`.\n",
        sig.type_encoding()
    )
}

/// Emit one generated trampoline: a non-capturing `@convention(c)` closure (installable
/// as an ObjC IMP) that gathers its typed args as raw `[BounceArg]` and delivers through
/// the shared inbound core — on thread 0 synchronously, off-main via the bounce, JS
/// throws contained to the typed default (ADR-0059 §5/§7; the core owns all of that).
fn emit_trampoline(s: &mut String, sig: &InboundSig) {
    let name = sig.imp_name();
    s.push_str(&entry_doc(sig));

    let mut conv = vec!["UInt".to_string(), "UInt".to_string()];
    let mut closure_params = vec!["selfId".to_string(), "cmd".to_string()];
    let mut args = Vec::with_capacity(sig.params.len());
    for (i, p) in sig.params.iter().enumerate() {
        conv.push(swift_c_type(*p).to_string());
        closure_params.push(format!("a{i}"));
        args.push(bounce_arg_expr(*p, &format!("a{i}")));
    }
    let conv_ret = sig.ret.map_or("Void", |t| swift_c_type(t));
    s.push_str(&format!(
        "private let {name}: @convention(c) ({}) -> {conv_ret} = {{ {} in\n",
        conv.join(", "),
        closure_params.join(", ")
    ));
    let args = format!("[{}]", args.join(", "));
    match sig.ret {
        None => {
            s.push_str(&format!("  deliverInboundVoid(selfId, cmd, {args})\n"));
        }
        Some(t) => {
            s.push_str(&format!(
                "  let slot = deliverInboundValue(selfId, cmd, {args}, {})\n",
                ret_kind(t)
            ));
            s.push_str(&format!("  return {}\n", ret_expr(t)));
        }
    }
    s.push_str("}\n");
}

/// Emit one generated block-maker **pair** for `sig` (ADR-0059 §2): a noescape maker
/// capturing the bare `cbid` (the `__withNoescapeBlock` bracket owns the lifetime) and
/// an escaping maker capturing an `EscapingBlockHolder` (strong — the framework's last
/// `_Block_release` fires its `deinit` → registry-drop on thread 0). Both bodies are
/// the same gather-`[BounceArg]` + `deliverBlockVoid`/`deliverBlockValue` shape (the
/// hand-written cores in inbound.swift), `_Block_copy`'d to the heap; the returned
/// pointer carries the runtime's sole `+1`.
fn emit_block_maker_pair(s: &mut String, sig: &InboundSig) {
    let code = sig.code_string();
    let conv: Vec<&str> = sig.params.iter().map(|p| swift_c_type(*p)).collect();
    let conv = conv.join(", ");
    let conv_ret = sig.ret.map_or("Void", |t| swift_c_type(t));
    let params: Vec<String> = (0..sig.params.len()).map(|i| format!("a{i}")).collect();
    let params = params.join(", ");
    let args: Vec<String> = sig
        .params
        .iter()
        .enumerate()
        .map(|(i, p)| bounce_arg_expr(*p, &format!("a{i}")))
        .collect();
    let args = format!("[{}]", args.join(", "));
    // The closure body: void delivers fire-and-forget; a value return reinterprets the
    // delivery core's raw UInt64 slot per the C-ABI return kind (implicit single-
    // expression return).
    let body = |cbid: &str| match sig.ret {
        None => format!("deliverBlockVoid({cbid}, {args})"),
        Some(t) => {
            let call = format!("deliverBlockValue({cbid}, {args}, {})", ret_kind(t));
            ret_expr(t).replace("slot", &call)
        }
    };
    // A capture list always needs `in`, even with zero params; a bare zero-param
    // closure takes none (the hand-written makers' spellings).
    let noescape_head = if sig.params.is_empty() {
        String::new()
    } else {
        format!("{params} in ")
    };
    let escaping_head = if sig.params.is_empty() {
        "[holder] in ".to_string()
    } else {
        format!("[holder] {params} in ")
    };

    s.push_str(&format!(
        "/// `({conv}) -> {conv_ret}` — block code `{code}` (noescape: captures the bare cbid).\n"
    ));
    s.push_str(&format!(
        "private func awMakeBlock_{code}(_ cbid: UInt) -> UInt {{\n"
    ));
    s.push_str(&format!(
        "  let closure: @convention(block) ({conv}) -> {conv_ret} = {{ {}\n    {}\n  }}\n",
        noescape_head.trim_end(),
        body("cbid")
    ));
    s.push_str("  return UInt(bitPattern: _Block_copy(unsafeBitCast(closure, to: UnsafeRawPointer.self)))\n}\n\n");

    s.push_str(&format!(
        "/// Escaping sibling of `awMakeBlock_{code}` — captures the holder (strong), so teardown\n/// routes to thread 0 via its `deinit` when the framework does the last release.\n"
    ));
    s.push_str(&format!(
        "private func awMakeEscapingBlock_{code}(_ holder: EscapingBlockHolder) -> UInt {{\n"
    ));
    s.push_str(&format!(
        "  let closure: @convention(block) ({conv}) -> {conv_ret} = {{ {}\n    {}\n  }}\n",
        escaping_head.trim_end(),
        body("holder.cbid")
    ));
    s.push_str("  return UInt(bitPattern: _Block_copy(unsafeBitCast(closure, to: UnsafeRawPointer.self)))\n}\n");
}

/// Read one visible super-send arg out of its napi slot into the typed C-ABI value the
/// `objc_msgSendSuper` recast expects. `idx` is the napi arg slot: a super-send's visible
/// param `i` sits at `a[i + 3]`, after receiver + super-class + selector.
fn super_reader_expr(t: InboundType, idx: usize) -> String {
    match t {
        InboundType::Ptr => format!("napiReadHandle(env, a[{idx}])"),
        InboundType::Bool => format!("napiGetBool(env, a[{idx}])"),
        InboundType::UInt8 => format!("UInt8(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        InboundType::Int16 => format!("Int16(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        InboundType::UInt16 => format!("UInt16(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        InboundType::Int32 => format!("Int32(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        InboundType::UInt32 => format!("UInt32(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        InboundType::Int64 => format!("napiReadInt64(env, a[{idx}])"),
        InboundType::UInt64 => format!("napiReadUInt64(env, a[{idx}])"),
        InboundType::Float => format!("Float(napiReadDouble(env, a[{idx}]))"),
        InboundType::Double => format!("napiReadDouble(env, a[{idx}])"),
        // The same `napiRead<Stem>` reader the outbound tables already use
        // (`swift_abi::reader_expr`) — one JS-object-to-struct reading convention, whichever
        // direction is reading it.
        InboundType::Struct(g) => format!("napiRead{}(env, a[{idx}])", geo_helper_stem(g)),
    }
}

/// Marshal the super-send's typed C-ABI return `r` back to a napi value. A **pointer**
/// return carries the ADR-0057 §4 retain axis, exactly as an outbound entry's does: a
/// `+0` object return folds `objcRetain` (the JS wrapper's uniform +1), an `owned` (`+1`)
/// return hands its own retain straight over, and a non-object pointer (`_n`) never
/// folds — retaining a `Class` leaks, `objc_retain` on a `SEL` is UB (k70/k71).
fn super_ret_expr(t: InboundType, axis: Option<RetainAxis>) -> &'static str {
    match t {
        InboundType::Ptr if axis == Some(RetainAxis::FoldRetain) => {
            "napiMakeHandle(env, objcRetain(r))"
        }
        InboundType::Ptr => "napiMakeHandle(env, r)",
        InboundType::Bool => "napiMakeBool(env, r)",
        InboundType::Int16 | InboundType::Int32 => "napiMakeInt64(env, Int64(r))",
        InboundType::Int64 => "napiMakeInt64(env, r)",
        InboundType::UInt8 | InboundType::UInt16 | InboundType::UInt32 => {
            "napiMakeInt64(env, Int64(r))"
        }
        InboundType::UInt64 => "napiMakeUInt64(env, r)",
        InboundType::Float => "napiMakeDouble(env, Double(r))",
        InboundType::Double => "napiMakeDouble(env, r)",
        InboundType::Struct(_) => unreachable!("a struct InboundType is never a return"),
    }
}

/// The one-line doc summary for a super-send entry — the visible JS arg shape plus the
/// fold convention a reader needs at the entry.
fn super_entry_doc(sig: &InboundSig, axis: Option<RetainAxis>) -> String {
    let params: String = sig
        .params
        .iter()
        .map(|p| format!(", {}", swift_c_type(*p)))
        .collect();
    let ret = sig.ret.map_or("Void", |t| swift_c_type(t));
    let notes = match axis {
        Some(RetainAxis::Owned) => {
            " — +1 owned object return, NO fold (`__wrapOwned` takes the base's own +1, ADR-0057 §4)"
        }
        Some(RetainAxis::FoldRetain) => " — +0 object return, retain folded (ADR-0057 §4)",
        Some(RetainAxis::NoWrap) => {
            " — non-object pointer return (`SEL`/`Class`): never wrapped, NO fold (ADR-0057 §4)"
        }
        None => "",
    };
    format!("/// `(id recv, Class superCls, SEL{params}) -> {ret}`{notes}\n")
}

/// Emit one generated super-send entry (ADR-0059 §4): a napi callback that builds the
/// `objc_super {receiver, super_class}` pair, recasts `objc_msgSendSuper` to this
/// signature's concrete `@convention(c)` shape, calls it, and marshals the result back.
/// Method lookup begins at `super_class` — the emitted parent's `__cls` — so the base
/// implementation runs and the JS override is skipped (the ADR-0034 `call-next-method`
/// infinite-recursion trap a native `super.` would hit).
fn emit_super_entry(s: &mut String, sig: &InboundSig, axis: Option<RetainAxis>) {
    let name = SuperEntry {
        sig: sig.clone(),
        axis,
    }
    .name();
    s.push_str(&super_entry_doc(sig, axis));
    s.push_str(&format!(
        "private func {name}(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {{\n"
    ));
    s.push_str(&format!(
        "  let a = napiCallbackArgs(env, info, {})\n",
        sig.params.len() + 3
    ));
    // The two contiguous pointer-width fields of `struct objc_super`, passed by address.
    s.push_str(
        "  var sup: (receiver: UInt, superClass: UInt) = (napiReadHandle(env, a[0]), napiReadHandle(env, a[1]))\n",
    );

    let mut conv = vec!["UnsafeMutableRawPointer".to_string(), "UInt".to_string()];
    let mut call_args = vec![
        "UnsafeMutableRawPointer($0)".to_string(),
        "napiReadHandle(env, a[2])".to_string(),
    ];
    for (i, p) in sig.params.iter().enumerate() {
        conv.push(swift_c_type(*p).to_string());
        call_args.push(super_reader_expr(*p, i + 3));
    }
    let conv_ret = sig.ret.map_or("Void", |t| swift_c_type(t));
    s.push_str(&format!(
        "  typealias Fn = @convention(c) ({}) -> {conv_ret}\n",
        conv.join(", ")
    ));
    let call = format!(
        "unsafeBitCast(awMsgSendSuperAddr, to: Fn.self)({})",
        call_args.join(", ")
    );
    match sig.ret {
        None => {
            s.push_str(&format!(
                "  withUnsafeMutablePointer(to: &sup) {{\n    {call}\n  }}\n"
            ));
            s.push_str("  return napiUndefined(env)\n");
        }
        Some(t) => {
            s.push_str(&format!(
                "  let r = withUnsafeMutablePointer(to: &sup) {{\n    {call}\n  }}\n"
            ));
            s.push_str(&format!("  return {}\n", super_ret_expr(t, axis)));
        }
    }
    s.push_str("}\n");
}

/// Render the whole `Generated/InboundTable.swift`: the banner, one typed trampoline per
/// distinct signature (deterministic `BTreeSet` order — regeneration is diff-stable),
/// the `awGeneratedInboundIMP(forEncoding:)` map inbound.swift's
/// `trampoline(forEncoding:)` consults, one block-maker pair per distinct block
/// signature, the `awGeneratedMakeBlock`/`awGeneratedMakeEscapingBlock` switches
/// `aw_makeBlock`/`aw_makeEscapingBlock` consult, and one `aw_ts_super_*` napi callback
/// per super-send entry with the `awRegisterGeneratedSuperSends` registration
/// `napi_register_module_v1` calls.
pub fn generate_inbound_swift(table: &InboundTable) -> String {
    let mut s = String::new();
    s.push_str("// Generated inbound table for the Node TypeScript target (ADR-0059 §1/§2/§4,\n");
    s.push_str("// the inbound dual of Generated/DispatchTable.swift). DO NOT EDIT —\n");
    s.push_str("// regenerated by `apianyware-generate` from the IR. One typed\n");
    s.push_str("// @convention(c) trampoline per distinct inbound ABI signature over the\n");
    s.push_str("// subclass-overridable + delegate/protocol method frontiers, keyed by ObjC\n");
    s.push_str("// type encoding (inbound_table.rs) — the same string the runtime hands\n");
    s.push_str("// defineSubclass/defineForwarder, so map and callers agree with no shared\n");
    s.push_str("// state. Plus one noescape + escaping block-maker pair per distinct\n");
    s.push_str("// block-invoke signature over ALL class + protocol methods' block params\n");
    s.push_str("// (the future frontier), keyed by the same signature-code alphabet as the\n");
    s.push_str("// trampoline identifiers (InboundSig::code_string — no second alphabet).\n");
    s.push_str("// Plus one `aw_ts_super_<code>` napi callback per super-send entry — the\n");
    s.push_str("// $super analogue of the outbound aw_ts_msg_* table, over the SAME frontier\n");
    s.push_str("// as the IMP trampolines (a super-send exists exactly where an override\n");
    s.push_str("// can), fanned out over the ADR-0057 §4 three-state retain axis (`_o`\n");
    s.push_str("// owned / `_n` non-object pointer, k70/k71).\n");
    s.push_str("// Delivery (thread-0 fast path, off-main bounce, JS-throw containment,\n");
    s.push_str("// holder teardown) lives in the hand-written core (inbound.swift).\n\n");
    // AppKit for NSDirectionalEdgeInsets (the rest of the POD geometry family is
    // Foundation/CoreGraphics, already reachable transitively) — matching napi_support.swift's
    // own import (`inbound-struct-arg-surface-k123`).
    s.push_str("import AppKit\nimport Foundation\n\n");

    for sig in &table.entries {
        emit_trampoline(&mut s, sig);
        s.push('\n');
    }

    s.push_str("/// Map an ObjC type encoding to its generated trampoline IMP (`nil` if outside\n");
    s.push_str("/// the generated alphabet — the caller skips the override; ADR-0059 §1's\n");
    s.push_str("/// NSInvocation escape hatch is a later concern).\n");
    s.push_str("func awGeneratedInboundIMP(forEncoding encoding: String) -> IMP? {\n");
    s.push_str("  switch encoding {\n");
    for sig in &table.entries {
        s.push_str(&format!(
            "  case \"{}\": return unsafeBitCast({}, to: IMP.self)\n",
            sig.type_encoding(),
            sig.imp_name()
        ));
    }
    s.push_str("  default: return nil\n  }\n}\n\n");

    for sig in &table.block_entries {
        emit_block_maker_pair(&mut s, sig);
        s.push('\n');
    }

    s.push_str("/// Build a NOESCAPE block for `signature` capturing `cbid` (ADR-0059 §2 fast\n");
    s.push_str("/// path — the `__withNoescapeBlock` bracket owns the registry lifetime).\n");
    s.push_str("/// `0` for a signature outside the generated alphabet (the runtime turns that\n");
    s.push_str("/// into a hard, visible error).\n");
    s.push_str("func awGeneratedMakeBlock(_ cbid: UInt, _ signature: String) -> UInt {\n");
    s.push_str("  switch signature {\n");
    for sig in &table.block_entries {
        let code = sig.code_string();
        s.push_str(&format!(
            "  case \"{code}\": return awMakeBlock_{code}(cbid)\n"
        ));
    }
    s.push_str("  default: return 0\n  }\n}\n\n");

    s.push_str("/// Build an ESCAPING block for `signature` (ADR-0059 §2 default path) — the\n");
    s.push_str("/// holder is created here, never on the unknown-signature path, so no spurious\n");
    s.push_str("/// release-bounce fires (the runtime drops the just-minted registry entry on\n");
    s.push_str("/// the `0` error path).\n");
    s.push_str("func awGeneratedMakeEscapingBlock(_ cbid: UInt, _ signature: String) -> UInt {\n");
    s.push_str("  switch signature {\n");
    for sig in &table.block_entries {
        let code = sig.code_string();
        s.push_str(&format!(
            "  case \"{code}\": return awMakeEscapingBlock_{code}(EscapingBlockHolder(cbid))\n"
        ));
    }
    s.push_str("  default: return 0\n  }\n}\n\n");

    for entry in &table.super_entries {
        emit_super_entry(&mut s, &entry.sig, entry.axis);
        s.push('\n');
    }

    s.push_str("/// Register every generated super-send entry on the addon's exports object —\n");
    s.push_str("/// called by `napi_register_module_v1` (dispatch.swift), beside the outbound\n");
    s.push_str("/// `awRegisterGeneratedDispatch`. These are napi callbacks the emitted\n");
    s.push_str("/// `$super` accessor calls, not IMPs — they never enter the encoding map.\n");
    s.push_str("func awRegisterGeneratedSuperSends(_ env: napi_env?, _ exports: napi_value?) {\n");
    for entry in &table.super_entries {
        let name = entry.name();
        s.push_str(&format!("  napiDefine(env, exports, \"{name}\", {name})\n"));
    }
    s.push_str("}\n\n");

    s.push_str(&format!(
        "// {} generated inbound trampoline{} ({} frontier method{} deferred: struct/C-string shapes).\n",
        table.entries.len(),
        if table.entries.len() == 1 { "" } else { "s" },
        table.deferred.len(),
        if table.deferred.len() == 1 { "" } else { "s" },
    ));
    s.push_str(&format!(
        "// {} generated block-maker pair{} ({} block param{} deferred: struct/C-string shapes).\n",
        table.block_entries.len(),
        if table.block_entries.len() == 1 {
            ""
        } else {
            "s"
        },
        table.deferred_blocks.len(),
        if table.deferred_blocks.len() == 1 {
            ""
        } else {
            "s"
        },
    ));
    let (plain, owned, no_wrap) = table.super_axis_counts();
    s.push_str(&format!(
        "// {} generated super-send entr{}: {plain} plain (+0, folds), {owned} owned (`_o`, no fold), {no_wrap} non-object (`_n`, no fold, no wrap).\n",
        table.super_entries.len(),
        if table.super_entries.len() == 1 { "y" } else { "ies" },
    ));
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::enrichment::{ClassSelectorEntry, EnrichmentData};
    use apianyware_types::ir::{Class, Framework, Method, Param, Protocol};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn param(kind: TypeRefKind) -> Param {
        Param {
            name: "x".into(),
            param_type: ty(kind),
        }
    }

    fn method(selector: &str, class_method: bool, params: Vec<Param>, ret: TypeRef) -> Method {
        Method {
            selector: selector.into(),
            class_method,
            init_method: selector.starts_with("init"),
            params,
            return_type: ret,
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn class(name: &str, methods: Vec<Method>) -> Class {
        Class {
            name: name.into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn protocol(name: &str, required: Vec<Method>, optional: Vec<Method>) -> Protocol {
        Protocol {
            name: name.into(),
            inherits: vec![],
            required_methods: required,
            optional_methods: optional,
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    fn framework(name: &str, classes: Vec<Class>, protocols: Vec<Protocol>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes,
            protocols,
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    fn nsinteger() -> TypeRef {
        ty(TypeRefKind::Primitive {
            name: "NSInteger".into(),
        })
    }

    fn boolean() -> TypeRef {
        ty(TypeRefKind::Primitive {
            name: "bool".into(),
        })
    }

    #[test]
    fn encoding_and_name_are_content_addressed() {
        let sig = |params: Vec<InboundType>, ret: Option<InboundType>| InboundSig { params, ret };
        // (id) -> NSInteger : the hand-written compare: shape.
        let s = sig(vec![InboundType::Ptr], Some(InboundType::Int64));
        assert_eq!(s.type_encoding(), "q@:@");
        assert_eq!(s.imp_name(), "aw_ts_inb_P_q");
        // () -> NSInteger : the no-visible-arg value-returning shape.
        let s = sig(vec![], Some(InboundType::Int64));
        assert_eq!(s.type_encoding(), "q@:");
        assert_eq!(s.imp_name(), "aw_ts_inb_0_q");
        // (id, id) -> id : the archiver:willEncodeObject: shape.
        let s = sig(
            vec![InboundType::Ptr, InboundType::Ptr],
            Some(InboundType::Ptr),
        );
        assert_eq!(s.type_encoding(), "@@:@@");
        assert_eq!(s.imp_name(), "aw_ts_inb_PP_P");
        // (id) -> void : the target-action shape.
        let s = sig(vec![InboundType::Ptr], None);
        assert_eq!(s.type_encoding(), "v@:@");
        assert_eq!(s.imp_name(), "aw_ts_inb_P_v");
        // (id) -> BOOL : the isEqual: shape.
        let s = sig(vec![InboundType::Ptr], Some(InboundType::Bool));
        assert_eq!(s.type_encoding(), "c@:@");
        assert_eq!(s.imp_name(), "aw_ts_inb_P_b");
        // () -> double : a CGFloat-returning delegate method (heightOfRow-class).
        let s = sig(vec![], Some(InboundType::Double));
        assert_eq!(s.type_encoding(), "d@:");
        assert_eq!(s.imp_name(), "aw_ts_inb_0_d");
        // (NSUInteger) -> id : a scalar-arg shape.
        let s = sig(vec![InboundType::UInt64], Some(InboundType::Ptr));
        assert_eq!(s.type_encoding(), "@@:Q");
        assert_eq!(s.imp_name(), "aw_ts_inb_Q_P");
    }

    #[test]
    fn int8_collapses_into_bool() {
        // ObjC encodes BOOL and signed char identically (`c`) — the encoding-keyed map
        // cannot tell them apart, so both land on the Bool trampoline.
        let m = method(
            "charValue",
            false,
            vec![],
            ty(TypeRefKind::Primitive {
                name: "int8".into(),
            }),
        );
        let sig = InboundSig::from_method(&m).unwrap();
        assert_eq!(sig.ret, Some(InboundType::Bool));
        assert_eq!(sig.type_encoding(), "c@:");
        assert_eq!(sig.imp_name(), "aw_ts_inb_0_b");
    }

    #[test]
    fn a_struct_param_is_now_admitted_a_struct_return_still_defers() {
        // `inbound-struct-arg-surface-k123`: setFrame: (CGRect) -> void — the drawRect: shape —
        // is now admitted (param-only widening).
        let m = method(
            "setFrame:",
            false,
            vec![param(TypeRefKind::Struct {
                name: "CGRect".into(),
            })],
            TypeRef::void(),
        );
        let sig = InboundSig::from_method(&m).expect("a struct PARAM now admits");
        assert_eq!(sig.params, vec![InboundType::Struct(GeoStruct::CGRect)]);
        assert_eq!(sig.ret, None);
        assert_eq!(sig.type_encoding(), "v@:{CGRect={CGPoint=dd}{CGSize=dd}}");
        assert_eq!(sig.code_string(), "R_v");

        // A struct RETURN still defers — the single-`UInt64`-slot delivery-core limitation
        // (module doc), unaffected by this widening.
        let m = method(
            "frame",
            false,
            vec![],
            ty(TypeRefKind::Struct {
                name: "CGRect".into(),
            }),
        );
        assert_eq!(InboundSig::from_method(&m), None);
    }

    #[test]
    fn a_cstring_shape_still_defers() {
        let m = method("UTF8String", false, vec![], ty(TypeRefKind::CString));
        assert_eq!(InboundSig::from_method(&m), None);
    }

    #[test]
    fn block_codes_canonicalise_on_the_single_alphabet() {
        // void (^)(id, NSUInteger, BOOL *stop) — the enumerateObjectsUsingBlock: shape.
        // The hand-written maker spelled this PQb_v (`b` for the out-pointer, the k61
        // drift); canonically a `BOOL*` is a pointer → P.
        let sig = InboundSig::from_block(
            &[
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
                ty(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
                ty(TypeRefKind::Pointer),
            ],
            &TypeRef::void(),
        )
        .unwrap();
        assert_eq!(sig.code_string(), "PQP_v");
        // void (^)(void) — hand-written `_v` → canonical `0_v` (the outbound `0` style).
        let sig = InboundSig::from_block(&[], &TypeRef::void()).unwrap();
        assert_eq!(sig.code_string(), "0_v");
        // BOOL (^)(id) — hand-written `P_B` → canonical `P_b` (Bool's one code is `b`).
        let sig = InboundSig::from_block(
            &[ty(TypeRefKind::Id {
                protocols: Vec::new(),
            })],
            &boolean(),
        )
        .unwrap();
        assert_eq!(sig.code_string(), "P_b");
        // A block param that is itself a block crosses as a raw handle → P.
        let inner = ty(TypeRefKind::Block {
            params: vec![],
            return_type: Box::new(TypeRef::void()),
        });
        let sig = InboundSig::from_block(&[inner], &TypeRef::void()).unwrap();
        assert_eq!(sig.code_string(), "P_v");
        // A struct / C-string anywhere in the block shape defers (None).
        assert_eq!(
            InboundSig::from_block(
                &[ty(TypeRefKind::Struct {
                    name: "CGRect".into()
                })],
                &TypeRef::void()
            ),
            None
        );
        assert_eq!(InboundSig::from_block(&[], &ty(TypeRefKind::CString)), None);
    }

    #[test]
    fn super_entry_names_ride_the_single_alphabet() {
        // `aw_ts_super_<code_string>` (+ `_o`/`_n`): the same code function that names
        // the IMP trampolines and keys the maker switches — no new alphabet (k63). The
        // hand-written pair's drifted `P_B` canonicalises to `P_b`.
        let sig = InboundSig {
            params: vec![InboundType::Ptr],
            ret: Some(InboundType::Bool),
        };
        assert_eq!(SuperEntry { sig, axis: None }.name(), "aw_ts_super_P_b");
        let sig = InboundSig {
            params: vec![],
            ret: None,
        };
        assert_eq!(SuperEntry { sig, axis: None }.name(), "aw_ts_super_0_v");
        // The non-folding owned sibling (ADR-0057 §4) — `$super.initWithName_(x)`.
        let sig = InboundSig {
            params: vec![InboundType::Ptr],
            ret: Some(InboundType::Ptr),
        };
        assert_eq!(
            SuperEntry {
                sig: sig.clone(),
                axis: Some(RetainAxis::Owned)
            }
            .name(),
            "aw_ts_super_P_P_o"
        );
        // The non-folding, non-wrapping non-object sibling (k70/k71) — a SEL/Class
        // return reached through `$super`.
        assert_eq!(
            SuperEntry {
                sig,
                axis: Some(RetainAxis::NoWrap)
            }
            .name(),
            "aw_ts_super_P_P_n"
        );
    }

    #[test]
    fn the_signature_code_function_is_the_imp_name_one() {
        // No second alphabet (the k62 mirror discipline): the IMP identifier is
        // literally the prefix + code_string, so block-maker switch keys, trampoline
        // names, and future emitted signature strings cannot drift apart.
        let sigs = [
            InboundSig {
                params: vec![],
                ret: None,
            },
            InboundSig {
                params: vec![InboundType::Ptr, InboundType::UInt64, InboundType::Ptr],
                ret: None,
            },
            InboundSig {
                params: vec![InboundType::Ptr],
                ret: Some(InboundType::Bool),
            },
            InboundSig {
                params: vec![InboundType::Double, InboundType::Float],
                ret: Some(InboundType::Int64),
            },
        ];
        for sig in sigs {
            assert_eq!(
                sig.imp_name(),
                format!("{INBOUND_IMP_PREFIX}{}", sig.code_string())
            );
        }
    }

    /// The fixture: one class + one protocol whose bindable shapes cover the five
    /// hand-written encodings plus scalar/double/deferred axes — each modelled on a real
    /// corpus method (named in place) — plus block-typed params across the class /
    /// class-method / category / protocol axes (the k62 block-maker frontier).
    fn fixture() -> Framework {
        let mut widget = class(
            "TKWidget",
            vec![
                // -compare: (id) -> NSInteger : q@:@ (the k37 battery shape).
                method(
                    "compare:",
                    false,
                    vec![param(TypeRefKind::Id {
                        protocols: Vec::new(),
                    })],
                    nsinteger(),
                ),
                // -integerValue () -> NSInteger : q@: .
                method("integerValue", false, vec![], nsinteger()),
                // -isEqual: (id) -> BOOL : c@:@ .
                method(
                    "isEqual:",
                    false,
                    vec![param(TypeRefKind::Id {
                        protocols: Vec::new(),
                    })],
                    boolean(),
                ),
                // -action () -> SEL : @@: at this alphabet (a SEL is a pointer-like) —
                // the -[NSControl action] shape. A non-object pointer return, so the
                // super entry rides the non-folding, non-wrapping `_n` axis (k70/k71).
                method("action", false, vec![], ty(TypeRefKind::Selector)),
                // -initWithName:count: (id, NSUInteger) -> instancetype : @@:@Q — an
                // overridable init, so the super table grows the non-folding owned
                // sibling (`$super.initWithName_count_(…)` takes the base's own +1 —
                // ADR-0057 §4). Two params keep `P_P` unique to the static factory.
                method(
                    "initWithName:count:",
                    false,
                    vec![
                        param(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                        param(TypeRefKind::Primitive {
                            name: "NSUInteger".into(),
                        }),
                    ],
                    ty(TypeRefKind::Instancetype),
                ),
                // -setName: (id) -> void : v@:@ .
                method(
                    "setName:",
                    false,
                    vec![param(TypeRefKind::Id {
                        protocols: Vec::new(),
                    })],
                    TypeRef::void(),
                ),
                // -objectsForKeys:notFoundMarker: (id, id) -> id : @@:@@ (the k38 shape).
                method(
                    "objectsForKeys:notFoundMarker:",
                    false,
                    vec![
                        param(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                        param(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                    ],
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                // + a static factory — statics are NOT installable instance IMPs.
                method(
                    "widgetWithName:",
                    true,
                    vec![param(TypeRefKind::Id {
                        protocols: Vec::new(),
                    })],
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                // -setFrame: (CGRect) -> void : outbound-bound, inbound-deferred.
                method(
                    "setFrame:",
                    false,
                    vec![param(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    })],
                    TypeRef::void(),
                ),
                // -writeToFile:error: — fallible; at the IMP ABI the NSError** cell is a
                // plain pointer arg, so the inbound sig is (id, ptr) -> BOOL : c@:@@ .
                method(
                    "writeToFile:error:",
                    false,
                    vec![
                        param(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                        param(TypeRefKind::Pointer),
                    ],
                    boolean(),
                ),
                // -enumerateObjectsUsingBlock: — block param void (^)(id, NSUInteger,
                // BOOL*). The METHOD is method_filter-deferred (no IMP entry, no IMP
                // deferral record); the BLOCK contributes maker signature PQP_v (the
                // future frontier — k62 module doc).
                method(
                    "enumerateObjectsUsingBlock:",
                    false,
                    vec![param(TypeRefKind::Block {
                        params: vec![
                            ty(TypeRefKind::Id {
                                protocols: Vec::new(),
                            }),
                            ty(TypeRefKind::Primitive {
                                name: "uint64".into(),
                            }),
                            ty(TypeRefKind::Pointer),
                        ],
                        return_type: Box::new(TypeRef::void()),
                    })],
                    TypeRef::void(),
                ),
                // + a CLASS method with a no-arg completion block — a static is no
                // instance IMP, but its block still needs a maker: 0_v.
                method(
                    "performWithCompletion:",
                    true,
                    vec![param(TypeRefKind::Block {
                        params: vec![],
                        return_type: Box::new(TypeRef::void()),
                    })],
                    TypeRef::void(),
                ),
                // -transformWithBlock: — a block whose param is a geometry struct falls
                // outside the inbound alphabet: deferred AND recorded, never silent.
                method(
                    "transformWithBlock:",
                    false,
                    vec![param(TypeRefKind::Block {
                        params: vec![ty(TypeRefKind::Struct {
                            name: "CGRect".into(),
                        })],
                        return_type: Box::new(TypeRef::void()),
                    })],
                    TypeRef::void(),
                ),
            ],
        );
        let proto = protocol(
            "TKWidgetDelegate",
            vec![
                // -numberOfRowsInWidget: (id) -> NSInteger : q@:@ (dedups with compare:).
                method(
                    "numberOfRowsInWidget:",
                    false,
                    vec![param(TypeRefKind::Id {
                        protocols: Vec::new(),
                    })],
                    nsinteger(),
                ),
            ],
            vec![
                // @optional -widget:heightOfRow: (id, NSInteger) -> double : d@:@q .
                method(
                    "widget:heightOfRow:",
                    false,
                    vec![
                        param(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                        param(nsinteger().kind),
                    ],
                    ty(TypeRefKind::Primitive {
                        name: "double".into(),
                    }),
                ),
                // @optional -widget:completion: — a PROTOCOL method's block param also
                // enters the maker set: void (^)(id) → P_v.
                method(
                    "widget:completion:",
                    false,
                    vec![
                        param(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                        param(TypeRefKind::Block {
                            params: vec![ty(TypeRefKind::Id {
                                protocols: Vec::new(),
                            })],
                            return_type: Box::new(TypeRef::void()),
                        }),
                    ],
                    TypeRef::void(),
                ),
            ],
        );
        // A CATEGORY method's block param enters the maker set too: BOOL (^)(id) → P_b.
        widget
            .category_methods
            .push(apianyware_types::ir::CategoryGroup {
                category: "TKWidgetExtensions".into(),
                origin_framework: "TestKit".into(),
                methods: vec![method(
                    "indexOfObjectPassingTest:",
                    false,
                    vec![param(TypeRefKind::Block {
                        params: vec![ty(TypeRefKind::Id {
                            protocols: Vec::new(),
                        })],
                        return_type: Box::new(boolean()),
                    })],
                    nsinteger(),
                )],
            });
        let mut fw = framework("TestKit", vec![widget], vec![proto]);
        fw.enrichment
            .get_or_insert_with(EnrichmentData::default)
            .convenience_error_methods
            .push(ClassSelectorEntry {
                class: "TKWidget".into(),
                selector: "writeToFile:error:".into(),
            });
        fw
    }

    #[test]
    fn collection_walks_class_and_protocol_frontiers() {
        let table = collect_inbound_table(&[fixture()]);
        let encodings: BTreeSet<String> = table.entries.iter().map(|s| s.type_encoding()).collect();
        assert_eq!(
            encodings,
            [
                "q@:@",                                // compare: + numberOfRowsInWidget: (deduplicated)
                "q@:",                                 // integerValue
                "c@:@",                                // isEqual:
                "@@:",   // action (a SEL return is a pointer-like at this alphabet)
                "@@:@Q", // initWithName:count: (an init IS an overridable instance IMP)
                "v@:@",  // setName:
                "@@:@@", // objectsForKeys:notFoundMarker:
                "c@:@@", // writeToFile:error: (full params — the error cell is a Ptr)
                "d@:@q", // widget:heightOfRow: (@optional protocol method)
                "v@:{CGRect={CGPoint=dd}{CGSize=dd}}", // setFrame: (inbound-struct-arg-surface-k123: now admitted, param-only)
            ]
            .into_iter()
            .map(String::from)
            .collect()
        );
        // The five hand-written encodings all arise from the corpus-modelled shapes —
        // the battery's overrides install from the generated map.
        for enc in ["q@:@", "q@:", "@@:@@", "v@:@", "c@:@"] {
            assert!(encodings.contains(enc), "missing hand-written {enc}");
        }
        // Nothing is deferred at the IMP frontier any more (`inbound-struct-arg-surface-k123`
        // widened struct PARAMS in); the static factory contributed nothing either way.
        assert_eq!(table.deferred.len(), 0);
        assert!(!table
            .entries
            .iter()
            .any(|s| s.imp_name() == "aw_ts_inb_P_P"));
    }

    #[test]
    fn super_collection_shares_the_imp_frontier_with_the_retain_axis() {
        // The super frontier IS the IMP frontier (a `$super` send happens only inside a
        // JS override, which installs only for IMP-alphabet signatures) — the walk,
        // alphabet, and deferral records are shared; the super set differs only by the
        // retain-axis fan-out (ADR-0057 §4, the shared `method_retain_axis` predicate).
        let table = collect_inbound_table(&[fixture()]);
        let names: BTreeSet<String> = table.super_entries.iter().map(|e| e.name()).collect();
        assert_eq!(
            names,
            [
                "aw_ts_super_P_q",    // compare: + numberOfRowsInWidget: (deduplicated)
                "aw_ts_super_0_q",    // integerValue
                "aw_ts_super_P_b",    // isEqual: (the canonicalised hand-written P_B)
                "aw_ts_super_0_P_n",  // action — SEL return: no fold, no wrap (k71)
                "aw_ts_super_PQ_P_o", // initWithName:count: — +1 return, NO fold
                "aw_ts_super_P_v",    // setName:
                "aw_ts_super_PP_P",   // objectsForKeys:notFoundMarker: — +0, folds
                "aw_ts_super_PP_b",   // writeToFile:error:
                "aw_ts_super_Pq_d",   // widget:heightOfRow: (@optional protocol method)
                "aw_ts_super_R_v", // setFrame: (inbound-struct-arg-surface-k123): void return, no axis
            ]
            .into_iter()
            .map(String::from)
            .collect()
        );
        // The frontier is shared by construction: projecting the super entries onto
        // their signatures reproduces the IMP entry set exactly (the super set differs
        // only by the retain-axis fan-out, which this fixture never splits — no two
        // methods share a signature across conventions).
        let projected: BTreeSet<InboundSig> =
            table.super_entries.iter().map(|e| e.sig.clone()).collect();
        assert_eq!(projected, table.entries);
        // The axis is the same `method_retain_axis` value the outbound table and the
        // call sites read: an init's +1 return does NOT fold; a plain object return
        // does; a SEL return is no object — never folded, never wrapped.
        assert!(table
            .super_entries
            .iter()
            .any(|e| e.axis == Some(RetainAxis::Owned) && e.name() == "aw_ts_super_PQ_P_o"));
        assert!(table
            .super_entries
            .iter()
            .any(|e| e.axis == Some(RetainAxis::FoldRetain) && e.name() == "aw_ts_super_PP_P"));
        assert!(table
            .super_entries
            .iter()
            .any(|e| e.axis == Some(RetainAxis::NoWrap) && e.name() == "aw_ts_super_0_P_n"));
        // setFrame: (the struct-param method) now contributes its own super entry too —
        // shared with the IMP table by construction (no super-specific deferral vec).
        assert!(names.iter().any(|n| n == "aw_ts_super_R_v"));
    }

    #[test]
    fn super_entry_renders_the_load_bearing_lines() {
        // (id, Class, SEL, id) -> Bool — the generated replacement for the hand-written
        // aw_ts_super_P_B (canonicalised P_b): napi args (recv, superCls, sel, arg), the
        // objc_super pair by address, the per-signature objc_msgSendSuper recast.
        let sig = InboundSig {
            params: vec![InboundType::Ptr],
            ret: Some(InboundType::Bool),
        };
        let mut s = String::new();
        emit_super_entry(&mut s, &sig, None);
        assert!(
            s.contains(
                "private func aw_ts_super_P_b(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {"
            ),
            "{s}"
        );
        assert!(s.contains("let a = napiCallbackArgs(env, info, 4)"), "{s}");
        assert!(
            s.contains(
                "var sup: (receiver: UInt, superClass: UInt) = (napiReadHandle(env, a[0]), napiReadHandle(env, a[1]))"
            ),
            "{s}"
        );
        assert!(
            s.contains(
                "typealias Fn = @convention(c) (UnsafeMutableRawPointer, UInt, UInt) -> Bool"
            ),
            "{s}"
        );
        assert!(
            s.contains(
                "unsafeBitCast(awMsgSendSuperAddr, to: Fn.self)(UnsafeMutableRawPointer($0), napiReadHandle(env, a[2]), napiReadHandle(env, a[3]))"
            ),
            "{s}"
        );
        assert!(s.contains("return napiMakeBool(env, r)"), "{s}");

        // () -> void — the $super.dealloc() shape: statement call, undefined return.
        let sig = InboundSig {
            params: vec![],
            ret: None,
        };
        let mut s = String::new();
        emit_super_entry(&mut s, &sig, None);
        assert!(s.contains("aw_ts_super_0_v"), "{s}");
        assert!(s.contains("let a = napiCallbackArgs(env, info, 3)"), "{s}");
        assert!(s.contains("return napiUndefined(env)"), "{s}");
        assert!(!s.contains("let r ="), "{s}");
    }

    #[test]
    fn owned_super_sibling_skips_the_fold_plain_folds() {
        // The outbound fold discipline carried over (ADR-0057 §4): a +0 object return
        // folds objcRetain in the entry (the JS wrapper's uniform +1); the `_o` sibling
        // takes the method's own +1 and must NOT fold.
        let sig = InboundSig {
            params: vec![],
            ret: Some(InboundType::Ptr),
        };
        let mut plain = String::new();
        emit_super_entry(&mut plain, &sig, Some(RetainAxis::FoldRetain));
        assert!(
            plain.contains("return napiMakeHandle(env, objcRetain(r))"),
            "{plain}"
        );
        let mut owned = String::new();
        emit_super_entry(&mut owned, &sig, Some(RetainAxis::Owned));
        assert!(owned.contains("func aw_ts_super_0_P_o("), "{owned}");
        assert!(owned.contains("return napiMakeHandle(env, r)"), "{owned}");
        assert!(!owned.contains("objcRetain"), "{owned}");
    }

    #[test]
    fn no_wrap_super_sibling_neither_folds_nor_shares_the_folding_name() {
        // The k70 defect's super copy, cured (k71): a pointer return that is NO object
        // (`SEL` — `$super.action()`; the `Class` metatype) must not fold objcRetain
        // (retaining a Class leaks; objc_retain on a SEL is UB) and must not share the
        // folding bare name — it routes to the `_n` sibling, ADR-0057 §4.
        let sig = InboundSig {
            params: vec![],
            ret: Some(InboundType::Ptr),
        };
        let mut s = String::new();
        emit_super_entry(&mut s, &sig, Some(RetainAxis::NoWrap));
        assert!(s.contains("func aw_ts_super_0_P_n("), "{s}");
        assert!(s.contains("return napiMakeHandle(env, r)"), "{s}");
        assert!(!s.contains("objcRetain"), "{s}");
        assert!(
            s.contains("non-object pointer return (`SEL`/`Class`): never wrapped, NO fold"),
            "{s}"
        );
    }

    #[test]
    fn generated_file_registers_every_super_entry() {
        // The k58 mirror invariant, registration form: every collected super entry has
        // exactly its one napiDefine line in awRegisterGeneratedSuperSends (and its
        // definition), keyed by the shared code function — counts match, no extras.
        let table = collect_inbound_table(&[fixture()]);
        assert!(!table.super_entries.is_empty());
        let out = generate_inbound_swift(&table);
        assert!(
            out.contains(
                "func awRegisterGeneratedSuperSends(_ env: napi_env?, _ exports: napi_value?) {"
            ),
            "{out}"
        );
        for entry in &table.super_entries {
            let name = entry.name();
            assert!(
                out.contains(&format!("napiDefine(env, exports, \"{name}\", {name})")),
                "missing registration for {name}"
            );
            assert!(
                out.contains(&format!(
                    "private func {name}(_ env: napi_env?, _ info: napi_callback_info?)"
                )),
                "missing definition for {name}"
            );
        }
        let body = out
            .split("func awRegisterGeneratedSuperSends(_ env: napi_env?, _ exports: napi_value?) {")
            .nth(1)
            .and_then(|rest| rest.split("\n}\n").next())
            .expect("missing awRegisterGeneratedSuperSends");
        assert_eq!(
            body.matches("napiDefine(").count(),
            table.super_entries.len(),
            "registration count mismatch"
        );
    }

    #[test]
    fn block_collection_walks_the_future_frontier() {
        // Block-carrying methods are method_filter-deferred (no IMP entry, no emitted
        // call site yet), so the maker collection walks ALL class (incl. class-method +
        // category) + protocol methods' block params — the frontier the block emitter
        // will admit later. Over-collection is a dead switch case; under-collection a
        // future missing maker (k62 module doc).
        let table = collect_inbound_table(&[fixture()]);
        let codes: BTreeSet<String> = table
            .block_entries
            .iter()
            .map(|s| s.code_string())
            .collect();
        assert_eq!(
            codes,
            [
                "PQP_v", // enumerateObjectsUsingBlock: (instance) — the canonicalised PQb_v
                "0_v",   // +performWithCompletion: (class method's block still gets a maker)
                "P_b",   // indexOfObjectPassingTest: (category) — the canonicalised P_B
                "P_v",   // widget:completion: (@optional protocol method)
            ]
            .into_iter()
            .map(String::from)
            .collect()
        );
        // No block-carrying method leaked into the IMP frontier…
        assert!(!table
            .deferred
            .iter()
            .any(|d| d.selector.contains("Block") || d.selector.contains("completion")));
        // …and the struct-carrying block was deferred AND recorded (never silent).
        assert_eq!(table.deferred_blocks.len(), 1);
        assert_eq!(table.deferred_blocks[0].selector, "transformWithBlock:");
        assert_eq!(table.deferred_blocks[0].owner, "TKWidget");
    }

    #[test]
    fn block_maker_pair_renders_the_load_bearing_lines() {
        // void (^)(id, NSUInteger, BOOL*) — the enumerate shape (PQP_v): typed
        // @convention(block) closure, raw BounceArg gather, noescape captures the bare
        // cbid, escaping captures the holder (strong) and reads holder.cbid.
        let sig = InboundSig {
            params: vec![InboundType::Ptr, InboundType::UInt64, InboundType::Ptr],
            ret: None,
        };
        let mut s = String::new();
        emit_block_maker_pair(&mut s, &sig);
        assert!(
            s.contains("private func awMakeBlock_PQP_v(_ cbid: UInt) -> UInt {"),
            "{s}"
        );
        assert!(
            s.contains(
                "let closure: @convention(block) (UInt, UInt64, UInt) -> Void = { a0, a1, a2 in"
            ),
            "{s}"
        );
        assert!(
            s.contains("deliverBlockVoid(cbid, [.handle(a0), .uint64(a1), .handle(a2)])"),
            "{s}"
        );
        assert!(
            s.contains(
                "private func awMakeEscapingBlock_PQP_v(_ holder: EscapingBlockHolder) -> UInt {"
            ),
            "{s}"
        );
        assert!(s.contains("{ [holder] a0, a1, a2 in"), "{s}");
        assert!(
            s.contains("deliverBlockVoid(holder.cbid, [.handle(a0), .uint64(a1), .handle(a2)])"),
            "{s}"
        );
        assert!(s.contains("_Block_copy"), "{s}");

        // BOOL (^)(id) — the value-returning shape (P_b): the delivery slot
        // reinterprets to the C-ABI Bool return.
        let sig = InboundSig {
            params: vec![InboundType::Ptr],
            ret: Some(InboundType::Bool),
        };
        let mut s = String::new();
        emit_block_maker_pair(&mut s, &sig);
        assert!(s.contains("(UInt) -> Bool = { a0 in"), "{s}");
        assert!(
            s.contains("deliverBlockValue(cbid, [.handle(a0)], .bool) != 0"),
            "{s}"
        );
        assert!(
            s.contains("deliverBlockValue(holder.cbid, [.handle(a0)], .bool) != 0"),
            "{s}"
        );

        // void (^)(void) — the zero-param spellings: a capture list still needs `in`.
        let sig = InboundSig {
            params: vec![],
            ret: None,
        };
        let mut s = String::new();
        emit_block_maker_pair(&mut s, &sig);
        assert!(s.contains("awMakeBlock_0_v"), "{s}");
        assert!(s.contains("deliverBlockVoid(cbid, [])"), "{s}");
        assert!(s.contains("{ [holder] in"), "{s}");
    }

    #[test]
    fn generated_file_switches_every_block_signature() {
        // The k62 mirror invariant, switch form: every collected block signature has
        // exactly its one case line in BOTH maker switches, keyed by code_string —
        // the same function that names the IMP trampolines (no second alphabet).
        let table = collect_inbound_table(&[fixture()]);
        assert!(!table.block_entries.is_empty());
        let out = generate_inbound_swift(&table);
        for sig in &table.block_entries {
            let code = sig.code_string();
            assert!(
                out.contains(&format!("case \"{code}\": return awMakeBlock_{code}(cbid)")),
                "missing noescape case for {code}"
            );
            assert!(
                out.contains(&format!(
                    "case \"{code}\": return awMakeEscapingBlock_{code}(EscapingBlockHolder(cbid))"
                )),
                "missing escaping case for {code}"
            );
        }
        // …and no extra cases: each switch has exactly entries + 1 (default) case lines.
        for switch_fn in ["awGeneratedMakeBlock", "awGeneratedMakeEscapingBlock"] {
            let body = out
                .split(&format!(
                    "func {switch_fn}(_ cbid: UInt, _ signature: String) -> UInt {{"
                ))
                .nth(1)
                .and_then(|rest| rest.split("\n}\n").next())
                .unwrap_or_else(|| panic!("missing {switch_fn}"));
            let cases = body.matches("case ").count();
            assert_eq!(
                cases,
                table.block_entries.len(),
                "{switch_fn} case-count mismatch"
            );
        }
    }

    #[test]
    fn value_trampoline_renders_the_load_bearing_lines() {
        // (id) -> NSInteger — the generated replacement for the hand-written
        // trampoline_q_at: typed closure, raw BounceArg gather, slot reinterpret.
        let sig = InboundSig {
            params: vec![InboundType::Ptr],
            ret: Some(InboundType::Int64),
        };
        let mut s = String::new();
        emit_trampoline(&mut s, &sig);
        assert!(
            s.contains(
                "private let aw_ts_inb_P_q: @convention(c) (UInt, UInt, UInt) -> Int64 = { selfId, cmd, a0 in"
            ),
            "{s}"
        );
        assert!(
            s.contains("let slot = deliverInboundValue(selfId, cmd, [.handle(a0)], .int64)"),
            "{s}"
        );
        assert!(s.contains("return Int64(bitPattern: slot)"), "{s}");
        assert!(s.contains("encoding `q@:@`"), "{s}");
    }

    #[test]
    fn void_scalar_and_double_trampolines_render() {
        // (id) -> void — fire-and-forget through the void core.
        let sig = InboundSig {
            params: vec![InboundType::Ptr],
            ret: None,
        };
        let mut s = String::new();
        emit_trampoline(&mut s, &sig);
        assert!(
            s.contains(
                "private let aw_ts_inb_P_v: @convention(c) (UInt, UInt, UInt) -> Void = { selfId, cmd, a0 in"
            ),
            "{s}"
        );
        assert!(
            s.contains("deliverInboundVoid(selfId, cmd, [.handle(a0)])"),
            "{s}"
        );
        assert!(!s.contains("deliverInboundValue"), "{s}");

        // (id, NSInteger) -> double — scalar arg widening + double slot reinterpret.
        let sig = InboundSig {
            params: vec![InboundType::Ptr, InboundType::Int64],
            ret: Some(InboundType::Double),
        };
        let mut s = String::new();
        emit_trampoline(&mut s, &sig);
        assert!(
            s.contains(
                "private let aw_ts_inb_Pq_d: @convention(c) (UInt, UInt, UInt, Int64) -> Double = { selfId, cmd, a0, a1 in"
            ),
            "{s}"
        );
        assert!(
            s.contains("deliverInboundValue(selfId, cmd, [.handle(a0), .int64(a1)], .double)"),
            "{s}"
        );
        assert!(s.contains("return Double(bitPattern: slot)"), "{s}");

        // (BOOL, unsigned) -> BOOL — the bool arg + uint64 arg + bool return kinds.
        let sig = InboundSig {
            params: vec![InboundType::Bool, InboundType::UInt32],
            ret: Some(InboundType::Bool),
        };
        let mut s = String::new();
        emit_trampoline(&mut s, &sig);
        assert!(s.contains("[.bool(a0), .uint64(UInt64(a1))], .bool"), "{s}");
        assert!(s.contains("return slot != 0"), "{s}");
    }

    #[test]
    fn generated_file_maps_every_entry_and_reports_counts() {
        let table = collect_inbound_table(&[fixture()]);
        let out = generate_inbound_swift(&table);
        assert!(out.contains("import AppKit"), "{out}");
        assert!(out.contains("import Foundation"), "{out}");
        assert!(
            out.contains("func awGeneratedInboundIMP(forEncoding encoding: String) -> IMP? {"),
            "{out}"
        );
        // The mirror invariant, switch form: every collected signature has exactly its
        // one case line, keyed by its encoding, returning its trampoline.
        for sig in &table.entries {
            assert!(
                out.contains(&format!(
                    "case \"{}\": return unsafeBitCast({}, to: IMP.self)",
                    sig.type_encoding(),
                    sig.imp_name()
                )),
                "missing case for {}",
                sig.type_encoding()
            );
        }
        assert!(out.contains("default: return nil"), "{out}");
        assert!(
            out.contains("// 10 generated inbound trampolines (0 frontier methods deferred: struct/C-string shapes)."),
            "{out}"
        );
        assert!(
            out.contains("// 4 generated block-maker pairs (1 block param deferred: struct/C-string shapes)."),
            "{out}"
        );
        // One super entry per IMP signature, `initWithName:count:` the sole `_o`,
        // `action`'s SEL return the sole `_n` (k71); setFrame: (struct param, void
        // return, inbound-struct-arg-surface-k123) is a new plain entry.
        assert!(
            out.contains("// 10 generated super-send entries: 8 plain (+0, folds), 1 owned (`_o`, no fold), 1 non-object (`_n`, no fold, no wrap)."),
            "{out}"
        );
    }
}
