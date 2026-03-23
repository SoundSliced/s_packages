import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    PopOverlay.clearAll();
    SContextMenu.closeAllOpenMenus();
  });

  testWidgets('resolves a popup tap-region scope in descendants',
      (tester) async {
    final inheritedGroupId = Object();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PopOverlayTapRegionScope(
            tapRegionGroupId: inheritedGroupId,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SContextMenu(
                  buttons: [
                    SContextMenuItem(
                        label: 'Edit', icon: Icons.edit, onPressed: () {}),
                  ],
                  child: const SizedBox(width: 200, height: 80),
                ),
                Builder(
                  builder: (context) {
                    return Text(
                      identical(PopOverlayTapRegionScope.maybeOf(context),
                              inheritedGroupId)
                          ? 'scope-ok'
                          : 'scope-missing',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('scope-ok'), findsOneWidget);
  });
}
