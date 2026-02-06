// ignore_for_file: unused_element, unused_field, public_member_api_docs, sort_constructors_first, unnecessary_import

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:s_button/s_button.dart';
import 'package:sizer/sizer.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';

// Static widgets for performance optimization
class _StaticBuilderWidgets {
  static const waitingWidget = TickerFreeCircularProgressIndicator();
  static const emptyWidget = SizedBox.shrink();
  static const errorTextStyle = TextStyle(color: Colors.red);

  // Use static final for non-const constructors
  static final smallBorderRadius = BorderRadius.circular(6);

  static final defaultPadding = EdgeInsets.all(8);

  static final smallIconConstraints =
      BoxConstraints(minWidth: 10, minHeight: 10);

  // Cached error widget factory
  static final Map<String, Widget> _errorWidgetCache = <String, Widget>{};

  static Widget getErrorWidget(dynamic error) {
    final errorString = 'Error: $error';
    return _errorWidgetCache.putIfAbsent(
      errorString,
      () => Text(errorString, style: errorTextStyle),
    );
  }
}

///**************  Keyboard Extensions  ****************** */
// The DismissKeybaord widget (it's reusable)
class DismissKeyboard extends StatelessWidget {
  final Widget child;
  const DismissKeyboard({super.key, required this.child});

  void onTap(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      KeyboardOverlay.removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: child,
    );
  }
}

///***** -------------------------------------------------------------- */
///my own custom made: inspired by (and modified)
///https://medium.com/@seb_remy/how-to-add-done-button-in-flutter-ios-app-b45e52a30039

class InputDoneView extends StatelessWidget {
  final void Function()? onTap;
  const InputDoneView({this.onTap, super.key});

  void onPressed(BuildContext context) {
    //execute the onTap function (if provided)
    onTap?.call();

    //remove the Done button Overlay
    KeyboardOverlay.removeOverlay();

    //pop out of the keyboard Focus
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 4.0),
              child: CupertinoButton(
                // color: Colors.yellow.shade100.withValues(alpha: 0.95),
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, right: 5, left: 5),
                onPressed: () => onPressed(context),
                child: Text("Done",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.blue.shade900,
                    )),
              ),
            )));
  }
}

//************************************** */

class KeyboardOverlay {
  static OverlayEntry? _overlayEntry;
  static void Function()? onTapProvided;

  static void showDoneButtonOverlay(
      {required BuildContext context, final void Function()? onTap}) {
    if (_overlayEntry != null) {
      return;
    }

    //get the onTap provided (if any) so to pass it to the Done Button Overlay
    onTapProvided = onTap;

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: InputDoneView(
            onTap: onTapProvided,
          ));
    });

    overlayState.insert(_overlayEntry!);
  }

  static void removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    // Note: onTapProvided is called in InputDoneView.onPressed, not here
    // to avoid double-calling when Done button is tapped
  }
}

///**********************    **************************** */
///

class SLoadingIndicator extends StatelessWidget {
  final Indicator indicatorType;
  final List<Color>? colors;
  final Color? backgroundColor;
  final double? strokeWidth;
  final Color? pathBackgroundColor;
  final bool pause;
  final double? scale;
  final double? scaleX;
  final double? scaleY;
  final Offset? origin;
  final AlignmentGeometry alignment;
  final bool transformHitTests;
  final FilterQuality? filterQuality;

  const SLoadingIndicator(
      {this.indicatorType = Indicator.circleStrokeSpin,
      this.colors,
      this.backgroundColor,
      this.strokeWidth,
      this.pathBackgroundColor,
      this.pause = false,
      this.scale,
      this.scaleX,
      this.scaleY,
      this.origin,
      this.alignment = AlignmentDirectional.center,
      this.transformHitTests = true,
      this.filterQuality,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.scale(
        scale: scale ?? 1.0,
        scaleX: scaleX,
        scaleY: scaleY,
        origin: origin,
        alignment: alignment,
        transformHitTests: transformHitTests,
        filterQuality: filterQuality,
        child: LoadingIndicator(
          indicatorType: indicatorType,
          colors: colors,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          pathBackgroundColor: pathBackgroundColor,
          pause: pause,
        ),
      ),
    );
  }
}

