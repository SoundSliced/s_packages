part of 'pop_overlay.dart';

/// A modified version of the ActivatorWidget for PopOverlay that uses BackgroundVisualCopy
/// to avoid GlobalKey duplications
class _PopOverlayActivator extends StatelessWidget {
  /// The main application content to display behind overlays
  final Widget child;

  /// Creates a new activator widget with the specified child content
  const _PopOverlayActivator({required this.child});

  @override
  Widget build(BuildContext context) {
    return OnBuilder(
      listenTo: PopOverlay.controller,
      builder: () {
        return Sizer(
          builder: (context, orientation, screenType) {
            return MaterialApp(
              color: Colors.transparent,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: Theme.of(context).colorScheme,
                textTheme: Theme.of(context).textTheme,
                useMaterial3: true,
              ),
              scrollBehavior: MaterialScrollBehavior().copyWith(
                physics: BouncingScrollPhysics(),
                scrollbars: true,
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                  PointerDeviceKind.trackpad
                },
              ),
              home: Directionality(
                textDirection: TextDirection.ltr,
                child: Material(
                  type: MaterialType.transparency,
                  child: EscapeKeyHandler(
                    child: SizedBox(
                      height: 100.h,
                      width: 100.w,
                      child: _AppContentWithOverlays(child: child),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Optimized widget that handles the base content plus overlays
class _AppContentWithOverlays extends StatelessWidget {
  final Widget child;

  const _AppContentWithOverlays({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Always show the original content as the base layer
        RepaintBoundary(child: child),
        // Stack all active overlays
        if (PopOverlay.controller.state.isNotEmpty)
          ...PopOverlay.controller.state.asMap().entries.map((entry) {
            final index = entry.key;
            final popContent = entry.value;

            return RepaintBoundary(
              key: ValueKey("PopOverlay-${popContent.id}-$index"),
              child: _OverlayStack(
                popContent: popContent,
                index: index,
              ),
            );
          }),
      ],
    );
  }
}

/// Optimized overlay stack widget to improve performance and reduce rebuilds
class _OverlayStack extends StatelessWidget {
  final PopOverlayContent popContent;
  final int index;

  const _OverlayStack({
    required this.popContent,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return OnBuilder(
      listenTo: PopOverlay.invisibleController,
      builder: () {
        // Check if this overlay should be invisible
        final isInvisible = popContent.shouldMakeInvisibleOnDismiss &&
            PopOverlay.invisibleController.state.contains(popContent.id);

        return _AnimatedVisibilityWrapper(
          isInvisible: isInvisible,
          popContent: popContent,
        );
      },
    );
  }
}

/// Custom widget to handle fade in/out with proper Offstage timing
class _AnimatedVisibilityWrapper extends StatefulWidget {
  final bool isInvisible;
  final PopOverlayContent popContent;

  const _AnimatedVisibilityWrapper({
    required this.isInvisible,
    required this.popContent,
  });

  @override
  State<_AnimatedVisibilityWrapper> createState() =>
      _AnimatedVisibilityWrapperState();
}

class _AnimatedVisibilityWrapperState
    extends State<_AnimatedVisibilityWrapper> {
  bool _shouldBeOffstage = false;

  // Cache the main content widget to prevent recreation
  Widget? _cachedContent;

  @override
  void initState() {
    super.initState();
    // Only set offstage immediately if starting invisible (shouldStartInvisible = true)
    // Otherwise, let didUpdateWidget handle the delayed offstage
    _shouldBeOffstage =
        widget.isInvisible && widget.popContent.shouldStartInvisible;
    _buildCachedContent();
  }

  void _buildCachedContent() {
    _cachedContent = _TransformWrapper(
      key: ValueKey(
          '${widget.popContent.id}-${DateTime.now().millisecondsSinceEpoch}'),
      popContent: widget.popContent,
    );
  }

  @override
  void didUpdateWidget(_AnimatedVisibilityWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isInvisible != oldWidget.isInvisible) {
      if (widget.isInvisible) {
        // Becoming invisible: don't change opacity here, let _FadeAnimationWrapper handle it
        // Just delay going offstage until fade completes
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted && widget.isInvisible) {
            setState(() {
              _shouldBeOffstage = true;
            });
          }
        });
      } else {
        // Becoming visible: immediately remove offstage
        setState(() {
          _shouldBeOffstage = false;
        });
        // If offsetToPopFrom is set, rebuild cached content to restart animation
        if (widget.popContent.offsetToPopFrom != null &&
            widget.popContent.shouldAnimatePopup) {
          _buildCachedContent();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: _shouldBeOffstage,
      child: Stack(
        children: [
          // Background blur effect only if specified and overlay is visible
          if (widget.popContent.shouldBlurBackground && !widget.isInvisible)
            OnBuilder(
              listenTo: widget.popContent.animationController,
              builder: () {
                final isExiting = widget.popContent.animationController.state;
                return _BlurBackground(
                  popContent: widget.popContent,
                  isExiting: isExiting,
                );
              },
            ),

          // Dismissable barrier only if overlay is visible
          if (!widget.isInvisible)
            OnBuilder(
              listenTo: widget.popContent.animationController,
              builder: () {
                final isExiting = widget.popContent.animationController.state;
                return _DismissBarrier(
                  popContent: widget.popContent,
                  isExiting: isExiting,
                );
              },
            ),

          // Actual popup content - use cached version
          Positioned.fill(
            child: _cachedContent!,
          ),
        ],
      ),
    );
  }
}

/// Optimized blur background component with animated blur radius
class _BlurBackground extends StatelessWidget {
  final PopOverlayContent popContent;
  final bool isExiting;

  const _BlurBackground({
    required this.popContent,
    required this.isExiting,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: STweenAnimationBuilder<double>(
        key: ValueKey("BlurEffect-${popContent.id}-$isExiting"),
        tween: Tween<double>(
          begin: isExiting ? 5.0 : 0.0,
          end: isExiting ? 0.0 : 5.0,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, blurRadius, child) {
          return Container(
            height: 100.h,
            width: 100.w,
            color: Colors.transparent,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: blurRadius,
                sigmaY: blurRadius,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Optimized dismiss barrier component
class _DismissBarrier extends StatelessWidget {
  final PopOverlayContent popContent;
  final bool isExiting;

  const _DismissBarrier({
    required this.popContent,
    required this.isExiting,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SInkButton(
      color:
          popContent.dismissBarrierColor?.withValues(alpha: 0.8).darken(0.2) ??
              Colors.lightBlueAccent,
      scaleFactor: 1,
      onTap: PopOverlay.isActive
          ? (pos) {
              if (popContent.shouldDismissOnBackgroundTap) {
                if (popContent.shouldMakeInvisibleOnDismiss) {
                  PopOverlay._makePopOverlayInvisible(popContent);
                } else {
                  PopOverlay.removePop(popContent.id);
                }
              }
            }
          : null,
      child: Container(
        height: size.height,
        width: size.width,
        color: popContent.dismissBarrierColor ??
            Colors.black.withValues(alpha: 0.4),
      ).animate(
        key: ValueKey("Barrier-${popContent.id}-$isExiting"),
        effects: [
          FadeEffect(
            duration: isExiting ? 0.4.sec : 0.5.sec,
            begin: isExiting ? 1 : 0,
            end: isExiting ? 0 : 1,
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ],
      ),
    );
  }
}

/// Transform wrapper that handles position updates efficiently
class _TransformWrapper extends StatelessWidget {
  final PopOverlayContent popContent;

  const _TransformWrapper({
    super.key,
    required this.popContent,
  });

  @override
  Widget build(BuildContext context) {
    // UNIFIED APPROACH: All popups now use the same positioning system
    // Both framed and non-framed popups listen to positionController for dragging

    return OnBuilder(
      listenTo: popContent.positionController,
      builder: () {
        final currentPosition = popContent.positionController.state;

        // Determine final position based on popPositionOffset
        final finalPosition = popContent.popPositionOffset ?? Offset.zero;

        // Combine drag position with final position
        final totalOffset = finalPosition + currentPosition;

        return RepaintBoundary(
          child: Transform.translate(
            offset: totalOffset,
            child: Align(
              alignment: Alignment.center,
              child: RepaintBoundary(
                child: _PopupContentIsolated(
                  key: key,
                  popContent: popContent,
                  isExiting: popContent.animationController.state,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Isolated popup content that doesn't rebuild when position changes
class _PopupContentIsolated extends StatefulWidget {
  final PopOverlayContent popContent;
  final bool isExiting;

  const _PopupContentIsolated({
    super.key,
    required this.popContent,
    required this.isExiting,
  });

  @override
  State<_PopupContentIsolated> createState() => _PopupContentIsolatedState();
}

class _PopupContentIsolatedState extends State<_PopupContentIsolated> {
  bool _hasInitializedAnimation = false;
  bool _isReadyToShow = true; // Default true for non-animated popups
  Offset? _animationStartOffset;
  String? _animationKey; // Used to restart animation on visibility toggle

  @override
  void initState() {
    super.initState();

    // Hide popup until animation is ready to prevent flash
    if (widget.popContent.offsetToPopFrom != null &&
        widget.popContent.shouldAnimatePopup) {
      _isReadyToShow = false;
      _hasInitializedAnimation = false;
    }
  }

  @override
  void didUpdateWidget(_PopupContentIsolated oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If widget is being recreated (e.g., due to visibility toggle with animation),
    // reset animation state to restart from beginning
    if (widget.popContent.offsetToPopFrom != null &&
        widget.popContent.shouldAnimatePopup &&
        widget.key != oldWidget.key) {
      _hasInitializedAnimation = false;
      _isReadyToShow = false;
      // Trigger re-initialization in didChangeDependencies
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize animation after dependencies are available
    if (!_hasInitializedAnimation &&
        widget.popContent.offsetToPopFrom != null &&
        widget.popContent.shouldAnimatePopup) {
      _hasInitializedAnimation = true;

      // Get screen center position
      final screenSize = MediaQuery.of(context).size;
      final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
      final targetOffset = widget.popContent.popPositionOffset ?? Offset.zero;

      // Calculate start offset for animation
      final startOffset =
          widget.popContent.offsetToPopFrom! - screenCenter - targetOffset;

      // Store the start offset and generate unique animation key
      _animationStartOffset = startOffset;
      _animationKey =
          '${widget.popContent.id}-${DateTime.now().millisecondsSinceEpoch}';

      // Schedule state updates after current frame completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Set initial position to prevent flash at final position
        widget.popContent.positionController.state = startOffset;

        setState(() {
          _isReadyToShow = true;
        });

        assert(() {
          return true;
        }());
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnBuilder(
      listenTo: widget.popContent.animationController,
      builder: () {
        final isExiting = widget.popContent.animationController.state;

        Widget content = _PopupContent(
          popContent: widget.popContent,
          isExiting: isExiting,
        );

        // Wrap with MyTweenAnimationBuilder if animation is needed
        if (_animationStartOffset != null && _isReadyToShow) {
          content = STweenAnimationBuilder<Offset>(
            key: ValueKey(_animationKey),
            tween: Tween<Offset>(
              begin: _animationStartOffset!,
              end: Offset.zero,
            ),
            duration: widget.popContent.popPositionAnimationDuration ??
                const Duration(milliseconds: 250),
            curve: Curves.fastEaseInToSlowEaseOut,
            builder: (context, offset, child) {
              // Update positionController with animated value
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  widget.popContent.positionController.state = offset;
                }
              });

              return child!;
            },
            onEnd: () {},
            child: content,
          );
        }

        return Opacity(
          opacity: _isReadyToShow ? 1.0 : 0.0,
          child: content,
        );
      },
    );
  }
}

/// Optimized popup content component with unified approach
class _PopupContent extends StatelessWidget {
  final PopOverlayContent popContent;
  final bool isExiting;

  const _PopupContent({
    required this.popContent,
    required this.isExiting,
  });

  @override
  Widget build(BuildContext context) {
    // UNIFIED APPROACH: All popups use _PopOverlayFrameDesignWidget
    Widget content = _PopupContentWrapper(
      popContent: popContent,
    );

    // Apply IgnorePointer logic without causing rebuilds
    if (PopOverlay.isActive &&
        popContent.shouldMakeInvisibleOnDismiss &&
        PopOverlay.invisibleController.state.contains(popContent.id)) {
      content = IgnorePointer(ignoring: true, child: content);
    }

    // Apply fade-out animation when dismissing
    if (popContent.shouldAnimatePopup) {
      content = AnimatedOpacity(
        opacity: isExiting ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: isExiting ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Separate StatelessWidget for wrapping content with frame design
class _PopupContentWrapper extends StatelessWidget {
  final PopOverlayContent popContent;

  const _PopupContentWrapper({
    required this.popContent,
  });

  @override
  Widget build(BuildContext context) {
    // UNIFIED APPROACH: All popups now use _PopOverlayFrameDesignWidget
    // Both framed and non-framed popups get the same treatment
    return _PopOverlayFrameDesignWidget(
      frameDesign: popContent.frameDesign, // Can be null
      isDraggable: popContent.isDraggeable,
      popContent: popContent,
      child: popContent.widget,
    );
  }
}
