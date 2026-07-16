//! THROWAWAY spike addon (libuv-runloop-primacy-spike-k6).
//!
//! Reaches Node's uv_loop_t* via the stable napi_get_uv_event_loop and hands it to the
//! Swift bridge, which implements the two candidate libuv↔CFRunLoop integration mechanisms
//! of ADR-0056 §2 (helper thread (c) / CFFileDescriptor (b)). Owns the background→main
//! callback bounce via napi_threadsafe_function (§3), reused from the substrate spike probe 3.
//!
//! No emitter, no IR, no build integration — evidence, not a binding.

use napi::bindgen_prelude::*;
use napi::threadsafe_function::{
    ErrorStrategy, ThreadSafeCallContext, ThreadsafeFunction, ThreadsafeFunctionCallMode,
};
use napi_derive::napi;
use std::ffi::CString;
use std::os::raw::{c_char, c_void};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::OnceLock;

// libuv, resolved at load time against the host (Node) via -undefined dynamic_lookup.
extern "C" {
    fn uv_run(loop_: *mut c_void, mode: i32) -> i32;
}
const UV_RUN_NOWAIT: i32 = 2;

// The v8-aware pump (pump_shim.cc): uv_run(NOWAIT) inside HandleScope + Context::Scope, then a
// V8 PerformMicrotaskCheckpoint. napi's public surface exposes neither, so this small C++ shim is
// the crux of making the embedded pump preserve Promise/await/microtask semantics.
extern "C" {
    fn aw_rl_pump_v8(loop_: *mut c_void);
}

// ---- Swift @_cdecl surface (from ../swift/libtsrlbridge.dylib) -------------
extern "C" {
    fn aw_rl_setup_app() -> bool;
    fn aw_rl_run_app(seconds: f64);
    fn aw_rl_start(loop_ptr: u64, mechanism: i32, common_modes: bool, pump: extern "C" fn());
    fn aw_rl_teardown();
    fn aw_rl_run_nested(mode: i32, seconds: f64);
    fn aw_rl_schedule_nested(delay_ms: i32, mode: i32, seconds: f64);
    fn aw_rl_start_pinger(interval_ms: i32);
    fn aw_rl_stop_pinger();
    fn aw_rl_get_stats(out: *mut i64);
    fn aw_rl_nudge();
    fn aw_rl_dispatch_bg(cb: extern "C" fn(u64), token: u64);
    fn aw_rl_start_tsfn_pinger(cb: extern "C" fn(u64), interval_ms: i32);
    fn aw_rl_stop_tsfn_pinger();
    fn aw_rl_has_symbol(name: *const c_char) -> bool;
}

fn uv_loop(env: &Env) -> Result<u64> {
    let mut loop_ptr: *mut napi::sys::uv_loop_s = std::ptr::null_mut();
    let status = unsafe { napi::sys::napi_get_uv_event_loop(env.raw(), &mut loop_ptr) };
    if status != 0 || loop_ptr.is_null() {
        return Err(Error::from_reason("napi_get_uv_event_loop failed"));
    }
    Ok(loop_ptr as u64)
}

// ---- the SCOPED pump ------------------------------------------------------------------------
// The pump body lives in the C++ shim (pump_shim.cc): uv_run(NOWAIT) inside a v8::HandleScope +
// Context::Scope, then a microtask checkpoint. Two things forced this out of the Swift bridge and
// out of napi's public surface (k6 findings A + C):
//   - A bare uv_run(NOWAIT) from a CFRunLoop callback crashes node::Environment::CheckImmediate
//     (v8::ToLocalChecked on an empty MaybeLocal — no HandleScope) the first time JS uses
//     setImmediate. So uv_run must be wrapped in a HandleScope, which napi can open but the shim
//     does more cheaply alongside the checkpoint.
//   - Promise/await/nextTick chains need the V8 microtask checkpoint, which has NO napi equivalent
//     (a napi handle/callback scope does not run it). Hence the small C++ shim resolving V8 symbols
//     against libnode. The pump therefore lives in the addon (Node side), not the Swift bridge —
//     ADR-0056 §Consequences.
static LOOP_RAW: AtomicUsize = AtomicUsize::new(0);

extern "C" fn pump_scoped() {
    let loop_ = LOOP_RAW.load(Ordering::Relaxed) as *mut c_void;
    if loop_.is_null() {
        return;
    }
    unsafe { aw_rl_pump_v8(loop_) };
}

fn init_pump(loop_raw: u64) {
    LOOP_RAW.store(loop_raw as usize, Ordering::Relaxed);
}

