//! Vendor the Homebrew dylibs an app exe transitively links into the bundle
//! and rewrite every Homebrew load command to an `@executable_path`
//! relative path — the *only* self-containment gap for a gerbil `.app`
//! (spec §7, grove leaf 070/020).
//!
//! `gxc -exe` links the Gerbil stdlib, which pulls in openssl@3
//! (`/opt/homebrew/opt/openssl@3/lib/libssl.3.dylib` and `libcrypto`). Those
//! are the only non-system, non-framework dependencies. After relocation,
//! `otool -L` on the bundled exe shows only `/usr/lib/*`, system frameworks,
//! and `@executable_path/../Frameworks/*`.
//!
//! The rewrite reads each Mach-O's **actual** `otool -L` output rather than
//! assuming paths: `libssl` references `libcrypto` by its *Cellar* path
//! (`…/Cellar/openssl@3/<ver>/lib/…`) while the exe references it by the
//! *opt* symlink path (`…/opt/openssl@3/…`). `install_name_tool -change`
//! needs the exact existing string, so every `/opt/homebrew/*` load command
//! is rewritten in place, keyed by basename.

use std::collections::BTreeMap;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_macos_stub_launcher::codesign_path;

use crate::bundle::BundleError;

/// The Homebrew prefix every vendored dependency lives under.
const HOMEBREW_PREFIX: &str = "/opt/homebrew/";

/// The Swift-native trampoline dylib's basename (ADR-0029). Built by
/// `swift build` from the `APIAnywareGerbil` SwiftPM target; the gerbil app exe
/// links it (`-lAPIAnywareGerbil`), so it appears in the exe's `otool -L` under
/// its `@rpath/libAPIAnywareGerbil.dylib` install name — matched by basename
/// (there is no on-disk path in the load command to key on, unlike Homebrew).
pub const SWIFT_DYLIB_NAME: &str = "libAPIAnywareGerbil.dylib";

/// The bundle subdirectory (under `Contents/`) vendored dylibs are copied
/// into. `@executable_path` is `Contents/MacOS/`, so a sibling reference is
/// `@executable_path/../Frameworks/<name>`.
pub const FRAMEWORKS_SUBDIR: &str = "Frameworks";

/// Parse `otool -L` output into the list of dependency load-command paths
/// that live under the Homebrew prefix. The first (header) line — the binary's
/// own path — is not indented and is skipped; dependency lines are tab-indented
/// `<path> (compatibility version …)`.
pub fn homebrew_deps_of(otool_output: &str) -> Vec<String> {
    otool_output
        .lines()
        .filter(|line| line.starts_with([' ', '\t']))
        .filter_map(|line| {
            let trimmed = line.trim();
            let path = trimmed.split(" (").next().unwrap_or(trimmed);
            path.starts_with(HOMEBREW_PREFIX).then(|| path.to_string())
        })
        .collect()
}

/// The `@executable_path`-relative install name a Homebrew load command at
/// `old_path` is rewritten to: `@executable_path/../<FRAMEWORKS_SUBDIR>/<base>`.
pub fn relocated_install_name(old_path: &str) -> String {
    let base = Path::new(old_path)
        .file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_else(|| old_path.to_string());
    format!("@executable_path/../{FRAMEWORKS_SUBDIR}/{base}")
}

