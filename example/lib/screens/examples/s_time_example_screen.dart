import 'package:flutter/material.dart';
import 'package:s_time/s_time.dart';

class STimeExampleScreen extends StatefulWidget {
  const STimeExampleScreen({super.key});

  @override
  State<STimeExampleScreen> createState() => _STimeExampleScreenState();
}

class _STimeExampleScreenState extends State<STimeExampleScreen> {
  TimeOfDay? _spinnerTime = const TimeOfDay(hour: 10, minute: 30);
  TimeOfDay? _textFieldTime;
  bool _is24HourFormat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STime Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Section 1: Spinner Time Picker
            const Text(
              'Spinner Time Picker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 12/24 hour toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('12-Hour'),
                const SizedBox(width: 8),
                Switch(
                  value: _is24HourFormat,
                  onChanged: (value) {
                    setState(() {
                      _is24HourFormat = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('24-Hour'),
              ],
            ),
            const SizedBox(height: 16),

            // Time Spinner
            TimeSpinner(
              initTime: _spinnerTime,
              is24HourFormat: _is24HourFormat,
              spinnerBgColor: const Color(0xFFF5F5F5),
              selectedTextStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              nonSelectedTextStyle: const TextStyle(
                fontSize: 18,
                color: Color(0xFFBDBDBD),
              ),
              onChangedSelectedTime: (time) {
                setState(() {
                  _spinnerTime = time;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildResultDisplay('Selected Spinner Time', _spinnerTime),
            const SizedBox(height: 32),

            const Divider(),
            const SizedBox(height: 32),

            // Section 2: Text Field Time Input
            const Text(
              'Text Field Time Input',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Basic TimeInput
            SizedBox(
              width: 150,
              child: TimeInput(
                title: 'Start Time',
                time: _textFieldTime?.toDateTime(),
                onSubmitted: (time) {
                  setState(() {
                    _textFieldTime = time;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildResultDisplay('Selected Text Field Time', _textFieldTime),
            const SizedBox(height: 32),

            // Section 3: Custom Styled TimeInput
            const Text(
              'Custom Styled Input',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: 150,
              child: TimeInput(
                title: 'End Time',
                time: null,
                colorPerTitle: const {'End Time': Colors.teal},
                inputFontSize: 18,
                borderRadius: 16,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                onSubmitted: (time) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Time submitted: ${time?.hour.toString().padLeft(2, '0')}:${time?.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 40),

            // Features info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• Double-tap spinner to edit directly'),
                  const Text(
                      '• Smart text formatting (e.g., "1030" → "10:30")'),
                  const Text('• Supports both 12 and 24-hour formats'),
                  const Text('• Real-time input validation'),
                  const Text('• Customizable styling options'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDisplay(String label, TimeOfDay? time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            time == null
                ? 'Not selected'
                : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: time == null ? Colors.grey[600] : Colors.blue.shade700,
              fontWeight: time == null ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
