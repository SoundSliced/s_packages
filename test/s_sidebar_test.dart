import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_sidebar/s_sidebar.dart';

void main() {
  group('SSideBar Modernization Tests', () {
    testWidgets('renders headers and dividers correctly and ignores tap on them',
        (tester) async {
      int tapCount = 0;
      int selectedIdx = 3;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: [
                SSideBarItem.header(title: 'MAIN SECTION'),
                SSideBarItem(
                  iconSelected: Icons.home,
                  title: 'Home',
                ),
                SSideBarItem.divider(),
                SSideBarItem(
                  iconSelected: Icons.settings,
                  title: 'Settings',
                ),
              ],
              onTapForAllTabButtons: (idx) {
                tapCount++;
                selectedIdx = idx;
              },
              preSelectedItemIndex: selectedIdx,
              settingsDivider: false,
            ),
          ),
        ),
      );

      // Verify that Header and Divider items are rendered
      expect(find.text('MAIN SECTION'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);

      // Tap on the Header 'MAIN SECTION' and verify it is not selected
      await tester.tap(find.text('MAIN SECTION'));
      await tester.pump();
      expect(tapCount, 0);

      // Tap on the 'Home' item and verify it is selected (index 1)
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(tapCount, 1);
      expect(selectedIdx, 1);
    });

    testWidgets('renders custom header and custom footer in SSideBar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: [
                SSideBarItem(
                  iconSelected: Icons.home,
                  title: 'Home',
                ),
              ],
              onTapForAllTabButtons: (_) {},
              header: const Text('CUSTOM HEADER'),
              footer: const Text('CUSTOM FOOTER'),
            ),
          ),
        ),
      );

      expect(find.text('CUSTOM HEADER'), findsOneWidget);
      expect(find.text('CUSTOM FOOTER'), findsOneWidget);
    });

    testWidgets('renders with modern bottom minimizes button and toggles state',
        (tester) async {
      bool minimizedState = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: [
                SSideBarItem(
                  iconSelected: Icons.home,
                  title: 'Home',
                ),
              ],
              onTapForAllTabButtons: (_) {},
              minimizeButtonStyle: SideBarMinimizeButtonStyle.bottomRow,
              minimizeButtonOnTap: (min) {
                minimizedState = min;
              },
            ),
          ),
        ),
      );

      // Verify the modern collapse row is rendered (Text label 'Collapse')
      expect(find.text('Collapse'), findsOneWidget);

      // Tap on the collapse button row
      await tester.tap(find.text('Collapse'));
      await tester.pumpAndSettle();

      // Minimize state should be true
      expect(minimizedState, isTrue);
      // 'Collapse' text should not be visible anymore when minimized
      expect(find.text('Collapse'), findsNothing);
    });

    testWidgets('renders with floating minimize button style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: [
                SSideBarItem(
                  iconSelected: Icons.home,
                  title: 'Home',
                ),
              ],
              onTapForAllTabButtons: (_) {},
              minimizeButtonStyle: SideBarMinimizeButtonStyle.floating,
            ),
          ),
        ),
      );

      // Since floating is selected, bottom collapse row shouldn't exist
      expect(find.text('Collapse'), findsNothing);

      // We should see a Stack and the circular icon chevron
      expect(find.byType(Stack), findsWidgets);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    });
  });
}
