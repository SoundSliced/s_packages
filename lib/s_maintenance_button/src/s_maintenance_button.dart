 
import 'package:s_packages/s_packages.dart';

class SMaintenanceButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isOnMaintenance;
  final Color? activeColor;
  final Color? nonActiveColor;
  const SMaintenanceButton({
    super.key,
    this.onTap,
    this.isOnMaintenance = false,
    this.activeColor,
    this.nonActiveColor,
  });

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return SizedBox.shrink();
    }

    final activeColor = this.activeColor ?? Colors.red;

    return SDisabled(
      isDisabled: kReleaseMode,
      child: SButton(
        onTap: (position) => onTap?.call(),
        child: SizedBox(
          height: 23,
          width: 23,
          child: Glow2(
            key: ValueKey(
                '${isOnMaintenance}_${this.activeColor}_$nonActiveColor'),
            glowColor: !isOnMaintenance ? Colors.transparent : activeColor,
            glowRadiusFactor: !isOnMaintenance ? 0 : 0.5,
            duration: 2.sec,
            animate: isOnMaintenance,
            repeat: true,
            glowCount: 2,
            startDelay: 0.2.sec,
            curve: Curves.easeInOut,
            child: CircleButton(
              clickAreaMargin: 0.allPad,
              backgroundColor:
                  !isOnMaintenance ? Colors.white : activeColor.lighten(0.25),
              tapColor: Colors.white70,
              iconPadding: 0.allPad,
              size: 20,
              icon: Icon(
                Icons.build_circle_rounded,
                color: (isOnMaintenance
                        ? activeColor.darken(0.15)
                        : (nonActiveColor ?? Colors.blue.shade900))
                    .withValues(alpha: 1),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
