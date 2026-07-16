//! TypeScript code generation — the Node TypeScript target's emitter crate.
//!
//! The fifth APIAnyware target (after `racket`, `chez`, `gerbil`, `sbcl`), and the
//! **first non-Lisp and first statically-typed** one. TypeScript projects the macOS
//! ObjC API into **real ES6 classes** mirroring the ObjC graph (`class NSString
//! extends NSObject`), each instance a **branded, disposable native handle**, with
//! the **`.d.ts` type surface co-generated from the same IR pass** — a first-class
//! deliverable no prior target has (ADR-0055). Method bodies are coercion-free calls
//! into an N-API generated-dispatch addon, trampoline-elided (ADR-0054).
//!
//! Pure codegen: no Swift, no Node, no native linkage — the hermetic ADR-0011 seam
//! lets the crate build and golden-test with no native core present. The runtime the
//! emitted modules call (Step 3) and the N-API addon (Step 4) are sibling build
//! leaves; this crate stops at emitted source.
//!
//! ## Module layout (grown per child leaf of the `emit-typescript` node)
//!
//! - `naming` / `ffi_type_mapping` / `method_filter` / `emit_framework` skeleton
//!   (`scaffold-and-foundations`).
//! - `native_dispatch` (the dispatch-shape mapper) + `emit_class` (the ES6 `.ts` class
//!   bodies) — `es6-class-body`.
//! - `class_surface` (the shared method set + signature rendering) + `emit_dts` (the
//!   co-generated `.d.ts` type surface) — `dts-surface`.
//! - `class_graph` (parent resolution, superclass-before-subclass load order, the
//!   class→module resolver) + `imports` (per-module import grouping) + the
//!   `emit_framework` orchestrator that threads the resolver through both emitters —
//!   `class-graph-and-orchestration`.
//! - `emit_enums` — `NS_ENUM`/`NS_OPTIONS` → real TS `enum` (co-generated `enums.ts` +
//!   `enums.d.ts`, barrel-re-exported). `enum_graph` (the cross-framework enum ownership
//!   registry + enum→module resolver) makes the [`ffi_type_mapping`] mapper enum-aware so a
//!   genuine enum alias in a signature renders as the enum type name, imported (type-only)
//!   from its owning `enums.ts` — `enum-alias-typing`.
//! - `emit_protocol` — protocols → `interface`s. `protocol_graph` (the cross-framework
//!   protocol ownership registry + protocol→module resolver, the third of the
//!   class/enum/protocol registry family) drives the class `implements` clause and
//!   cross-framework protocol `extends`, each interface imported type-only —
//!   `implements-and-param-typing`.
//! - `emit_constants` — each `Constant` → an exported module-load-initialized `const`
//!   (CFSTR macro built from its literal, pointer-valued global read + wrapped borrowed,
//!   scalar/enum global read; ADR-0055 §6). `emit_functions` — each `objc_exposed`
//!   `Function` → an exported free function dispatching through the addon's per-symbol
//!   entry (the free-function dual of `emit_class`'s method bodies, ADR-0054) —
//!   `constants-and-functions`. Both co-generate `.ts` + `.d.ts` and barrel-re-export.
//! - `dispatch_table` — the **generated outbound dispatch table** (the racket ADR-0013
//!   shape at corpus scale): `collect_global_entries` walks the same `bound_methods`
//!   frontier the class emitters walk (the mirror invariant), `generate_dispatch_swift`
//!   renders one napi callback per distinct ABI signature (+ `_o`/`_e` siblings) into the
//!   addon's `Generated/DispatchTable.swift`, wired as a generate-CLI global pass —
//!   `outbound-dispatch-table` (k58).
//! - `function_table` — the **generated plain-C free-function table** (ADR-0054 §1a):
//!   `collect_function_entries` walks the same `objc_exposed` admission predicate
//!   `emit_functions` does, `generate_function_table_swift` renders 2192 per-symbol
//!   `aw_ts_fn_<symbol>` exports over 317 shared per-signature bodies (joined by
//!   `napi_create_function`'s `data` descriptor) into `Generated/FunctionTable.swift` —
//!   `fn-table-codegen` (k69). `swift_abi` (private) is the Swift-side rendering vocabulary
//!   `dispatch_table` and `function_table` share, so a shape cannot mean two things.
//! - `inbound_table` — the **generated inbound IMP trampoline table** (ADR-0059 §1, the
//!   inbound dual of `dispatch_table`): `collect_inbound_table` walks the `bound_methods`
//!   instance frontier + `emit_protocol`'s interface frontier, `generate_inbound_swift`
//!   renders one typed `@convention(c)` trampoline per distinct inbound signature + the
//!   encoding-keyed `awGeneratedInboundIMP` map into `Generated/InboundTable.swift` —
//!   `inbound-imp-table` (k61).
//! - the **`NSError**` → `Result<T>` channel** for fallible **methods** — `error-model`
//!   (ADR-0058). A fallible `…error:` selector (detected by the enrichment
//!   [`class_error_selectors`](apianyware_emit::enrichment::class_error_selectors) set +
//!   a trailing raw `Pointer`, the cross-target signal) drops its `NSError**` cell from the
//!   JS args, dispatches through a distinct `…_e` entry ([`native_dispatch`]), and returns
//!   `Result<T>` — the object primary through `__resultRetained`/`__resultOwned`, a scalar
//!   through `__resultScalar`; `Result` imports type-only from the runtime seam and the
//!   framework barrel re-exports the runtime error hierarchy (`unwrap`/`ObjCError`/…). The
//!   native `@catch` + primary-return keying is the Step-4 addon's; the emitter emits the
//!   call site + the `Result<T>` surface only. (`NSException`→throw and the Swift-`throws`
//!   bridge are native/runtime + trampoline concerns — Steps 3/4.)

