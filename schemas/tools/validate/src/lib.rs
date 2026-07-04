//! The **one validation mechanism** over every authored APIAnyware artifact
//! (`structural-refactoring` grove, workstream 8 — `schema-validation-k149`,
//! leaf `validate-umbrella-k154`).
//!
//! ws2–ws6 each authored a `.apiw` KDL-Schema under `schemas/spec-format/` plus a
//! focused in-crate validator + a per-crate `tests/*_registry.rs` guard. ws8's job
//! was **not** to re-author any of that — it is to wire the twelve validators into
//! a single tree-walking driver so "formal validation of *every* artifact"
//! (root BRIEF #8) becomes one runnable command instead of twelve `cargo test`s.
//!
//! This module is that driver's testable core. It is deliberately **lean** (leaf
//! brief: "a lean driver over the machinery that already exists, not new
//! machinery"): the only logic here is
//!
//! 1. **classification by path** — a static table mapping each authored-artifact
//!    layout (`platforms/macos/api/<F>/annotations.apiw`,
//!    `targets/<t>/capability.apiw`, …) to the producing crate's validator; and
//! 2. **coverage as a guard** — rather than globbing each class, [`validate_authored`]
//!    walks *every* `.apiw` and reports any file that matches **no** rule as a
//!    failure, so a future artifact type added without wiring this umbrella cannot
//!    silently escape the "validate every artifact" promise.
//!
//! Validation itself is entirely delegated: each [`Class::validate`] is a thin
//! adapter over a `pub fn validate_*(source_name, text)` re-exported by the crate
//! that owns the schema. No schema text is embedded here.
//!
//! ## Machine IR
//!
//! The derived machine IR (`extracted.kdl` / `resolved.kdl`,
//! `apianyware_spec_format::validate_machine_kdl`) is validated **only on opt-in**
//! ([`machine_ir_files`] + the binary's `--machine` flag). It is gitignored/derived
//! (constraint 4), runs on the format-preserving KDL parser (~2 s/MB, ADR-0046 §5),
//! and a flattened `resolved.kdl` can exceed 80 MB — so a full-corpus check is a
//! minutes-scale operation that must not run on every `make validate`. The
//! bounded-work registry test
//! (`apianyware-spec-format/tests/machine_schema_validation.rs`) is the cheap
//! machine-IR guard for `cargo test`; this umbrella's `--machine` is the exhaustive
//! on-demand one.

use std::fmt::Display;
use std::path::{Path, PathBuf};

/// One class of authored artifact: how to recognise its files on disk, and how to
/// validate one. `matches` and `validate` are non-capturing closures (they coerce
/// to `fn` pointers), so [`Class`] is a plain data row in the [`classes`] table.
struct Class {
    /// Human-readable class name, used in reports.
    name: &'static str,
    /// True when the repo-relative path components identify a file of this class.
    /// Fed only `.apiw` paths, so the final component always ends in `.apiw`.
    matches: fn(&[&str]) -> bool,
    /// Validate one file's `(source_name, text)`; `Err` carries a displayable
    /// diagnostic. Delegates to the producing crate's `validate_*` function.
    validate: fn(&str, &str) -> Result<(), String>,
}

/// Uniform adapter: collapse any producing crate's `Result<(), E: Display>` to the
/// `Result<(), String>` the report carries (the umbrella only ever *displays* a
/// validator's error, never inspects its type).
fn disp<E: Display>(r: Result<(), E>) -> Result<(), String> {
    r.map_err(|e| e.to_string())
}

