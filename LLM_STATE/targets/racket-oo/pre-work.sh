#!/usr/bin/env bash
# Work-phase bootstrap for the racket-oo plan. Delegates to the shared
# pipeline freshness check, scoped to the racket-oo emitter so other
# language targets are not paid for during racket-oo-only sessions.
# Invoked by the Ravel-Lite runner from the project root before the
# work-phase session is launched.

set -euo pipefail
exec ./analysis/scripts/regenerate-stale-pipeline.sh --lang racket-oo
