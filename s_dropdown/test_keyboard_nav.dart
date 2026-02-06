import 'package:flutter/material.dart';
import 'package:s_dropdown/s_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDropdown Keyboard Navigation Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String? _selection1;
  String? _selection2;
  String? _selection3;

  final List<String> _items = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SDropdown Keyboard Navigation Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'With Keyboard Navigation (default):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SDropdown(
                items: _items,
                selectedItem: _selection1,
                hintText: 'Select a fruit',
                width: 300,
                height: 50,
                onChanged: (value) {
                  setState(() {
                    _selection1 = value;
                  });
                },
                // useKeyboardNavigation is true by default
              ),
              const SizedBox(height: 30),
              const Text(
                'Without Keyboard Navigation:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SDropdown(
                items: _items,
                selectedItem: _selection2,
                hintText: 'Select a fruit',
                width: 300,
                height: 50,
                onChanged: (value) {
                  setState(() {
                    _selection2 = value;
                  });
                },
                useKeyboardNavigation: false,
              ),
              const SizedBox(height: 30),
              const Text(
                'With auto-focus on init:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SDropdown(
                items: _items,
                selectedItem: _selection3,
                hintText: 'Select a fruit',
                width: 300,
                height: 50,
                onChanged: (value) {
                  setState(() {
                    _selection3 = value;
                  });
                },
                useKeyboardNavigation: true,
                requestFocusOnInit: true,
              ),
              const SizedBox(height: 30),
              const Text(
                'Keyboard shortcuts:\n'
                '• Arrow Down/Up: Navigate items\n'
                '• Enter/Space: Select item\n'
                '• Escape: Close dropdown',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
