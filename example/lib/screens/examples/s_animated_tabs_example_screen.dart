import 'package:s_packages/s_packages.dart';

class SAnimatedTabsExampleScreen extends StatefulWidget {
  const SAnimatedTabsExampleScreen({super.key});

  @override
  State<SAnimatedTabsExampleScreen> createState() =>
      _SAnimatedTabsExampleScreenState();
}

class _SAnimatedTabsExampleScreenState
    extends State<SAnimatedTabsExampleScreen> {
  int _selectedIndex = 0;
  int _customSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S Animated Tabs Example'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Different tab configurations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Basic Example
              const Text(
                'Basic Tabs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SAnimatedTabs(
                tabTitles: const ['Home', 'Profile', 'Settings'],
                tabIcons: const [Icons.home, Icons.person, Icons.settings],
                tabBadges: const ['3', null, '!'],
                onTabSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Selected: ${const [
                  'Home',
                  'Profile',
                  'Settings'
                ][_selectedIndex]}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 40),

              // Custom Styled Tabs
              const Text(
                'Custom Styled Tabs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SAnimatedTabs(
                tabTitles: const ['Messages', 'Calls', 'Contacts'],
                onTabSelected: (index) {
                  setState(() {
                    _customSelectedIndex = index;
                  });
                },
                height: 52,
                width: 320,
                borderRadius: 12,
                backgroundColor: Colors.green.shade50,
                activeColor: Colors.green.shade600,
                animationDuration: const Duration(milliseconds: 350),
                animationCurve: Curves.easeOutBack,
                enableHapticFeedback: true,
              ),
              const SizedBox(height: 12),
              Text(
                'Selected: ${const [
                  'Messages',
                  'Calls',
                  'Contacts'
                ][_customSelectedIndex]}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 40),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem('Smooth animated transitions'),
                    _buildFeatureItem('Customizable colors and sizes'),
                    _buildFeatureItem('Multiple animation styles'),
                    _buildFeatureItem('Haptic feedback support'),
                    _buildFeatureItem('Material 3 color schemes'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
