import 'package:s_packages/s_packages.dart';

class SSidebarExampleScreen extends StatefulWidget {
  const SSidebarExampleScreen({super.key});

  @override
  State<SSidebarExampleScreen> createState() => _SSidebarExampleScreenState();
}

class _SSidebarExampleScreenState extends State<SSidebarExampleScreen> {
  int _selectedIndex = 1; // Start at Dashboard (which is index 1 after header)
  bool _isMinimized = false;

  // New configuration options for live demo
  SideBarIndicatorStyle _indicatorStyle = SideBarIndicatorStyle.pill;
  SideBarMinimizeButtonStyle _minimizeButtonStyle = SideBarMinimizeButtonStyle.bottomRow;
  bool _showShadow = true;
  bool _hoverAnimation = true;
  bool _useCustomDecorations = false;

  // List of sidebar items configuration
  // Helper to map index to content
  String _getCurrentPageTitle(int index) {
    if (index >= 0 && index < _sidebarItems.length) {
      return _sidebarItems[index].title;
    }
    return 'Dashboard';
  }

  // Define the items list statically/dynamically
  List<SSideBarItem> get _sidebarItems => [
        SSideBarItem.header(title: "Main Menu"),
        SSideBarItem(
          iconSelected: Icons.dashboard,
          iconUnselected: Icons.dashboard_outlined,
          title: "Dashboard",
          tooltip: "Dashboard Overview",
          badgeText: "3",
          badgeColor: Colors.green.shade400,
        ),
        SSideBarItem(
          iconSelected: Icons.analytics,
          iconUnselected: Icons.analytics_outlined,
          title: "Analytics",
          tooltip: "Reports and Metrics",
        ),
        SSideBarItem(
          iconSelected: Icons.message,
          iconUnselected: Icons.message_outlined,
          title: "Messages",
          tooltip: "Inbox",
          badgeText: "12",
          badgeColor: Colors.redAccent,
        ),
        SSideBarItem.divider(),
        SSideBarItem.header(title: "Settings & System"),
        SSideBarItem(
          iconSelected: Icons.settings,
          iconUnselected: Icons.settings_outlined,
          title: "Settings",
          tooltip: "App Customization",
        ),
      ];

  Widget _buildExampleHeader() {
    return _isMinimized
        ? const SizedBox.shrink()
        : Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.flash_on, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Text(
                  "PRO PLAN ACTIVE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildExampleFooter() {
    if (_isMinimized) {
      return Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade600],
            ),
          ),
          child: const Center(
            child: Text(
              "AR",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade600],
              ),
            ),
            child: const Center(
              child: Text(
                "AR",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Alex Rivera",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "alex@company.com",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Custom decorations demo
    final Decoration? customSelectedDeco = _useCustomDecorations
        ? BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.purple.shade700],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade500.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          )
        : null;

    final Decoration? customUnselectedDeco = _useCustomDecorations
        ? BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SSidebar Modern Showcase'),
      ),
      body: Row(
        children: [
          // Sidebar Container with layout styling
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: SSideBar(
              sidebarItems: _sidebarItems,
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
              settingsDivider: false, // Turned off to use custom items instead
              sideBarColor: const Color(0xFF13131A),
              selectedIconBackgroundColor: const Color(0xFF252538),
              selectedIconColor: Colors.blue.shade400,
              unselectedIconColor: const Color(0xFF7E7E9A),
              selectedTextColor: Colors.white,
              unSelectedTextColor: const Color(0xFF7E7E9A),
              hoverColor: Colors.white.withValues(alpha: 0.05),
              splashColor: Colors.white.withValues(alpha: 0.1),
              borderRadius: 24,
              sideBarWidth: 260,
              sideBarSmallWidth: 84,
              // Modern features
              header: _buildExampleHeader(),
              footer: _buildExampleFooter(),
              indicatorStyle: _indicatorStyle,
              minimizeButtonStyle: _minimizeButtonStyle,
              showShadow: _showShadow,
              hoverAnimation: _hoverAnimation,
              selectedItemDecoration: customSelectedDeco,
              unselectedItemDecoration: customUnselectedDeco,
              logo: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (!_isMinimized) ...[
                      const SizedBox(width: 12),
                      const Text(
                        "SoundSliced",
                        style: TextStyle(
                          fontFamily: "SFPro",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Main Interactive Configuration Panel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Page Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primaryContainer,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Page: ${_getCurrentPageTitle(_selectedIndex)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tapped Sidebar item index: $_selectedIndex',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Customize SSideBar Dynamically:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selection Settings Grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // Indicator Style Dropdown
                      _buildConfigCard(
                        title: 'Indicator Style',
                        child: DropdownButton<SideBarIndicatorStyle>(
                          value: _indicatorStyle,
                          underline: const SizedBox(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _indicatorStyle = val);
                            }
                          },
                          items: SideBarIndicatorStyle.values.map((style) {
                            return DropdownMenuItem(
                              value: style,
                              child: Text(style.name),
                            );
                          }).toList(),
                        ),
                      ),

                      // Minimize Button Style Dropdown
                      _buildConfigCard(
                        title: 'Minimize Button Style',
                        child: DropdownButton<SideBarMinimizeButtonStyle>(
                          value: _minimizeButtonStyle,
                          underline: const SizedBox(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _minimizeButtonStyle = val);
                            }
                          },
                          items: SideBarMinimizeButtonStyle.values.map((style) {
                            return DropdownMenuItem(
                              value: style,
                              child: Text(style.name),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Switches section
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Show Shadows (Elevation)'),
                            subtitle: const Text('Renders a subtle modern drop shadow'),
                            value: _showShadow,
                            onChanged: (val) => setState(() => _showShadow = val),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text('Hover Animations'),
                            subtitle: const Text('Items shift & scale slightly on hover'),
                            value: _hoverAnimation,
                            onChanged: (val) => setState(() => _hoverAnimation = val),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text('Use Custom Item Decorations'),
                            subtitle: const Text('Applies custom gradient & shadow to active item'),
                            value: _useCustomDecorations,
                            onChanged: (val) => setState(() => _useCustomDecorations = val),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Interactive Popup Test
                  SButton(
                    onTap: (position) {
                      SideBarController.activateSideBar(
                        sSideBar: SSideBar(
                          sidebarItems: [
                            SSideBarItem.header(title: "Quick Options"),
                            SSideBarItem(
                              iconSelected: Icons.star_rounded,
                              title: "Favorites",
                            ),
                            SSideBarItem(
                              iconSelected: Icons.help_center_rounded,
                              title: "Help & Support",
                            ),
                          ],
                          onTapForAllTabButtons: (index) {
                            debugPrint('Popup Option Tapped: $index');
                          },
                          sideBarColor: const Color(0xFF13131A),
                          selectedIconBackgroundColor: const Color(0xFF252538),
                          selectedIconColor: Colors.purple.shade400,
                          unselectedIconColor: const Color(0xFF7E7E9A),
                          selectedTextColor: Colors.white,
                          unSelectedTextColor: const Color(0xFF7E7E9A),
                          indicatorStyle: SideBarIndicatorStyle.pill,
                          sideBarHeight: 280,
                        ),
                        offset: Offset(position.dx - 40, position.dy - 140),
                        useGlobalPosition: true,
                        animateFromOffset: position,
                        curve: Curves.easeOutBack,
                        animationDuration: const Duration(milliseconds: 500),
                        popFrameColor: Colors.blue.shade900,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.open_in_new_rounded, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'Show Floating Context Sidebar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildConfigCard({required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