/// Vendor every Homebrew dylib `exe` transitively depends on into
/// `frameworks_dir`, rewrite all Homebrew load commands (in the exe and the
/// vendored dylibs) to `@executable_path/../Frameworks/<name>`, and re-sign
/// each vendored dylib. The exe itself is re-signed by the caller when the
/// whole bundle is signed (after its load commands were rewritten).
///
/// Returns the vendored dylib paths (for logging).
pub fn relocate_homebrew_deps(
    exe: &Path,
    frameworks_dir: &Path,
    identity: &str,
) -> Result<Vec<PathBuf>, BundleError> {
    // 1. Transitively discover the Homebrew dylib *files* reachable from the
    //    exe, keyed by basename (the vendoring identity). libssl's libcrypto
    //    edge and the exe's libcrypto edge collapse to one file here.
    let mut to_vendor: BTreeMap<String, PathBuf> = BTreeMap::new();
    let mut queue: Vec<PathBuf> = homebrew_deps_of(&otool_l(exe)?)
        .into_iter()
        .map(PathBuf::from)
        .collect();
    while let Some(dep) = queue.pop() {
        let base = match dep.file_name() {
            Some(n) => n.to_string_lossy().into_owned(),
            None => continue,
        };
        if to_vendor.contains_key(&base) {
            continue;
        }
        if !dep.exists() {
            return Err(BundleError::DylibSourceMissing(dep));
        }
        to_vendor.insert(base, dep.clone());
        // Chase this dylib's own Homebrew deps (libssl → libcrypto).
        for next in homebrew_deps_of(&otool_l(&dep)?) {
            queue.push(PathBuf::from(next));
        }
    }

    // 2. Copy each into the bundle, made writable so install_name_tool can
    //    edit it (Homebrew dylibs ship 0444).
    fs::create_dir_all(frameworks_dir)?;
    let mut vendored = Vec::new();
    for (base, src) in &to_vendor {
        let dst = frameworks_dir.join(base);
        fs::copy(src, &dst)?;
        let mut perms = fs::metadata(&dst)?.permissions();
        perms.set_mode(0o644);
        fs::set_permissions(&dst, perms)?;
        vendored.push(dst);
    }

    // 3. Rewrite load commands. The exe gets every Homebrew dep -change'd;
    //    each vendored dylib gets its own -id reset plus its Homebrew deps
    //    -change'd. Old paths are read from each binary's live otool -L so
    //    the exact load-command strings match (opt vs Cellar).
    rewrite_changes(exe)?;
    for dylib in &vendored {
        let base = dylib.file_name().unwrap().to_string_lossy().into_owned();
        run_install_name_tool(
            dylib,
            &[
                "-id".to_string(),
                format!("@executable_path/../{FRAMEWORKS_SUBDIR}/{base}"),
            ],
        )?;
        rewrite_changes(dylib)?;
        // install_name_tool invalidated the signature — re-sign the dylib.
        codesign_path(dylib, identity)?;
    }

    Ok(vendored)
}

/// Find the exe's load-command string that references the Swift trampoline
/// dylib, matched by `dylib_name` basename. Returns `None` when the exe does
/// not link it (every current sample app — relocation is then a no-op).
///
/// Unlike [`homebrew_deps_of`], this cannot key on a path prefix: the dylib is
/// recorded by its `@rpath/<name>` install name, which carries no filesystem
/// path. The header line (the binary's own path, unindented) is skipped so a
/// dylib bundled under its own name never matches itself.
pub fn swift_dylib_load_command(otool_output: &str, dylib_name: &str) -> Option<String> {
    otool_output
        .lines()
        .filter(|line| line.starts_with([' ', '\t']))
        .find_map(|line| {
            let trimmed = line.trim();
            let path = trimmed.split(" (").next().unwrap_or(trimmed);
            let is_match = Path::new(path)
                .file_name()
                .map(|n| n.to_string_lossy())
                .as_deref()
                == Some(dylib_name);
            is_match.then(|| path.to_string())
        })
}

