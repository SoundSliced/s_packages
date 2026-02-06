import 'package:flutter/material.dart';
import 'package:s_sidebar/s_sidebar.dart';

void main() {
  runApp(const MyApp());
}

enum _SidebarHeightMode {
  full,
  medium,
  compact,
}

enum _SidebarCurveMode {
  easeOutExpo,
  easeInOut,
  fastOutSlowIn,
  linear,
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S_Sidebar Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SidebarExamplePage(),
    );
  }
}

class SidebarExamplePage extends StatefulWidget {
  const SidebarExamplePage({super.key});

  @override
  State<SidebarExamplePage> createState() => _SidebarExamplePageState();
}

class _SidebarExamplePageState extends State<SidebarExamplePage> {
  // Selected page index
  int selectedIndex = 0;

  // Advanced feature toggles
  bool showLogo = false;
  bool showDivider = true;
  bool isMinimized = false;
  bool customColors = false;
  bool fastAnimation = false;
  bool compactMode = false;
  bool showTooltipsWhenMinimized = true;
  bool showBadges = true;
  _SidebarHeightMode heightMode = _SidebarHeightMode.full;
  bool showBorder = true;
  double borderWidth = 1;
  double borderRadius = 20;
  double sideBarWidth = 240;
  double sideBarSmallWidth = 84;
  double sideBarItemHeight = 48;
  double itemHorizontalPadding = 10;
  double itemIconTextSpacing = 12;
  double itemBorderRadius = 10;
  bool useBoldText = false;
  double textSize = 16;
  bool ignoreDifferenceOnFlutterWeb = false;
  _SidebarCurveMode curveMode = _SidebarCurveMode.easeOutExpo;
  bool disableMessagesTap = false;

  // Page content
  final List<String> pageNames = [
    'Dashboard',
    'Analytics',
    'Messages',
    'Calendar',
    'Documents',
    'Settings',
  ];

  double? get _sidebarHeightValue {
    switch (heightMode) {
      case _SidebarHeightMode.full:
        return null;
      case _SidebarHeightMode.medium:
        return 450;
      case _SidebarHeightMode.compact:
        return 360;
    }
  }

  Curve get _sidebarCurve {
    switch (curveMode) {
      case _SidebarCurveMode.easeOutExpo:
        return Curves.easeOutExpo;
      case _SidebarCurveMode.easeInOut:
        return Curves.easeInOut;
      case _SidebarCurveMode.fastOutSlowIn:
        return Curves.fastOutSlowIn;
      case _SidebarCurveMode.linear:
        return Curves.linear;
    }
  }

  TextStyle get _sidebarTextStyle {
    return TextStyle(
      fontFamily: "SFPro",
      fontSize: textSize,
      fontWeight: useBoldText ? FontWeight.w600 : FontWeight.w400,
      color: Colors.white,
    );
  }

  List<bool> get _shouldTapItems {
    if (!disableMessagesTap) {
      return const [];
    }

    return const [true, true, false, true, true, true];
  }

