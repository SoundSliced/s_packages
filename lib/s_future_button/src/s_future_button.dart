import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:rxdart/subjects.dart';
import 'package:s_packages/s_packages.dart';

part 'rouded_loading_button.dart';

/// A customizable button widget that handles asynchronous operations with automatic loading states.
///
/// The [onTap] callback returns a `Future<bool?>` to control the button's behavior:
/// - Returns `true` or completes successfully: Shows success animation
/// - Returns `false`: Shows error state with 'Validation failed' message
/// - Returns `null`: Resets button without showing success animation (silent dismissal)
/// - Throws exception: Shows error state with the exception message
///
/// Example usage:
/// ```dart
/// SFutureButton(
///   onTap: () async {
///     // Perform validation
///     if (someCondition) return null; // Dismiss without success
///     if (!isValid) return false; // Show error
///
///     // Perform the actual operation
///     await someAsyncOperation();
///     return true; // Show success animation
///   },
///   onPostSuccess: () {
///     // Called only when onTap returns true
///     print('Operation completed successfully');
///   },
/// )
/// ```
class SFutureButton extends StatefulWidget {
  final Future<bool?> Function()? onTap;
  final ValueChanged<String>? onPostError;
  final VoidCallback? onPostSuccess;

  /// The text displayed when [icon] is not the only button content.
  final String? label;

  /// The style applied to [label].
  ///
  /// It is merged with the default bold, white label style, so only the
  /// properties that need to differ have to be supplied.
  final TextStyle? labelStyle;
  final Widget? icon;
  final double? height, width;
  final bool isEnabled, isElevatedButton, showErrorMessage;
  final Color? bgColor, iconColor;
  final Color? successColor, errorColor;
  final IconData successIcon, errorIcon;
  final double? borderRadius;
  final FocusNode? focusNode;
  final void Function(bool)? onFocusChange;

  /// An accessible name for the button. Defaults to [label] or `Tap`.
  final String? semanticsLabel;

  final double? loadingCircleSize;

  /// Duration to display the success state before resetting.
  /// Defaults to 400ms.
  final Duration? successDuration;

  /// Duration to display the error state before resetting.
  /// Defaults to 1500ms.
  final Duration? errorDuration;

  /// Custom widget to display while loading. Replaces the default
  /// circular progress indicator inside the button.
  final Widget? loadingWidget;

  const SFutureButton({
    super.key,
    this.onTap,
    this.label,
    this.labelStyle,
    this.icon,
    this.height,
    this.width,
    this.isEnabled = true,
    this.isElevatedButton = true,
    this.showErrorMessage = true,
    this.bgColor,
    this.iconColor,
    this.successColor,
    this.errorColor,
    this.successIcon = Icons.check,
    this.errorIcon = Icons.close,
    this.borderRadius,
    this.onPostError,
    this.onPostSuccess,
    this.focusNode,
    this.onFocusChange,
    this.semanticsLabel,
    this.loadingCircleSize,
    this.successDuration,
    this.errorDuration,
    this.loadingWidget,
  });

  @override
  State<SFutureButton> createState() => _SFutureButtonState();
}

class _SFutureButtonState extends State<SFutureButton> {
  // Individual controllers for each button instance - survives hot reload
  late final _SFutureButtonController _controller = _SFutureButtonController();
  int _contentRevision = 0;
  int _operationId = 0;
  bool _isHandlingTap = false;

  bool _isCurrentOperation(int operationId) =>
      mounted && !_controller.isDisposed && operationId == _operationId;

