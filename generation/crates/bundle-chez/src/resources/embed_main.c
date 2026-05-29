/* embed_main.c — minimal Chez Scheme kernel-embedding host for the
 * self-contained chez `.app`. Compiled and linked by bundle-chez's
 * standalone.rs (ported verbatim from the 060/010 spike evidence).
 *
 * INTERIM (grove add-chez-target, node 060/030, leaf 010): this host seeds
 * the runtime dylib-search root by `chdir`-ing to the resource dir — the
 * spike-proven expedient. Node-leaf 030 replaces the chdir with a Scheme
 * prelude object that sets (library-directories) from an exe-relative path
 * and keeps the process cwd untouched. Until then, chdir is the green path.
 *
 * Boots an embedded Chez heap from a single self-contained boot file
 * (made via make-boot-file with petite.boot + [scheme.boot] + app objects
 * concatenated) and hands control to the heap's (scheme-start) thunk.
 *
 * The boot file is located relative to the executable: we expect it at
 * <dir-of-argv0>/<BOOTNAME>.  This keeps the binary host-Chez-independent:
 * nothing is read from /opt/homebrew or PATH.
 *
 * Build (standalone.rs): cc embed_main.c libkernel.a liblz4.a libz.a
 * with -framework Foundation -framework AppKit -liconv -lncurses (NOT
 * main.o — it defines its own main(); spike F9).
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>
#include <limits.h>
#include <unistd.h>
#include <mach-o/dyld.h>

#include "scheme.h"

#ifndef BOOTNAME
#define BOOTNAME "app.boot"
#endif

int main(int argc, const char *argv[]) {
    /* Resolve the real path of this executable so we can find the boot
     * file sitting next to it, regardless of cwd or how we were launched. */
    char exe[PATH_MAX];
    uint32_t size = sizeof(exe);
    if (_NSGetExecutablePath(exe, &size) != 0) {
        fprintf(stderr, "embed_main: executable path too long\n");
        return 1;
    }
    char real[PATH_MAX];
    if (realpath(exe, real) == NULL) {
        strncpy(real, exe, PATH_MAX - 1);
        real[PATH_MAX - 1] = '\0';
    }
    char dir[PATH_MAX];
    strncpy(dir, real, PATH_MAX - 1);
    dir[PATH_MAX - 1] = '\0';
    char *d = dirname(dir);

    /* Locate the resource dir holding <BOOTNAME> + lib/.  Two layouts:
     *   flat standalone run dir : alongside the executable
     *   .app bundle             : Contents/Resources/ (the .boot is a DATA
     *                             resource there; codesign --strict rejects
     *                             non-Mach-O files placed in Contents/MacOS/)
     * Pick whichever actually contains the boot file. */
    char resdir[PATH_MAX];
    char boot[PATH_MAX];
    snprintf(boot, sizeof(boot), "%s/%s", d, BOOTNAME);
    if (access(boot, R_OK) == 0) {
        strncpy(resdir, d, PATH_MAX - 1); resdir[PATH_MAX - 1] = '\0';
    } else {
        snprintf(resdir, sizeof(resdir), "%s/../Resources", d);
        snprintf(boot, sizeof(boot), "%s/%s", resdir, BOOTNAME);
    }

    /* Seed the runtime's dylib search root before the heap is built.  The
     * apianyware libraries instantiate during boot load (Sbuild_heap) — well
     * before any Scheme hook we control — and resolve-dylib-path probes each
     * (library-directories) entry for `lib/libAPIAnywareChez.dylib`.  The
     * embedded kernel's library-directories defaults to "." and does NOT read
     * CHEZSCHEMELIBDIRS, so we chdir to the executable's own directory: "."
     * then resolves to <exe-dir>/lib/libAPIAnywareChez.dylib.  (Production
     * bundler note: a cleaner shape is a prelude object linked into the boot
     * ahead of the app that sets (library-directories) from an exe-relative
     * path — see spike report.) */
    if (chdir(resdir) != 0) {
        fprintf(stderr, "embed_main: chdir(%s) failed\n", resdir);
    }

    Sscheme_init(NULL);
    Sregister_boot_file(boot);
    Sbuild_heap(NULL, NULL);

    /* Sscheme_start invokes the heap's (scheme-start) thunk with the
     * remaining command-line args.  Our app sets (scheme-start ...) to
     * its real entry point.  Returns the exit status the thunk yields. */
    int status = Sscheme_start(argc - 1, argv + 1);

    Sscheme_deinit();
    return status;
}
