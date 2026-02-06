import 'package:flutter/material.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

class SDisabled extends StatelessWidget {
  final Widget child;
  final bool isDisabled, disableOpacityChange;
  final double? opacityWhenDisabled;
  final void Function(Offset offset)? onTappedWhenDisabled;
  const SDisabled({
    super.key,
    required this.child,
    required this.isDisabled,
    this.disableOpacityChange = false,
    this.opacityWhenDisabled,
    this.onTappedWhenDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
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
              child: AbsorbPointer(absorbing: isDisabled, child: child),
            )
          : child,
    );
  }
}
