//! Validate a [`PatternInstance`] against the authored kind registry, and resolve
//! its DP3 home (ADR-0048, workstream-3 child 2).
//!
//! The *instance* model and its two determinism rules (DP4 identity, DP3 home
//! mechanism) live in `apianyware-types` — they need no registry. The checks
//! here are the ones that *do* need the authored kinds: an instance references a
//! real kind, binds only declared roles (with the declared cardinality), and each
//! participant matches its role's `binds` (ADR-0048 D5). The home *rule* is in
//! types; this module supplies the kind-aware input — which role is the kind's
//! designated primary.

use apianyware_types::pattern_instance::{Participant, PatternInstance};

use crate::kind::{Cardinality, Role, RoleBinds};
use crate::registry::PatternKindRegistry;

/// Why a pattern-instance is not a valid instance of its kind.
#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
pub enum InstanceError {
    /// The instance's `kind` is not in the registry.
    #[error("instance references unknown pattern-kind `{0}`")]
    UnknownKind(String),

    /// The instance binds a role the kind does not declare.
    #[error("instance of `{kind}` binds undeclared role `{role}`")]
    UnknownRole {
        /// The instantiated kind.
        kind: String,
        /// The undeclared role name.
        role: String,
    },

    /// A role's participant count violates its declared cardinality (this covers
    /// a missing required role — zero participants where `1`/`+` is required).
    #[error(
        "role `{role}` of `{kind}` requires {expected} participant(s) but {actual} were bound"
    )]
    Cardinality {
        /// The instantiated kind.
        kind: String,
        /// The role whose cardinality is violated.
        role: String,
        /// The declared cardinality, as its `.apiw` token.
        expected: String,
        /// How many participants were actually bound.
        actual: usize,
    },

    /// A participant's variant does not match the role's declared `binds`.
    #[error(
        "role `{role}` of `{kind}` binds `{expected}`, but a `{actual}` participant was given"
    )]
    Binds {
        /// The instantiated kind.
        kind: String,
        /// The role whose binding is violated.
        role: String,
        /// The declared participant kind (`type`/`operation`/`parameter`/`pattern`).
        expected: String,
        /// The participant kind actually given.
        actual: String,
    },
}

impl PatternKindRegistry {
    /// Validate `instance` against this registry: the kind exists, every bound
    /// role is declared, every declared role's participant count respects its
    /// cardinality, and each participant matches the role's `binds` (D5).
    pub fn validate_instance(&self, instance: &PatternInstance) -> Result<(), InstanceError> {
        let kind = self
            .get(&instance.kind)
            .ok_or_else(|| InstanceError::UnknownKind(instance.kind.clone()))?;

        // No role outside the kind's declared set.
        for role_name in instance.roles.keys() {
            if kind.role(role_name).is_none() {
                return Err(InstanceError::UnknownRole {
                    kind: instance.kind.clone(),
                    role: role_name.clone(),
                });
            }
        }

        // Each declared role: cardinality + per-participant binds.
        for role in &kind.roles {
            let bound = instance
                .roles
                .get(&role.name)
                .map(Vec::as_slice)
                .unwrap_or(&[]);
            if !cardinality_admits(role.cardinality, bound.len()) {
                return Err(InstanceError::Cardinality {
                    kind: instance.kind.clone(),
                    role: role.name.clone(),
                    expected: cardinality_token(role.cardinality).to_string(),
                    actual: bound.len(),
                });
            }
            for participant in bound {
                if !binds_admits(role.binds, participant) {
                    return Err(InstanceError::Binds {
                        kind: instance.kind.clone(),
                        role: role.name.clone(),
                        expected: role_binds_token(role.binds).to_string(),
                        actual: participant_token(participant).to_string(),
                    });
                }
            }
        }

        Ok(())
    }

