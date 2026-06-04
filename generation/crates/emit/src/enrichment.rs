//! Target-neutral helpers over [`EnrichmentData`] — the analysis-stage relations
//! emitters key idiomatic emission off.
//!
//! Lifted here so every target keying off the same enrichment relation computes
//! the same set, never drifting. The first such helper is
//! [`class_error_selectors`] (the `NSError**` out-param convenience methods),
//! shared by `emit-racket` (native `…_e` dispatch entry) and `emit-gerbil`
//! (in-Gerbil out-param crossing). See `docs/adr/0006-chez-nserror-shape.md`.

use std::collections::HashSet;

use apianyware_macos_types::enrichment::EnrichmentData;

/// The set of selectors for a class that the analysis stage classified as
/// **NSError out-param** convenience methods (`ErrorPattern::ErrorOutParam` →
/// [`EnrichmentData::convenience_error_methods`]). Every target keys error-out
/// routing off this one set, so they classify the same methods and never drift.
/// Empty when there is no enrichment.
pub fn class_error_selectors(
    enrichment: Option<&EnrichmentData>,
    class_name: &str,
) -> HashSet<String> {
    match enrichment {
        None => HashSet::new(),
        Some(data) => data
            .convenience_error_methods
            .iter()
            .filter(|e| e.class == class_name)
            .map(|e| e.selector.clone())
            .collect(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::enrichment::ClassSelectorEntry;

    #[test]
    fn filters_convenience_error_methods_by_class() {
        let data = EnrichmentData {
            convenience_error_methods: vec![
                ClassSelectorEntry {
                    class: "NSData".into(),
                    selector: "writeToFile:options:error:".into(),
                },
                ClassSelectorEntry {
                    class: "NSString".into(),
                    selector: "writeToURL:atomically:encoding:error:".into(),
                },
            ],
            ..Default::default()
        };
        let sel = class_error_selectors(Some(&data), "NSData");
        assert_eq!(sel.len(), 1);
        assert!(sel.contains("writeToFile:options:error:"));
        // A different class's error selector is not included.
        assert!(!sel.contains("writeToURL:atomically:encoding:error:"));
    }

    #[test]
    fn empty_without_enrichment() {
        assert!(class_error_selectors(None, "NSData").is_empty());
    }
}
