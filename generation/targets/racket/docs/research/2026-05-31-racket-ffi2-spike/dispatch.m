// dispatch.m — spike: native ObjC dispatcher variants for the racket ffi2 migration.
//
// THROWAWAY spike code (leaf 040/010). Not shipped. Built into libspike.dylib
// and called from Racket two ways (ffi2 seam, vs in-Racket `tell` baseline) to
// answer: does relocating outbound ObjC dispatch into the native lib help or
// hurt per-call cost, once the ffi2<->ffi/unsafe pointer-bridging tax is paid?
//
// Build: see build.sh

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#include <ffi/ffi.h>

// --- 3. libffi generic dispatcher (D1 follow-up spike) -----------------------
// A single generic native dispatcher: build an ffi_cif from a signature, then
// ffi_call(objc_msgSend, ...). This is how PyObjC/JNA-style bridges do fully-
// dynamic dispatch. The realistic design caches the CIF per call-site, so we
// expose both a CIF-cached fast path and a CIF-per-call path to price the cache.

// CIF for the (id, SEL) -> uint64 signature, prepared once.
static ffi_cif s_cif_uint;
static ffi_type *s_args_uint[2];
static int s_cif_uint_ready = 0;

static void ensure_cif_uint(void) {
    if (s_cif_uint_ready) return;
    s_args_uint[0] = &ffi_type_pointer; // self (id)
    s_args_uint[1] = &ffi_type_pointer; // _cmd (SEL)
    ffi_prep_cif(&s_cif_uint, FFI_DEFAULT_ABI, 2, &ffi_type_uint64, s_args_uint);
    s_cif_uint_ready = 1;
}

// libffi generic, CIF cached (steady state — the realistic hot path).
uint64_t aw_spike_ffi_msg_uint(void *target, void *sel) {
    ensure_cif_uint();
    void *avalues[2] = {&target, &sel};
    uint64_t result = 0;
    ffi_call(&s_cif_uint, FFI_FN(objc_msgSend), &result, avalues);
    return result;
}

// libffi generic, CIF rebuilt every call (the cost the cache avoids).
uint64_t aw_spike_ffi_msg_uint_nocache(void *target, void *sel) {
    ffi_cif cif;
    ffi_type *args[2] = {&ffi_type_pointer, &ffi_type_pointer};
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 2, &ffi_type_uint64, args);
    void *avalues[2] = {&target, &sel};
    uint64_t result = 0;
    ffi_call(&cif, FFI_FN(objc_msgSend), &result, avalues);
    return result;
}

// --- 0. SEL pre-registration (so benches can cache the selector once, matching
//        how the `tell` macro caches SEL at expansion — fair comparison).
void *aw_spike_sel(const char *selname) {
    return (void *)sel_registerName(selname);
}

// --- 1. Typed entry point: (target, sel) -> uint64  (no-arg, e.g. -hash/-length)
uint64_t aw_spike_msg_uint(void *target, const char *selname) {
    SEL sel = sel_registerName(selname);
    uint64_t (*fn)(void *, SEL) = (uint64_t (*)(void *, SEL))objc_msgSend;
    return fn(target, sel);
}

// --- 1-sel. Typed entry with a PRE-REGISTERED SEL pointer (no per-call string).
uint64_t aw_spike_msg_uint_sel(void *target, void *sel) {
    uint64_t (*fn)(void *, SEL) = (uint64_t (*)(void *, SEL))objc_msgSend;
    return fn(target, (SEL)sel);
}

// --- 1b. Typed entry point: (target, sel, id) -> id  (one id arg, returns id)
void *aw_spike_msg_id1(void *target, const char *selname, void *arg0) {
    SEL sel = sel_registerName(selname);
    void *(*fn)(void *, SEL, void *) = (void *(*)(void *, SEL, void *))objc_msgSend;
    return fn(target, sel, arg0);
}

// --- 2. NSInvocation generic dispatcher: (target, sel) -> uint64
// Builds an NSInvocation per call (the realistic generic path). Measures the
// cost of fully-dynamic dispatch with no per-selector typed C shim.
uint64_t aw_spike_invoke_uint(void *target, const char *selname) {
    SEL sel = sel_registerName(selname);
    id obj = (__bridge id)target;
    NSMethodSignature *sig = [obj methodSignatureForSelector:sel];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:obj];
    [inv setSelector:sel];
    [inv invoke];
    uint64_t result = 0;
    [inv getReturnValue:&result];
    return result;
}

// --- 2b. NSInvocation generic dispatcher: (target, sel, id) -> id
void *aw_spike_invoke_id1(void *target, const char *selname, void *arg0) {
    SEL sel = sel_registerName(selname);
    id obj = (__bridge id)target;
    NSMethodSignature *sig = [obj methodSignatureForSelector:sel];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:obj];
    [inv setSelector:sel];
    [inv setArgument:&arg0 atIndex:2]; // 0=self,1=_cmd,2=first real arg
    [inv invoke];
    void *result = NULL;
    [inv getReturnValue:&result];
    return result;
}

// --- helpers to manufacture stable test objects from C (so the bench loop is
//     not measuring object creation) -------------------------------------------

// Returns a +1-retained NSObject. Caller keeps it for the run.
void *aw_spike_make_nsobject(void) {
    return (__bridge_retained void *)[[NSObject alloc] init];
}

// Returns a +1-retained NSString "spike".
void *aw_spike_make_nsstring(void) {
    return (__bridge_retained void *)[[NSString alloc] initWithUTF8String:"spike"];
}

// Plain void-returning callout, no callback — isolate whether the ffi2 `#f`
// glitch is about void RESULTS in general or callbacks specifically.
void aw_spike_void_noop(uint64_t x) { (void)x; }

