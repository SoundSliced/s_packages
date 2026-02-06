import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_offstage/s_offstage.dart';

///****** FocusNode with a stable role identifier preserved in release builds. *****/

/// FocusNode with a stable role identifier preserved in release builds.
class RoleFocusNode extends FocusNode {
  final String role;
  RoleFocusNode(this.role, {super.skipTraversal}) : super(debugLabel: role);
}

///********************** INTENTS DEFINITIONS **************************
/// Basic Navigation and System Intents
/// These are simple classes that represent the abstract actions we want to perform.

/// Intent triggered when the Escape key is pressed
class EscapeIntent extends Intent {
  const EscapeIntent();
}

/// Intent triggered when the Up arrow key is pressed
class NavigateUpIntent extends Intent {
  const NavigateUpIntent();
}

/// Intent triggered when the Down arrow key is pressed
class NavigateDownIntent extends Intent {
  const NavigateDownIntent();
}

/// Intent triggered when the Left arrow key is pressed
class NavigateLeftIntent extends Intent {
  const NavigateLeftIntent();
}

/// Intent triggered when the Right arrow key is pressed
class NavigateRightIntent extends Intent {
  const NavigateRightIntent();
}

/// Intent triggered when the Enter/Return key is pressed
class SubmitIntent extends Intent {
  const SubmitIntent();
}

/// Intent triggered when the Backspace key is pressed
class DeleteIntent extends Intent {
  const DeleteIntent();
}

/// Intent triggered when Ctrl/Cmd + S is pressed
class SaveIntent extends Intent {
  const SaveIntent();
}

/// Intent triggered when Ctrl/Cmd + Z is pressed
class UndoIntent extends Intent {
  const UndoIntent();
}

/// Intent triggered when Ctrl/Cmd + Y is pressed
class RedoIntent extends Intent {
  const RedoIntent();
}

/// Intent triggered when Ctrl/Cmd + A is pressed
class SelectAllIntent extends Intent {
  const SelectAllIntent();
}

/// Intent triggered when Ctrl/Cmd + C is pressed
class CopyIntent extends Intent {
  const CopyIntent();
}

/// Intent triggered when Ctrl/Cmd + V is pressed
class PasteIntent extends Intent {
  const PasteIntent();
}

/// Intent triggered when Ctrl/Cmd + X is pressed
class CutIntent extends Intent {
  const CutIntent();
}

/// Intent triggered when Tab key is pressed
class TabIntent extends Intent {
  const TabIntent();
}

/// Intent triggered when Shift + Tab is pressed
class ReverseTabIntent extends Intent {
  const ReverseTabIntent();
}

/// Intent triggered when Ctrl/Cmd + / is pressed (toggle comment)
class ToggleCommentIntent extends Intent {
  const ToggleCommentIntent();
}

/// Intent triggered when F1 is pressed (help)
class HelpIntent extends Intent {
  const HelpIntent();
}

/// Intent triggered when Space is pressed
class SpaceIntent extends Intent {
  const SpaceIntent();
}

///********************** END INTENTS DEFINITIONS **********************

///********************** KeystrokeListener WIDGET **********************
/// A versatile widget wrapper that captures keyboard events and converts them to actions.
///
/// This widget:
/// - Wraps its child with a FocusableActionDetector to capture key events
/// - Calls back an optional callback on key events
/// - Includes a hidden TextField to force focus (especially useful on Flutter Web)
/// - Includes optional visual debug feature to show which key was pressed
///
/// The hidden TextField ensures focus is maintained, which is crucial on Flutter Web
/// where the browser's default behavior is to not focus elements automatically.
///
/// Example:
/// ```dart
/// KeystrokeListener(
///   onKeyEvent: (event) => print('Key pressed: ${event.logicalKey}'),
///   child: MyWidget(),
/// )
/// ```
///********************** END KeystrokeListener DOCUMENTATION ***********
class KeystrokeListener extends StatefulWidget {
  final Widget child;
  final bool enableVisualDebug;
  final void Function(KeyDownEvent keyDownEvent)?
      onKeyEvent; // Optional callback for key events
  final FocusNode? focusNode;
  final bool requestFocusOnInit;
  final bool autoFocus;
  const KeystrokeListener({
    super.key,
    required this.child,
    this.onKeyEvent,
    this.enableVisualDebug = false,
    this.focusNode,
    this.requestFocusOnInit = true,
    this.autoFocus = true,
  });

  @override
  State<KeystrokeListener> createState() => _KeystrokeListenerState();
}

class _KeystrokeListenerState extends State<KeystrokeListener> {
  FocusNode? _focusNode;
  bool _ownsFocusNode = false;

  FocusNode get _effectiveFocusNode {
    assert(_focusNode != null, '_focusNode should never be null when building');
    return _focusNode!;
  }

  @override
  void initState() {
    super.initState();
    _configureFocusNode(widget.focusNode);
    _maybeRequestInitialFocus();
  }

  @override
  void didUpdateWidget(KeystrokeListener oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      _configureFocusNode(widget.focusNode);
    }

