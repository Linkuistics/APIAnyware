//! Throwaway proof harness for ADR-0021 (leaf 055/020): emit a `functions.ss`
//! for a handful of REAL Foundation functions using the converted
//! `generate_functions_file`, so the output can be compiled+linked under the
//! bottle's default gcc-15 (no clang, no `-x objective-c`). Covers the three
//! shapes the conversion must handle: an object-returning function
//! (`NSHomeDirectory` → `id`), an NS-geometry-struct **argument** by value
//! (`NSStringFromRange(NSRange)`), and an NS-geometry-struct **return** by value
//! (`NSRangeFromString` → `NSRange`) — the last two driving the inline plain-C
//! `struct _NSRange` decl (never the non-C-safe `<Foundation/NSRange.h>`). Run:
//!   cargo run -p apianyware-emit-gerbil --example dump_foundation_functions
//! then build the printed module with gxc against -framework Foundation.

use apianyware_emit_gerbil::emit_functions::generate_functions_file;
use apianyware_types::ir::{Function, Param};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

fn ty(kind: TypeRefKind) -> TypeRef {
    TypeRef {
        nullable: false,
        kind,
    }
}

fn func(name: &str, params: Vec<Param>, ret: TypeRefKind) -> Function {
    Function {
        name: name.into(),
        params,
        return_type: ty(ret),
        inline: false,
        variadic: false,
        source: None,
        provenance: None,
        doc_refs: None,
        objc_exposed: true,
        swift_fn: None,
    }
}

fn param(name: &str, kind: TypeRefKind) -> Param {
    Param {
        name: name.into(),
        param_type: ty(kind),
    }
}

fn main() {
    // Real exported Foundation functions (FOUNDATION_EXPORT, non-inline):
    let fs = vec![
        // id NSHomeDirectory(void) — object return, raw (pointer void).
        func(
            "NSHomeDirectory",
            vec![],
            TypeRefKind::Id {
                protocols: Vec::new(),
            },
        ),
        // NSString *NSStringFromRange(NSRange) — NS-geometry struct by-value ARG.
        func(
            "NSStringFromRange",
            vec![param(
                "range",
                TypeRefKind::Struct {
                    name: "NSRange".into(),
                },
            )],
            TypeRefKind::Id {
                protocols: Vec::new(),
            },
        ),
        // NSRange NSRangeFromString(NSString *) — NS-geometry struct by-value RETURN.
        func(
            "NSRangeFromString",
            vec![param(
                "s",
                TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            )],
            TypeRefKind::Struct {
                name: "NSRange".into(),
            },
        ),
    ];
    print!("{}", generate_functions_file(&fs, "Foundation", &[]));
}
