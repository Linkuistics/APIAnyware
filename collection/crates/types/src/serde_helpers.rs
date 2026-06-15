//! Serde helper functions for checkpoint deserialization.

use serde::{Deserialize, Deserializer, Serialize, Serializer};

/// Deserialize a `Vec<T>` that may be `null` in JSON.
///
/// Go emits `null` for nil slices, so we normalize to an empty Vec.
/// On serialization, always writes an array (never null).
pub fn null_as_empty_vec<'de, D, T>(deserializer: D) -> Result<Vec<T>, D::Error>
where
    D: Deserializer<'de>,
    T: Deserialize<'de>,
{
    Option::<Vec<T>>::deserialize(deserializer).map(|opt| opt.unwrap_or_default())
}

/// Default value for the `objc_exposed` IR field: `true`, the fully-elided
/// ObjC limit. Used as `#[serde(default = "...")]` so checkpoints written
/// before the field existed deserialize as ObjC-exposed.
pub fn default_true() -> bool {
    true
}

/// `skip_serializing_if` predicate for the `objc_exposed` IR field: omit it
/// from JSON when `true` so the golden diff audits exactly the trampoline
/// residual (the `false` cases).
pub fn is_true(b: &bool) -> bool {
    *b
}

/// Serialize a `Vec<T>` — always writes as an array (matching the deserialize side).
/// This is the default behavior, included for symmetry with `null_as_empty_vec`.
pub fn empty_vec_as_array<S, T>(vec: &Vec<T>, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
    T: Serialize,
{
    vec.serialize(serializer)
}