/// Vendor the built Swift trampoline dylib at `dylib_src` into `frameworks_dir`
/// and rewrite `exe`'s `@rpath/<name>` load command to
/// `@executable_path/../Frameworks/<name>` — the gerbil counterpart to
/// [`relocate_homebrew_deps`] for the one dylib that is *linked* rather than
/// dlopen'd (ADR-0029 §3: self-containment via the existing relocation path, no
/// new mechanism). The vendored dylib's own `-id` is reset to the same relative
/// install name and it is re-signed.
///
/// A no-op (returns `Ok(None)`) when the exe does not link the dylib — so it is
/// safe to call unconditionally for apps with no Swift-native trampoline. When
/// it *does* link it, `dylib_src` must exist (the `swift build` artifact).
///
/// The exe itself is re-signed by the caller when the whole bundle is signed
/// (after this rewrote its load command), exactly as [`relocate_homebrew_deps`].
pub fn relocate_swift_dylib(
    exe: &Path,
    dylib_src: &Path,
    frameworks_dir: &Path,
    identity: &str,
) -> Result<Option<PathBuf>, BundleError> {
    let base = dylib_src
        .file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_else(|| SWIFT_DYLIB_NAME.to_string());

    // Only act if the exe actually links the dylib.
    let old = match swift_dylib_load_command(&otool_l(exe)?, &base) {
        Some(old) => old,
        None => return Ok(None),
    };
    if !dylib_src.exists() {
        return Err(BundleError::DylibSourceMissing(dylib_src.to_path_buf()));
    }

    // Copy into the bundle, made writable so install_name_tool can edit it
    // (the .build dylib may ship read-only).
    fs::create_dir_all(frameworks_dir)?;
    let dst = frameworks_dir.join(&base);
    fs::copy(dylib_src, &dst)?;
    let mut perms = fs::metadata(&dst)?.permissions();
    perms.set_mode(0o644);
    fs::set_permissions(&dst, perms)?;

    // Reset the vendored dylib's own install name, then re-sign it
    // (install_name_tool invalidated the signature).
    let new_name = relocated_install_name(&base);
    run_install_name_tool(&dst, &["-id".to_string(), new_name.clone()])?;
    codesign_path(&dst, identity)?;

    // Rewrite the exe's @rpath load command to point at the vendored copy.
    run_install_name_tool(exe, &["-change".to_string(), old, new_name])?;

    Ok(Some(dst))
}

/// Rewrite every Homebrew load command in `binary` to its
/// `@executable_path` relative form, one `install_name_tool -change` per dep.
fn rewrite_changes(binary: &Path) -> Result<(), BundleError> {
    let deps = homebrew_deps_of(&otool_l(binary)?);
    if deps.is_empty() {
        return Ok(());
    }
    let mut args = Vec::new();
    for old in &deps {
        args.push("-change".to_string());
        args.push(old.clone());
        args.push(relocated_install_name(old));
    }
    run_install_name_tool(binary, &args)
}

