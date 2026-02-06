import 'package:flutter_test/flutter_test.dart';
import 'package:s_glow/s_glow.dart';

void main() {
  group('Package Export Tests', () {
    test('Glow1 is exported', () {
      expect(Glow1, isNotNull);
    });

    test('Glow2 is exported', () {
      expect(Glow2, isNotNull);
    });
  });
}
