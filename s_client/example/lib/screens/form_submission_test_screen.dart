import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';

class FormSubmissionTestScreen extends StatefulWidget {
  const FormSubmissionTestScreen({super.key});

  @override
  State<FormSubmissionTestScreen> createState() =>
      _FormSubmissionTestScreenState();
}

class _FormSubmissionTestScreenState extends State<FormSubmissionTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoadingHttp = false;
  bool _isLoadingDio = false;
  bool _subscribeNewsletter = false;
  String _priority = 'normal';
  Map<String, dynamic>? _httpSubmissionResult;
  Map<String, dynamic>? _dioSubmissionResult;
  String? _httpError;
  String? _dioError;
  int? _httpDuration;
  int? _dioDuration;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm({required ClientType clientType}) async {
    if (!_formKey.currentState!.validate()) return;

    final isHttp = clientType == ClientType.http;
    setState(() {
      if (isHttp) {
        _isLoadingHttp = true;
        _httpSubmissionResult = null;
        _httpError = null;
        _httpDuration = null;
      } else {
        _isLoadingDio = true;
        _dioSubmissionResult = null;
        _dioError = null;
        _dioDuration = null;
      }
    });

    final formData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'message': _messageController.text,
      'subscribeNewsletter': _subscribeNewsletter,
      'priority': _priority,
      'submittedAt': DateTime.now().toIso8601String(),
    };

    final stopwatch = Stopwatch()..start();
    final (response, error) = await SClient.instance.post(
      url: 'https://httpbin.org/post',
      body: formData,
      clientType: clientType,
    );
    stopwatch.stop();

    setState(() {
      if (isHttp) {
        _isLoadingHttp = false;
        _httpDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _httpError = error.message;
        } else if (response != null) {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            try {
              final responseData = jsonDecode(response.body);
              _httpSubmissionResult = {
                'statusCode': response.statusCode,
                'submittedData': responseData['json'],
              };
            } catch (e) {
              _httpError = 'Failed to parse response: $e';
            }
          } else {
            _httpError = 'Server returned status ${response.statusCode}';
          }
        }
      } else {
        _isLoadingDio = false;
        _dioDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _dioError = error.message;
        } else if (response != null) {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            try {
              final responseData = jsonDecode(response.body);
              _dioSubmissionResult = {
                'statusCode': response.statusCode,
                'submittedData': responseData['json'],
              };
            } catch (e) {
              _dioError = 'Failed to parse response: $e';
            }
          } else {
            _dioError = 'Server returned status ${response.statusCode}';
          }
        }
      }
    });
  }

  Future<void> _submitBoth() async {
    if (!_formKey.currentState!.validate()) return;
    await Future.wait([
      _submitForm(clientType: ClientType.http),
      _submitForm(clientType: ClientType.dio),
    ]);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    setState(() {
      _subscribeNewsletter = false;
      _priority = 'normal';
      _httpSubmissionResult = null;
      _dioSubmissionResult = null;
      _httpError = null;
      _dioError = null;
      _httpDuration = null;
      _dioDuration = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Submission Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: Interactive Form Submission',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill in the form below and submit it using http_handler. '
              'The data will be sent to httpbin.org and echoed back.',
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.message),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Priority:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          RadioGroup<String>(
                            groupValue: _priority,
                            onChanged: (v) => setState(() => _priority = v!),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('Low'),
                                    value: 'low',
                                    dense: true,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('Normal'),
                                    value: 'normal',
                                    dense: true,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('High'),
                                    value: 'high',
                                    dense: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Subscribe to newsletter'),
                    value: _subscribeNewsletter,
                    onChanged: (v) =>
                        setState(() => _subscribeNewsletter = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingHttp
                              ? null
                              : () => _submitForm(clientType: ClientType.http),
                          icon: _isLoadingHttp
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.http, size: 18),
                          label: const Text('HTTP'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.blue.shade100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingDio
                              ? null
                              : () => _submitForm(clientType: ClientType.dio),
                          icon: _isLoadingDio
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.rocket_launch, size: 18),
                          label: const Text('Dio'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.green.shade100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_isLoadingHttp || _isLoadingDio)
                              ? null
                              : _submitBoth,
                          icon: (_isLoadingHttp || _isLoadingDio)
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.compare_arrows, size: 18),
                          label: const Text('Both'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_httpSubmissionResult != null ||
                _dioSubmissionResult != null ||
                _httpError != null ||
                _dioError != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildResultCard(
                      label: 'HTTP',
                      icon: Icons.http,
                      color: Colors.blue,
                      result: _httpSubmissionResult,
                      error: _httpError,
                      duration: _httpDuration,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildResultCard(
                      label: 'Dio',
                      icon: Icons.rocket_launch,
                      color: Colors.green,
                      result: _dioSubmissionResult,
                      error: _dioError,
                      duration: _dioDuration,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String label,
    required IconData icon,
    required Color color,
    required Map<String, dynamic>? result,
    required String? error,
    required int? duration,
  }) {
    if (error != null) {
      return Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (duration != null)
                    Text(
                      '${duration}ms',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700], size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (result != null) {
      return Card(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (duration != null)
                    Text(
                      '${duration}ms',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Status: ${result['statusCode']}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  const JsonEncoder.withIndent('  ')
                      .convert(result['submittedData']),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
