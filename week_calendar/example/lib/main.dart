import 'package:flutter/material.dart';
import 'package:week_calendar/week_calendar.dart';

void main() {
  runApp(const WeekCalendarExampleApp());
}

class WeekCalendarExampleApp extends StatelessWidget {
  const WeekCalendarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week Calendar Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
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
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    StandardCalendarExample(),
    OutlinedCalendarExample(),
    MinimalCalendarExample(),
    ElevatedCalendarExample(),
    CustomStyleExample(),
    StartingDayExample(),
    AnimationExample(),
    CallbacksExample(),
    AllFeaturesExample(),
  ];

  final List<String> _titles = const [
    'Standard Calendar',
    'Outlined Calendar',
    'Minimal Calendar',
    'Elevated Calendar',
    'Custom Styles',
    'Starting Day Options',
    'Animation Controls',
    'Callbacks Demo',
    'All Features',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.calendar_month, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Week Calendar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Examples',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ...List.generate(_titles.length, (index) {
              return ListTile(
                selected: _selectedIndex == index,
                selectedTileColor: Colors.blueAccent.withValues(alpha: 0.1),
                leading: Icon(
                  _getIconForIndex(index),
                  color:
                      _selectedIndex == index ? Colors.blueAccent : Colors.grey,
                ),
                title: Text(_titles[index]),
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.calendar_today;
      case 1:
        return Icons.calendar_view_week_outlined;
      case 2:
        return Icons.view_week;
      case 3:
        return Icons.calendar_view_month;
      case 4:
        return Icons.palette;
      case 5:
        return Icons.start;
      case 6:
        return Icons.animation;
      case 7:
        return Icons.touch_app;
      case 8:
        return Icons.star;
      default:
        return Icons.calendar_today;
    }
  }
}

// Example 1: Standard Calendar Type
class StandardCalendarExample extends StatefulWidget {
  const StandardCalendarExample({super.key});

  @override
  State<StandardCalendarExample> createState() =>
      _StandardCalendarExampleState();
}

class _StandardCalendarExampleState extends State<StandardCalendarExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Standard Calendar Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'The default calendar with circular day indicators.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: WeekCalendar(
              initialDate: _initialDate,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              onNextMonth: () {
                setState(() {
                  _initialDate =
                      DateTime(_initialDate.year, _initialDate.month + 1);
                });
              },
              onPreviousMonth: () {
                setState(() {
                  _initialDate =
                      DateTime(_initialDate.year, _initialDate.month - 1);
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSelectedDateInfo(),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 2: Outlined Calendar Type
class OutlinedCalendarExample extends StatefulWidget {
  const OutlinedCalendarExample({super.key});

  @override
  State<OutlinedCalendarExample> createState() =>
      _OutlinedCalendarExampleState();
}

class _OutlinedCalendarExampleState extends State<OutlinedCalendarExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Outlined Calendar Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Calendar with outlined containers and borders.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          WeekCalendar.outlined(
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onNextMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month + 1);
              });
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month - 1);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSelectedDateInfo(),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 3: Minimal Calendar Type
class MinimalCalendarExample extends StatefulWidget {
  const MinimalCalendarExample({super.key});

  @override
  State<MinimalCalendarExample> createState() => _MinimalCalendarExampleState();
}

class _MinimalCalendarExampleState extends State<MinimalCalendarExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minimal Calendar Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Simplified text-based calendar with minimal styling.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          WeekCalendar.minimal(
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onNextMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month + 1);
              });
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month - 1);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSelectedDateInfo(),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 4: Elevated Calendar Type
class ElevatedCalendarExample extends StatefulWidget {
  const ElevatedCalendarExample({super.key});

  @override
  State<ElevatedCalendarExample> createState() =>
      _ElevatedCalendarExampleState();
}

class _ElevatedCalendarExampleState extends State<ElevatedCalendarExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elevated Calendar Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Material-elevated containers with shadow effects.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          WeekCalendar(
            calendarType: WeekCalendarType.elevated,
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onNextMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month + 1);
              });
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month - 1);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSelectedDateInfo(),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 5: Custom Style
class CustomStyleExample extends StatefulWidget {
  const CustomStyleExample({super.key});

