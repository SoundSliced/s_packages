import 'package:s_packages/s_packages.dart';

class WeekCalendarExampleScreen extends StatefulWidget {
  const WeekCalendarExampleScreen({super.key});

  @override
  State<WeekCalendarExampleScreen> createState() =>
      _WeekCalendarExampleScreenState();
}

class _WeekCalendarExampleScreenState extends State<WeekCalendarExampleScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();
  WeekCalendarType _calendarType = WeekCalendarType.standard;

  // Event dates for indicator demo
  late final Set<DateTime> _eventDates = {
    DateTime.now(),
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
    DateTime.now().subtract(const Duration(days: 1)),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeekCalendar Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Customizable Week Calendar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Standard calendar
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Standard Calendar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: WeekCalendar(
                          initialDate: _initialDate,
                          selectedDate: _selectedDate,
                          calendarType: _calendarType,
                          minDate:
                              DateTime.now().subtract(const Duration(days: 30)),
                          maxDate: DateTime.now().add(const Duration(days: 60)),
                          eventIndicatorDates: _eventDates,
                          eventIndicatorColor: Colors.red,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          onNextMonth: () {
                            setState(() {
                              _initialDate = DateTime(
                                _initialDate.year,
                                _initialDate.month + 1,
                              );
                            });
                          },
                          onPreviousMonth: () {
                            setState(() {
                              _initialDate = DateTime(
                                _initialDate.year,
                                _initialDate.month - 1,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selected: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Calendar type selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calendar Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Standard'),
                            selected:
                                _calendarType == WeekCalendarType.standard,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _calendarType = WeekCalendarType.standard;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Outlined'),
                            selected:
                                _calendarType == WeekCalendarType.outlined,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _calendarType = WeekCalendarType.outlined;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Minimal'),
                            selected: _calendarType == WeekCalendarType.minimal,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _calendarType = WeekCalendarType.minimal;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Elevated'),
                            selected:
                                _calendarType == WeekCalendarType.elevated,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _calendarType = WeekCalendarType.elevated;
                                });
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

              // Custom styled calendar
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Custom Styled Calendar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: WeekCalendar(
                          initialDate: _initialDate,
                          selectedDate: _selectedDate,
                          calendarStyle: WeekCalendarStyle(
                            monthHeaderStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                            dayNameStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.deepPurple,
                            ),
                            activeDayColor: Colors.deepPurple,
                            dayIndicatorColor: Colors.purple.shade50,
                            selectedDayTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          onNextMonth: () {
                            setState(() {
                              _initialDate = DateTime(
                                _initialDate.year,
                                _initialDate.month + 1,
                              );
                            });
                          },
                          onPreviousMonth: () {
                            setState(() {
                              _initialDate = DateTime(
                                _initialDate.year,
                                _initialDate.month - 1,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Reset button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _initialDate = DateTime.now();
                    _calendarType = WeekCalendarType.standard;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Today'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
