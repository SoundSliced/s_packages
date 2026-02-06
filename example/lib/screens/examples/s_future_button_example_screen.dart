import 'package:flutter/material.dart';
import 'package:s_future_button/s_future_button.dart';

class SFutureButtonExampleScreen extends StatefulWidget {
  const SFutureButtonExampleScreen({super.key});

  @override
  State<SFutureButtonExampleScreen> createState() =>
      _SFutureButtonExampleScreenState();
}

class _SFutureButtonExampleScreenState
    extends State<SFutureButtonExampleScreen> {
  String _statusMessage = '';

  Future<bool?> _simulateSuccess() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool?> _simulateValidationError() async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }

  Future<bool?> _simulateException() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Network error occurred');
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusMessage = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S Future Button Example'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Different button states and behaviors',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Success Example
              const Text(
                'Success Operation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Returns true after 2 seconds',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Center(
                child: SFutureButton(
                  onTap: _simulateSuccess,
                  label: 'Submit',
                  bgColor: Colors.blue.shade700,
                  onPostSuccess: () {
                    _updateStatus('Operation completed successfully!');
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Validation Error Example
              const Text(
                'Validation Failure',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Returns false to show validation error',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Center(
                child: SFutureButton(
                  onTap: _simulateValidationError,
                  label: 'Validate Form',
                  bgColor: Colors.orange.shade700,
                  onPostError: (error) {
                    _updateStatus('Validation failed: $error');
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Exception Handling Example
              const Text(
                'Exception Handling',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Throws an exception to show error',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Center(
                child: SFutureButton(
                  onTap: _simulateException,
                  label: 'Network Request',
                  bgColor: Colors.red.shade700,
                  onPostError: (error) {
                    _updateStatus('Error: $error');
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Custom Styled Button
              const Text(
                'Custom Styled',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Custom dimensions and border radius',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Center(
                child: SFutureButton(
                  onTap: _simulateSuccess,
                  label: 'Custom Style',
                  height: 50,
                  width: 200,
                  borderRadius: 12,
                  bgColor: Colors.green.shade600,
                  isElevatedButton: true,
                  onPostSuccess: () {
                    _updateStatus('Custom styled button pressed!');
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Icon Button
              const Text(
                'Icon Button',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Button with icon instead of text',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Center(
                child: SFutureButton(
                  onTap: _simulateSuccess,
                  icon: Icon(
                    Icons.cloud_upload,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 24,
                  ),
                  height: 50,
                  width: 50,
                  borderRadius: 25,
                  bgColor: Colors.purple.shade600,
                  onPostSuccess: () {
                    _updateStatus('Upload completed!');
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Status Message
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 14,
                          ),
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
