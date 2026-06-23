//! Load collected IR frameworks into the resolution Datalog program.
//!
//! Iterates over a [`Framework`]'s declarations and pushes tuples
//! into the [`ResolutionProgram`]'s base relations.

use apianyware_types::Framework;

use crate::program::ResolutionProgram;

/// Populate base relations from a deserialized IR [`Framework`].
///
/// Can be called multiple times for different frameworks (e.g., Foundation + AppKit)
/// before running the program to resolve cross-framework inheritance.
pub fn load_framework_facts(prog: &mut ResolutionProgram, framework: &Framework) {
    let framework_name = &framework.name;

    for class in &framework.classes {
        prog.class_decl.push((
            class.name.clone(),
            class.superclass.clone(),
            framework_name.clone(),
        ));

        if !class.superclass.is_empty() {
            prog.inherits_from
                .push((class.name.clone(), class.superclass.clone()));
        }

        for protocol in &class.protocols {
            prog.conforms_to
                .push((class.name.clone(), protocol.clone()));
        }

        for method in &class.methods {
            prog.method_decl.push((
                class.name.clone(),
                method.selector.clone(),
                method.class_method,
                method.init_method,
                method.deprecated,
                method.variadic,
            ));
        }

        for prop in &class.properties {
            prog.property_decl.push((
                class.name.clone(),
                prop.name.clone(),
                prop.readonly,
                prop.class_property,
                prop.deprecated,
            ));
        }
    }

    for proto in &framework.protocols {
        prog.protocol_decl.push((proto.name.clone(),));

        for parent in &proto.inherits {
            prog.protocol_inherits
                .push((proto.name.clone(), parent.clone()));
        }

        for method in &proto.required_methods {
            prog.protocol_method.push((
                proto.name.clone(),
                method.selector.clone(),
                true,
                method.class_method,
                method.init_method,
                method.deprecated,
                method.variadic,
            ));
        }

        for method in &proto.optional_methods {
            prog.protocol_method.push((
                proto.name.clone(),
                method.selector.clone(),
                false,
                method.class_method,
                method.init_method,
                method.deprecated,
                method.variadic,
            ));
        }

        for prop in &proto.properties {
            prog.protocol_property
                .push((proto.name.clone(), prop.name.clone(), true));
        }
    }

    for enumeration in &framework.enums {
        prog.enum_decl.push((enumeration.name.clone(),));

        for value in &enumeration.values {
            prog.enum_value_decl
                .push((enumeration.name.clone(), value.name.clone(), value.value));
        }
    }

    for structure in &framework.structs {
        prog.struct_decl.push((structure.name.clone(),));

        for (i, field) in structure.fields.iter().enumerate() {
            prog.struct_field_decl
                .push((structure.name.clone(), field.name.clone(), i as u32));
        }
    }

    for function in &framework.functions {
        prog.function_decl.push((function.name.clone(),));
    }

    for constant in &framework.constants {
        prog.constant_decl.push((constant.name.clone(),));
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::program::ResolutionProgram;
    use apianyware_datalog::loading;
    use std::path::PathBuf;

    fn collected_ir_directory() -> PathBuf {
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("..")
            .join("..")
            .join("collection")
            .join("ir")
            .join("collected")
    }

    fn load_foundation() -> Option<Framework> {
        let path = collected_ir_directory().join("Foundation.json");
        if !path.exists() {
            return None;
        }
        Some(loading::load_framework_from_file(&path).unwrap())
    }

    #[test]
    fn class_count_matches_ir() {
        let Some(fw) = load_foundation() else {
            eprintln!("skipping: no Foundation.json");
            return;
        };
        let mut prog = ResolutionProgram::default();
        load_framework_facts(&mut prog, &fw);
        assert_eq!(prog.class_decl.len(), fw.classes.len());
    }

    #[test]
    fn method_count_matches_ir() {
        let Some(fw) = load_foundation() else {
            eprintln!("skipping: no Foundation.json");
            return;
        };
        let expected: usize = fw.classes.iter().map(|c| c.methods.len()).sum();
        let mut prog = ResolutionProgram::default();
        load_framework_facts(&mut prog, &fw);
        assert_eq!(prog.method_decl.len(), expected);
    }

    #[test]
    fn property_count_matches_ir() {
        let Some(fw) = load_foundation() else {
            eprintln!("skipping: no Foundation.json");
            return;
        };
        let expected: usize = fw.classes.iter().map(|c| c.properties.len()).sum();
        let mut prog = ResolutionProgram::default();
        load_framework_facts(&mut prog, &fw);
        assert_eq!(prog.property_decl.len(), expected);
    }

    #[test]
    fn protocol_count_matches_ir() {
        let Some(fw) = load_foundation() else {
            eprintln!("skipping: no Foundation.json");
            return;
        };
        let mut prog = ResolutionProgram::default();
        load_framework_facts(&mut prog, &fw);
        assert_eq!(prog.protocol_decl.len(), fw.protocols.len());
    }

    #[test]
    fn nsstring_inherits_from_nsobject() {
        let Some(fw) = load_foundation() else {
            eprintln!("skipping: no Foundation.json");
            return;
        };
        let mut prog = ResolutionProgram::default();
        load_framework_facts(&mut prog, &fw);
        let has = prog
            .inherits_from
            .iter()
            .any(|(child, parent)| child == "NSString" && parent == "NSObject");
        assert!(has, "expected NSString inherits_from NSObject");
    }

    #[test]
    fn class_decl_includes_framework_name() {
        let Some(fw) = load_foundation() else {
            eprintln!("skipping: no Foundation.json");
            return;
        };
        let mut prog = ResolutionProgram::default();
        load_framework_facts(&mut prog, &fw);
        let all_foundation = prog.class_decl.iter().all(|(_, _, fw)| fw == "Foundation");
        assert!(
            all_foundation,
            "all class_decl should have framework=Foundation"
        );
    }
}
