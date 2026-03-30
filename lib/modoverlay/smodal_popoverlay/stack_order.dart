/// Shared activation-order clock used to keep PopOverlay and s_modal
/// layering consistent across the combined root overlay.
///
/// Each call to [next] returns a strictly increasing integer so that
/// interleaved overlays can be ordered deterministically even when their
/// stack levels match. This avoids flicker when multiple systems register
/// layers in the same frame.
class OverlayActivationOrder {
  static int _counter = 0;

  /// Returns a monotonically increasing activation order value.
  static int next() => ++_counter;
}
