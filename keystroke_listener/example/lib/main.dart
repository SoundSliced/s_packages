import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keystroke_listener/keystroke_listener.dart';

void main() {
  runApp(const KeystrokeListenerExampleApp());
}

class KeystrokeListenerExampleApp extends StatelessWidget {
  const KeystrokeListenerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keystroke Listener Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const KeystrokeListenerExample(),
    );
  }
}

class KeystrokeListenerExample extends StatefulWidget {
  const KeystrokeListenerExample({super.key});

  @override
  State<KeystrokeListenerExample> createState() =>
      _KeystrokeListenerExampleState();
}

class _KeystrokeListenerExampleState extends State<KeystrokeListenerExample> {
  final List<String> _eventLog = [];
  bool _enableVisualDebug = false;
  int _commandCount = 0;
  String _selectedAction = 'None';
  bool _ctrlPressed = false;
  bool _cmdPressed = false;
  bool _shiftPressed = false;
  bool _altPressed = false;

  // Track which key descriptions should be highlighted
  final Set<String> _highlightedKeys = {};
  late DateTime _lastHighlightTime;

  // Map of key combinations to their descriptions
  static const Map<String, String> _keyMap = {
    // Arrow keys - handle both word and symbol forms
    'up': 'Navigate',
    'down': 'Navigate',
    'left': 'Navigate',
    'right': 'Navigate',
    'arrow up': 'Navigate',
    'arrow down': 'Navigate',
    'arrow left': 'Navigate',
    'arrow right': 'Navigate',
    '↑': 'Navigate',
    '↓': 'Navigate',
    '←': 'Navigate',
    '→': 'Navigate',
    'enter': 'Submit',
    'escape': 'Escape',
    'backspace': 'Delete',
    'space': 'Space',
    ' ': 'Space', // Space key may be labeled as actual space character
    'tab': 'Tab Navigation',
    'shift+tab': 'Tab Navigation',
    'ctrl+s': 'Save',
    'cmd+s': 'Save',
    'ctrl+z': 'Undo',
    'cmd+z': 'Undo',
    'ctrl+y': 'Redo',
    'cmd+y': 'Redo',
    'ctrl+a': 'Select All',
    'cmd+a': 'Select All',
    'ctrl+c': 'Copy',
    'cmd+c': 'Copy',
    'ctrl+v': 'Paste',
    'cmd+v': 'Paste',
    'ctrl+x': 'Cut',
    'cmd+x': 'Cut',
    'ctrl+/': 'Toggle Comment',
    'cmd+/': 'Toggle Comment',
    'f1': 'Help',
  };

  void _logEvent(String event) {
    setState(() {
      _eventLog.insert(0, '${DateTime.now().toIso8601String()}: $event');
      if (_eventLog.length > 20) {
        _eventLog.removeLast();
      }
    });
  }

  void _clearLog() {
    setState(() {
      _eventLog.clear();
      _commandCount = 0;
      _selectedAction = 'None';
    });
  }

  @override
  void initState() {
    super.initState();
    // Update modifier state periodically to show live state
    Future.delayed(const Duration(milliseconds: 50), _updateModifierState);
  }

  void _updateModifierState() {
    if (!mounted) return;
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final cmd = HardwareKeyboard.instance.isMetaPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final alt = HardwareKeyboard.instance.isAltPressed;

    if (ctrl != _ctrlPressed ||
        cmd != _cmdPressed ||
        shift != _shiftPressed ||
        alt != _altPressed) {
      setState(() {
        _ctrlPressed = ctrl;
        _cmdPressed = cmd;
        _shiftPressed = shift;
        _altPressed = alt;
      });
    }
    Future.delayed(const Duration(milliseconds: 50), _updateModifierState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keystroke Listener Example'),
        centerTitle: true,
        elevation: 0,
      ),
      body: KeystrokeListener(
        enableVisualDebug: _enableVisualDebug,
        onKeyEvent: (event) {
          // IMPORTANT: This callback fires for every key event (including modifier keys).
          // To detect a combination like Cmd+X:
          // 1. Cmd key is pressed first -> fires callback with Cmd+ (but no char key)
          // 2. X key is pressed while Cmd held -> fires callback with "Cmd+X" (THIS is the combo!)
          // The modifier state is checked AT THE MOMENT this event fires, so we can detect
          // which modifiers were active when the X key was pressed.
          final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
          final isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
          final isAltPressed = HardwareKeyboard.instance.isAltPressed;

          String modifiers = '';
          if (isCtrlPressed) modifiers += 'ctrl+';
          if (isMetaPressed) modifiers += 'cmd+';
          if (isShiftPressed) modifiers += 'shift+';
          if (isAltPressed) modifiers += 'alt+';

          // Get the key label and normalize it
          var rawLabel = event.logicalKey.keyLabel;

          // Handle special cases for key labels
          String keyLabel;
          if (rawLabel == ' ' || rawLabel.toLowerCase() == 'space') {
            keyLabel = 'space';
          } else if (rawLabel == '↑' || rawLabel.toLowerCase() == 'arrowup') {
            keyLabel = '↑';
          } else if (rawLabel == '↓' || rawLabel.toLowerCase() == 'arrowdown') {
            keyLabel = '↓';
          } else if (rawLabel == '←' || rawLabel.toLowerCase() == 'arrowleft') {
            keyLabel = '←';
          } else if (rawLabel == '→' ||
              rawLabel.toLowerCase() == 'arrowright') {
            keyLabel = '→';
          } else {
            keyLabel = rawLabel.toLowerCase();
          }

          final fullKey = modifiers.isEmpty ? keyLabel : '$modifiers$keyLabel';

          // Check if this key combination matches any mapped action
          if (_keyMap.containsKey(fullKey)) {
            final action = _keyMap[fullKey]!;
            setState(() {
              _highlightedKeys.clear();
              _highlightedKeys.add(action);
              _lastHighlightTime = DateTime.now();
              _selectedAction = action;
              _commandCount++;
            });

            // Auto-unhighlight after 600ms
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted &&
                  DateTime.now()
                          .difference(_lastHighlightTime)
                          .inMilliseconds >=
                      600) {
                setState(() {
                  _highlightedKeys.clear();
                });
              }
            });
          }

