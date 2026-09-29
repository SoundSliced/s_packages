import 'package:flutter/material.dart';

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

  static OverlayState? _overlayState;
  static final Map<String, OverlayEntry> _entries = <String, OverlayEntry>{};
  static List<String> _mountedOrder = <String>[];

  /// Ids whose entry this manager has inserted into the target overlay and not
  /// yet detached.
  ///
  /// [OverlayEntry.mounted] cannot answer "is this entry in the overlay's list
  /// already?": it only turns true when the Overlay rebuilds and mounts the
  /// entry widget, so an entry inserted earlier in the *same* frame reports
  /// `false` while it is in fact already listed. A restack that trusted it
  /// therefore skipped that entry's removal and inserted it again, which is
  /// what Flutter rejects with "The specified entry is already present in the
  /// target Overlay" (widgets/overlay.dart, _debugCanInsertEntry) as soon as two
  /// layers change in one frame - a snackbar landing while a pop/modal layer is
  /// added or removed, for example. Detachment is driven by this record, with
  /// `entry.mounted` kept as a second condition so an entry left attached to a
  /// stale overlay we no longer track is still released.
  static final Set<String> _insertedIds = <String>{};
  static bool _installScheduled = false;
  static bool _bringToFrontScheduled = false;
  static BuildContext? _pendingBringContext;

  static final ValueNotifier<List<InterleavedOverlayLayer>> _layers =
      ValueNotifier<List<InterleavedOverlayLayer>>(<InterleavedOverlayLayer>[]);

  static const bool _showInterleaveDebugLogs = false;

  static void _debugInterleaveLog(String message) {
    if (!_showInterleaveDebugLogs) return;
    debugPrint('[OverlayInterleave] $message');
  }

  /// Formats a human-readable layer order for debug output.
  static String _formatLayerOrder(List<InterleavedOverlayLayer> layers) {
    if (layers.isEmpty) return '[]';
    return '[${layers.map((layer) => '${layer.id}(a:${layer.activationOrder},l:${layer.stackLevel})').join(' -> ')}]';
  }

  /// Current list of registered layers (sorted by activation/stack).
  static List<InterleavedOverlayLayer> get layers => _layers.value;

  /// Returns the top-most layer id that should own the dismiss barrier.
  ///
  /// In interleaved mode, multiple layers can be visible at once. Rendering a
  /// full-screen barrier for every visible layer compounds opacity and causes a
  /// progressively darker backdrop. This helper enforces a single barrier
  /// owner.
  ///
  /// Policy:
  /// - Visual ownership should be stable to avoid backdrop flicker when layers
  ///   are added/removed above an existing overlay. By default this selects
  ///   the oldest non-excluded layer.
  /// - Tap ownership can opt into top-most behavior by setting
  ///   `preferOldest` to false.
  static String? topBarrierOwnerLayerId({
    List<String> excludedPrefixes = const ['snackbar:'],
    List<String> preferredPrefixes = const [],
    bool preferOldest = true,
  }) {
    if (_layers.value.isEmpty) return null;

    if (preferOldest) {
      if (preferredPrefixes.isNotEmpty) {
        for (final layer in _layers.value) {
          final isExcluded =
              excludedPrefixes.any((prefix) => layer.id.startsWith(prefix));
          if (isExcluded) continue;

          final isPreferred =
              preferredPrefixes.any((prefix) => layer.id.startsWith(prefix));
          if (isPreferred) return layer.id;
        }
      }

      for (final layer in _layers.value) {
        final isExcluded =
            excludedPrefixes.any((prefix) => layer.id.startsWith(prefix));
        if (!isExcluded) return layer.id;
      }
    } else {
      if (preferredPrefixes.isNotEmpty) {
        for (final layer in _layers.value.reversed) {
          final isExcluded =
              excludedPrefixes.any((prefix) => layer.id.startsWith(prefix));
          if (isExcluded) continue;

          final isPreferred =
              preferredPrefixes.any((prefix) => layer.id.startsWith(prefix));
          if (isPreferred) return layer.id;
        }
      }

      for (final layer in _layers.value.reversed) {
        final isExcluded =
            excludedPrefixes.any((prefix) => layer.id.startsWith(prefix));
        if (!isExcluded) return layer.id;
      }
    }

    return null;
  }

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
    final isNewLayer = existingIndex == -1;

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
      // Always update the layer in place, even when activation/stack are
      // unchanged. The builder closure may have changed (for example after a
      // rebuild or hot reload), and dropping that update leaves the overlay
      // entry rendering stale content.
      next[existingIndex] = candidate;
    }

    // Sort and publish the updated layer list.
    _sortLayers(next);
    _layers.value = next;
    ensureInstalled(context: context);
    // Only promote/restack on first insertion. Ordinary builder or metadata
    // updates must preserve the mounted subtree state of the layer; otherwise
    // stateful popup/modal content (for example a resized AnimatedContainer)
    // can be recreated and jump back to its initial size right before
    // dismissal.
    _syncEntries(forceToFront: isNewLayer, context: context);
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
    _syncEntries(forceToFront: false);
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
    _syncEntries(forceToFront: false);
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
    _syncEntries(forceToFront: false);
    _debugInterleaveLog('clearLayers order=[]');
  }

  /// Removes the shared host overlay entry and optionally clears layer state.
  ///
  /// Useful for hard resets (for example test teardown) so stale host entries
  /// do not accumulate across widget tree lifecycles.
  static void teardownHost({bool clearLayers = true}) {
    final entries = Map<String, OverlayEntry>.from(_entries);
    _entries.clear();
    _mountedOrder = <String>[];
    _overlayState = null;
    _installScheduled = false;
    _bringToFrontScheduled = false;
    _pendingBringContext = null;

    for (final entry in entries.entries) {
      // Detach by id rather than by `entry.mounted`: an entry inserted in this
      // frame is in the overlay's list but not mounted yet (see [_insertedIds]).
      _detachEntry(entry.key, entry.value);
    }
    _insertedIds.clear();

    if (clearLayers) {
      _layers.value = <InterleavedOverlayLayer>[];
    }
  }

  /// Ensure the interleaved overlay target overlay is resolved.
  static void ensureInstalled({BuildContext? context}) {
    if (!enabled) return;
    if (_overlayState != null && !_overlayState!.mounted) {
      _overlayState = null;
      _mountedOrder = <String>[];
    }
    if (context != null) {
      _pendingBringContext = context;
    }

    final resolvedNow = resolveRootOverlay(context ?? _pendingBringContext);
    if (resolvedNow != null && resolvedNow.mounted) {
      _overlayState = resolvedNow;
      return;
    }

    if (_installScheduled) return;
    _installScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Complete the deferred install on the next frame.
      _installScheduled = false;

      final overlayState = resolveRootOverlay(context ?? _pendingBringContext);
      if (overlayState == null || !overlayState.mounted) return;

      _overlayState = overlayState;
      _syncEntries(forceToFront: true, context: context);
    });
  }

  /// Bring the interleaved layer group to the front of the root overlay.
  static void bringToFront({BuildContext? context}) {
    ensureInstalled(context: context);
    _syncEntries(forceToFront: true, context: context);
  }

  /// Resolve the best root overlay from a context or the app root.
  static OverlayState? resolveRootOverlay(BuildContext? context) {
    if (context != null) {
      // Prefer the true root overlay when available.
      final rootOverlay = Overlay.maybeOf(context, rootOverlay: true);
      if (rootOverlay != null && rootOverlay.mounted) return rootOverlay;

      // Fallback to the nearest overlay in unusual embed cases.
      final nearestOverlay = Overlay.maybeOf(context, rootOverlay: false);
      if (nearestOverlay != null && nearestOverlay.mounted) {
        return nearestOverlay;
      }
    }

    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) return null;

    final rootOverlay = Overlay.maybeOf(rootElement, rootOverlay: true);
    if (rootOverlay != null && rootOverlay.mounted) return rootOverlay;

    OverlayState? found;

    void visit(Element element) {
      // DFS search for an OverlayState as a last-resort fallback.
      if (found != null) return;
      if (element is StatefulElement && element.state is OverlayState) {
        final overlayState = element.state as OverlayState;
        if (overlayState.mounted) {
          found = overlayState;
          return;
        }
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

  static bool _sameOrder(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Detaches [entry] from whichever overlay currently holds it, and forgets
  /// its id.
  ///
  /// Safe for an entry that was never inserted or was already detached:
  /// [OverlayEntry.remove] only acts on the overlay recorded at insert time, and
  /// it clears that reference *before* checking whether the overlay is still
  /// mounted - so an entry whose overlay has been disposed is released without
  /// touching the tree.
  static void _detachEntry(String id, OverlayEntry entry) {
    final bool tracked = _insertedIds.remove(id);
    if (tracked || entry.mounted) {
      entry.remove();
    }
  }

  static void _syncEntries({bool forceToFront = false, BuildContext? context}) {
    if (!enabled) return;

    final staleOverlayState = _overlayState;
    final overlayState =
        (staleOverlayState != null && staleOverlayState.mounted)
            ? staleOverlayState
            : resolveRootOverlay(context ?? _pendingBringContext);
    if (overlayState == null || !overlayState.mounted) {
      _overlayState = null;
      _mountedOrder = <String>[];
      ensureInstalled(context: context ?? _pendingBringContext);
      return;
    }
    _overlayState = overlayState;

    final desiredIds = _layers.value.map((layer) => layer.id).toSet();
    final currentIds = List<String>.from(_entries.keys);

    for (final id in currentIds) {
      if (desiredIds.contains(id)) continue;
      final removed = _entries.remove(id);
      if (removed != null) {
        _detachEntry(id, removed);
      }
    }

    _mountedOrder = _mountedOrder
        .where((id) => desiredIds.contains(id))
        .toList(growable: false);

    InterleavedOverlayLayer? findLayer(String id) {
      for (final layer in _layers.value) {
        if (layer.id == id) return layer;
      }
      return null;
    }

    for (final layer in _layers.value) {
      _entries.putIfAbsent(
        layer.id,
        () => OverlayEntry(
          maintainState: true,
          builder: (overlayContext) {
            final currentLayer = findLayer(layer.id);
            if (currentLayer == null) {
              return const SizedBox.shrink();
            }

            return KeyedSubtree(
              key: ValueKey('interleave_layer_${currentLayer.id}'),
              child: currentLayer.builder(),
            );
          },
        ),
      );
    }

    final orderedEntries = _layers.value
        .map((layer) => _entries[layer.id])
        .whereType<OverlayEntry>()
        .toList(growable: false);

    final desiredOrder =
        _layers.value.map((layer) => layer.id).toList(growable: false);

    if (orderedEntries.isEmpty) {
      _mountedOrder = <String>[];
      return;
    }

    final hasUnmountedEntries = orderedEntries.any((entry) => !entry.mounted);
    final shouldRestack = forceToFront ||
        hasUnmountedEntries ||
        !_sameOrder(_mountedOrder, desiredOrder);

    if (shouldRestack) {
      // Detach by layer id, driven by [_insertedIds] instead of by
      // `entry.mounted`. An entry inserted earlier in this same frame is still
      // in the overlay's entry list while reporting `mounted == false`; a
      // `mounted`-based sweep skipped it, and the insert below then re-added an
      // entry that was already listed. `_detachEntry` covers both what we
      // ourselves attached and an entry left attached to a stale overlay.
      //
      // (OverlayState.rearrange would tolerate a re-insert too, but it refuses
      // an entry that still belongs to another - possibly disposed - overlay,
      // and with no explicit `below` it would move every foreign entry above
      // ours, changing the stacking this manager exists to decide.)
      for (int i = 0; i < orderedEntries.length; i++) {
        _detachEntry(desiredOrder[i], orderedEntries[i]);
      }

      for (final entry in orderedEntries) {
        overlayState.insert(entry);
      }

      // Exactly what is attached now: any id this restack did not re-insert has
      // been detached above, and keeping a stale id would make a later swap of
      // the same layer detach an entry that was never inserted.
      _insertedIds
        ..clear()
        ..addAll(desiredOrder);
      _mountedOrder = desiredOrder;
    }

    for (final entry in orderedEntries) {
      entry.markNeedsBuild();
    }
  }
}
