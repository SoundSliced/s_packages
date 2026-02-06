part of '../signals_watch.dart';

/// Private selective observer implementation used by
/// SignalsWatch.initializeSignalsObserver().
class _SelectiveSignalsObserver implements SignalsObserver {
  @override
  void onSignalCreated<T>(Signal<T> signal, T value) {
    if (signal.debugLabel != null) {
      debugPrint(
        'SelectiveSignalsObserver.onSignalCreated | ${signal.debugLabel} => $value',
      );
    }
  }

  @override
  void onSignalUpdated<T>(Signal<T> signal, T newValue) {
    if (signal.debugLabel != null) {
      debugPrint(
        'SelectiveSignalsObserver.onSignalUpdated | ${signal.debugLabel} => $newValue (previously: ${signal.value})',
      );
    }
  }

  @override
  void onComputedCreated<T>(Computed<T> computed) {}

  @override
  void onComputedUpdated<T>(Computed<T> computed, T previousValue) {}

  @override
  void onEffectCreated(Effect effect) {}

  @override
  void onEffectCalled(Effect effect) {}

  @override
  void onEffectRemoved(Effect effect) {}
}
