import 'package:calendar_date_picker2/calendar_date_picker2.dart';
// The app side of these tests is a legacy app, on purpose.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:s_packages/s_packages.dart';

const _seed = Color(0xFFB00020);

final _legacyTheme = legacy.ThemeData(
  colorScheme: legacy.ColorScheme.fromSeed(seedColor: _seed),
  tooltipTheme: const legacy.TooltipThemeData(
    waitDuration: Duration(milliseconds: 123),
  ),
  inputDecorationTheme: const legacy.InputDecorationTheme(
    filled: true,
    border: legacy.OutlineInputBorder(),
  ),
);

/// A legacy `MaterialApp`, bridged once in its builder, as an app would be.
Future<BuildContext> _pumpLegacyApp(
  WidgetTester tester, {
  Widget body = const SizedBox(),
}) async {
  late BuildContext captured;
  await tester.pumpWidget(
    legacy.MaterialApp(
      theme: _legacyTheme,
      builder: (context, child) => SMaterialUiBridge(child: child!),
      home: legacy.Scaffold(
        body: Builder(
          builder: (context) {
            captured = context;
            return body;
          },
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  testWidgets('maps the legacy theme into a material_ui theme', (tester) async {
    final context = await _pumpLegacyApp(tester);
    final theme = Theme.of(context);
    final legacyScheme = _legacyTheme.colorScheme;

    expect(theme.colorScheme.primary, legacyScheme.primary);
    expect(theme.colorScheme.surface, legacyScheme.surface);
    expect(theme.colorScheme.brightness, legacyScheme.brightness);
    // Theme.of returns the localized theme, with the font sizes filled in.
    expect(
      theme.textTheme.bodyMedium,
      legacy.Theme.of(context).textTheme.bodyMedium,
    );
    expect(theme.tooltipTheme.waitDuration, const Duration(milliseconds: 123));
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
  });

  testWidgets('provides material_ui localizations and Material', (
    tester,
  ) async {
    final context = await _pumpLegacyApp(tester, body: const TextField());

    expect(MaterialLocalizations.of(context), isNotNull);
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('material_ui snack bars show', (tester) async {
    final context = await _pumpLegacyApp(tester);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('saved')));
    await tester.pumpAndSettle();

    expect(find.text('saved'), findsOneWidget);
  });

  testWidgets('calendar_date_picker2 dialog opens under a legacy app', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 0.7;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final context = await _pumpLegacyApp(tester);

    showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: DateTime(2026),
        lastDate: DateTime(2026, 12, 31),
      ),
      dialogSize: const Size(325, 400),
      value: [DateTime(2026, 10, 26)],
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CalendarDatePicker2), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
  });

  testWidgets('loading indicator takes the legacy primary colour', (
    tester,
  ) async {
    await _pumpLegacyApp(
      tester,
      body: const SizedBox.square(
        dimension: 40,
        child: SLoadingIndicator(pause: true),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SLoadingIndicator), findsOneWidget);
  });
}
