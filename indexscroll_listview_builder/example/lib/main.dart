// (imports and main already declared above in this file)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the separate card widgets
import 'basic_example_card.dart';
import 'declarative_scroll_card.dart';
import 'imperative_scroll_card.dart';
import 'declarative_test_card.dart';

void main() {
  // Entry point for the demo app.
  runApp(const DemoApp());
}

/// Small demo showcasing IndexScrollListViewBuilder features:
/// - Basic list usage
/// - Auto-scrolling to a target index
/// - Programmatic control via an external controller
class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndexScrollListViewBuilder Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Material 3 + color seed + Google Fonts (Inter).
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: GoogleFonts.inter().fontFamily,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: GoogleFonts.inter().fontFamily,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  // Global amount of items used by multiple cards.
  int _globalCount = 60;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        title: Row(
          children: [
            // App icon badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.view_list_rounded, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            // App title/subtitle
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('IndexScrollListViewBuilder',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Interactive Demo',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          // Global settings are managed per card now
        ],
      ),
      body: Container(
        // Decorative gradient background for the demo.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.3),
              colorScheme.secondaryContainer.withValues(alpha: 0.2),
              colorScheme.tertiaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Global Settings Card (controls number of demo items)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.settings_rounded,
                                  color: colorScheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text('Global Settings',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Item count display
                        Row(
                          children: [
                            Expanded(
                              child: Text('Demo item count',
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('$_globalCount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colorScheme.primary,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Item count slider controlling _globalCount
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            min: 10,
                            max: 200,
                            divisions: 19,
                            value: _globalCount.toDouble().clamp(10, 200),
                            label: '$_globalCount items',
                            onChanged: (value) => setState(() {
                              _globalCount = value.toInt();
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Responsive area: 2 columns on wide screens, stacked on narrow.
                  LayoutBuilder(builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth;
                    final bool twoColumns = maxWidth >= 700;
                    final double cardWidth =
                        twoColumns ? (maxWidth - 12) / 2 : maxWidth;

                    // Card 1: Basic usage without auto-scrolling or external control.
                    final Widget basicCard = const BasicExampleCard();

                    // Card 2: Auto-scroll example (scrolls on build/rebuild).
                    final Widget autoCard = DeclarativeScrollCard(
                      globalCount: _globalCount,
                    );

                    // Card 3: Programmatic control via local/imperative controller.
                    final Widget externalCard = ImperativeScrollCard(
                      globalCount: _globalCount,
                    );

                    // Card 4: Declarative behavior demo (indexToScrollTo with imperative override)
                    final Widget declarativeTestCard = DeclarativeTestCard(
                      globalCount: _globalCount,
                    );

                    // Render cards in a responsive wrap.
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(width: cardWidth, child: basicCard),
                        SizedBox(width: cardWidth, child: autoCard),
                        SizedBox(width: cardWidth, child: externalCard),
                        SizedBox(width: cardWidth, child: declarativeTestCard),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),

                  // Info section explaining what the demo shows.
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer.withValues(alpha: 0.5),
                          colorScheme.secondaryContainer.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 32, color: colorScheme.primary),
                        const SizedBox(height: 12),
                        Text(
                          'Feature Showcase - v2.2.0',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This interactive demo showcases IndexScrollListViewBuilder\'s key features:\n\n'
                          '• Basic list building and scrollbar customization\n'
                          '• Declarative scrolling with alignment and offset control\n'
                          '• Imperative scrolling with external controller\n'
                          '• NEW v2.2.0: Declarative Test - shows how indexToScrollTo acts as a "home position - therefore if not updated within onScrolledTo callback when controller triggered scrolls are made, on rebuild it will still be the same position"\n'
                          '• NEW v2.2.0: Imperative Test - demonstrates persistence with null indexToScrollTo',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // The example cards are now separated into their own StatefulWidgets.
  // Keep helper methods out of this file to avoid duplication of styling.
}
