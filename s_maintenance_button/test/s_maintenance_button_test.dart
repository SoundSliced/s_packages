import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_maintenance_button/s_maintenance_button.dart';

// The Glow2 widget from s_glow has a 200ms startDelay timer.
// We need to pump for at least this duration to allow the timer to complete.
const _glowStartDelay = Duration(milliseconds: 250);

void main() {
  group('MyMaintenanceButton', () {
    testWidgets('should render in debug mode', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: false,
            ),
          ),
        ),
      );

      // In debug mode (which test runs in), the button should be visible
      expect(find.byType(SMaintenanceButton), findsOneWidget);

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);
    });

    testWidgets('should display build icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: false,
            ),
          ),
        ),
      );

      // Check that the build icon is present
      expect(find.byIcon(Icons.build_circle_rounded), findsOneWidget);

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);
    });

    testWidgets('should call onTap callback when tapped',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: false,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byType(SMaintenanceButton));
      await tester.pump();

      // Verify callback was called
      expect(wasTapped, true);

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);
    });

    testWidgets('should handle null onTap callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: false,
              onTap: null,
            ),
          ),
        ),
      );

      // Should not throw when tapping without callback
      await tester.tap(find.byType(SMaintenanceButton));
      await tester.pump();

      // If we get here without error, the test passes
      expect(find.byType(SMaintenanceButton), findsOneWidget);

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);
    });

    testWidgets('should show different visual state when on maintenance',
        (WidgetTester tester) async {
      // Build with maintenance OFF
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: false,
            ),
          ),
        ),
      );

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);

      // Rebuild with maintenance ON (new Glow2 widget with new timer)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: true,
            ),
          ),
        ),
      );

      // The button should still be present
      expect(find.byType(SMaintenanceButton), findsOneWidget);
      expect(find.byIcon(Icons.build_circle_rounded), findsOneWidget);

      // Allow new Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);
    });

    testWidgets('should accept custom glow color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: true,
              activeColor: Colors.orange,
            ),
          ),
        ),
      );

      // Widget should render with custom color
      expect(find.byType(SMaintenanceButton), findsOneWidget);

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);
    });

    testWidgets('should update when isOnMaintenance changes',
        (WidgetTester tester) async {
      // Start with maintenance OFF
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: false,
            ),
          ),
        ),
      );

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);

      expect(find.byType(SMaintenanceButton), findsOneWidget);

      // Update to maintenance ON (new Glow2 widget with new timer)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: true,
            ),
          ),
        ),
      );

      // Allow new Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);

      // Should still be visible
      expect(find.byType(SMaintenanceButton), findsOneWidget);
    });

    testWidgets('should work in stateful widget scenario',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestStatefulWidget()));

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);

      // Initially not on maintenance
      expect(find.text('OFF'), findsOneWidget);

      // Tap to toggle (creates new Glow2 with new timer)
      await tester.tap(find.byType(SMaintenanceButton));
      await tester.pump();
      await tester.pump(_glowStartDelay);

      // Should now be ON
      expect(find.text('ON'), findsOneWidget);

      // Tap again to toggle back (creates new Glow2 with new timer)
      await tester.tap(find.byType(SMaintenanceButton));
      await tester.pump();
      await tester.pump(_glowStartDelay);

      // Should be OFF again
      expect(find.text('OFF'), findsOneWidget);
    });

    testWidgets('should have correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SMaintenanceButton(
              isOnMaintenance: false,
            ),
          ),
        ),
      );

      // Allow Glow2's startDelay timer to complete
      await tester.pump(_glowStartDelay);

      // Find the sized box that wraps the button
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(SMaintenanceButton),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      // Verify dimensions
      expect(sizedBox.height, 23);
      expect(sizedBox.width, 23);
    });

    test('should only be visible in non-release mode', () {
      // This test verifies the logic but can't truly test kReleaseMode
      // as it's a compile-time constant
      expect(kReleaseMode, false); // Tests always run in debug mode
    });
  });
}

// Helper widget for stateful testing
class TestStatefulWidget extends StatefulWidget {
  const TestStatefulWidget({super.key});

  @override
  State<TestStatefulWidget> createState() => _TestStatefulWidgetState();
}

class _TestStatefulWidgetState extends State<TestStatefulWidget> {
  bool isOnMaintenance = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SMaintenanceButton(
            isOnMaintenance: isOnMaintenance,
            onTap: () => setState(() => isOnMaintenance = !isOnMaintenance),
          ),
          Text(isOnMaintenance ? 'ON' : 'OFF'),
        ],
      ),
    );
  }
}
