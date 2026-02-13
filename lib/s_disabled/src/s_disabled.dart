import 'package:s_packages/s_packages.dart';

/// A grayscale color filter matrix for disabled state visual feedback.
const ColorFilter _grayscaleFilter = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

class SDisabled extends StatelessWidget {
  final Widget child;
  final bool isDisabled, disableOpacityChange;
  final double? opacityWhenDisabled;
  final void Function(Offset offset)? onTappedWhenDisabled;

  /// When true, applies a grayscale filter to the child when disabled.
  final bool applyGrayscale;

  /// Semantic label announced by screen readers when the widget is disabled.
  final String? disabledSemanticLabel;

  /// Alternative widget to display when disabled.
  /// If provided, this widget replaces [child] when [isDisabled] is true.
  final Widget? disabledChild;

  const SDisabled({
    super.key,
    required this.child,
    required this.isDisabled,
    this.disableOpacityChange = false,
    this.opacityWhenDisabled,
    this.onTappedWhenDisabled,
    this.applyGrayscale = false,
    this.disabledSemanticLabel,
    this.disabledChild,
  });

  @override
  Widget build(BuildContext context) {
    final activeChild =
        (isDisabled && disabledChild != null) ? disabledChild! : child;

    Widget result = AnimatedOpacity(
      duration: 0.3.sec,
      opacity: disableOpacityChange == true
          ? 1
          : isDisabled == true
              ? opacityWhenDisabled ?? 0.3
              : 1,
      child: isDisabled == true
          ? GestureDetector(
              onTapDown: (details) {
                if (onTappedWhenDisabled != null) {
                  onTappedWhenDisabled!(details.globalPosition);
                }
              },
              child: AbsorbPointer(absorbing: isDisabled, child: activeChild),
            )
          : activeChild,
    );

    if (isDisabled && applyGrayscale) {
      result = ColorFiltered(
        colorFilter: _grayscaleFilter,
        child: result,
      );
    }

    if (isDisabled && disabledSemanticLabel != null) {
      result = Semantics(
        label: disabledSemanticLabel,
        child: result,
      );
    }

    return result;
  }
}