//-------------------------------------//
class MountedState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Container(); //returns void widget if not mounted
  }

  @override
  void setState(VoidCallback fn) {
    //only calls setState when mounted
    if (mounted) {
      super.setState(fn);
    } else {
      // For debugging purposes, can log when setState is called on an unmounted widget
      // Future.delayed(
      //   Duration.zero,
      // () {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (mounted) {
            super.setState(fn);
          }
        },
      );
    }
  }
}

//-------------------------------------//

//Extension to add Material Widget when needed
extension GenericExtensions<dynamics extends Widget> on Widget {
//extension to add Material to any widget
  Material addMaterialWidget() {
    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: this,
    );
  }

//extension to add Tooltip to any widget
  Tooltip addTooltipWidget(String toolTip) {
    Widget widget = this;
    return Tooltip(
      message: toolTip,
      child: widget,
    );
  }

  /// set parent widget in center
  //https://howtoflutter.dev/how-to-add-opacity-color-filter-to-an-image-in-flutter/
  //and
  //https://www.kindacode.com/article/flutter-colorfiltered/
  Widget colorFilter([ColorFilter? colorFilter]) {
    return ColorFiltered(
      colorFilter: colorFilter ??
          const ColorFilter.mode(
            Colors.transparent,
            BlendMode.color,
          ),
      child: this,
    );
  }

  Widget borderRadius([BorderRadiusGeometry? borderRadius]) {
    return FittedBox(
      fit: BoxFit.contain,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12.0),
        child: this,
      ),
    );
  }

  Widget boxDecoration([BoxDecoration? boxDecoration]) {
    return Container(
      decoration: boxDecoration,
      child: this,
    );
  }
}

//******************************************************** */

//Snackbar extensions to BuildContext (as per Supabase: https://supabase.com/docs/guides/with-flutter#get-the-api-keys)
extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    // Use a post-frame callback to ensure the context is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verify the context is still mounted and valid
      if (!mounted) return;

      try {
        ScaffoldMessenger.of(this).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ));
      } catch (e) {
        // If ScaffoldMessenger is not available, silently fail
        debugPrint('Warning: Could not show snackbar - $e');
      }
    });
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}

//******************************************************** */

class SDivider extends StatelessWidget {
  final double? lineThickness, lineLength, lineOpacity;
  final Color? lineColor;
  final bool isVertical;
  final EdgeInsetsGeometry widthPadding;
  const SDivider({
    super.key,
    this.lineLength,
    this.lineThickness,
    this.lineColor,
    this.lineOpacity,
    this.widthPadding = EdgeInsets.zero,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widthPadding,
      child: Container(
        height: (isVertical ? lineLength : lineThickness) ??
            (isVertical ? 100.h : 5),
        width: (isVertical ? lineThickness : lineLength) ??
            (isVertical ? 5 : 100.w),
        color: lineColor ?? Colors.black.withValues(alpha: lineOpacity ?? 0.5),
      ),
    );
  }
}

//*************** STextButton Widget **************/

class STextButton extends StatelessWidget {
  final void Function(Offset offset)? onTap;
  final Color? backgroundColor;
  final double? height, width;
  final String? buttonTitle;
  final TextStyle? textStyle;
  final double? backgroundColorOpacity, scale;
  final BorderRadiusGeometry? buttonBorderRadius;
  final EdgeInsetsGeometry? buttonContentPadding;
  final BoxShape? buttonShape;
  final Widget? prefixIcon, midIcon, suffixIcon;
  final BoxBorder? border;

  const STextButton({
    super.key,
    this.onTap,
    this.backgroundColor,
    this.buttonTitle,
    this.textStyle,
    this.backgroundColorOpacity,
    this.buttonBorderRadius,
    this.buttonShape,
    this.buttonContentPadding,
    this.prefixIcon,
    this.midIcon,
    this.suffixIcon,
    this.scale,
    this.height,
    this.width,
    this.border,
  });

  void _onTap(Offset offset) {
    //call the given onTap function
    onTap?.call(offset);
  }

