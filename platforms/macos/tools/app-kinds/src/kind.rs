//! The typed app-kind model (node-brief D2): the authored, projection-free
//! definition of one *kind* of macOS application.
//!
//! An [`AppKind`] is a [`ProcessModel`] (entry / run-loop / termination), an
//! [`ActivationPolicy`] (how it presents to the window server), a [`BundleModel`]
//! (the on-disk container + required Info.plist keys), and a set of test-obligation
//! references. The controlled vocabularies are *flat* enums — unlike a pattern
//! law's category-conditional token set — so they live directly here as serde
//! enums *and* as `enum` constraints in `app-kind.kdl-schema` (exactly like the
//! platform manifest's `DiscoverSource`); no separate side-table vocabulary is
//! warranted.
//!
//! This is platform TRUTH only. Nothing here states how any target language builds
//! a kind (that is `targets/`, workstream 6 — the domain rule). The serde
//! `kebab-case` spelling of each enum variant IS its `.apiw` token, the single
//! source of truth.

use serde::{Deserialize, Serialize};

/// One authored kind of macOS application (`app-kinds/<name>/kind.apiw`).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct AppKind {
    /// The kind's stable identity (matches its containing directory, e.g.
    /// `"gui-app"`).
    pub name: String,
    /// Optional one-line human description.
    pub doc: Option<String>,
    /// How a program of this kind starts, runs, and stops.
    pub process: ProcessModel,
    /// How it presents to the window server.
    pub activation: ActivationPolicy,
    /// The on-disk container it produces (or [`BundleType::None`]).
    pub bundle: BundleModel,
    /// Forward references to platform-level test obligations (the bodies are
    /// authored later in `tests/app-kinds/<name>.apiw`, workstream 4 child 3). In
    /// declared order; refs are unique.
    pub test_obligations: Vec<String>,
}

impl AppKind {
    /// Whether this kind runs inside a host process rather than as a standalone
    /// program — the `host-loaded` / `host-driven` / `host-controlled` /
    /// `hosted` / `mdimporter` / `appex` family. Extensions and importers are
    /// hosted; standalone apps and tools are not.
    pub fn is_hosted(&self) -> bool {
        matches!(
            self.bundle.bundle_type,
            BundleType::Mdimporter | BundleType::Appex
        )
    }
}

/// The process model — how a program of this kind starts, runs, and stops.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct ProcessModel {
    /// What runs first.
    pub entry: EntryModel,
    /// What drives the main loop.
    pub run_loop: RunLoopModel,
    /// How it ends.
    pub termination: TerminationModel,
}

/// The entry-point model — what runs first.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum EntryModel {
    /// A C `main()` the program owns.
    CMain,
    /// `NSApplicationMain()` / the `NSApp` bootstrap.
    NsApplicationMain,
    /// No own entry point; a host process loads the bundle's principal class.
    HostLoaded,
}

/// The run-loop model — what drives the main loop.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum RunLoopModel {
    /// Runs to completion and returns (a batch tool).
    None,
    /// `[NSApp run]` — the AppKit main loop.
    NsApplication,
    /// A manual `CFRunLoop` / `dispatch_main()` (a daemon servicing events
    /// without AppKit).
    CfRunLoop,
    /// The host process owns the run loop.
    HostDriven,
}

/// The termination model — how it ends.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum TerminationModel {
    /// `main` returns / `exit()`.
    Return,
    /// `-[NSApplication terminate:]` / Quit.
    NsApplicationTerminate,
    /// Terminated by signal (SIGTERM from launchd).
    Signal,
    /// The host unloads the bundle.
    HostControlled,
}

/// The window-server activation policy — how the program presents.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum ActivationPolicy {
    /// A normal app: Dock icon + menu bar.
    Regular,
    /// `LSUIElement`: no Dock icon, menu-bar / status-item only.
    Accessory,
    /// `LSBackgroundOnly`: no GUI session at all (a daemon).
    Background,
    /// No activation policy of its own; runs inside a host.
    Hosted,
}

/// The on-disk bundle the kind produces, plus its bundle metadata.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct BundleModel {
    /// The container kind.
    pub bundle_type: BundleType,
    /// `CFBundlePackageType` (a 4-char OSType, e.g. `"APPL"`), if the kind fixes
    /// one.
    pub package_type: Option<String>,
    /// The Info.plist key naming the bundle's principal class (e.g.
    /// `"NSPrincipalClass"`), if any.
    pub principal_class_key: Option<String>,
    /// The `NSExtensionPointIdentifier` the bundle plugs into (e.g.
    /// `"com.apple.FinderSync"`), if it is a hosted extension. Only meaningful for
    /// [`BundleType::Mdimporter`] / [`BundleType::Appex`].
    pub extension_point: Option<String>,
    /// The Info.plist keys this kind requires, in declared order (unique; empty
    /// for a bare executable).
    pub required_plist_keys: Vec<String>,
}

/// The on-disk container a kind produces.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum BundleType {
    /// A bare Mach-O executable (no `.app`, no Info.plist).
    None,
    /// A `.app` bundle.
    App,
    /// A `.mdimporter` Spotlight-importer bundle.
    Mdimporter,
    /// A `.appex` app-extension bundle.
    Appex,
}