    if (widget.requestFocusOnInit && !oldWidget.requestFocusOnInit) {
      _maybeRequestInitialFocus();
    }
  }

  void _configureFocusNode(FocusNode? providedNode) {
    if (providedNode == null && _ownsFocusNode && _focusNode != null) {
      return;
    }

    if (_focusNode == providedNode && providedNode != null) {
      return;
    }

    if (_focusNode != null) {
      _focusNode!.onKeyEvent = null;
      _focusNode!.removeListener(_handleFocusChange);
      if (_ownsFocusNode) {
        _focusNode!.dispose();
      }
    }

    if (providedNode != null) {
      _focusNode = providedNode;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _focusNode!.addListener(_handleFocusChange);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (widget.enableVisualDebug) {
      //show snackbar with pressed key
      final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
      final isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      String modifiers = '';
      if (isCtrlPressed) modifiers += 'Ctrl+';
      if (isMetaPressed) modifiers += 'Cmd+';
      if (isShiftPressed) modifiers += 'Shift+';

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Pressed: $modifiers${event.logicalKey.keyLabel}')),
      );
    }

    widget.onKeyEvent?.call(event);
    // Return ignored so that the event continues to propagate (bubbling)
    // and can trigger Shortcuts defined in the Actions/Shortcuts widgets.
    return KeyEventResult.ignored;
  }

  void _handleFocusChange() {
    if (_effectiveFocusNode.hasPrimaryFocus) {
      debugPrint(">>>>> _focusNode has primary focus!");
    }
  }

  void _maybeRequestInitialFocus() {
    if (!widget.requestFocusOnInit) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _effectiveFocusNode.requestFocus();
      FocusScope.of(context).nextFocus(); // Equivalent to pressing TAB
    });
  }

  @override
  void dispose() {
    if (_focusNode != null) {
      _focusNode!.onKeyEvent = null;
      _focusNode!.removeListener(_handleFocusChange);
      if (_ownsFocusNode) {
        _focusNode!.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        EscapeIntent:
            CallbackAction(onInvoke: (_) => debugPrint('ESC Action invoked!')),
        NavigateUpIntent: CallbackAction(
            onInvoke: (_) => debugPrint('Navigate Up Action invoked!')),
        NavigateDownIntent: CallbackAction(
            onInvoke: (_) => debugPrint('Navigate Down Action invoked!')),
        NavigateLeftIntent: CallbackAction(
            onInvoke: (_) => debugPrint('Navigate Left Action invoked!')),
        NavigateRightIntent: CallbackAction(
            onInvoke: (_) => debugPrint('Navigate Right Action invoked!')),
        SubmitIntent: CallbackAction(
            onInvoke: (_) => debugPrint('Submit Action invoked!')),
        DeleteIntent: CallbackAction(
            onInvoke: (_) => debugPrint('Delete Action invoked!')),
        SaveIntent:
            CallbackAction(onInvoke: (_) => debugPrint('Save Action invoked!')),
        UndoIntent:
            CallbackAction(onInvoke: (_) => debugPrint('Undo Action invoked!')),
        RedoIntent:
            CallbackAction(onInvoke: (_) => debugPrint('Redo Action invoked!')),
        SelectAllIntent: CallbackAction(
            onInvoke: (_) => debugPrint('SelectAll Action invoked!')),
        CopyIntent:
            CallbackAction(onInvoke: (_) => debugPrint('Copy Action invoked!')),
        PasteIntent: CallbackAction(
            onInvoke: (_) => debugPrint('Paste Action invoked!')),
        CutIntent:
            CallbackAction(onInvoke: (_) => debugPrint('Cut Action invoked!')),
        TabIntent:
            CallbackAction(onInvoke: (_) => debugPrint('Tab Action invoked!')),
        ReverseTabIntent: CallbackAction(
            onInvoke: (_) => debugPrint('ReverseTab Action invoked!')),
        ToggleCommentIntent: CallbackAction(
            onInvoke: (_) => debugPrint('ToggleComment Action invoked!')),
        HelpIntent:
            CallbackAction(onInvoke: (_) => debugPrint('Help Action invoked!')),
        SpaceIntent: CallbackAction(
            onInvoke: (_) => debugPrint('Space Action invoked!')),
      },
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          // Navigation intents
          LogicalKeySet(LogicalKeyboardKey.arrowUp): NavigateUpIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowDown): NavigateDownIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): NavigateLeftIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): NavigateRightIntent(),

          // System intents
          LogicalKeySet(LogicalKeyboardKey.escape): EscapeIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): SubmitIntent(),
          LogicalKeySet(LogicalKeyboardKey.backspace): DeleteIntent(),
          LogicalKeySet(LogicalKeyboardKey.space): SpaceIntent(),

          // Tab intents
          LogicalKeySet(LogicalKeyboardKey.tab): TabIntent(),
          LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
              ReverseTabIntent(),

          // Edit intents (Ctrl/Cmd + key)
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
              SaveIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
              UndoIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY):
              RedoIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
              SelectAllIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
              CopyIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
              PasteIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyX):
              CutIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.slash):
              ToggleCommentIntent(),

          // Meta (Cmd on Mac) variants for macOS
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS):
              SaveIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyZ):
              UndoIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyY):
              RedoIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyA):
              SelectAllIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC):
              CopyIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyV):
              PasteIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyX):
              CutIntent(),

          // Function keys
          LogicalKeySet(LogicalKeyboardKey.f1): HelpIntent(),
        },
        child: Focus(
          focusNode: _effectiveFocusNode,
          autofocus: widget.autoFocus,
          onKeyEvent: _handleKeyEvent,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                SOffstage(
                  isOffstage: true,
                  showLoadingIndicator: false,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TextField(
                      autofocus: widget.requestFocusOnInit,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      style: TextStyle(fontSize: 12),
                      maxLines: 1,
                    ),
                  ),
                ),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//************************************************* */