          _logEvent('Key: $fullKey');
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Keystroke Listener Demo',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try pressing various keys to see the listener in action. This example demonstrates both basic and advanced keystroke handling.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Total Commands: $_commandCount',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Chip(
                              label: Text(_selectedAction),
                              backgroundColor: Colors.deepPurple.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Modifier State Display
                        Row(
                          children: [
                            _buildModifierChip('Cmd', _cmdPressed),
                            const SizedBox(width: 4),
                            _buildModifierChip('Ctrl', _ctrlPressed),
                            const SizedBox(width: 4),
                            _buildModifierChip('Shift', _shiftPressed),
                            const SizedBox(width: 4),
                            _buildModifierChip('Alt', _altPressed),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Basic Controls Section
                const Text(
                  'Basic Controls',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKeyDescription(
                          '↑ / ↓ / ← / →',
                          'Navigate',
                          'Arrow keys for navigation',
                        ),
                        _buildKeyDescription(
                          'Enter',
                          'Submit',
                          'Press Enter to submit',
                        ),
                        _buildKeyDescription(
                          'Esc',
                          'Escape',
                          'Press Escape to dismiss',
                        ),
                        _buildKeyDescription(
                          'Backspace',
                          'Delete',
                          'Delete previous character',
                        ),
                        _buildKeyDescription(
                          'Space',
                          'Space',
                          'Press Space for action',
                        ),
                        _buildKeyDescription(
                          'Tab / Shift+Tab',
                          'Tab Navigation',
                          'Move focus forward/backward',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Advanced Controls Section
                const Text(
                  'Advanced Controls',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKeyDescription(
                          'Ctrl/Cmd + S',
                          'Save',
                          'Save current state',
                        ),
                        _buildKeyDescription(
                          'Ctrl/Cmd + Z',
                          'Undo',
                          'Undo last action',
                        ),
                        _buildKeyDescription(
                          'Ctrl/Cmd + Y',
                          'Redo',
                          'Redo last action',
                        ),
                        _buildKeyDescription(
                          'Ctrl/Cmd + A',
                          'Select All',
                          'Select all content',
                        ),
                        _buildKeyDescription(
                          'Ctrl/Cmd + C',
                          'Copy',
                          'Copy to clipboard',
                        ),
                        _buildKeyDescription(
                          'Ctrl/Cmd + V',
                          'Paste',
                          'Paste from clipboard',
                        ),
                        _buildKeyDescription(
                          'Ctrl/Cmd + X',
                          'Cut',
                          'Cut to clipboard',
                        ),
                        _buildKeyDescription(
                          'Ctrl/Cmd + /',
                          'Toggle Comment',
                          'Toggle comment on line',
                        ),
                        _buildKeyDescription(
                          'F1',
                          'Help',
                          'Show help information',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: _enableVisualDebug,
                          onChanged: (value) {
                            setState(() {
                              _enableVisualDebug = value ?? false;
                            });
                          },
                          title: const Text('Enable Visual Debug'),
                          subtitle: const Text(
                            'Shows SnackBar with pressed key name',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Event Log Section
                const Text(
                  'Event Log',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_eventLog.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Text(
                              'No events yet. Start pressing keys!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 300),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  itemCount: _eventLog.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                      child: Text(
                                        _eventLog[index],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _clearLog,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Clear Log'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyDescription(String keys, String action, String description) {
    final isHighlighted = _highlightedKeys.contains(action);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.deepPurple.shade50 : Colors.transparent,
          border: Border.all(
            color:
                isHighlighted ? Colors.deepPurple.shade300 : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.deepPurple
                    : Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isHighlighted
                      ? Colors.deepPurple.shade700
                      : Colors.deepPurple.shade300,
                ),
              ),
              child: Text(
                keys,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isHighlighted ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isHighlighted
                          ? Colors.deepPurple.shade700
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isHighlighted
                          ? Colors.deepPurple.shade600
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModifierChip(String label, bool isPressed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPressed ? Colors.deepPurple : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPressed ? Colors.deepPurple.shade700 : Colors.grey.shade400,
          width: isPressed ? 2 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isPressed ? FontWeight.bold : FontWeight.normal,
          color: isPressed ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }
}
