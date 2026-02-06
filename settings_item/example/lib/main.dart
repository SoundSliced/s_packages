import 'package:flutter/material.dart';
import 'package:settings_item/settings_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Expandable Menu Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: SettingsPage(onThemeChanged: _toggleTheme),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final void Function(bool) onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Switch states (for external state management examples)
  bool darkModeEnabled = false;
  bool vibrationEnabled = true;

  // Expandable states (for external state management examples)
  bool accountExpanded = false;
  bool securityExpanded = false;
  bool privacyExpanded = false;
  bool advancedExpanded = false;

  // Button states
  bool aboutButtonActive = false;
  bool helpButtonActive = false;

  // Advanced settings
  int privacyLevel = 1;
  String selectedLanguage = 'English';
  double fontSize = 16.0;

  // page variable
  // page selection
  _PageType? _selectedPage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageCardColor =
        colorScheme.surface.withValues(alpha: isDark ? 0.12 : 0.85);
    final pageBorderColor =
        colorScheme.onSurface.withValues(alpha: isDark ? 0.12 : 0.08);
    final textMuted = colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Example App'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          //the settings
          SizedBox(
            width: 320,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section: Basic Switches
                _buildSectionHeader('Basic Settings'),
                const SizedBox(height: 8),

                // Example with INTERNAL state management
                const SettingsItem(
                  parameters: ExpandableParameters(
                    prefixIcon: Icons.notifications_rounded,
                    title: 'Notifications (Internal State)',
                    isSwitch: true,
                  ),
                  initialState: true,
                ),

                // Example with EXTERNAL state management
                SettingsItem(
                  parameters: const ExpandableParameters(
                    prefixIcon: Icons.dark_mode_rounded,
                    title: 'Dark Mode (External State)',
                    isSwitch: true,
                  ),
                  isActive: darkModeEnabled,
                  onChange: (value) {
                    setState(() {
                      darkModeEnabled = value;
                    });
                    widget.onThemeChanged(value);
                  },
                ),

                // Example with INTERNAL state management + callback
                SettingsItem(
                  parameters: const ExpandableParameters(
                    prefixIcon: Icons.volume_up_rounded,
                    title: 'Sound (Internal + Callback)',
                    isSwitch: true,
                  ),
                  initialState: true,
                  onChange: (value) {
                    _showSnackBar('Sound is now ${value ? 'ON' : 'OFF'}');
                  },
                ),

                SettingsItem(
                  parameters: const ExpandableParameters(
                    prefixIcon: Icons.vibration_rounded,
                    title: 'Vibration',
                    isSwitch: true,
                  ),
                  isActive: vibrationEnabled,
                  onChange: (value) {
                    setState(() {
                      vibrationEnabled = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Section: Expandable Menus
                _buildSectionHeader('Account & Security'),
                const SizedBox(height: 8),

                SettingsItem(
                  parameters: ExpandableParameters(
                    prefixIcon: Icons.account_circle_rounded,
                    title: 'Account Settings',
                    isExpandeable: true,
                    expandedWidget: Column(
                      children: [
                        _buildExpandedMenuItem(
                          icon: Icons.person,
                          title: 'Edit Profile',
                          onTap: () {
                            _showSnackBar('Edit Profile tapped');
                          },
                        ),
                        _buildExpandedMenuItem(
                          icon: Icons.email,
                          title: 'Change Email',
                          onTap: () {
                            _showSnackBar('Change Email tapped');
                          },
                        ),
                        _buildExpandedMenuItem(
                          icon: Icons.phone,
                          title: 'Phone Number',
                          onTap: () {
                            _showSnackBar('Phone Number tapped');
                          },
                        ),
                        _buildExpandedMenuItem(
                          icon: Icons.logout,
                          title: 'Sign Out',
                          isDestructive: true,
                          onTap: () {
                            _showSnackBar('Sign Out tapped');
                          },
                        ),
                      ],
                    ),
                    onExpandedSectionToggle: () => _showSnackBar(
                        'Account Settings section ${accountExpanded ? 'Expanded' : 'Collapsed'}!'),
                  ),
                  isActive: accountExpanded,
                  onChange: (value) {
                    setState(() {
                      accountExpanded = value;
                    });
                  },
                ),

                SettingsItem(
                  parameters: ExpandableParameters(
                    prefixIcon: Icons.security_rounded,
                    title: 'Security',
                    isExpandeable: true,
                    expandedWidget: Column(
                      children: [
                        _buildExpandedMenuItem(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {
                            _showSnackBar('Change Password tapped');
                          },
                        ),
                        _buildExpandedMenuItem(
                          icon: Icons.fingerprint,
                          title: 'Biometric Authentication',
                          onTap: () {
                            _showSnackBar('Biometric Auth tapped');
                          },
                        ),
                        _buildExpandedMenuItem(
                          icon: Icons.vpn_key,
                          title: 'Two-Factor Authentication',
                          onTap: () {
                            _showSnackBar('2FA tapped');
                          },
                        ),
                      ],
                    ),
                    onExpandedSectionToggle: () => _showSnackBar(
                        'Security section ${securityExpanded ? 'Expanded' : 'Collapsed'}!'),
                  ),
                  isActive: securityExpanded,
                  onChange: (value) {
                    setState(() {
                      securityExpanded = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Section: Advanced Features
                _buildSectionHeader('Advanced Settings'),
                const SizedBox(height: 8),

                // Internal state management for expandable
                SettingsItem(
                  parameters: ExpandableParameters(
                    prefixIcon: Icons.tune_rounded,
                    title: 'Display Settings (Internal)',
                    isExpandeable: true,
                    expandedWidget: Column(
                      children: [
                        _buildExpandedMenuItem(
                          icon: Icons.brightness_6,
                          title: 'Brightness',
                          onTap: () {
                            _showSnackBar('Brightness tapped');
                          },
                        ),
                        _buildExpandedMenuItem(
                          icon: Icons.text_fields,
                          title: 'Font Size',
                          onTap: () {
                            _showSnackBar('Font Size tapped');
                          },
                        ),
                      ],
                    ),
                  ),
                  initialState: false,
                ),

                // Privacy with custom suffix widget
                SettingsItem(
                  parameters: ExpandableParameters(
                    prefixIcon: Icons.privacy_tip_rounded,
                    title: 'Privacy Level',
                    isExpandeable: true,
                    suffixWidget: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ['Low', 'Medium', 'High'][privacyLevel],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    expandedWidget: RadioGroup<int>(
                      groupValue: privacyLevel,
                      onChanged: (value) {
                        setState(() {
                          privacyLevel = value!;
                        });
                      },
                      child: Column(
                        children: [
                          RadioListTile<int>(
                            title: const Text('Low'),
                            subtitle: const Text('Basic privacy protection'),
                            value: 0,
                          ),
                          RadioListTile<int>(
                            title: const Text('Medium'),
                            subtitle: const Text(
                                'Balanced privacy and functionality'),
                            value: 1,
                          ),
                          RadioListTile<int>(
                            title: const Text('High'),
                            subtitle: const Text('Maximum privacy protection'),
                            value: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  isActive: privacyExpanded,
                  onChange: (value) {
                    setState(() {
                      privacyExpanded = value;
                    });
                  },
                ),

                // Language selector
                SettingsItem(
                  parameters: ExpandableParameters(
                    prefixIcon: Icons.language_rounded,
                    title: 'Language',
                    isExpandeable: true,
                    suffixWidget: Text(
                      selectedLanguage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    expandedWidget: RadioGroup<String>(
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                      child: Column(
                        children: [
                          for (var lang in [
                            'English',
                            'Spanish',
                            'French',
                            'German',
                            'Japanese'
                          ])
                            RadioListTile<String>(
                              title: Text(lang),
                              value: lang,
                            ),
                        ],
                      ),
                    ),
                  ),
                  isActive: advancedExpanded,
                  onChange: (value) {
                    setState(() {
                      advancedExpanded = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Section: Button Mode (No expansion)
                _buildSectionHeader('Info & Support'),
                const SizedBox(height: 8),

                SettingsItem(
                  parameters: const ExpandableParameters(
                    prefixIcon: Icons.info_rounded,
                    title: 'About',
                    isExpandeable: false,
                  ),
                  isActive: aboutButtonActive,
                  onChange: (value) {
                    setState(() {
                      aboutButtonActive = value;
                      if (aboutButtonActive) {
                        helpButtonActive = false;
                        _selectedPage = _PageType.about;
                      } else if (_selectedPage == _PageType.about) {
                        _selectedPage = null;
                      }
                    });
                    _showSnackBar(
                        'About page would ${value ? 'open' : 'close'} from This Action');
                  },
                ),

                SettingsItem(
                  parameters: const ExpandableParameters(
                    prefixIcon: Icons.help_rounded,
                    title: 'Help & Support',
                    isExpandeable: false,
                  ),
                  isActive: helpButtonActive,
                  onChange: (value) {
                    setState(() {
                      helpButtonActive = value;
                      if (helpButtonActive) {
                        aboutButtonActive = false;
                        _selectedPage = _PageType.help;
                      } else if (_selectedPage == _PageType.help) {
                        _selectedPage = null;
                      }
                    });
                    _showSnackBar(
                        'Help page would ${value ? 'open' : 'close'} from This Action');
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // the page
          Expanded(
            child: _ThePage(
              page: _buildSelectedPage(
                context,
                pageCardColor: pageCardColor,
                pageBorderColor: pageBorderColor,
                textMuted: textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildExpandedMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? Colors.red
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isDestructive
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, IconData icon, String title, String description) {
    final textMuted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        colorScheme.surface.withValues(alpha: isDark ? 0.12 : 0.85);
    final borderColor =
        colorScheme.onSurface.withValues(alpha: isDark ? 0.12 : 0.08);
    final textMuted = colorScheme.onSurface.withValues(alpha: 0.7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.question_answer,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              answer,
              style: TextStyle(
                color: textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        colorScheme.surface.withValues(alpha: isDark ? 0.12 : 0.85);
    final borderColor =
        colorScheme.onSurface.withValues(alpha: isDark ? 0.12 : 0.08);
    final textMuted = colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: textMuted,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    final textMuted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildSelectedPage(
    BuildContext context, {
    required Color pageCardColor,
    required Color pageBorderColor,
    required Color textMuted,
  }) {
    switch (_selectedPage) {
      case _PageType.about:
        return _buildAboutPage(
          context,
          pageCardColor: pageCardColor,
          pageBorderColor: pageBorderColor,
          textMuted: textMuted,
        );
      case _PageType.help:
        return _buildHelpPage(
          context,
          pageCardColor: pageCardColor,
          textMuted: textMuted,
        );
      case null:
        return null;
    }
  }

  Widget _buildAboutPage(
    BuildContext context, {
    required Color pageCardColor,
    required Color pageBorderColor,
    required Color textMuted,
  }) {
    return Padding(
      key: const ValueKey('about_page'),
      padding: const EdgeInsets.all(24.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pageCardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Settings Example App',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Description
              Text(
                'About This App',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'A comprehensive demonstration of the SettingsItem package, showcasing expandable menus, switches, and custom widgets for building beautiful settings interfaces in Flutter.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textMuted,
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 32),

              // Features
              Text(
                'Key Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                context,
                Icons.tune,
                'Customizable Settings',
                'Flexible parameters for switches, expandable menus, and custom widgets',
              ),
              _buildFeatureItem(
                context,
                Icons.palette,
                'Material Design 3',
                'Modern UI components following Material 3 guidelines',
              ),
              _buildFeatureItem(
                context,
                Icons.dark_mode,
                'Theme Support',
                'Full support for light and dark themes',
              ),
              _buildFeatureItem(
                context,
                Icons.code,
                'Easy Integration',
                'Simple API for quick implementation',
              ),
              const SizedBox(height: 32),

              // Developer Info
              Text(
                'Developer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Built with ',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textMuted,
                        ),
                  ),
                  Icon(
                    Icons.favorite,
                    size: 18,
                    color: Colors.red,
                  ),
                  Text(
                    ' using Flutter',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textMuted,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // License
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: pageCardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: pageBorderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, size: 20, color: textMuted),
                        const SizedBox(width: 8),
                        Text(
                          'License',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This project is licensed under the MIT License',
                      style: TextStyle(color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpPage(
    BuildContext context, {
    required Color pageCardColor,
    required Color textMuted,
  }) {
    return Padding(
      key: const ValueKey('help_page'),
      padding: const EdgeInsets.all(24.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pageCardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Help & Support',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'re here to help you',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // FAQs
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                context,
                'How do I customize the settings items?',
                'You can customize settings items using the ExpandableParameters class. Set properties like prefixIcon, title, isSwitch, and isExpandeable to configure the behavior.',
              ),
              _buildFAQItem(
                context,
                'Can I use custom widgets in expanded sections?',
                'Yes! Use the expandedWidget parameter to provide any custom Flutter widget for the expanded content.',
              ),
              _buildFAQItem(
                context,
                'How do I handle state changes?',
                'Use the onChange callback to react to changes in the settings item state, whether it\'s a switch toggle or menu expansion.',
              ),
              _buildFAQItem(
                context,
                'Does it support dark mode?',
                'Absolutely! The package fully supports Flutter\'s theme system, including light and dark modes.',
              ),
              const SizedBox(height: 32),

              // Contact Support
              Text(
                'Contact Support',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                context,
                Icons.email,
                'Email',
                'support@example.com',
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                context,
                Icons.public,
                'Website',
                'https://pub.dev/packages/settings_item',
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                context,
                Icons.bug_report,
                'Report Bug',
                'github.com/yourrepo/issues',
              ),
              const SizedBox(height: 32),

              // Quick Tips
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pro Tips',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTipItem(
                        'Use suffixWidget for custom badges and indicators'),
                    _buildTipItem(
                        'Combine switches with expandable sections for complex settings'),
                    _buildTipItem(
                        'Use onExpandedSectionToggle for analytics tracking'),
                    _buildTipItem(
                        'Keep expanded content focused and easy to navigate'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PageType { about, help }

//****************************** */

class _ThePage extends StatelessWidget {
  final Widget? page;
  // ignore: unused_element_parameter
  const _ThePage({super.key, this.page});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: 300,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade900
            : Colors.blue.shade200,
      ),
      child: AnimatedSwitcher(
        duration: Duration(
          milliseconds: 300,
        ),
        child: page ??
            Center(
              key: ValueKey('no_page_selected'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Basic Example of SettingsItem",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontSize: 20,
                    ),
                  ),

                  // basic SettingsItem example
                  SizedBox(height: 36),
                  SizedBox(
                    width: 300,
                    child: SettingsItem(
                      parameters: ExpandableParameters(
                        prefixIcon: Icons.settings,
                        title: 'Settings Example',
                        isExpandeable: true,
                        expandedWidget: Text(
                          'This is a basic example of SettingsItem with INTERNAL state management. No need to manage state in parent! Select a page from the left menu to see more examples.',
                        ),
                      ),
                      // Using internal state - no isActive needed!
                      initialState: false,
                      onChange: (value) {
                        // Optional: listen to state changes
                        debugPrint('State changed to: $value');
                      },
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
