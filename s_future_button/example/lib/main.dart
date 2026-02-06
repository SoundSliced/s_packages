import 'package:flutter/material.dart';
import 'package:s_future_button/s_future_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFutureButton Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SFutureButtonExample(),
    );
  }
}

class SFutureButtonExample extends StatefulWidget {
  const SFutureButtonExample({super.key});

  @override
  State<SFutureButtonExample> createState() => _SFutureButtonExampleState();
}

class _SFutureButtonExampleState extends State<SFutureButtonExample> {
  String _statusMessage = '';

  Future<bool?> _simulateSuccessfulOperation() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool?> _simulateValidationFailure() async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }

  Future<bool?> _simulateException() async {
    await Future.delayed(const Duration(seconds: 2));
    throw Exception('Network error: Failed to connect to server');
  }

  Future<bool?> _simulateSilentDismissal() async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SFutureButton Examples'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          spacing: 24.0,
          children: [
            // Basic Example Section
            _buildSectionHeader('Basic Examples'),

            // Success Example
            _buildExampleCard(
              title: 'Success Operation',
              description: 'Returns true after 2 seconds',
              child: SFutureButton(
                onTap: _simulateSuccessfulOperation,
                label: 'Submit',
                onPostSuccess: () {
                  _updateStatus('Operation completed successfully!');
                },
              ),
            ),

            // Validation Failure Example
            _buildExampleCard(
              title: 'Validation Failure',
              description: 'Returns false to show validation error',
              child: SFutureButton(
                onTap: _simulateValidationFailure,
                label: 'Validate',
                bgColor: Colors.orange.shade700,
                onPostError: (error) {
                  _updateStatus('Validation failed: $error');
                },
              ),
            ),

            // Exception Handling Example
            _buildExampleCard(
              title: 'Exception Handling',
              description: 'Throws an exception to show error message',
              child: SFutureButton(
                onTap: _simulateException,
                label: 'Network Request',
                bgColor: Colors.red.shade700,
                onPostError: (error) {
                  _updateStatus('Error: $error');
                },
              ),
            ),

            // Silent Dismissal Example
            _buildExampleCard(
              title: 'Silent Dismissal',
              description: 'Returns null for silent reset',
              child: SFutureButton(
                onTap: _simulateSilentDismissal,
                label: 'Silent',
                bgColor: Colors.purple.shade700,
                showErrorMessage: false,
                onPostSuccess: () {
                  _updateStatus('Operation dismissed silently');
                },
              ),
            ),

            // Advanced Examples Section
            _buildSectionHeader('Advanced Examples'),

            // Custom Styled Button
            _buildExampleCard(
              title: 'Custom Styled Button',
              description: 'Custom dimensions, colors, and border radius',
              child: SFutureButton(
                onTap: _simulateSuccessfulOperation,
                label: 'Custom Style',
                height: 50,
                width: 200,
                borderRadius: 12,
                bgColor: Colors.green.shade600,
                iconColor: Colors.white,
                isElevatedButton: true,
                onPostSuccess: () {
                  _updateStatus('Custom styled button pressed!');
                },
              ),
            ),

            // Icon Button Example
            _buildExampleCard(
              title: 'Icon Button',
              description: 'Button with custom icon instead of text',
              child: SFutureButton(
                onTap: _simulateSuccessfulOperation,
                icon: const Icon(
                  Icons.cloud_upload,
                  color: Colors.white,
                  size: 24,
                ),
                height: 50,
                width: 50,
                borderRadius: 25,
                bgColor: Colors.blue.shade600,
                onPostSuccess: () {
                  _updateStatus('File uploaded successfully!');
                },
              ),
            ),

            // Flat Button Example
            _buildExampleCard(
              title: 'Flat Button (No Elevation)',
              description: 'Button without shadow elevation',
              child: SFutureButton(
                onTap: _simulateSuccessfulOperation,
                label: 'Flat Button',
                isElevatedButton: false,
                bgColor: Colors.indigo.shade600,
                onPostSuccess: () {
                  _updateStatus('Flat button action completed!');
                },
              ),
            ),

            // Disabled State Example
            _buildExampleCard(
              title: 'Disabled Button',
              description: 'Button in disabled state (cannot be tapped)',
              child: SFutureButton(
                onTap: _simulateSuccessfulOperation,
                label: 'Disabled',
                isEnabled: false,
                bgColor: Colors.grey.shade600,
              ),
            ),

            // Status Message Display
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
      ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
    // Auto-clear status after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _statusMessage = '';
        });
      }
    });
  }
}
