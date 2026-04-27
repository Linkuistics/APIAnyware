#!/usr/bin/env bash
# Work-phase bootstrap for the core plan. Delegates to the shared
# pipeline freshness check so a stale analysis or generation checkpoint
# cannot survive across sessions and mislead the next fix hypothesis.
# Invoked by the Ravel-Lite runner from the project root before the
# work-phase session is launched.

set -euo pipefail
exec ./analysis/scripts/regenerate-stale-pipeline.sh
