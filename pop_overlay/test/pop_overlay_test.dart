import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pop_overlay/pop_overlay.dart';

void main() {
  group('PopOverlay Tests', () {
    setUp(() {
      // Clean up any existing popups before each test
      // Note: PopOverlay doesn't have removeAllPops, so we'll skip cleanup
    });

    tearDown(() {
      // Clean up after each test by removing any added popups
      // Note: PopOverlay doesn't have removeAllPops built-in
    });

    test('PopOverlayContent can be created with required parameters', () {
      final content = PopOverlayContent(
        id: 'test_popup',
        widget: const Text('Test'),
      );

      expect(content.id, 'test_popup');
      expect(content.widget, isNotNull);
    });

    test('PopOverlayContent can be created with draggable enabled', () {
      final content = PopOverlayContent(
        id: 'draggable_test',
        widget: const Text('Draggable Test'),
        isDraggeable: true,
      );

      expect(content.isDraggeable, true);
    });

    test('PopOverlayContent respects shouldDismissOnBackgroundTap setting', () {
      final content1 = PopOverlayContent(
        id: 'dismissible_true',
        widget: const Text('Test'),
        shouldDismissOnBackgroundTap: true,
      );

      final content2 = PopOverlayContent(
        id: 'dismissible_false',
        widget: const Text('Test'),
        shouldDismissOnBackgroundTap: false,
      );

      expect(content1.shouldDismissOnBackgroundTap, true);
      expect(content2.shouldDismissOnBackgroundTap, false);
    });

    test('PopOverlayContent can be created with custom dismissBarrierColor',
        () {
      final customColor = Colors.black.withValues(alpha: 0.5);

      final content = PopOverlayContent(
        id: 'colored_barrier',
        widget: const Text('Test'),
        dismissBarrierColor: customColor,
      );

      expect(content.dismissBarrierColor, customColor);
    });

    test('PopOverlayContent auto-dismissal duration can be set', () {
      const customDuration = Duration(milliseconds: 500);

      final content = PopOverlayContent(
        id: 'auto_dismiss_test',
        widget: const Text('Test'),
        duration: customDuration,
      );

      expect(content.duration, customDuration);
    });

    test('PopOverlayContent can have blur background effect', () {
      final content1 = PopOverlayContent(
        id: 'blur_true',
        widget: const Text('Test'),
        shouldBlurBackground: true,
      );

      final content2 = PopOverlayContent(
        id: 'blur_false',
        widget: const Text('Test'),
        shouldBlurBackground: false,
      );

      expect(content1.shouldBlurBackground, true);
      expect(content2.shouldBlurBackground, false);
    });

    test('Multiple PopOverlayContent items can be created independently', () {
      final content1 = PopOverlayContent(
        id: 'popup_1',
        widget: const Text('Popup 1'),
      );

      final content2 = PopOverlayContent(
        id: 'popup_2',
        widget: const Text('Popup 2'),
      );

      expect(content1.id, 'popup_1');
      expect(content2.id, 'popup_2');
      expect(content1.id, isNot(content2.id));
    });

    test('PopOverlayContent can be created with all optional parameters', () {
      const onDismissed = _MockCallback();

      final content = PopOverlayContent(
        id: 'complete_test',
        widget: Container(
          padding: const EdgeInsets.all(16),
          child: const Text('Complete Content'),
        ),
        isDraggeable: true,
        shouldDismissOnBackgroundTap: true,
        dismissBarrierColor: Colors.black.withValues(alpha: 0.4),
        duration: const Duration(milliseconds: 3000),
        onDismissed: onDismissed.call,
        shouldBlurBackground: true,
        shouldAnimatePopup: true,
      );

      expect(content.id, 'complete_test');
      expect(content.isDraggeable, true);
      expect(content.shouldDismissOnBackgroundTap, true);
      expect(content.duration, const Duration(milliseconds: 3000));
      expect(content.shouldBlurBackground, true);
      expect(content.shouldAnimatePopup, true);
    });

    test('PopOverlayContent can have padding', () {
      const testPadding = EdgeInsets.all(20);

      final content = PopOverlayContent(
        id: 'padded_test',
        widget: const Text('Test'),
        padding: testPadding,
      );

      expect(content.padding, testPadding);
    });

    test('PopOverlayContent can have frame color and width', () {
      final content = PopOverlayContent(
        id: 'frame_test',
        widget: const Text('Test'),
        frameColor: Colors.blue,
        frameWidth: 2.0,
      );

      expect(content.frameColor, Colors.blue);
      expect(content.frameWidth, 2.0);
    });

    test('PopOverlayContent can have box shadow', () {
      final content = PopOverlayContent(
        id: 'shadow_test',
        widget: const Text('Test'),
        hasBoxShadow: true,
      );

      expect(content.hasBoxShadow, true);
    });

    test('PopOverlayContent id is required and unique', () {
      final content1 = PopOverlayContent(
        id: 'unique_id_1',
        widget: const Text('Test 1'),
      );

      final content2 = PopOverlayContent(
        id: 'unique_id_2',
        widget: const Text('Test 2'),
      );

      expect(content1.id, isNotEmpty);
      expect(content2.id, isNotEmpty);
      expect(content1.id != content2.id, true);
    });

    test('PopOverlayContent with nested widgets can be created', () {
      final complexWidget = Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Complex Widget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Action'),
            ),
          ],
        ),
      );

      final content = PopOverlayContent(
        id: 'complex_widget_test',
        widget: complexWidget,
      );

      expect(content.widget, isNotNull);
      expect(content.widget, complexWidget);
    });

    test('PopOverlay.isActive returns correct status', () {
      // Initially no popups are active
      expect(PopOverlay.isActive, false);
    });

    test('PopOverlay controller is accessible', () {
      final controller = PopOverlay.controller;
      expect(controller, isNotNull);
    });
  });
}

/// Mock callback for testing
class _MockCallback {
  const _MockCallback();

  void call() {
    // Mock implementation
  }
}
