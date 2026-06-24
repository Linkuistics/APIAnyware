//! Framework dependency ordering for code generation.
//!
//! Emitters need to generate frameworks in dependency order so that required
//! modules (e.g., Foundation) are available before dependent modules (e.g., AppKit).
//! This module provides a topological sort based on the `depends_on` field in the IR.

use std::collections::{HashMap, HashSet, VecDeque};

use apianyware_types::Framework;

/// Sort frameworks in dependency order (dependencies before dependents).
///
/// Returns framework names in an order suitable for sequential generation.
/// Frameworks with no dependencies come first. Cycles are broken arbitrarily
/// (unlikely in practice since Apple frameworks form a DAG).
///
/// Frameworks not present in the input (external dependencies) are silently ignored.
pub fn topological_sort(frameworks: &[Framework]) -> Vec<String> {
    let names: HashSet<&str> = frameworks.iter().map(|fw| fw.name.as_str()).collect();

    // Build adjacency: dependent → dependencies (only those in our set)
    let mut in_degree: HashMap<&str, usize> = HashMap::new();
    let mut dependents: HashMap<&str, Vec<&str>> = HashMap::new();

    for fw in frameworks {
        in_degree.entry(fw.name.as_str()).or_insert(0);
        for dep in &fw.depends_on {
            if names.contains(dep.as_str()) {
                *in_degree.entry(fw.name.as_str()).or_insert(0) += 1;
                dependents
                    .entry(dep.as_str())
                    .or_default()
                    .push(fw.name.as_str());
            }
        }
    }

    // Kahn's algorithm
    let mut queue: VecDeque<&str> = in_degree
        .iter()
        .filter(|(_, &deg)| deg == 0)
        .map(|(&name, _)| name)
        .collect();

    // Sort the initial queue for deterministic output
    let mut sorted_queue: Vec<&str> = queue.drain(..).collect();
    sorted_queue.sort();
    queue.extend(sorted_queue);

    let mut result = Vec::with_capacity(frameworks.len());

    while let Some(name) = queue.pop_front() {
        result.push(name.to_string());
        if let Some(deps) = dependents.get(name) {
            let mut next_batch = Vec::new();
            for &dep in deps {
                if let Some(deg) = in_degree.get_mut(dep) {
                    *deg -= 1;
                    if *deg == 0 {
                        next_batch.push(dep);
                    }
                }
            }
            // Sort for deterministic output
            next_batch.sort();
            queue.extend(next_batch);
        }
    }

    // If there are cycles, append remaining frameworks (sorted for determinism)
    if result.len() < frameworks.len() {
        let in_result: HashSet<&str> = result.iter().map(|s| s.as_str()).collect();
        let mut remaining: Vec<String> = frameworks
            .iter()
            .filter(|fw| !in_result.contains(fw.name.as_str()))
            .map(|fw| fw.name.clone())
            .collect();
        remaining.sort();
        result.extend(remaining);
    }

    result
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_framework(name: &str, depends_on: &[&str]) -> Framework {
        Framework {
            name: name.to_string(),
            depends_on: depends_on.iter().map(|s| s.to_string()).collect(),
            ..default_framework()
        }
    }

    fn default_framework() -> Framework {
        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "resolved".to_string(),
            name: String::new(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    #[test]
    fn test_no_dependencies() {
        let frameworks = vec![
            make_framework("CoreGraphics", &[]),
            make_framework("Foundation", &[]),
            make_framework("AppKit", &[]),
        ];
        let order = topological_sort(&frameworks);
        assert_eq!(order, vec!["AppKit", "CoreGraphics", "Foundation"]);
    }

    #[test]
    fn test_linear_dependencies() {
        let frameworks = vec![
            make_framework("AppKit", &["Foundation"]),
            make_framework("Foundation", &[]),
        ];
        let order = topological_sort(&frameworks);
        assert_eq!(order, vec!["Foundation", "AppKit"]);
    }

    #[test]
    fn test_diamond_dependency() {
        let frameworks = vec![
            make_framework("AppKit", &["Foundation", "CoreGraphics"]),
            make_framework("CoreGraphics", &["Foundation"]),
            make_framework("Foundation", &[]),
        ];
        let order = topological_sort(&frameworks);
        // Foundation first, then CoreGraphics, then AppKit
        let foundation_pos = order.iter().position(|n| n == "Foundation").unwrap();
        let cg_pos = order.iter().position(|n| n == "CoreGraphics").unwrap();
        let appkit_pos = order.iter().position(|n| n == "AppKit").unwrap();
        assert!(foundation_pos < cg_pos);
        assert!(foundation_pos < appkit_pos);
        assert!(cg_pos < appkit_pos);
    }

    #[test]
    fn test_external_dependencies_ignored() {
        let frameworks = vec![
            make_framework("AppKit", &["Foundation", "IOKit"]),
            make_framework("Foundation", &[]),
        ];
        // IOKit is not in our set — should be silently ignored
        let order = topological_sort(&frameworks);
        assert_eq!(order, vec!["Foundation", "AppKit"]);
    }

    #[test]
    fn test_empty_input() {
        let frameworks: Vec<Framework> = vec![];
        let order = topological_sort(&frameworks);
        assert!(order.is_empty());
    }

    #[test]
    fn test_single_framework() {
        let frameworks = vec![make_framework("Foundation", &[])];
        let order = topological_sort(&frameworks);
        assert_eq!(order, vec!["Foundation"]);
    }
}
