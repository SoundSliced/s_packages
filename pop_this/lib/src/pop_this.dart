// ignore_for_file: unnecessary_import
import 'dart:async';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:s_button/s_button.dart';
import 'package:sizer/sizer.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

//****************************************** */
///            PUBLIC FUNCTIONS            ///
///******************************************* */
///
///

/// A utility class for displaying popup overlays and toast-like notifications.
///
/// [PopThis] provides methods to show customizable popup widgets on top of your app,
/// with support for animations, timers, and styling options.
class PopThis {
  /// Creates a new instance of [PopThis].
  ///
  /// This class is designed to be used with static methods, so you typically
  /// won't need to instantiate it directly.
  PopThis();

  /// Popup a Widget in front of your screen.
  ///
  ///[child] : the Widget you want to popup - popIt will show an empty small box if no child is given

  /// [duration] : the duration to show a popup,
  /// if no duration is given, then Duration.zero is set by default, which will make the toast to not autodismiss
  /// if so, then in order to dismiss the toast, the user will then need to tap anywhere on the background overlay

  /// [popUpAnimationDuration] : the duration (in double type) for the animation popup to last --> default value is 0.5 sec

  static Future<void> pop({
    required final Widget child,
    final Duration duration = Duration.zero,
    final double popUpAnimationDuration = 0.4,
    final BuildContext? context,
    final Color? popBackgroundColor,
    final Color? dismissBarrierColor,
    final Color? backButtonBackgroundColor,
    final Color? backButtonIconColor,
    final Color? backgroundOverlaySplashColor,
    final Color? shadowColor,
    final bool showTimer = false,
    final bool hasShadow = true,
    final bool shouldBackgroundOverlayHaveBorderRadius = true,
    final bool shouldDismissWhenTappingBackgroundOverlay = true,
    final bool shouldBeMarginned = true,
    final bool shouldAnimatePopup = true,
    final bool shouldSaveThisPop = true,
    final bool shouldBlurBackgroundOverlayLayer = true,
    final bool isSecondaryTemporarySinglePop = false,
    final Gradient? backgroundOverlayGradient,
    final Offset? popPositionOffset,
    final Offset? overlayBackgroundLayerOffset,
    final BoxShadow? popShadow,
    final VoidCallback? onDismiss,
    final EdgeInsetsGeometry? popupBorderPadding,
    final BorderRadiusGeometry? overlayBackgroundBorderRadius,
    final Curve newWidgetResizeAnimationCurve = Curves.easeInOutBack,
  }) async {
    // Ensure the overlay system is installed before showing the popup
    _PopThisBootstrapper.ensureInstalled(context: context);

    //if the widget tree is built
    if (WidgetsBinding.instance.isRootWidgetAttached) {
      if (shouldSaveThisPop == false && PopThis.isPopThisActive()) {
        PopThis.animatedDismissPopThis();
      }

      if (isSecondaryTemporarySinglePop == false) {
        //this Future.delayed is a safetynet to ensure the PopThis is called to be built
        //after any currently running build run of any other unrelated widget
        // await Future.delayed(0.sec, () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updatePopPositionOffset(popPositionOffset);

          //log("_popThisController: ${_popThisController.state}");

          //if an original popIt Overlay already exists
          //then replace the popped widget with this new one
          if (_popThisController.state != null) {
            //first, save the child widget in the Widget history cache list
            if (shouldSaveThisPop == true) {
              _shouldSavePreviousPop.state = true;
              _savePopWidget(
                popToSave: child,
                popPositionOffset: popPositionOffset,
                // Pass all styling parameters
                popBackgroundColor: popBackgroundColor,
                backgroundOverlayColor: dismissBarrierColor,
                backButtonBackgroundColor: backButtonBackgroundColor,
                backButtonIconColor: backButtonIconColor,
                backgroundOverlaySplashColor: backgroundOverlaySplashColor,
                shadowColor: shadowColor,
                showTimer: showTimer,
                hasShadow: hasShadow,
                shouldBackgroundOverlayHaveBorderRadius:
                    shouldBackgroundOverlayHaveBorderRadius,
                shouldDismissWhenTappingBackgroundOverlay:
                    shouldDismissWhenTappingBackgroundOverlay,
                shouldBeMarginned: shouldBeMarginned,
                shouldAnimatePopup: shouldAnimatePopup,
                shouldBlurBackgroundOverlayLayer:
                    shouldBlurBackgroundOverlayLayer,
                popUpAnimationDuration: popUpAnimationDuration,
                backgroundOverlayGradient: backgroundOverlayGradient,
                popShadow: popShadow,
                popupBorderPadding: popupBorderPadding,
                overlayBackgroundBorderRadius: overlayBackgroundBorderRadius,
                animationCurve: newWidgetResizeAnimationCurve,
              );

              // Log for debugging purposes
              // log("After saving pop widget: ${_poppedWidgets.state.length} widgets in list");
            } else {
              _shouldSavePreviousPop.state = false;
            }

            //then repop with all style parameters
            _rePop(
              child,
              onDismiss,
              duration,
              popBackgroundColor: popBackgroundColor,
              backgroundOverlayColor: dismissBarrierColor,
              backButtonBackgroundColor: backButtonBackgroundColor,
              backButtonIconColor: backButtonIconColor,
              backgroundOverlaySplashColor: backgroundOverlaySplashColor,
              shadowColor: shadowColor,
              showTimer: showTimer,
              hasShadow: hasShadow,
              shouldBackgroundOverlayHaveBorderRadius:
                  shouldBackgroundOverlayHaveBorderRadius,
              shouldDismissWhenTappingBackgroundOverlay:
                  shouldDismissWhenTappingBackgroundOverlay,
              shouldBeMarginned: shouldBeMarginned,
              shouldAnimatePopup: shouldAnimatePopup,
              shouldBlurBackgroundOverlayLayer:
                  shouldBlurBackgroundOverlayLayer,
              popUpAnimationDuration: popUpAnimationDuration,
              backgroundOverlayGradient: backgroundOverlayGradient,
              popShadow: popShadow,
              popupBorderPadding: popupBorderPadding,
              overlayBackgroundBorderRadius: overlayBackgroundBorderRadius,
              animationCurve: newWidgetResizeAnimationCurve,
            );
            return;
          } else {
            //set the timer (if given a duration to show the pop for)
            //if (duration != Duration.zero) {
            //initialise the _onDismissTimerController

            _onDismissTimerController.state = _OnDismissController()
              ..onDismissCallbacks.add(onDismiss)
              ..onDismissTimer = duration != Duration.zero
                  ? PausableTimer(
                      duration,
                      () {
                        duration == Duration.zero
                            ? null
                            : PopThis.animatedDismissPopThis(
                                shouldPopBackToPreviousWidget: false);
                      },
                    )
                  : PausableTimer(
                      Duration.zero,
                      () {},
                    );

            //start the TimerController
            _onDismissTimerController.state!.onDismissTimer.start();
            //  }

            //first, save the child widget in the Widget history cache list
            if (shouldSaveThisPop == true) {
              _savePopWidget(
                popToSave: child,
                popPositionOffset: popPositionOffset,
                // Pass all styling parameters
                popBackgroundColor: popBackgroundColor,
                backgroundOverlayColor: dismissBarrierColor,
                backButtonBackgroundColor: backButtonBackgroundColor,
                backButtonIconColor: backButtonIconColor,
                backgroundOverlaySplashColor: backgroundOverlaySplashColor,
                shadowColor: shadowColor,
                showTimer: showTimer,
                hasShadow: hasShadow,
                shouldBackgroundOverlayHaveBorderRadius:
                    shouldBackgroundOverlayHaveBorderRadius,
                shouldDismissWhenTappingBackgroundOverlay:
                    shouldDismissWhenTappingBackgroundOverlay,
                shouldBeMarginned: shouldBeMarginned,
                shouldAnimatePopup: shouldAnimatePopup,
                shouldBlurBackgroundOverlayLayer:
                    shouldBlurBackgroundOverlayLayer,
                popUpAnimationDuration: popUpAnimationDuration,
                backgroundOverlayGradient: backgroundOverlayGradient,
                popShadow: popShadow,
                popupBorderPadding: popupBorderPadding,
                overlayBackgroundBorderRadius: overlayBackgroundBorderRadius,
                animationCurve: newWidgetResizeAnimationCurve,
              );
            } else {
              //if the user does not want to save the widget, then set the _shouldSavePreviousPop to false
              _shouldSavePreviousPop.state = false;
            }

            _popThisController.state = _showCustomOverlay(
              (context, opacity) => OnBuilder(
                  listenTo: _poppedWidgets,
                  builder: () {
                    // Get all parameters from current pop widget's state or fallback to original ones
                    var lastWidget = _poppedWidgets.state.isNotEmpty
                        ? _poppedWidgets.state.last
                        : null;

                    // Colors
                    Color? currentBackgroundOverlayColor =
                        lastWidget?.backgroundOverlayColor ??
                            dismissBarrierColor;
                    Color? currentBackgroundOverlaySplashColor =
                        lastWidget?.backgroundOverlaySplashColor ??
                            backgroundOverlaySplashColor;
                    Color? currentPopBackgroundColor =
                        lastWidget?.popBackgroundColor ?? popBackgroundColor;
                    Color? currentBackButtonBackgroundColor =
                        lastWidget?.backButtonBackgroundColor ??
                            backButtonBackgroundColor;
                    Color? currentBackButtonIconColor =
                        lastWidget?.backButtonIconColor ?? backButtonIconColor;
                    Color? currentShadowColor =
                        lastWidget?.shadowColor ?? shadowColor;

                    // Boolean flags
                    bool currentShowTimer = lastWidget?.showTimer ?? showTimer;
                    bool currentHasShadow = lastWidget?.hasShadow ?? hasShadow;
                    bool currentShouldBackgroundOverlayHaveBorderRadius =
                        lastWidget?.shouldBackgroundOverlayHaveBorderRadius ??
                            shouldBackgroundOverlayHaveBorderRadius;
                    bool currentShouldDismissWhenTappingBackgroundOverlay =
                        lastWidget?.shouldDismissWhenTappingBackgroundOverlay ??
                            shouldDismissWhenTappingBackgroundOverlay;
                    bool currentShouldBeMarginned =
                        lastWidget?.shouldBeMarginned ?? shouldBeMarginned;
                    bool currentShouldAnimatePopup =
                        lastWidget?.shouldAnimatePopup ?? shouldAnimatePopup;

                    // Numeric values
                    double currentPopUpAnimationDuration =
                        lastWidget?.popUpAnimationDuration ??
                            popUpAnimationDuration;

                    // Complex objects

                    BoxShadow? currentPopShadow =
                        lastWidget?.popShadow ?? popShadow;
                    EdgeInsetsGeometry? currentPopupBorderPadding =
                        lastWidget?.popupBorderPadding ?? popupBorderPadding;
                    BorderRadiusGeometry? currentOverlayBackgroundBorderRadius =
                        lastWidget?.overlayBackgroundBorderRadius ??
                            overlayBackgroundBorderRadius;
                    Curve currentAnimationCurve = lastWidget?.animationCurve ??
                        newWidgetResizeAnimationCurve;

                    return ClipRRect(
                      borderRadius:
                          currentShouldBackgroundOverlayHaveBorderRadius
                              ? currentOverlayBackgroundBorderRadius ??
                                  BorderRadius.circular(0)
                              : BorderRadius.zero,
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        backgroundColor: Colors.transparent,
                        body: SizedBox(
                          height: 100.h,
                          width: 100.w,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                //Background Empty space widget
                                Positioned(
                                  left: overlayBackgroundLayerOffset?.dx,
                                  top: overlayBackgroundLayerOffset?.dy,
                                  child: //creates a underneath overlay layer

                                      //this animatedSwitcher controls
                                      //the background overlay fade animation at the end of the pop
                                      AnimatedSwitcher(
                                    //  key: const ValueKey('main_switcher'),
                                    duration: 0.3.sec,
                                    switchInCurve: Curves.easeIn,
                                    switchOutCurve: Curves.easeInOut,
                                    child: PopThis.isPopThisActive() == false
                                        ? const SizedBox(
                                            //   key: ValueKey('empty_box_main'),
                                            )
                                        : STweenAnimationBuilder<double>(
                                            tween: Tween<double>(
                                              begin: (lastWidget
                                                          ?.shouldBlurBackgroundOverlayLayer ??
                                                      shouldBlurBackgroundOverlayLayer)
                                                  ? 0.0
                                                  : 10.0,
                                              end: (lastWidget
                                                          ?.shouldBlurBackgroundOverlayLayer ??
                                                      shouldBlurBackgroundOverlayLayer)
                                                  ? 10.0
                                                  : 0.0,
                                            ),
                                            duration: 0.3.sec,
                                            curve: Curves.easeOut,
                                            builder:
                                                (context, blurValue, child) =>
                                                    ClipRect(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: blurValue,
                                                  sigmaY: blurValue,
                                                ),
                                                child: child,
                                              ),
                                            ),
                                            child: SButton(
                                              //  key: const ValueKey('button_main'),
                                              onTap: (position) {
                                                // Use the temporary variable we created
                                                bool shouldDismiss =
                                                    currentShouldDismissWhenTappingBackgroundOverlay;

                                                shouldDismiss == false
                                                    ? null
                                                    : PopThis
                                                        .animatedDismissPopThis(
                                                        shouldPopBackToPreviousWidget:
                                                            false,
                                                      );
                                              },
                                              splashColor:
                                                  currentBackgroundOverlaySplashColor ??
                                                      Colors.transparent,
                                              shouldBounce: false,
                                              child: Box(
                                                height: 100.h,
                                                width: 100.w,
                                                color:
                                                    currentBackgroundOverlayColor ??
                                                        Colors.black.withValues(
                                                            alpha: 0.3),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),

                                // the toast content widget
                                _popThisController.state == null
                                    ? const SizedBox().animate(
                                        effects: [
                                          FadeEffect(
                                            duration:
                                                currentPopUpAnimationDuration
                                                    .sec,
                                            curve: currentAnimationCurve,
                                          ),
                                        ],
                                      )
                                    : Positioned(
                                        left: _popPositionOffset.state?.dx,
                                        top: _popPositionOffset.state?.dy,
                                        child: _AnimatedPopContent(
                                          animationDuration:
                                              currentPopUpAnimationDuration,
                                          animationCurve: currentAnimationCurve,
                                          shouldAnimatePopup:
                                              currentShouldAnimatePopup,
                                          child: _PopThisUp(
                                            isSecondaryPop: false,
                                            backgroundColor:
                                                currentPopBackgroundColor,
                                            duration: duration,
                                            showTimer: currentShowTimer,
                                            // if an offset position is not given, then remove the margin,
                                            // so the popup can be in the center
                                            shouldBeMarginned:
                                                popPositionOffset == null
                                                    ? false
                                                    : currentShouldBeMarginned,
                                            isCentered:
                                                popPositionOffset == null
                                                    ? true
                                                    : false,
                                            hasShadow: currentHasShadow,
                                            boxShadow: currentPopShadow,
                                            shadowColor: currentShadowColor,
                                            backButtonBackgroundColor:
                                                currentBackButtonBackgroundColor,
                                            backButtonIconColor:
                                                currentBackButtonIconColor,
                                            popupBorderPadding:
                                                currentPopupBorderPadding,
                                            child:
                                                _poppedWidgets.state.isNotEmpty
                                                    ? _poppedWidgets.state.last
                                                            ?.savedPop ??
                                                        child
                                                    : child,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              duration: duration,
              context: context,
            );
          }
        });
      } else {
        //as precaution, dismiss any previous secondary temp pop
        PopThis.dismissSecondaryTempPopThis();

        //then show the Secondary Temp popup

        _secondaryTempPopThisController.state = _showCustomOverlay(
          (context, opacity) => Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: shouldBackgroundOverlayHaveBorderRadius
                  ? overlayBackgroundBorderRadius ?? BorderRadius.circular(32)
                  : BorderRadius.zero,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: SizedBox(
                  height: 100.h,
                  width: 100.w,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      //Background Empty space widget
                      Positioned(
                        left: overlayBackgroundLayerOffset?.dx,
                        top: overlayBackgroundLayerOffset?.dy,
                        child: //creates a underneath overlay layer

                            //this animatedSwitcher controls
                            //the background overlay fade animation at the end of the pop
                            AnimatedSwitcher(
                          // key: const ValueKey('secondary_switcher'),
                          duration: 0.3.sec,
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeInOut,
                          child: STweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin:
                                  shouldBlurBackgroundOverlayLayer ? 0.0 : 10.0,
                              end:
                                  shouldBlurBackgroundOverlayLayer ? 10.0 : 0.0,
                            ),
                            duration: 0.3.sec,
                            curve: Curves.easeOut,
                            builder: (context, blurValue, child) => ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: blurValue,
                                  sigmaY: blurValue,
                                ),
                                child: child,
                              ),
                            ),
                            child: SButton(
                              // key: const ValueKey('button_secondary'),
                              onTap: (position) =>
                                  shouldDismissWhenTappingBackgroundOverlay ==
                                          false
                                      ? null
                                      : PopThis
                                          .animatedDismissSecondaryTempPopThis(
                                              onDismissExtraCallback:
                                                  onDismiss),
                              splashColor: backgroundOverlaySplashColor ??
                                  Colors.transparent,
                              shouldBounce: false,
                              child: Box(
                                height: 100.h,
                                width: 100.w,
                                color: dismissBarrierColor ??
                                    Colors.black.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // the toast content widget
                      Positioned(
                        left: popPositionOffset?.dx,
                        top: popPositionOffset?.dy,
                        child: _AnimatedPopContent(
                          animationDuration: popUpAnimationDuration,
                          animationCurve: newWidgetResizeAnimationCurve,
                          shouldAnimatePopup: shouldAnimatePopup,
                          child: _PopThisUp(
                            isSecondaryPop: true,
                            backgroundColor: popBackgroundColor,
                            duration: duration,
                            showTimer: showTimer,
                            // if an offset position is not given, then remove the margin,
                            // so the popup can be in the center
                            shouldBeMarginned: popPositionOffset == null
                                ? false
                                : shouldBeMarginned,
                            isCentered:
                                popPositionOffset == null ? true : false,
                            hasShadow: hasShadow,
                            boxShadow: popShadow,
                            shadowColor: shadowColor,
                            backButtonBackgroundColor:
                                backButtonBackgroundColor,
                            backButtonIconColor: backButtonIconColor,
                            popupBorderPadding: popupBorderPadding,
                            child: _poppedWidgets.state.isNotEmpty
                                ? _poppedWidgets.state.last?.savedPop ?? child
                                : child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          duration: duration,
          context: context,
        );
      }
    }
  }

  //----------------------------------------------//

  /// Dismisses the currently active PopThis overlay.
  ///
  /// By default, if there are multiple widgets in the pop history and
  /// [shouldPopBackToPreviousWidget] is true, this will navigate back to the
  /// previous widget in the stack. Otherwise, it dismisses the entire overlay.
  ///
  /// - [onDismissExtraCallback]: Optional callback to execute when dismissing.
  /// - [shouldPopBackToPreviousWidget]: If true, navigates to the previous widget
  ///   in the pop history instead of dismissing the entire overlay. Defaults to false.
  static void dismissPopThis({
    VoidCallback? onDismissExtraCallback,
    bool shouldPopBackToPreviousWidget = false,
  }) {
    if (PopThis.isPopThisActive() == true) {
      if (shouldPopBackToPreviousWidget == true) {
        //if we have more than one widget in the history
        if (_poppedWidgets.state.length > 1) {
          //remove the last page
          _poppedWidgets.state.removeLast();
          //log("_removePage: ${_myToastpages.state.toString()}");

          //if there still are previous pages, then return to the previous page
          if (_poppedWidgets.state.isNotEmpty) {
            _popPositionOffset.state =
                _poppedWidgets.state.last?.savedPopPositionOffset;

            // Reset the dismiss animation notifier so the previous widget animates in properly
            _shouldAnimateOutNotifier.value = false;

            // Notify listeners that we've changed the state
            _poppedWidgets.notify();
            return;
          }
          //otherwise show there is nothing to rePop anymore, so that the popThis can be dismissed entirely
          else {
            _poppedWidgets.notify();
            _popPositionOffset.refresh();
          }
        }
      }

      // if a Timer was setup, then call the ondismiss callback given to it
      // then cancel the timer
      if (_onDismissTimerController.state != null &&
          _onDismissTimerController.state!.onDismissCallbacks.isNotEmpty) {
        for (VoidCallback? f
            in _onDismissTimerController.state!.onDismissCallbacks) {
          f?.call();
        }
      }

      _onDismissTimerController.state?.onDismissTimer.cancel();

      // Call the extra dismiss callback if provided
      onDismissExtraCallback?.call();

      // Dismiss the PopThis overlay
      _popThisController.state?.dismiss();

      // Reset controllers
      refreshPopThisControllers();
    }
  }

  //----------------------------------------------//

  /// Dismisses the PopThis overlay with an animated transition.
  ///
  /// This method plays a dismissal animation (fade out and subtle scale down)
  /// before removing the overlay. The animation duration is 60% of the original
  /// popup animation duration for a snappier feel.
  ///
  /// - [onDismissExtraCallback]: Optional callback to execute after dismissal.
  /// - [shouldPopBackToPreviousWidget]: If true, navigates to the previous widget
  ///   in the pop history instead of dismissing the entire overlay. Defaults to false.
  ///
  /// Returns a [Future] that completes when the animation finishes and the overlay is dismissed.
  static Future<void> animatedDismissPopThis({
    VoidCallback? onDismissExtraCallback,
    bool shouldPopBackToPreviousWidget = false,
  }) async {
    if (!isPopThisActive()) return;

    // Get the current pop widget
    var lastWidget =
        _poppedWidgets.state.isNotEmpty ? _poppedWidgets.state.last : null;
    double dismissAnimationDuration = lastWidget?.popUpAnimationDuration ?? 0.4;

    // Dismiss is 60% of the original duration for a snappier feel
    double actualDismissDuration = dismissAnimationDuration * 0.6;

    // Trigger the dismiss animation via the ValueNotifier
    _shouldAnimateOutNotifier.value = true;

    // Wait for animation to complete
    await Future.delayed(
        Duration(milliseconds: (actualDismissDuration * 1000).toInt()));

    // Then dismiss
    dismissPopThis(
      onDismissExtraCallback: onDismissExtraCallback,
      shouldPopBackToPreviousWidget: shouldPopBackToPreviousWidget,
    );
  }

  //----------------------------------------------//

  /// Dismisses the secondary temporary PopThis overlay with an animated transition.
  ///
  /// This method is specifically for dismissing secondary/temporary pop overlays that were
  /// shown with [isSecondaryTemporarySinglePop] set to true. It plays a dismissal animation
  /// before removing the overlay.
  ///
  /// - [onDismissExtraCallback]: Optional callback to execute after dismissal.
  ///
  /// Returns a [Future] that completes when the animation finishes and the overlay is dismissed.
  static Future<void> animatedDismissSecondaryTempPopThis({
    VoidCallback? onDismissExtraCallback,
  }) async {
    if (!isSecondaryPopThisActive()) return;

    // Get the current pop widget
    var lastWidget =
        _poppedWidgets.state.isNotEmpty ? _poppedWidgets.state.last : null;
    double dismissAnimationDuration = lastWidget?.popUpAnimationDuration ?? 0.4;

    // Dismiss is 60% of the original duration for a snappier feel
    double actualDismissDuration = dismissAnimationDuration * 0.6;

    // Trigger the dismiss animation via the ValueNotifier
    _shouldAnimateOutNotifier.value = true;

    // Wait for animation to complete
    await Future.delayed(
        Duration(milliseconds: (actualDismissDuration * 1000).toInt()));

    // Then dismiss
    dismissSecondaryTempPopThis(
      onDismissExtraCallback: onDismissExtraCallback,
    );
  }

  //----------------------------------------------//

  static void dismissSecondaryTempPopThis({
    VoidCallback? onDismissExtraCallback,
  }) {
    // Then, call the onDismissExtraCallback function
    onDismissExtraCallback?.call();

    // Dismiss the PopThis overlay
    _secondaryTempPopThisController.state?.dismiss();

    // Finally, reset the controllers
    _secondaryTempPopThisController.refresh();
  }

  //----------------------------------------------//

  //method to notify to the user (if he wishes to programatically determine or not) if the PopThis overlay is active (if a pop is shown on screen)
  static bool isPopThisActive() {
    return _popThisController.state == null ? false : true;
  }

  static bool isSecondaryPopThisActive() {
    return _secondaryTempPopThisController.state == null ? false : true;
  }
  //----------------------------------------------//

//function to display a faint red overlay for less a 5th of a second,
//to show a wrong action by the user
  static void showErrorOverlay({
    Duration? duration,
    String? errorMessage,
    IconData? icon,
    double? overlayOpacity,
    void Function()? onDismiss,
  }) {
    if (WidgetsBinding.instance.isRootWidgetAttached) {
      if (errorMessage == null) {
        _errorOverlayController.refresh();
        _errorOverlayController.state = _showCustomOverlay(
          (context, opacity) {
            return SButton(
              borderRadius: BorderRadius.circular(30),
              shouldBounce: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade900
                      .withValues(alpha: overlayOpacity ?? 0.3),
                  borderRadius: BorderRadius.circular(30),
                ),
              ).animate(
                effects: [
                  FadeEffect(
                    duration: 0.12.sec,
                    curve: Curves.easeInOut,
                  )
                ],
              ),
            );
          },
          duration: duration,
        );

        //execute onDismiss call
        Future.delayed(duration ?? 0.20.sec, () => dismissErrorOverlay());
        return;
      }

      //otherwise, show a PopThis,
      //the Timer delay is only to allow
      //any previous PopThis to first dismiss
      //then to show this one
      Timer(.2.sec, () {
        PopThis.animatedDismissPopThis();
        PopThis.pop(
          shouldSaveThisPop: false,
          onDismiss: onDismiss,
          duration: duration ?? 4.sec,
          popBackgroundColor: Colors.white.withValues(alpha: 0.9),
          dismissBarrierColor:
              Colors.red.shade900.withValues(alpha: overlayOpacity ?? 0.7),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  icon ?? Iconsax.shield_cross_bold,
                  color: Colors.red,
                  size: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }

    //if GetMaterial is not initialised yet
    onDismiss?.call();
  }

  //---------------------------------------------//

  /// Dismisses both the error overlay and any active PopThis overlay.
  ///
  /// This method removes any error overlay created by [showErrorOverlay]
  /// and also calls [animatedDismissPopThis] to dismiss the main PopThis overlay.
  static void dismissErrorOverlay() {
    _errorOverlayController.state?.dismiss();
    PopThis.animatedDismissPopThis();
  }

  //---------------------------------------------//

//function to display a faint green overlay for less a 5th of a second,
//to show a right action by the user
  static void showSuccessOverlay({
    Duration? duration,
    String? successMessage,
    IconData? icon,
    Widget? successMessageWidget,
    void Function()? onDismiss,
  }) {
    //  log("showErrorOverlay");

    if (WidgetsBinding.instance.isRootWidgetAttached) {
      if (successMessage == null && successMessageWidget == null) {
        _successOverlayController.refresh();
        _successOverlayController.state = _showCustomOverlay(
          (context, opacity) {
            return SButton(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade900.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
              ).animate(
                effects: [
                  FadeEffect(
                    duration: 0.12.sec,
                    curve: Curves.easeInOut,
                  )
                ],
              ),
            );
          },
          duration: duration,
        );

        //execute onDismiss call
        Future.delayed(duration ?? 0.20.sec, () => dismissErrorOverlay());
        return;
      }

      //otherwise, show a PopThis,
      //the Timer delay is only to allow
      //any previous PopThis to first dismiss
      //then to show this one
      Timer(.2.sec, () {
        PopThis.animatedDismissPopThis();
        PopThis.pop(
          shouldSaveThisPop: false,
          onDismiss: onDismiss,
          duration: duration ?? 4.sec,
          popShadow: BoxShadow(
            offset: Offset(0, 5),
            blurRadius: 15,
            spreadRadius: -10,
          ),
          popBackgroundColor: Colors.white.withValues(alpha: 0.9),
          dismissBarrierColor:
              Colors.green.shade900.darken(0.1).withValues(alpha: 0.8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  icon ?? Iconsax.tick_circle_bold,
                  color: Colors.green,
                  size: 100,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: successMessageWidget ??
                      Text(
                        successMessage ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                ),
              ],
            ),
          ),
        );
      });

      return;
    }

    //if GetMaterial is not initialised yet
    onDismiss?.call();
  }

  //---------------------------------------------//

  static void dismissSuccessOverlay() {
    _successOverlayController.state?.dismiss();
    PopThis.animatedDismissPopThis();
  }
}

///****************************************** */
///     BOOTSTRAPPER AUTO-INSTALLATION      ///
///******************************************* */

/// Internal bootstrapper that automatically installs the overlay system
/// into the root widget tree when PopThis.pop() is first called.
class _PopThisBootstrapper {
  static OverlayState? _overlayState;
  static bool _installScheduled = false;

  /// Ensures the overlay system is available.
  /// Called automatically when PopThis.pop() is invoked.
  static void ensureInstalled({BuildContext? context}) {
    // If we already have an overlay state, nothing to do
    if (_overlayState != null) return;

    // Prevent multiple installation attempts
    if (_installScheduled) return;
    _installScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _installScheduled = false;

      // Double-check if already found
      if (_overlayState != null) return;

      // Find and cache the root overlay
      _overlayState = _resolveRootOverlay(context);
    });
  }

  /// Resolves the root OverlayState from the widget tree.
  static OverlayState? _resolveRootOverlay(BuildContext? context) {
    // Try to get overlay from provided context
    if (context != null) {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay != null) return overlay;
    }

    // Fallback: traverse the widget tree to find the root overlay
    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) return null;

    OverlayState? found;

    void visit(Element element) {
      if (found != null) return;
      if (element is StatefulElement && element.state is OverlayState) {
        found = element.state as OverlayState;
        return;
      }
      element.visitChildElements(visit);
    }

    visit(rootElement);
    return found;
  }

  /// Gets the cached overlay state, or tries to resolve it
  static OverlayState? get overlayState {
    if (_overlayState != null) return _overlayState;
    _overlayState = _resolveRootOverlay(null);
    return _overlayState;
  }
}

/// Helper function to show a custom overlay with auto-dismiss support
OverlayEntry _showCustomOverlay(
  Widget Function(BuildContext, double) builder, {
  Duration? duration,
  BuildContext? context,
}) {
  // Ensure overlay system is available
  _PopThisBootstrapper.ensureInstalled(context: context);

  final overlayState = _PopThisBootstrapper.overlayState;
  if (overlayState == null) {
    throw Exception(
      'PopThis: Could not find an Overlay in the widget tree. '
      'Make sure your app has a MaterialApp or WidgetsApp.',
    );
  }

  final entry = OverlayEntry(
    builder: (context) => Sizer(
      builder: (sizerContext, orientation, deviceType) {
        return builder(sizerContext, 1.0);
      },
    ),
  );

  overlayState.insert(entry);
  return entry;
}

/// Extension to add dismiss method to OverlayEntry
extension _OverlayEntryDismiss on OverlayEntry {
  void dismiss() {
    if (mounted) {
      remove();
    }
  }
}

///****************************************** */
///    PRIVATE Controllers and FUNCTIONS     ///
///******************************************* */

final _popPositionOffset = RM.inject<Offset?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);
void _updatePopPositionOffset(Offset? popPositionOffset) {
  _popPositionOffset.state = popPositionOffset;
}

//function which when give a new widget, will replace the original pop widget within the same overlay. the original popUp was saved for future reference when the initial PopThis.pop() instance was called
//_rePop will update all the popup parameters including styling, colors, animations, etc.
void _rePop(
  Widget? newWidget,
  VoidCallback? onDismiss,
  Duration? duration, {
  // Add all styling parameters
  Color? popBackgroundColor,
  Color? backgroundOverlayColor,
  Color? backButtonBackgroundColor,
  Color? backButtonIconColor,
  Color? backgroundOverlaySplashColor,
  Color? shadowColor,
  bool showTimer = false,
  bool hasShadow = true,
  bool shouldBackgroundOverlayHaveBorderRadius = true,
  bool shouldDismissWhenTappingBackgroundOverlay = true,
  bool shouldBeMarginned = true,
  bool shouldAnimatePopup = true,
  bool shouldBlurBackgroundOverlayLayer = true,
  double popUpAnimationDuration = 0.4,
  Gradient? backgroundOverlayGradient,
  BoxShadow? popShadow,
  EdgeInsetsGeometry? popupBorderPadding,
  BorderRadiusGeometry? overlayBackgroundBorderRadius,
  Curve animationCurve = Curves.easeInOutBack,
}) {
  // Update the current pop widget in the list with the new parameters
  if (_poppedWidgets.state.isNotEmpty) {
    var currentWidget = _poppedWidgets.state.last;

    // Update the widget itself
    currentWidget?.savedPop = newWidget;

    // Update all styling parameters if provided
    currentWidget?.popBackgroundColor = popBackgroundColor;
    currentWidget?.backgroundOverlayColor = backgroundOverlayColor;
    currentWidget?.backButtonBackgroundColor = backButtonBackgroundColor;
    currentWidget?.backButtonIconColor = backButtonIconColor;
    currentWidget?.backgroundOverlaySplashColor = backgroundOverlaySplashColor;
    currentWidget?.shadowColor = shadowColor;
    currentWidget?.showTimer = showTimer;
    currentWidget?.hasShadow = hasShadow;
    currentWidget?.shouldBackgroundOverlayHaveBorderRadius =
        shouldBackgroundOverlayHaveBorderRadius;
    currentWidget?.shouldDismissWhenTappingBackgroundOverlay =
        shouldDismissWhenTappingBackgroundOverlay;
    currentWidget?.shouldBeMarginned = shouldBeMarginned;
    currentWidget?.shouldAnimatePopup = shouldAnimatePopup;
    currentWidget?.shouldBlurBackgroundOverlayLayer =
        shouldBlurBackgroundOverlayLayer;
    currentWidget?.popUpAnimationDuration = popUpAnimationDuration;
    currentWidget?.backgroundOverlayGradient = backgroundOverlayGradient;
    currentWidget?.popShadow = popShadow;
    currentWidget?.popupBorderPadding = popupBorderPadding;
    currentWidget?.overlayBackgroundBorderRadius =
        overlayBackgroundBorderRadius;
    currentWidget?.animationCurve = animationCurve;

    // Trigger rebuild by notifying state change
    _poppedWidgets.notify();
  }

  _onDismissTimerController.state ??= _OnDismissController()
    ..onDismissCallbacks.add(onDismiss)
    ..onDismissTimer = duration != Duration.zero
        ? PausableTimer(
            duration ?? Duration.zero,
            () {
              duration == Duration.zero
                  ? null
                  : PopThis.animatedDismissPopThis(
                      shouldPopBackToPreviousWidget: false);
            },
          )
        : PausableTimer(
            Duration.zero,
            () {},
          );

  //start the TimerController
  _onDismissTimerController.state!.onDismissTimer.start();
}

///****************************************** */

class _OnDismissController {
  PausableTimer onDismissTimer = PausableTimer(Duration.zero, () {});
  List<VoidCallback?> onDismissCallbacks = [];
}

// controller used for to stop the duration countdown
// when a user initiated PopThis.dismiss() call is made.
final _onDismissTimerController = RM.inject<_OnDismissController?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

///****************************************** */
///

// ValueNotifier to signal that the pop should animate out (for dismiss animation)
final _shouldAnimateOutNotifier = ValueNotifier<bool>(false);

// controller used privately by PopThis package in order to call the popup overlay and dismiss it
final _popThisController = RM.inject<OverlayEntry?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

final _secondaryTempPopThisController = RM.inject<OverlayEntry?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

//this controller holds the list of Widgets given to the same Toast, and if more than 1  page is found, then a "backButton" is displayed, to allow user to display again the previous Widget of the same Toast - as if using a navigate back from a route page navigator - if no more pages found, then the backButton will dismiss the toast
final _poppedWidgets = RM.inject<List<SavedPopWidget?>>(
  () => [],
  autoDisposeWhenNotUsed: true,
);

//this controller determines if we should save the previous pop widget when a new one is shown
final _shouldSavePreviousPop = RM.inject<bool>(
  () => true,
  autoDisposeWhenNotUsed: true,
);

// Helper extension to get the current widget from the _poppedWidgets controller
extension PopWidgetsX on Injected<List<SavedPopWidget?>> {
  Widget? get currentWidget => state.isNotEmpty ? state.last?.savedPop : null;
}

void refreshRepopControllers() {
  _poppedWidgets.refresh();
  _popPositionOffset.refresh();
  // Reset the dismiss animation notifier for the next pop
  _shouldAnimateOutNotifier.value = false;
}

void refreshPopThisControllers() {
  _popThisController.refresh();
  _onDismissTimerController.refresh();
  refreshRepopControllers();
}

//**************************************************** */

final _errorOverlayController = RM.inject<OverlayEntry?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

final _successOverlayController = RM.inject<OverlayEntry?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

//**************************************************** */

class SavedPopWidget {
  Widget? savedPop;
  Offset? savedPopPositionOffset;

  // Additional parameters
  Color? popBackgroundColor;
  Color? backgroundOverlayColor;
  Color? backButtonBackgroundColor;
  Color? backButtonIconColor;
  Color? backgroundOverlaySplashColor;
  Color? shadowColor;
  bool showTimer = false;
  bool hasShadow = true;
  bool shouldBackgroundOverlayHaveBorderRadius = true;
  bool shouldDismissWhenTappingBackgroundOverlay = true;
  bool shouldBeMarginned = true;
  bool shouldAnimatePopup = true;
  bool shouldBlurBackgroundOverlayLayer = true;
  bool shouldAnimateOut = false; // Controls the dismiss animation
  double popUpAnimationDuration = 0.4;
  Gradient? backgroundOverlayGradient;
  BoxShadow? popShadow;
  EdgeInsetsGeometry? popupBorderPadding;
  BorderRadiusGeometry? overlayBackgroundBorderRadius;
  Curve animationCurve = Curves.easeInOutBack;
}

void _savePopWidget({
  Widget? popToSave,
  Offset? popPositionOffset,
  // Add all the possible parameters
  Color? popBackgroundColor,
  Color? backgroundOverlayColor,
  Color? backButtonBackgroundColor,
  Color? backButtonIconColor,
  Color? backgroundOverlaySplashColor,
  Color? shadowColor,
  bool showTimer = false,
  bool hasShadow = true,
  bool shouldBackgroundOverlayHaveBorderRadius = true,
  bool shouldDismissWhenTappingBackgroundOverlay = true,
  bool shouldBeMarginned = true,
  bool shouldAnimatePopup = true,
  bool shouldBlurBackgroundOverlayLayer = true,
  double popUpAnimationDuration = 0.4,
  Gradient? backgroundOverlayGradient,
  BoxShadow? popShadow,
  EdgeInsetsGeometry? popupBorderPadding,
  BorderRadiusGeometry? overlayBackgroundBorderRadius,
  Curve animationCurve = Curves.easeInOutBack,
}) {
  if (popToSave != null) {
    // Instead of trying to compare widgets (which often fails),
    // we'll simply add the new widget if we're explicitly saving a new pop
    final savedPopWidget = SavedPopWidget()
      ..savedPop = popToSave
      ..savedPopPositionOffset = popPositionOffset
      // Save all additional parameters
      ..popBackgroundColor = popBackgroundColor
      ..backgroundOverlayColor = backgroundOverlayColor
      ..backButtonBackgroundColor = backButtonBackgroundColor
      ..backButtonIconColor = backButtonIconColor
      ..backgroundOverlaySplashColor = backgroundOverlaySplashColor
      ..shadowColor = shadowColor
      ..showTimer = showTimer
      ..hasShadow = hasShadow
      ..shouldBackgroundOverlayHaveBorderRadius =
          shouldBackgroundOverlayHaveBorderRadius
      ..shouldDismissWhenTappingBackgroundOverlay =
          shouldDismissWhenTappingBackgroundOverlay
      ..shouldBeMarginned = shouldBeMarginned
      ..shouldAnimatePopup = shouldAnimatePopup
      ..shouldBlurBackgroundOverlayLayer = shouldBlurBackgroundOverlayLayer
      ..popUpAnimationDuration = popUpAnimationDuration
      ..backgroundOverlayGradient = backgroundOverlayGradient
      ..popShadow = popShadow
      ..popupBorderPadding = popupBorderPadding
      ..overlayBackgroundBorderRadius = overlayBackgroundBorderRadius
      ..animationCurve = animationCurve;

    _poppedWidgets.state.add(savedPopWidget);

    // Force notify listeners of the state change
    _poppedWidgets.notify();

    //  log("_savePopWidget: Added new pop, now have ${_poppedWidgets.state.length} widgets");
  }
}

//**************************************************** */

/// A widget that handles animated pop content with proper reverse animation support
class _AnimatedPopContent extends StatefulWidget {
  final Widget child;
  final double animationDuration;
  final Curve animationCurve;
  final bool shouldAnimatePopup;

  const _AnimatedPopContent({
    required this.child,
    required this.animationDuration,
    required this.animationCurve,
    required this.shouldAnimatePopup,
  });

  @override
  State<_AnimatedPopContent> createState() => _AnimatedPopContentState();
}

class _AnimatedPopContentState extends State<_AnimatedPopContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleInAnimation;
  late Animation<double> _scaleOutAnimation;
  bool _isReversing = false;

  // Dismiss animation is faster for a snappier feel
  static const double _dismissSpeedMultiplier = 0.6;
  // Minimum scale on dismiss (subtle zoom out, not full)
  static const double _dismissMinScale = 0.85;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration:
          Duration(milliseconds: (widget.animationDuration * 1000).toInt()),
      // Faster reverse animation for snappy dismiss
      reverseDuration: Duration(
          milliseconds:
              (widget.animationDuration * 1000 * _dismissSpeedMultiplier)
                  .toInt()),
      vsync: this,
    );

    // Fade animation: full fade in on entry, full fade out on dismiss
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut,
    );

    final scaleDuration = widget.shouldAnimatePopup
        ? (widget.animationDuration - 0.2 < 0
            ? 0.0
            : widget.animationDuration - 0.2)
        : 0.0;

    // Scale IN animation: 0 -> 1 with bounce
    _scaleInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          scaleDuration / widget.animationDuration,
          curve: widget.animationCurve,
        ),
      ),
    );

    // Scale OUT animation: 1 -> 0.85 (subtle shrink)
    _scaleOutAnimation =
        Tween<double>(begin: _dismissMinScale, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Listen to the dismiss animation notifier
    _shouldAnimateOutNotifier.addListener(_onShouldAnimateOutChanged);

    // Start the forward animation (only if not already dismissing)
    if (!_shouldAnimateOutNotifier.value) {
      _controller.forward();
    }
  }

  void _onShouldAnimateOutChanged() {
    if (_shouldAnimateOutNotifier.value && mounted) {
      setState(() {
        _isReversing = true;
      });
      _controller.reverse();
    } else if (!_shouldAnimateOutNotifier.value && mounted) {
      // Reset the reversing flag and play forward animation when notifier is false
      setState(() {
        _isReversing = false;
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _shouldAnimateOutNotifier.removeListener(_onShouldAnimateOutChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Use different scale animations for entry vs dismiss
        double scale;
        if (!widget.shouldAnimatePopup) {
          scale = 1.0;
        } else if (_isReversing) {
          // On dismiss: subtle scale from 1.0 to 0.85
          scale = _scaleOutAnimation.value;
        } else {
          // On entry: scale from 0 to 1 with bounce
          scale = _scaleInAnimation.value.clamp(0.0, 1.0);
        }

        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

//**************************************************** */

class _PopThisUp extends StatefulWidget {
  final bool showTimer,
      hasShadow,
      shouldBeMarginned,
      isCentered,
      isSecondaryPop;
  final Duration? duration;
  final Color? backgroundColor,
      shadowColor,
      backButtonBackgroundColor,
      backButtonIconColor;
  final BoxShadow? boxShadow;
  final Widget child;
  final EdgeInsetsGeometry? popupBorderPadding;

  const _PopThisUp({
    this.backgroundColor,
    this.duration,
    this.showTimer = true,
    this.hasShadow = true,
    this.isSecondaryPop = false,
    this.boxShadow,
    this.shadowColor,
    required this.child,
    this.popupBorderPadding,
    this.backButtonBackgroundColor,
    this.backButtonIconColor,
    this.shouldBeMarginned = true,
    required this.isCentered,
  });

  @override
  State<_PopThisUp> createState() => _PopThisUpState();
}

class _PopThisUpState extends State<_PopThisUp> {
  FocusNode escapeFN = FocusNode();
  FocusNode escapeFN2 = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.addListener(_onFocusChange);
      FocusScope.of(context)
          .requestFocus(widget.isSecondaryPop == false ? escapeFN : escapeFN2);
    });
  }

  void _onFocusChange() {
    //as soon as any other FN loses focus, make this FN regain focus
    if (mounted) {
      if (FocusScope.of(context).hasFocus &&
          FocusScope.of(context).hasPrimaryFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FocusScope.of(context).requestFocus(
                widget.isSecondaryPop == false ? escapeFN : escapeFN2);
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(_PopThisUp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget != widget) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.removeListener(_onFocusChange);

    if (widget.isSecondaryPop == false) {
      escapeFN.dispose();
    } else {
      escapeFN2.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        //SafeArea allows for the popIt to NOT take up the whole screen if a Widget with no height or width constraints has been given to it to be displayed
        Focus(
      focusNode: widget.isSecondaryPop == false ? escapeFN : escapeFN2,
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          if (PopThis.isSecondaryPopThisActive() == false) {
            PopThis.animatedDismissPopThis();
          } else {
            PopThis.animatedDismissSecondaryTempPopThis();
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        height: 100.h,
        width: 100.w,
        child: SafeArea(
          //minimum allows for the popIt to have a padding margin of the following values from the defined edges of the screen below
          minimum: widget.shouldBeMarginned == true
              ? EdgeInsets.only(left: 5, right: 8, top: 10, bottom: 10)
              : EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: widget.isCentered == true
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: widget.isCentered == true
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              //if a new widget(s) was called to be displayed within the same myToast, then show a backbutton
              if (_poppedWidgets.state.length > 1 &&
                  _shouldSavePreviousPop.state == true)
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: ElevatedButton(
                    onPressed: () => PopThis.animatedDismissPopThis(
                      shouldPopBackToPreviousWidget: true,
                    ),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      backgroundColor:
                          widget.backButtonBackgroundColor ?? Colors.white70,
                    ),
                    child: IgnorePointer(
                      child: Tooltip(
                        message: "Previous toast page",
                        child: Icon(
                          LucideIcons.arrowLeft,
                          color:
                              widget.backButtonIconColor ?? Colors.red.shade800,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),

              //the Toast Content
              Flexible(
                child: Container(
                  padding: widget.popupBorderPadding ??
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: widget.hasShadow
                        ? [
                            widget.boxShadow ??
                                BoxShadow(
                                  color: widget.shadowColor ??
                                      Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 8.0,
                                  spreadRadius: 2.0,
                                  offset: const Offset(0, 8.0),
                                ),
                          ]
                        : null,
                  ),

                  //Column with expan widgets are there to avoid Render Flex flow errors if the content widget is of dimensions greater than the dimensions of this SizedBox
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    //  reverse: true,

                    child: Column(
                      children: [
                        widget.child,
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //the Timer
              if (widget.showTimer == true)
                _PopTimer(
                  duration: widget.duration ?? 1.sec,
                  // backgroundColor: backgroundColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//**************************************************** */

class _PopTimer extends StatefulWidget {
  final Duration duration;

  const _PopTimer({required this.duration});

  @override
  State<_PopTimer> createState() => _PopTimerState();
}

class _PopTimerState extends State<_PopTimer> {
  CountDownController countDownController = CountDownController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CircularCountDownTimer(
        duration: widget.duration.inSeconds + 1,
        initialDuration: 0,
        controller: countDownController,
        width: 50,
        height: 50,
        ringColor: Colors.grey[300]!,
        ringGradient: null,
        fillColor: Colors.yellowAccent.shade700,
        fillGradient: null,
        backgroundColor: Colors.yellow.shade800,
        backgroundGradient: null,
        strokeWidth: 20.0,
        strokeCap: StrokeCap.round,
        textStyle: const TextStyle(
          fontSize: 20.0,
          color: Colors.black87,
          backgroundColor: Colors.transparent,
          fontWeight: FontWeight.bold,
        ),
        textFormat: CountdownTextFormat.SS,
        isReverse: true,
        isReverseAnimation: false,
        isTimerTextShown: true,
        autoStart: true,
        onStart: () {
          // debugPrint('Countdown Started');
        },
        onComplete: () {
          // debugPrint('Countdown Ended');
        },
        onChange: (String timeStamp) {
          //  debugPrint('Countdown Changed $timeStamp');
        },
      ),
    );
  }
}

///******************************************* */
