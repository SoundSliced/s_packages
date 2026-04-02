/// Escape Key Listener for Pop Overlays
///
/// This file implements global escape key handling for pop overlays.
/// It provides reliable dismissal of overlays via the Escape key without
/// requiring focus management or complex widget hierarchies.
///
/// Key Features:
/// - Global HardwareKeyboard handler for reliable key detection
/// - Works across modal boundaries and focus states
/// - Dismisses the topmost visible overlay that allows escape dismissal
/// - Integrates with context menus to avoid conflicts
/// - Optional visual debug mode for development
/// - Web fallback support for edge cases
///
/// The implementation uses HardwareKeyboard.instance.addHandler() for
/// primary key detection, ensuring it works regardless of which widget
/// currently has focus. This makes it much more reliable than traditional
/// focus-based approaches for modal dismissal.
///
/// Usage:
/// The EscapeKeyHandler is automatically installed by the PopOverlay
/// activator and requires no manual setup for basic usage.
library;

import 'package:s_packages/s_packages.dart';
// ignore: depend_on_referenced_packages
import 'package:universal_html/universal_html.dart' as html;

/// Simple, reliable escape key handler that works globally without focus dependencies
///
/// This approach abandons complex focus management in favor of:
/// - Global HardwareKeyboard handler (primary, works everywhere)
/// - HTML window listener (web fallback for edge cases)
/// - No focus node complications
///
/// Much more reliable than trying to manage focus in modal-heavy applications.
///
/// NOTE: This is used by PopOverlay and is auto-installed via the internal
/// activator. If you need EscapeKeyHandler without PopOverlay, wrap your app
/// with EscapeKeyHandler manually.
class EscapeKeyHandler extends StatefulWidget {
  final Widget child;
  final Function? onKeyEvent;
  final LogicalKeyboardKey? dismissKey;
  final bool enableVisualDebug;

  const EscapeKeyHandler({
    super.key,
    required this.child,
    this.dismissKey,
    this.onKeyEvent,
    this.enableVisualDebug = false,
  });

  @override
  State<EscapeKeyHandler> createState() => _EscapeKeyHandlerState();
}

class _EscapeKeyHandlerState extends State<EscapeKeyHandler> {
  late final LogicalKeyboardKey _effectiveKey;
  dynamic _htmlListener;

  // Lightweight debug logger for this handler.
  void _log(String msg) {
    // Keep logging centralized for easier toggling.
    // debugPrint('[EscapeKeyHandler] $msg');
  }

  @override
  // Initialize key mapping and install global handlers.
  void initState() {
    super.initState();
    // Resolve the effective key (defaults to Escape).
    _effectiveKey = widget.dismissKey ?? LogicalKeyboardKey.escape;
    // _log('initState: dismissKey=${_effectiveKey.debugName}');
    _log('initState: attaching global handlers');
    _attachGlobalHandlers();
  }

  @override
  // Remove global handlers when the widget is disposed.
  void dispose() {
    // Ensure key handlers are detached to prevent leaks.
    _detachGlobalHandlers();
    super.dispose();
  }

  // Execute the dismissal flow for the topmost eligible overlay.
  void _handleDismiss(String source) {
    // _log('Key captured by $source');
    // Call the optional callback if provided
    widget.onKeyEvent?.call();

    if (PopOverlay.isActive) {
      // Walk overlays from top to bottom to find the first visible one.
      final overlays = PopOverlay.controller.state;
      if (overlays.isNotEmpty) {
        // Find the topmost overlay that allows escape key dismissal
        for (int i = overlays.length - 1; i >= 0; i--) {
          final overlay = overlays[i];
          // Skip invisible overlays
          if (PopOverlay.invisibleController.state.contains(overlay.id)) {
            continue;
          }
          if (overlay.shouldDismissOnEscapeKey) {
            _log('Dismissing overlay id=${overlay.id}');
            PopOverlay.dismissPop(overlay.id);
          }
          // Whether or not it's dismissable, stop at the topmost visible overlay
          break;
        }
      }
    }
  }

  // Primary HardwareKeyboard handler.
  bool _hardwareHandler(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == _effectiveKey &&
        event is! KeyRepeatEvent) {
      // Avoid dismissing overlays while context menus are open.
      // Ignore if any context menu is open
      if (SContextMenu.hasAnyOpenMenus == true) {
        return false;
      }

      // Execute dismissal and optional debug UI.
      _handleDismiss('HardwareKeyboard');

      // Visual debug if enabled
      if (widget.enableVisualDebug) {
        _showKeyDebug(event.logicalKey.keyLabel);
      }

      return true;

// Mark as handled
    }
    return false;
  }

  // Attach global handlers (HardwareKeyboard and web fallback).
  void _attachGlobalHandlers() {
    // Primary handler - works globally without focus
    HardwareKeyboard.instance.addHandler(_hardwareHandler);
    _log('Global handlers attached');
  }

  // Detach global handlers to avoid leaks.
  void _detachGlobalHandlers() {
    HardwareKeyboard.instance.removeHandler(_hardwareHandler);

    if (kIsWeb && _htmlListener != null) {
      // Clean up web listener if one was used.
      html.window.removeEventListener('keydown', _htmlListener, true);
      _htmlListener = null;
    }

    _log('Global handlers detached');
  }

  // Visual debug overlay that shows the last captured key.
  void _showKeyDebug(String keyName) {
    PopOverlay.addPop(
      PopOverlayContent(
        id: 'ek_debug_key_${DateTime.now().millisecondsSinceEpoch}',
        duration: const Duration(milliseconds: 800),
        shouldDismissOnBackgroundTap: false,
        shouldAnimatePopup: false,
        widget: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Text(
              '🎯 $keyName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  // Simple passthrough build.
  Widget build(BuildContext context) {
    // No focus nodes or gestures needed here.
    // Simple passthrough - no focus nodes, no gesture detection, no complexity
    return widget.child;
  }
}
