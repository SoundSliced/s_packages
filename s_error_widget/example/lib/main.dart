import 'package:flutter/material.dart';
import 'package:s_error_widget/s_error_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error Widget Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  int _selectedExample = 0;

  List<Map<String, dynamic>> get _examples => [
        {
          'title': 'With Retry Action',
          'widget': SErrorWidget(
            headerText: 'Connection Failed',
            exceptionText: 'Unable to reach the server.',
            onRetry: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Retry initiated...')),
              );
            },
          ),
        },
        {
          'title': 'Custom Icon',
          'widget': const SErrorWidget(
            icon: Icon(Icons.wifi_off_rounded, size: 60, color: Colors.white),
            headerText: 'Offline',
            exceptionText: 'You are currently offline.',
            backgroundColor: Color(0xFF5C6BC0),
          ),
        },
        {
          'title': 'Constrained Size',
          'widget': Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const SErrorWidget(
                  headerText: 'Small Widget',
                  exceptionText: 'This widget fits in a 300x300 box.',
                  backgroundColor: Colors.teal,
                ),
              ),
            ),
          ),
        },
        {
          'title': 'Default Error Widget',
          'widget': const SErrorWidget(
            exceptionText:
                'An unexpected error occurred. Please try again later.',
          ),
        },
        {
          'title': 'Custom Header',
          'widget': const SErrorWidget(
            headerText: 'Oops! Something went wrong',
            exceptionText:
                'The server is currently unavailable. Please check your internet connection and try again.',
          ),
        },
        {
          'title': 'Custom Colors',
          'widget': const SErrorWidget(
            headerText: 'Connection Error',
            exceptionText:
                'Unable to connect to the server. Please check your network settings.',
            backgroundColor: Color(0xFFFF5252),
            headerTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            exceptionTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        },
        {
          'title': 'Custom Builder',
          'widget': SErrorWidget(
            headerText: 'Builder Example',
            exceptionText: 'This is a custom-built error message display.',
            backgroundColor: Colors.indigo,
            exceptionBuilder: (context, exceptionText) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.code, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      exceptionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        },
        {
          'title': 'Warning Style',
          'widget': const SErrorWidget(
            headerText: 'Warning',
            exceptionText:
                'This action cannot be undone. Please make sure you want to continue.',
            backgroundColor: Color(0xFFFFA726),
            headerTextStyle: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            exceptionTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
        },
        {
          'title': 'Dark Theme',
          'widget': const SErrorWidget(
            headerText: 'Critical Error',
            exceptionText:
                'A critical error has occurred in the application. The error has been logged and our team has been notified.',
            backgroundColor: Color(0xFF212121),
            headerTextStyle: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            exceptionTextStyle: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        },
        {
          'title': 'Long Error Message',
          'widget': const SErrorWidget(
            headerText: 'Detailed Error',
            exceptionText: '''Error Code: ERR_500
Message: Internal Server Error

The server encountered an unexpected condition that prevented it from fulfilling the request. This could be due to:
• Database connection failure
• Server overload
• Configuration error
• Third-party service unavailable

Please contact support if this problem persists.
Support ID: #12345-67890''',
            backgroundColor: Color(0xFF1976D2),
            headerTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            exceptionTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('SErrorWidget Examples'),
      ),
      body: Column(
        children: [
          // Example selector
          Container(
            height: 60,
            color: Colors.grey[200],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _examples.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedExample == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_examples[index]['title']),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedExample = index;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          // Preview area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _examples[_selectedExample]['widget'],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show info dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Current Example'),
              content: Text(_examples[_selectedExample]['title']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        tooltip: 'Info',
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}