  @override
  State<CustomStyleExample> createState() => _CustomStyleExampleState();
}

class _CustomStyleExampleState extends State<CustomStyleExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Calendar Styles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Calendar with custom colors, sizes, and text styles.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          WeekCalendar(
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            calendarStyle: WeekCalendarStyle(
              monthHeaderStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              dayNameStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple,
              ),
              dayNumberStyle: const TextStyle(fontSize: 18),
              selectedDayTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              inactiveDayTextStyle: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              activeDayColor: Colors.deepPurple,
              dayIndicatorColor: Colors.purple.shade50,
              dayIndicatorSize: 40,
              selectionAnimationDuration: const Duration(milliseconds: 400),
              selectionAnimationCurve: Curves.elasticOut,
            ),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onNextMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month + 1);
              });
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month - 1);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSelectedDateInfo(),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Date:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18, color: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 6: Starting Day Options
class StartingDayExample extends StatefulWidget {
  const StartingDayExample({super.key});

  @override
  State<StartingDayExample> createState() => _StartingDayExampleState();
}

class _StartingDayExampleState extends State<StartingDayExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();
  Weekday _startingDay = Weekday.monday;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Starting Day Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Change the first day of the week.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Weekday.values.map((day) {
              return ChoiceChip(
                label: Text(day.name.toUpperCase()),
                selected: _startingDay == day,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _startingDay = day;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          WeekCalendar(
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            startingDay: _startingDay,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onNextMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month + 1);
              });
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month - 1);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSelectedDateInfo(),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Week starts on: ${_startingDay.name.toUpperCase()}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 7: Animation Controls
class AnimationExample extends StatefulWidget {
  const AnimationExample({super.key});

  @override
  State<AnimationExample> createState() => _AnimationExampleState();
}

class _AnimationExampleState extends State<AnimationExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();
  bool _enableAnimations = true;
  Duration _animationDuration = const Duration(milliseconds: 300);
  Curve _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Animation Controls',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Control animation behavior and timing.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable Animations'),
            value: _enableAnimations,
            onChanged: (value) {
              setState(() {
                _enableAnimations = value;
              });
            },
          ),
          ListTile(
            title: const Text('Animation Duration'),
            subtitle: Text('${_animationDuration.inMilliseconds}ms'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _animationDuration.inMilliseconds.toDouble(),
                min: 100,
                max: 1000,
                divisions: 9,
                label: '${_animationDuration.inMilliseconds}ms',
                onChanged: (value) {
                  setState(() {
                    _animationDuration = Duration(milliseconds: value.toInt());
                  });
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Animation Curve'),
            subtitle: Text(_getCurveName(_animationCurve)),
            trailing: DropdownButton<Curve>(
              value: _animationCurve,
              items: [
                Curves.easeInOut,
                Curves.linear,
                Curves.bounceOut,
                Curves.elasticOut,
                Curves.easeOutBack,
              ].map((curve) {
                return DropdownMenuItem(
                  value: curve,
                  child: Text(_getCurveName(curve)),
                );
              }).toList(),
              onChanged: (curve) {
                if (curve != null) {
                  setState(() {
                    _animationCurve = curve;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          WeekCalendar(
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            enableAnimations: _enableAnimations,
            animationDuration: _animationDuration,
            animationCurve: _animationCurve,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onNextMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month + 1);
              });
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month - 1);
              });
            },
          ),
        ],
      ),
    );
  }

  String _getCurveName(Curve curve) {
    if (curve == Curves.easeInOut) return 'Ease In Out';
    if (curve == Curves.linear) return 'Linear';
    if (curve == Curves.bounceOut) return 'Bounce Out';
    if (curve == Curves.elasticOut) return 'Elastic Out';
    if (curve == Curves.easeOutBack) return 'Ease Out Back';
    return 'Unknown';
  }
}

// Example 8: Callbacks Demo
class CallbacksExample extends StatefulWidget {
  const CallbacksExample({super.key});

