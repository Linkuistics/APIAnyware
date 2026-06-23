//! ObjC/C API extraction from macOS SDK headers via libclang.
//!
//! This crate parses Objective-C umbrella headers from the macOS SDK,
//! extracts API declarations (classes, methods, properties, protocols,
//! enums, structs, functions, constants), and produces IR checkpoint
//! JSON files with full provenance and documentation references.

pub mod extract_declarations;
pub mod extractor;
pub mod sdk;
pub mod type_mapping;

pub use extractor::{create_index, extract_framework, init_clang};
pub use sdk::{discover_frameworks, discover_sdk, FrameworkInfo, SdkInfo};
