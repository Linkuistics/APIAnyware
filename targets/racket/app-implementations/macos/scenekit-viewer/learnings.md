# scenekit-viewer x racket

**2026-06-02 (Racket 9.2 + ffi2, native dispatch) — first VM verification:**
- 🟢 Toolbar (shape popup / Color…) + SCNView render a lit, continuously-rotating
  3D cube (Metal-backed SceneKit: SCNScene, geometry, material, lighting).
- 🟢 Switching the shape popup (Cube → Torus) rebuilds the scene geometry live.
- TestAnyware VM (macOS 26.3).
