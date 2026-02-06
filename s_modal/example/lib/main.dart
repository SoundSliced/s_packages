import 'package:flutter/material.dart';
import 'package:s_ink_button/s_ink_button.dart';
import 'package:s_modal/s_modal.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_modal Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 's_modal Example'),
      builder: (context, child) => Modal.appBuilder(
        context,
        child,
        backgroundColor: Colors.black,
        borderRadius: BorderRadius.circular(24),
        showDebugPrints: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Alignment _selectedPosition = Alignment.bottomCenter;
  SnackbarDisplayMode _selectedDisplayMode = SnackbarDisplayMode.replace;
  String _selectedSnackbarType = 'Simple';
  int _snackbarCounter = 1;
  double? _snackbarWidth = 260.0; // null = default width

  // Snackbar Dismissal & Barrier Config
  bool _snackbarIsDismissible = true; // default: true
  Color _snackbarBarrierColor =
      Colors.transparent; // default: none (transparent)

  // Duration Indicator Config
  bool _showDurationTimer = true;
  DurationIndicatorDirection _durationTimerDirection =
      DurationIndicatorDirection.leftToRight;
  Color? _durationTimerColor;

  // Snackbar Offset Config (for 'With Offset' type) - using ValueNotifier for decoupled state
  late final ValueNotifier<SnackbarOffset> _snackbarOffsetNotifier =
      ValueNotifier(SnackbarOffset(offsetX: 100.0, offsetY: 260.0));

  @override
  void dispose() {
    _snackbarOffsetNotifier.dispose();
    super.dispose();
  }

  // Bottom Sheet Config
  String _selectedSheetContentType = 'Default';
  bool _sheetExpandable = false;
  SheetPosition _sheetPosition = SheetPosition.bottom;
  double _sheetSize = 300;
  // Sheet background color selector
  Color _sheetBackgroundColor = Colors.white;

  // Dialog Config
  String _selectedDialogType = 'Info';
  bool _dialogDraggable = false;
  bool _dialogWithOffset = false;

  // Global Modal Config
  bool _globalDismissable = true;
  bool _globalBlockBackgroundInteraction = false;
  Color _globalBarrierColor = Colors.black.withValues(alpha: 0.3);
  bool _globalBlur = true;
  double _globalBlurAmount = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Global Modal Settings Section
              Text(
                'Global Modal Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'These settings apply to all modals shown from configurators',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Dismissable on Background Tap'),
                        subtitle: Text(
                          _globalDismissable
                              ? 'Tapping background dismisses modal'
                              : 'Background tap does nothing',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        value: _globalDismissable,
                        onChanged: (value) {
                          setState(() {
                            _globalDismissable = value;
                          });
                          // Live update if any modal is active
                          if (Modal.isDialogActive) {
                            Modal.updateParams(
                                id: Modal.activeDialogId!,
                                isDismissable: value);
                          }
                          if (Modal.isSheetActive) {
                            Modal.updateParams(
                                id: Modal.activeSheetId!, isDismissable: value);
                          }
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Block Background Interaction'),
                        subtitle: Text(
                          _globalBlockBackgroundInteraction
                              ? 'Buttons behind modal are blocked'
                              : 'Buttons behind modal can still be tapped',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        value: _globalBlockBackgroundInteraction,
                        onChanged: (value) {
                          setState(() {
                            _globalBlockBackgroundInteraction = value;
                          });
                          // Live update if any modal is active
                          if (Modal.isDialogActive) {
                            Modal.updateParams(
                                id: Modal.activeDialogId!,
                                blockBackgroundInteraction: value);
                          }
                          if (Modal.isSheetActive) {
                            Modal.updateParams(
                                id: Modal.activeSheetId!,
                                blockBackgroundInteraction: value);
                          }
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Background Blur'),
                        value: _globalBlur,
                        onChanged: (value) {
                          setState(() {
                            _globalBlur = value;
                          });
                          // Live update if any modal is active
                          if (Modal.isDialogActive) {
                            Modal.updateParams(
                              id: Modal.activeDialogId!,
                              shouldBlurBackground: value,
                              blurAmount: value ? _globalBlurAmount : 0,
                            );
                          }
                          if (Modal.isSheetActive) {
                            Modal.updateParams(
                              id: Modal.activeSheetId!,
                              shouldBlurBackground: value,
                              blurAmount: value ? _globalBlurAmount : 0,
                            );
                          }
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_globalBlur)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Text('Blur Amount: '),
                              Expanded(
                                child: Slider(
                                  value: _globalBlurAmount.clamp(0.0, 10.0),
                                  min: 0.0,
                                  max: 10.0,
                                  onChanged: (value) {
                                    setState(() {
                                      _globalBlurAmount = value;
                                    });
                                    // Live update if any modal is active
                                    if (Modal.isDialogActive) {
                                      Modal.updateParams(
                                          id: Modal.activeDialogId!,
                                          blurAmount: value);
                                    }
                                    if (Modal.isSheetActive) {
                                      Modal.updateParams(
                                          id: Modal.activeSheetId!,
                                          blurAmount: value);
                                    }
                                  },
                                ),
                              ),
                              Text(_globalBlurAmount.toStringAsFixed(1)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text('Barrier Color',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildColorChoice(
                            color: Colors.black.withValues(alpha: 0.3),
                            label: 'Default',
                            selectedColor: _globalBarrierColor,
                            onSelect: (c) {
                              setState(() => _globalBarrierColor = c);
                              if (Modal.isDialogActive) {
                                Modal.updateParams(
                                    id: Modal.activeDialogId!, barrierColor: c);
                              }
                              if (Modal.isSheetActive) {
                                Modal.updateParams(
                                    id: Modal.activeSheetId!, barrierColor: c);
                              }
                            },
                          ),
                          _buildColorChoice(
                            color: Colors.blue.withValues(alpha: 0.3),
                            label: 'Blue',
                            selectedColor: _globalBarrierColor,
                            onSelect: (c) {
                              setState(() => _globalBarrierColor = c);
                              if (Modal.isDialogActive) {
                                Modal.updateParams(
                                    id: Modal.activeDialogId!, barrierColor: c);
                              }
                              if (Modal.isSheetActive) {
                                Modal.updateParams(
                                    id: Modal.activeSheetId!, barrierColor: c);
                              }
                            },
                          ),
                          _buildColorChoice(
                            color: Colors.red.withValues(alpha: 0.3),
                            label: 'Red',
                            selectedColor: _globalBarrierColor,
                            onSelect: (c) {
                              setState(() => _globalBarrierColor = c);
                              if (Modal.isDialogActive) {
                                Modal.updateParams(
                                    id: Modal.activeDialogId!, barrierColor: c);
                              }
                              if (Modal.isSheetActive) {
                                Modal.updateParams(
                                    id: Modal.activeSheetId!, barrierColor: c);
                              }
                            },
                          ),
                          _buildColorChoice(
                            color: Colors.transparent,
                            label: 'None',
                            selectedColor: _globalBarrierColor,
                            onSelect: (c) {
                              setState(() => _globalBarrierColor = c);
                              if (Modal.isDialogActive) {
                                Modal.updateParams(
                                    id: Modal.activeDialogId!, barrierColor: c);
                              }
                              if (Modal.isSheetActive) {
                                Modal.updateParams(
                                    id: Modal.activeSheetId!, barrierColor: c);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sheet Configurator Section (unified for all sheet types)
              Text(
                'Sheet Configurator',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Position Selector (Top, Bottom, Left, Right)
                      Text('Position',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SheetPosition.values.map((position) {
                          return ChoiceChip(
                            label: Text(position.name.toUpperCase()),
                            selected: _sheetPosition == position,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _sheetPosition = position);
                                // Live update if any sheet is active
                                if (Modal.isSheetActive ||
                                    Modal.isSideSheetActive ||
                                    Modal.isTopSheetActive) {
                                  _showConfiguredSheet();
                                }
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Content Type Selector
                      Text('Content Type',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Default',
                          'Menu',
                          'Settings',
                          'Profile',
                          'Custom',
                          'List'
                        ].map((type) {
                          return ChoiceChip(
                            label: Text(type),
                            selected: _selectedSheetContentType == type,
                            onSelected: (selected) {
                              if (selected) {
                                setState(
                                    () => _selectedSheetContentType = type);
                                // Live update if any sheet is active
                                if (Modal.isSheetActive ||
                                    Modal.isSideSheetActive ||
                                    Modal.isTopSheetActive) {
                                  _showConfiguredSheet();
                                }
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Size Slider
                      Text(
                          _sheetPosition == SheetPosition.left ||
                                  _sheetPosition == SheetPosition.right
                              ? 'Width'
                              : 'Height',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _sheetSize,
                              min: 150,
                              max: 500,
                              divisions: 14,
                              label: '${_sheetSize.toInt()}px',
                              onChanged: (value) {
                                setState(() => _sheetSize = value);
                                // Update the active sheet size in real-time
                                if (Modal.isSheetActive ||
                                    Modal.isSideSheetActive ||
                                    Modal.isTopSheetActive) {
                                  Modal.updateParams(
                                    id: 'configured-sheet',
                                    size: value,
                                  );
                                }
                              },
                            ),
                          ),
                          Text('${_sheetSize.toInt()}px'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Expandable Toggle
                      SwitchListTile(
                        title: const Text('Expandable'),
                        subtitle: Text(_sheetExpandable
                            ? 'Can expand by dragging'
                            : 'Fixed size'),
                        value: _sheetExpandable,
                        onChanged: (value) {
                          setState(() => _sheetExpandable = value);
                          if (Modal.isSheetActive ||
                              Modal.isSideSheetActive ||
                              Modal.isTopSheetActive) {
                            Modal.updateParams(
                              id: 'configured-sheet',
                              isExpandable: value,
                              expandedPercentageSize: value ? 85.0 : 0.0,
                            );
                          }
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),

                      // Background Color Selector
                      Text('Background Color',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildColorChoice(
                            color: Colors.white,
                            label: 'White',
                            selectedColor: _sheetBackgroundColor,
                            onSelect: (c) {
                              setState(() => _sheetBackgroundColor = c);
                              // Live update if configured sheet is open
                              Modal.updateParams(
                                  id: 'configured-sheet', backgroundColor: c);
                            },
                          ),
                          _buildColorChoice(
                            color: Colors.grey.shade50,
                            label: 'Light',
                            selectedColor: _sheetBackgroundColor,
                            onSelect: (c) {
                              setState(() => _sheetBackgroundColor = c);
                              Modal.updateParams(
                                  id: 'configured-sheet', backgroundColor: c);
                            },
                          ),
                          _buildColorChoice(
                            color: Colors.blue.shade50,
                            label: 'Blue',
                            selectedColor: _sheetBackgroundColor,
                            onSelect: (c) {
                              setState(() => _sheetBackgroundColor = c);
                              Modal.updateParams(
                                  id: 'configured-sheet', backgroundColor: c);
                            },
                          ),
                          _buildColorChoice(
                            color: Colors.green.shade50,
                            label: 'Green',
                            selectedColor: _sheetBackgroundColor,
                            onSelect: (c) {
                              setState(() => _sheetBackgroundColor = c);
                              Modal.updateParams(
                                  id: 'configured-sheet', backgroundColor: c);
                            },
                          ),
                          _buildColorChoice(
                            color: Colors.purple.shade50,
                            label: 'Purple',
                            selectedColor: _sheetBackgroundColor,
                            onSelect: (c) {
                              setState(() => _sheetBackgroundColor = c);
                              Modal.updateParams(
                                  id: 'configured-sheet', backgroundColor: c);
                            },
                          ),
                          _buildColorChoice(
                            color: Colors.amber.shade50,
                            label: 'Amber',
                            selectedColor: _sheetBackgroundColor,
                            onSelect: (c) {
                              setState(() => _sheetBackgroundColor = c);
                              Modal.updateParams(
                                  id: 'configured-sheet', backgroundColor: c);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Show Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(_getSheetIcon(_sheetPosition)),
                          label: Text(
                              'SHOW ${_getSheetTypeName(_sheetPosition).toUpperCase()}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _showConfiguredSheet,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Dialog Configurator Section
              Text(
                'Dialog Configurator',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Selector
                      Text('Content Type',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Info', 'Confirm', 'Form', 'Callbacks']
                            .map((type) {
                          return ChoiceChip(
                            label: Text(type),
                            selected: _selectedDialogType == type,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedDialogType = type);
                                // Live update if dialog is active
                                if (Modal.isDialogActive) {
                                  _showConfiguredDialog();
                                }
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Options (live-update active dialog)
                      Text('Options',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Draggable'),
                        value: _dialogDraggable,
                        onChanged: (value) {
                          setState(() {
                            _dialogDraggable = value;
                          });
                          // Live update if dialog is active
                          if (Modal.isDialogActive) {
                            Modal.updateParams(
                                id: 'configured-dialog', isDraggable: value);
                          }
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('With Offset'),
                        subtitle: Text(_dialogWithOffset
                            ? 'Dialog positioned with offset (50, 30)'
                            : 'Dialog uses default position'),
                        value: _dialogWithOffset,
                        onChanged: (value) {
                          setState(() {
                            _dialogWithOffset = value;
                          });
                          // Live update if dialog is active
                          if (Modal.isDialogActive) {
                            Modal.updateParams(
                              id: 'configured-dialog',
                              offset: value ? const Offset(50, 30) : null,
                            );
                          }
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),

                      // Show Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat_bubble),
                          label: const Text('SHOW DIALOG'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _showConfiguredDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Snackbar Configurator Section
              Text(
                'Snackbar Configurator',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Position Selector (hidden when 'With Offset' is selected since offset replaces alignment)
                      if (_selectedSnackbarType != 'With Offset') ...[
                        Text('Position',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildPositionSelector(),
                        const SizedBox(height: 16),
                      ],

                      // Display Mode Selector
                      Text('Display Mode',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SnackbarDisplayMode.values.map((mode) {
                          return ChoiceChip(
                            label: Text(mode.name),
                            selected: _selectedDisplayMode == mode,
                            onSelected: (selected) {
                              if (selected) {
                                // Dismiss all snackbars when changing display mode
                                Modal.dismissAllSnackbars();
                                setState(() => _selectedDisplayMode = mode);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Type Selector
                      Text('Content Type',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Simple',
                          'Success',
                          'Error',
                          'Custom',
                          'With Offset'
                        ].map((type) {
                          return ChoiceChip(
                            label: Text(type),
                            selected: _selectedSnackbarType == type,
                            onSelected: (selected) {
                              if (selected) {
                                // Dismiss all snackbars when changing content type
                                Modal.dismissAllSnackbars();
                                setState(() => _selectedSnackbarType = type);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Offset Controls (only show when 'With Offset' is selected)
                      // Replaces the alignment-based Position selector
                      if (_selectedSnackbarType == 'With Offset') ...[
                        Text('Position (Offset)',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text(
                          'Drag the pin to set snackbar position',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Draggable Position Picker
                        _buildOffsetPositionPicker(),
                        const SizedBox(height: 8),
                        // Show current coordinates
                        ValueListenableBuilder<SnackbarOffset>(
                          valueListenable: _snackbarOffsetNotifier,
                          builder: (context, offset, _) => Text(
                            'Position: (${offset.offsetX.toInt()}, ${offset.offsetY.toInt()})',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Duration Indicator Settings
                      Text('Duration Indicator',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),

                      // Show/Hide Toggle
                      SwitchListTile(
                        title: const Text('Show Duration Timer'),
                        subtitle: const Text('Linear progress bar at bottom'),
                        value: _showDurationTimer,
                        onChanged: (value) {
                          setState(() => _showDurationTimer = value);
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),

                      // Direction selector (only show if timer is enabled)
                      if (_showDurationTimer) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Direction: '),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 110,
                              child: ChoiceChip(
                                label: const Text('← Left'),
                                selected: _durationTimerDirection ==
                                    DurationIndicatorDirection.leftToRight,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _durationTimerDirection =
                                        DurationIndicatorDirection.leftToRight);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 110,
                              child: ChoiceChip(
                                label: const Text('Right →'),
                                selected: _durationTimerDirection ==
                                    DurationIndicatorDirection.rightToLeft,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _durationTimerDirection =
                                        DurationIndicatorDirection.rightToLeft);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Color selector
                        Row(
                          children: [
                            const Text('Color: '),
                            const SizedBox(width: 8),
                            _buildColorChip(null, 'Default'),
                            const SizedBox(width: 4),
                            _buildColorChip(Colors.grey.shade300, 'Grey'),
                            const SizedBox(width: 4),
                            _buildColorChip(Colors.cyan, 'Cyan'),
                            const SizedBox(width: 4),
                            _buildColorChip(Colors.pink, 'Pink'),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Width Slider
                      Text('Snackbar Width',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _snackbarWidth ?? 260.0, // 260 = default
                              min: 260.0,
                              max: 600.0,
                              divisions: 17,
                              label: _snackbarWidth == null ||
                                      _snackbarWidth == 260.0
                                  ? 'Default'
                                  : '${_snackbarWidth!.toInt()}px',
                              onChanged: (value) {
                                setState(() {
                                  // 260 means default (null)
                                  _snackbarWidth =
                                      value == 260.0 ? 260.0 : value;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              _snackbarWidth == null
                                  ? 'Default'
                                  : '${_snackbarWidth!.toInt()}px',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Dismissible Toggle
                      SwitchListTile(
                        title: const Text('Dismissible'),
                        subtitle: Text(
                          _snackbarIsDismissible
                              ? 'Can be swiped to dismiss'
                              : 'Cannot be dismissed (no auto-dismiss)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        value: _snackbarIsDismissible,
                        onChanged: (value) {
                          setState(() => _snackbarIsDismissible = value);
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      const SizedBox(height: 16),

                      // Barrier Color Selector
                      Text('Barrier Color',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBarrierColorChip(
                              Colors.transparent, 'None', true),
                          const SizedBox(width: 4),
                          _buildBarrierColorChip(
                              Colors.black.withValues(alpha: 0.3),
                              'Black',
                              false),
                          const SizedBox(width: 4),
                          _buildBarrierColorChip(
                              Colors.blue.withValues(alpha: 0.2),
                              'Blue',
                              false),
                          const SizedBox(width: 4),
                          _buildBarrierColorChip(
                              Colors.red.withValues(alpha: 0.2), 'Red', false),
                          const SizedBox(width: 4),
                          _buildBarrierColorChip(
                              Colors.green.withValues(alpha: 0.2),
                              'Green',
                              false),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Show Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.visibility),
                          label: const Text('SHOW SNACKBAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _showConfiguredSnackbar,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Modal Mixing Configurator Section
              Text(
                'Modal Mixing Configurator',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test how different modal types interact',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bottom Sheet + Snackbar
                      GestureDetector(
                        onTap: () =>
                            _showMixedModalDemo('BottomSheet + Snackbar'),
                        child: _buildCardButton(
                          icon: Icons.layers,
                          text: 'Bottom Sheet + Snackbar',
                          subtitle: 'Show sheet, then trigger snackbar',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dialog + Snackbar
                      GestureDetector(
                        onTap: () => _showMixedModalDemo('Dialog + Snackbar'),
                        child: _buildCardButton(
                          icon: Icons.chat_bubble,
                          text: 'Dialog + Snackbar',
                          subtitle: 'Show dialog, then trigger snackbar',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Snackbar + Bottom Sheet
                      GestureDetector(
                        onTap: () =>
                            _showMixedModalDemo('Snackbar + Bottom Sheet'),
                        child: _buildCardButton(
                          icon: Icons.vertical_align_bottom,
                          text: 'Snackbar + Bottom Sheet',
                          subtitle:
                              'Show snackbar, then automatically open bottomsheet',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Snackbar with Modal Buttons
                      GestureDetector(
                        onTap: () =>
                            _showMixedModalDemo('Snackbar with Modal Buttons'),
                        child: _buildCardButton(
                          icon: Icons.touch_app,
                          text: 'Snackbar with Modal Buttons',
                          subtitle: 'Snackbar with buttons to open modals',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Side Sheet + Snackbar
                      GestureDetector(
                        onTap: () =>
                            _showMixedModalDemo('SideSheet + Snackbar'),
                        child: _buildCardButton(
                          icon: Icons.view_sidebar,
                          text: 'Side Sheet + Snackbar',
                          subtitle: 'Show side sheet, then trigger snackbar',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Reactive State Examples Section
              Text(
                'Reactive State Examples',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Demo Type',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),

                      // Reactive Counter Modal using ModalBuilder (with hot reload)
                      ModalBuilder(
                        builder: () => _buildReactiveCounterContent(),
                        size: 350,
                        shouldBlurBackground: _globalBlur,
                        isDismissable: _globalDismissable,
                        blockBackgroundInteraction:
                            _globalBlockBackgroundInteraction,
                        child: _buildCardButton(
                          icon: Icons.add_circle,
                          text: 'Reactive Counter (ModalBuilder)',
                          subtitle: 'Uses ModalBuilder with hot reload support',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Reactive Counter Modal using Modal.show()
                      GestureDetector(
                        onTap: _showReactiveCounterWithModalShow,
                        child: _buildCardButton(
                          icon: Icons.refresh,
                          text: 'Reactive Counter (Modal.show)',
                          subtitle: 'Uses Modal.show() with OnReactive',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Reactive Form Modal
                      ModalBuilder.dialog(
                        builder: () => _buildReactiveFormContent(),
                        size: 400,
                        shouldBlurBackground: _globalBlur,
                        isDismissable: _globalDismissable,
                        blockBackgroundInteraction:
                            _globalBlockBackgroundInteraction,
                        child: _buildCardButton(
                          icon: Icons.edit,
                          text: 'Reactive Form Dialog',
                          subtitle: 'Form validation with reactive state',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Live Update Examples Section
              Text(
                'Live Update Examples',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modal.updateParams() Demos',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Update modal properties live without recreation',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dynamic Parameter Updates
                      GestureDetector(
                        onTap: _showDynamicBottomSheet,
                        child: _buildCardButton(
                          icon: Icons.tune,
                          text: 'Dynamic Bottom Sheet Updates',
                          subtitle: 'Blur, height, color, dismissable',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Modal Type Morphing
                      GestureDetector(
                        onTap: _showMorphingModal,
                        child: _buildCardButton(
                          icon: Icons.transform,
                          text: 'Modal Type Morphing',
                          subtitle: 'Switch between bottom sheet and dialog',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Position Animation
                      GestureDetector(
                        onTap: _showPositionUpdatingDialog,
                        child: _buildCardButton(
                          icon: Icons.open_with,
                          text: 'Dialog Position Updates',
                          subtitle: 'Move dialog to different positions',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Snackbar Live Updates
                      GestureDetector(
                        onTap: _showLiveUpdatingSnackbar,
                        child: _buildCardButton(
                          icon: Icons.notifications_active,
                          text: 'Live Updating Snackbar',
                          subtitle: 'Countdown with color changes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Overlay Widgets Showcase Section
              Text(
                'Overlay Widgets Showcase',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Widgets requiring Overlay ancestor',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Demonstrates Slider, TextField, DropdownButton working correctly inside modals',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slider in Bottom Sheet
                      GestureDetector(
                        onTap: _showSliderBottomSheet,
                        child: _buildCardButton(
                          icon: Icons.linear_scale,
                          text: 'Slider in Bottom Sheet',
                          subtitle: 'Slider with value indicator tooltip',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // TextField in Dialog
                      GestureDetector(
                        onTap: _showTextFieldDialog,
                        child: _buildCardButton(
                          icon: Icons.text_fields,
                          text: 'TextField in Dialog',
                          subtitle: 'Text input with autocomplete',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // DropdownButton in Bottom Sheet
                      GestureDetector(
                        onTap: _showDropdownBottomSheet,
                        child: _buildCardButton(
                          icon: Icons.arrow_drop_down_circle,
                          text: 'DropdownButton in Bottom Sheet',
                          subtitle: 'Dropdown menu displays correctly',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Combined Widgets Demo
                      GestureDetector(
                        onTap: _showCombinedWidgetsDialog,
                        child: _buildCardButton(
                          icon: Icons.widgets,
                          text: 'Combined Widgets Demo',
                          subtitle: 'All overlay widgets in one modal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a consistent button style for card sections
  Widget _buildCardButton({
    required IconData icon,
    required String text,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  // ============================================
  // Builder methods for modal content (hot-reloadable!)
  // ============================================

  /// Builds blurred bottom sheet content
  // ignore: unused_element
  Widget _buildBlurredBottomSheetContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.blur_on, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Blurred Background',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Notice how the content behind is blurred! This creates a nice depth effect.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Modal.dismissBottomSheet(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Builds custom blur slider content
  Widget _buildCustomBlurContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.tune, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blur Intensity',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Adjust background blur effect',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Blur value display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.blur_on,
                        color: Colors.purple.shade400, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      _globalBlurAmount.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'px',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.purple.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Slider with labels
              Row(
                children: [
                  Text('0',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.purple.shade400,
                        inactiveTrackColor: Colors.purple.shade100,
                        thumbColor: Colors.purple.shade600,
                        overlayColor: Colors.purple.withValues(alpha: 0.2),
                        trackHeight: 6,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        value: _globalBlurAmount,
                        min: 0.0,
                        max: 15.0,
                        onChanged: (value) {
                          setModalState(() => _globalBlurAmount = value);
                          setState(() => _globalBlurAmount = value);
                          Modal.updateParams(
                              id: 'configured-bottom-sheet', blurAmount: value);
                        },
                      ),
                    ),
                  ),
                  Text('15',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 28),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple.shade600,
                        side: BorderSide(color: Colors.purple.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setModalState(() => _globalBlurAmount = 3.0);
                        setState(() => _globalBlurAmount = 3.0);
                        Modal.updateParams(
                            id: 'configured-bottom-sheet', blurAmount: 3.0);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Modal.dismissBottomSheet(),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds expandable sheet content
  Widget _buildExpandableSheetContent() {
    return ListView(
      shrinkWrap: true,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Drag Up to Expand',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...List.generate(
          8,
          (index) => ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text('Option ${index + 1}'),
            subtitle: const Text('Select this option'),
            onTap: () {
              Modal.dismissBottomSheet();
            },
          ),
        ),
      ],
    );
  }

  /// Builds the dialog content - extracted to a method for hot reload support
  Widget _buildDialogContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'This is a dialog modal. It appears centered on the screen.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Modal.dismissDialog(),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds confirmation dialog content
  Widget _buildConfirmationDialogContent() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.black.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.question_mark, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Confirm Action',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to proceed with this action?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Modal.dismissDialog();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Modal.dismissDialog();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds callbacks demo content
  Widget _buildCallbacksContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Callbacks Demo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Icon(Icons.notifications_active, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const SizedBox(height: 12),
          const Text(
            'Close this dialog to trigger onDismiss callback',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'The example callback calls to show a Modal snackbar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => Modal.dismissDialog(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Snackbar Examples
  // ============================================

  /// Builds a success snackbar
  Widget _buildSuccessSnackbarContent(String snackbarId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Success!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your changes have been saved',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Modal.dismissById(snackbarId),
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an error snackbar
  Widget _buildErrorSnackbarContent(String snackbarId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Something went wrong. Please try again.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Modal.dismissById(snackbarId),
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a snackbar with action button
  Widget _buildActionSnackbarContent(String snackbarId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Item deleted',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () {
                // Dismiss this specific snackbar by its ID
                Modal.dismissById(snackbarId);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'UNDO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // Mixed Modal Demo Builders (for hot reload support)
  // ============================================

  /// Builds the bottom sheet content for 'BottomSheet + Snackbar' demo
  Widget _buildBottomSheetWithSnackbarContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.layers, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Bottom Sheet Actives',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Now click the button below to show a snackbar on top!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.notifications),
            label: const Text('Show Snackbar'),
            onPressed: () {
              Modal.showSnackbar(
                text: 'I am a snackbar on top of the bottom sheet!',
                position: Alignment.topCenter,
                backgroundColor: Colors.blue.shade800,
                duration: const Duration(seconds: 3),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Modal.dismissBottomSheet(),
            child: const Text('Close Sheet'),
          ),
        ],
      ),
    );
  }

  /// Builds the dialog content for 'Dialog + Snackbar' demo
  Widget _buildDialogWithSnackbarContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble, size: 48, color: Colors.purple),
          const SizedBox(height: 16),
          Text(
            'Dialog Active',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Click below to show a snackbar. It should appear above this dialog.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.notifications),
            label: const Text('Show Snackbar'),
            onPressed: () {
              Modal.showSnackbar(
                text: 'I am a snackbar on top of the dialog!',
                position: Alignment.bottomCenter,
                backgroundColor: Colors.purple.shade800,
                duration: const Duration(seconds: 3),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Modal.dismissDialog(),
            child: const Text('Close Dialog'),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom sheet content for 'Snackbar + Bottom Sheet' demo
  Widget _buildBottomSheetAfterSnackbarContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.vertical_align_bottom,
              size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Bottom Sheet Opened',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'The snackbar should still be visible (or have finished).',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Modal.dismissBottomSheet(),
            child: const Text('Close Sheet'),
          ),
        ],
      ),
    );
  }

  /// Builds bottom sheet content opened from snackbar button
  Widget _buildBottomSheetFromSnackbarContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.layers, size: 48, color: Colors.indigo),
          const SizedBox(height: 16),
          Text(
            'Opened from Snackbar!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'This bottom sheet was triggered by a snackbar button. The snackbar should still be visible above.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Modal.dismissBottomSheet(),
            child: const Text('Close Sheet'),
          ),
        ],
      ),
    );
  }

  /// Builds dialog content opened from snackbar button
  Widget _buildDialogFromSnackbarContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble, size: 48, color: Colors.indigo),
          const SizedBox(height: 16),
          Text(
            'Opened from Snackbar!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'This dialog was triggered by a snackbar button. The snackbar should still be visible.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Modal.dismissDialog(),
            child: const Text('Close Dialog'),
          ),
        ],
      ),
    );
  }

  /// Builds the interactive snackbar content with modal buttons
  Widget _buildInteractiveSnackbarContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.touch_app, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Snackbar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap a button to open a modal',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Modal.dismissById('snackbar_with_buttons'),
                child: const Icon(Icons.close, color: Colors.white70, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.vertical_align_bottom, size: 18),
                  label: const Text('Bottom Sheet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Show bottom sheet - snackbar stays visible!
                    Modal.show(
                      id: 'bottom-sheet-from-snackbar',
                      builder: () => _buildBottomSheetFromSnackbarContent(),
                      modalType: ModalType.sheet,
                      size: 300,
                      shouldBlurBackground: _globalBlur,
                      isDismissable: _globalDismissable,
                      blockBackgroundInteraction:
                          _globalBlockBackgroundInteraction,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble, size: 18),
                  label: const Text('Dialog'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Show dialog - snackbar stays visible!
                    Modal.show(
                      id: 'dialog-from-snackbar',
                      builder: () => _buildDialogFromSnackbarContent(),
                      modalType: ModalType.dialog,
                      modalPosition: Alignment.center,
                      shouldBlurBackground: _globalBlur,
                      isDismissable: _globalDismissable,
                      blockBackgroundInteraction:
                          _globalBlockBackgroundInteraction,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the side sheet content for 'SideSheet + Snackbar' demo
  Widget _buildSideSheetWithSnackbarContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.view_sidebar,
                    size: 32, color: Colors.teal.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Side Sheet Active',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Slides in from the side!',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Click the button below to show a snackbar. The side sheet remains visible!',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.notifications),
              label: const Text('Show Snackbar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Modal.showSnackbar(
                  text: 'I am a snackbar on top of the side sheet!',
                  position: Alignment.topCenter,
                  backgroundColor: Colors.teal.shade800,
                  duration: const Duration(seconds: 3),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Modal.dismissSideSheet(),
              child: const Text('Close Side Sheet'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Reactive State Examples (using states_rebuilder)
  // ============================================

  /// Builds reactive counter content using states_rebuilder
  /// The counter state is managed by ReactiveModel and rebuilds automatically
  Widget _buildReactiveCounterContent() {
    // Create a local reactive state for the counter
    final counter = 0.inj();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_circle, size: 48, color: Colors.purple),
          const SizedBox(height: 16),
          Text(
            'Reactive Counter',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'This counter updates in real-time using states_rebuilder!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // OnReactive automatically rebuilds when counter changes
          OnReactive(
            () => Text(
              '${counter.state}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, size: 40),
                onPressed: () => counter.state--,
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 40),
                onPressed: () => counter.state++,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Modal.dismissBottomSheet(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Demonstrates reactive state with Modal.show() - the key is wrapping
  /// the content with reactive state management
  void _showReactiveCounterWithModalShow() {
    // The counter state lives OUTSIDE the builder, but the builder
    // uses OnReactive to subscribe and rebuild when it changes
    final counter = 0.inj();

    Modal.show(
      builder: () => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, size: 48, color: Colors.teal),
            const SizedBox(height: 16),
            Builder(
              builder: (context) => Text(
                'Modal.show() Reactive',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Even with Modal.show(), you can have reactive state!\n'
              'Just wrap reactive widgets with OnReactive.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // OnReactive subscribes to counter and rebuilds
            OnReactive(
              () => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  'Count: ${counter.state}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                  onPressed: () => counter.state--,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                  onPressed: () => counter.state++,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Modal.dismissBottomSheet(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
      size: 420,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
    );
  }

  /// Builds a reactive form dialog demonstrating form state management
  Widget _buildReactiveFormContent() {
    final name = ''.inj();
    final email = ''.inj();
    final isValid = false.inj();

    void validateForm() {
      isValid.state = name.state.isNotEmpty &&
          email.state.contains('@') &&
          email.state.contains('.');
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 330,
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, size: 48, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                'Reactive Form',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  name.state = value;
                  validateForm();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  email.state = value;
                  validateForm();
                },
              ),
              const SizedBox(height: 24),
              OnReactive(
                () => Column(
                  children: [
                    Text(
                      isValid.state
                          ? '✓ Form is valid'
                          : '✗ Please fill all fields',
                      style: TextStyle(
                        color: isValid.state ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isValid.state
                          ? () {
                              Modal.dismissDialog();
                            }
                          : null,
                      child: const Text('Submit'),
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

  // ============================================
  // Live Update Examples (Modal.updateParams)
  // ============================================

  /// Demonstrates dynamic parameter updates on a bottom sheet
  void _showDynamicBottomSheet() {
    double currentBlur = 0.0;
    double currentHeight = 250.0;
    bool isDismissable = true;
    Color currentBgColor = Colors.white;

    final colors = [
      Colors.white,
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.orange.shade50,
      Colors.purple.shade50,
    ];
    int colorIndex = 0;

    Modal.show(
      id: 'dynamic_sheet',
      builder: () => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dynamic Updates Demo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All changes happen live without modal recreation!',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // Blur slider
                Row(
                  children: [
                    const Icon(Icons.blur_on, size: 20),
                    const SizedBox(width: 8),
                    const Text('Blur: '),
                    Expanded(
                      child: Slider(
                        value: currentBlur,
                        min: 0,
                        max: 15,
                        onChanged: (value) {
                          setModalState(() => currentBlur = value);
                          Modal.updateParams(
                            id: 'dynamic_sheet',
                            blurAmount: value,
                            shouldBlurBackground: value > 0,
                          );
                        },
                      ),
                    ),
                    Text(currentBlur.toStringAsFixed(1)),
                  ],
                ),

                // Height slider
                Row(
                  children: [
                    const Icon(Icons.height, size: 20),
                    const SizedBox(width: 8),
                    const Text('Height: '),
                    Expanded(
                      child: Slider(
                        value: currentHeight,
                        min: 200,
                        max: 500,
                        onChanged: (value) {
                          setModalState(() => currentHeight = value);
                          Modal.updateParams(id: 'dynamic_sheet', size: value);
                        },
                      ),
                    ),
                    Text('${currentHeight.toInt()}'),
                  ],
                ),

                // Dismissable toggle
                SwitchListTile(
                  title: const Text('Dismissable'),
                  subtitle: Text(isDismissable
                      ? 'Tap outside to close'
                      : 'Must use button to close'),
                  value: isDismissable,
                  onChanged: (value) {
                    setModalState(() => isDismissable = value);
                    Modal.updateParams(
                        id: 'dynamic_sheet', isDismissable: value);
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                // Background color button
                Row(
                  children: [
                    const Text('Background: '),
                    const SizedBox(width: 8),
                    ...colors.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            colorIndex = entry.key;
                            currentBgColor = entry.value;
                          });
                          Modal.updateParams(
                              id: 'dynamic_sheet',
                              backgroundColor: entry.value);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: entry.value,
                            border: Border.all(
                              color: colorIndex == entry.key
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: colorIndex == entry.key ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Modal.dismissBottomSheet(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      modalType: ModalType.sheet,
      size: currentHeight,
      backgroundColor: currentBgColor,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
    );
  }

  /// Demonstrates changing modal type dynamically (morphing)
  void _showMorphingModal() {
    ModalType currentType = ModalType.sheet;
    int morphCount = 0;

    void showMorphContent() {
      Modal.show(
        id: 'morphing_modal', // Keep same ID to maintain identity
        builder: () => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: currentType == ModalType.dialog
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                        ),
                      ],
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentType == ModalType.sheet
                        ? Icons.vertical_align_bottom
                        : Icons.center_focus_strong,
                    size: 48,
                    color: currentType == ModalType.sheet
                        ? Colors.blue
                        : Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentType == ModalType.sheet
                        ? 'Bottom Sheet Mode'
                        : 'Dialog Mode',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Morphed $morphCount times',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.transform),
                    label: Text(currentType == ModalType.sheet
                        ? 'Morph to Dialog'
                        : 'Morph to Bottom Sheet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentType == ModalType.sheet
                          ? Colors.purple
                          : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      morphCount++;
                      final newType = currentType == ModalType.sheet
                          ? ModalType.dialog
                          : ModalType.sheet;
                      currentType = newType;

                      // Update the modal type - this triggers a full rebuild
                      Modal.updateParams(
                        id: 'morphing_modal',
                        modalType: newType,
                        modalPosition: newType == ModalType.dialog
                            ? Alignment.center
                            : Alignment.bottomCenter,
                        isDraggable: newType == ModalType.dialog,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Modal.dismissById('morphing_modal'),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        modalType: currentType,
        modalPosition: Alignment.bottomCenter,
        size: 300,

        blurAmount: 5,
        shouldBlurBackground: _globalBlur,
        isDismissable: _globalDismissable,

        blockBackgroundInteraction: _globalBlockBackgroundInteraction,
      );
    }

    showMorphContent();
  }

  /// Demonstrates updating dialog position dynamically
  void _showPositionUpdatingDialog() {
    final positions = [
      Alignment.topLeft,
      Alignment.topCenter,
      Alignment.topRight,
      Alignment.centerLeft,
      Alignment.center,
      Alignment.centerRight,
      Alignment.bottomLeft,
      Alignment.bottomCenter,
      Alignment.bottomRight,
    ];
    int positionIndex = 4; // Start at center
    bool useOffset = false; // Track if using offset mode

    Modal.show(
      id: 'position_dialog',
      builder: () => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: const BoxConstraints(
              maxWidth: 320,
              maxHeight: 380,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.open_with, size: 48, color: Colors.indigo),
                const SizedBox(height: 16),
                Text(
                  useOffset
                      ? 'Mode: Offset (150, 100)'
                      : 'Position: ${positions[positionIndex].toString().split('.').last}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  useOffset
                      ? 'Using absolute positioning'
                      : 'Tap arrows to move!',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (!useOffset)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: positionIndex > 0
                            ? () {
                                setModalState(() => positionIndex--);
                                Modal.updateParams(
                                  id: 'position_dialog',
                                  modalPosition: positions[positionIndex],
                                );
                              }
                            : null,
                      ),
                      Text('${positionIndex + 1}/${positions.length}'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: positionIndex < positions.length - 1
                            ? () {
                                setModalState(() => positionIndex++);
                                Modal.updateParams(
                                  id: 'position_dialog',
                                  modalPosition: positions[positionIndex],
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setModalState(() => useOffset = !useOffset);
                    if (useOffset) {
                      // Switch to offset mode at a specific position
                      Modal.updateParams(
                        id: 'position_dialog',
                        offset: const Offset(150, 100),
                      );
                    } else {
                      // Switch back to alignment mode
                      // Pass null offset to clear it
                      Modal.updateParams(
                        id: 'position_dialog',
                        modalPosition: positions[positionIndex],
                        offset: null,
                      );
                    }
                  },
                  icon: Icon(useOffset ? Icons.grid_view : Icons.gps_fixed),
                  label: Text(useOffset ? 'Use Alignment' : 'Use Offset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Modal.dismissDialog(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
      modalType: ModalType.dialog,
      modalPosition: positions[positionIndex],
      isDraggable: true,
      blurAmount: 3,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
    );
  }

  /// Demonstrates live-updating snackbar parameters
  void _showLiveUpdatingSnackbar() {
    int countdown = 5;
    final colors = [
      Colors.grey.shade800,
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.red.shade700,
    ];
    int colorIndex = 0;

    // Show initial snackbar
    Modal.showSnackbar(
      id: 'live_snackbar',
      builder: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: colors[colorIndex],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.timer, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Countdown: $countdown',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            GestureDetector(
              onTap: () => Modal.dismissById('live_snackbar'),
              child: const Icon(Icons.close, color: Colors.white70),
            ),
          ],
        ),
      ),
      position: Alignment.topCenter,
      displayMode: SnackbarDisplayMode.replace,
      isDismissible: true,
      duration: null,
    );

    // Update countdown every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      countdown--;
      colorIndex = (colorIndex + 1) % colors.length;

      if (countdown <= 0 || !Modal.isSnackbarActive) {
        Modal.dismissById('live_snackbar');
        return false;
      }

      // Update the snackbar content
      Modal.updateParams(
        id: 'live_snackbar',
        builder: () => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: colors[colorIndex],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                countdown <= 3 ? Icons.warning : Icons.timer,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  countdown <= 3
                      ? 'Closing in $countdown...'
                      : 'Countdown: $countdown',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: () => Modal.dismissById('live_snackbar'),
                child: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
        ),
      );

      return true;
    });
  }

  // ============================================
  // Overlay Widgets Showcase
  // ============================================

  /// Demonstrates Slider with value indicator tooltip working inside a modal
  void _showSliderBottomSheet() {
    double sliderValue = 50.0;

    Modal.show(
      id: 'slider_sheet',
      builder: () => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.linear_scale,
                          size: 28, color: Colors.blue.shade700),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Slider Demo',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Value indicator tooltip works!',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    children: [
                      Text(
                        sliderValue.toInt().toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          showValueIndicator: ShowValueIndicator.onDrag,
                          valueIndicatorTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: sliderValue.toInt().toString(),
                          onChanged: (value) {
                            setModalState(() => sliderValue = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Drag the slider to see the value indicator!',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Modal.dismissBottomSheet(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
      modalType: ModalType.sheet,
      size: 360,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
    );
  }

  /// Demonstrates TextField with autocomplete suggestions working inside a dialog
  void _showTextFieldDialog() {
    final textController = TextEditingController();
    final suggestions = [
      'Apple',
      'Banana',
      'Cherry',
      'Date',
      'Elderberry',
      'Fig',
      'Grape'
    ];

    Modal.show(
      id: 'textfield_dialog',
      builder: () => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.text_fields,
                          size: 24, color: Colors.green.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'TextField Demo',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return suggestions.where((option) => option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    textController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Type a fruit name',
                        hintText: 'e.g., Apple, Banana...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Autocomplete suggestions appear correctly!',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Modal.dismissDialog(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Modal.dismissDialog(),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      modalType: ModalType.dialog,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
    );
  }

  /// Demonstrates DropdownButton with dropdown menu working inside a bottom sheet
  void _showDropdownBottomSheet() {
    String? selectedValue;
    final items = ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5'];

    Modal.show(
      id: 'dropdown_sheet',
      builder: () => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_drop_down_circle,
                          size: 28, color: Colors.purple.shade700),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dropdown Demo',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Dropdown menu displays correctly!',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Select an option:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: DropdownButton<String>(
                          value: selectedValue,
                          hint: const Text('Choose option'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(12),
                          items: items.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setModalState(() => selectedValue = newValue);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (selectedValue != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Selected: $selectedValue',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Modal.dismissBottomSheet(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
      modalType: ModalType.sheet,
      size: 400,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
    );
  }

  /// Demonstrates all overlay widgets combined in one dialog
  void _showCombinedWidgetsDialog() {
    double sliderValue = 50.0;
    String? dropdownValue;
    final textController = TextEditingController();
    final dropdownItems = ['Red', 'Green', 'Blue', 'Yellow', 'Purple'];

    Modal.show(
      id: 'combined_widgets_dialog',
      builder: () => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.purple.shade400
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.widgets,
                          size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Combined Widgets',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'All overlay widgets working!',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Slider
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.linear_scale, size: 18),
                          const SizedBox(width: 8),
                          const Text('Slider',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(
                            sliderValue.toInt().toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          showValueIndicator: ShowValueIndicator.onDrag,
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: sliderValue.toInt().toString(),
                          onChanged: (value) {
                            setModalState(() => sliderValue = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // TextField
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.text_fields, size: 18),
                          SizedBox(width: 8),
                          Text('TextField',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Type something...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dropdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_drop_down_circle, size: 18),
                          SizedBox(width: 8),
                          Text('Dropdown',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          hint: const Text('Select color'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(8),
                          items: dropdownItems.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setModalState(() => dropdownValue = newValue);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Modal.dismissDialog(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Done'),
                      onPressed: () => Modal.dismissDialog(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      modalType: ModalType.dialog,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
    );
  }

  // ============================================
  // Mixed Modal Demos
  // ============================================

  void _showMixedModalDemo(String scenario) {
    // Reset any active modals first
    Modal.dismissAll();

    switch (scenario) {
      case 'BottomSheet + Snackbar':
        // 1. Show Bottom Sheet
        Modal.show(
          id: 'bottom-sheet-with-snackbar', // ID enables auto-update
          builder: () => _buildBottomSheetWithSnackbarContent(),
          modalType: ModalType.sheet,
          shouldBlurBackground: _globalBlur,
          isDismissable: _globalDismissable,
          blockBackgroundInteraction: _globalBlockBackgroundInteraction,
        );
        break;

      case 'Dialog + Snackbar':
        // 1. Show Dialog
        Modal.show(
          id: 'dialog-with-snackbar', // ID enables auto-update
          builder: () => _buildDialogWithSnackbarContent(),
          modalType: ModalType.dialog,
          modalPosition: Alignment.center,
          shouldBlurBackground: _globalBlur,
          isDismissable: _globalDismissable,
          blockBackgroundInteraction: _globalBlockBackgroundInteraction,
        );
        break;

      case 'Snackbar + Bottom Sheet':
        // 1. Show Snackbar first
        Modal.showSnackbar(
          text: 'I am a persistent snackbar. Open the sheet!',
          position: Alignment.topCenter,
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 5),
        );

        // 2. Wait a bit then show Bottom Sheet (simulating user action or sequence)
        Future.delayed(const Duration(milliseconds: 700), () {
          Modal.show(
            id: 'bottom-sheet-after-snackbar', // ID enables auto-update
            builder: () => _buildBottomSheetAfterSnackbarContent(),
            modalType: ModalType.sheet,
            size: 300,
            shouldBlurBackground: _globalBlur,
            isDismissable: _globalDismissable,
            blockBackgroundInteraction: _globalBlockBackgroundInteraction,
          );
        });
        break;

      case 'Snackbar with Modal Buttons':
        // Show a snackbar with buttons to open other modals
        Modal.showSnackbar(
          duration: const Duration(seconds: 8),
          id: 'snackbar_with_buttons',
          builder: () => _buildInteractiveSnackbarContent(),
          position: Alignment.bottomCenter,
          isDismissible: true,
        );
        break;

      case 'SideSheet + Snackbar':
        // 1. Show Side Sheet
        Modal.show(
          modalType: ModalType.sheet,
          builder: () => _buildSideSheetWithSnackbarContent(),
          sheetPosition: SheetPosition.right,
          size: 300,
          shouldBlurBackground: _globalBlur,
          isDismissable: _globalDismissable,
          id: 'side-sheet-with-snackbar',
        );
        break;
    }
  }

  Widget _buildPositionSelector() {
    return Column(
      children: [
        Row(
          children: [
            _buildPositionChip(Alignment.topLeft, 'TL'),
            const SizedBox(width: 8),
            _buildPositionChip(Alignment.topCenter, 'TC'),
            const SizedBox(width: 8),
            _buildPositionChip(Alignment.topRight, 'TR'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPositionChip(Alignment.bottomLeft, 'BL'),
            const SizedBox(width: 8),
            _buildPositionChip(Alignment.bottomCenter, 'BC'),
            const SizedBox(width: 8),
            _buildPositionChip(Alignment.bottomRight, 'BR'),
          ],
        ),
      ],
    );
  }

  Widget _buildPositionChip(Alignment position, String label) {
    final isSelected = _selectedPosition == position;
    return Expanded(
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedPosition = position);
            // Live update if snackbar is active
            if (Modal.isSnackbarActive) {
              final activeId = Modal.snackbarController.state?.uniqueId;
              if (activeId != null) {
                Modal.updateParams(id: activeId, modalPosition: position);
              }
            }
          }
        },
      ),
    );
  }

  /// Builds a draggable position picker for offset-based snackbar positioning
  ///
  /// The widget displays a rectangular area representing the screen,
  /// with a draggable pin that the user can move to set the snackbar's position.
  Widget _buildOffsetPositionPicker() {
    // Get actual screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    // The picker dimensions - represents a scaled-down version of the screen
    // Maintain aspect ratio with the actual screen
    const double pickerWidth = 160.0; // Reduced from 280.0
    final double pickerHeight = pickerWidth * (screenHeight / screenSize.width);

    // The actual screen dimensions we're mapping to (full usable screen)
    final double maxScreenX = screenSize.width;
    final double maxScreenY = screenHeight;

    return Center(
      child: ValueListenableBuilder<SnackbarOffset>(
        valueListenable: _snackbarOffsetNotifier,
        builder: (context, offset, _) {
          // Calculate pin position within the picker (scaled from actual offset values)
          final double pinX =
              (offset.offsetX / maxScreenX * pickerWidth).clamp(0, pickerWidth);
          final double pinY = (offset.offsetY / maxScreenY * pickerHeight)
              .clamp(0, pickerHeight);

          return _OffsetPickerWidget(
            width: pickerWidth,
            height: pickerHeight,
            maxScreenX: maxScreenX,
            maxScreenY: maxScreenY,
            pinX: pinX,
            pinY: pinY,
            onOffsetChanged: (offsetX, offsetY) {
              _snackbarOffsetNotifier.value =
                  SnackbarOffset(offsetX: offsetX, offsetY: offsetY);
            },
          );
        },
      ),
    );
  }

  void _showConfiguredSnackbar() {
    final count = _snackbarCounter++;

    // Callback to decrement counter when staggered snackbar is dismissed
    void onDismissedCallback() {
      if (_selectedDisplayMode == SnackbarDisplayMode.staggered ||
          _selectedDisplayMode == SnackbarDisplayMode.notificationBubble) {
        setState(() {
          _snackbarCounter--;
        });
      }
    }

    // Generate ID only for custom types that need it
    final needsId =
        ['Success', 'Error', 'Custom'].contains(_selectedSnackbarType);
    final snackbarId =
        needsId ? 'snackbar_${DateTime.now().millisecondsSinceEpoch}' : null;

    // Calculate offset for 'With Offset' type using ValueNotifier state
    Offset? offset;
    if (_selectedSnackbarType == 'With Offset') {
      final offsetState = _snackbarOffsetNotifier.value;
      offset = Offset(offsetState.offsetX, offsetState.offsetY);
    }

    // Calculate effective duration (null for staggered/notification modes)
    final effectiveDuration =
        _selectedDisplayMode == SnackbarDisplayMode.staggered ||
                _selectedDisplayMode == SnackbarDisplayMode.notificationBubble
            ? null
            : const Duration(seconds: 3);

    // Determine builder for custom content types
    final builder = switch (_selectedSnackbarType) {
      'Success' => () => _buildSuccessSnackbarContent(snackbarId!),
      'Error' => () => _buildErrorSnackbarContent(snackbarId!),
      'Custom' => () => _buildActionSnackbarContent(snackbarId!),
      _ => null,
    };

    // Get offset display text from ValueNotifier state
    final offsetStateText = _selectedSnackbarType == 'With Offset'
        ? () {
            final offsetState = _snackbarOffsetNotifier.value;
            return 'Snackbar at (${offsetState.offsetX.toInt()}, ${offsetState.offsetY.toInt()})';
          }()
        : 'Snackbar #$count';

    Modal.showSnackbar(
      id: snackbarId,
      duration: effectiveDuration,
      builder: builder,
      text: builder == null ? offsetStateText : null,
      prefixIcon: builder == null
          ? (_selectedSnackbarType == 'With Offset'
              ? Icons.control_camera
              : Icons.info_outline)
          : null,
      backgroundColor:
          _selectedSnackbarType == 'With Offset' ? Colors.deepPurple : null,
      offset: offset,
      position: _selectedPosition,
      displayMode: _selectedDisplayMode,
      onDismissed: onDismissedCallback,
      showDurationTimer: _showDurationTimer,
      durationTimerColor: _durationTimerColor,
      durationTimerDirection: _durationTimerDirection,
      width: _snackbarWidth,
      isDismissible: _snackbarIsDismissible,
      barrierColor: _snackbarBarrierColor,
    );
  }

  Widget _buildColorChip(Color? color, String label) {
    final isSelected = _durationTimerColor == color;
    return GestureDetector(
      onTap: () => setState(() => _durationTimerColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color ?? Colors.amber,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color == null
                ? Colors.black87
                : (color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBarrierColorChip(Color color, String label, bool isTransparent) {
    final isSelected = _snackbarBarrierColor == color;
    return GestureDetector(
      onTap: () => setState(() => _snackbarBarrierColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isTransparent
              ? Colors.grey.shade200
              : color.withValues(
                  alpha: 1.0), // Show fully opaque for visibility
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isTransparent
                ? Colors.black87
                : (color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Helper to get icon for sheet position
  IconData _getSheetIcon(SheetPosition position) {
    switch (position) {
      case SheetPosition.top:
        return Icons.vertical_align_top;
      case SheetPosition.bottom:
        return Icons.vertical_align_bottom;
      case SheetPosition.left:
        return Icons.align_horizontal_left;
      case SheetPosition.right:
        return Icons.align_horizontal_right;
    }
  }

  // Helper to get display name for sheet position
  String _getSheetTypeName(SheetPosition position) {
    switch (position) {
      case SheetPosition.top:
        return 'Top Sheet';
      case SheetPosition.bottom:
        return 'Bottom Sheet';
      case SheetPosition.left:
        return 'Left Side Sheet';
      case SheetPosition.right:
        return 'Right Side Sheet';
    }
  }

  void _showConfiguredSheet() {
    ModalWidgetBuilder builder;
    double? size = _sheetSize;
    double? expandedHeightPercent;

    // Determine the modal type based on position
    ModalType modalType;
    switch (_sheetPosition) {
      case SheetPosition.top:
        modalType = ModalType.sheet;
        break;
      case SheetPosition.bottom:
        modalType = ModalType.sheet;
        break;
      case SheetPosition.left:
      case SheetPosition.right:
        modalType = ModalType.sheet;
        break;
    }

    // Build content based on selected content type
    switch (_selectedSheetContentType) {
      case 'Custom':
        builder = () => _buildSideSheetCustomContent();
        break;
      case 'Blurred':
        builder = () => _buildCustomBlurContent();
        size = 350;
        break;
      case 'List':
        builder = () => _buildExpandableSheetContent();
        size = 200;
        expandedHeightPercent = 85;
        break;
      case 'Menu':
        builder = () => _buildSideSheetMenuContent();
        break;
      case 'Settings':
        builder = () => _buildSideSheetSettingsContent();
        break;
      case 'Profile':
        builder = () => _buildSideSheetProfileContent();
        break;
      case 'Default':
      default:
        builder = () => Modal.bottomSheetTemplate;
        break;
    }

    Modal.show(
      id: 'configured-sheet',
      builder: builder,
      modalType: modalType,
      sheetPosition: _sheetPosition,
      isExpandable: _sheetExpandable,
      size: size,
      expandedPercentageSize:
          _sheetExpandable ? (expandedHeightPercent ?? 85.0) : 85.0,
      blurAmount: _globalBlurAmount,
      barrierColor: _globalBarrierColor,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
      backgroundColor: _sheetBackgroundColor,
    );
  }

  void _showConfiguredDialog() {
    ModalWidgetBuilder builder;
    double? size;

    switch (_selectedDialogType) {
      case 'Confirm':
        builder = () => _buildConfirmationDialogContent();
        size = 300;
        break;
      case 'Form':
        builder = () => _buildReactiveFormContent();
        size = 400;
        break;
      case 'Callbacks':
        builder = () => _buildCallbacksContent();
        size = 250;
        break;
      case 'Info':
      default:
        builder = () => _buildDialogContent();
        size = 300;
        break;
    }

    final onDismissCallback = _selectedDialogType == 'Callbacks'
        ? () async {
            debugPrint("DIALOG DISMISSED");
            Modal.showSnackbar(
              text: 'Modal dismissed!',
              prefixIcon: Icons.check_circle,
              backgroundColor: Colors.teal,
              position: Alignment.topCenter,
            );
          }
        : null;

    // AUTO-UPDATE FEATURE: Just call Modal.show() with an ID.
    // If a dialog with this ID is already active, it will be updated.
    // If not, a new one will be shown. No need for if/else checking!

    Modal.show(
      id: 'configured-dialog', // ID enables auto-update
      builder: builder,
      modalType: ModalType.dialog,
      modalPosition: Alignment.center,
      size: size,
      blurAmount: _globalBlurAmount,
      barrierColor: _globalBarrierColor,
      isDraggable: _dialogDraggable,
      offset: _dialogWithOffset ? const Offset(50, 30) : null,
      shouldBlurBackground: _globalBlur,
      isDismissable: _globalDismissable,
      blockBackgroundInteraction: _globalBlockBackgroundInteraction,
      onDismissed: onDismissCallback,
    );
  }

  Widget _buildSideSheetMenuContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Menu',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildMenuListItem(
              Icons.home, 'Home', () => Modal.dismissSideSheet()),
          _buildMenuListItem(
              Icons.person, 'Profile', () => Modal.dismissSideSheet()),
          _buildMenuListItem(
              Icons.settings, 'Settings', () => Modal.dismissSideSheet()),
          _buildMenuListItem(Icons.notifications, 'Notifications',
              () => Modal.dismissSideSheet()),
          _buildMenuListItem(
              Icons.help, 'Help & Support', () => Modal.dismissSideSheet()),
          const SizedBox(height: 48),
          const Divider(),
          _buildMenuListItem(
              Icons.logout, 'Logout', () => Modal.dismissSideSheet(),
              isDestructive: true),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuListItem(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey.shade700,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? Colors.red : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideSheetSettingsContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: false,
            onChanged: (_) {},
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable push notifications'),
            value: true,
            onChanged: (_) {},
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sounds for actions'),
            value: true,
            onChanged: (_) {},
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Text('English'),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSideSheetProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'john.doe@example.com',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          _buildProfileStat('Posts', '142'),
          _buildProfileStat('Followers', '1.2K'),
          _buildProfileStat('Following', '89'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Modal.dismissSideSheet(),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSideSheetCustomContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Custom Side Sheet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is a fully customizable side sheet. You can put any content here!',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Swipe horizontally to dismiss!',
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Modal.dismissSideSheet(),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChoice({
    required Color color,
    required String label,
    required Color selectedColor,
    required Function(Color) onSelect,
  }) {
    // Compare Color objects directly instead of using the deprecated `.value`.
    final isSelected = color == selectedColor;
    final isTransparent = color == Colors.transparent;

    return GestureDetector(
      onTap: () => onSelect(color),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTransparent ? Colors.white : color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check,
                    color: (color.computeLuminance() > 0.5 || isTransparent)
                        ? Colors.black
                        : Colors.white,
                    size: 20)
                : (isTransparent
                    ? Icon(Icons.grid_3x3,
                        color: Colors.grey.shade300, size: 20)
                    : null),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Model for snackbar offset state management with states_rebuilder
class SnackbarOffset {
  final double offsetX;
  final double offsetY;

  SnackbarOffset({required this.offsetX, required this.offsetY});

  SnackbarOffset copyWith({double? offsetX, double? offsetY}) {
    return SnackbarOffset(
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
    );
  }

  @override
  String toString() => 'SnackbarOffset(x: $offsetX, y: $offsetY)';
}

class ExampleButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  const ExampleButton(
      {required this.icon, required this.text, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final button = Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
    if (onPressed != null) {
      return SInkButton(
        onTap: (pos) => onPressed?.call(),
        child: button,
      );
    }
    return button;
  }
}

/// Stateful widget for the offset position picker with smooth dragging
class _OffsetPickerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double maxScreenX;
  final double maxScreenY;
  final double pinX;
  final double pinY;
  final Function(double offsetX, double offsetY) onOffsetChanged;

  const _OffsetPickerWidget({
    required this.width,
    required this.height,
    required this.maxScreenX,
    required this.maxScreenY,
    required this.pinX,
    required this.pinY,
    required this.onOffsetChanged,
  });

  @override
  State<_OffsetPickerWidget> createState() => _OffsetPickerWidgetState();
}

class _OffsetPickerWidgetState extends State<_OffsetPickerWidget> {
  late double _currentPinX;
  late double _currentPinY;

  @override
  void initState() {
    super.initState();
    _currentPinX = widget.pinX;
    _currentPinY = widget.pinY;
  }

  @override
  void didUpdateWidget(_OffsetPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pinX != widget.pinX || oldWidget.pinY != widget.pinY) {
      _currentPinX = widget.pinX;
      _currentPinY = widget.pinY;
    }
  }

  void _updatePinPosition(Offset localPosition) {
    // Clamp position to picker bounds
    final clampedX = localPosition.dx.clamp(0.0, widget.width);
    final clampedY = localPosition.dy.clamp(0.0, widget.height);

    // Update local state for immediate visual feedback
    setState(() {
      _currentPinX = clampedX;
      _currentPinY = clampedY;
    });

    // Convert picker position to screen offset
    final newOffsetX = (clampedX / widget.width * widget.maxScreenX);
    final newOffsetY = (clampedY / widget.height * widget.maxScreenY);

    // Notify parent of change
    widget.onOffsetChanged(newOffsetX, newOffsetY);
  }

  @override
  Widget build(BuildContext context) {
    const double pinSize = 24.0;

    return Listener(
      onPointerDown: (event) => _updatePinPosition(event.localPosition),
      onPointerMove: (event) => _updatePinPosition(event.localPosition),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Grid lines for visual reference
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),

            // "Screen" label
            Positioned(
              top: 4,
              left: 8,
              child: Text(
                'Screen',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Draggable Pin
            Positioned(
              left: _currentPinX - pinSize / 2,
              top: _currentPinY - pinSize / 2,
              child: IgnorePointer(
                child: Container(
                  width: pinSize,
                  height: pinSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Snackbar preview indicator
            Positioned(
              left: _currentPinX,
              top: _currentPinY,
              child: IgnorePointer(
                child: Container(
                  width: 50,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for drawing grid lines in the offset position picker
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    const int verticalDivisions = 4;
    for (int i = 1; i < verticalDivisions; i++) {
      final x = size.width * i / verticalDivisions;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    const int horizontalDivisions = 3;
    for (int i = 1; i < horizontalDivisions; i++) {
      final y = size.height * i / horizontalDivisions;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
