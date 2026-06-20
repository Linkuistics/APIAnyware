//! Emitter registry — maps target IDs to [`TargetEmitter`] implementations.
//!
//! New targets are added by inserting their emitter into [`EmitterRegistry::new`].

use apianyware_macos_emit::target_emitter::TargetEmitter;

/// Registry of all available target emitters.
pub struct EmitterRegistry {
    emitters: Vec<Box<dyn TargetEmitter>>,
}

impl EmitterRegistry {
    /// Create a registry with all built-in emitters.
    pub fn new() -> Self {
        let emitters: Vec<Box<dyn TargetEmitter>> = vec![
            Box::new(apianyware_macos_emit_racket::RacketEmitter),
            Box::new(apianyware_macos_emit_chez::ChezEmitter),
            // Gerbil's per-run emitter carries an empty cross-framework
            // `ClassRegistry`; the generate pre-pass swaps in a populated one
            // built over all loaded frameworks (see `generate.rs`). The
            // registry instance here is what `--list-targets` / lookups see.
            Box::new(apianyware_macos_emit_gerbil::GerbilEmitter::new()),
            // SBCL's per-run emitter (leaf 040/010 scaffold). Like gerbil, later
            // leaves give it cross-framework registries via a `generate` pre-pass;
            // the `new()` instance here backs `--list-targets` / lookups.
            Box::new(apianyware_macos_emit_sbcl::SbclEmitter::new()),
        ];
        Self { emitters }
    }

    /// Look up an emitter by target ID (e.g., "racket").
    pub fn get(&self, target_id: &str) -> Option<&dyn TargetEmitter> {
        self.emitters
            .iter()
            .find(|e| e.target_info().id == target_id)
            .map(|e| e.as_ref())
    }

    /// All registered emitters.
    pub fn all(&self) -> impl Iterator<Item = &dyn TargetEmitter> {
        self.emitters.iter().map(|e| e.as_ref())
    }

    /// Format a human-readable listing of all registered targets.
    pub fn format_target_list(&self) -> String {
        let mut lines = Vec::new();
        for emitter in self.all() {
            let info = emitter.target_info();
            lines.push(format!("  {:<16} {}", info.id, info.display_name));
        }
        lines.sort();
        lines.join("\n")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn registry_contains_racket() {
        let registry = EmitterRegistry::new();
        let racket = registry.get("racket");
        assert!(racket.is_some(), "registry should contain racket emitter");
        let info = racket.unwrap().target_info();
        assert_eq!(info.id, "racket");
        assert_eq!(info.display_name, "Racket");
    }

    #[test]
    fn registry_returns_none_for_unknown_target() {
        let registry = EmitterRegistry::new();
        assert!(registry.get("unknown").is_none());
    }

    #[test]
    fn registry_lists_all_emitters() {
        let registry = EmitterRegistry::new();
        let all: Vec<_> = registry.all().collect();
        assert!(!all.is_empty());
        let ids: Vec<&str> = all.iter().map(|e| e.target_info().id).collect();
        assert!(ids.contains(&"racket"));
        assert!(ids.contains(&"chez"));
        assert!(ids.contains(&"gerbil"));
        assert!(ids.contains(&"sbcl"));
    }

    #[test]
    fn registry_contains_sbcl() {
        let registry = EmitterRegistry::new();
        let sbcl = registry.get("sbcl");
        assert!(sbcl.is_some(), "registry should contain sbcl emitter");
        let info = sbcl.unwrap().target_info();
        assert_eq!(info.id, "sbcl");
        assert_eq!(info.display_name, "SBCL");
    }

    #[test]
    fn registry_contains_gerbil() {
        let registry = EmitterRegistry::new();
        let gerbil = registry.get("gerbil");
        assert!(gerbil.is_some(), "registry should contain gerbil emitter");
        let info = gerbil.unwrap().target_info();
        assert_eq!(info.id, "gerbil");
        assert_eq!(info.display_name, "Gerbil Scheme");
    }

    #[test]
    fn registry_contains_chez() {
        let registry = EmitterRegistry::new();
        let chez = registry.get("chez");
        assert!(chez.is_some(), "registry should contain chez emitter");
        let info = chez.unwrap().target_info();
        assert_eq!(info.id, "chez");
        assert_eq!(info.display_name, "Chez Scheme");
    }

    #[test]
    fn format_target_list_includes_both() {
        let registry = EmitterRegistry::new();
        let list = registry.format_target_list();
        assert!(list.contains("racket"));
        assert!(list.contains("Racket"));
        assert!(list.contains("chez"));
        assert!(list.contains("Chez Scheme"));
        assert!(list.contains("gerbil"));
        assert!(list.contains("Gerbil Scheme"));
        assert!(list.contains("sbcl"));
        assert!(list.contains("SBCL"));
    }
}