  @override
  void didUpdateWidget(covariant SFutureButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label ||
        oldWidget.labelStyle != widget.labelStyle ||
        oldWidget.icon != widget.icon) {
      // Widget updates normally rebuild the Text instance. The revision also
      // gives AnimatedSwitcher a new identity, so a changed label or style is
      // never retained by an existing animated child.
      _contentRevision++;
    }
  }

  @override
  void dispose() {
    _operationId++;
    _controller.dispose();
    super.dispose();
  }

  // Handle the Future execution as an instance method
  Future<void> _handleTap() async {
    if (widget.onTap == null || _isHandlingTap) return;

    final operationId = ++_operationId;
    _isHandlingTap = true;

    try {
      // Execute the onTap callback and get the result
      final result = await widget.onTap!();
      if (!_isCurrentOperation(operationId)) return;

      // Handle the result
      if (result == false) {
        // Validation failed - show error
        throw 'Validation failed';
      } else if (result == null) {
        // Silent dismissal - reset without showing success
        _controller.reset();
        return;
      }
      // result == true or any other truthy value - show success
      await _controller.success(
        duration: widget.successDuration,
        isActive: () => _isCurrentOperation(operationId),
      );
      if (!_isCurrentOperation(operationId)) return;
      // Call the post-success callback if provided
      widget.onPostSuccess?.call();
    } catch (error) {
      if (!_isCurrentOperation(operationId)) return;
      await _controller.error(
        message: error.toString(),
        duration: widget.errorDuration,
        isActive: () => _isCurrentOperation(operationId),
        then: () {
          if (_isCurrentOperation(operationId)) {
            widget.onPostError?.call(error.toString());
          }
        },
      );
    } finally {
      if (_isCurrentOperation(operationId)) {
        _isHandlingTap = false;
      }
    }
  }

  Widget _buildContent() {
    final label = widget.label ?? 'Tap';
    final labelWidget = Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ).merge(widget.labelStyle),
      textAlign: TextAlign.center,
    );

    if (widget.icon == null) return labelWidget;
    if (widget.label == null) return widget.icon!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.icon!,
        const SizedBox(width: 8),
        Flexible(child: labelWidget),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SDisabled(
      isDisabled: !widget.isEnabled,
      child: Box(
        height: widget.height != null
            ? widget.height! - (25 * (widget.showErrorMessage ? 1 : 0))
            : 70,
        //  color: yellow,
        child: Column(
          children: [
            //Login Button
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MyRoundedLoadingButton(
                    loaderSize: widget.loadingCircleSize ?? 24,
                    customLoaderWidget: widget.loadingWidget,
                    width: (widget.width != null && widget.width!.isFinite)
                        ? widget.width!
                        : 150,
                    height: (widget.height != null && widget.height!.isFinite)
                        ? widget.height!
                        : 40,
                    controller: _controller.controller.state,
                    focusNode: widget.focusNode,
                    onFocusChange: widget.onFocusChange,
                    onPressed: widget.isEnabled && widget.onTap != null
                        ? _handleTap
                        : null,
                    color: widget.bgColor ?? Colors.blue.shade800,
                    valueColor: widget.iconColor ?? Colors.white,
                    elevation: widget.isElevatedButton ? 2 : 0,
                    successColor: widget.successColor ?? Colors.green,
                    errorColor: widget.errorColor ?? Colors.red,
                    successIcon: widget.successIcon,
                    failedIcon: widget.errorIcon,
                    contentKey: ValueKey(_contentRevision),
                    semanticLabel:
                        widget.semanticsLabel ?? widget.label ?? 'Tap',
                    borderRadius: (widget.borderRadius != null &&
                            widget.borderRadius!.isFinite)
                        ? widget.borderRadius!
                        : 35,
                    child: Center(child: _buildContent()),
                  ),
                  _controller.overlayController.builderData<bool>(
                    (isOverlayVisible) {
                      return isOverlayVisible
                          ? Container(
                              decoration: BoxDecoration(
                                color: (widget.errorColor ?? Colors.red)
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(
                                    (widget.borderRadius != null &&
                                            widget.borderRadius!.isFinite)
                                        ? widget.borderRadius!
                                        : 35),
                              ),
                              width: (widget.width != null &&
                                      widget.width!.isFinite)
                                  ? widget.width!
                                  : 150,
                              height: (widget.height != null &&
                                      widget.height!.isFinite)
                                  ? widget.height!
                                  : 40,
                            )
                          : const SizedBox();
                    },
                  ),
                ],
              ),
            ),

            //Login Button Error Message
            _controller.errorMessageController.builderData<String?>(
              (err) {
                // log("Error message: ${err}");

                return err == null
                    ? const SizedBox()
                    : Box(
                        height: widget.showErrorMessage ? 15 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            err,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//************************************ */

class _SFutureButtonController {
  final controller = SRoundedLoadingButtonController()
      .inject<SRoundedLoadingButtonController>(autoDispose: true);

  final errorMessageController = MyNull.inject<String?>(autoDispose: true);
  final overlayController = false.inject<bool>(autoDispose: true);
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  void dispose() {
    _isDisposed = true;
  }

  //---------------------------------//
  // reset method to reset the button state
  void reset() {
    if (_isDisposed) return;
    controller.state.reset();
  }

// error method to indicate an error occurred
  Future<void> error(
      {String? message,
      Duration? duration,
      VoidCallback? then,
      bool Function()? isActive}) async {
    if (_isDisposed || !(isActive?.call() ?? true)) return;
    final errorDur = duration ?? 1.5.sec;
    //show the red overlay layer
    overlayController.state = true;

    //if an error message is provided, show it
    controller.state.error();

    //show the error message to the user

    errorMessageController.update<String?>((s) => message);

    // reset the button state after a delay
    await Future.delayed(errorDur);
    if (_isDisposed || !(isActive?.call() ?? true)) return;

    await Future.delayed(0.3.sec);
    if (_isDisposed || !(isActive?.call() ?? true)) return;

    then?.call();
    // reset the button state and refresh the error message controller
    controller.state.reset();
    errorMessageController.refresh();
    overlayController.state = false;
  } // success method to indicate a successful operation

  Future<void> success(
      {Duration? duration,
      VoidCallback? then,
      bool Function()? isActive}) async {
    if (_isDisposed || !(isActive?.call() ?? true)) return;
    controller.state.success();

    // reset the button state after a delay
    await Future.delayed(duration ?? 0.4.sec);
    if (_isDisposed || !(isActive?.call() ?? true)) return;

    then?.call();
    // reset the button state
    controller.state.reset();
  }
}
