import 'package:s_packages/s_packages.dart';

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
  final void Function(KeyDownEvent keyDownEvent)? onKeyEvent; // Optional callback for key events
  final FocusNode? focusNode;
  final bool requestFocusOnInit;
  final bool autoFocus;

  /// Additional shortcut bindings scoped to this listener.
  ///
  /// These are merged after the built-in shortcuts, so callers can override
  /// defaults such as Cmd/Ctrl + A when a screen needs an app-specific action.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Whether the built-in navigation/editing shortcuts should be registered.
  ///
  /// Keep this enabled for the usual KeystrokeListener behavior. Disable it
  /// when a caller wants this listener to expose only [shortcuts].
  final bool includeDefaultShortcuts;

  /// Custom action handlers for keyboard intents. When provided, these override
  /// the default debugPrint actions. Keys are Intent types, values are callbacks.
  ///
  /// Custom intent types that are not part of KeystrokeListener's built-in
  /// intent set are also registered automatically with Flutter's [Actions]
  /// system, allowing caller-provided [shortcuts] or ancestor [Shortcuts]
  /// widgets to invoke them without manual raw-key handling.
  final Map<Type, VoidCallback>? actionHandlers;

  /// When provided and returns true, the listener will not steal focus back
  /// from descendant FocusNodes (e.g. TextFields inside the child subtree).
  ///
  /// Use this to suppress the automatic refocus behavior while an input
  /// inside the listener is being edited. For example, pass a callback that
  /// checks a scheduler's keystroke-pause flag.
  ///
  /// When null (the default), the listener always steals focus back from
  /// descendants, maintaining the original aggressive refocus behavior.
  final bool Function()? shouldSuppressAutoRefocus;

  const KeystrokeListener({
    super.key,
    required this.child,
    this.onKeyEvent,
    this.enableVisualDebug = false,
    this.focusNode,
    this.requestFocusOnInit = true,
    this.autoFocus = true,
    this.shortcuts,
    this.includeDefaultShortcuts = true,
    this.actionHandlers,
    this.shouldSuppressAutoRefocus,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pressed: $modifiers${event.logicalKey.keyLabel}')));
    }

    widget.onKeyEvent?.call(event);
    // Return ignored so that the event continues to propagate (bubbling)
    // and can trigger Shortcuts defined in the Actions/Shortcuts widgets.
    return KeyEventResult.ignored;
  }

  void _handleFocusChange() {
    if (_effectiveFocusNode.hasPrimaryFocus && widget.enableVisualDebug) {
      debugPrint(">>>>> _focusNode has primary focus!");
    } else if (_effectiveFocusNode.hasFocus &&
        widget.shouldSuppressAutoRefocus != null &&
        widget.shouldSuppressAutoRefocus!()) {
      // A descendant FocusNode (e.g. a TextField/TimeInput inside this
      // listener's subtree) now has primary focus AND the caller has
      // signalled that auto-refocus should be suppressed (e.g. scheduler
      // keystroke pause is active) — do NOT steal it back.
      return;
    } else {
      // Focus left the entire subtree — optionally refocus this listener
      // so keyboard shortcuts continue to work after clicks outside.
      // Refocus only when the caller has opted into focus management via
      // requestFocusOnInit to avoid fighting child text inputs.
      if (!widget.requestFocusOnInit && !widget.autoFocus) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_effectiveFocusNode.hasPrimaryFocus) {
          _effectiveFocusNode.requestFocus();
        }
      });
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
    final handlers = widget.actionHandlers;

    CallbackAction<T> action<T extends Intent>(String label) {
      final callback = handlers?[T];
      return CallbackAction<T>(
        onInvoke: (_) {
          if (callback != null) {
            callback();
          } else {
            if (widget.enableVisualDebug) {
              debugPrint('$label Action invoked!');
            }
          }
          return null;
        },
      );
    }

    final actions = <Type, Action<Intent>>{
      EscapeIntent: action<EscapeIntent>('ESC'),
      NavigateUpIntent: action<NavigateUpIntent>('Navigate Up'),
      NavigateDownIntent: action<NavigateDownIntent>('Navigate Down'),
      NavigateLeftIntent: action<NavigateLeftIntent>('Navigate Left'),
      NavigateRightIntent: action<NavigateRightIntent>('Navigate Right'),
      SubmitIntent: action<SubmitIntent>('Submit'),
      DeleteIntent: action<DeleteIntent>('Delete'),
      SaveIntent: action<SaveIntent>('Save'),
      UndoIntent: action<UndoIntent>('Undo'),
      RedoIntent: action<RedoIntent>('Redo'),
      SelectAllIntent: action<SelectAllIntent>('SelectAll'),
      CopyIntent: action<CopyIntent>('Copy'),
      PasteIntent: action<PasteIntent>('Paste'),
      CutIntent: action<CutIntent>('Cut'),
      TabIntent: action<TabIntent>('Tab'),
      ReverseTabIntent: action<ReverseTabIntent>('ReverseTab'),
      ToggleCommentIntent: action<ToggleCommentIntent>('ToggleComment'),
      HelpIntent: action<HelpIntent>('Help'),
      SpaceIntent: action<SpaceIntent>('Space'),
    };

    handlers?.forEach((intentType, callback) {
      actions[intentType] = CallbackAction<Intent>(
        onInvoke: (_) {
          callback();
          return null;
        },
      );
    });

    final shortcuts = <ShortcutActivator, Intent>{
      if (widget.includeDefaultShortcuts) ..._defaultShortcuts,
      ...?widget.shortcuts,
    };

    return Actions(
      actions: actions,
      child: Shortcuts(
        shortcuts: shortcuts,
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
                    decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 2)),
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

  static const Map<ShortcutActivator, Intent> _defaultShortcuts = {
    // Navigation intents
    SingleActivator(LogicalKeyboardKey.arrowUp): NavigateUpIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown): NavigateDownIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft): NavigateLeftIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight): NavigateRightIntent(),

    // System intents
    SingleActivator(LogicalKeyboardKey.escape): EscapeIntent(),
    SingleActivator(LogicalKeyboardKey.enter): SubmitIntent(),
    SingleActivator(LogicalKeyboardKey.backspace): DeleteIntent(),
    SingleActivator(LogicalKeyboardKey.space): SpaceIntent(),

    // Tab intents
    SingleActivator(LogicalKeyboardKey.tab): TabIntent(),
    SingleActivator(LogicalKeyboardKey.tab, shift: true): ReverseTabIntent(),

    // Edit intents (Ctrl/Cmd + key)
    SingleActivator(LogicalKeyboardKey.keyS, control: true): SaveIntent(),
    SingleActivator(LogicalKeyboardKey.keyS, meta: true): SaveIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true): RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyY, control: true): RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyY, meta: true): RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyA, control: true): SelectAllIntent(),
    SingleActivator(LogicalKeyboardKey.keyA, meta: true): SelectAllIntent(),
    SingleActivator(LogicalKeyboardKey.keyC, control: true): CopyIntent(),
    SingleActivator(LogicalKeyboardKey.keyC, meta: true): CopyIntent(),
    SingleActivator(LogicalKeyboardKey.keyV, control: true): PasteIntent(),
    SingleActivator(LogicalKeyboardKey.keyV, meta: true): PasteIntent(),
    SingleActivator(LogicalKeyboardKey.keyX, control: true): CutIntent(),
    SingleActivator(LogicalKeyboardKey.keyX, meta: true): CutIntent(),
    SingleActivator(LogicalKeyboardKey.slash, control: true): ToggleCommentIntent(),
    SingleActivator(LogicalKeyboardKey.slash, meta: true): ToggleCommentIntent(),

    // Function keys
    SingleActivator(LogicalKeyboardKey.f1): HelpIntent(),
  };
}

//************************************************* */
