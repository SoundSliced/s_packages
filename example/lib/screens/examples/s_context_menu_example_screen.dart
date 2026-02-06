import 'package:s_packages/s_packages.dart';

class SContextMenuExampleScreen extends StatefulWidget {
  const SContextMenuExampleScreen({super.key});

  @override
  State<SContextMenuExampleScreen> createState() =>
      _SContextMenuExampleScreenState();
}

class _SContextMenuExampleScreenState extends State<SContextMenuExampleScreen> {
  String _lastAction = 'None';

  void _updateAction(String action) {
    setState(() {
      _lastAction = action;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S Context Menu Example'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
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
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Desktop: Right-click on boxes\n• Mobile: Long-press on boxes\n• Keyboard: Use ↑↓ arrows, Enter/Space to select',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Basic Context Menu
              const Text(
                'Basic Context Menu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Center(
                child: SContextMenu(
                  buttons: [
                    SContextMenuItem(
                      label: 'Edit',
                      icon: Icons.edit,
                      onPressed: () => _updateAction('Edit'),
                    ),
                    SContextMenuItem(
                      label: 'Copy',
                      icon: Icons.copy,
                      onPressed: () => _updateAction('Copy'),
                    ),
                    SContextMenuItem(
                      label: 'Delete',
                      icon: Icons.delete,
                      destructive: true,
                      onPressed: () => _updateAction('Delete'),
                    ),
                  ],
                  onButtonPressed: (label) => _updateAction(label),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      'Right-click or\nlong-press me',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Styled Context Menu
              const Text(
                'Custom Styled Menu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Center(
                child: SContextMenu(
                  theme: SContextMenuTheme(
                    panelBackgroundColor: Colors.purple.shade50,
                    panelBorderColor: Colors.purple.shade300,
                    panelBorderRadius: 16,
                    iconColor: Colors.purple.shade700,
                    destructiveColor: Colors.red.shade600,
                    arrowShape: ArrowShape.curved,
                    showDuration: const Duration(milliseconds: 300),
                  ),
                  buttons: [
                    SContextMenuItem(
                      label: 'Share',
                      icon: Icons.share,
                      onPressed: () => _updateAction('Share'),
                    ),
                    SContextMenuItem(
                      label: 'Bookmark',
                      icon: Icons.bookmark_add,
                      onPressed: () => _updateAction('Bookmark'),
                    ),
                    SContextMenuItem(
                      label: 'Download',
                      icon: Icons.download,
                      onPressed: () => _updateAction('Download'),
                    ),
                  ],
                  onButtonPressed: (label) => _updateAction(label),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade100,
                          Colors.purple.shade50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade300),
                    ),
                    child: Text(
                      'Custom themed\ncontext menu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.purple.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Multiple Options Menu
              const Text(
                'Multiple Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Center(
                child: SContextMenu(
                  buttons: [
                    SContextMenuItem(
                      label: 'View Details',
                      icon: Icons.info,
                      onPressed: () => _updateAction('View Details'),
                    ),
                    SContextMenuItem(
                      label: 'Edit',
                      icon: Icons.edit,
                      onPressed: () => _updateAction('Edit'),
                    ),
                    SContextMenuItem(
                      label: 'Duplicate',
                      icon: Icons.copy,
                      onPressed: () => _updateAction('Duplicate'),
                    ),
                    SContextMenuItem(
                      label: 'Move',
                      icon: Icons.move_up,
                      onPressed: () => _updateAction('Move'),
                    ),
                    SContextMenuItem(
                      label: 'Archive',
                      icon: Icons.archive,
                      onPressed: () => _updateAction('Archive'),
                    ),
                    SContextMenuItem(
                      label: 'Delete',
                      icon: Icons.delete,
                      destructive: true,
                      onPressed: () => _updateAction('Delete'),
                    ),
                  ],
                  onButtonPressed: (label) => _updateAction(label),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'Many options\nwith scrolling',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Last Action Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Last Action',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastAction,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
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
}
