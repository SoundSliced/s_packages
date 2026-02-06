import 'package:flutter/material.dart';
import 'package:s_dropdown/s_dropdown.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'SDropdown Example',
        home: const ExampleHome(),
      );
    });
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  final List<String> _items = [
    'Apple',
    'Banana',
    'Cherry',
    'Durian',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
    'Kiwi',
    'Lemon',
    'Mango',
    'Nectarine',
    'Orange',
    'Papaya',
    'Quince',
    'Raspberry',
    'Strawberry',
    'Tangerine',
    'Ugli',
    'Vanilla Bean',
    'Watermelon',
    'Xigua',
    'Yuzu',
    'Zucchini',
    'Apricot',
    'Blackberry',
    'Cantaloupe',
    'Dragonfruit',
    'Eggplant'
  ];
  String? _selected;
  bool _excludeSelected = false; // Toggle for first dropdown
  final SDropdownController _controller = SDropdownController();
  final SDropdownController _controller2 = SDropdownController();
  final SDropdownController _controller3 = SDropdownController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SDropdown Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Intro
            const Text(
              'SDropdown showcase',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore different configurations, decoration, validation, and controller-driven actions. Use the controls below to interact with each dropdown overlay.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            // Basic usage section
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1) Basic usage',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SDropdown(
                                items: _items,
                                selectedItem: _selected,
                                hintText: 'Select a fruit',
                                onChanged: (value) {
                                  setState(() {
                                    _selected = value;
                                  });

                                  debugPrint('🔍 Selected: $value');
                                },
                                width: 280,
                                height: 52,
                                excludeSelected: _excludeSelected,
                                controller: _controller,
                              ),
                              const SizedBox(height: 8),
                              const Text('Plain dropdown with default overlay. '
                                  'Programmatic controls available on the right.\n'
                                  'Note: Toggle excludeSelected below to see the difference!'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('excludeSelected: '),
                                  Switch(
                                    value: _excludeSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        _excludeSelected = value;
                                        _controller.close();
                                      });
                                    },
                                  ),
                                  Text(
                                    _excludeSelected ? 'true' : 'false',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _excludeSelected
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _excludeSelected
                                        ? '(selected item hidden)'
                                        : '(selected item visible, autoscrolls)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Tooltip(
                              message:
                                  'Select item at bottom of list to test autoscroll',
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selected = 'Eggplant';
                                  });
                                },
                                icon: const Icon(Icons.agriculture),
                                label: const Text('Eggplant'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade100,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Tooltip(
                              message: 'Open overlay',
                              child: ElevatedButton.icon(
                                onPressed: () => _controller.open(),
                                icon: const Icon(Icons.arrow_drop_down_circle),
                                label: const Text('Open'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Tooltip(
                              message: 'Close overlay',
                              child: ElevatedButton.icon(
                                onPressed: () => _controller.close(),
                                icon: const Icon(Icons.close),
                                label: const Text('Close'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Tooltip(
                              message: 'Toggle overlay open/close',
                              child: ElevatedButton.icon(
                                onPressed: () => _controller.toggle(),
                                icon: const Icon(Icons.flip),
                                label: const Text('Toggle'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 24),

            // Decorated + overlay sizing
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2) Decoration + overlay sizing',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SDropdown(
                      items: _items,
                      selectedItem: _selected,
                      hintText: 'Decorated with specified overlay dimensions',
                      hintTextStyle:
                          const TextStyle(fontSize: 10, color: Colors.grey),
                      onChanged: (value) {
                        setState(() {
                          _selected = value;
                        });
                      },
                      width: 280,
                      height: 55,
                      overlayWidth: 350,
                      overlayHeight: 180,
                      excludeSelected: false,
                      decoration: SDropdownDecoration(
                        closedFillColor: Colors.grey.shade200,
                        expandedFillColor: Colors.white,
                        closedBorder: Border.all(color: Colors.grey.shade400),
                        expandedBorder:
                            Border.all(color: Colors.blue.shade700, width: 1.5),
                        closedBorderRadius: BorderRadius.circular(10),
                        expandedBorderRadius: BorderRadius.circular(8),
                        headerStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        hintStyle:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                        listItemStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Overrides overlay size (w:350, h:180). Styled header, hint, and list items.'),
                  ],
                ),
              ),
            ),

            const Divider(height: 24),

            // Exclude selected + custom display names
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('3) Exclude selected + custom item labels',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SDropdown(
                                items: _items,
                                selectedItem: _selected,
                                hintText: 'Exclude selected',
                                onChanged: (value) {
                                  setState(() {
                                    _selected = value;
                                  });
                                },
                                width: 260,
                                height: 48,
                                excludeSelected: true,
                                controller: _controller3,
                                customItemsNamesDisplayed: const [
                                  '🍎 Apple',
                                  '🍌 Banana',
                                  '🍒 Cherry',
                                  '💥 Durian',
                                  'Elderberry',
                                  'Fig',
                                  '🍇 Grape',
                                  'Honeydew',
                                  '🥝 Kiwi',
                                  '🍋 Lemon',
                                  '🥭 Mango',
                                  'Nectarine',
                                  '🍊 Orange',
                                  'Papaya',
                                  'Quince',
                                  '🍓 Raspberry',
                                  '🍓 Strawberry',
                                  '🍊 Tangerine',
                                  'Ugli',
                                  'Vanilla Bean',
                                  '🍉 Watermelon',
                                  'Xigua',
                                  'Yuzu',
                                  '🥒 Zucchini',
                                  '🍑 Apricot',
                                  '🫐 Blackberry',
                                  '🍈 Cantaloupe',
                                  'Dragonfruit',
                                  '🍆 Eggplant'
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                  'The currently selected item is hidden from the overlay list.'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _controller3.open(),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _controller3.highlightAtIndex(0),
                              icon: const Icon(Icons.highlight),
                              label: const Text('Highlight 0'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _controller3.selectIndex(2),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Select 2'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 24),

            // Selected text override
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('4) Selected text override',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    SDropdown(
                      items: ['Apple', 'Banana', 'Cherry', 'Durian'],
                      selectedItem: 'Apple',
                      selectedItemText: '🍎 Apple',
                      hintText: 'Selected text override',
                      width: 260,
                      height: 48,
                    ),
                    SizedBox(height: 8),
                    Text('Displays a friendly label for the selected value.'),
                  ],
                ),
              ),
            ),

            const Divider(height: 24),

            // Validator + item specific style + responsive sizing
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        '5) Validator + item styles + responsive sizing + Different overlay width',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Form(
                      child: SDropdown(
                        items: _items,
                        selectedItem: _selected,
                        hintText: 'With validator & item styles (60% width)',
                        onChanged: (value) {
                          setState(() {
                            _selected = value;
                          });
                        },
                        overlayWidth: 50.w,
                        width: 30.w,
                        height: 4.h,
                        excludeSelected: false,
                        validator: (v) => v == null ? 'Please select' : null,
                        validateOnChange: true,
                        itemSpecificStyles: const {
                          'Durian': TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Validates selection and applies custom style to Durian.'),
                  ],
                ),
              ),
            ),

            const Divider(height: 24),

            // Controller demonstration with programmatic navigation
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('6) Controller demo: navigate & select',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SDropdown(
                                items: _items,
                                hintText: 'Controller demo',
                                width: 260,
                                height: 48,
                                excludeSelected: false,
                                controller: _controller2,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tip: Use keyboard arrows to navigate, Enter to select.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        TapRegion(
                          groupId: _controller2.tapRegionGroupId,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _controller2.open(),
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Open'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _controller2.highlightNext(),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  label: const Text('Highlight Next'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _controller2.highlightPrevious(),
                                  icon: const Icon(Icons.keyboard_arrow_up),
                                  label: const Text('Highlight Previous'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _controller2.highlightAtIndex(2),
                                  icon: const Icon(Icons.filter_2),
                                  label: const Text('Highlight Index 2'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _controller2.highlightItem('Apple'),
                                  icon: const Icon(Icons.apple),
                                  label: const Text('Highlight Apple'),
                                ),
                                const SizedBox(height: 8),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _controller2.selectHighlighted(),
                                  icon: const Icon(Icons.done_all),
                                  label: const Text('Select highlighted'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _controller2.selectNext(),
                                  icon: const Icon(Icons.arrow_downward),
                                  label: const Text('Select next'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _controller2.selectPrevious(),
                                  icon: const Icon(Icons.arrow_upward),
                                  label: const Text('Select prev'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _controller2.selectIndex(1),
                                  icon: const Icon(Icons.looks_one),
                                  label: const Text('Select 1'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _controller2.selectItem('Cherry'),
                                  icon: const Icon(Icons.nature),
                                  label: const Text('Select Cherry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text('Selected value: ${_selected ?? "(none)"}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