// Callout taking an int->int callback, invoked synchronously on this thread.
int aw_spike_call_int_cb(int (*cb)(int)) { return cb(21); }

// Callout taking a void->void callback, invoked synchronously on this thread.
void aw_spike_call_void_cb(void (*cb)(void)) { cb(); }

// Pure-C floor: objc_msgSend -hash N times in a tight C loop (no FFI per call).
uint64_t aw_spike_floor_hash_loop(void *target, uint64_t iters) {
    SEL sel = sel_registerName("hash");
    uint64_t (*fn)(void *, SEL) = (uint64_t (*)(void *, SEL))objc_msgSend;
    uint64_t acc = 0;
    for (uint64_t i = 0; i < iters; i++) {
        acc += fn(target, sel);
    }
    return acc;
}

// ============================================================================
// Multi-shape benchmark target (D1 rigor): a controlled ObjC class with known
// method signatures, dispatched three ways (generated-typed / libffi / — tell
// is done Racket-side). Proves "generated typed beats libffi ~2x" holds across
// scalar / id / struct-return / multi-float shapes, not just the trivial case.
// ============================================================================

@interface AWSpikeTarget : NSObject
- (uint64_t)h;
- (void *)idfor:(void *)x;
- (CGRect)rectfor:(uint64_t)n;
- (double)addx:(double)a y:(double)b;
@end
@implementation AWSpikeTarget
- (uint64_t)h { return 42; }
- (void *)idfor:(void *)x { return x; }
- (CGRect)rectfor:(uint64_t)n { return CGRectMake((double)n, 2.0, 3.0, 4.0); }
- (double)addx:(double)a y:(double)b { return a + b; }
@end

void *aw_spike_make_target(void) { return (__bridge_retained void *)[AWSpikeTarget new]; }

// ---- generated-typed entries (what the emitter would emit from the IR) ----
uint64_t aw_t_h(void *t, void *sel) {
    return ((uint64_t(*)(void *, SEL))objc_msgSend)(t, (SEL)sel);
}
void *aw_t_idfor(void *t, void *sel, void *a) {
    return ((void *(*)(void *, SEL, void *))objc_msgSend)(t, (SEL)sel, a);
}
void aw_t_rectfor(void *t, void *sel, uint64_t n, double *out4) {
    CGRect r = ((CGRect(*)(void *, SEL, uint64_t))objc_msgSend)(t, (SEL)sel, n);
    out4[0]=r.origin.x; out4[1]=r.origin.y; out4[2]=r.size.width; out4[3]=r.size.height;
}
double aw_t_addxy(void *t, void *sel, double a, double b) {
    return ((double(*)(void *, SEL, double, double))objc_msgSend)(t, (SEL)sel, a, b);
}

// ---- libffi generic entries (CIF cached per shape) ----
static ffi_cif cif_h, cif_idfor, cif_rectfor, cif_addxy;
static int cifs_ready = 0;
static ffi_type cgrect_t;
static ffi_type *cgrect_elems[5];
static void ensure_cifs(void) {
    if (cifs_ready) return;
    cgrect_elems[0]=&ffi_type_double; cgrect_elems[1]=&ffi_type_double;
    cgrect_elems[2]=&ffi_type_double; cgrect_elems[3]=&ffi_type_double; cgrect_elems[4]=NULL;
    cgrect_t.size=0; cgrect_t.alignment=0; cgrect_t.type=FFI_TYPE_STRUCT; cgrect_t.elements=cgrect_elems;
    static ffi_type *a_h[2]   = {&ffi_type_pointer,&ffi_type_pointer};
    static ffi_type *a_id[3]  = {&ffi_type_pointer,&ffi_type_pointer,&ffi_type_pointer};
    static ffi_type *a_rect[3]= {&ffi_type_pointer,&ffi_type_pointer,&ffi_type_uint64};
    static ffi_type *a_add[4] = {&ffi_type_pointer,&ffi_type_pointer,&ffi_type_double,&ffi_type_double};
    ffi_prep_cif(&cif_h,      FFI_DEFAULT_ABI, 2, &ffi_type_uint64,  a_h);
    ffi_prep_cif(&cif_idfor,  FFI_DEFAULT_ABI, 3, &ffi_type_pointer, a_id);
    ffi_prep_cif(&cif_rectfor,FFI_DEFAULT_ABI, 3, &cgrect_t,         a_rect);
    ffi_prep_cif(&cif_addxy,  FFI_DEFAULT_ABI, 4, &ffi_type_double,  a_add);
    cifs_ready = 1;
}
uint64_t aw_l_h(void *t, void *sel) {
    ensure_cifs(); void *av[2]={&t,&sel}; uint64_t r=0; ffi_call(&cif_h, FFI_FN(objc_msgSend), &r, av); return r;
}
void *aw_l_idfor(void *t, void *sel, void *a) {
    ensure_cifs(); void *av[3]={&t,&sel,&a}; void *r=NULL; ffi_call(&cif_idfor, FFI_FN(objc_msgSend), &r, av); return r;
}
void aw_l_rectfor(void *t, void *sel, uint64_t n, double *out4) {
    ensure_cifs(); void *av[3]={&t,&sel,&n}; CGRect r; ffi_call(&cif_rectfor, FFI_FN(objc_msgSend), &r, av);
    out4[0]=r.origin.x; out4[1]=r.origin.y; out4[2]=r.size.width; out4[3]=r.size.height;
}
double aw_l_addxy(void *t, void *sel, double a, double b) {
    ensure_cifs(); void *av[4]={&t,&sel,&a,&b}; double r=0; ffi_call(&cif_addxy, FFI_FN(objc_msgSend), &r, av); return r;
}
