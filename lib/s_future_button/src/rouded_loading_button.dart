part of 's_future_button.dart';

/// States that your button can assume via the controller
// ignore: public_member_api_docs
enum SButtonState { idle, loading, success, error }

/// Helper function to ensure a double value is finite, returning a fallback if not
double _safeDouble(double value, double fallback) {
  return value.isFinite ? value : fallback;
}

/// Initialize class
class MyRoundedLoadingButton extends StatefulWidget {
  /// Button controller, now required
  final SRoundedLoadingButtonController controller;

  /// The callback that is called when
  /// the button is tapped or otherwise activated.
  final VoidCallback? onPressed;

  /// The button's label
  final Widget child;

  /// The primary color of the button
  final Color? color;

  /// The vertical extent of the button.
  final double height;

  /// The horizontal extent of the button.
  final double width;

  /// The size of the CircularProgressIndicator
  final double loaderSize;

  /// The stroke width of the CircularProgressIndicator
  final double loaderStrokeWidth;

  /// Whether to trigger the animation on the tap event
  final bool animateOnTap;

  /// The color of the static icons
  final Color valueColor;

  /// reset the animation after specified duration,
  /// use resetDuration parameter to set Duration, defaults to 15 seconds
  final bool resetAfterDuration;

  /// The curve of the shrink animation
  final Curve curve;

  /// The radius of the button border
  final double borderRadius;

  /// The duration of the button animation
  final Duration duration;

  /// The elevation of the raised button
  final double elevation;

  /// Duration after which reset the button
  final Duration resetDuration;

  /// The color of the button when it is in the error state
  final Color? errorColor;

  /// The color of the button when it is in the success state
  final Color? successColor;

  /// The color of the button when it is disabled
  final Color? disabledColor;

  /// The icon for the success state
  final IconData successIcon;

  /// The icon for the failed state
  final IconData failedIcon;

  /// The success and failed animation curve
  final Curve completionCurve;

  /// The duration of the success and failed animation
  final Duration completionDuration;

  /// Optional focus node for managing focus state
  final FocusNode? focusNode;
  final void Function(bool)? onFocusChange;

  /// Custom widget to display while loading.
  final Widget? customLoaderWidget;

  /// initialize constructor
  MyRoundedLoadingButton({
    super.key,
    required this.controller,
    required this.onPressed,
    required this.child,
    this.color = Colors.lightBlue,
    this.height = 50,
    this.width = 300,
    this.loaderSize = 24.0,
    this.loaderStrokeWidth = 2.0,
    this.animateOnTap = true,
    this.valueColor = Colors.white,
    this.borderRadius = 35,
    this.elevation = 2,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCirc,
    this.errorColor = Colors.red,
    this.successColor,
    this.resetDuration = const Duration(seconds: 12),
    this.resetAfterDuration = false,
    this.successIcon = Icons.check,
    this.failedIcon = Icons.close,
    this.completionCurve = Curves.elasticOut,
    this.completionDuration = const Duration(milliseconds: 800),
    this.disabledColor,
    this.focusNode,
    this.onFocusChange,
    this.customLoaderWidget,
  })  : assert(height.isFinite, 'Height must be a finite number'),
        assert(width.isFinite, 'Width must be a finite number'),
        assert(borderRadius.isFinite, 'Border radius must be a finite number');

  @override
  State<StatefulWidget> createState() => _MyRoundedLoadingButtonState();
}

/// Class implementation
class _MyRoundedLoadingButtonState extends State<MyRoundedLoadingButton> {
  final _state = BehaviorSubject<SButtonState>.seeded(SButtonState.idle);
  Color? onFocusColor;

  // Animation state variables
  int _squeezeAnimationKey = 0;
  int _bounceAnimationKey = 0;
  bool _isSqueezing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetHeight = _safeDouble(widget.height, 50);

    Widget loader = widget.customLoaderWidget ??
        SizedBox(
          height: widget.loaderSize,
          width: widget.loaderSize,
          child: TickerFreeCircularProgressIndicator(
            color: widget.valueColor,
            strokeWidth: widget.loaderStrokeWidth,
            strokeCap: StrokeCap.round,
          ),
        );