    /// The DP3 home framework of `instance` against this registry: resolves the
    /// kind's designated primary role (if any), then applies the home rule
    /// (`PatternInstance::home_framework`). Unknown kinds fall back to the
    /// no-primary rule (home from all participants).
    pub fn instance_home(&self, instance: &PatternInstance) -> Option<String> {
        let primary = self.get(&instance.kind).and_then(primary_role_name);
        PatternInstance::home_framework(&instance.roles, primary)
    }
}

/// Whether a role with cardinality `card` admits exactly `n` bound participants.
fn cardinality_admits(card: Cardinality, n: usize) -> bool {
    match card {
        Cardinality::One => n == 1,
        Cardinality::Optional => n <= 1,
        Cardinality::Many => true,
        Cardinality::AtLeastOne => n >= 1,
    }
}

/// The `.apiw` token for a cardinality (for diagnostics).
fn cardinality_token(card: Cardinality) -> &'static str {
    match card {
        Cardinality::One => "1",
        Cardinality::Optional => "?",
        Cardinality::Many => "*",
        Cardinality::AtLeastOne => "+",
    }
}

/// Whether a participant satisfies a role's declared `binds`.
fn binds_admits(binds: RoleBinds, participant: &Participant) -> bool {
    matches!(
        (binds, participant),
        (RoleBinds::Type, Participant::Type { .. })
            | (RoleBinds::Operation, Participant::Operation { .. })
            | (RoleBinds::Parameter, Participant::Parameter { .. })
            | (RoleBinds::Pattern, Participant::Pattern { .. })
    )
}

/// The `binds` token a role declares (for diagnostics).
fn role_binds_token(binds: RoleBinds) -> &'static str {
    match binds {
        RoleBinds::Type => "type",
        RoleBinds::Operation => "operation",
        RoleBinds::Parameter => "parameter",
        RoleBinds::Pattern => "pattern",
    }
}

/// The participant-kind token a participant carries (for diagnostics).
fn participant_token(p: &Participant) -> &'static str {
    match p {
        Participant::Type { .. } => "type",
        Participant::Operation { .. } => "operation",
        Participant::Parameter { .. } => "parameter",
        Participant::Pattern { .. } => "pattern",
    }
}

/// The name of a kind's designated primary role, if it declares one.
fn primary_role_name(kind: &crate::kind::PatternKind) -> Option<&str> {
    kind.roles
        .iter()
        .find(|r: &&Role| r.primary)
        .map(|r| r.name.as_str())
}

#[cfg(test)]
mod tests {
    use std::collections::BTreeMap;
    use std::path::PathBuf;

    use apianyware_types::pattern_instance::{InstanceSource, Participant, PatternInstance};

    use super::*;

    /// Load the authored `semantic/pattern-kinds/` registry (the real kinds).
    fn registry() -> PatternKindRegistry {
        let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("../../pattern-kinds")
            .canonicalize()
            .expect("semantic/pattern-kinds/ resolves");
        PatternKindRegistry::load_dir(&dir).expect("authored kinds load")
    }

    fn op(framework: &str, selector: &str) -> Participant {
        Participant::Operation {
            framework: Some(framework.to_string()),
            class: None,
            selector: selector.to_string(),
        }
    }

    fn ty(framework: &str, name: &str) -> Participant {
        Participant::Type {
            framework: Some(framework.to_string()),
            name: name.to_string(),
        }
    }

    fn instance(kind: &str, roles: &[(&str, Vec<Participant>)]) -> PatternInstance {
        let roles: BTreeMap<String, Vec<Participant>> = roles
            .iter()
            .map(|(n, ps)| (n.to_string(), ps.clone()))
            .collect();
        PatternInstance {
            id: PatternInstance::compute_id(kind, &roles),
            kind: kind.to_string(),
            home: String::new(),
            roles,
            source: InstanceSource::Convention,
            confidence: None,
            provenance: None,
        }
    }

    #[test]
    fn valid_bracket_instance_passes() {
        let inst = instance(
            "bracket",
            &[
                ("acquire", vec![op("CoreGraphics", "CGPathCreateMutable")]),
                ("operation", vec![op("CoreGraphics", "CGPathAddRect")]),
                ("release", vec![op("CoreGraphics", "CGPathRelease")]),
            ],
        );
        assert_eq!(registry().validate_instance(&inst), Ok(()));
    }

