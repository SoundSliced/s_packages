import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Internal sync-scroll controller group used by `s_packages`.
///
/// This is a maintained fork of the upstream package with additional safety for
/// modern Flutter scroll lifecycles (multiple positions, controller churn,
/// explicit group disposal).
class SyncScrollControllerGroup {
  SyncScrollControllerGroup({this.initialScrollOffset = 0.0}) {
    _lastKnownOffset = initialScrollOffset;
    _offsetNotifier = _SyncScrollControllerGroupOffsetNotifier(this);
  }

  final double initialScrollOffset;
  final List<_SyncScrollController> _allControllers = <_SyncScrollController>[];

  late final _SyncScrollControllerGroupOffsetNotifier _offsetNotifier;
  late double _lastKnownOffset;
  bool _disposed = false;

  /// Whether this group has been disposed.
  bool get isDisposed => _disposed;

  /// Current synchronized offset.
  ///
  /// Unlike upstream, this remains readable even when no controllers are
  /// attached by returning the last known synchronized offset.
  double get offset {
    _assertNotDisposed();
    final attached = _attachedControllers;
    if (attached.isEmpty) return _lastKnownOffset;
    final first = attached.first;
    if (first.positions.isEmpty) return _lastKnownOffset;
    return first.position.pixels;
  }

  /// Creates and returns a new linked [ScrollController].
  ScrollController addAndGet() {
    _assertNotDisposed();

    final initialOffset = _attachedControllers.isEmpty
        ? _lastKnownOffset
        : _attachedControllers.first.position.pixels;

    final controller = _SyncScrollController(
      this,
      initialScrollOffset: initialOffset,
    );

    _allControllers.add(controller);
    controller.addListener(_handleControllerOffsetChange);
    return controller;
  }

  /// Adds a callback triggered when group offset changes.
  void addOffsetChangedListener(VoidCallback onChanged) {
    _assertNotDisposed();
    _offsetNotifier.addListener(onChanged);
  }

  /// Removes a callback previously added via [addOffsetChangedListener].
  void removeOffsetChangedListener(VoidCallback listener) {
    if (_disposed) return;
    _offsetNotifier.removeListener(listener);
  }

  Iterable<_SyncScrollController> get _attachedControllers {
    return _allControllers.where((controller) => controller.hasClients);
  }

  void _assertNotDisposed() {
    if (_disposed) {
      throw StateError('SyncScrollControllerGroup has been disposed.');
    }
  }

  void _handleControllerOffsetChange() {
    if (_disposed) return;
    final currentOffset = _computeCurrentOffset();
    if (currentOffset != _lastKnownOffset) {
      _lastKnownOffset = currentOffset;
      _offsetNotifier.emit();
    }
  }

  double _computeCurrentOffset() {
    final attached = _attachedControllers;
    if (attached.isEmpty) return _lastKnownOffset;
    final first = attached.first;
    if (!first.hasClients || first.positions.isEmpty) return _lastKnownOffset;
    return first.position.pixels;
  }

  /// Animates all attached linked controllers to [targetOffset].
  Future<void> animateTo(
    double targetOffset, {
    required Curve curve,
    required Duration duration,
  }) async {
    _assertNotDisposed();

    final attached = _attachedControllers.toList(growable: false);
    if (attached.isEmpty) {
      _lastKnownOffset = targetOffset;
      _offsetNotifier.emit();
      return;
    }

    final animations = <Future<void>>[];
    for (final controller in attached) {
      if (controller.hasClients) {
        animations.add(
          controller.animateTo(
            targetOffset,
            duration: duration,
            curve: curve,
          ),
        );
      }
    }
    await Future.wait(animations);
  }

  /// Jumps all attached linked controllers to [value].
  void jumpTo(double value) {
    _assertNotDisposed();
    _lastKnownOffset = value;

    for (final controller in _attachedControllers.toList(growable: false)) {
      if (controller.hasClients) {
        controller.jumpTo(value);
      }
    }

    _offsetNotifier.emit();
  }

  /// Resets all attached linked controllers to offset 0.
  void resetScroll() => jumpTo(0.0);

  void _onControllerDisposed(_SyncScrollController controller) {
    controller.removeListener(_handleControllerOffsetChange);
    _allControllers.remove(controller);
  }

  /// Disposes all controllers created by this group and the internal notifier.
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    final controllers = List<_SyncScrollController>.from(_allControllers);
    for (final controller in controllers) {
      if (!controller._isDisposed) {
        controller.dispose();
      }
    }
    _allControllers.clear();
    _offsetNotifier.dispose();
  }
}

class _SyncScrollControllerGroupOffsetNotifier extends ChangeNotifier {
  _SyncScrollControllerGroupOffsetNotifier(this.controllerGroup);

  final SyncScrollControllerGroup controllerGroup;

  void emit() => notifyListeners();
}

class _SyncScrollController extends ScrollController {
  _SyncScrollController(
    this._controllers, {
    required super.initialScrollOffset,
  }) : super(
          keepScrollOffset: false,
        );

