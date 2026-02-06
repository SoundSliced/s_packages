import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:async';

// ignore: unnecessary_import
import 'package:flutter/material.dart';
import 'package:s_disabled/s_disabled.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';

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
  final String? label;
  final Widget? icon;
  final double? height, width;
  final bool isEnabled, isElevatedButton, showErrorMessage;
  final Color? bgColor, iconColor;
  final double? borderRadius;
  final FocusNode? focusNode;
  final void Function(bool)? onFocusChange;

  final double? loadingCircleSize;
  const SFutureButton({
    super.key,
    this.onTap,
    this.label,
    this.icon,
    this.height,
    this.width,
    this.isEnabled = true,
    this.isElevatedButton = true,
    this.showErrorMessage = true,
    this.bgColor,
    this.iconColor,
    this.borderRadius,
    this.onPostError,
    this.onPostSuccess,
    this.focusNode,
    this.onFocusChange,
    this.loadingCircleSize,
  });

  @override
  State<SFutureButton> createState() => _SFutureButtonState();
}

class _SFutureButtonState extends State<SFutureButton> {
  // Individual controllers for each button instance - survives hot reload
  late final _SFutureButtonController _controller = _SFutureButtonController();

  // Handle the Future execution as an instance method
  Future<void> _handleTap() async {
    if (widget.onTap == null) return;

    try {
      // Execute the onTap callback and get the result
      final result = await widget.onTap!();

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
      await _controller.success();
      // Call the post-success callback if provided
      widget.onPostSuccess?.call();
    } catch (error) {
      //  log("Error in SFutureButton: $error");
      await _controller.error(
        message: error.toString(),
        then: () => widget.onPostError?.call(error.toString()),
      );
    }
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
            Stack(
              alignment: Alignment.center,
              children: [
                MyRoundedLoadingButton(
                    loaderSize: widget.loadingCircleSize ?? 24,
                    width: (widget.width != null && widget.width!.isFinite)
                        ? widget.width!
                        : 150,
                    height: (widget.height != null && widget.height!.isFinite)
                        ? widget.height!
                        : 40,
                    controller: _controller.controller.state,
                    focusNode: widget.focusNode,
                    onFocusChange: widget.onFocusChange,
                    onPressed: widget.onTap != null ? _handleTap : null,
                    color: widget.bgColor ?? Colors.blue.shade800,
                    valueColor: widget.iconColor ?? Colors.white,
                    elevation: widget.isElevatedButton ? 2 : 0,
                    successColor: Colors.green,
                    borderRadius: (widget.borderRadius != null &&
                            widget.borderRadius!.isFinite)
                        ? widget.borderRadius!
                        : 35,
                    child: Center(
                      child: widget.icon ??
                          Text(
                            widget.label ?? "Tap",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                    )),
                _controller.overlayController.builderData<bool>(
                  (isOverlayVisible) {
                    return isOverlayVisible
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(
                                  (widget.borderRadius != null &&
                                          widget.borderRadius!.isFinite)
                                      ? widget.borderRadius!
                                      : 35),
                            ),
                            width:
                                (widget.width != null && widget.width!.isFinite)
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
            ).expand(),

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

  //---------------------------------//
  // reset method to reset the button state
  void reset() {
    controller.state.reset();
  }

// error method to indicate an error occurred
  Future<void> error({String? message, Function? then}) async {
    //show the red overlay layer for 1.8 seconds
    overlayController.state = true;

    //if an error message is provided, show it
    controller.state.error();

    //show the error message to the user

    errorMessageController.update<String?>((s) => message);

    // reset the button state after a delay
    await Future.delayed(1.5.sec, () async {
      await Future.delayed(
        0.3.sec,
        () => then?.call(),
      );

      // reset the button state and refresh the error message controller
      controller.state.reset();
      errorMessageController.refresh();
      overlayController.state = false;
    });
  } // success method to indicate a successful operation

  Future<void> success({Function? then}) async {
    controller.state.success();

    // reset the button state after a delay
    await Future.delayed(
      0.4.sec,
      () => then?.call(),
    );

    // reset the button state
    controller.state.reset();
  }
}