    Widget childStream = StreamBuilder(
      stream: _state,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: snapshot.data == SButtonState.loading ? loader : widget.child,
        );
      },
    );

    return SizedBox(
      height: targetHeight,
      child: Center(
        child: StreamBuilder(
          stream: _state,
          builder: (context, snapshot) {
            final currentState = snapshot.data ?? SButtonState.idle;

            // Show completion animations
            if (currentState == SButtonState.error ||
                currentState == SButtonState.success) {
              return STweenAnimationBuilder<double>(
                key: ValueKey(_bounceAnimationKey),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: widget.completionDuration,
                curve: widget.completionCurve,
                builder: (context, progress, child) {
                  // Curves like elasticOut can yield negative progress values at the
                  // beginning of the animation (overshooting below 0). That produces
                  // negative width/height which violates BoxConstraints and throws.
                  // We clamp the lower bound to 0 while still allowing overshoot > 1
                  // (a positive bounce/expansion effect) to remain visually intact.
                  final safeProgress = progress < 0 ? 0.0 : progress;
                  final size = targetHeight * safeProgress;
                  return Container(
                    width: size,
                    height: size,
                    alignment: FractionalOffset.center,
                    decoration: BoxDecoration(
                      color: currentState == SButtonState.success
                          ? (widget.successColor ?? theme.primaryColor)
                          : widget.errorColor,
                      // Guard against negative radius (shouldn't happen after clamp)
                      borderRadius: BorderRadius.all(
                          Radius.circular(size <= 0 ? 0 : size / 2)),
                    ),
                    child: size > 20
                        ? Icon(
                            currentState == SButtonState.success
                                ? widget.successIcon
                                : widget.failedIcon,
                            color: widget.valueColor,
                            size: size / 3,
                          )
                        : null,
                  );
                },
              );
            }

            // Show button with squeeze animation
            return STweenAnimationBuilder<double>(
              key: ValueKey(_squeezeAnimationKey),
              tween: Tween<double>(
                begin: _isSqueezing
                    ? _safeDouble(widget.width, 300)
                    : targetHeight,
                end: _isSqueezing
                    ? targetHeight
                    : _safeDouble(widget.width, 300),
              ),
              duration: widget.duration,
              curve: widget.curve,
              onEnd: () {
                if (_isSqueezing &&
                    widget.animateOnTap &&
                    widget.onPressed != null) {
                  widget.onPressed!();
                }
              },
              builder: (context, squeezeValue, child) {
                final borderRadius = _isSqueezing
                    ? widget.borderRadius +
                        ((targetHeight - widget.borderRadius) *
                            (1 -
                                (squeezeValue - targetHeight) /
                                    (_safeDouble(widget.width, 300) -
                                        targetHeight)))
                    : widget.borderRadius;

                return ButtonTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_safeDouble(borderRadius, 35)),
                  ),
                  disabledColor: widget.disabledColor,
                  padding: const EdgeInsets.all(0),
                  child: ElevatedButton(
                    focusNode: widget.focusNode,
                    onFocusChange: (value) {
                      if (mounted) {
                        setState(
                          () => onFocusColor = value
                              ? Colors.blue.shade800.withValues(alpha: 0.6)
                              : null,
                        );

                        widget.onFocusChange?.call(value);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      surfaceTintColor: widget.disabledColor,
                      minimumSize:
                          Size(_safeDouble(squeezeValue, 150), targetHeight),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: onFocusColor ??
                              widget.successColor?.darken(0.2) ??
                              Colors.transparent,
                          width: onFocusColor == null ? 0.2 : 2,
                        ),
                        borderRadius: BorderRadius.circular(
                            _safeDouble(borderRadius, 35)),
                      ),
                      backgroundColor: widget.color,
                      shadowColor:
                          widget.elevation == 0 ? Colors.transparent : null,
                      elevation: widget.elevation,
                      padding: const EdgeInsets.all(0),
                    ),
                    onPressed: widget.onPressed == null ? null : _btnPressed,
                    child: childStream,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Sync state to controller
    _state.stream.listen((event) {
      if (!mounted) return;
      widget.controller._state.sink.add(event);
    });

    widget.controller._addListeners(_start, _stop, _success, _error, _reset);
  }

  @override
  void didUpdateWidget(covariant MyRoundedLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebind this state's listeners to the controller on every update so
    // external calls like start/stop/success/error/reset affect the live
    // widget instance. This avoids stale listener pointers after hot reloads
    // or when the element tree is rebuilt.
    widget.controller._addListeners(_start, _stop, _success, _error, _reset);
  }

  @override
  void dispose() {
    _state.close();
    super.dispose();
  }

  void _btnPressed() async {
    if (widget.animateOnTap) {
      _start();
    } else {
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
    }
  }

  void _start() {
    if (!mounted) return;
    setState(() {
      _isSqueezing = true;
      _squeezeAnimationKey++;
    });
    _state.sink.add(SButtonState.loading);
    if (widget.resetAfterDuration) _reset();
  }

  void _stop() {
    if (!mounted) return;
    setState(() {
      _isSqueezing = false;
      _squeezeAnimationKey++;
    });
    _state.sink.add(SButtonState.idle);
  }

  void _success() {
    if (!mounted) return;
    setState(() {
      _bounceAnimationKey++;
    });
    _state.sink.add(SButtonState.success);
  }

  void _error() {
    if (!mounted) return;
    setState(() {
      _bounceAnimationKey++;
    });
    _state.sink.add(SButtonState.error);
  }

  void _reset() async {
    if (widget.resetAfterDuration) await Future.delayed(widget.resetDuration);
    if (!mounted) return;
    setState(() {
      _isSqueezing = false;
      _squeezeAnimationKey++;
      _bounceAnimationKey++;
    });
    _state.sink.add(SButtonState.idle);
  }
}

/// Options that can be chosen by the controller
/// each will perform a unique animation
class SRoundedLoadingButtonController {
  VoidCallback? _startListener;
  VoidCallback? _stopListener;
  VoidCallback? _successListener;
  VoidCallback? _errorListener;
  VoidCallback? _resetListener;

  void _addListeners(
    VoidCallback startListener,
    VoidCallback stopListener,
    VoidCallback successListener,
    VoidCallback errorListener,
    VoidCallback resetListener,
  ) {
    _startListener = startListener;
    _stopListener = stopListener;
    _successListener = successListener;
    _errorListener = errorListener;
    _resetListener = resetListener;
  }

  final BehaviorSubject<SButtonState> _state =
      BehaviorSubject<SButtonState>.seeded(SButtonState.idle);

  /// A read-only stream of the button state
  Stream<SButtonState> get stateStream => _state.stream;

  /// Gets the current state
  SButtonState? get currentState => _state.value;

  /// Notify listeners to start the loading animation
  void start() {
    if (_startListener != null) _startListener!();
  }

  /// Notify listeners to start the stop animation
  void stop() {
    if (_stopListener != null) _stopListener!();
  }

  /// Notify listeners to start the success animation
  void success() {
    if (_successListener != null) _successListener!();
  }

  /// Notify listeners to start the error animation
  void error() {
    if (_errorListener != null) _errorListener!();
  }

  /// Notify listeners to start the reset animation
  void reset() {
    if (_resetListener != null) _resetListener!();
  }
}
