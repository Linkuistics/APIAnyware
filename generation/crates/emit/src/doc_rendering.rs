//! Language-neutral documentation rendering from IR provenance and doc refs.
//!
//! Produces structured doc content from [`SourceProvenance`] and [`DocRefs`].
//! Each language emitter formats this content into its own comment syntax
//! (`;; ...` for Scheme, `-- ...` for Haskell, `/// ...` for Zig, etc.).

use apianyware_types::provenance::{DocRefs, SourceProvenance};

/// A rendered documentation block ready for language-specific formatting.
#[derive(Debug, Clone, Default)]
pub struct DocBlock {
    /// Brief description from header comments.
    pub summary: Option<String>,
    /// Apple developer documentation URL.
    pub apple_doc_url: Option<String>,
    /// Availability note (e.g., "Available since macOS 10.0, deprecated in 14.0").
    pub availability: Option<String>,
    /// Source header path (e.g., "Foundation/NSString.h:142").
    pub source_location: Option<String>,
}

impl DocBlock {
    /// Whether this doc block has any content worth rendering.
    pub fn is_empty(&self) -> bool {
        self.summary.is_none()
            && self.apple_doc_url.is_none()
            && self.availability.is_none()
            && self.source_location.is_none()
    }

    /// Render as a sequence of lines (without comment markers).
    pub fn to_lines(&self) -> Vec<String> {
        let mut lines = Vec::new();
        if let Some(summary) = &self.summary {
            lines.push(summary.clone());
        }
        if let Some(availability) = &self.availability {
            if !lines.is_empty() {
                lines.push(String::new());
            }
            lines.push(availability.clone());
        }
        if let Some(url) = &self.apple_doc_url {
            if !lines.is_empty() {
                lines.push(String::new());
            }
            lines.push(format!("See: {url}"));
        }
        if let Some(location) = &self.source_location {
            lines.push(format!("Source: {location}"));
        }
        lines
    }
}

/// Build a [`DocBlock`] from provenance and doc refs.
pub fn render_doc_block(
    provenance: Option<&SourceProvenance>,
    doc_refs: Option<&DocRefs>,
) -> DocBlock {
    let mut block = DocBlock::default();

    if let Some(refs) = doc_refs {
        block.summary = refs.header_comment.clone();
        block.apple_doc_url = refs.apple_doc_url.clone();
    }

    if let Some(prov) = provenance {
        // Availability
        if let Some(avail) = &prov.availability {
            let mut parts = Vec::new();
            if let Some(intro) = &avail.introduced {
                parts.push(format!("Available since macOS {intro}"));
            }
            if let Some(dep) = &avail.deprecated {
                parts.push(format!("deprecated in {dep}"));
            }
            if !parts.is_empty() {
                block.availability = Some(parts.join(", "));
            }
        }

        // Source location
        if let Some(header) = &prov.header {
            if let Some(line) = prov.line {
                block.source_location = Some(format!("{header}:{line}"));
            } else {
                block.source_location = Some(header.clone());
            }
        }
    }

    block
}

/// Render a doc block as lines with a given comment prefix.
///
/// Example: `format_doc_lines(&block, ";; ")` produces Scheme-style comments.
pub fn format_doc_lines(block: &DocBlock, prefix: &str) -> Vec<String> {
    block
        .to_lines()
        .into_iter()
        .map(|line| {
            if line.is_empty() {
                prefix.trim_end().to_string()
            } else {
                format!("{prefix}{line}")
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::provenance::Availability;

    #[test]
    fn test_empty_doc_block() {
        let block = render_doc_block(None, None);
        assert!(block.is_empty());
        assert!(block.to_lines().is_empty());
    }

    #[test]
    fn test_doc_block_with_summary_only() {
        let refs = DocRefs {
            header_comment: Some("Returns the length of the string.".to_string()),
            apple_doc_url: None,
            usr: None,
        };
        let block = render_doc_block(None, Some(&refs));
        assert!(!block.is_empty());
        assert_eq!(block.to_lines(), vec!["Returns the length of the string."]);
    }

    #[test]
    fn test_doc_block_full() {
        let prov = SourceProvenance {
            header: Some("Foundation/NSString.h".to_string()),
            line: Some(142),
            availability: Some(Availability {
                introduced: Some("10.0".to_string()),
                deprecated: None,
            }),
        };
        let refs = DocRefs {
            header_comment: Some("Returns the length.".to_string()),
            apple_doc_url: Some(
                "https://developer.apple.com/documentation/foundation/nsstring/length".to_string(),
            ),
            usr: Some("c:objc(cs)NSString(py)length".to_string()),
        };
        let block = render_doc_block(Some(&prov), Some(&refs));
        let lines = block.to_lines();
        assert_eq!(lines[0], "Returns the length.");
        assert_eq!(lines[1], ""); // blank separator
        assert_eq!(lines[2], "Available since macOS 10.0");
        assert_eq!(lines[3], ""); // blank separator
        assert_eq!(
            lines[4],
            "See: https://developer.apple.com/documentation/foundation/nsstring/length"
        );
        assert_eq!(lines[5], "Source: Foundation/NSString.h:142");
    }

    #[test]
    fn test_deprecated_availability() {
        let prov = SourceProvenance {
            header: None,
            line: None,
            availability: Some(Availability {
                introduced: Some("10.0".to_string()),
                deprecated: Some("14.0".to_string()),
            }),
        };
        let block = render_doc_block(Some(&prov), None);
        assert_eq!(
            block.availability.as_deref(),
            Some("Available since macOS 10.0, deprecated in 14.0")
        );
    }

    #[test]
    fn test_format_doc_lines_scheme() {
        let refs = DocRefs {
            header_comment: Some("Get the length.".to_string()),
            apple_doc_url: Some("https://example.com".to_string()),
            usr: None,
        };
        let block = render_doc_block(None, Some(&refs));
        let lines = format_doc_lines(&block, ";; ");
        assert_eq!(lines[0], ";; Get the length.");
        assert_eq!(lines[1], ";;"); // blank line with trimmed prefix
        assert_eq!(lines[2], ";; See: https://example.com");
    }

    #[test]
    fn test_format_doc_lines_haskell() {
        let refs = DocRefs {
            header_comment: Some("Get the length.".to_string()),
            apple_doc_url: None,
            usr: None,
        };
        let block = render_doc_block(None, Some(&refs));
        let lines = format_doc_lines(&block, "-- | ");
        assert_eq!(lines[0], "-- | Get the length.");
    }
}
