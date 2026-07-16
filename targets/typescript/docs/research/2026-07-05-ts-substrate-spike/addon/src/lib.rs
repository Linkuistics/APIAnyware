//! THROWAWAY spike addon (ts-substrate-spike-k3).
//!
//! A napi-rs N-API addon that links the Swift bridge dylib and surfaces:
//!   - probe 1: generated-style ObjC dispatch (scalar/id + CGRect struct return)
//!   - probe 2: NSApplication ownership of thread 0 (setup/run/pump)
//!   - probe 3: background-thread callback delivered to JS via napi_threadsafe_function
//!
//! ObjC pointers (id/SEL/Class) cross to JS as BigInt opaque handles.

use napi::bindgen_prelude::*;
use napi::threadsafe_function::{
    ErrorStrategy, ThreadSafeCallContext, ThreadsafeFunction, ThreadsafeFunctionCallMode,
};
use napi_derive::napi;
use std::ffi::CString;
use std::os::raw::c_char;
use std::sync::OnceLock;

// ---- CGRect, repr(C): the arm64 x8 struct-by-value return shape -----------
#[repr(C)]
struct CgPoint {
    x: f64,
    y: f64,
}
#[repr(C)]
struct CgSize {
    width: f64,
    height: f64,
}
#[repr(C)]
struct CgRect {
    origin: CgPoint,
    size: CgSize,
}

// ---- the Swift @_cdecl surface (linked from ../swift/libtsbridge.dylib) ----
extern "C" {
    fn aw_ts_get_class(name: *const c_char) -> u64;
    fn aw_ts_sel(name: *const c_char) -> u64;
    fn aw_ts_msg_id__id_sel(recv: u64, sel: u64) -> u64;
    fn aw_ts_msg_id__id_sel_cstr(recv: u64, sel: u64, cstr: *const c_char) -> u64;
    fn aw_ts_msg_u64__id_sel(recv: u64, sel: u64) -> u64;
    fn aw_ts_msg_rect__id_sel(recv: u64, sel: u64) -> CgRect;
    fn aw_ts_rect_probe(recv: u64, sel: u64, out: *mut f64);
    fn aw_ts_setup_app() -> bool;
    fn aw_ts_run_app(seconds: f64);
    fn aw_ts_pump(max: i32) -> i32;
    fn aw_ts_dispatch_bg(cb: extern "C" fn(u64), token: u64);
    fn aw_ts_dispatch_bg_then_main(cb: extern "C" fn(u64), token: u64);
    fn aw_ts_run_app_integrated(loop_ptr: u64, seconds: f64, pump: extern "C" fn(u64));
}

// libuv, resolved at load time against the host (Node) via -undefined dynamic_lookup.
extern "C" {
    fn uv_run(loop_: *mut std::os::raw::c_void, mode: i32) -> i32;
}
const UV_RUN_NOWAIT: i32 = 2;

// Pump callback the Swift main-runloop timer invokes: drain ready libuv work
// without blocking, so Node's loop stays serviced while NSApp.run() owns thread 0.
extern "C" fn pump_uv(loop_ptr: u64) {
    unsafe { uv_run(loop_ptr as *mut std::os::raw::c_void, UV_RUN_NOWAIT) };
}

// BigInt -> u64 low word (version-robust across napi-rs 2.x tuple shapes).
#[inline]
fn h(bi: &BigInt) -> u64 {
    bi.words.first().copied().unwrap_or(0)
}

// ---- probe 1: dispatch ----------------------------------------------------
#[napi]
pub fn get_class(name: String) -> Result<BigInt> {
    let c = CString::new(name).map_err(|e| Error::from_reason(e.to_string()))?;
    Ok(BigInt::from(unsafe { aw_ts_get_class(c.as_ptr()) }))
}

#[napi]
pub fn sel(name: String) -> Result<BigInt> {
    let c = CString::new(name).map_err(|e| Error::from_reason(e.to_string()))?;
    Ok(BigInt::from(unsafe { aw_ts_sel(c.as_ptr()) }))
}

#[napi]
pub fn msg_id(recv: BigInt, sel: BigInt) -> BigInt {
    BigInt::from(unsafe { aw_ts_msg_id__id_sel(h(&recv), h(&sel)) })
}

#[napi]
pub fn msg_id_cstr(recv: BigInt, sel: BigInt, arg: String) -> Result<BigInt> {
    let c = CString::new(arg).map_err(|e| Error::from_reason(e.to_string()))?;
    Ok(BigInt::from(unsafe {
        aw_ts_msg_id__id_sel_cstr(h(&recv), h(&sel), c.as_ptr())
    }))
}

#[napi(js_name = "msgU64")]
pub fn msg_u64(recv: BigInt, sel: BigInt) -> BigInt {
    BigInt::from(unsafe { aw_ts_msg_u64__id_sel(h(&recv), h(&sel)) })
}

#[napi(object)]
pub struct Rect {
    pub x: f64,
    pub y: f64,
    pub w: f64,
    pub h: f64,
}

// CGRect returned by value, Swift -> Rust -> JS.
#[napi]
pub fn msg_rect(recv: BigInt, sel: BigInt) -> Rect {
    let r = unsafe { aw_ts_msg_rect__id_sel(h(&recv), h(&sel)) };
    Rect {
        x: r.origin.x,
        y: r.origin.y,
        w: r.size.width,
        h: r.size.height,
    }
}

// Independent cross-check: same selector via an out-buffer (not by-value return).
#[napi]
pub fn rect_probe(recv: BigInt, sel: BigInt) -> Vec<f64> {
    let mut out = [0.0f64; 4];
    unsafe { aw_ts_rect_probe(h(&recv), h(&sel), out.as_mut_ptr()) };
    out.to_vec()
}

// ---- probe 2: thread-0 ownership -----------------------------------------
#[napi]
pub fn setup_app() -> bool {
    unsafe { aw_ts_setup_app() }
}

#[napi]
pub fn run_app(seconds: f64) {
    unsafe { aw_ts_run_app(seconds) }
}

#[napi]
pub fn pump(max: i32) -> i32 {
    unsafe { aw_ts_pump(max) }
}

// NSApplication.run() owns thread 0 AND libuv stays serviced (integrated model).
// Uses the stable N-API hook napi_get_uv_event_loop to reach Node's uv loop.
#[napi]
pub fn run_app_integrated(env: Env, seconds: f64) -> Result<()> {
    let mut loop_ptr: *mut napi::sys::uv_loop_s = std::ptr::null_mut();
    let status = unsafe { napi::sys::napi_get_uv_event_loop(env.raw(), &mut loop_ptr) };
    if status != 0 || loop_ptr.is_null() {
        return Err(Error::from_reason("napi_get_uv_event_loop failed"));
    }
    unsafe { aw_ts_run_app_integrated(loop_ptr as u64, seconds, pump_uv) };
    Ok(())
}

// ---- probe 3: background-thread callback -> JS via threadsafe function -----
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
    unsafe { aw_ts_dispatch_bg(bg_trampoline, token as u64) }
}

#[napi]
pub fn fire_bg_then_main(token: i64) {
    unsafe { aw_ts_dispatch_bg_then_main(bg_trampoline, token as u64) }
}