/// `otool -L <path>`.
fn otool_l(path: &Path) -> Result<String, BundleError> {
    let out = Command::new("otool")
        .arg("-L")
        .arg(path)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable {
            tool: "otool",
            source,
        })?;
    if !out.status.success() {
        return Err(BundleError::OtoolFailed {
            path: path.to_path_buf(),
            stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
        });
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// `install_name_tool <args> <path>`.
fn run_install_name_tool(path: &Path, args: &[String]) -> Result<(), BundleError> {
    let out = Command::new("install_name_tool")
        .args(args)
        .arg(path)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable {
            tool: "install_name_tool",
            source,
        })?;
    if !out.status.success() {
        return Err(BundleError::InstallNameToolFailed {
            path: path.to_path_buf(),
            stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
        });
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Real `otool -L` output for the hello-window exe (070/020).
    const HELLO_OTOOL: &str = "\
generation/targets/gerbil/apps/hello-window/build/hello-window:
\t/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
\t/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit (compatibility version 45.0.0, current version 2685.60.104)
\t/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation (compatibility version 300.0.0, current version 5026.5.4)
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1356.0.0)
\t/usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.12)
\t/opt/homebrew/opt/openssl@3/lib/libssl.3.dylib (compatibility version 3.0.0, current version 3.0.0)
\t/opt/homebrew/opt/openssl@3/lib/libcrypto.3.dylib (compatibility version 3.0.0, current version 3.0.0)
\t/usr/lib/libsqlite3.dylib (compatibility version 9.0.0, current version 382.0.0)
";

    #[test]
    fn homebrew_deps_extracts_only_homebrew_paths() {
        assert_eq!(
            homebrew_deps_of(HELLO_OTOOL),
            vec![
                "/opt/homebrew/opt/openssl@3/lib/libssl.3.dylib",
                "/opt/homebrew/opt/openssl@3/lib/libcrypto.3.dylib",
            ]
        );
    }

    #[test]
    fn homebrew_deps_skips_the_header_line() {
        // The unindented first line is the binary's own path, never a dep —
        // even if it were under /opt/homebrew it would be skipped.
        let out = "/opt/homebrew/x/bin/thing:\n\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0)\n";
        assert!(homebrew_deps_of(out).is_empty());
    }

    #[test]
    fn homebrew_deps_handles_cellar_path() {
        // libssl references libcrypto by its Cellar path, not the opt symlink.
        let out = "\
/path/in/bundle/libssl.3.dylib:
\t@executable_path/../Frameworks/libssl.3.dylib (compatibility version 3.0.0)
\t/opt/homebrew/Cellar/openssl@3/3.6.2/lib/libcrypto.3.dylib (compatibility version 3.0.0)
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0)
";
        assert_eq!(
            homebrew_deps_of(out),
            vec!["/opt/homebrew/Cellar/openssl@3/3.6.2/lib/libcrypto.3.dylib"]
        );
    }

    #[test]
    fn relocated_name_is_executable_path_relative() {
        assert_eq!(
            relocated_install_name("/opt/homebrew/opt/openssl@3/lib/libssl.3.dylib"),
            "@executable_path/../Frameworks/libssl.3.dylib"
        );
        // Cellar path collapses to the same basename → same target as the
        // opt path, so the exe and libssl agree on libcrypto's new location.
        assert_eq!(
            relocated_install_name("/opt/homebrew/Cellar/openssl@3/3.6.2/lib/libcrypto.3.dylib"),
            "@executable_path/../Frameworks/libcrypto.3.dylib"
        );
        // The Swift trampoline dylib is referenced by its @rpath install name,
        // not a filesystem path — relocation keys on the basename all the same.
        assert_eq!(
            relocated_install_name("@rpath/libAPIAnywareGerbil.dylib"),
            "@executable_path/../Frameworks/libAPIAnywareGerbil.dylib"
        );
    }

    /// Real `otool -L` of the leaf-070/010 probe exe: the Swift dylib is the
    /// `@rpath` line, openssl is the Homebrew lines, everything else is system.
    const PROBE_OTOOL: &str = "\
/tmp/gerbil-swift-probe.XXX/probe-smoke:
\t@rpath/libAPIAnywareGerbil.dylib (compatibility version 0.0.0, current version 0.0.0)
\t/opt/homebrew/opt/openssl@3/lib/libssl.3.dylib (compatibility version 3.0.0, current version 3.0.0)
\t/opt/homebrew/opt/openssl@3/lib/libcrypto.3.dylib (compatibility version 3.0.0, current version 3.0.0)
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1356.0.0)
";

    #[test]
    fn swift_dylib_load_command_matches_by_basename() {
        // The exe records the dylib by its @rpath install name, so we match on
        // basename rather than a path prefix (there is no on-disk path here).
        assert_eq!(
            swift_dylib_load_command(PROBE_OTOOL, SWIFT_DYLIB_NAME).as_deref(),
            Some("@rpath/libAPIAnywareGerbil.dylib")
        );
    }

    #[test]
    fn swift_dylib_load_command_absent_when_not_linked() {
        // An app that links no Swift trampoline (every current sample app today)
        // has no such load command — relocation must be a clean no-op for it.
        let no_swift = "\
/path/exe:
\t/opt/homebrew/opt/openssl@3/lib/libssl.3.dylib (compatibility version 3.0.0)
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0)
";
        assert_eq!(swift_dylib_load_command(no_swift, SWIFT_DYLIB_NAME), None);
    }

    #[test]
    fn swift_dylib_load_command_skips_header_line() {
        // The unindented first line is the binary's own path; even if its
        // basename matched it is not a dependency load command.
        let out = "/build/libAPIAnywareGerbil.dylib:\n\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0)\n";
        assert_eq!(swift_dylib_load_command(out, SWIFT_DYLIB_NAME), None);
    }
}
