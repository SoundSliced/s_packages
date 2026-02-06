import 'package:flutter/material.dart';
import 'package:s_error_widget/s_error_widget.dart';

class SErrorWidgetExampleScreen extends StatefulWidget {
  const SErrorWidgetExampleScreen({super.key});

  @override
  State<SErrorWidgetExampleScreen> createState() =>
      _SErrorWidgetExampleScreenState();
}

class _SErrorWidgetExampleScreenState extends State<SErrorWidgetExampleScreen> {
  int _selectedExample = 0;

  List<Map<String, dynamic>> get _examples => [
        {
          'title': 'With Retry',
          'widget': const _RetryExample(),
        },
        {
          'title': 'Custom Colors',
          'widget': Builder(
            builder: (context) => SErrorWidget(
              headerText: 'Connection Error',
              exceptionText:
                  'Unable to connect to the server. Please check your network.',
              backgroundColor: Theme.of(context).colorScheme.error,
              headerTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              exceptionTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontSize: 16,
              ),
            ),
          ),
        },
        {
          'title': 'Custom Icon',
          'widget': Builder(
            builder: (context) => SErrorWidget(
              icon: Icon(
                Icons.wifi_off_rounded,
                size: 60,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              headerText: 'Offline',
              exceptionText: 'You are currently offline.',
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SErrorWidget Example'),
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
                    label: Text(_examples[index]['title'] as String),
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
              child: _examples[_selectedExample]['widget'] as Widget,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryExample extends StatelessWidget {
  const _RetryExample();

  @override
  Widget build(BuildContext context) {
    return SErrorWidget(
      headerText: 'Connection Failed',
      exceptionText: 'Unable to reach the server.',
      onRetry: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Retry initiated...')),
        );
      },
    );
  }
}