/// The static dispatch table: every authored-`.apiw` layout in the repo, paired
/// with the validator that owns its schema. Rules are **disjoint** — a path
/// matches at most one — so first-match in [`classify`] is unambiguous. Adding a
/// new authored artifact type means adding a row here (and its producing crate as
/// a dependency); until then [`validate_authored`] reports it as unclassified.
fn classes() -> Vec<Class> {
    vec![
        // platforms/macos — the platform model (ws4) + the LLM annotation overlay (ws2/ws5).
        Class {
            name: "annotations overlay",
            matches: |c| matches!(c, ["platforms", "macos", "api", _, "annotations.apiw"]),
            validate: |n, t| disp(apianyware_spec_format::validate_apiw(n, t)),
        },
        Class {
            name: "platform manifest",
            matches: |c| matches!(c, ["platforms", "macos", "platform.apiw"]),
            validate: |n, t| {
                disp(apianyware_platform_manifest::validate_platform_manifest(
                    n, t,
                ))
            },
        },
        Class {
            name: "app-kind",
            matches: |c| matches!(c, ["platforms", "macos", "app-kinds", _, "kind.apiw"]),
            validate: |n, t| disp(apianyware_app_kinds::validate_app_kind(n, t)),
        },
        Class {
            name: "api-semantics test",
            matches: |c| matches!(c, ["platforms", "macos", "tests", "api-semantics", _]),
            validate: |n, t| disp(apianyware_platform_tests::validate_api_semantics(n, t)),
        },
        Class {
            name: "app-kind test",
            matches: |c| matches!(c, ["platforms", "macos", "tests", "app-kinds", _]),
            validate: |n, t| disp(apianyware_platform_tests::validate_app_kind_tests(n, t)),
        },
        // semantic — the pattern-kind registry (ws3).
        Class {
            name: "pattern-kind",
            matches: |c| matches!(c, ["semantic", "pattern-kinds", _]),
            validate: |n, t| disp(apianyware_patterns::validate_pattern_kind(n, t)),
        },
        // targets/<t> — the authored target model (ws6).
        Class {
            name: "target descriptor",
            matches: |c| matches!(c, ["targets", _, "target.apiw"]),
            validate: |n, t| disp(apianyware_target_model::validate_target(n, t)),
        },
        Class {
            name: "capability profile",
            matches: |c| matches!(c, ["targets", _, "capability.apiw"]),
            validate: |n, t| disp(apianyware_target_model::validate_capability(n, t)),
        },
        Class {
            name: "idiom catalogue",
            matches: |c| matches!(c, ["targets", _, "idioms", _]),
            validate: |n, t| disp(apianyware_target_model::validate_idioms(n, t)),
        },
        Class {
            name: "projection policy",
            matches: |c| matches!(c, ["targets", _, "policies", _, _]),
            validate: |n, t| disp(apianyware_target_model::validate_policy(n, t)),
        },
        Class {
            name: "adapter spec",
            matches: |c| matches!(c, ["targets", _, "adapters", _, _]),
            validate: |n, t| disp(apianyware_target_model::validate_adapter_spec(n, t)),
        },
        Class {
            name: "conformance judgment",
            matches: |c| matches!(c, ["targets", _, "conformance", _]),
            validate: |n, t| disp(apianyware_target_model::validate_conformance(n, t)),
        },
    ]
}

/// One authored file's validation result.
pub struct Outcome {
    /// The [`Class::name`] it was dispatched to.
    pub class: &'static str,
    /// Repo-relative, `/`-joined path (stable across platforms, used in reports).
    pub rel_path: String,
    /// `None` on success; `Some(diagnostic)` on a schema/semantic violation.
    pub error: Option<String>,
}

/// The result of validating every authored `.apiw` artifact under a repo root.
pub struct AuthoredReport {
    /// Classified files (validated), in walk order.
    pub outcomes: Vec<Outcome>,
    /// Repo-relative paths of `.apiw` files that matched **no** class — a coverage
    /// gap the umbrella refuses to hide (treated as a failure by [`AuthoredReport::ok`]).
    pub unclassified: Vec<String>,
}

impl AuthoredReport {
    /// Files that validated cleanly.
    pub fn passed(&self) -> usize {
        self.outcomes.iter().filter(|o| o.error.is_none()).count()
    }

    /// Files that failed validation.
    pub fn failed(&self) -> usize {
        self.outcomes.iter().filter(|o| o.error.is_some()).count()
    }

    /// True only when every classified file validated **and** no `.apiw` was left
    /// unclassified (a coverage gap is a failure, not a pass).
    pub fn ok(&self) -> bool {
        self.failed() == 0 && self.unclassified.is_empty()
    }
}

/// Validate every authored `.apiw` artifact under `root`, dispatching each to its
/// class's validator and reporting any that match no class. Pure over the
/// filesystem: reads files, calls the (side-effect-free) validators, returns data.
pub fn validate_authored(root: &Path) -> AuthoredReport {
    let classes = classes();
    let mut outcomes = Vec::new();
    let mut unclassified = Vec::new();

    for path in walk(root, is_apiw) {
        let rel = rel_path(root, &path);
        let components: Vec<&str> = rel.split('/').collect();
        match classes.iter().find(|c| (c.matches)(&components)) {
            Some(class) => {
                let error = match std::fs::read_to_string(&path) {
                    Ok(text) => (class.validate)(&rel, &text).err(),
                    Err(e) => Some(format!("could not read file: {e}")),
                };
                outcomes.push(Outcome {
                    class: class.name,
                    rel_path: rel,
                    error,
                });
            }
            None => unclassified.push(rel),
        }
    }

    // Deterministic, reviewable ordering regardless of filesystem walk order.
    outcomes.sort_by(|a, b| a.rel_path.cmp(&b.rel_path));
    unclassified.sort();
    AuthoredReport {
        outcomes,
        unclassified,
    }
}

