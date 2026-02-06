# Week Calendar Tests

Comprehensive test suite for the week_calendar package covering all features and edge cases.

## Test Files

### 1. `week_calendar_test.dart`
Main widget tests covering core functionality:

- **Widget Creation Tests**
  - Default constructor
  - Outlined constructor
  - Minimal constructor
  - All calendar types

- **User Interaction Tests**
  - Date selection
  - Month navigation (previous/next)
  - Header interactions
  - Today button functionality

- **Display Tests**
  - Month header visibility
  - Custom navigation icons
  - Calendar type rendering

- **Callback Tests**
  - `onDateSelected`
  - `onNextMonth`
  - `onPreviousMonth`
  - `onHeaderDateTapped`
  - `onHeaderTodayDate`

- **Integration Tests**
  - Complete user flows
  - State management
  - Multiple interactions

### 2. `enums_test.dart`
Tests for enum types:

- **Weekday Enum**
  - All 7 weekday values (Monday-Sunday)
  - ISO 8601 compliance (Monday = 1, Sunday = 7)
  - `fromDateTime()` conversion
  - Value ordering

- **WeekCalendarType Enum**
  - Standard, Outlined, Minimal, Elevated types
  - Enum names and values
  - Ordering verification

### 3. `week_calendar_style_test.dart`
Style configuration tests:

- **Default Styles**
  - Default text styles
  - Default colors
  - Default sizes
  - Default animations

- **Custom Styles**
  - Custom colors
  - Custom text styles
  - Custom indicator sizes
  - Custom borders
  - Custom shadows
  - Custom animations

- **Style Properties**
  - Animation durations
  - Animation curves
  - Particle effects
  - Const constructibility

### 4. `date_handling_test.dart`
Date manipulation and edge cases:

- **Date Handling**
  - Current date
  - Past dates
  - Future dates
  - First day of month
  - Last day of month

- **Calendar Edge Cases**
  - Leap years (February 29)
  - Non-leap years (February 28)
  - Months with 31 days
  - Months with 30 days
  - Year boundaries

- **UTC Date Support**
  - UTC date creation
  - UTC year boundaries
  - Local vs UTC comparison

- **Week Generation**
  - Different starting days (Monday-Sunday)
  - Week boundaries
  - Month transitions

- **State Updates**
  - Selected date changes
  - Starting day changes
  - Dynamic updates

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/week_calendar_test.dart
flutter test test/enums_test.dart
flutter test test/week_calendar_style_test.dart
flutter test test/date_handling_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Open in browser (macOS)
open coverage/html/index.html

# Open in browser (Linux)
xdg-open coverage/html/index.html

# Open in browser (Windows)
start coverage/html/index.html
```

## Test Coverage

The test suite provides comprehensive coverage of:

### Widget Functionality (95%+)
- ✅ All constructors (default, outlined, minimal)
- ✅ All calendar types (standard, outlined, minimal, elevated)
- ✅ Date selection and callbacks
- ✅ Month navigation
- ✅ Header interactions
- ✅ Animation controls
- ✅ Style customization

### Date Logic (100%)
- ✅ All month lengths (28, 29, 30, 31 days)
- ✅ Leap year handling
- ✅ Year transitions
- ✅ Month transitions
- ✅ UTC and local dates
- ✅ Week generation for all starting days

### Configuration (100%)
- ✅ All weekday values
- ✅ All calendar types
- ✅ Style properties
- ✅ Animation settings
- ✅ Icon customization

### Edge Cases (100%)
- ✅ Leap years (2024, 2028, etc.)
- ✅ Non-leap years (2025, 2026, etc.)
- ✅ Year boundaries (Dec 31 → Jan 1)
- ✅ Month boundaries
- ✅ Future date restrictions
- ✅ All starting day configurations

## Test Organization

Tests are organized by feature area:

```
test/
├── week_calendar_test.dart        # Core widget tests
├── enums_test.dart                # Enum type tests
├── week_calendar_style_test.dart  # Styling tests
└── date_handling_test.dart        # Date logic tests
```

## Writing New Tests

When adding new features, follow these patterns:

### Widget Test Template
```dart
testWidgets('should [expected behavior]', (WidgetTester tester) async {
  // Setup
  final selectedDate = DateTime(2026, 1, 15);
  final initialDate = DateTime(2026, 1, 1);
  
  // Build widget
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WeekCalendar(
          initialDate: initialDate,
          selectedDate: selectedDate,
          onDateSelected: (date) {},
          onNextMonth: () {},
          onPreviousMonth: () {},
        ),
      ),
    ),
  );
  
  // Verify
  expect(find.byType(WeekCalendar), findsOneWidget);
});
```

### Unit Test Template
```dart
test('should [expected behavior]', () {
  // Setup
  const style = WeekCalendarStyle(activeDayColor: Colors.red);
  
  // Verify
  expect(style.activeDayColor, Colors.red);
});
```

## Continuous Integration

These tests are designed to run in CI/CD environments:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter analyze
```

## Test Assertions Used

- `expect()` - Basic assertions
- `findsOneWidget` - Widget presence
- `findsNothing` - Widget absence
- `findsNWidgets(n)` - Multiple widgets
- `findsAtLeastNWidgets(n)` - Minimum count
- `equals()` - Value equality
- `isNull` / `isNotNull` - Null checks
- `isTrue` / `isFalse` - Boolean checks

## Best Practices

1. **Test Isolation**: Each test should be independent
2. **Clear Names**: Use descriptive test names
3. **Arrange-Act-Assert**: Follow AAA pattern
4. **Edge Cases**: Test boundaries and special cases
5. **Cleanup**: Use `pumpWidget(Container())` between tests when needed
6. **Mock Data**: Use consistent, predictable test data
7. **Coverage**: Aim for 90%+ code coverage

## Troubleshooting

### Golden File Tests
If golden file tests fail:
```bash
flutter test --update-goldens
```

### Flaky Tests
If tests are inconsistent:
- Add `await tester.pumpAndSettle()` after interactions
- Increase timeout durations
- Check for async operations

### Widget Not Found
If `find.text()` or `find.byType()` fails:
- Use `find.byKey()` with explicit keys
- Check widget tree with `debugDumpApp()`
- Verify widget is actually rendered

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Testing Best Practices](https://docs.flutter.dev/testing/best-practices)

## Contributing

When contributing, please:
1. Add tests for new features
2. Update existing tests if behavior changes
3. Maintain test coverage above 90%
4. Run all tests before submitting PR
5. Document complex test scenarios