  @override
  State<CallbacksExample> createState() => _CallbacksExampleState();
}

class _CallbacksExampleState extends State<CallbacksExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();
  final List<String> _eventLog = [];

  void _addEvent(String event) {
    setState(() {
      _eventLog.insert(
          0, '${DateTime.now().toString().substring(11, 19)}: $event');
      if (_eventLog.length > 10) {
        _eventLog.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Callbacks Demo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track all calendar interactions and callbacks.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          WeekCalendar(
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
              _addEvent(
                  'Date selected: ${date.day}/${date.month}/${date.year}');
            },
            onNextMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month + 1);
              });
              _addEvent('Next month clicked');
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month - 1);
              });
              _addEvent('Previous month clicked');
            },
            onHeaderDateTapped: (position) {
              _addEvent(
                  'Header date tapped at position: (${position.dx.toStringAsFixed(0)}, ${position.dy.toStringAsFixed(0)})');
            },
            onHeaderTodayDate: (position) {
              _addEvent(
                  'Today button tapped at position: (${position.dx.toStringAsFixed(0)}, ${position.dy.toStringAsFixed(0)})');
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Event Log:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: Card(
              child: _eventLog.isEmpty
                  ? const Center(
                      child: Text(
                        'No events yet. Interact with the calendar!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _eventLog.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.access_time, size: 16),
                          title: Text(
                            _eventLog[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example 9: All Features Combined
class AllFeaturesExample extends StatefulWidget {
  const AllFeaturesExample({super.key});

  @override
  State<AllFeaturesExample> createState() => _AllFeaturesExampleState();
}

class _AllFeaturesExampleState extends State<AllFeaturesExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();
  WeekCalendarType _calendarType = WeekCalendarType.standard;
  Weekday _startingDay = Weekday.monday;
  bool _showMonthHeader = true;
  bool _enableAnimations = true;
  bool _isUtc = true;
  Color _activeColor = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Features Combined',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore all customization options at once.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Calendar Widget
          WeekCalendar(
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            calendarType: _calendarType,
            startingDay: _startingDay,
            showMonthHeader: _showMonthHeader,
            enableAnimations: _enableAnimations,
            isUtc: _isUtc,
            calendarStyle: WeekCalendarStyle(
              activeDayColor: _activeColor,
              dayIndicatorSize: 38,
            ),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onNextMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month + 1);
              });
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate =
                    DateTime(_initialDate.year, _initialDate.month - 1);
              });
            },
            onHeaderDateTapped: (position) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Header date tapped!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onHeaderTodayDate: (position) {
              setState(() {
                _selectedDate = DateTime.now();
                _initialDate = DateTime.now();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jumped to today!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Controls
          const Text(
            'Customization Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Calendar Type
          const Text('Calendar Type:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: WeekCalendarType.values.map((type) {
              return ChoiceChip(
                label: Text(type.name.toUpperCase()),
                selected: _calendarType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _calendarType = type;
                    });
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Starting Day
          const Text('Starting Day:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Weekday.values.map((day) {
              return ChoiceChip(
                label: Text(day.name.substring(0, 3).toUpperCase()),
                selected: _startingDay == day,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _startingDay = day;
                    });
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Color Picker
          const Text('Active Color:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Colors.blueAccent,
              Colors.red,
              Colors.green,
              Colors.purple,
              Colors.orange,
              Colors.teal,
            ].map((color) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _activeColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: _activeColor == color
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Toggles
          SwitchListTile(
            title: const Text('Show Month Header'),
            value: _showMonthHeader,
            onChanged: (value) {
              setState(() {
                _showMonthHeader = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Enable Animations'),
            value: _enableAnimations,
            onChanged: (value) {
              setState(() {
                _enableAnimations = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Use UTC Dates'),
            value: _isUtc,
            onChanged: (value) {
              setState(() {
                _isUtc = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Selected Date Info
          Card(
            color: _activeColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Date:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(fontSize: 18, color: _activeColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${_calendarType.name}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Week starts: ${_startingDay.name}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