    #[test]
    fn unknown_kind_is_rejected() {
        let inst = instance("not-a-kind", &[("r", vec![ty("F", "T")])]);
        assert_eq!(
            registry().validate_instance(&inst),
            Err(InstanceError::UnknownKind("not-a-kind".to_string()))
        );
    }

    #[test]
    fn undeclared_role_is_rejected() {
        let inst = instance(
            "parent-child",
            &[
                ("parent", vec![ty("AppKit", "NSView")]),
                ("child", vec![ty("AppKit", "NSButton")]),
                ("sibling", vec![ty("AppKit", "NSLabel")]),
            ],
        );
        assert_eq!(
            registry().validate_instance(&inst),
            Err(InstanceError::UnknownRole {
                kind: "parent-child".to_string(),
                role: "sibling".to_string(),
            })
        );
    }

    #[test]
    fn missing_required_role_is_rejected_as_cardinality() {
        // parent-child requires both `parent` (1) and `child` (1).
        let inst = instance("parent-child", &[("parent", vec![ty("AppKit", "NSView")])]);
        assert_eq!(
            registry().validate_instance(&inst),
            Err(InstanceError::Cardinality {
                kind: "parent-child".to_string(),
                role: "child".to_string(),
                expected: "1".to_string(),
                actual: 0,
            })
        );
    }

    #[test]
    fn too_many_for_cardinality_one_is_rejected() {
        // `acquire` is cardinality 1 — two participants violate it.
        let inst = instance(
            "bracket",
            &[
                ("acquire", vec![op("F", "openA"), op("F", "openB")]),
                ("release", vec![op("F", "close")]),
            ],
        );
        assert_eq!(
            registry().validate_instance(&inst),
            Err(InstanceError::Cardinality {
                kind: "bracket".to_string(),
                role: "acquire".to_string(),
                expected: "1".to_string(),
                actual: 2,
            })
        );
    }

    #[test]
    fn wrong_participant_kind_is_rejected() {
        // bracket's `acquire` binds an operation; a type participant is wrong.
        let inst = instance(
            "bracket",
            &[
                ("acquire", vec![ty("F", "SomeType")]),
                ("release", vec![op("F", "close")]),
            ],
        );
        assert_eq!(
            registry().validate_instance(&inst),
            Err(InstanceError::Binds {
                kind: "bracket".to_string(),
                role: "acquire".to_string(),
                expected: "operation".to_string(),
                actual: "type".to_string(),
            })
        );
    }

    #[test]
    fn optional_and_many_roles_admit_zero() {
        // bracket's `operation` is `*` (zero allowed); acquire+release present.
        let inst = instance(
            "bracket",
            &[
                ("acquire", vec![op("F", "open")]),
                ("release", vec![op("F", "close")]),
            ],
        );
        assert_eq!(registry().validate_instance(&inst), Ok(()));
    }

    #[test]
    fn home_is_the_primary_role_framework_cross_framework() {
        // parent-child's `parent` is primary: an AppKit NSView parenting a
        // CoreAudio type homes to AppKit (DP3).
        let inst = instance(
            "parent-child",
            &[
                ("parent", vec![ty("AppKit", "NSView")]),
                ("child", vec![ty("CoreAudio", "AUNode")]),
            ],
        );
        assert_eq!(registry().instance_home(&inst).as_deref(), Some("AppKit"));
    }

    #[test]
    fn home_falls_back_to_all_participants_when_kind_has_no_primary() {
        // bracket declares no primary role → home is the smallest framework name.
        let inst = instance(
            "bracket",
            &[
                ("acquire", vec![op("Zoo", "open")]),
                ("release", vec![op("AppKit", "close")]),
            ],
        );
        assert_eq!(registry().instance_home(&inst).as_deref(), Some("AppKit"));
    }
}
