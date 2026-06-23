//! Enrichment-derived metadata comments for generated Racket binding files.
//!
//! The analysis "enrich" stage computes an [`EnrichmentData`] struct of
//! annotation-derived metadata: which methods take block parameters classified
//! as synchronous / async-copied / stored, which methods have `NSError`
//! out-params, which methods have weak-reference parameters, and which
//! classes/protocols are main-thread-only.
//!
//! [`EnrichmentNotes`] projects that framework-wide data onto a single class
//! or protocol, indexed by selector, so the class/protocol emitters can surface
//! it as `;;` metadata comment lines next to the methods they describe.

use std::collections::BTreeMap;

use apianyware_types::enrichment::{
    BlockMethodEntry, ClassSelectorEntry, EnrichmentData, WeakParamEntry,
};

/// Enrichment-derived metadata notes for one class or protocol, indexed by selector.
///
/// Built once per class/protocol via [`EnrichmentNotes::for_class`] or
/// [`EnrichmentNotes::for_protocol`]; the emitter then queries it per method.
pub struct EnrichmentNotes {
    /// Metadata note strings keyed by selector. A selector is absent when it
    /// has no notes; per-selector vecs are in fixed family order, never empty.
    by_selector: BTreeMap<String, Vec<String>>,
    /// Whether the class/protocol has main-thread-only methods.
    main_thread: bool,
}

impl EnrichmentNotes {
    /// Build notes for a class from the framework's class-keyed enrichment data.
    ///
    /// `None` enrichment yields an empty set of notes (no notes, not main-thread).
    pub fn for_class(enrichment: Option<&EnrichmentData>, class_name: &str) -> Self {
        match enrichment {
            None => Self::empty(),
            Some(data) => Self::build(
                class_name,
                &data.sync_block_methods,
                &data.async_block_methods,
                &data.stored_block_methods,
                &data.convenience_error_methods,
                &data.weak_param_methods,
                &data.main_thread_classes,
            ),
        }
    }

    /// Build notes for a protocol from the framework's protocol-keyed
    /// enrichment data (the `protocol_*` fields).
    ///
    /// `None` enrichment yields an empty set of notes (no notes, not main-thread).
    pub fn for_protocol(enrichment: Option<&EnrichmentData>, protocol_name: &str) -> Self {
        match enrichment {
            None => Self::empty(),
            Some(data) => Self::build(
                protocol_name,
                &data.protocol_sync_block_methods,
                &data.protocol_async_block_methods,
                &data.protocol_stored_block_methods,
                &data.protocol_convenience_error_methods,
                &data.protocol_weak_param_methods,
                &data.protocol_main_thread_protocols,
            ),
        }
    }

    /// Metadata note strings for one selector (empty slice if none).
    pub fn notes_for(&self, selector: &str) -> &[String] {
        self.by_selector
            .get(selector)
            .map(Vec::as_slice)
            .unwrap_or(&[])
    }

    /// Whether the class/protocol has main-thread-only methods.
    pub fn is_main_thread(&self) -> bool {
        self.main_thread
    }

    /// An empty notes set — no notes, not main-thread.
    fn empty() -> Self {
        Self {
            by_selector: BTreeMap::new(),
            main_thread: false,
        }
    }