  void _showPopupSidebar() {
    SideBarController.activateSideBar(
      sSideBar: SSideBar(
        sidebarItems: [
          SSideBarItem(
            iconSelected: Icons.rocket_launch,
            iconUnselected: Icons.rocket_launch_outlined,
            title: "Explore",
            badgeText: "New",
            badgeColor: Colors.purple,
          ),
          SSideBarItem(
            iconSelected: Icons.favorite,
            iconUnselected: Icons.favorite_border,
            title: "Favorites",
            badgeText: "5",
            badgeColor: Colors.pink,
          ),
          SSideBarItem(
            iconSelected: Icons.history,
            iconUnselected: Icons.history_outlined,
            title: "History",
          ),
          SSideBarItem(
            iconSelected: Icons.cloud,
            iconUnselected: Icons.cloud_outlined,
            title: "Cloud",
          ),
          SSideBarItem(
            iconSelected: Icons.help,
            iconUnselected: Icons.help_outline,
            title: "Help",
          ),
        ],
        onTapForAllTabButtons: (index) {
          debugPrint('Popup sidebar item tapped: $index');
        },
        sideBarColor: const Color(0xFF1A237E),
        selectedIconBackgroundColor: const Color(0xFF283593),
        selectedIconColor: Colors.amber,
        unselectedIconColor: Colors.white70,
        selectedTextColor: Colors.amber,
        unSelectedTextColor: Colors.white70,
        sideBarHeight: 450,
        borderRadius: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPopupSidebar,
        backgroundColor: Colors.purpleAccent.withValues(alpha: 0.8),
        icon: const Icon(Icons.add_box),
        label: const Text('Show Popup Sidebar'),
        tooltip: 'Demonstrate SideBarController.activateSideBar()',
      ),
      body: Row(
        children: [
          // Sidebar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SSideBar(
              // Basic configuration
              sidebarItems: [
                SSideBarItem(
                  iconSelected: Icons.dashboard,
                  iconUnselected: Icons.dashboard_outlined,
                  title: "Dashboard",
                  tooltip: "Dashboard",
                  badgeText: showBadges ? "3" : null,
                  badgeColor: Colors.green.shade400,
                  onTap: (offset) {
                    debugPrint('Dashboard tapped at: $offset');
                  },
                ),
                SSideBarItem(
                  iconSelected: Icons.analytics,
                  iconUnselected: Icons.analytics_outlined,
                  title: "Analytics",
                  tooltip: "Analytics",
                  badgeText: showBadges ? "New" : null,
                  badgeColor: Colors.orange.shade400,
                  onTap: (offset) {
                    debugPrint('Analytics tapped at: $offset');
                  },
                ),
                SSideBarItem(
                  iconSelected: Icons.message,
                  iconUnselected: Icons.message_outlined,
                  title: "Messages",
                  tooltip: "Messages",
                  badgeText: showBadges ? "12" : null,
                  badgeColor: Colors.redAccent,
                  onTap: (offset) {
                    debugPrint('Messages tapped at: $offset');
                  },
                ),
                SSideBarItem(
                  iconSelected: Icons.calendar_today,
                  iconUnselected: Icons.calendar_today_outlined,
                  title: "Calendar",
                  tooltip: "Calendar",
                  onTap: (offset) {
                    debugPrint('Calendar tapped at: $offset');
                  },
                ),
                SSideBarItem(
                  iconSelected: Icons.folder,
                  iconUnselected: Icons.folder_outlined,
                  title: "Documents",
                  tooltip: "Documents",
                  onTap: (offset) {
                    debugPrint('Documents tapped at: $offset');
                  },
                ),
                SSideBarItem(
                  iconSelected: Icons.settings,
                  iconUnselected: Icons.settings_outlined,
                  title: "Settings",
                  tooltip: "Settings",
                  onTap: (offset) {
                    debugPrint('Settings tapped at: $offset');
                  },
                ),
              ],
              onTapForAllTabButtons: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              preSelectedItemIndex: selectedIndex,
              shouldTapItems: _shouldTapItems,
              ignoreDifferenceOnFlutterWeb: ignoreDifferenceOnFlutterWeb,

              // Advanced features - controlled by toggles
              logo: showLogo
                  ? const Icon(
                      Icons.coffee,
                      size: 40,
                      color: Colors.blue,
                    )
                  : null,
              settingsDivider: showDivider,
              isMinimized: isMinimized,
              compactMode: compactMode,
              showTooltipsWhenMinimized: showTooltipsWhenMinimized,
              minimizeButtonOnTap: (minimized) {
                setState(() {
                  isMinimized = minimized;
                });
              },

              // Custom colors - toggled
              sideBarColor: customColors
                  ? const Color(0xFF2C3E50)
                  : const Color(0xFF1D1D1D),
              selectedIconBackgroundColor: customColors
                  ? const Color(0xFF34495E)
                  : const Color(0xFF323232),
              selectedIconColor: customColors ? Colors.amber : Colors.white,
              unselectedIconColor: customColors
                  ? const Color(0xFFBDC3C7)
                  : const Color(0xFFA0A5A9),
              selectedTextColor: customColors ? Colors.amber : Colors.white,
              unSelectedTextColor: customColors
                  ? const Color(0xFFBDC3C7)
                  : const Color(0xFFA0A5A9),
              dividerColor: customColors
                  ? Colors.amber.shade700
                  : const Color(0xFF929292),
              hoverColor: customColors
                  ? Colors.amber.withValues(alpha: 0.1)
                  : Colors.black38,
              splashColor: customColors
                  ? Colors.amber.withValues(alpha: 0.3)
                  : Colors.black87,
              highlightColor: customColors
                  ? Colors.amber.withValues(alpha: 0.2)
                  : Colors.black,

              // Animation duration - toggled
              sideBarAnimationDuration: fastAnimation
                  ? const Duration(milliseconds: 300)
                  : const Duration(milliseconds: 700),
              floatingAnimationDuration: fastAnimation
                  ? const Duration(milliseconds: 150)
                  : const Duration(milliseconds: 300),
              curve: _sidebarCurve,
              textStyle: _sidebarTextStyle,

              // Other customizations
              sideBarBorder: showBorder
                  ? Border.all(
                      color:
                          customColors ? Colors.amber.shade700 : Colors.black26,
                      width: borderWidth,
                    )
                  : null,
              borderRadius: borderRadius,
              sideBarWidth: sideBarWidth,
              sideBarSmallWidth: sideBarSmallWidth,
              sideBarHeight: _sidebarHeightValue,
              sideBarItemHeight: sideBarItemHeight,
              itemHorizontalPadding: itemHorizontalPadding,
              itemIconTextSpacing: itemIconTextSpacing,
              itemBorderRadius: itemBorderRadius,
            ),
          ),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    pageNames[selectedIndex],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1D1D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current page: ${pageNames[selectedIndex]}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Feature toggles section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Advanced Features Control Panel',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D1D1D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toggle these switches to see advanced features in action',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Feature toggles
                            _buildFeatureToggle(
                              title: 'Show Logo',
                              description:
                                  'Display a custom logo at the top of the sidebar',
                              value: showLogo,
                              onChanged: (value) {
                                setState(() {
                                  showLogo = value;
                                });
                              },
                              icon: Icons.code,
                            ),
                            const Divider(height: 40),

                            _buildFeatureToggle(
                              title: 'Settings Divider',
                              description:
                                  'Show a divider before the last item (typically settings)',
                              value: showDivider,
                              onChanged: (value) {
                                setState(() {
                                  showDivider = value;
                                });
                              },
                              icon: Icons.horizontal_rule,
                            ),
                            const Divider(height: 40),

                            _buildFeatureToggle(
                              title: 'Minimize Sidebar',
                              description:
                                  'Start the sidebar in minimized mode (icon-only)',
                              value: isMinimized,
                              onChanged: (value) {
                                setState(() {
                                  isMinimized = value;
                                });
                              },
                              icon: Icons.compress,
                            ),
                            const Divider(height: 40),

                            _buildFeatureToggle(
                              title: 'Custom Color Scheme',
                              description:
                                  'Apply a custom color scheme with amber accents',
                              value: customColors,
                              onChanged: (value) {
                                setState(() {
                                  customColors = value;
                                });
                              },
                              icon: Icons.palette,
                            ),
                            const Divider(height: 40),

                            _buildFeatureToggle(
                              title: 'Fast Animations',
                              description:
                                  'Use faster animation durations for quick transitions',
                              value: fastAnimation,
                              onChanged: (value) {
                                setState(() {
                                  fastAnimation = value;
                                });
                              },
                              icon: Icons.speed,
                            ),
                            const Divider(height: 40),

                            _buildFeatureToggle(
                              title: 'Compact Mode',
                              description:
                                  'Reduce item height and spacing for denser layouts',
                              value: compactMode,
                              onChanged: (value) {
                                setState(() {
                                  compactMode = value;
                                });
                              },
                              icon: Icons.view_agenda_outlined,
                            ),
                            const Divider(height: 40),

                            _buildHeightSelector(
                              currentMode: heightMode,
                              onChanged: (mode) {
                                setState(() {
                                  heightMode = mode;
                                });
                              },
                            ),
                            const Divider(height: 40),

                            _buildSectionHeader('Layout & Styling Controls'),
                            const SizedBox(height: 12),
                            _buildFeatureToggle(
                              title: 'Show Border',
                              description:
                                  'Enable or disable the sidebar border',
                              value: showBorder,
                              onChanged: (value) {
                                setState(() {
                                  showBorder = value;
                                });
                              },
                              icon: Icons.crop_square,
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Border Width',
                              value: borderWidth,
                              min: 0.5,
                              max: 4,
                              divisions: 7,
                              suffix: 'px',
                              onChanged: (value) {
                                setState(() {
                                  borderWidth = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Border Radius',
                              value: borderRadius,
                              min: 0,
                              max: 40,
                              divisions: 20,
                              suffix: 'px',
                              onChanged: (value) {
                                setState(() {
                                  borderRadius = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Sidebar Width',
                              value: sideBarWidth,
                              min: 180,
                              max: 320,
                              divisions: 14,
                              suffix: 'px',
                              onChanged: (value) {
                                setState(() {
                                  sideBarWidth = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Sidebar Small Width',
                              value: sideBarSmallWidth,
                              min: 60,
                              max: 140,
                              divisions: 16,
                              suffix: 'px',
                              onChanged: (value) {
                                setState(() {
                                  sideBarSmallWidth = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Item Height',
                              value: sideBarItemHeight,
                              min: 32,
                              max: 72,
                              divisions: 20,
                              suffix: 'px',
                              onChanged: (value) {
                                setState(() {
                                  sideBarItemHeight = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Item Horizontal Padding',
                              value: itemHorizontalPadding,
                              min: 0,
                              max: 20,
                              divisions: 20,
                              suffix: 'px',
                              onChanged: (value) {
                                setState(() {
                                  itemHorizontalPadding = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Icon/Text Spacing',
                              value: itemIconTextSpacing,
                              min: 4,
                              max: 24,
                              divisions: 20,
                              suffix: 'px',
                              onChanged: (value) {
                                setState(() {
                                  itemIconTextSpacing = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Item Border Radius',
                              value: itemBorderRadius,
                              min: 0,
                              max: 20,
                              divisions: 20,
                              suffix: 'px',
                              onChanged: (value) {
                                setState(() {
                                  itemBorderRadius = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSliderControl(
                              label: 'Text Size',
                              value: textSize,
                              min: 12,
                              max: 22,
                              divisions: 10,
                              suffix: 'pt',
                              onChanged: (value) {
                                setState(() {
                                  textSize = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildFeatureToggle(
                              title: 'Bold Text',
                              description:
                                  'Increase text weight for sidebar items',
                              value: useBoldText,
                              onChanged: (value) {
                                setState(() {
                                  useBoldText = value;
                                });
                              },
                              icon: Icons.format_bold,
                            ),
                            const SizedBox(height: 16),
                            _buildCurveSelector(
                              currentMode: curveMode,
                              onChanged: (mode) {
                                setState(() {
                                  curveMode = mode;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureToggle(
                              title: 'Ignore Web Differences',
                              description:
                                  'Match behavior between web and other platforms',
                              value: ignoreDifferenceOnFlutterWeb,
                              onChanged: (value) {
                                setState(() {
                                  ignoreDifferenceOnFlutterWeb = value;
                                });
                              },
                              icon: Icons.language,
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureToggle(
                              title: 'Disable Messages Tap',
                              description:
                                  'Demonstrate shouldTapItems with one disabled item',
                              value: disableMessagesTap,
                              onChanged: (value) {
                                setState(() {
                                  disableMessagesTap = value;
                                });
                              },
                              icon: Icons.block,
                            ),
                            const Divider(height: 40),

                            _buildFeatureToggle(
                              title: 'Tooltips When Minimized',
                              description:
                                  'Show helpful tooltips when sidebar is collapsed',
                              value: showTooltipsWhenMinimized,
                              onChanged: (value) {
                                setState(() {
                                  showTooltipsWhenMinimized = value;
                                });
                              },
                              icon: Icons.badge_outlined,
                            ),
                            const Divider(height: 40),

                            _buildFeatureToggle(
                              title: 'Show Badges',
                              description:
                                  'Display notification badges on sidebar items',
                              value: showBadges,
                              onChanged: (value) {
                                setState(() {
                                  showBadges = value;
                                });
                              },
                              icon: Icons.notifications_active_outlined,
                            ),
                            const SizedBox(height: 40),

                            // SideBarController info panel
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.deepPurple.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.control_camera,
                                        color: Colors.deepPurple.shade700,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'SideBarController Demo',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Use the floating action buttons to test SideBarController:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.deepPurple.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildControllerInfoItem(
                                    '• Purple button: Calls SideBarController.activateSideBar() to create a popup sidebar',
                                    Colors.deepPurple.shade900,
                                  ),
                                  _buildControllerInfoItem(
                                    '• Red button: Calls SideBarController.deactivateSideBar() to dismiss it',
                                    Colors.deepPurple.shade900,
                                  ),
                                  _buildControllerInfoItem(
                                    '• Tap outside: Popup sidebar auto-dismisses with barrier tap',
                                    Colors.deepPurple.shade900,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Other SideBarController methods:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.deepPurple.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildControllerInfoItem(
                                    '• isSideBarActive() - Check if popup sidebar is visible',
                                    Colors.deepPurple.shade900,
                                  ),
                                  _buildControllerInfoItem(
                                    '• isSideBarMinimized() - Check sidebar minimized state',
                                    Colors.deepPurple.shade900,
                                  ),
                                  _buildControllerInfoItem(
                                    '• setMinimizedState(bool) - Control minimized state',
                                    Colors.deepPurple.shade900,
                                  ),
                                  _buildControllerInfoItem(
                                    '• getController() - Access the underlying controller',
                                    Colors.deepPurple.shade900,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Info panel
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue.shade700,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Additional Features',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoItem(
                                    '• Tap callbacks: Each item has an onTap callback with position',
                                  ),
                                  _buildInfoItem(
                                    '• Hover effects: Interactive hover, splash, and highlight colors',
                                  ),
                                  _buildInfoItem(
                                    '• Dual icons: Support for selected/unselected icon states',
                                  ),
                                  _buildInfoItem(
                                    '• Smooth curves: Customizable animation curves',
                                  ),
                                  _buildInfoItem(
                                    '• Border customization: Custom borders and border radius',
                                  ),
                                  _buildInfoItem(
                                    '• Size control: Fully customizable width and height',
                                  ),
                                  _buildInfoItem(
                                    '• Tooltips: Accessible labels when minimized',
                                  ),
                                  _buildInfoItem(
                                    '• Badges: Per-item notifications and labels',
                                  ),
                                  _buildInfoItem(
                                    '• Compact mode: Denser item spacing',
                                  ),
                                  _buildInfoItem(
                                    '• Height modes: Full height (null) or fixed sizes',
                                  ),
                                  _buildInfoItem(
                                    '• Layout controls: Width, radius, padding, and spacing sliders',
                                  ),
                                  _buildInfoItem(
                                    '• Text controls: Size and weight adjustments',
                                  ),
                                  _buildInfoItem(
                                    '• Curve selection: Choose different animation curves',
                                  ),
                                  _buildInfoItem(
                                    '• Tap rules: Disable taps on specific items',
                                  ),
                                ],
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

  Widget _buildFeatureToggle({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: value ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: value ? Colors.blue.shade700 : Colors.grey.shade600,
            size: 28,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D1D1D),
      ),
    );
  }

  Widget _buildSliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    String? suffix,
  }) {
    final formatted = value.toStringAsFixed(1).replaceAll('.0', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1D),
                ),
              ),
            ),
            Text(
              '$formatted${suffix ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCurveSelector({
    required _SidebarCurveMode currentMode,
    required ValueChanged<_SidebarCurveMode> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animation Curve',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1D1D),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<_SidebarCurveMode>(
          value: currentMode,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          items: const [
            DropdownMenuItem(
              value: _SidebarCurveMode.easeOutExpo,
              child: Text('EaseOutExpo'),
            ),
            DropdownMenuItem(
              value: _SidebarCurveMode.easeInOut,
              child: Text('EaseInOut'),
            ),
            DropdownMenuItem(
              value: _SidebarCurveMode.fastOutSlowIn,
              child: Text('FastOutSlowIn'),
            ),
            DropdownMenuItem(
              value: _SidebarCurveMode.linear,
              child: Text('Linear'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeightSelector({
    required _SidebarHeightMode currentMode,
    required ValueChanged<_SidebarHeightMode> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sidebar Height',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1D1D),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose full-height (default) or fixed heights',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<_SidebarHeightMode>(
          segments: const [
            ButtonSegment(
              value: _SidebarHeightMode.full,
              label: Text('Full (null)'),
              icon: Icon(Icons.height),
            ),
            ButtonSegment(
              value: _SidebarHeightMode.medium,
              label: Text('450px'),
              icon: Icon(Icons.crop_7_5),
            ),
            ButtonSegment(
              value: _SidebarHeightMode.compact,
              label: Text('360px'),
              icon: Icon(Icons.crop_5_4),
            ),
          ],
          selected: <_SidebarHeightMode>{currentMode},
          onSelectionChanged: (values) {
            if (values.isNotEmpty) {
              onChanged(values.first);
            }
          },
        ),
      ],
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue.shade900,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildControllerInfoItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color,
          height: 1.5,
        ),
      ),
    );
  }
}
