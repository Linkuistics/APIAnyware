//! Throwaway proof harness for ADR-0021 (leaf 055/010): emit a `constants.ss`
//! for a handful of REAL Foundation global symbols using the converted
//! `generate_constants_file`, so the output can be compiled+linked under the
//! bottle's default gcc-15 (no clang, no `-x objective-c`). Run:
//!   cargo run -p apianyware-macos-emit-gerbil --example dump_foundation_constants
//! then build the printed module with gxc against -framework Foundation.

use apianyware_macos_emit_gerbil::emit_constants::generate_constants_file;
use apianyware_macos_types::ir::Constant;
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

fn obj(name: &str) -> Constant {
    Constant {
        name: name.into(),
        constant_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        },
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: None,
        objc_exposed: true,
    }
}

fn scalar(name: &str, prim: &str) -> Constant {
    Constant {
        name: name.into(),
        constant_type: TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive { name: prim.into() },
        },
        source: None,
        provenance: None,
        doc_refs: None,
        macro_value: None,
        objc_exposed: true,
    }
}

fn main() {
    // Real Foundation exports: object globals (NSString * const) + a scalar double.
    let consts = vec![
        obj("NSCocoaErrorDomain"),
        obj("NSURLFileScheme"),
        scalar("NSFoundationVersionNumber", "double"),
    ];
    print!("{}", generate_constants_file(&consts, "Foundation"));
}
