//! Target-emitter abstraction shared by every target's emitter crate.
//!
//! Each target produces exactly one binding style by construction; the style
//! is implicit in the target, never reified here. See
//! `docs/adr/0004-retire-paradigm-dimension.md`.

use std::io;
use std::path::Path;

use apianyware_types::Framework;

/// Metadata about a target target emitter.
pub struct TargetInfo {
    /// Short identifier used in CLI (e.g., `"racket"`).
    pub id: &'static str,
    /// Human-readable name (e.g., `"Racket"`).
    pub display_name: &'static str,
    /// Subdirectory under `targets/<id>/bindings/macos/` that receives the
    /// emitter's framework output. Most targets use `"generated"`; the
    /// chez target uses `"apianyware"` so Chez's default library-name
    /// resolution (`(apianyware <fw> <cls>)` →
    /// `<libdir>/apianyware/<fw>/<cls>.sls`) finds emitted files with
    /// `--libdirs targets/chez/bindings/macos`.
    pub generated_subdir: &'static str,
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

/// Trait that all target-specific emitters implement.
///
/// The generation CLI uses this to dispatch framework emission to the
/// appropriate target emitter based on the `--lang` flag.
pub trait TargetEmitter {
    /// Metadata about this emitter.
    fn target_info(&self) -> &TargetInfo;

    /// Emit bindings for a single framework.
    ///
    /// `output_dir` is the target's generated-bindings root (e.g.,
    /// `targets/racket/bindings/macos/generated/` for racket,
    /// `targets/chez/bindings/macos/apianyware/` for chez — see
    /// `TargetInfo::generated_subdir`). The emitter creates a
    /// framework subdirectory within it.
    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_target_info() {
        let racket = TargetInfo {
            id: "racket",
            display_name: "Racket",
            generated_subdir: "generated",
        };
        assert_eq!(racket.id, "racket");
        assert_eq!(racket.display_name, "Racket");
        assert_eq!(racket.generated_subdir, "generated");
    }
}