/// Every materialized machine-IR file (`extracted.kdl` / `resolved.kdl` under
/// `platforms/macos/api/<F>/`) below `root`, sorted by **ascending size** so a
/// caller that streams progress does the cheap files first. Empty when the IR has
/// not been materialized (it is derived/gitignored — the caller then emits the
/// "run the pipeline first" precondition message). Validate each with
/// [`apianyware_spec_format::validate_machine_kdl`].
pub fn machine_ir_files(root: &Path) -> Vec<PathBuf> {
    let api_root = root.join("platforms").join("macos").join("api");
    let mut files: Vec<(u64, PathBuf)> = Vec::new();
    let Ok(entries) = std::fs::read_dir(&api_root) else {
        return Vec::new();
    };
    for entry in entries.flatten() {
        let family_dir = entry.path();
        if !family_dir.is_dir() {
            continue;
        }
        for phase in ["extracted", "resolved"] {
            let path = family_dir.join(format!("{phase}.kdl"));
            if let Ok(meta) = std::fs::metadata(&path) {
                files.push((meta.len(), path));
            }
        }
    }
    files.sort_by_key(|(size, _)| *size);
    files.into_iter().map(|(_, path)| path).collect()
}

/// Walk up from `start` to find the repository root — the ancestor that holds all
/// four domain directories (`semantic`, `platforms`, `targets`, `schemas`). Lets
/// `apianyware-validate` be run from any subdirectory, not just the repo root.
/// `None` if no ancestor qualifies.
pub fn find_repo_root(start: &Path) -> Option<PathBuf> {
    start
        .ancestors()
        .find(|dir| {
            ["semantic", "platforms", "targets", "schemas"]
                .iter()
                .all(|d| dir.join(d).is_dir())
        })
        .map(Path::to_path_buf)
}

/// Repo-relative, `/`-joined path (for stable reporting + component matching).
fn rel_path(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .components()
        .map(|c| c.as_os_str().to_string_lossy())
        .collect::<Vec<_>>()
        .join("/")
}

/// Is this an authored `.apiw` file?
fn is_apiw(path: &Path) -> bool {
    path.extension().is_some_and(|e| e == "apiw")
}

/// Recursively collect files under `root` matching `keep`, skipping build/VCS/grove
/// directories and `tests/**/fixtures/` (crate test fixtures are not authored
/// artifacts — e.g. `spec-format`'s deliberately-`invalid.apiw`). Dot-directories
/// (`.git`, `.grove`, `.grove-worktrees`) and `target` (the build tree) are pruned.
fn walk(root: &Path, keep: fn(&Path) -> bool) -> Vec<PathBuf> {
    let mut out = Vec::new();
    walk_into(root, keep, &mut out);
    out
}

fn walk_into(dir: &Path, keep: fn(&Path) -> bool, out: &mut Vec<PathBuf>) {
    let Ok(entries) = std::fs::read_dir(dir) else {
        return;
    };
    for entry in entries.flatten() {
        let path = entry.path();
        let name = entry.file_name();
        let name = name.to_string_lossy();
        if path.is_dir() {
            let pruned = name == "target" || name == "fixtures" || name.starts_with('.');
            if !pruned {
                walk_into(&path, keep, out);
            }
        } else if keep(&path) {
            out.push(path);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Exactly one class matches each real authored layout — the dispatch table is
    /// a total, disjoint cover of the artifact tree (guards against a rule being
    /// dropped or two rules overlapping).
    #[test]
    fn each_authored_layout_maps_to_exactly_one_class() {
        let classes = classes();
        let layouts = [
            "platforms/macos/api/Foundation/annotations.apiw",
            "platforms/macos/platform.apiw",
            "platforms/macos/app-kinds/gui-app/kind.apiw",
            "platforms/macos/tests/api-semantics/ownership.apiw",
            "platforms/macos/tests/app-kinds/gui-app.apiw",
            "semantic/pattern-kinds/delegate.apiw",
            "targets/racket/target.apiw",
            "targets/racket/capability.apiw",
            "targets/racket/idioms/catalogue.apiw",
            "targets/racket/policies/macos/projection.apiw",
            "targets/racket/adapters/macos/spec.apiw",
            "targets/racket/conformance/macos.apiw",
        ];
        for layout in layouts {
            let components: Vec<&str> = layout.split('/').collect();
            let n = classes.iter().filter(|c| (c.matches)(&components)).count();
            assert_eq!(n, 1, "`{layout}` must match exactly one class, matched {n}");
        }
    }

    /// A `.apiw` in no known layout is unclassified (the coverage guard), and a
    /// crate test fixture must never be surfaced (it is pruned by the walk, but the
    /// matcher must also decline it defensively).
    #[test]
    fn stray_apiw_is_unclassified() {
        let classes = classes();
        for stray in [
            "semantic/tools/spec-format/tests/fixtures/invalid.apiw",
            "targets/racket/something-new.apiw",
            "docs/example.apiw",
        ] {
            let components: Vec<&str> = stray.split('/').collect();
            assert!(
                classes.iter().all(|c| !(c.matches)(&components)),
                "`{stray}` must match no class"
            );
        }
    }

    #[test]
    fn is_apiw_only_matches_apiw() {
        assert!(is_apiw(Path::new("a/b/x.apiw")));
        assert!(!is_apiw(Path::new("a/b/x.kdl")));
        assert!(!is_apiw(Path::new("a/b/x.apiw.bak")));
        assert!(!is_apiw(Path::new("a/b/apiw")));
    }
}
