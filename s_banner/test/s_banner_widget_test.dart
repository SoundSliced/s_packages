import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_banner/s_banner.dart';

void main() {
  testWidgets('SBanner shows content when active and hides when inactive',
      (WidgetTester tester) async {
    const bannerText = 'TEST';

    // When active, banner content should be present in the widget tree.
    await tester.pumpWidget(const MaterialApp(
      home: SBanner(
        isActive: true,
        bannerContent: Text(bannerText),
        child: SizedBox(width: 100, height: 50),
      ),
    ));

    // Pump an additional frame to allow the size measurement callback to fire
    await tester.pump();

    expect(find.text(bannerText), findsOneWidget);

    // When inactive, the banner content should not be present.
    await tester.pumpWidget(const MaterialApp(
      home: SBanner(
        isActive: false,
        bannerContent: Text(bannerText),
        child: SizedBox(width: 100, height: 50),
      ),
    ));

    expect(find.text(bannerText), findsNothing);
  });

  testWidgets('SBanner can toggle active state multiple times',
      (WidgetTester tester) async {
    const bannerText = 'TOGGLE TEST';

    // Create a stateful test widget to properly test toggling
    bool isActive = false;
    late StateSetter setState;

    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(
        builder: (context, setter) {
          setState = setter;
          return SBanner(
            isActive: isActive,
            bannerContent: const Text(bannerText),
            child: const SizedBox(width: 100, height: 50),
          );
        },
      ),
    ));
    await tester.pump(); // Allow initial size measurement

    expect(find.text(bannerText), findsNothing);

    // Toggle to active - banner should appear
    setState(() => isActive = true);
    await tester.pump();
    await tester.pump(); // Additional pump for size callback

    expect(find.text(bannerText), findsOneWidget);

    // Toggle back to inactive
    setState(() => isActive = false);
    await tester.pump();

    expect(find.text(bannerText), findsNothing);

    // Toggle to active again - banner should reappear
    setState(() => isActive = true);
    await tester.pump();

    expect(find.text(bannerText), findsOneWidget);
  });
}