  @override
  Widget build(BuildContext context) {
    return SButton(
      onTap: (offset) => _onTap(offset),
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale ?? 1,
        child: Container(
          height: height ?? 60,
          width: width ?? 100,
          padding: _StaticBuilderWidgets.defaultPadding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: buttonShape ?? BoxShape.rectangle,
            border: border,
            color: backgroundColor != null
                ? backgroundColor!
                    .withValues(alpha: backgroundColorOpacity ?? 0.8)
                : Colors.green.withValues(alpha: backgroundColorOpacity ?? 0.8),
            // borderRadius is only valid for BoxShape.rectangle
            borderRadius:
                (buttonShape ?? BoxShape.rectangle) == BoxShape.rectangle
                    ? (buttonBorderRadius ??
                        _StaticBuilderWidgets.smallBorderRadius)
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //prefix Icon
              if (prefixIcon != null) prefixIcon.flexible(),

              //Button Title
              if (midIcon == null)
                Text(
                  buttonTitle ?? "Button",
                  textAlign: TextAlign.center,
                  style: textStyle ??
                      TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                ).expand(flex: 4),

              if (midIcon != null) Center(child: midIcon!).flexible(),

              //suffix Icon
              if (suffixIcon != null) suffixIcon!.flexible(),
            ],
          ),
        ),
      ),
    );
  }
}

//****************************** */

//https://blog.gskinner.com/archives/2020/09/flutter-tricks-widget-size-position.html
Offset? getWidgetPosition(BuildContext context) {
  RenderBox? box = context.findRenderObject() as RenderBox?;
  return box?.localToGlobal(Offset.zero);
}

//https://blog.gskinner.com/archives/2020/09/flutter-tricks-widget-size-position.html
Size? getWidgetSize(BuildContext context) {
  RenderBox? box = context.findRenderObject() as RenderBox?;
  return box?.size;
}

//******************************* */

class SIconButton extends StatelessWidget {
  final void Function(Offset offset)? onTap;
  final double? size;
  final Color? color, splashColor;
  final BorderRadius? splashBorderRadius;
  final IconData? iconData;
  final bool isActive;
  final Widget? customIcon;
  final String? label;
  const SIconButton({
    super.key,
    this.onTap,
    this.size,
    this.color,
    this.splashColor,
    this.splashBorderRadius,
    this.iconData,
    this.isActive = true,
    this.customIcon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SButton(
            onTap: onTap,
            isActive: isActive,
            borderRadius: splashBorderRadius ?? BorderRadius.circular(12),
            splashColor: splashColor,
            child: customIcon ??
                Icon(iconData ?? Icons.square_rounded,
                    size: size, color: color),
          ),
          if (label != null && label!.isNotEmpty)
            Text(
              label!,
              style: TextStyle(
                fontSize: 9,
                color: color ?? Colors.black.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
        ],
      ),
    );
  }
}

//******************************* */

//******************************* */

class SBlur extends StatelessWidget {
  final Widget child;
  final bool isEnabled, isAnimated;
  final double blurAmountOnX, blurAmountOnY;
  final Duration? animationDuration;
  const SBlur({
    super.key,
    required this.child,
    this.isEnabled = true,
    this.isAnimated = false,
    this.blurAmountOnX = 7,
    this.blurAmountOnY = 7,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    // Return child directly when blur is disabled
    if (!isEnabled && !isAnimated) return child;

    return isAnimated == false
        ? ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurAmountOnX,
              sigmaY: blurAmountOnY,
              tileMode: TileMode.decal,
            ),
            child: child,
          )
        : child.animate(
            key: ValueKey("SBlur${child.hashCode}"),
            effects: isAnimated == true
                ? [BlurEffect(duration: animationDuration ?? 0.3.sec)]
                : [],
          );
  }
}

// Helper widget to measure child size during layout
class MeasureChildSizeWidget extends StatelessWidget {
  final Widget child;

  final void Function(Size size) onChange;

  const MeasureChildSizeWidget({
    required this.child,
    required this.onChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Use addPostFrameCallback to get the size after layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final newSize = renderBox.size;

          onChange(newSize);
        }
      });

      // Return the child directly; size measurement is handled in the callback
      return child;
    });
  }
}

