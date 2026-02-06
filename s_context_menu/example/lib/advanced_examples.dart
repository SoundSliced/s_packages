import 'package:flutter/material.dart';
import 'package:s_context_menu/s_context_menu.dart';

/// Example demonstrating advanced s_context_menu usage patterns
class AdvancedExamples extends StatefulWidget {
  const AdvancedExamples({super.key});

  @override
  State<AdvancedExamples> createState() => _AdvancedExamplesState();
}

class _AdvancedExamplesState extends State<AdvancedExamples> {
  int _itemCount = 3;
  final List<String> _selectedItems = [];
  final List<String> _actionLog = [];

  void _logAction(String action) {
    setState(() {
      _actionLog.add(
          '[${DateTime.now().toLocal().toString().split('.')[0]}] $action');
      // Keep only the last 50 actions
      if (_actionLog.length > 50) {
        _actionLog.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Multi-select Example
            Text(
              'Multi-Select List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ..._buildSelectableList(),
            const SizedBox(height: 24),

            // Dynamic Menu Example
            Text(
              'Dynamic Menu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildDynamicMenuExample(),
            const SizedBox(height: 24),

            // Custom Theme Example
            Text(
              'Custom Themed Menu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildCustomThemeExample(),
            const SizedBox(height: 24),

            // Action Log Display
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Action Log (${_actionLog.length}):',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _actionLog.clear()),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _actionLog.isEmpty
                        ? Center(
                            child: Text(
                              'No actions yet',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _actionLog.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final logEntry =
                                  _actionLog[_actionLog.length - 1 - index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  logEntry,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSelectableList() {
    return List.generate(_itemCount, (index) {
      final itemId = 'item_$index';
      final isSelected = _selectedItems.contains(itemId);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SContextMenu(
          buttons: [
            SContextMenuItem(
              label: isSelected ? 'Deselect' : 'Select',
              icon:
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              keepMenuOpen: true, // Menu stays open for quick multi-selection
              onPressed: () {
                setState(() {
                  if (isSelected) {
                    _selectedItems.remove(itemId);
                  } else {
                    _selectedItems.add(itemId);
                  }
                });
                _logAction(
                    'MultiSelect - Item ${index + 1} ${isSelected ? 'deselected' : 'selected'}');
              },
            ),
            SContextMenuItem(
              label: 'Delete',
              icon: Icons.delete,
              destructive: true,
              onPressed: () {
                setState(() {
                  _itemCount--;
                  _selectedItems.remove(itemId);
                });
                _logAction('MultiSelect - Item deleted');
              },
            ),
          ],
          onOpened: () =>
              _logAction('MultiSelect - Item ${index + 1} menu opened'),
          onDismissed: () =>
              _logAction('MultiSelect - Item ${index + 1} menu dismissed'),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Text('Item ${index + 1}'),
          ),
        ),
      );
    });
  }

  Widget _buildDynamicMenuExample() {
    return SContextMenu(
      buttons: [
        SContextMenuItem(
          label: 'Add Item',
          icon: Icons.add,
          onPressed: () {
            setState(() => _itemCount++);
            _logAction('Dynamic - Item added!');
          },
        ),
        if (_itemCount > 0)
          SContextMenuItem(
            label: 'Remove Item',
            icon: Icons.remove,
            onPressed: () {
              setState(() => _itemCount--);
              _logAction('Dynamic - Item removed!');
            },
          ),
        if (_selectedItems.isNotEmpty)
          SContextMenuItem(
            label: 'Clear Selection (${_selectedItems.length})',
            icon: Icons.clear_all,
            onPressed: () {
              setState(() => _selectedItems.clear());
              _logAction('Dynamic - Selection cleared!');
            },
          ),
      ],
      onOpened: () => _logAction('Dynamic Menu opened'),
      onDismissed: () => _logAction('Dynamic Menu dismissed'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text('Dynamic menu\nadapts to state'),
        ),
      ),
    );
  }

  Widget _buildCustomThemeExample() {
    return SContextMenu(
      theme: SContextMenuTheme(
        panelBorderRadius: 20,
        panelBlurSigma: 40,
        arrowShape: ArrowShape.curved,
        arrowBaseWidth: 16,
        arrowTipGap: 8,
        showDuration: const Duration(milliseconds: 300),
        hideDuration: const Duration(milliseconds: 200),
      ),
      buttons: [
        SContextMenuItem(
          label: 'Action 1',
          icon: Icons.star,
          onPressed: () => _logAction('CustomTheme - Action 1 pressed'),
        ),
        SContextMenuItem(
          label: 'Action 2',
          icon: Icons.favorite,
          onPressed: () => _logAction('CustomTheme - Action 2 pressed'),
        ),
      ],
      onOpened: () => _logAction('CustomTheme Menu opened'),
      onDismissed: () => _logAction('CustomTheme Menu dismissed'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.cyan.shade200, Colors.blue.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: const Center(
          child: Text(
            'Premium\nCustom Theme',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
