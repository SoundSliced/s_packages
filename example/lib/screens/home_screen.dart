import 'package:flutter/material.dart';
import 'package:s_packages_example/models/package_info.dart';
import 'package:s_packages_example/utils/package_examples_registry.dart';

import 'package:s_packages_example/widgets/package_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  final List<PackageInfo> _packages = [
    PackageInfo(
      name: 'bubble_label',
      description: 'A bubble label widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 'indexscroll_listview_builder',
      description: 'ListView with index scrolling',
      category: 'Lists',
    ),
    PackageInfo(
      name: 'keystroke_listener',
      description: 'Keyboard event listener',
      category: 'Input',
    ),
    PackageInfo(
      name: 'pop_overlay',
      description: 'Overlay management',
      category: 'Navigation',
    ),
    PackageInfo(
      name: 'pop_this',
      description: 'Navigation utilities',
      category: 'Navigation',
    ),
    PackageInfo(
      name: 'post_frame',
      description: 'Post-frame callbacks',
      category: 'Utilities',
    ),
    PackageInfo(
      name: 's_animated_tabs',
      description: 'Animated tab bar',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_banner',
      description: 'Banner widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_bounceable',
      description: 'Bounceable animations',
      category: 'Animations',
    ),
    PackageInfo(
      name: 's_button',
      description: 'Custom button widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_client',
      description: 'HTTP client utilities',
      category: 'Networking',
    ),
    PackageInfo(
      name: 's_connectivity',
      description: 'Connectivity monitoring',
      category: 'Networking',
    ),
    PackageInfo(
      name: 's_context_menu',
      description: 'Context menu widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_disabled',
      description: 'Disabled state widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_dropdown',
      description: 'Dropdown widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_error_widget',
      description: 'Error display widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_expendable_menu',
      description: 'Expandable menu widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_future_button',
      description: 'Future-based button',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_glow',
      description: 'Glow effects',
      category: 'Animations',
    ),
    PackageInfo(
      name: 's_gridview',
      description: 'Grid view widget',
      category: 'Lists',
    ),
    PackageInfo(
      name: 's_ink_button',
      description: 'Ink effect button',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_liquid_pull_to_refresh',
      description: 'Liquid pull to refresh',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_maintenance_button',
      description: 'Maintenance button widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_modal',
      description: 'Modal dialogs',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_offstage',
      description: 'Offstage widget utilities',
      category: 'Layout',
    ),
    PackageInfo(
      name: 's_screenshot',
      description: 'Screenshot utilities',
      category: 'Utilities',
    ),
    PackageInfo(
      name: 's_sidebar',
      description: 'Sidebar navigation',
      category: 'Navigation',
    ),
    PackageInfo(
      name: 's_standby',
      description: 'Standby state widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_time',
      description: 'Time utilities',
      category: 'Utilities',
    ),
    PackageInfo(
      name: 's_toggle',
      description: 'Toggle switch widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 's_webview',
      description: 'WebView integration',
      category: 'Platform',
    ),
    PackageInfo(
      name: 's_widgets',
      description: 'Collection of widgets',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 'settings_item',
      description: 'Settings item widget',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 'shaker',
      description: 'Shake animations',
      category: 'Animations',
    ),
    PackageInfo(
      name: 'signals_watch',
      description: 'Signal watching utilities',
      category: 'State Management',
    ),
    PackageInfo(
      name: 'soundsliced_dart_extensions',
      description: 'Dart extensions',
      category: 'Utilities',
    ),
    PackageInfo(
      name: 'soundsliced_tween_animation_builder',
      description: 'Tween animation builder',
      category: 'Animations',
    ),
    PackageInfo(
      name: 'states_rebuilder_extended',
      description: 'State management extension',
      category: 'State Management',
    ),
    PackageInfo(
      name: 'ticker_free_circular_progress_indicator',
      description: 'Ticker-free progress indicator',
      category: 'UI Components',
    ),
    PackageInfo(
      name: 'week_calendar',
      description: 'Week calendar widget',
      category: 'Calendar',
    ),
  ];

  List<PackageInfo> get _filteredPackages {
    if (_searchQuery.isEmpty) {
      return _packages;
    }
    return _packages.where((pkg) {
      return pkg.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pkg.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pkg.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Map<String, List<PackageInfo>> get _packagesByCategory {
    final Map<String, List<PackageInfo>> grouped = {};
    for (final package in _filteredPackages) {
      grouped.putIfAbsent(package.category, () => []).add(package);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packagesByCategory = _packagesByCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('S Packages Examples'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search packages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: packagesByCategory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No packages found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Stats banner
                Builder(builder: (context) {
                  final examplesCount =
                      PackageExamplesRegistry.getAvailableExamples().length;
                  final totalPackages = _packages.length;

                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.widgets,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$examplesCount Examples Available',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$examplesCount of $totalPackages packages with interactive demos',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withValues(alpha: 0.8),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: packagesByCategory.length,
                    itemBuilder: (context, index) {
                      final category = packagesByCategory.keys.elementAt(index);
                      final packages = packagesByCategory[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index > 0) const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 12),
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${packages.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...packages.map((pkg) => PackageCard(package: pkg)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'UI Components':
        return Icons.widgets;
      case 'Lists':
        return Icons.list;
      case 'Input':
        return Icons.keyboard;
      case 'Navigation':
        return Icons.navigation;
      case 'Utilities':
        return Icons.build;
      case 'Animations':
        return Icons.animation;
      case 'Networking':
        return Icons.cloud;
      case 'Layout':
        return Icons.view_quilt;
      case 'Platform':
        return Icons.phone_android;
      case 'State Management':
        return Icons.settings_backup_restore;
      case 'Calendar':
        return Icons.calendar_month;
      default:
        return Icons.category;
    }
  }
}
