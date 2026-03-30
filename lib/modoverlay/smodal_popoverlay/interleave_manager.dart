import 'package:flutter/widgets.dart';

typedef InterleavedLayerBuilder = Widget Function();

/// Immutable description of a single interleaved overlay layer.
class InterleavedOverlayLayer {
  const InterleavedOverlayLayer({
    required this.id,
    required this.activationOrder,
    required this.stackLevel,
    required this.builder,
  });

  final String id;
  final int activationOrder;
  final int stackLevel;
  final InterleavedLayerBuilder builder;

  /// Creates a new instance with selective overrides (keeps immutability).
  InterleavedOverlayLayer copyWith({
    int? activationOrder,
    int? stackLevel,
    InterleavedLayerBuilder? builder,
  }) {
    // Preserve the layer id while optionally updating other fields.
    return InterleavedOverlayLayer(
      id: id,
      activationOrder: activationOrder ?? this.activationOrder,
      stackLevel: stackLevel ?? this.stackLevel,
      builder: builder ?? this.builder,
    );
  }
}

class OverlayInterleaveManager {
  /// When enabled, PopOverlay and s_modal register lightweight layer entries
  /// into a single root overlay host. This avoids z-order surprises when both
  /// systems are active by letting a shared sorter decide the final stack.
  static bool enabled = true;

  static OverlayEntry? _entry;
  static bool _installScheduled = false;
  static bool _bringToFrontScheduled = false;
  static BuildContext? _pendingBringContext;

  static final ValueNotifier<List<InterleavedOverlayLayer>> _layers =
      ValueNotifier<List<InterleavedOverlayLayer>>(<InterleavedOverlayLayer>[]);

  static void _debugInterleaveLog(String message) {
    assert(() {
      // Debug-only logging to avoid release overhead.
      // ignore: avoid_print
      print('[OverlayInterleave] $message');
      return true;
    }());
  }

  /// Formats a human-readable layer order for debug output.
  static String _formatLayerOrder(List<InterleavedOverlayLayer> layers) {
    if (layers.isEmpty) return '[]';
    return '[${layers.map((layer) => '${layer.id}(a:${layer.activationOrder},l:${layer.stackLevel})').join(' -> ')}]';
  }

  /// Current list of registered layers (sorted by activation/stack).
  static List<InterleavedOverlayLayer> get layers => _layers.value;

  /// Register or update a layer in the global interleaved host.
  static void registerLayer({
    required String id,
    required int activationOrder,
    required int stackLevel,
    required InterleavedLayerBuilder builder,
    BuildContext? context,
  }) {
    if (!enabled) return;

    final existingIndex = _layers.value.indexWhere((layer) => layer.id == id);
    final next = List<InterleavedOverlayLayer>.from(_layers.value);

    final candidate = InterleavedOverlayLayer(
      id: id,
      activationOrder: activationOrder,
      stackLevel: stackLevel,
      builder: builder,
    );

    if (existingIndex == -1) {
      // First time registration.
      next.add(candidate);
    } else {
      final current = next[existingIndex];
      final unchanged = current.activationOrder == activationOrder &&
          current.stackLevel == stackLevel;

      if (unchanged) {
        // Keep host installed and visible even if data didn't change.
        ensureInstalled(context: context);
        requestBringToFront(context: context);
        return;
      }

      // Update the layer in place for the same id.
      next[existingIndex] = candidate;
    }

    // Sort and publish the updated layer list.
    _sortLayers(next);
    _layers.value = next;
    _entry?.markNeedsBuild();
    ensureInstalled(context: context);
    requestBringToFront(context: context);
    // Order is sorted by activationOrder (first) then stackLevel (second).
    // activationOrder preserves "first shown" semantics across systems.
    _debugInterleaveLog(
      'registerLayer id=$id order=${_formatLayerOrder(_layers.value)}',
    );
  }

