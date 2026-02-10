import 'package:s_packages/s_packages.dart';

class SSidebarExampleScreen extends StatefulWidget {
  const SSidebarExampleScreen({super.key});

  @override
  State<SSidebarExampleScreen> createState() => _SSidebarExampleScreenState();
}

class _SSidebarExampleScreenState extends State<SSidebarExampleScreen> {
  int _selectedIndex = 0;
  bool _isMinimized = false;

  final List<String> _pageNames = [
    'Dashboard',
    'Analytics',
    'Messages',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSidebar Example'),
      ),
      body: Row(
        children: [
          // Sidebar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SSideBar(
              sidebarItems: [
                SSideBarItem(
                  iconSelected: Icons.dashboard,
                  iconUnselected: Icons.dashboard_outlined,
                  title: "Dashboard",
                  tooltip: "Dashboard",
                  badgeText: "3",
                  badgeColor: Colors.green.shade400,
                ),
                SSideBarItem(
                  iconSelected: Icons.analytics,
                  iconUnselected: Icons.analytics_outlined,
                  title: "Analytics",
                  tooltip: "Analytics",
                ),
                SSideBarItem(
                  iconSelected: Icons.message,
                  iconUnselected: Icons.message_outlined,
                  title: "Messages",
                  tooltip: "Messages",
                  badgeText: "12",
                  badgeColor: Colors.redAccent,
                ),
                SSideBarItem(
                  iconSelected: Icons.settings,
                  iconUnselected: Icons.settings_outlined,
                  title: "Settings",
                  tooltip: "Settings",
                ),
              ],
              onTapForAllTabButtons: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              preSelectedItemIndex: _selectedIndex,
              isMinimized: _isMinimized,
              minimizeButtonOnTap: (minimized) {
                setState(() {
                  _isMinimized = minimized;
                });
              },
              settingsDivider: true,
              sideBarColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedIconBackgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              selectedIconColor:
                  Theme.of(context).colorScheme.onPrimaryContainer,
              unselectedIconColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              selectedTextColor: Theme.of(context).colorScheme.onSurface,
              unSelectedTextColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          // Main content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pageNames[_selectedIndex],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current page: ${_pageNames[_selectedIndex]}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SButton(
                              onTap: (pos) => log("Icon Position: $pos"),
                              child: Icon(
                                Icons.info_outline,
                                size: 64,
                                color: Colors.blue.shade300,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Sidebar features:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('• Click minimize button to collapse'),
                            const Text('• Badges show notifications'),
                            const Text('• Hover effects on items'),

                            const SizedBox(height: 16),

                            /// Popup sidebar button
                            SButton(
                              onTap: (position) {
                                SideBarController.activateSideBar(
                                  sSideBar: SSideBar(
                                    sidebarItems: [
                                      SSideBarItem(
                                        iconSelected: Icons.favorite,
                                        iconUnselected: Icons.favorite_border,
                                        title: "Favorites",
                                      ),
                                      SSideBarItem(
                                        iconSelected: Icons.help,
                                        iconUnselected: Icons.help_outline,
                                        title: "Help",
                                      ),
                                    ],
                                    onTapForAllTabButtons: (index) {
                                      debugPrint('Popup item: $index');
                                    },
                                    sideBarColor: const Color(0xFF1A237E),
                                    sideBarHeight: 300,
                                  ),
                                  // Directly use the global position from the tap
                                  offset: Offset(
                                      position.dx - 50, position.dy - 220),
                                  useGlobalPosition: true,
                                  animateFromOffset: position,
                                  curve: Curves.easeOutBack,
                                  animationDuration:
                                      const Duration(milliseconds: 600),
                                  popFrameColor: Colors.yellow.shade800,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_box,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Show Popup Sidebar, \nanimating it from the button \nto the final position',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
