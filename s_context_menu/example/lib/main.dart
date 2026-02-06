import 'package:flutter/material.dart';
import 'package:s_context_menu/s_context_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_context_menu Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.light(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _actionLog = [];

  // State for Keep Menu Open example
  final Set<String> _selectedOptions = {};

  void _updateLastAction(String action) {
    setState(() {
      _actionLog.add(
          '[${DateTime.now().toLocal().toString().split('.')[0]}] $action');
      // Keep only the last 50 actions
      if (_actionLog.length > 50) {
        _actionLog.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_context_menu Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Info Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                    const SizedBox(height: 8),
                    Text('• Desktop: Right-click on any box',
                        style: TextStyle(color: Colors.blue.shade900)),
                    Text('• Mobile: Long-press on any box',
                        style: TextStyle(color: Colors.blue.shade900)),
                    Text(
                        '• Keyboard: Use ↑↓ arrow keys to navigate, ENTER or SPACE to select, ESC key to cancel/close the menu',
                        style: TextStyle(color: Colors.blue.shade900)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Basic Example
              Text(
                'Basic Example',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SContextMenu(
                buttons: [
                  SContextMenuItem(
                    label: 'Edit',
                    icon: Icons.edit,
                    onPressed: () => _updateLastAction('Basic - Edit button'),
                  ),
                  SContextMenuItem(
                    label: 'Copy',
                    icon: Icons.copy,
                    onPressed: () => _updateLastAction('Basic - Copy button'),
                  ),
                  SContextMenuItem(
                    label: 'Delete',
                    icon: Icons.delete,
                    destructive: true,
                    onPressed: () => _updateLastAction('Basic - Delete button'),
                  ),
                ],
                onOpened: () => _updateLastAction('Basic - Menu opened'),
                onDismissed: () => _updateLastAction('Basic - Menu dismissed'),
                onButtonPressed: (label) => _updateLastAction(
                    'Basic - onButtonPressed - Button pressed was:  $label'),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Right-click or long-press\nfor context menu',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Themed Example - Custom Light Style
              Text(
                'Custom Themed Example',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SContextMenu(
                theme: SContextMenuTheme(
                  // Light panel with teal accent
                  panelBackgroundColor: const Color.fromARGB(248, 30, 109, 69),
                  panelBorderColor: Colors.teal.shade300,
                  panelBorderRadius: 16,
                  panelBlurSigma: 20,
                  panelPadding: const EdgeInsets.symmetric(vertical: 4),
                  // Soft shadows
                  panelShadows: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  // Custom colors for menu items
                  iconColor: const Color.fromARGB(255, 83, 245, 226),
                  destructiveColor: const Color.fromARGB(255, 237, 134, 132),
                  hoverColor: const Color.fromARGB(255, 84, 201, 190)
                      .withValues(alpha: 0.12),
                  // Curved arrow with larger size
                  arrowShape: ArrowShape.curved,
                  arrowColor: const Color.fromARGB(255, 48, 91, 86),
                  arrowBaseWidth: 16,
                  arrowMaxLength: 8,
                  arrowTipRoundness: 3,
                  // Slower, more dramatic animations
                  showDuration: const Duration(milliseconds: 350),
                  hideDuration: const Duration(milliseconds: 250),
                ),
                buttons: [
                  SContextMenuItem(
                    label: 'Refresh',
                    icon: Icons.refresh,
                    onPressed: () =>
                        _updateLastAction('Themed - Refresh button'),
                  ),
                  SContextMenuItem(
                    label: 'Bookmark',
                    icon: Icons.bookmark_add_outlined,
                    onPressed: () =>
                        _updateLastAction('Themed - Bookmark button'),
                  ),
                  SContextMenuItem(
                    label: 'Share',
                    icon: Icons.share_outlined,
                    onPressed: () => _updateLastAction('Themed - Share button'),
                  ),
                  SContextMenuItem(
                    label: 'Remove',
                    icon: Icons.remove_circle_outline,
                    destructive: true,
                    onPressed: () =>
                        _updateLastAction('Themed - Remove button'),
                  ),
                ],
                onOpened: () => _updateLastAction('Themed Menu opened'),
                onDismissed: () => _updateLastAction('Themed Menu dismissed'),
                onButtonPressed: (label) =>
                    _updateLastAction('Themed - Button pressed was: $label'),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.teal.shade100,
                        Colors.cyan.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '🌿 Custom light theme\nwith teal accent',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Multiple Items Example
              Text(
                'Multiple Items Example',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SContextMenu(
                buttons: [
                  SContextMenuItem(
                    label: 'View Details',
                    icon: Icons.info,
                    onPressed: () =>
                        _updateLastAction('Multiple - View Details button'),
                  ),
                  SContextMenuItem(
                    label: 'Edit',
                    icon: Icons.edit,
                    onPressed: () =>
                        _updateLastAction('Multiple - Edit button'),
                  ),
                  SContextMenuItem(
                    label: 'Duplicate',
                    icon: Icons.copy,
                    onPressed: () =>
                        _updateLastAction('Multiple - Duplicate button'),
                  ),
                  SContextMenuItem(
                    label: 'Move',
                    icon: Icons.move_up_rounded,
                    onPressed: () =>
                        _updateLastAction('Multiple - Move button'),
                  ),
                  SContextMenuItem(
                    label: 'Download',
                    icon: Icons.download,
                    onPressed: () =>
                        _updateLastAction('Multiple - Download button'),
                  ),
                  SContextMenuItem(
                    label: 'Delete',
                    icon: Icons.delete,
                    destructive: true,
                    onPressed: () =>
                        _updateLastAction('Multiple - Delete button'),
                  ),
                ],
                onOpened: () => _updateLastAction('Multiple Items Menu opened'),
                onDismissed: () =>
                    _updateLastAction('Multiple Items Menu dismissed'),
                onButtonPressed: (label) => _updateLastAction(
                    'Multiple onButtonPressed - Button pressed was: $label'),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Many options\nwill scroll',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Keep Menu Open Example
              Text(
                'Keep Menu Open Example',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildKeepOpenExample(),
              const SizedBox(height: 24),

              // Action Log Display
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Action Log (${_actionLog.length}):',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _actionLog.clear()),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Clear'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _actionLog.isEmpty
                          ? Center(
                              child: Text(
                                'No actions yet',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _actionLog.length,
                              reverse: true,
                              itemBuilder: (context, index) {
                                final logEntry =
                                    _actionLog[_actionLog.length - 1 - index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    logEntry,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                );
                              },
                            ),
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

  Widget _buildKeepOpenExample() {
    final options = ['Option A', 'Option B', 'Option C', 'Option D'];

    return SContextMenu(
      buttons: [
        // Toggle options - these keep the menu open
        ...options.map((option) {
          final isSelected = _selectedOptions.contains(option);
          return SContextMenuItem(
            label: '$option ${isSelected ? '✓' : ''}',
            icon: isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            keepMenuOpen: true, // Menu stays open!
            onPressed: () {
              setState(() {
                if (isSelected) {
                  _selectedOptions.remove(option);
                } else {
                  _selectedOptions.add(option);
                }
              });
              _updateLastAction(
                  'KeepOpen - $option ${isSelected ? 'deselected' : 'selected'}');
            },
          );
        }),
        // Apply button - this closes the menu
        SContextMenuItem(
          label: 'Apply (${_selectedOptions.length} selected)',
          icon: Icons.check,
          keepMenuOpen: false, // This one closes the menu
          onPressed: () => _updateLastAction(
              'KeepOpen - Applied: ${_selectedOptions.join(', ')}'),
        ),
      ],
      onOpened: () => _updateLastAction('KeepOpen Menu opened'),
      onDismissed: () => _updateLastAction('KeepOpen Menu dismissed'),
      onButtonPressed: (label) =>
          _updateLastAction('KeepOpen - Button pressed was: $label'),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          border: Border.all(color: Colors.amber.shade700),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: [
              Text(
                'Multi-select menu\n(stays open)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber.shade900),
              ),
              if (_selectedOptions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${_selectedOptions.join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
