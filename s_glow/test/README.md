# Test Documentation

This directory contains comprehensive tests for the glow1_2 package.

## Test Files

### glow1_test.dart
Tests for the Glow1 widget (breathing effect):
- Basic rendering with child widget
- Enable/disable functionality
- Animation behavior
- Custom color support
- Opacity validation and assertions
- State change handling
- Custom border radius
- Animation duration
- Repeat animation flag
- Custom scale values

### glow2_test.dart
Tests for the Glow2 widget (ripple effect):
- Basic rendering with child widget
- Enable/disable animation
- Glow count variations
- Custom glow colors
- Circle and rectangle shapes
- Border radius validation
- Shape assertions (circle cannot have border radius)
- Animation behavior
- Start delay functionality
- State change handling
- Repeat flag behavior
- Custom curves
- Glow radius factor (v1.1.0: unified for both shapes)
- Start inset factor (v1.1.0: controls where glow begins)
- Duration customization
- Widget update handling
- Shape-aware expansion calculations (v1.1.0)

### glow1_2_test.dart
Package-level tests:
- Verify all widgets are properly exported
- Package structure validation

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/glow1_test.dart
flutter test test/glow2_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Generate coverage report
```bash
# Install lcov if not already installed (macOS)
brew install lcov

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

## Test Coverage

The test suite covers:
- ✅ Widget rendering
- ✅ Animation behavior
- ✅ Property validation
- ✅ State management
- ✅ Edge cases
- ✅ Assertion tests
- ✅ Widget lifecycle
- ✅ User interactions
- ✅ Shape-aware expansion (v1.1.0)
- ✅ Start inset calculations (v1.1.0)
- ✅ Unified glowRadiusFactor behavior (v1.1.0)

## Writing New Tests

When adding new features, ensure to:
1. Add corresponding tests to the appropriate test file
2. Test both positive and negative scenarios
3. Include assertion tests for validation
4. Test state changes and lifecycle events
5. Verify animation behavior
6. Update this README with new test descriptions