  /// Schedule a bring-to-front request on the next frame.
  static void requestBringToFront({BuildContext? context}) {
    if (context != null) {
      // Prefer the freshest context when provided.
      _pendingBringContext = context;
    }

    if (_bringToFrontScheduled) return;
    _bringToFrontScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset scheduling flag and use the latest captured context.
      _bringToFrontScheduled = false;
      final pendingContext = _pendingBringContext;
      _pendingBringContext = null;
      bringToFront(context: pendingContext);
    });
  }

  /// Remove a single layer by id.
  static void unregisterLayer(String id) {
    if (_layers.value.isEmpty) return;

    final next = List<InterleavedOverlayLayer>.from(_layers.value)
      ..removeWhere((layer) => layer.id == id);
    if (next.length == _layers.value.length) return;

    _layers.value = next;
    _entry?.markNeedsBuild();
    _debugInterleaveLog(
      'unregisterLayer id=$id order=${_formatLayerOrder(_layers.value)}',
    );
  }

  /// Remove any layer whose id matches the predicate.
  static void unregisterWhere(bool Function(String id) predicate) {
    if (_layers.value.isEmpty) return;

    final next = List<InterleavedOverlayLayer>.from(_layers.value)
      ..removeWhere((layer) => predicate(layer.id));

    if (next.length == _layers.value.length) return;

    _layers.value = next;
    _entry?.markNeedsBuild();
    _debugInterleaveLog(
      'unregisterWhere order=${_formatLayerOrder(_layers.value)}',
    );
  }

  /// Quick membership check by id.
  static bool containsLayer(String id) {
    return _layers.value.any((layer) => layer.id == id);
  }

  /// Clear all interleaved layers.
  static void clearLayers() {
    if (_layers.value.isEmpty) return;
    // Reset list and mark for rebuild.
    _layers.value = <InterleavedOverlayLayer>[];
    _entry?.markNeedsBuild();
    _debugInterleaveLog('clearLayers order=[]');
  }

  /// Ensure the interleaved overlay host is installed in the root overlay.
  static void ensureInstalled({BuildContext? context}) {
    if (!enabled) return;
    if (_entry?.mounted == true) return;

    if (_entry != null && _entry?.mounted != true) {
      _entry = null;
    }

    if (_installScheduled) return;
    _installScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Complete the deferred install on the next frame.
      _installScheduled = false;

      if (_entry?.mounted == true) return;

      final overlayState = _resolveRootOverlay(context);
      if (overlayState == null) return;

      final entry = OverlayEntry(
        maintainState: true,
        builder: (context) => const _InterleavedOverlayHost(),
      );

      overlayState.insert(entry);
      _entry = entry;
    });
  }

  /// Bring the interleaved host to the front of the root overlay.
  static void bringToFront({BuildContext? context}) {
    final entry = _entry;
    if (entry == null) {
      // Ensure install if we have no entry yet.
      ensureInstalled(context: context);
      return;
    }

    final overlayState = _resolveRootOverlay(context);
    if (overlayState == null) return;

    if (entry.mounted) {
      // Rearrange moves the entry to the top of the overlay stack.
      overlayState.rearrange([entry]);
      return;
    }

    // Entry is not mounted yet; installation callback will insert it.
    // Avoid inserting here to prevent duplicate-entry assertions.
    ensureInstalled(context: context);
  }

  /// Resolve the best root overlay from a context or the app root.
  static OverlayState? _resolveRootOverlay(BuildContext? context) {
    if (context != null) {
      // Prefer the true root overlay when available.
      final rootOverlay = Overlay.maybeOf(context, rootOverlay: true);
      if (rootOverlay != null) return rootOverlay;

      // Fallback to the nearest overlay in unusual embed cases.
      final nearestOverlay = Overlay.maybeOf(context, rootOverlay: false);
      if (nearestOverlay != null) return nearestOverlay;
    }

    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) return null;

    final rootOverlay = Overlay.maybeOf(rootElement, rootOverlay: true);
    if (rootOverlay != null) return rootOverlay;

    OverlayState? found;

    void visit(Element element) {
      // DFS search for an OverlayState as a last-resort fallback.
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

  /// Sort layers by activation order and stack level, stable by insertion.
  static void _sortLayers(List<InterleavedOverlayLayer> list) {
    // Stable sort with explicit activation order and stack level.
    final indexed = list.asMap().entries.toList();
    indexed.sort((a, b) {
      final byOrder =
          a.value.activationOrder.compareTo(b.value.activationOrder);
      if (byOrder != 0) return byOrder;

      final byLevel = a.value.stackLevel.compareTo(b.value.stackLevel);
      if (byLevel != 0) return byLevel;

      return a.key.compareTo(b.key);
    });

    list
      ..clear()
      ..addAll(indexed.map((e) => e.value));
  }
}

/// Root overlay entry that renders interleaved layers in a single stack.
class _InterleavedOverlayHost extends StatelessWidget {
  const _InterleavedOverlayHost();

  @override
  Widget build(BuildContext context) {
    // Listen to the layer registry for updates.
    return ValueListenableBuilder<List<InterleavedOverlayLayer>>(
      valueListenable: OverlayInterleaveManager._layers,
      builder: (context, layers, child) {
        if (layers.isEmpty) {
          // When empty, keep host inert to avoid intercepting taps.
          return const IgnorePointer(
            ignoring: true,
            child: SizedBox.shrink(),
          );
        }

        // Render each layer in stack order.
        return IgnorePointer(
          ignoring: false,
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: layers
                  .map(
                    (layer) => Positioned.fill(
                      child: KeyedSubtree(
                        key: ValueKey('interleave_layer_${layer.id}'),
                        // Delegate actual content to the layer builder.
                        child: layer.builder(),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
  }
}
