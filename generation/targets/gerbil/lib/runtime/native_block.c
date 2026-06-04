/* native_block.c — the ObjC block literals for `make-objc-block`.
 *
 * ADR-0017 §6 native core, the ONE piece that cannot live in the gsc-compiled
 * Gerbil module: a `^` block literal. gcc-15 (the bottle's default C compiler)
 * cannot parse block syntax, so this single translation unit is compiled
 * SEPARATELY by `clang -fblocks` and linked into the executable. Everything
 * else in the native core (`native-core.ss`) stays gcc-15 C-safe.
 *
 * Each maker builds a heap block (Block_copy) that captures an integer block-id
 * AND an opaque dispatcher function pointer, forwarding every invocation to it.
 * The dispatcher is one of native-core.ss's `aw_blk_*` `c-define`s, which looks
 * the id up in the Scheme block-closure table and runs the user's Gerbil proc.
 *
 * Passing the dispatcher in (rather than referencing it by symbol) is
 * deliberate: it makes THIS unit self-contained — it has no external symbol of
 * its own — so it links cleanly on every link line, breaking what would
 * otherwise be a mutual reference with native-core's loadable object. The
 * opaque `void *` is cast back to the typed fn-pointer locally.
 *
 * The blocks carry a fixed 3-arg pointer tail (see native-core.ss
 * "generic-trampoline arg model"); a block the framework calls with fewer args
 * leaves the upper slots unread.
 *
 * Block lifetime: Block_copy moves the block to the heap so it outlives this
 * call; the captured id keeps the Scheme closure rooted in the table. The block
 * itself is currently never Block_release'd (one per make-objc-block) — adequate
 * for the main-thread, bounded callback set the early sample apps use; a
 * free-objc-block / dispose path is a later refinement (cf. racket block.rkt).
 */

#include <Block.h>
#include <stdbool.h>

void *aw_make_block_void(int bid, void *dv) {
    void (*d)(int, void *, void *, void *) = (void (*)(int, void *, void *, void *))dv;
    void (^b)(void *, void *, void *) =
        ^(void *a1, void *a2, void *a3) { d(bid, a1, a2, a3); };
    return (void *)Block_copy(b);
}

void *aw_make_block_id(int bid, void *dv) {
    void *(*d)(int, void *, void *, void *) = (void *(*)(int, void *, void *, void *))dv;
    void *(^b)(void *, void *, void *) =
        ^void *(void *a1, void *a2, void *a3) { return d(bid, a1, a2, a3); };
    return (void *)Block_copy(b);
}

void *aw_make_block_bool(int bid, void *dv) {
    bool (*d)(int, void *, void *, void *) = (bool (*)(int, void *, void *, void *))dv;
    bool (^b)(void *, void *, void *) =
        ^bool(void *a1, void *a2, void *a3) { return d(bid, a1, a2, a3); };
    return (void *)Block_copy(b);
}

void *aw_make_block_long(int bid, void *dv) {
    long (*d)(int, void *, void *, void *) = (long (*)(int, void *, void *, void *))dv;
    long (^b)(void *, void *, void *) =
        ^long(void *a1, void *a2, void *a3) { return d(bid, a1, a2, a3); };
    return (void *)Block_copy(b);
}
