import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:s_packages/s_banner/s_banner.dart';

void main() {
  testWidgets('SBanner preserves ribbon when child instance changes but size is identical', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SBanner(
            isActive: true,
            bannerContent: const Text('Pending'),
            child: Container(width: 100, height: 50, color: Colors.white),
          ),
        ),
      ),
    );

    expect(find.text('Pending'), findsOneWidget);
    final initialSize = tester.getSize(find.byType(SBanner));

    // Rebuild with a different child instance but identical size
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SBanner(
            isActive: true,
            bannerContent: const Text('Pending'),
            child: Container(width: 100, height: 50, color: Colors.white),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pending'), findsOneWidget);
    final newSize = tester.getSize(find.byType(SBanner));
    expect(newSize, equals(initialSize));
  });
}