//! - `delegate_spec` — the **emitted per-protocol `DelegateSpec`** (`delegates.ts`, ADR-0059 §3/§8):
//!   what turns a plain JS object literal reaching *any* bound `id<P>` slot (ADR-0055 §4b) into a real
//!   ObjC forwarder. One spec per emitted protocol (the forwarder-class memo key, the installable
//!   methods keyed by `InboundSig`'s encoding, the inbound value surface); the *slot* facts — the
//!   association key and the associate/skip arm off k82's resolved ownership — ride the call site,
//!   which is what lets one spec serve every slot its protocol types — `emitted-delegate-spec` (k84).

pub mod class_binding;
pub mod class_graph;
pub mod class_surface;
pub mod delegate_spec;
pub mod dispatch_table;
pub mod emit_class;
pub mod emit_constants;
pub mod emit_dts;
pub mod emit_enums;
pub mod emit_framework;
pub mod emit_functions;
pub mod emit_protocol;
pub mod enum_graph;
pub mod ffi_type_mapping;
pub mod function_table;
pub mod imports;
pub mod inbound_table;
pub mod method_filter;
pub mod naming;
pub mod native_dispatch;
pub mod override_widening;
pub mod protocol_binding;
pub mod protocol_graph;
pub mod ptr_value;
pub mod subclass_surface;
mod swift_abi;
pub mod trampoline;

pub use class_binding::{class_binding, deferred_class, surface_class_name, ClassBinding};
pub use class_graph::{
    build_class_graph, ordered_classes, ClassGraph, ClassModuleResolver, ClassRegistry, ParentRef,
    RUNTIME_MODULE, RUNTIME_ROOT,
};
pub use delegate_spec::{
    render_delegates_dts, render_delegates_module, slot_report, BoundSlot, SlotReport,
};
pub use dispatch_table::{collect_global_entries, generate_dispatch_swift, DispatchTable};
pub use emit_class::render_class;
pub use emit_constants::{render_constants_dts, render_constants_module};
pub use emit_dts::render_dts;
pub use emit_enums::{render_enums_dts, render_enums_module};
pub use emit_framework::{TsEmitter, TS_TARGET_INFO};
pub use emit_functions::{render_functions_dts, render_functions_module};
pub use emit_protocol::{render_protocols_dts, render_protocols_module};
pub use enum_graph::{EnumModuleResolver, EnumRegistry};
pub use ffi_type_mapping::TsFfiTypeMapper;
pub use function_table::{collect_function_entries, generate_function_table_swift, FunctionTable};
pub use inbound_table::{collect_inbound_table, generate_inbound_swift, InboundSig, InboundTable};
pub use native_dispatch::{AbiType, NativeSig};
pub use protocol_binding::{
    degradation_report, id_surface_type, protocol_binding, protocol_type_name, renamed_protocols,
    DegradationReport, ProtocolBinding,
};
pub use protocol_graph::{ProtocolModuleResolver, ProtocolRegistry};
