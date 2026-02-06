/// Helper functions for bottom sheet animations
///
/// This file contains methods that help create smooth animations
/// for expanding and collapsing the bottom sheet without requiring
/// AnimationController setup or StatefulWidget integration.
part of '../s_modal_libs.dart';

/// Creates a smooth animation effect without needing a TickerProvider
///
/// This function creates a timer-based animation that updates at approximately 60fps.
/// It's used when traditional Flutter animations aren't suitable, such as when
/// animating values across widget boundaries or outside the build context.
///
/// Parameters:
/// - startValue: The initial value of the animation
/// - endValue: The target value to animate toward
/// - duration: How long the animation should take to complete
/// - curve: The easing curve to use (defaults to easeOutCubic for natural motion)
/// - onUpdate: Callback function that receives the animated value on each frame
/// - onComplete: Optional callback that executes when animation finishes
///
/// Example:
/// ```dart
/// createSmoothAnimation(
///   startValue: 200.0,
///   endValue: 400.0,
///   duration: Duration(milliseconds: 300),
///   onUpdate: (value) => _modalSheetHeightNotifier.state = value,
///   onComplete: () => setState(() { isExpanded = true; })
/// );
/// ```
void createSmoothAnimation({
  required double startValue,
  required double endValue,
  required Duration duration,
  Curve curve = Curves.easeOutCubic,
  required Function(double value) onUpdate,
  VoidCallback? onComplete,
}) {
  final startTime = DateTime.now();
  final totalChange = endValue - startValue;

  if (_showDebugPrints) {
    debugPrint(
        '[🎬 ANIM START] start=$startValue | end=$endValue | duration=${duration.inMilliseconds}ms | curve=$curve');
  }

  // Target ~60fps with 16ms intervals for smooth animation
  const frameInterval = Duration(milliseconds: 16);

  // Create a periodic timer for smooth animation
  Timer.periodic(frameInterval, (timer) {
    // Calculate progress based on elapsed time (0.0 to 1.0)
    final elapsedMilliseconds =
        DateTime.now().difference(startTime).inMilliseconds;
    final normalizedProgress =
        (elapsedMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    // Apply easing curve for natural motion feeling
    final easedProgress = curve.transform(normalizedProgress);

    // Calculate current value
    final currentValue = startValue + (totalChange * easedProgress);

    // Log every 5th frame to avoid spam
    if (elapsedMilliseconds % 80 < 20 && _showDebugPrints) {
      debugPrint(
          '[🎬 ANIM] progress=${(normalizedProgress * 100).toStringAsFixed(0)}% | '
          'value=${currentValue.toStringAsFixed(1)} | '
          'elapsed=${elapsedMilliseconds}ms');
    }

    // Call the update function with current value
    onUpdate(currentValue);

    // Stop timer when animation completes
    if (normalizedProgress >= 1.0) {
      timer.cancel();
      if (_showDebugPrints) {
        debugPrint('[🎬 ANIM COMPLETE] final value=$currentValue');
      }
      onComplete?.call();
    }
  });
}
