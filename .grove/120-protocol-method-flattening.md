# 120-protocol-method-flattening

**Kind:** work

## Origin

Deferred from an inbox observation captured at 100/050 (scenekit-viewer),
2026-06-08.

## Goal

Make the gerbil emitter flatten conformed-protocol instance methods/properties
onto each bound class, removing the need for app-local raw-`msgSend` shims.

## Context

The gerbil emitter emits a class's **own** methods/properties but does **not**
flatten methods/properties declared in the protocols the class conforms to.

Example: `SCNNode` has 0 `instance_methods` in IR + 56 own properties, but
`runAction:` (declared on the `SCNActionable` protocol) and `SCNView`'s
`autoenablesDefaultLighting` (declared on `SCNSceneRenderer`) are unreachable —
they live on conformed protocols. The **chez** and **racket** emitters surface
these; **gerbil** does not.

100/050 worked around it with an app-local `begin-ffi` raw-`msgSend` shim for
`runAction:` + `setAutoenablesDefaultLighting:`. That shim is a smell; it should
disappear once the emitter is fixed.

### Proposed fix

For each bound class, walk its conformed-protocol chain and emit those instance
methods/properties onto the class — with the **dual surface** (`{}` /
`:std/generic`) and **diamond-dedup** already used by the 060/020 shared-generics
facade.

## Done when

- Emitter flattens conformed-protocol instance methods/properties onto each bound
  class (dual surface + diamond-dedup).
- scenekit-viewer's app-local raw-`msgSend` shim removed; app rebuilt +
  VM-verified still PASS.
- Emission tests cover a protocol-provided method on a bound class.
- Other ported apps re-checked for latent reliance on protocol methods they
  happened not to exercise.

## Notes

Likely affects other apps relying on protocol-provided behaviour. Sequenced after
the sample-app portfolio (100) and knowledge/README (110).
