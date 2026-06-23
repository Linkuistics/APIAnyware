//! Shared Datalog base relations, fact loaders, and types.
//!
//! This crate defines the fact types and loading utilities used by both
//! the `resolve` crate (Datalog pass 1) and the `enrich` crate (Datalog pass 2).
//! Each of those crates defines its own `ascent!` program with its own rules.

pub mod loading;
pub mod ownership;
