/// Platform-neutral snapshot of everything the player wants this frame.
/// Keyboard/mouse and touch controllers both produce this state.
class InputState {
  InputState();

  /// Horizontal move intent, -1..1.
  double moveAxis = 0;

  bool jump = false;
  bool crouch = false;
  bool grab = false;
  bool fire = false;
  bool interact = false;
  bool slowmo = false;
  bool slot1 = false;
  bool slot2 = false;
  bool pause = false;

  /// Aim direction in world units (normalised intent; may be zero on
  /// touch before the first aim drag).
  double aimX = 1;
  double aimY = 0;

  /// True once per-press edges should be consumed by edge triggers.
  bool jumpEdge = false;
  bool interactEdge = false;
  bool slowmoEdge = false;
  bool pauseEdge = false;

  void clearEdges() {
    jumpEdge = false;
    interactEdge = false;
    slowmoEdge = false;
    pauseEdge = false;
    slot1 = false;
    slot2 = false;
  }
}