    /// Build notes for one class-or-protocol `name` from the matching relations.
    ///
    /// Each source vec is already sorted; notes are appended in a fixed family
    /// order (sync blocks, async blocks, stored blocks, error, weak) so the
    /// per-selector vec is deterministic and golden-safe.
    fn build(
        name: &str,
        sync_blocks: &[BlockMethodEntry],
        async_blocks: &[BlockMethodEntry],
        stored_blocks: &[BlockMethodEntry],
        error_methods: &[ClassSelectorEntry],
        weak_params: &[WeakParamEntry],
        main_thread_names: &[String],
    ) -> Self {
        let mut by_selector: BTreeMap<String, Vec<String>> = BTreeMap::new();

        for entry in sync_blocks.iter().filter(|e| e.class == name) {
            by_selector
                .entry(entry.selector.clone())
                .or_default()
                .push(format!(
                    "block param {}: synchronous (caller frees)",
                    entry.param_index
                ));
        }
        for entry in async_blocks.iter().filter(|e| e.class == name) {
            by_selector
                .entry(entry.selector.clone())
                .or_default()
                .push(format!(
                    "block param {}: async-copied (runtime-managed)",
                    entry.param_index
                ));
        }
        for entry in stored_blocks.iter().filter(|e| e.class == name) {
            by_selector
                .entry(entry.selector.clone())
                .or_default()
                .push(format!(
                    "block param {}: stored (retained across calls)",
                    entry.param_index
                ));
        }
        for entry in error_methods.iter().filter(|e| e.class == name) {
            by_selector
                .entry(entry.selector.clone())
                .or_default()
                .push("NSError out-param: result-or-error wrapper candidate".to_string());
        }
        for entry in weak_params.iter().filter(|e| e.class == name) {
            by_selector
                .entry(entry.selector.clone())
                .or_default()
                .push(format!("param {}: weak reference", entry.param_index));
        }

        let main_thread = main_thread_names.iter().any(|n| n == name);

        Self {
            by_selector,
            main_thread,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn block_entry(class: &str, selector: &str, param_index: usize) -> BlockMethodEntry {
        BlockMethodEntry {
            class: class.to_string(),
            selector: selector.to_string(),
            param_index,
        }
    }

    fn weak_entry(class: &str, selector: &str, param_index: usize) -> WeakParamEntry {
        WeakParamEntry {
            class: class.to_string(),
            selector: selector.to_string(),
            param_index,
        }
    }

    fn error_entry(class: &str, selector: &str) -> ClassSelectorEntry {
        ClassSelectorEntry {
            class: class.to_string(),
            selector: selector.to_string(),
        }
    }

    #[test]
    fn none_enrichment_yields_no_notes() {
        let class_notes = EnrichmentNotes::for_class(None, "TKView");
        assert!(class_notes.notes_for("anything:").is_empty());
        assert!(!class_notes.is_main_thread());

        let proto_notes = EnrichmentNotes::for_protocol(None, "TKDelegate");
        assert!(proto_notes.notes_for("anything:").is_empty());
        assert!(!proto_notes.is_main_thread());
    }

    #[test]
    fn empty_enrichment_yields_no_notes() {
        let data = EnrichmentData::default();
        let notes = EnrichmentNotes::for_class(Some(&data), "TKView");
        assert!(notes.notes_for("doThing:").is_empty());
        assert!(!notes.is_main_thread());
    }

    #[test]
    fn class_notes_ordered_by_family_then_source_order() {
        // A single selector carrying sync, async, and weak entries: the notes
        // must appear in family order (sync, async, stored, error, weak),
        // independent of how the source vecs interleave.
        let data = EnrichmentData {
            sync_block_methods: vec![block_entry("TKView", "loadWithHandler:retry:", 1)],
            async_block_methods: vec![block_entry("TKView", "loadWithHandler:retry:", 0)],
            weak_param_methods: vec![weak_entry("TKView", "loadWithHandler:retry:", 2)],
            ..EnrichmentData::default()
        };
        let notes = EnrichmentNotes::for_class(Some(&data), "TKView");
        assert_eq!(
            notes.notes_for("loadWithHandler:retry:"),
            &[
                "block param 1: synchronous (caller frees)".to_string(),
                "block param 0: async-copied (runtime-managed)".to_string(),
                "param 2: weak reference".to_string(),
            ]
        );
    }

    #[test]
    fn stored_block_and_error_notes_are_emitted() {
        let data = EnrichmentData {
            stored_block_methods: vec![block_entry("TKView", "observe:", 0)],
            convenience_error_methods: vec![error_entry("TKView", "readData:")],
            ..EnrichmentData::default()
        };
        let notes = EnrichmentNotes::for_class(Some(&data), "TKView");
        assert_eq!(
            notes.notes_for("observe:"),
            &["block param 0: stored (retained across calls)".to_string()]
        );
        assert_eq!(
            notes.notes_for("readData:"),
            &["NSError out-param: result-or-error wrapper candidate".to_string()]
        );
    }

    #[test]
    fn class_notes_filter_by_class_name() {
        let data = EnrichmentData {
            async_block_methods: vec![
                block_entry("TKView", "mine:", 0),
                block_entry("TKOther", "theirs:", 0),
            ],
            ..EnrichmentData::default()
        };
        let notes = EnrichmentNotes::for_class(Some(&data), "TKView");
        assert!(!notes.notes_for("mine:").is_empty());
        assert!(notes.notes_for("theirs:").is_empty());
    }

    #[test]
    fn for_protocol_reads_protocol_fields_not_class_fields() {
        // Class-keyed and protocol-keyed fields both reference the same name;
        // for_protocol must read only the protocol_* fields.
        let data = EnrichmentData {
            async_block_methods: vec![block_entry("TKDelegate", "classScoped:", 0)],
            protocol_async_block_methods: vec![block_entry("TKDelegate", "protoScoped:", 0)],
            ..EnrichmentData::default()
        };
        let notes = EnrichmentNotes::for_protocol(Some(&data), "TKDelegate");
        assert!(
            notes.notes_for("classScoped:").is_empty(),
            "for_protocol must not read class-keyed fields"
        );
        assert_eq!(
            notes.notes_for("protoScoped:"),
            &["block param 0: async-copied (runtime-managed)".to_string()]
        );
    }

    #[test]
    fn for_class_does_not_read_protocol_fields() {
        let data = EnrichmentData {
            protocol_async_block_methods: vec![block_entry("TKView", "protoScoped:", 0)],
            ..EnrichmentData::default()
        };
        let notes = EnrichmentNotes::for_class(Some(&data), "TKView");
        assert!(notes.notes_for("protoScoped:").is_empty());
    }

    #[test]
    fn is_main_thread_reflects_main_thread_classes() {
        let data = EnrichmentData {
            main_thread_classes: vec!["TKView".to_string()],
            ..EnrichmentData::default()
        };
        assert!(EnrichmentNotes::for_class(Some(&data), "TKView").is_main_thread());
        assert!(!EnrichmentNotes::for_class(Some(&data), "TKOther").is_main_thread());
    }

    #[test]
    fn is_main_thread_reflects_protocol_main_thread_protocols() {
        let data = EnrichmentData {
            protocol_main_thread_protocols: vec!["TKDelegate".to_string()],
            ..EnrichmentData::default()
        };
        assert!(EnrichmentNotes::for_protocol(Some(&data), "TKDelegate").is_main_thread());
        assert!(!EnrichmentNotes::for_protocol(Some(&data), "TKOther").is_main_thread());
        // The protocol main-thread flag must not leak into for_class.
        assert!(!EnrichmentNotes::for_class(Some(&data), "TKDelegate").is_main_thread());
    }
}
