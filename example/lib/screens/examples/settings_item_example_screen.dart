import 'package:s_packages/s_packages.dart';

class SettingsItemExampleScreen extends StatefulWidget {
  const SettingsItemExampleScreen({super.key});

  @override
  State<SettingsItemExampleScreen> createState() =>
      _SettingsItemExampleScreenState();
}

class _SettingsItemExampleScreenState extends State<SettingsItemExampleScreen> {
  final bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _accountExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SettingsItem Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'SettingsItem Examples',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Switch example with internal state
          const Text(
            'Switch Setting (Internal State):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const SettingsItem(
            parameters: ExpandableParameters(
              prefixIcon: Icons.notifications,
              title: 'Notifications',
              isSwitch: true,
            ),
            initialState: true,
          ),
          const SizedBox(height: 24),

          // Switch example with external state
          const Text(
            'Switch Setting (External State):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SettingsItem(
            parameters: const ExpandableParameters(
              prefixIcon: Icons.dark_mode,
              title: 'Dark Mode',
              isSwitch: true,
            ),
            isActive: _darkModeEnabled,
            onChange: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Expandable menu example
          const Text(
            'Expandable Menu:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SettingsItem(
            parameters: ExpandableParameters(
              prefixIcon: Icons.account_circle,
              title: 'Account Settings',
              isExpandeable: true,
              expandedWidget: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () => _showMessage('Edit Profile tapped'),
                  ),
                  _buildMenuItem(
                    icon: Icons.email,
                    title: 'Change Email',
                    onTap: () => _showMessage('Change Email tapped'),
                  ),
                  _buildMenuItem(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () => _showMessage('Change Password tapped'),
                  ),
                ],
              ),
            ),
            isActive: _accountExpanded,
            onChange: (value) {
              setState(() {
                _accountExpanded = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Button-style setting
          const Text(
            'Button Setting:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SettingsItem(
            parameters: const ExpandableParameters(
              prefixIcon: Icons.info,
              title: 'About',
              isExpandeable: false,
            ),
            onChange: (value) {
              _showMessage('About tapped');
            },
          ),
          const SizedBox(height: 24),

          // Display state
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current State:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Notifications: $_notificationsEnabled'),
                Text('Dark Mode: $_darkModeEnabled'),
                Text('Account Expanded: $_accountExpanded'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
