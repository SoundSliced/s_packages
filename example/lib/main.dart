import 'dart:ui';

import 'package:s_packages/s_packages.dart';

import 'screens/home_screen.dart';

void main() {
  _installDebugNullLogFilter();

  runZonedGuarded(
    () {
      runApp(const SPackagesExampleApp());
    },
    (error, stackTrace) {},
    zoneSpecification: kDebugMode
        ? ZoneSpecification(
            print: (self, parent, zone, line) {
              final trimmed = line.trim().toLowerCase();
              if (trimmed == 'null') {
                return;
              }
              parent.print(zone, line);
            },
          )
        : null,
  );
}

void _installDebugNullLogFilter() {
  if (!kDebugMode) return;

  final previousDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    final trimmed = message?.trim().toLowerCase();
    if (trimmed == null || trimmed.isEmpty || trimmed == 'null') {
      return;
    }
    previousDebugPrint(message, wrapWidth: wrapWidth);
  };
}

class SPackagesExampleApp extends StatelessWidget {
  const SPackagesExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ForcePhoneSizeOnWeb(
      size: const Size(2048, 2732),
      child: MaterialApp(
        title: 'S Packages Examples',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        //https://stackoverflow.com/questions/69232764/flutter-web-cannot-scroll-with-mouse-down-drag-flutter-2-5
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          physics: const BouncingScrollPhysics(),
          scrollbars: true,
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown,
            PointerDeviceKind.trackpad
          },
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        builder: (context, child) => Modal.appBuilder(
          context,
          child,
          backgroundColor: Colors.black,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
