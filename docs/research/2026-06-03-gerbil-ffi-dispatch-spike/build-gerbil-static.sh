#!/usr/bin/env bash
# Source-build Gerbil 0.18.2 with a static (--enable-shared=no) Gambit, so
# `gxc -static -exe` works (spike item 5; also the target's eventual bundler
# toolchain per ADR-0009). Logs to build.log. Idempotent-ish: wipes BUILD first.
set -euo pipefail

BUILD="$HOME/src/gerbil-0.18.2-build"
PREFIX="$HOME/.local/gerbil-0.18.2-static"

echo "[$(date +%T)] clone gerbil v0.18.2 -> $BUILD"
rm -rf "$BUILD" "$PREFIX"
git clone --depth 1 --branch v0.18.2 https://github.com/mighty-gerbils/gerbil.git "$BUILD"
cd "$BUILD"
echo "[$(date +%T)] init submodules (gambit)"
git submodule update --init --recursive --depth 1

echo "[$(date +%T)] configure --prefix=$PREFIX --enable-shared=no"
# Gerbil's configure forwards to the vendored Gambit. --enable-shared=no makes
# Gambit build static libs (libgambit.a) so -static linking works.
if ! ./configure --prefix="$PREFIX" --enable-shared=no 2>&1; then
  echo "[$(date +%T)] --enable-shared=no rejected; checking ./configure --help"
  ./configure --help 2>&1 | sed -n '1,80p'
  exit 3
fi

echo "[$(date +%T)] make (bootstrap gambit + build gerbil)"
make
echo "[$(date +%T)] make install"
make install
echo "[$(date +%T)] DONE. gxc at: $PREFIX/bin/gxc"
"$PREFIX/bin/gxc" --version 2>&1 || true
