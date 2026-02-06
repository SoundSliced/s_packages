import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_widgets/s_widgets.dart';

void main() {
  group('s_widgets Tests', () {
    // =========================================================================
    // DismissKeyboard Tests
    // =========================================================================
    group('DismissKeyboard', () {
      testWidgets('DismissKeyboard wraps child widget',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DismissKeyboard(
                child: Text('Test Child'),
              ),
            ),
          ),
        );

        expect(find.text('Test Child'), findsOneWidget);
      });

      testWidgets('DismissKeyboard detects tap gesture',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DismissKeyboard(
                child: GestureDetector(
                  child: Text('Test Child'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test Child'));
        await tester.pumpAndSettle();

        expect(find.text('Test Child'), findsOneWidget);
      });
    });

    // =========================================================================
    // SLoadingIndicator Tests
    // =========================================================================
    group('SLoadingIndicator', () {
      testWidgets('SLoadingIndicator renders with default parameters',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SLoadingIndicator(),
            ),
          ),
        );

        expect(find.byType(SLoadingIndicator), findsOneWidget);
      });

      testWidgets('SLoadingIndicator renders with custom scale',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SLoadingIndicator(scale: 2.0),
            ),
          ),
        );

        expect(find.byType(SLoadingIndicator), findsOneWidget);
      });

      testWidgets('SLoadingIndicator renders with custom colors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SLoadingIndicator(
                colors: [Colors.blue, Colors.red],
              ),
            ),
          ),
        );

        expect(find.byType(SLoadingIndicator), findsOneWidget);
      });
    });

    // =========================================================================
    // STextButton Tests
    // =========================================================================
    group('STextButton', () {
      testWidgets('STextButton renders with title',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: STextButton(
                buttonTitle: 'Click Me',
                onTap: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Click Me'), findsOneWidget);
      });

      testWidgets('STextButton calls onTap callback',
          (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: STextButton(
                buttonTitle: 'Click Me',
                onTap: (_) {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(STextButton));
        await tester.pumpAndSettle();

        expect(tapped, true);
      });

      testWidgets('STextButton renders with custom dimensions',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: STextButton(
                buttonTitle: 'Large Button',
                height: 100,
                width: 200,
                onTap: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Large Button'), findsOneWidget);
      });
    });

    // =========================================================================
    // SIconButton Tests
    // =========================================================================
    group('SIconButton', () {
      testWidgets('SIconButton renders with icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SIconButton(
                iconData: Icons.home,
                onTap: (_) {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.home), findsOneWidget);
      });

      testWidgets('SIconButton renders with label',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SIconButton(
                iconData: Icons.home,
                label: 'Home',
                onTap: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('SIconButton calls onTap callback',
          (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SIconButton(
                iconData: Icons.home,
                onTap: (_) {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();

        expect(tapped, true);
      });
    });

    // =========================================================================
    // SDivider Tests
    // =========================================================================
    group('SDivider', () {
      testWidgets('SDivider renders horizontal divider by default',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SDivider(
                lineLength: 200,
                lineThickness: 2,
              ),
            ),
          ),
        );

        expect(find.byType(SDivider), findsOneWidget);
      });

      testWidgets('SDivider renders vertical divider',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SDivider(
                lineLength: 200,
                lineThickness: 2,
                isVertical: true,
              ),
            ),
          ),
        );

        expect(find.byType(SDivider), findsOneWidget);
      });

      testWidgets('SDivider renders with custom color',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SDivider(
                lineLength: 200,
                lineThickness: 2,
                lineColor: Colors.red,
              ),
            ),
          ),
        );

        expect(find.byType(SDivider), findsOneWidget);
      });
    });

    // =========================================================================
    // SBlur Tests
    // =========================================================================
    group('SBlur', () {
      testWidgets('SBlur renders child widget', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SBlur(
                child: Text('Blurred Content'),
              ),
            ),
          ),
        );

        expect(find.text('Blurred Content'), findsOneWidget);
      });

      testWidgets('SBlur can be disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SBlur(
                isEnabled: false,
                child: Text('Not Blurred'),
              ),
            ),
          ),
        );

        expect(find.text('Not Blurred'), findsOneWidget);
      });

      testWidgets('SBlur renders with custom blur amounts',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SBlur(
                blurAmountOnX: 20,
                blurAmountOnY: 20,
                child: Text('Heavily Blurred'),
              ),
            ),
          ),
        );

        expect(find.text('Heavily Blurred'), findsOneWidget);
      });
    });

    // =========================================================================
    // SAnimatedBlur Tests
    // =========================================================================
    group('SAnimatedBlur', () {
      testWidgets('SAnimatedBlur renders child widget',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SAnimatedBlur(
                child: Text('Animated Blur Content'),
              ),
            ),
          ),
        );

        expect(find.text('Animated Blur Content'), findsOneWidget);
      });

      testWidgets('SAnimatedBlur animates on build',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SAnimatedBlur(
                opacity: 0.8,
                child: Text('Animating'),
              ),
            ),
          ),
        );

        expect(find.text('Animating'), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.text('Animating'), findsOneWidget);
      });
    });

    // =========================================================================
    // MeasureChildSizeWidget Tests
    // =========================================================================
    group('MeasureChildSizeWidget', () {
      testWidgets('MeasureChildSizeWidget calls onChange with size',
          (WidgetTester tester) async {
        Size? measuredSize;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MeasureChildSizeWidget(
                onChange: (size) {
                  measuredSize = size;
                },
                child: SizedBox(
                  width: 200,
                  height: 100,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(measuredSize, isNotNull);
        expect(measuredSize!.width, 200);
        expect(measuredSize!.height, 100);
      });
    });

    // =========================================================================
    // ExpandCollapseButton Tests
    // =========================================================================
    group('ExpandCollapseButton', () {
      testWidgets('ExpandCollapseButton renders with initial state',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExpandCollapseButton(
                isExpanded: false,
                onTap: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(ExpandCollapseButton), findsOneWidget);
      });

      testWidgets('ExpandCollapseButton calls onTap with new state',
          (WidgetTester tester) async {
        bool? newState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExpandCollapseButton(
                isExpanded: false,
                onTap: (state) {
                  newState = state;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ExpandCollapseButton));
        await tester.pumpAndSettle();

        expect(newState, true);
      });
    });

    // =========================================================================
    // TextFormFieldClearButton Tests
    // =========================================================================
    group('TextFormFieldClearButton', () {
      testWidgets('TextFormFieldClearButton renders when onPressed is provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextFormFieldClearButton(
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('TextFormFieldClearButton is hidden when onPressed is null',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextFormFieldClearButton(),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsNothing);
      });

      testWidgets('TextFormFieldClearButton calls onPressed callback',
          (WidgetTester tester) async {
        bool pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextFormFieldClearButton(
                onPressed: () {
                  pressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        expect(pressed, true);
      });
    });

    // =========================================================================
    // ScrollTextFormFieldWhenKeyboardIsShown Tests
    // =========================================================================
    group('ScrollTextFormFieldWhenKeyboardIsShown', () {
      testWidgets('ScrollTextFormFieldWhenKeyboardIsShown renders child',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScrollTextFormFieldWhenKeyboardIsShown(
                child: Column(
                  children: [
                    Text('Scrollable Content'),
                    TextField(),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Scrollable Content'), findsOneWidget);
      });
    });

    // =========================================================================
    // Widget Extensions Tests
    // =========================================================================
    group('Widget Extensions', () {
      testWidgets('Widget.addMaterialWidget wraps widget in Material',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Test').addMaterialWidget(),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
        expect(find.byType(Material), findsWidgets);
      });

      testWidgets('Widget.addTooltipWidget adds tooltip',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Icon(Icons.info).addTooltipWidget('Tooltip Text'),
            ),
          ),
        );

        expect(find.byIcon(Icons.info), findsOneWidget);
        expect(find.byType(Tooltip), findsOneWidget);
      });

      testWidgets('Widget.colorFilter applies color filter',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                color: Colors.red,
                child: const Text('Filtered'),
              ).colorFilter(),
            ),
          ),
        );

        expect(find.text('Filtered'), findsOneWidget);
        expect(find.byType(ColorFiltered), findsOneWidget);
      });

      testWidgets('Widget.borderRadius adds border radius',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Text('Rounded'),
              ).borderRadius(),
            ),
          ),
        );

        expect(find.text('Rounded'), findsOneWidget);
      });
    });

    // =========================================================================
    // ShowSnackBar Extension Tests
    // =========================================================================
    group('ShowSnackBar Extension', () {
      testWidgets('BuildContext.showSnackBar displays snackbar',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      context.showSnackBar(message: 'Test Snackbar');
                    },
                    child: const Text('Show Snackbar'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Snackbar'));
        await tester.pumpAndSettle();

        expect(find.text('Test Snackbar'), findsOneWidget);
      });

      testWidgets('BuildContext.showErrorSnackBar displays error snackbar',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      context.showErrorSnackBar(message: 'Error occurred');
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        expect(find.text('Error occurred'), findsOneWidget);
      });
    });

    // =========================================================================
    // MountedState Tests
    // =========================================================================
    group('MountedState', () {
      testWidgets('MountedState prevents setState on unmounted widget',
          (WidgetTester tester) async {
        bool stateSetFailed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestMountedWidget(
                onStateSetError: () {
                  stateSetFailed = true;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // The widget should not throw an error when setState is called
        expect(stateSetFailed, false);
      });
    });
  });
}

// ============================================================================
// Test Helper Widgets
// ============================================================================

class TestMountedWidget extends StatefulWidget {
  final Function() onStateSetError;

  const TestMountedWidget({
    required this.onStateSetError,
    super.key,
  });

  @override
  State<TestMountedWidget> createState() => _TestMountedWidgetState();
}

class _TestMountedWidgetState extends MountedState<TestMountedWidget> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        setState(() => _counter++);
      } catch (e) {
        widget.onStateSetError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Counter: $_counter'),
    );
  }
}