// ---- app + mechanism control ----------------------------------------------
#[napi]
pub fn setup_app() -> bool {
    unsafe { aw_rl_setup_app() }
}

#[napi]
pub fn run_app(seconds: f64) {
    unsafe { aw_rl_run_app(seconds) }
}

/// mechanism: 1 = (c) helper thread, 2 = (b) CFFileDescriptor, 3 = 4ms-poll baseline (probe 2c).
/// common_modes: false runs the default-mode-only CONTROL (must fail the nested test).
#[napi]
pub fn start(env: Env, mechanism: i32, common_modes: bool) -> Result<()> {
    let l = uv_loop(&env)?;
    init_pump(l);
    unsafe { aw_rl_start(l, mechanism, common_modes, pump_scoped) };
    Ok(())
}

#[napi]
pub fn teardown() {
    unsafe { aw_rl_teardown() }
}

/// Run a nested runloop in a non-default mode for `seconds` (mode 0 = event-tracking,
/// 1 = modal-panel) — reproduces AppKit's modal/menu/resize nested runloops.
#[napi]
pub fn run_nested(mode: i32, seconds: f64) {
    unsafe { aw_rl_run_nested(mode, seconds) }
}

/// Schedule a nested runloop (mode 0 = event-tracking, 1 = modal) to begin `delay_ms` into
/// NSApp.run(), so it runs while AppKit owns thread 0 (the nested-runloop-survival test).
#[napi]
pub fn schedule_nested(delay_ms: i32, mode: i32, seconds: f64) {
    unsafe { aw_rl_schedule_nested(delay_ms, mode, seconds) }
}

#[napi]
pub fn start_pinger(interval_ms: i32) {
    unsafe { aw_rl_start_pinger(interval_ms) }
}

#[napi]
pub fn stop_pinger() {
    unsafe { aw_rl_stop_pinger() }
}

#[napi]
pub fn nudge() {
    unsafe { aw_rl_nudge() }
}

#[napi(object)]
pub struct Stats {
    pub passes: i64,
    pub fd_fires: i64,
    pub timer_fires: i64,
    pub helper_polls: i64,
    pub source_fires: i64,
    pub timeout_zero_polls: i64,
    pub last_timeout: i64,
    pub nested_start: i64,
    pub nested_end: i64,
}

#[napi]
pub fn get_stats() -> Stats {
    let mut out = [0i64; 9];
    unsafe { aw_rl_get_stats(out.as_mut_ptr()) };
    Stats {
        passes: out[0],
        fd_fires: out[1],
        timer_fires: out[2],
        helper_polls: out[3],
        source_fires: out[4],
        timeout_zero_polls: out[5],
        last_timeout: out[6],
        nested_start: out[7],
        nested_end: out[8],
    }
}

/// Deno leg: probe whether a libuv embedding symbol is present in-process (expected
/// ABSENT on Deno — its napi shim omits uv_backend_fd / uv_backend_timeout / uv_run).
#[napi]
pub fn has_symbol(name: String) -> Result<bool> {
    let c = CString::new(name).map_err(|e| Error::from_reason(e.to_string()))?;
    Ok(unsafe { aw_rl_has_symbol(c.as_ptr()) })
}

// ---- background → main tsfn bounce (reused from substrate spike probe 3) ----
static TSFN: OnceLock<ThreadsafeFunction<i64, ErrorStrategy::Fatal>> = OnceLock::new();

extern "C" fn bg_trampoline(token: u64) {
    if let Some(tsfn) = TSFN.get() {
        tsfn.call(token as i64, ThreadsafeFunctionCallMode::NonBlocking);
    }
}

#[napi]
pub fn register_callback(cb: JsFunction) -> Result<()> {
    let tsfn: ThreadsafeFunction<i64, ErrorStrategy::Fatal> =
        cb.create_threadsafe_function(0, |ctx: ThreadSafeCallContext<i64>| Ok(vec![ctx.value]))?;
    TSFN.set(tsfn)
        .map_err(|_| Error::from_reason("callback already registered"))
}

#[napi]
pub fn fire_bg(token: i64) {
    unsafe { aw_rl_dispatch_bg(bg_trampoline, token as u64) }
}

#[napi]
pub fn start_tsfn_pinger(interval_ms: i32) {
    unsafe { aw_rl_start_tsfn_pinger(bg_trampoline, interval_ms) }
}

#[napi]
pub fn stop_tsfn_pinger() {
    unsafe { aw_rl_stop_tsfn_pinger() }
}
