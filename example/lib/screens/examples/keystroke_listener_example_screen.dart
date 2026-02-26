import 'package:s_packages/s_packages.dart';

class KeystrokeListenerExampleScreen extends StatefulWidget {
  const KeystrokeListenerExampleScreen({super.key});

  @override
  State<KeystrokeListenerExampleScreen> createState() =>
      _KeystrokeListenerExampleScreenState();
}

class _KeystrokeListenerExampleScreenState
    extends State<KeystrokeListenerExampleScreen> {
  final List<String> _eventLog = [];
  bool _enableVisualDebug = false;
  String _lastKey = 'None';

  void _logEvent(String event) {
    setState(() {
      _lastKey = event;
      _eventLog.insert(0, event);
      if (_eventLog.length > 10) {
        _eventLog.removeLast();
      }
    });
  }

  void _clearLog() {
    setState(() {
      _eventLog.clear();
      _lastKey = 'None';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keystroke Listener Example'),
      ),
      body: KeystrokeListener(
        enableVisualDebug: _enableVisualDebug,
        actionHandlers: {
          CopySelectionTextIntent: () => _logEvent('Copy (action handler)'),
          PasteTextIntent: () => _logEvent('Paste (action handler)'),
          SelectAllTextIntent: () => _logEvent('Select All (action handler)'),
        },
        onKeyEvent: (event) {
          final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
          final isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

          String modifiers = '';
          if (isCtrlPressed) modifiers += 'Ctrl+';
          if (isMetaPressed) modifiers += 'Cmd+';
          if (isShiftPressed) modifiers += 'Shift+';

          final keyLabel = event.logicalKey.keyLabel.toLowerCase();
          final fullKey = modifiers.isEmpty ? keyLabel : '$modifiers$keyLabel';

          _logEvent(fullKey);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Press any key to see it captured',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Last Key Display
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Last Key Pressed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastKey,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Visual Debug Toggle
                SwitchListTile(
                  value: _enableVisualDebug,
                  onChanged: (value) {
                    setState(() {
                      _enableVisualDebug = value;
                    });
                  },
                  title: const Text('Enable Visual Debug'),
                  subtitle: const Text('Shows SnackBar with pressed key name'),
                ),
                const SizedBox(height: 24),

                // Common Shortcuts
                const Text(
                  'Try These Common Shortcuts:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildShortcutHint('Arrow Keys', 'Navigation'),
                _buildShortcutHint('Ctrl/Cmd + S', 'Save'),
                _buildShortcutHint('Ctrl/Cmd + C', 'Copy'),
                _buildShortcutHint('Ctrl/Cmd + V', 'Paste'),
                _buildShortcutHint('Escape', 'Dismiss'),
                _buildShortcutHint('Enter', 'Submit'),
                const SizedBox(height: 24),

                // Event Log
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Event Log',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _clearLog,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _eventLog.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'No events yet. Start pressing keys!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _eventLog.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                '${index + 1}. ${_eventLog[index]}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutHint(String keys, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            action,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
