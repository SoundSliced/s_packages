part of '../signals_watch.dart';

/// Create a signal from a Future.
/// The signal starts with [initialValue] (default null) and updates to the
/// future's resolved value. Errors are forwarded to [onError].
s.Signal<T?> _signalFromFuture<T>(
  Future<T> future, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  void Function(Object error, StackTrace stackTrace)? onError,
  Function? onInit,
  Function? onValueUpdated,
  Function? onAfterBuild,
  Function? onDispose,
  bool debugTrace = false,
  Map<String, dynamic>? metadata,
}) {
  final sig = SignalsWatch.signal<T?>(
    initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    onInit: onInit,
    onValueUpdated: onValueUpdated,
    onAfterBuild: onAfterBuild,
    onDispose: onDispose,
    debugTrace: debugTrace,
    metadata: metadata,
  );
  future.then((value) {
    sig.value = value;
  }).catchError((Object error, StackTrace stack) {
    onError?.call(error, stack);
  });
  return sig;
}

/// Create a signal from a Stream.
/// The signal starts with [initialValue] (default null) and updates on each
/// event from the stream. The subscription is canceled on signal dispose.
s.Signal<T?> _signalFromStream<T>(
  Stream<T> stream, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  bool cancelOnError = false,
  void Function(Object error, StackTrace stackTrace)? onError,
  Function? onInit,
  Function? onValueUpdated,
  Function? onAfterBuild,
  Function? onDispose,
  bool debugTrace = false,
  Map<String, dynamic>? metadata,
}) {
  final sig = SignalsWatch.signal<T?>(
    initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    onInit: onInit,
    onValueUpdated: onValueUpdated,
    onAfterBuild: onAfterBuild,
    onDispose: onDispose,
    debugTrace: debugTrace,
    metadata: metadata,
  );

  late final StreamSubscription<T> sub;
  sub = stream.listen(
    (event) {
      sig.value = event;
    },
    onError: (Object error, StackTrace stack) {
      onError?.call(error, stack);
      if (cancelOnError) {
        sub.cancel();
      }
    },
    cancelOnError: cancelOnError,
  );

  sig.onDispose(() {
    sub.cancel();
  });

  return sig;
}
