// spike.m — chez dispatch/marshalling spike (grove chez-adopt-native-binding, leaf 010).
//
// THROWAWAY spike code. Not shipped. Built into libchezspike.dylib and called
// from Chez Scheme to answer two questions the design grilling left to measure:
//
//   Part A (hop isolation): does wrapping objc_msgSend in a native typed shim
//     (aw_chez_send_*) cost anything vs Chez calling objc_msgSend DIRECTLY via
//     `foreign-procedure`? Chez's foreign-procedure compiles to a direct typed
//     C call, so the native shim is a *second* native call chez doesn't have
//     today. libffi-generic is measured as the escape-hatch reference.
//
//   Part B (marshalling payoff): for string-in/out and list->NSArray, does a
//     native entry that does the ObjC marshalling beat chez-side coercion +
//     direct msgSend (the path the runtime uses today)?
//
// Build: see build.sh

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#include <ffi/ffi.h>
#include <stdlib.h>
#include <string.h>

// ---------------------------------------------------------------------------
// Controlled target across the four ABI shapes from the racket spike table.
// ---------------------------------------------------------------------------
@interface AWSpikeTarget : NSObject
- (int64_t)scalar:(int64_t)x;        // scalar:   (id,SEL,long) -> long
- (id)idecho:(id)x;                  // id->id:   (id,SEL,id)   -> id
- (NSRect)rect;                      // struct:   (id,SEL)      -> NSRect (by value)
- (double)sum:(double)a and:(double)b; // 2xfloat: (id,SEL,double,double) -> double
- (NSString *)appendBang:(NSString *)s; // marshalling: NSString in/out
@end

@implementation AWSpikeTarget
- (int64_t)scalar:(int64_t)x { return x + 1; }
- (id)idecho:(id)x { return x; }
- (NSRect)rect { return NSMakeRect(1.0, 2.0, 3.0, 4.0); }
- (double)sum:(double)a and:(double)b { return a + b; }
- (NSString *)appendBang:(NSString *)s { return [s stringByAppendingString:@"!"]; }
@end

// Factory + SEL pre-registration so the bench can cache once (fair comparison:
// matches how the runtime caches selectors at library-load).
void *aw_spike_make_target(void) { return (__bridge_retained void *)[AWSpikeTarget new]; }
void *aw_spike_sel(const char *name) { return (void *)sel_registerName(name); }

// ===========================================================================
// PART A — dispatch mechanisms
// ===========================================================================
//
// (1) DIRECT is not here: Chez calls objc_msgSend itself via foreign-procedure.
// (2) NATIVE TYPED SHIMS: one extra native call that forwards to objc_msgSend.
// (3) LIBFFI GENERIC: one generic dispatcher, CIF cached per signature.

// --- (2) native typed shims (the "hop") ---
int64_t aw_chez_send_scalar(void *recv, void *sel, int64_t x) {
    int64_t (*fn)(void *, SEL, int64_t) = (int64_t (*)(void *, SEL, int64_t))objc_msgSend;
    return fn(recv, (SEL)sel, x);
}
void *aw_chez_send_id(void *recv, void *sel, void *arg) {
    void *(*fn)(void *, SEL, void *) = (void *(*)(void *, SEL, void *))objc_msgSend;
    return fn(recv, (SEL)sel, arg);
}
double aw_chez_send_2f(void *recv, void *sel, double a, double b) {
    double (*fn)(void *, SEL, double, double) = (double (*)(void *, SEL, double, double))objc_msgSend;
    return fn(recv, (SEL)sel, a, b);
}
// Struct-by-value return: native shim returns NSRect flattened into a caller
// buffer (4 doubles), so Chez never sees the (& NSRect) indirect-result ABI.
void aw_chez_send_rect(void *recv, void *sel, double *out4) {
    // NSRect is 4 doubles = a homogeneous float aggregate; arm64 returns it in
    // FP registers, so plain objc_msgSend (not objc_msgSend_stret) is correct.
    NSRect r = ((NSRect (*)(void *, SEL))objc_msgSend)(recv, (SEL)sel);
    out4[0] = r.origin.x; out4[1] = r.origin.y; out4[2] = r.size.width; out4[3] = r.size.height;
}

// --- (3) libffi generic, CIF cached per signature (escape-hatch reference) ---
static ffi_cif s_cif_scalar; static ffi_type *s_args_scalar[3]; static int s_ready_scalar = 0;
static void ensure_cif_scalar(void) {
    if (s_ready_scalar) return;
    s_args_scalar[0] = &ffi_type_pointer; // self
    s_args_scalar[1] = &ffi_type_pointer; // _cmd
    s_args_scalar[2] = &ffi_type_sint64;  // x
    ffi_prep_cif(&s_cif_scalar, FFI_DEFAULT_ABI, 3, &ffi_type_sint64, s_args_scalar);
    s_ready_scalar = 1;
}
int64_t aw_chez_ffi_scalar(void *recv, void *sel, int64_t x) {
    ensure_cif_scalar();
    void *avalues[3] = {&recv, &sel, &x};
    int64_t result = 0;
    ffi_call(&s_cif_scalar, FFI_FN(objc_msgSend), &result, avalues);
    return result;
}

// ===========================================================================
// PART B — marshalling payoff
// ===========================================================================

// --- B0. The string converters the chez runtime uses TODAY (native helpers,
//         one FFI crossing each). The "chez-side coercion" path = str2ns +
//         direct msgSend(appendBang:) + ns2str = THREE crossings.
void *aw_chez_str2ns(const char *utf8) {
    return (__bridge_retained void *)[NSString stringWithUTF8String:utf8];
}
char *aw_chez_ns2str(void *ns) {
    const char *c = [(__bridge NSString *)ns UTF8String];
    return strdup(c); // caller frees via aw_chez_free
}
void aw_chez_free(void *p) { free(p); }

// --- B1. String in/out done entirely natively: UTF-8 char* in, freshly-malloc'd
//         UTF-8 char* out. ONE native call replaces the three-crossing round trip.
char *aw_chez_append_bang(const char *utf8) {
    @autoreleasepool {
        NSString *s = [NSString stringWithUTF8String:utf8];
        NSString *r = [s stringByAppendingString:@"!"];
        return strdup([r UTF8String]); // caller frees via aw_chez_free
    }
}

// --- B2. list->NSArray. Native one-crossing build: chez passes the n strings
//         newline-joined; native splits into an NSArray. Compared against chez
//         building NSMutableArray with a per-element (str2ns + addObject:) loop.
void *aw_chez_strings_to_nsarray_joined(const char *joined) {
    @autoreleasepool {
        NSString *s = [NSString stringWithUTF8String:joined];
        return (__bridge_retained void *)[s componentsSeparatedByString:@"\n"];
    }
}
unsigned long aw_chez_nsarray_count(void *arr) {
    return (unsigned long)[(__bridge NSArray *)arr count];
}

// Proper char** batch builder: chez marshals each element to a C string and
// fills a void* array, then ONE crossing builds the NSArray. Isolates the
// crossing-reduction benefit from any string-split overhead.
void *aw_chez_strs_to_nsarray(void *items_ptr, int n) {
    const char **items = (const char **)items_ptr;
    @autoreleasepool {
        NSMutableArray *a = [NSMutableArray arrayWithCapacity:n];
        for (int i = 0; i < n; i++) [a addObject:[NSString stringWithUTF8String:items[i]]];
        return (__bridge_retained void *)a;
    }
}
