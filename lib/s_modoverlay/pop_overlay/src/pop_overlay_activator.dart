part of 'pop_overlay.dart';

/// A modified version of the ActivatorWidget for PopOverlay that uses BackgroundVisualCopy
/// to avoid GlobalKey duplications
class _PopOverlayActivator extends StatelessWidget {
  /// The main application content to display behind overlays
  final Widget child;

  /// Creates a new activator widget with the specified child content
  const _PopOverlayActivator({required this.child});

  @override
  // Build the overlay host tree with sizing, theme, and input config.
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        // Preserve the current theme and scroll behavior for overlay layers.
        return Theme(
          data: Theme.of(context),
          child: ScrollConfiguration(
            behavior: MaterialScrollBehavior().copyWith(
              physics: BouncingScrollPhysics(),
              scrollbars: true,
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown,
                PointerDeviceKind.trackpad,
              },
            ),
            child: Directionality(
              textDirection:
                  Directionality.maybeOf(context) ?? TextDirection.ltr,
              child: Material(
                type: MaterialType.transparency,
                // EscapeKeyHandler manages global dismiss via keyboard.
                child: EscapeKeyHandler(
                  child: SizedBox(
                    key: PopOverlay._overlayAreaKey,
                    height: double.infinity,
                    width: double.infinity,
                    child: _AppContentWithOverlays(child: child),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Resolve the viewport size when MediaQuery is unavailable (e.g., tests).
Size _popOverlayViewportSizeOf(BuildContext context) {
  final mediaSize = MediaQuery.maybeOf(context)?.size;
  if (mediaSize != null && mediaSize.width > 0 && mediaSize.height > 0) {
    return mediaSize;
  }

  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isNotEmpty) {
    final view = views.first;
    final dpr = view.devicePixelRatio == 0 ? 1.0 : view.devicePixelRatio;
    return Size(
      view.physicalSize.width / dpr,
      view.physicalSize.height / dpr,
    );
  }

  // Fallback minimal size to avoid zero-division issues.
  return const Size(1, 1);
}

/// Optimized widget that handles the base content plus overlays
class _AppContentWithOverlays extends StatelessWidget {
  final Widget child;

  const _AppContentWithOverlays({
    required this.child,
  });

  @override
  // Build base content with optional overlay stack.
  Widget build(BuildContext context) {
    if (OverlayInterleaveManager.enabled) {
      // In interleaved mode, PopOverlay content is rendered elsewhere.
      return RepaintBoundary(child: child);
    }

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
  // Listen for invisibility toggles and wrap with animation logic.
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

// Interleaved layer wrapper used by OverlayInterleaveManager.
class _InterleavedPopLayer extends StatelessWidget {
  final String popId;

  const _InterleavedPopLayer({required this.popId});

  @override
  // Build only if the target pop is still active.
  Widget build(BuildContext context) {
    return OnBuilder(
      listenToMany: [
        PopOverlay.controller,
        PopOverlay.invisibleController,
      ],
      builder: () {
        final popContent = PopOverlay.getActiveById(popId);
        if (popContent == null) {
          return const SizedBox.shrink();
        }

        final isInvisible = popContent.shouldMakeInvisibleOnDismiss &&
            PopOverlay.invisibleController.state.contains(popContent.id);

        return RepaintBoundary(
          key: ValueKey('InterleavedPop-${popContent.id}'),
          child: _AnimatedVisibilityWrapper(
            isInvisible: isInvisible,
            popContent: popContent,
          ),
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
  // Manage offstage timing for fade animations.
  State<_AnimatedVisibilityWrapper> createState() =>
      _AnimatedVisibilityWrapperState();
}

class _AnimatedVisibilityWrapperState
    extends State<_AnimatedVisibilityWrapper> {
  bool _shouldBeOffstage = false;

  // Cache the main content widget to prevent recreation
  Widget? _cachedContent;

  @override
  // Initialize cached content and offstage state.
  void initState() {
    super.initState();
    // Only set offstage immediately if starting invisible (shouldStartInvisible = true)
    // Otherwise, let didUpdateWidget handle the delayed offstage
    _shouldBeOffstage =
        widget.isInvisible && widget.popContent.shouldStartInvisible;
    _buildCachedContent();
  }

  // Build the expensive popup subtree once and reuse it.
  void _buildCachedContent() {
    _cachedContent = _TransformWrapper(
      key: ValueKey(
          '${widget.popContent.id}-${DateTime.now().millisecondsSinceEpoch}'),
      popContent: widget.popContent,
    );
  }

  @override
  // Respond to visibility or content changes.
  void didUpdateWidget(_AnimatedVisibilityWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(widget.popContent, oldWidget.popContent)) {
      _buildCachedContent();
    }

    if (widget.isInvisible != oldWidget.isInvisible) {
      if (widget.isInvisible) {
        // Becoming invisible: wait for fade-out before offstaging.
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
        // Becoming visible: remove offstage immediately.
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
  // Assemble blur, barrier, and popup content layers.
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
  // Animate blur intensity during entry/exit.
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: STweenAnimationBuilder<double>(
        key: ValueKey("BlurEffect-${popContent.id}-$isExiting"),
        tween: Tween<double>(
          begin: isExiting ? 5.0 : 0.0,
          end: isExiting ? 0.0 : 5.0,
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, blurRadius, child) {
          // Build the backdrop filter with the animated radius.
          return SizedBox.expand(
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
  // Build the tap-to-dismiss barrier with fade animation.
  Widget build(BuildContext context) {
    return SInkButton(
      color:
          popContent.dismissBarrierColor?.withValues(alpha: 0.8).darken(0.2) ??
              Colors.lightBlueAccent,
      scaleFactor: 1,
      onTap: PopOverlay.isActive
          ? (pos) {
              // Barrier tap respects shouldDismissOnBackgroundTap.
              _debugPopOverlayLog(
                'barrier tapped id=${popContent.id} shouldDismiss=${popContent.shouldDismissOnBackgroundTap}',
              );
              if (popContent.shouldDismissOnBackgroundTap) {
                if (popContent.shouldMakeInvisibleOnDismiss) {
                  PopOverlay._makePopOverlayInvisible(popContent);
                } else {
                  PopOverlay.removePop(popContent.id);
                }
              }
            }
          : null,
      child: SizedBox.expand(
        child: ColoredBox(
          color: popContent.dismissBarrierColor ??
              Colors.black.withValues(alpha: 0.4),
        ),
      ).animate(
        // key: ValueKey("Barrier-${popContent.id}-$isExiting"),
        effects: [
          FadeEffect(
            duration: isExiting ? 0.8.sec : 1.0.sec,
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
  // Translate popup based on current drag offset and target alignment.
  Widget build(BuildContext context) {
    // UNIFIED APPROACH: All popups now use the same positioning system
    // Both framed and non-framed popups listen to positionController for dragging

    return OnBuilder(
      listenTo: popContent.positionController,
      builder: () {
        final currentPosition = popContent.positionController.state;

        // Determine final position based on popPositionOffset
        var finalPosition = popContent.popPositionOffset ?? Offset.zero;
        final alignment = popContent.alignment ?? Alignment.center;

        // Convert global position to overlay-local coordinates.
        // Uses the overlay area's RenderBox so that FittedBox transforms
        // (e.g. ForcePhoneSizeOnWeb) are accounted for.
        if (popContent.useGlobalPosition) {
          // Convert global coordinates into overlay-local space.
          final overlayBox = PopOverlay._overlayAreaKey.currentContext
              ?.findRenderObject() as RenderBox?;
          if (overlayBox != null && overlayBox.hasSize) {
            final localPos = overlayBox.globalToLocal(finalPosition);
            final screenPoint = alignment
                .resolve(Directionality.of(context))
                .alongSize(overlayBox.size);
            finalPosition = localPos - screenPoint;
          } else {
            final screenSize = _popOverlayViewportSizeOf(context);
            final screenPoint = alignment
                .resolve(Directionality.of(context))
                .alongSize(screenSize);
            finalPosition = finalPosition - screenPoint;
          }
        }

        // Combine drag position with final position
        final totalOffset = finalPosition + currentPosition;

        return RepaintBoundary(
          child: Transform.translate(
            offset: totalOffset,
            child: Align(
              alignment: alignment,
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
  // Manages animation timing and initial hide to avoid flashing.
  State<_PopupContentIsolated> createState() => _PopupContentIsolatedState();
}

class _PopupContentIsolatedState extends State<_PopupContentIsolated> {
  bool _hasInitializedAnimation = false;
  bool _isReadyToShow = true; // Default true for non-animated popups
  Offset? _animationStartOffset;
  String? _animationKey; // Used to restart animation on visibility toggle

  @override
  // Initialize animation readiness flags.
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
  // Reset animation state when the widget identity changes.
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
  // Resolve global-to-local coordinates after layout.
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize animation after dependencies are available
    if (!_hasInitializedAnimation &&
        widget.popContent.offsetToPopFrom != null &&
        widget.popContent.shouldAnimatePopup) {
      _hasInitializedAnimation = true;
      _animationKey =
          '${widget.popContent.id}-${DateTime.now().millisecondsSinceEpoch}';

      // Defer position computation until after layout so globalToLocal
      // produces accurate results (accounts for FittedBox transforms
      // from ForcePhoneSizeOnWeb / FlutterWebFrame).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use post-frame to ensure render objects have sizes.
        if (!mounted) return;

        final alignment = widget.popContent.alignment ?? Alignment.center;
        final overlayBox = PopOverlay._overlayAreaKey.currentContext
            ?.findRenderObject() as RenderBox?;
        final Size overlaySize = (overlayBox != null && overlayBox.hasSize)
            ? overlayBox.size
            : _popOverlayViewportSizeOf(context);
        final screenPoint = alignment
            .resolve(Directionality.of(context))
            .alongSize(overlaySize);

        var targetOffset = widget.popContent.popPositionOffset ?? Offset.zero;

        if (widget.popContent.useGlobalPosition) {
          // Convert target to overlay-local if using global positioning.
          if (overlayBox != null && overlayBox.hasSize) {
            targetOffset = overlayBox.globalToLocal(targetOffset) - screenPoint;
          } else {
            targetOffset = targetOffset - screenPoint;
          }
        }

        // Convert offsetToPopFrom from global to overlay-local
        Offset localOrigin;
        if (overlayBox != null && overlayBox.hasSize) {
          // Translate global origin to overlay-local.
          localOrigin =
              overlayBox.globalToLocal(widget.popContent.offsetToPopFrom!);
        } else {
          localOrigin = widget.popContent.offsetToPopFrom!;
        }

        final startOffset = localOrigin - screenPoint - targetOffset;

        _animationStartOffset = startOffset;
        widget.popContent.positionController.state = startOffset;

        setState(() {
          _isReadyToShow = true;
        });
      });
    }
  }

  @override
  // No extra disposal work beyond base class.
  void dispose() {
    super.dispose();
  }

  @override
  // Build popup content and optional position animation.
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
          // Animate from the source offset to the final position.
          content = STweenAnimationBuilder<Offset>(
            key: ValueKey(_animationKey),
            tween: Tween<Offset>(
              begin: _animationStartOffset!,
              end: Offset.zero,
            ),
            duration: widget.popContent.popPositionAnimationDuration ??
                const Duration(milliseconds: 250),
            curve: widget.popContent.popPositionAnimationCurve ??
                Curves.fastEaseInToSlowEaseOut,
            builder: (context, offset, child) {
              // Update positionController with animated value
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Keep controller in sync with the animation.
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
  // Apply frame design, pointer handling, and exit animations.
  Widget build(BuildContext context) {
    // UNIFIED APPROACH: All popups use _PopOverlayFrameDesignWidget
    Widget content = _PopupContentWrapper(
      popContent: popContent,
    );

    // Apply IgnorePointer logic without causing rebuilds
    if (PopOverlay.isActive &&
        popContent.shouldMakeInvisibleOnDismiss &&
        PopOverlay.invisibleController.state.contains(popContent.id)) {
      // Avoid interactions when hidden.
      content = IgnorePointer(ignoring: true, child: content);
    }

    // Apply fade-out animation when dismissing
    if (popContent.shouldAnimatePopup) {
      // Use a subtle fade+scale for entry/exit.
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
  // Wrap with frame design and optional TapRegion.
  Widget build(BuildContext context) {
    // UNIFIED APPROACH: All popups now use _PopOverlayFrameDesignWidget
    // Both framed and non-framed popups get the same treatment
    Widget content = _PopOverlayFrameDesignWidget(
      frameDesign: popContent.frameDesign, // Can be null
      isDraggable: popContent.isDraggeable,
      popContent: popContent,
      child: popContent.widget,
    );

    if (popContent.tapRegionGroupId != null ||
        popContent.onTapRegionOutside != null ||
        popContent.onTapRegionInside != null ||
        popContent.tapRegionConsumeOutsideTaps) {
      // TapRegion groups prevent outside-tap misclassification.
      content = TapRegion(
        groupId: popContent.tapRegionGroupId,
        behavior: popContent.tapRegionBehavior,
        consumeOutsideTaps: popContent.tapRegionConsumeOutsideTaps,
        onTapOutside: popContent.onTapRegionOutside,
        onTapInside: popContent.onTapRegionInside,
        child: content,
      );
    }

    return content;
  }
}
