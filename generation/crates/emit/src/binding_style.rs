//! Language-emitter abstraction shared by every target's emitter crate.
//!
//! Each target produces exactly one binding style by construction; the style
//! is implicit in the target, never reified here. See
//! `docs/adr/0004-retire-paradigm-dimension.md`.

use std::io;
use std::path::Path;

use apianyware_macos_types::Framework;

/// Metadata about a target language emitter.
pub struct LanguageInfo {
    /// Short identifier used in CLI (e.g., `"racket-oo"`).
    pub id: &'static str,
    /// Human-readable name (e.g., `"Racket OO"`).
    pub display_name: &'static str,
}

/// Result of emitting a single framework.
#[derive(Debug, Default)]
pub struct EmitResult {
    /// Number of files written.
    pub files_written: usize,
    /// Number of classes emitted.
    pub classes_emitted: usize,
    /// Number of protocols emitted.
    pub protocols_emitted: usize,
    /// Number of enums emitted.
    pub enums_emitted: usize,
    /// Number of functions emitted.
    pub functions_emitted: usize,
    /// Number of constants emitted.
    pub constants_emitted: usize,
}

/// Trait that all language-specific emitters implement.
///
/// The generation CLI uses this to dispatch framework emission to the
/// appropriate language emitter based on the `--lang` flag.
pub trait LanguageEmitter {
    /// Metadata about this emitter.
    fn language_info(&self) -> &LanguageInfo;

    /// Emit bindings for a single framework.
    ///
    /// `output_dir` is the target's generated-bindings root (e.g.,
    /// `generation/targets/racket-oo/generated/`). The emitter creates a
    /// framework subdirectory within it.
    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_language_info() {
        let racket = LanguageInfo {
            id: "racket-oo",
            display_name: "Racket OO",
        };
        assert_eq!(racket.id, "racket-oo");
        assert_eq!(racket.display_name, "Racket OO");
    }
}
