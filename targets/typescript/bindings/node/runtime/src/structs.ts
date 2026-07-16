// The POD geometry family (ADR-0042 population A, ADR-0055 §5): the by-value C/ObjC aggregates
// that cross the dispatch seam as **plain JS objects**, not branded handles — no `id`, no retain,
// no disposal. Pure types: this module declares no runtime value, so an emitted module imports
// them with `import type` and they erase completely at emit.
//
// ## Why they live in the runtime and not in a framework module
//
// The set is **fixed and closed**, and keyed by *memory layout* rather than by framework: one
// `CGRect` is shared by AppKit, Foundation and CoreGraphics alike, so a per-framework `structs.ts`
// would define the same nine types once per framework that touches geometry — and would have to
// answer an ownership question the IR cannot (which framework owns `CGRect` when CoreGraphics is
// not in the emit set?). Beside `NSObject` and `Result<T>`, they are the third thing every emitted
// framework may name without owning.
//
// ## Each type mirrors its C struct's fields, one for one
//
// The shape here is the shape the addon marshals (`napi_support.swift`, the `napiMake<Stem>` /
// `napiRead<Stem>` pair per struct) — a plain object with the struct's own field names, doubles
// throughout. That is one rule, not nine: **the TS object mirrors the C struct.** `CGRect` is the
// only member whose C struct is itself nested (`struct CGRect { CGPoint origin; CGSize size; }`),
// so it is the only nested type here — and nesting is what keeps it composable, since `rect.origin`
// is exactly the `CGPoint` that `-[NSView setFrameOrigin:]` takes.
//
// A reader defaults a missing or non-numeric field to 0 (a JS-side typo surfaces as zeroed
// geometry, never a crash), so these are the *intended* shapes rather than enforced ones — which
// is precisely why `tsc` checking them at every call site is load-bearing.

/** `CGPoint` / `NSPoint` — a point in the coordinate space. */
export interface CGPoint {
  x: number;
  y: number;
}

/** `CGSize` / `NSSize` — a width/height extent. */
export interface CGSize {
  width: number;
  height: number;
}

/**
 * `CGRect` / `NSRect` — an origin plus an extent. The one **nested** member of the family,
 * faithful to `struct CGRect { CGPoint origin; CGSize size; }`, so `r.origin` and `r.size` are
 * themselves the `CGPoint` / `CGSize` the geometry methods take.
 */
export interface CGRect {
  origin: CGPoint;
  size: CGSize;
}

/** `NSRange` — a location/length span (integers, marshalled as doubles). */
export interface NSRange {
  location: number;
  length: number;
}

/** `NSEdgeInsets` — absolute (left/right) edge insets. */
export interface NSEdgeInsets {
  top: number;
  left: number;
  bottom: number;
  right: number;
}

/** `NSDirectionalEdgeInsets` — writing-direction-relative (leading/trailing) edge insets. */
export interface NSDirectionalEdgeInsets {
  top: number;
  leading: number;
  bottom: number;
  trailing: number;
}

/** `NSAffineTransformStruct` — AppKit's affine matrix (note the capitalised `tX`/`tY` fields). */
export interface NSAffineTransformStruct {
  m11: number;
  m12: number;
  m21: number;
  m22: number;
  tX: number;
  tY: number;
}

/** `CGAffineTransform` — CoreGraphics' affine matrix (lowercase `tx`/`ty`; a distinct layout). */
export interface CGAffineTransform {
  a: number;
  b: number;
  c: number;
  d: number;
  tx: number;
  ty: number;
}

/** `CGVector` — a two-dimensional delta. */
export interface CGVector {
  dx: number;
  dy: number;
}
