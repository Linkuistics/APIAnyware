// CollectionMarshal.swift — batched Racket ⇄ Foundation collection marshalling.
//
// The Depth-2 slice of the marshalling-depth spectrum (leaf 050/030, design §3):
// move the per-element conversions `runtime/type-mapping.rkt` used to do in
// interpreted Racket — a `tell addObject:` / `objectAtIndex:` per element — into
// one native call per collection. The Racket side hands over (or reads back) a
// flat C array once via `ffi/unsafe`'s `(_list i …)` / `(_list o … count)`
// marshalling; Foundation object construction and enumeration happen natively.
//
// Exports (all `aw_racket_` per ADR-0011 hermetic isolation):
//   list:  aw_racket_list_to_nsarray / aw_racket_nsarray_count / aw_racket_nsarray_get_all
//   dict:  aw_racket_hash_to_nsdictionary / aw_racket_nsdictionary_count
//          / aw_racket_nsdictionary_get_all
//
// Ownership conventions (match the prior Racket helpers exactly, so the runtime
// contract is unchanged):
//   - *_to_* constructors return a freshly retained (+1) collection; the Racket
//     side wraps it with `#:retained #t` and the finalizer releases it.
//   - *_get_all readers write **unretained** element/value pointers, valid only
//     while the source collection is alive — which it is, since the caller holds
//     it across the synchronous call. The Racket side copies what it needs
//     (object wrappers / string copies) before returning.
//   - Keys read back as `char*` from `-utf8String`: +0/borrowed (autoreleased),
//     copied into a Racket string immediately. Same contract as a returned
//     `string_t` (see StringConversion.swift).
//   - The `count` argument on every `_get_all` is the caller's buffer size; the
//     loop clamps to it so a collection that grew between the count query and the
//     read can never overflow the buffer.

import Foundation

// MARK: - list ⇄ NSArray

/// Build a +1-retained NSArray from a C array of `count` ObjC `id` pointers.
/// nil slots are skipped (NSArray cannot hold nil). Mirrors the old
/// `list->nsarray`'s `tell NSMutableArray addObject:` loop in one call.
@_cdecl("aw_racket_list_to_nsarray")
public func listToNSArray(
    _ items: UnsafePointer<UnsafeMutableRawPointer?>?,
    _ count: Int
) -> UnsafeMutableRawPointer {
    let arr = NSMutableArray(capacity: count)
    if let items = items {
        for i in 0..<count where items[i] != nil {
            arr.add(Unmanaged<AnyObject>.fromOpaque(items[i]!).takeUnretainedValue())
        }
    }
    return Unmanaged.passRetained(arr).toOpaque()
}

/// Number of elements in an NSArray — the count the caller allocates its
/// read-back buffer to before calling `aw_racket_nsarray_get_all`.
@_cdecl("aw_racket_nsarray_count")
public func nsarrayCount(_ array: UnsafeMutableRawPointer) -> Int {
    Unmanaged<NSArray>.fromOpaque(array).takeUnretainedValue().count
}

/// Fill `out` (caller-allocated, `count` pointers wide) with the array's element
/// `id` pointers, **unretained**. Replaces the `objectAtIndex:` loop in one native
/// enumeration.
@_cdecl("aw_racket_nsarray_get_all")
public func nsarrayGetAll(
    _ array: UnsafeMutableRawPointer,
    _ count: Int,
    _ out: UnsafeMutablePointer<UnsafeMutableRawPointer?>
) {
    let a = Unmanaged<NSArray>.fromOpaque(array).takeUnretainedValue()
    let n = min(count, a.count)
    for i in 0..<n {
        out[i] = Unmanaged.passUnretained(a[i] as AnyObject).toOpaque()
    }
}

// MARK: - hash ⇄ NSDictionary

/// Build a +1-retained NSDictionary from parallel C arrays of `count` UTF-8 string
/// keys and `count` ObjC `id` values. Mirrors `hash->nsdictionary`'s per-key
/// NSString creation + `setObject:forKey:` loop in one call. A nil key or value
/// slot is skipped together.
@_cdecl("aw_racket_hash_to_nsdictionary")
public func hashToNSDictionary(
    _ keys: UnsafePointer<UnsafePointer<CChar>?>?,
    _ values: UnsafePointer<UnsafeMutableRawPointer?>?,
    _ count: Int
) -> UnsafeMutableRawPointer {
    let dict = NSMutableDictionary(capacity: count)
    if let keys = keys, let values = values {
        for i in 0..<count {
            guard let keyC = keys[i], let valP = values[i] else { continue }
            let key = String(cString: keyC) as NSString
            dict[key] = Unmanaged<AnyObject>.fromOpaque(valP).takeUnretainedValue()
        }
    }
    return Unmanaged.passRetained(dict).toOpaque()
}

/// Number of entries in an NSDictionary.
@_cdecl("aw_racket_nsdictionary_count")
public func nsdictionaryCount(_ dict: UnsafeMutableRawPointer) -> Int {
    Unmanaged<NSDictionary>.fromOpaque(dict).takeUnretainedValue().count
}

/// Fill parallel caller-allocated buffers (each `count` wide) with the
/// dictionary's string keys (`-utf8String`, +0/borrowed) and **unretained** `id`
/// values, as matched pairs. Replaces the `allKeys` + `objectForKey:` + per-key
/// NSString→string loop in one native enumeration.
@_cdecl("aw_racket_nsdictionary_get_all")
public func nsdictionaryGetAll(
    _ dict: UnsafeMutableRawPointer,
    _ count: Int,
    _ outKeys: UnsafeMutablePointer<UnsafePointer<CChar>?>,
    _ outValues: UnsafeMutablePointer<UnsafeMutableRawPointer?>
) {
    let d = Unmanaged<NSDictionary>.fromOpaque(dict).takeUnretainedValue()
    let keys = d.allKeys
    let n = min(count, keys.count)
    for i in 0..<n {
        let k = keys[i]
        outKeys[i] = (k as? NSString)?.utf8String
        if let v = d.object(forKey: k) {
            outValues[i] = Unmanaged.passUnretained(v as AnyObject).toOpaque()
        } else {
            outValues[i] = nil
        }
    }
}
