import 'package:flutter/material.dart';
import 'package:s_dropdown/s_dropdown.dart';

class SDropdownExampleScreen extends StatefulWidget {
  const SDropdownExampleScreen({super.key});

  @override
  State<SDropdownExampleScreen> createState() => _SDropdownExampleScreenState();
}

class _SDropdownExampleScreenState extends State<SDropdownExampleScreen> {
  final List<String> _fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Durian',
    'Elderberry',
    'Fig',
    'Grape',
  ];

  String? _selectedFruit;
  final SDropdownController _controller = SDropdownController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SDropdown Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'SDropdown Examples',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Basic dropdown
              const Text(
                'Basic Dropdown:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SDropdown(
                items: _fruits,
                selectedItem: _selectedFruit,
                hintText: 'Select a fruit',
                onChanged: (value) {
                  setState(() {
                    _selectedFruit = value;
                  });
                },
                width: 280,
                height: 52,
              ),
              const SizedBox(height: 32),

              // Decorated dropdown with custom styling
              const Text(
                'Decorated Dropdown:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SDropdown(
                items: _fruits,
                selectedItem: _selectedFruit,
                hintText: 'Pick your favorite',
                onChanged: (value) {
                  setState(() {
                    _selectedFruit = value;
                  });
                },
                width: 280,
                height: 52,
                overlayWidth: 280,
                overlayHeight: 200,
                decoration: SDropdownDecoration(
                  closedFillColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  expandedFillColor: Theme.of(context).colorScheme.surface,
                  closedBorder:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  expandedBorder: Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                  closedBorderRadius: BorderRadius.circular(8),
                  expandedBorderRadius: BorderRadius.circular(8),
                  headerStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Controller-based dropdown with programmatic control
              const Text(
                'Controller Example:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SDropdown(
                items: _fruits,
                selectedItem: _selectedFruit,
                hintText: 'Use buttons below',
                onChanged: (value) {
                  setState(() {
                    _selectedFruit = value;
                  });
                },
                width: 280,
                height: 52,
                controller: _controller,
                excludeSelected: false,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _controller.open(),
                    child: const Text('Open'),
                  ),
                  ElevatedButton(
                    onPressed: () => _controller.selectIndex(0),
                    child: const Text('Select First'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Display selected value
              if (_selectedFruit != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    'Selected: $_selectedFruit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