//************************************************ */

class ForcePhoneSizeOnWeb extends StatelessWidget {
  final Widget child;
  final Size? size;
  const ForcePhoneSizeOnWeb({super.key, required this.child, this.size});

  @override
  Widget build(BuildContext context) {
    return FlutterWebFrame(
      maximumSize: size ?? Size(420.0, 812.0),
      enabled: kIsWeb, // default is enable, when disable content is full size
      backgroundColor:
          const Color.fromARGB(255, 13, 36, 55).withValues(alpha: 1),
      builder: (context) => Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: kIsWeb ? Border.all(width: 8) : null,
          borderRadius: kIsWeb ? BorderRadius.circular(35) : BorderRadius.zero,
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius:
                kIsWeb ? BorderRadius.circular(30) : BorderRadius.zero,
          ),
          child: child,
        ),
      ),
    );
  }
}

//************************************ */

class SAnimatedBlur extends StatefulWidget {
  final Widget? child;
  final double? opacity;
  final Duration? duration;
  final bool isBlurred;
  final BorderRadiusGeometry? borderRadius;
  const SAnimatedBlur({
    super.key,
    this.child,
    this.opacity,
    this.borderRadius,
    this.duration,
    this.isBlurred = false,
  });

  @override
  State<SAnimatedBlur> createState() => _SAnimatedBlurState();
}

class _SAnimatedBlurState extends State<SAnimatedBlur> {
  bool _isBlurred = false;

  @override
  void initState() {
    super.initState();
    // Trigger animation on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isBlurred = widget.isBlurred);
      }
    });
  }

  @override
  void didUpdateWidget(SAnimatedBlur oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when isAnimated changes
    if (oldWidget.isBlurred != widget.isBlurred) {
      setState(() => _isBlurred = widget.isBlurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    return STweenAnimationBuilder<double>(
      key: ValueKey(_isBlurred),
      tween: Tween<double>(
          begin: _isBlurred ? 0.0 : 1.0, end: _isBlurred ? 1.0 : 0.0),
      duration: widget.duration ?? 0.3.sec,
      curve: Curves.easeOut,
      builder: (context, value, child) => ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: value * 10.0,
          sigmaY: value * 10.0,
          tileMode: TileMode.decal,
        ),
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(32),
          child: Opacity(
            opacity: widget.opacity ?? 1.0,
            child: widget.child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

//************************************ */

class ScrollTextFormFieldWhenKeyboardIsShown extends StatefulWidget {
  final Widget child;
  const ScrollTextFormFieldWhenKeyboardIsShown(
      {super.key, required this.child});

  @override
  State<ScrollTextFormFieldWhenKeyboardIsShown> createState() =>
      _ScrollTextFormFieldWhenKeyboardIsShownState();
}

class _ScrollTextFormFieldWhenKeyboardIsShownState
    extends State<ScrollTextFormFieldWhenKeyboardIsShown> {
  final _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus == true) {
      if (mounted) {
        final renderObject = context.findRenderObject();
        if (renderObject != null) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 200),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      reverse: true,
      child: Focus(
        focusNode: _focusNode,
        child: widget.child,
      ),
    );
  }
}

//************************************ */

class ExpandCollapseButton extends StatelessWidget {
  final bool isExpanded;
  final ValueChanged<bool> onTap;

  const ExpandCollapseButton({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SButton(
      onTap: (pos) => onTap(!isExpanded),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue.shade100.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade800, width: 0.5),
        ),
        child: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 12,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

//************************************ */

class TextFormFieldClearButton extends StatelessWidget {
  final Function? onPressed;
  const TextFormFieldClearButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // TextFormField Suffix Widget for clear button
    if (onPressed == null) return const SizedBox.shrink();

    return Padding(
      padding: 3.rightPad,
      child: SButton(
        onTap: (p) => onPressed?.call(),
        tooltipMessage: "Clear",
        child: SizedBox(
          width: 10,
          height: 10,
          child: const Icon(
            Icons.clear,
            color: Colors.redAccent,
            size: 11,
          ),
        ),
      ),
    );
  }
}

//************************************ */
