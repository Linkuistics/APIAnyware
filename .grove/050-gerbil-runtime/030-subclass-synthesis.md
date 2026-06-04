# 030-subclass-synthesis

**Kind:** work

## Goal

Build the **transparent extensible subclassing** bridge — the center of ADR-0020.
The shadowing `defclass`/`defmethod` forms that, for an ObjC-backed superclass,
synthesize a *real* ObjC subclass at runtime so the macOS frameworks dispatch their
callbacks into the user's Gerbil override methods. *Deriving in Gerbil = deriving in
ObjC.* Replaces the 010 stub forms.

## Context

Racket analogue: `runtime/dynamic-class.rkt` / `define-objc-subclass`. Reuses the
`objc_allocateClassPair` + IMP-install C helpers factored in 020. The emitter (040)
emits the metadata IMP-signature inference needs (superclass ObjC type encodings)
+ the class registry (`register-objc-class!`, 010). Main-thread only.

## Done when

- **Shadowing `defclass`** — `(defclass (MyView NSView) (extra-slots …) …)` where
  the superclass resolves to an ObjC-backed bound class: synthesize an ObjC subclass
  pair (name uniqued), record it in the registry, and make the Gerbil class wrap
  instances of it. For a non-ObjC superclass, fall through to Gerbil's built-in
  `defclass` cleanly.
- **Shadowing `defmethod`** (both surfaces) — an override of an inherited ObjC
  selector installs an IMP on the synthesized class whose trampoline calls the
  user's Gerbil method (marshalling args/return from the superclass's ObjC type
  encodings), so framework callbacks (`drawRect:`, delegate-style overrides) reach
  Gerbil. Non-override methods stay pure-Gerbil.
- **Ordering settled** — resolve `class_addMethod`-after-`objc_registerClassPair`:
  racket registers all methods before finalizing, but separate top-level
  `defmethod`s arrive after the class is registered. Decide lazy-registration vs.
  post-registration `class_addMethod` (legal on a registered class) and document
  the choice + any constraint it imposes on emitted/user code ordering.
- **IMP-signature inference** from the superclass ObjC type encodings (the emitter-
  supplied metadata) — `super`-dispatch (`objc_msgSendSuper`) available for the
  common "call super then extend" override.
- **Smoke:** a synthesized `NSView` subclass overriding `drawRect:` is installed in
  a window and the framework invokes the Gerbil `drawRect:` body (observable via a
  side effect / a drawn primitive count). Via gxc; full visual proof is node 090's
  drawing-canvas VM-verify.

## Notes

This is the hardest, most-novel runtime piece and the reason ADR-0020 exists — the
wrapper-only model could *call* but never *override*. Budget the session for the
encoding→signature marshalling and the registration-ordering subtlety. If it proves
too large, decompose (encoding inference vs. the form macros).
