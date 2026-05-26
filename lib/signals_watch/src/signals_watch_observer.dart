part of '../signals_watch.dart';

/// Private selective observer implementation used by
/// SignalsWatch.initializeSignalsObserver().
class _SelectiveSignalsObserver implements SignalsObserver {
  @override
  void onSignalCreated<T>(Signal<T> signal, T value) {
    if (signal.name != null) {
      debugPrint(
        'SelectiveSignalsObserver.onSignalCreated | ${signal.name} => $value',
      );
    }
  }

  @override
  void onSignalUpdated<T>(Signal<T> signal, T newValue) {
    if (signal.name != null) {
      debugPrint(
        'SelectiveSignalsObserver.onSignalUpdated | ${signal.name} => $newValue',
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
