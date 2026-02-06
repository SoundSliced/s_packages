part of '../signals_watch.dart';

/// Internal registry for tracking created signals/computeds.
final Set<s.ReadonlySignal<dynamic>> _registeredSignals =
    <s.ReadonlySignal<dynamic>>{};

S _registerSignal<S extends s.ReadonlySignal<dynamic>>(S signal) {
  _registeredSignals.add(signal);
  signal.onDispose(() {
    _registeredSignals.remove(signal);
  });
  return signal;
}

void _registryDisposeAll() {
  final current = List<s.ReadonlySignal<dynamic>>.from(_registeredSignals);
  for (final sig in current) {
    if (sig is s.Signal<dynamic>) {
      sig.dispose();
    } else if (sig is s.Computed<dynamic>) {
      sig.dispose();
    } else {
      try {
        (sig as dynamic).dispose();
      } catch (_) {}
    }
  }
  _registeredSignals.clear();
}

int _registrySize() => _registeredSignals.length;

void _registryUnregister(s.ReadonlySignal<dynamic> signal) {
  _registeredSignals.remove(signal);
}