  final SyncScrollControllerGroup _controllers;
  bool _isDisposed = false;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _controllers._onControllerDisposed(this);
    super.dispose();
  }

  @override
  void attach(ScrollPosition position) {
    assert(
      position is _SyncScrollPosition,
      '_SyncScrollControllers can only be used with _SyncScrollPositions.',
    );
    final syncPosition = position as _SyncScrollPosition;
    assert(
      syncPosition.owner == this,
      '_SyncScrollPosition cannot change controllers once created.',
    );
    super.attach(position);
  }

  @override
  _SyncScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SyncScrollPosition(
      this,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      oldPosition: oldPosition,
    );
  }

  @override
  double get initialScrollOffset {
    final peers = _controllers._attachedControllers;
    if (peers.isEmpty) return super.initialScrollOffset;
    return _controllers.offset;
  }

  @override
  _SyncScrollPosition get position => super.position as _SyncScrollPosition;

  Iterable<_SyncScrollController> get _allPeersWithClients =>
      _controllers._attachedControllers.where((peer) => peer != this);

  bool get canLinkWithPeers => _allPeersWithClients.isNotEmpty;

  Iterable<_SyncScrollActivity> linkWithPeers(_SyncScrollPosition driver) {
    if (!canLinkWithPeers) return const <_SyncScrollActivity>[];
    return _allPeersWithClients
        .map((peer) => peer.link(driver))
        .expand((activities) => activities);
  }

  Iterable<_SyncScrollActivity> link(_SyncScrollPosition driver) {
    if (!hasClients) return const <_SyncScrollActivity>[];
    final activities = <_SyncScrollActivity>[];
    for (final p in positions) {
      final syncPosition = p as _SyncScrollPosition;
      activities.add(syncPosition.link(driver));
    }
    return activities;
  }
}

class _SyncScrollPosition extends ScrollPositionWithSingleContext {
  _SyncScrollPosition(
    this.owner, {
    required super.physics,
    required super.context,
    super.initialPixels = null,
    super.oldPosition,
  });

  final _SyncScrollController owner;
  final Set<_SyncScrollActivity> _peerActivities = <_SyncScrollActivity>{};

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    for (final controller in owner._allPeersWithClients) {
      for (final peerPosition in controller.positions) {
        (peerPosition as _SyncScrollPosition)._holdInternal();
      }
    }
    return super.hold(holdCancelCallback);
  }

  void _holdInternal() {
    super.hold(() {});
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (newActivity == null) return;

    for (final activity in _peerActivities.toList(growable: false)) {
      activity.unlink(this);
    }
    _peerActivities.clear();

    super.beginActivity(newActivity);
  }

  @override
  double setPixels(double newPixels) {
    if (newPixels == pixels) return 0.0;

    updateUserScrollDirection(
      newPixels - pixels > 0.0
          ? ScrollDirection.forward
          : ScrollDirection.reverse,
    );

    if (owner.canLinkWithPeers) {
      _peerActivities.addAll(owner.linkWithPeers(this));
      for (final activity in _peerActivities.toList(growable: false)) {
        activity.moveTo(newPixels);
      }
    }

    return setPixelsInternal(newPixels);
  }

  double setPixelsInternal(double newPixels) {
    return super.setPixels(newPixels);
  }

  @override
  void forcePixels(double value) {
    if (value == pixels) return;

    updateUserScrollDirection(
      value - pixels > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse,
    );

    if (owner.canLinkWithPeers) {
      _peerActivities.addAll(owner.linkWithPeers(this));
      for (final activity in _peerActivities.toList(growable: false)) {
        activity.jumpTo(value);
      }
    }

    forcePixelsInternal(value);
  }

  void forcePixelsInternal(double value) {
    super.forcePixels(value);
  }

  _SyncScrollActivity link(_SyncScrollPosition driver) {
    if (activity is! _SyncScrollActivity) {
      beginActivity(_SyncScrollActivity(this));
    }
    final syncActivity = activity as _SyncScrollActivity;
    syncActivity.link(driver);
    return syncActivity;
  }

  void unlink(_SyncScrollActivity activity) {
    _peerActivities.remove(activity);
  }

  @override
  // ignore: unnecessary_overrides
  void updateUserScrollDirection(ScrollDirection value) {
    super.updateUserScrollDirection(value);
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('owner: $owner');
  }
}

class _SyncScrollActivity extends ScrollActivity {
  _SyncScrollActivity(_SyncScrollPosition super.delegate);

  @override
  _SyncScrollPosition get delegate => super.delegate as _SyncScrollPosition;

  final Set<_SyncScrollPosition> drivers = <_SyncScrollPosition>{};

  void link(_SyncScrollPosition driver) {
    drivers.add(driver);
  }

  void unlink(_SyncScrollPosition driver) {
    drivers.remove(driver);
    if (drivers.isEmpty) {
      delegate.goIdle();
    }
  }

  @override
  bool get shouldIgnorePointer => true;

  @override
  bool get isScrolling => true;

  @override
  double get velocity => 0.0;

  void moveTo(double newPixels) {
    _updateUserScrollDirection();
    delegate.setPixelsInternal(newPixels);
  }

  void jumpTo(double newPixels) {
    _updateUserScrollDirection();
    delegate.forcePixelsInternal(newPixels);
  }

  void _updateUserScrollDirection() {
    if (drivers.isEmpty) return;
    var commonDirection = drivers.first.userScrollDirection;
    for (final driver in drivers) {
      if (driver.userScrollDirection != commonDirection) {
        commonDirection = ScrollDirection.idle;
        break;
      }
    }
    delegate.updateUserScrollDirection(commonDirection);
  }

  @override
  void dispose() {
    for (final driver in drivers.toList(growable: false)) {
      driver.unlink(this);
    }
    super.dispose();
  }
}
