//! Source provenance, documentation references, and declaration source tracking.
//!
//! These types capture where a declaration came from and how to find
//! its documentation — enabling the generation phase to produce
//! cross-referenced documentation linking back to Apple's docs.

use serde::{Deserialize, Serialize};

/// Where a declaration was extracted from: its source file, line number,
/// SDK version, and platform availability.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SourceProvenance {
    /// Path to the source header, relative to the SDK root.
    /// Example: `"Foundation/NSString.h"`
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub header: Option<String>,

    /// Line number within the header file.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub line: Option<u32>,

    /// Platform availability (introduced/deprecated versions).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub availability: Option<Availability>,
}

/// Platform availability attributes from `API_AVAILABLE` / `NS_DEPRECATED` macros.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Availability {
    /// macOS version when the API was introduced (e.g., `"10.0"`).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub introduced: Option<String>,

    /// macOS version when the API was deprecated, if applicable.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub deprecated: Option<String>,
}

/// Documentation references for a declaration: header comments,
/// Apple developer documentation URL, and USR for symbol lookup.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocRefs {
    /// Brief comment text from the header file (libclang `clang_Cursor_getBriefCommentText`).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub header_comment: Option<String>,

    /// Apple developer documentation URL constructed from the USR.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub apple_doc_url: Option<String>,

    /// Unified Symbol Resolution identifier (libclang `clang_getCursorUSR`).
    /// Stable across SDK versions; used for Apple doc URL construction.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub usr: Option<String>,
}

/// Which extraction source produced a declaration.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum DeclarationSource {
    /// Extracted from Objective-C/C headers via libclang.
    ObjcHeader,
    /// Extracted from Swift module interfaces via swift-api-digester.
    SwiftInterface,
}
