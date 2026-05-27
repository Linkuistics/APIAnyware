//! Emitter registry — maps language IDs to [`LanguageEmitter`] implementations.
//!
//! New languages are added by inserting their emitter into [`EmitterRegistry::new`].

use apianyware_macos_emit::binding_style::LanguageEmitter;

/// Registry of all available language emitters.
pub struct EmitterRegistry {
    emitters: Vec<Box<dyn LanguageEmitter>>,
}

impl EmitterRegistry {
    /// Create a registry with all built-in emitters.
    pub fn new() -> Self {
        let emitters: Vec<Box<dyn LanguageEmitter>> =
            vec![Box::new(apianyware_macos_emit_racket::RacketEmitter)];
        Self { emitters }
    }

    /// Look up an emitter by language ID (e.g., "racket").
    pub fn get(&self, language_id: &str) -> Option<&dyn LanguageEmitter> {
        self.emitters
            .iter()
            .find(|e| e.language_info().id == language_id)
            .map(|e| e.as_ref())
    }

    /// All registered emitters.
    pub fn all(&self) -> impl Iterator<Item = &dyn LanguageEmitter> {
        self.emitters.iter().map(|e| e.as_ref())
    }

    /// Format a human-readable listing of all registered languages.
    pub fn format_language_list(&self) -> String {
        let mut lines = Vec::new();
        for emitter in self.all() {
            let info = emitter.language_info();
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
        assert!(
            racket.is_some(),
            "registry should contain racket emitter"
        );
        let info = racket.unwrap().language_info();
        assert_eq!(info.id, "racket");
        assert_eq!(info.display_name, "Racket");
    }

    #[test]
    fn registry_returns_none_for_unknown_language() {
        let registry = EmitterRegistry::new();
        assert!(registry.get("unknown").is_none());
    }

    #[test]
    fn registry_lists_all_emitters() {
        let registry = EmitterRegistry::new();
        let all: Vec<_> = registry.all().collect();
        assert!(!all.is_empty());
        assert_eq!(all[0].language_info().id, "racket");
    }

    #[test]
    fn format_language_list_includes_racket() {
        let registry = EmitterRegistry::new();
        let list = registry.format_language_list();
        assert!(list.contains("racket"));
        assert!(list.contains("Racket"));
    }
}
