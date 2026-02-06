import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pop_overlay/pop_overlay.dart';
import 'package:s_context_menu/s_context_menu.dart';
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

  void _log(String msg) {
    debugPrint('[EscapeKeyHandler] $msg');
  }

  @override
  void initState() {
    super.initState();
    _effectiveKey = widget.dismissKey ?? LogicalKeyboardKey.escape;
    // _log('initState: dismissKey=${_effectiveKey.debugName}');
    _attachGlobalHandlers();
  }

  @override
  void dispose() {
    _detachGlobalHandlers();
    super.dispose();
  }

  void _handleDismiss(String source) {
    // _log('Key captured by $source');
    // Call the optional callback if provided
    widget.onKeyEvent?.call();

    if (PopOverlay.isActive) {
      final overlays = PopOverlay.controller.state;
      if (overlays.isNotEmpty) {
        final last = overlays.last;
        _log('Dismissing overlay id=${last.id}');
        PopOverlay.dismissPop(last.id);
      }
    }
  }

  bool _hardwareHandler(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == _effectiveKey &&
        event is! KeyRepeatEvent) {
      // Ignore if any context menu is open
      if (SContextMenu.hasAnyOpenMenus == true) {
        return false;
      }

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

  void _attachGlobalHandlers() {
    // Primary handler - works globally without focus
    HardwareKeyboard.instance.addHandler(_hardwareHandler);
    // _log('HardwareKeyboard handler attached');
  }

  void _detachGlobalHandlers() {
    HardwareKeyboard.instance.removeHandler(_hardwareHandler);

    if (kIsWeb && _htmlListener != null) {
      html.window.removeEventListener('keydown', _htmlListener, true);
      _htmlListener = null;
    }

    _log('Global handlers detached');
  }

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
  Widget build(BuildContext context) {
    // Simple passthrough - no focus nodes, no gesture detection, no complexity
    return widget.child;
  }
}
