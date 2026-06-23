#!/usr/bin/env python3
"""Spike 2 generator — emit a full-AppKit+Foundation-scale CLOS binding to measure
SBCL compile cost (the gerbil ADR-0023 generic-explosion question).

Writes three files mirroring the emission shape:
  spike-classes.lisp   — C metaclass-backed classes in a manifest graph
  spike-generics.lisp   — G `defgeneric` (one per selector; pure declarations)
  spike-methods.lisp    — M `defmethod` over (class x selector), trivial bodies

Defaults are calibrated to gerbil's documented scale (6,496 selectors) plus a
generous method multiplier. Run: python3 gen-binding.py && sbcl --non-interactive --load 2-compile-cost.lisp
"""
import random

G, C, M = 6500, 2000, 40000   # generics, classes, methods
random.seed(42)

with open("spike-classes.lisp", "w") as f:
    f.write("(defpackage :ns (:use))\n(in-package :cl-user)\n")
    f.write("(defclass objc-class (standard-class) ())\n")
    f.write("(defmethod sb-mop:validate-superclass ((c objc-class) (s standard-class)) t)\n")
    f.write("(defclass ns::ns-object () ((ptr :initform nil)) (:metaclass objc-class))\n")
    for i in range(C):
        sup = "ns::ns-object" if i < 50 else f"ns::cls-{random.randint(0, i-1)}"
        f.write(f"(defclass ns::cls-{i} ({sup}) () (:metaclass objc-class))\n")

with open("spike-generics.lisp", "w") as f:
    f.write("(in-package :cl-user)\n")
    for s in range(G):
        f.write(f"(defgeneric ns::sel-{s} (self))\n")

with open("spike-methods.lisp", "w") as f:
    f.write("(in-package :cl-user)\n")
    for m in range(M):
        f.write(f"(defmethod ns::sel-{random.randint(0, G-1)} "
                f"((self ns::cls-{random.randint(0, C-1)})) (declare (ignore self)) {m})\n")

print(f"generated {G} generics, {C} classes, {M} methods")
