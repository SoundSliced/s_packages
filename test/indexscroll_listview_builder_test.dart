import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

/// Runs one frame the way Flutter web does: `onBeginFrame` then `onDrawFrame`
/// with NO microtask flush in between (unlike `tester.pump`).
void _webFrame(WidgetTester tester) {
  final binding = tester.binding;
  binding.handleBeginFrame(
      Duration(microseconds: binding.clock.now().microsecondsSinceEpoch));
  binding.handleDrawFrame();
}

class _Host extends StatefulWidget {
  const _Host({super.key, required this.labels});
  final List<String> labels;
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<String> labels = widget.labels;
  void setLabels(List<String> next) => setState(() => labels = next);

  @override
  Widget build(BuildContext context) {
    final current = labels;
    return MaterialApp(
      home: Scaffold(
        body: IndexScrollListViewBuilder(
          itemCount: current.length,
          itemKeyBuilder: (i) => ValueKey(current[i]),
          onScrolledTo: (_) {},
          itemBuilder: (context, i) =>
              SizedBox(height: 20, child: Text(current[i])),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
      'a structural reset in the frame row insertions complete does not '
      'dispose an AnimationController twice (Flutter web frame ordering)',
      (tester) async {
    final host = GlobalKey<_HostState>();
    await tester
        .pumpWidget(_Host(key: host, labels: const ['a', 'b', 'c', 'd']));

    // Small change (< 30% new keys): an animated insertion (default 400ms).
    host.currentState!.setLabels(const ['a', 'b', 'c', 'd', 'e']);
    await tester.pump();

    // Let the insertion's time run out without a frame, so the next frame's
    // tick completes it.
    await tester.binding.delayed(const Duration(seconds: 1));

    // Mostly-new key set (> 30% changed) => structural reset, applied in the
    // very frame whose tick completes the insertion above.
    host.currentState!.setLabels(const ['x', 'y', 'z']);
    _webFrame(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('x'), findsOneWidget);
    expect(find.text('y'), findsOneWidget);
    expect(find.text('z'), findsOneWidget);
    for (final gone in ['a', 'b', 'c', 'd', 'e']) {
      expect(find.text(gone), findsNothing);
    }
  });

  testWidgets('a structural reset shows exactly the new rows', (tester) async {
    final host = GlobalKey<_HostState>();
    await tester.pumpWidget(_Host(key: host, labels: const ['a', 'b', 'c']));

    host.currentState!.setLabels(const ['d', 'e']);
    await tester.pump();

    expect(find.text('d'), findsOneWidget);
    expect(find.text('e'), findsOneWidget);
    for (final gone in ['a', 'b', 'c']) {
      expect(find.text(gone), findsNothing);
    }
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNWidgets(2));
  });
}
