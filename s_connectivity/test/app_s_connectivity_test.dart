import 'package:flutter_test/flutter_test.dart';

import 'package:s_connectivity/src/s_connection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppInternetConnectivity', () {
    test('emitCurrentStateNow triggers disconnected callback when false', () {
      var connectedCalls = 0;
      var disconnectedCalls = 0;

      // Ensure disposed state is clean.
      AppInternetConnectivity.disposeInternetConnectivityListener();

      // Initialize with callbacks.
      AppInternetConnectivity.initialiseInternetConnectivityListener(
        onConnected: () => connectedCalls++,
        onDisconnected: () => disconnectedCalls++,
        emitInitialStatus: false,
      );

      // Default is false.
      expect(AppInternetConnectivity.isConnected, isFalse);

      AppInternetConnectivity.emitCurrentStateNow();

      expect(connectedCalls, 0);
      expect(disconnectedCalls, 1);
    });
  });
}
