import 'package:flutter/material.dart';
import 'package:s_time/s_time.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S Time Picker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TimePickerDemoPage(),
    );
  }
}

class TimePickerDemoPage extends StatefulWidget {
  const TimePickerDemoPage({super.key});

  @override
  State<TimePickerDemoPage> createState() => _TimePickerDemoPageState();
}

class _TimePickerDemoPageState extends State<TimePickerDemoPage> {
  TimeOfDay? selectedSpinnerTime = const TimeOfDay(hour: 10, minute: 30);
  bool is24HourFormat = false; // Toggle for 12/24 hour format
  bool useCustomValues = false; // Toggle for custom hour/minute values
  bool useDiscardedValues = false; // Toggle for discarded values
  bool showNoSelectionDots = true; // Toggle for no-selection dots

  TimeOfDay? selectedTextFieldTime;
  int selectedTimeInputExample = 0; // Track which TimeInput example to show

  void _onSpinnerTimeChanged(TimeOfDay? time) {
    setState(() {
      selectedSpinnerTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('S Time Picker Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Showcasing all features of the package',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // SECTION 1: SPINNER TIME PICKER
            _buildSectionHeader('1. Spinner Time Picker'),
            const SizedBox(height: 16),

            // Toggle: 12/24 hour format
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('12-Hour', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Switch(
                  value: is24HourFormat,
                  onChanged: (value) {
                    setState(() {
                      is24HourFormat = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('24-Hour', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),

            // Toggle: Custom values
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Default Values', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Switch(
                  value: useCustomValues,
                  onChanged: (value) {
                    setState(() {
                      useCustomValues = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('Custom Values', style: TextStyle(fontSize: 14)),
              ],
            ),
            if (useCustomValues)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  is24HourFormat
                      ? 'Hours: Every 2 hours (0, 2, 4, ..., 22)\nMinutes: Every 15 minutes (0, 15, 30, 45)'
                      : 'Hours: Every 2 hours (0, 2, 4, ..., 10)\nMinutes: Every 15 minutes (0, 15, 30, 45)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),

            // Toggle: Discarded values
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('All Hours/Minutes', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Switch(
                  value: useDiscardedValues,
                  onChanged: (value) {
                    setState(() {
                      useDiscardedValues = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('Discard Some', style: TextStyle(fontSize: 14)),
              ],
            ),
            if (useDiscardedValues)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Discarded hours: 13-17 (lunch break)\nDiscarded minutes: 5, 35, 55',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),

            // Toggle: No-selection dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hide Dots', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Switch(
                  value: showNoSelectionDots,
                  onChanged: (value) {
                    setState(() {
                      showNoSelectionDots = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('Show Dots', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),

            TimeSpinner(
              initTime: selectedSpinnerTime,
              is24HourFormat: is24HourFormat,
              amPmButtonStyle: AmPmButtonStyle(
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
                selectedColor: is24HourFormat
                    ? Colors.indigo.withValues(alpha: 0.2)
                    : useCustomValues
                        ? Colors.green.withValues(alpha: 0.2)
                        : useDiscardedValues
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.2),
                borderColor: is24HourFormat
                    ? Colors.indigo
                    : useCustomValues
                        ? Colors.green
                        : useDiscardedValues
                            ? Colors.orange
                            : Colors.blue,
                borderWidth: 1.5,
                borderRadius: BorderRadius.circular(4),
              ),
              spinnerBgColor: is24HourFormat
                  ? const Color(0xFFE3F2FD)
                  : useCustomValues
                      ? const Color(0xFFE8F5E9)
                      : useDiscardedValues
                          ? const Color(0xFFFFF3E0)
                          : const Color(0xFFF5F5F5),
              selectedTextStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: is24HourFormat
                    ? Colors.indigo
                    : useCustomValues
                        ? Colors.green
                        : useDiscardedValues
                            ? Colors.orange
                            : Colors.blue,
              ),
              nonSelectedTextStyle: const TextStyle(
                fontSize: 18,
                color: Color(0xFFBDBDBD),
              ),
              borderRadius: is24HourFormat
                  ? BorderRadius.circular(12)
                  : useCustomValues
                      ? BorderRadius.circular(16)
                      : useDiscardedValues
                          ? BorderRadius.circular(20)
                          : null,
              spinnerBorder: is24HourFormat
                  ? Border.all(color: Colors.blue, width: 2)
                  : useDiscardedValues
                      ? Border.all(color: Colors.orange, width: 1.5)
                      : null,
              hrValues: useCustomValues
                  ? (is24HourFormat
                      ? List.generate(12, (i) => i * 2) // 0, 2, 4, ..., 22
                      : List.generate(
                          6, (i) => i * 2)) // 0, 2, 4, ..., 10 for 12-hour
                  : null,
              minValues: useCustomValues ? const [0, 15, 30, 45] : null,
              discardedHrValues:
                  useDiscardedValues ? const [13, 14, 15, 16, 17] : const [],
              discardedMinValues:
                  useDiscardedValues ? const [5, 35, 55] : const [],
              showNoSelectionDots: showNoSelectionDots,
              onChangedSelectedTime: _onSpinnerTimeChanged,
            ),
            const SizedBox(height: 8),
            _buildResultDisplay('Selected Time', selectedSpinnerTime),
            const SizedBox(height: 32),

            // SECTION 2: TEXT FIELD TIME INPUT
            _buildSectionHeader('2. Text Field Time Input (TimeInput)'),
            const SizedBox(height: 16),

            // Toggle buttons for different examples
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildExampleToggleButton(0, 'Basic'),
                _buildExampleToggleButton(1, 'Custom Style'),
                _buildExampleToggleButton(2, 'Auto-Focus'),
                _buildExampleToggleButton(3, 'Nullable'),
                _buildExampleToggleButton(4, 'Default Time'),
                _buildExampleToggleButton(5, 'Local Time'),
                _buildExampleToggleButton(6, 'Local + Indicator'),
                _buildExampleToggleButton(7, 'Custom Decoration'),
              ],
            ),
            const SizedBox(height: 16),

            // Example description
            _buildExampleDescription(),
            const SizedBox(height: 16),

            // TimeInput widget based on selected example
            _buildSelectedTimeInputExample(),
            const SizedBox(height: 8),
            _buildResultDisplay('Selected Time', selectedTextFieldTime,
                allowNull: selectedTimeInputExample == 3),
            const SizedBox(height: 32),

            // SECTION 3: FEATURES & INTERACTIONS
            _buildSectionHeader('3. Features & Interactions'),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildInfoCard(
                  icon: Icons.keyboard,
                  title: 'Double-Tap Edit',
                  description: 'Double-tap spinner to type time directly',
                  color: Colors.indigo,
                ),
                _buildInfoCard(
                  icon: Icons.keyboard_return,
                  title: 'Enter Key',
                  description: 'Submit time input',
                  color: Colors.green,
                ),
                _buildInfoCard(
                  icon: Icons.cancel_outlined,
                  title: 'Escape Key',
                  description: 'Cancel editing',
                  color: Colors.red,
                ),
                _buildInfoCard(
                  icon: Icons.edit,
                  title: 'Smart Format',
                  description: 'Auto-formats "1030" → "10:30"',
                  color: Colors.purple,
                ),
                _buildInfoCard(
                  icon: Icons.touch_app,
                  title: 'Smart Cursor',
                  description: 'Intelligent cursor positioning',
                  color: Colors.orange,
                ),
                _buildInfoCard(
                  icon: Icons.check_circle_outline,
                  title: 'Validation',
                  description: 'Real-time input validation',
                  color: Colors.teal,
                ),
                _buildInfoCard(
                  icon: Icons.loop,
                  title: 'Infinite Scroll',
                  description: 'Smooth infinite spinner scrolling',
                  color: Colors.blue,
                ),
                _buildInfoCard(
                  icon: Icons.settings,
                  title: 'Customizable',
                  description: 'Extensive styling options',
                  color: Colors.brown,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Footer
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Try interacting with the components above to see all features in action!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildExampleToggleButton(int index, String label) {
    final isSelected = selectedTimeInputExample == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTimeInputExample = index;
          selectedTextFieldTime = null; // Reset selection when switching
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[700] : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 4 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildExampleDescription() {
    final descriptions = [
      'Basic usage with default styling and behavior',
      'Custom styling with colors, padding, and border radius',
      'Auto-focus mode with cursor selection options',
      'Nullable time - can be empty and return null when cleared',
      'Default time fallback - uses 08:00 when input is invalid',
      'Local time mode - displays time without timezone suffix (e.g., "12:56")',
      'Local time with indicator - displays time with small "ʟ" suffix (e.g., "12:56 ʟ")',
      'Custom input decoration with custom styles and icons',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              descriptions[selectedTimeInputExample],
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTimeInputExample() {
    // Determine properties based on selected example
    final titles = [
      'Start Time',
      'End Time',
      'Meeting Time',
      'Optional Time',
      'Work Start',
      'Local Time',
      'Local Time',
      'Custom Style'
    ];
    final title = titles[selectedTimeInputExample];

    return SizedBox(
      width: 120,
      child: TimeInput(
        title: title,
        time: selectedTextFieldTime?.toDateTime(),
        colorPerTitle: selectedTimeInputExample == 1
            ? const {'End Time': Colors.teal}
            : null,
        inputFontSize: selectedTimeInputExample == 1 ? 18 : null,
        borderRadius: selectedTimeInputExample == 1 ? 16 : null,
        contentPadding: selectedTimeInputExample == 1
            ? const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
            : null,
        autoFocus: selectedTimeInputExample == 2,
        replaceAllTextOnAutoFocus: selectedTimeInputExample == 2,
        isEmptyWhenTimeNull: selectedTimeInputExample == 3,
        showClearButton: selectedTimeInputExample == 3,
        defaultTime: selectedTimeInputExample == 4
            ? const TimeOfDay(hour: 8, minute: 0)
            : null,
        isUtc: selectedTimeInputExample != 5 && selectedTimeInputExample != 6,
        showLocalIndicator: selectedTimeInputExample == 6,
        inputDecoration: selectedTimeInputExample == 7
            ? InputDecoration(
                fillColor: Colors.amber[50],
                filled: true,
                hintText: 'Enter time (HHMM)',
                labelText: 'Custom Label',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.amber, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              )
            : null,
        onSubmitted: (time) {
          setState(() {
            selectedTextFieldTime = time;
          });
        },
        onChanged: selectedTimeInputExample == 1
            ? (time) {
                print('Time changed: $time');
              }
            : null,
      ),
    );
  }

  Widget _buildResultDisplay(String label, TimeOfDay? time,
      {bool allowNull = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            time == null
                ? (allowNull ? 'null (empty)' : 'Not selected')
                : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: time == null ? Colors.grey[600] : Colors.blue[700],
              fontWeight: time == null ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
