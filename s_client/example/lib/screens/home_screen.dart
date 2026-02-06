import 'package:flutter/material.dart';
import 'package:s_client_example/screens/basic_post_test_screen.dart';
import 'package:s_client_example/screens/custom_headers_test_screen.dart';
import 'package:s_client_example/screens/error_handling_test_screen.dart';
import 'package:s_client_example/screens/json_response_test_screen.dart';
import 'package:s_client_example/screens/form_submission_test_screen.dart';
import 'package:s_client_example/screens/get_request_test_screen.dart';
import 'package:s_client_example/screens/crud_operations_test_screen.dart';
import 'package:s_client_example/screens/retry_test_screen.dart';
import 'package:s_client_example/screens/typed_response_test_screen.dart';
import 'package:s_client_example/screens/reachability_test_screen.dart';
import 'package:s_client_example/screens/backend_switch_test_screen.dart';
import 'package:s_client_example/screens/interceptors_test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Tests'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'This app demonstrates the s_client package with support for both '
              'http and dio backends, interceptors, caching, and more.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const _SectionHeader(title: 'Basic Requests'),
          _TestCard(
            title: 'GET Request',
            description: 'Fetch data with query parameters',
            icon: Icons.download,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GetRequestTestScreen(),
              ),
            ),
          ),
          _TestCard(
            title: 'POST Request',
            description: 'Simple POST request with JSON body',
            icon: Icons.upload,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BasicPostTestScreen(),
              ),
            ),
          ),
          _TestCard(
            title: 'CRUD Operations',
            description: 'Test PUT, PATCH, DELETE methods',
            icon: Icons.build,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CrudOperationsTestScreen(),
              ),
            ),
          ),
          const _SectionHeader(title: 'Advanced Features'),
          _TestCard(
            title: 'Custom Headers',
            description: 'Request with custom headers',
            icon: Icons.settings,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomHeadersTestScreen(),
              ),
            ),
          ),
          _TestCard(
            title: 'Typed JSON Responses',
            description: 'Parse JSON into Dart models',
            icon: Icons.data_object,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TypedResponseTestScreen(),
              ),
            ),
          ),
          _TestCard(
            title: 'Retry with Backoff',
            description: 'Automatic retry with exponential backoff',
            icon: Icons.replay,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RetryTestScreen(),
              ),
            ),
          ),
          _TestCard(
            title: 'Reachability Check',
            description: 'Check if URLs are reachable',
            icon: Icons.wifi_find,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReachabilityTestScreen(),
              ),
            ),
          ),
          const _SectionHeader(title: 'Error & Validation'),
          _TestCard(
            title: 'Error Handling',
            description: 'Test error scenarios and exceptions',
            icon: Icons.error_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ErrorHandlingTestScreen(),
              ),
            ),
          ),
          _TestCard(
            title: 'JSON Response Parsing',
            description: 'Parse and display JSON data',
            icon: Icons.code,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JsonResponseTestScreen(),
              ),
            ),
          ),
          _TestCard(
            title: 'Form Submission',
            description: 'Interactive form with validation',
            icon: Icons.edit_document,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FormSubmissionTestScreen(),
              ),
            ),
          ),
          const _SectionHeader(title: 'Backend & Interceptors'),
          _TestCard(
            title: 'Backend Switching',
            description: 'Compare HTTP and Dio backends',
            icon: Icons.swap_horiz,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BackendSwitchTestScreen(),
              ),
            ),
          ),
          _TestCard(
            title: 'Interceptors',
            description: 'Test logging, caching, and auth',
            icon: Icons.layers,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InterceptorsTestScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
