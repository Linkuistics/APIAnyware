# `generated/` — emitted Racket binding source (macOS)

Home for the per-framework `.rkt` binding files the racket emitter produces
(`apianyware-generate`). The contents are **gitignored and absent in a clean
checkout** — they are regenerated from the IR by the pipeline.

Sample apps `(require "../../generated/<framework>/<class>.rkt")` relative to
their app directory; the bundler (`apianyware-bundle-racket`) walks that require
tree and copies the reachable files into each `.app`.
