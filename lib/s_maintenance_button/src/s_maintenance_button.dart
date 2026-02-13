import 'package:s_packages/s_packages.dart';

class SMaintenanceButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isOnMaintenance;
  final Color? activeColor;
  final Color? nonActiveColor;

  /// Custom icon to display instead of the default build icon.
  final Widget? icon;

  /// When true, shows a confirmation dialog before toggling maintenance.
  final bool showConfirmation;

  /// Custom message for the confirmation dialog.
  final String? confirmationMessage;

  const SMaintenanceButton({
    super.key,
    this.onTap,
    this.isOnMaintenance = false,
    this.activeColor,
    this.nonActiveColor,
    this.icon,
    this.showConfirmation = false,
    this.confirmationMessage,
  });

  void _handleTap(BuildContext context) {
    if (showConfirmation) {
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm'),
          content: Text(confirmationMessage ??
              (isOnMaintenance
                  ? 'Disable maintenance mode?'
                  : 'Enable maintenance mode?')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) {
          onTap?.call();
        }
      });
    } else {
      onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return SizedBox.shrink();
    }

    final activeColor = this.activeColor ?? Colors.red;

    return SDisabled(
      isDisabled: kReleaseMode,
      child: SButton(
        onTap: (position) => _handleTap(context),
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
              icon: icon ??
                  Icon(
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
