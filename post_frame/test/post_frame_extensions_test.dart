import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BuildContext Extensions', () {
    testWidgets('postFrame runs after frame with mounted check',
        (tester) async {
      var executed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              context.postFrame(() {
                executed = true;
              });
              return Container();
            },
          ),
        ),
      );

      expect(executed, false);
      await tester.pumpAndSettle();
      expect(executed, true);
    });

    testWidgets('postFrameRun respects mounted predicate', (tester) async {
      var executed = false;
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      // Schedule action on captured context.
      capturedContext.postFrameRun(() {
        executed = true;
      });

      // Remove widget before frame completes.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      // Action should not execute because widget was unmounted.
      expect(executed, false);
    });

    testWidgets('postFrameDebounced cancels previous tasks', (tester) async {
      var executionCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Schedule multiple debounced tasks with same key.
              context.postFrameDebounced(
                () => executionCount++,
                debounceKey: 'test',
              );
              context.postFrameDebounced(
                () => executionCount++,
                debounceKey: 'test',
              );
              context.postFrameDebounced(
                () => executionCount++,
                debounceKey: 'test',
              );
              return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Only the last task should execute.
      expect(executionCount, 1);
    });
  });

  group('PostFramePredicates', () {
    testWidgets('mounted predicate works', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      final predicate = PostFramePredicates.mounted(capturedContext);
      expect(predicate(), true);

      // Remove widget.
      await tester.pumpWidget(const SizedBox.shrink());
      expect(predicate(), false);
    });

    testWidgets('routeActive predicate works', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      final predicate = PostFramePredicates.routeActive(capturedContext);
      expect(predicate(), true);
    });

    test('all predicate combines with AND logic', () {
      var flag1 = true;
      var flag2 = true;

      final predicate = PostFramePredicates.all([
        () => flag1,
        () => flag2,
      ]);

      expect(predicate(), true);
      flag1 = false;
      expect(predicate(), false);
      flag1 = true;
      flag2 = false;
      expect(predicate(), false);
    });

    test('any predicate combines with OR logic', () {
      var flag1 = false;
      var flag2 = false;

      final predicate = PostFramePredicates.any([
        () => flag1,
        () => flag2,
      ]);

      expect(predicate(), false);
      flag1 = true;
      expect(predicate(), true);
      flag1 = false;
      flag2 = true;
      expect(predicate(), true);
    });

    test('not predicate negates', () {
      var flag = true;
      final predicate = PostFramePredicates.not(() => flag);

      expect(predicate(), false);
      flag = false;
      expect(predicate(), true);
    });
  });

  group('Conditional Execution', () {
    testWidgets('predicate prevents execution when false', (tester) async {
      var shouldExecute = false;
      var executed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              PostFrame.run(
                () => executed = true,
                predicate: () => shouldExecute,
              );
              return Container();
            },
          ),
        ),
      );

      await tester.pump();
      expect(executed, false);

      // Now allow execution.
      shouldExecute = true;
      executed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              PostFrame.run(
                () => executed = true,
                predicate: () => shouldExecute,
              );
              return Container();
            },
          ),
        ),
      );

      await tester.pump();
      expect(executed, true);
    });
  });

  group('Error Handling', () {
    testWidgets('global error handler is called on error', (tester) async {
      Object? capturedError;
      StackTrace? capturedStack;
      String? capturedOperation;

      PostFrame.errorHandler = (error, stack, operation) {
        capturedError = error;
        capturedStack = stack;
        capturedOperation = operation;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              PostFrame.run(() {
                throw Exception('Test error');
              });
              return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('Test error'));
      expect(capturedStack, isNotNull);
      expect(capturedOperation, 'PostFrame.run');

      // Clean up.
      PostFrame.errorHandler = null;
    });

    testWidgets('local error handler is called on error', (tester) async {
      Object? capturedError;
      StackTrace? capturedStack;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              PostFrame.run(
                () {
                  throw Exception('Test error');
                },
                onError: (error, stack) {
                  capturedError = error;
                  capturedStack = stack;
                },
              );
              return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('Test error'));
      expect(capturedStack, isNotNull);
    });
  });

  group('Debounced', () {
    testWidgets('debounced cancels previous tasks', (tester) async {
      var executionCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Schedule multiple tasks rapidly.
              PostFrame.debounced(
                () => executionCount++,
                debounceKey: 'key1',
              );
              PostFrame.debounced(
                () => executionCount++,
                debounceKey: 'key1',
              );
              PostFrame.debounced(
                () => executionCount++,
                debounceKey: 'key1',
              );
              return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Only the last task should execute.
      expect(executionCount, 1);
    });

    testWidgets('different debounce keys do not interfere', (tester) async {
      var count1 = 0;
      var count2 = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              PostFrame.debounced(
                () => count1++,
                debounceKey: 'key1',
              );
              PostFrame.debounced(
                () => count2++,
                debounceKey: 'key2',
              );
              return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both tasks should execute.
      expect(count1, 1);
      expect(count2, 1);
    });
  });
}
