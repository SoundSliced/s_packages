 
import 'package:s_packages/s_packages.dart';

/// Configuration for AM/PM toggle buttons styling
class AmPmButtonStyle {
  const AmPmButtonStyle({
    this.textStyle,
    this.constraints,
    this.selectedColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
  });
  final TextStyle? textStyle;
  final BoxConstraints? constraints;
  final Color? selectedColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;

  static const defaultStyle = AmPmButtonStyle(
    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    constraints: BoxConstraints(minWidth: 48, minHeight: 40),
    borderWidth: 1,
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );
}

class TimeSpinner extends StatefulWidget {
  // Styling for AM/PM buttons
  const TimeSpinner({
    required this.onChangedSelectedTime,
    super.key,
    this.initTime,
    this.is24HourFormat = false,
    this.spinnerHeight = 120,
    this.spinnerWidth = 60,
    this.elementsSpace = 8,
    this.digitHeight = 40,
    this.spinnerBgColor = const Color(0xFFF5F5F5),
    this.selectedTextStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    ),
    this.nonSelectedTextStyle = const TextStyle(
      fontSize: 18,
      color: Color(0xFFBDBDBD),
    ),
    this.hrValues,
    this.minValues,
    this.discardedHrValues = const [],
    this.discardedMinValues = const [],
    this.borderRadius,
    this.spinnerBorder,
    this.onKeyboardEditing,
    this.showNoSelectionDots = true,
    this.amPmButtonStyle,
    this.isInfiniteScroll = true,
  });
  // Initialize parameters for the time picker
  final TimeOfDay? initTime; // Initial time value
  final bool is24HourFormat; // Indicates if the time format is 24-hour
  final double spinnerHeight; // Height of the widget
  final double spinnerWidth; // Width of the widget
  final double elementsSpace; // Space between hour and minute pickers
  final double digitHeight; // Height of individual time elements
  final Color spinnerBgColor; // Background color of the widget
  final TextStyle selectedTextStyle; // Text style for selected time elements
  final TextStyle
      nonSelectedTextStyle; // Text style for non-selected time elements
  final void Function(TimeOfDay? selected)
      onChangedSelectedTime; // Callback for time selection
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? spinnerBorder;
  final Function? onKeyboardEditing;
  final List<int>? hrValues;
  final List<int>? minValues;
  final List<int> discardedHrValues;
  final List<int> discardedMinValues;
  final bool showNoSelectionDots;
  final AmPmButtonStyle? amPmButtonStyle;
  final bool isInfiniteScroll;

  @override
  State<TimeSpinner> createState() => _TimeSpinnerState();
}

// Define the state for the SpinnerTimePicker widget
class _TimeSpinnerState extends State<TimeSpinner> {
  DayPeriod selectedDayPeriod = DayPeriod.am; // Selected AM/PM period
  int? selectedHour; // Selected hour value
  int selectedMinute = 0; // Selected minute value
  bool isHourTFC = false, isMinTFC = false;

  // Options for AM and PM periods
  final _dayPeriodOptions = const [DayPeriod.am, DayPeriod.pm];

  // Computed values for hr and min values
  List<int>? _effectiveHrValues;
  List<int>? _effectiveMinValues;

  // Helper to calculate discarded hours based on format and AM/PM
  List<int> get _effectiveDiscardedHrValues {
    if (widget.is24HourFormat) {
      return widget.discardedHrValues;
    }

    final offset = selectedDayPeriod == DayPeriod.pm ? 12 : 0;
    return widget.discardedHrValues
        .where((h) => h >= offset && h < offset + 12)
        .map((h) => h - offset)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeEffectiveValues();
    _initializeTimeValues();
  }

  /// Initialize effective hr and min values based on widget parameters
  void _initializeEffectiveValues() {
    // If null is given, use default values based on is24HourFormat
    // If empty list is given, treat it as null (show dots)
    _effectiveHrValues = widget.hrValues == null
        ? (widget.is24HourFormat
            ? List.generate(24, (i) => i)
            : List.generate(12, (i) => i))
        : (widget.hrValues!.isEmpty ? null : widget.hrValues);

    _effectiveMinValues = widget.minValues == null
        ? List.generate(60, (i) => i)
        : (widget.minValues!.isEmpty ? null : widget.minValues);
  }

  /// Initialize time values from widget.initTime
  void _initializeTimeValues() {
    if (widget.initTime != null) {
      selectedDayPeriod = widget.initTime!.period;
      selectedHour = !widget.is24HourFormat && selectedDayPeriod == DayPeriod.pm
          ? widget.initTime!.hour - 12
          : widget.initTime!.hour;
      selectedMinute = widget.initTime!.minute;
    }
  }

  @override
  void didUpdateWidget(TimeSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if parameters that affect effective values have changed
    final needsValueUpdate =
        oldWidget.is24HourFormat != widget.is24HourFormat ||
            oldWidget.hrValues != widget.hrValues ||
            oldWidget.minValues != widget.minValues;

    if (needsValueUpdate) {
      setState(_initializeEffectiveValues);
    }

    // Update time values if initTime changed
    if (oldWidget.initTime != widget.initTime && widget.initTime != null) {
      setState(_initializeTimeValues);
    }
  }

  // Get a list indicating which day period is selected
  List<bool> get _isSelectedDayPeriod => switch (selectedDayPeriod) {
        DayPeriod.am => [true, false], // AM is selected
        DayPeriod.pm => [false, true], // PM is selected
      };

  @override
  Widget build(BuildContext context) {
    // Build the time picker layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        //hour spinner widget
        Flexible(
          child: AnimatedSwitcher(
            duration: 0.2.sec,
            child: isHourTFC == false
                ? SInkButton(
                    key: ValueKey('hour Spinner + $isHourTFC'),
                    onDoubleTap: (position) {
                      setState(() {
                        //de-activate the minutes TFC (if it was activated)
                        if (isMinTFC) {
                          isMinTFC = false;
                        }
                        //activate the hour TFC
                        isHourTFC = true;
                        widget.onKeyboardEditing?.call();
                        //log("MySpinnerTimePicker | isHourTFC: $isHourTFC");
                      });
                    },
                    child: _hourPicker(),
                  )
                : DigitTfcWidget(
                    key: ValueKey('hour TFC + $isHourTFC'),
                    digits: selectedHour,
                    shouldDotsOnEmptyTfc: true,
                    onInputComplete: (newValue) {
                      setState(() {
                        selectedHour = newValue;
                        isHourTFC = false;
                        // log("MySpinnerTimePicker | newValue Hour: $newValue");
                      });
                      setSelectedTime();
                    },
                  ),
          ),
        ),

        //separator widget
        _timeSeparator(context),

        //minute spinner widget
        Flexible(
          child: AnimatedSwitcher(
            duration: 0.2.sec,
            child: isMinTFC == false
                ? SInkButton(
                    key: ValueKey('min Spinner + $isMinTFC'),
                    onDoubleTap: (position) {
                      setState(() {
                        //de-activate the hour TFC (if it was activated)
                        if (isHourTFC) {
                          isHourTFC = false;
                        }
                        //activate the minutes TFC
                        isMinTFC = true;
                        widget.onKeyboardEditing?.call();
                        // log("MySpinnerTimePicker | isMinTFC: $isMinTFC");
                      });
                    },
                    child: _minutePicker(),
                  )
                : DigitTfcWidget(
                    key: ValueKey('min TFC + $isHourTFC'),
                    digits: selectedMinute,
                    onInputComplete: (newValue) {
                      setState(() {
                        selectedMinute = newValue ?? 0;
                        isMinTFC = false;
                        //log("MySpinnerTimePicker | newValue Minute: $newValue");
                      });
                      setSelectedTime();
                    }),
          ),
        ),

        //extra widgets
        if (!widget.is24HourFormat) SizedBox(width: 0.7 * widget.elementsSpace),
        if (!widget.is24HourFormat) _dayPeriodSelector(),
      ],
    );
  }

  // Build the day period selector toggle buttons
  ToggleButtons _dayPeriodSelector() {
    final style = widget.amPmButtonStyle ?? AmPmButtonStyle.defaultStyle;

    return ToggleButtons(
      isSelected: _isSelectedDayPeriod,
      direction: Axis.vertical,
      constraints:
          style.constraints ?? AmPmButtonStyle.defaultStyle.constraints!,
      fillColor: style.selectedColor,
      borderColor: style.borderColor,
      selectedBorderColor: style.borderColor,
      borderWidth:
          style.borderWidth ?? AmPmButtonStyle.defaultStyle.borderWidth!,
      borderRadius:
          style.borderRadius ?? AmPmButtonStyle.defaultStyle.borderRadius!,
      onPressed: (index) {
        setState(() {
          selectedDayPeriod = _dayPeriodOptions[index];
        });
        setSelectedTime();
      },
      children: _dayPeriodOptions
          .map((option) => Text(
                option.name.toUpperCase(),
                style:
                    style.textStyle ?? AmPmButtonStyle.defaultStyle.textStyle,
              ))
          .toList(),
    );
  }

  // Build the hour picker
  MySpinnerNumericPicker _hourPicker() => MySpinnerNumericPicker(
        maxValue: widget.is24HourFormat ? 24 : 12,
        initValue: selectedHour,
        height: widget.spinnerHeight,
        width: widget.spinnerWidth,
        digitHeight: widget.digitHeight,
        nonSelectedTextStyle: widget.nonSelectedTextStyle,
        selectedTextStyle: widget.selectedTextStyle,
        spinnerBgColor: widget.spinnerBgColor,
        borderRadius: widget.borderRadius,
        spinnerBorder: widget.spinnerBorder,
        values: _effectiveHrValues,
        discardedValues: _effectiveDiscardedHrValues,
        showNoSelectionDots: widget.showNoSelectionDots,
        isInfiniteScroll: widget.isInfiniteScroll,
        onSelectedItemChanged: (value) async {
          setState(() {
            selectedHour = value;
          });
          setSelectedTime();
        },
      );

  // Build the time separator between hour and minute pickers
  SizedBox _timeSeparator(BuildContext context) => SizedBox(
        width: widget.elementsSpace,
        child: Center(
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 25,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  // Build the minute picker
  MySpinnerNumericPicker _minutePicker() => MySpinnerNumericPicker(
        initValue: selectedMinute,
        maxValue: 60,
        height: widget.spinnerHeight,
        width: widget.spinnerWidth,
        digitHeight: widget.digitHeight,
        nonSelectedTextStyle: widget.nonSelectedTextStyle,
        selectedTextStyle: widget.selectedTextStyle,
        spinnerBgColor: widget.spinnerBgColor,
        borderRadius: widget.borderRadius,
        spinnerBorder: widget.spinnerBorder,
        values: _effectiveMinValues,
        discardedValues: widget.discardedMinValues,
        showNoSelectionDots: false,
        isInfiniteScroll: widget.isInfiniteScroll,
        onSelectedItemChanged: (value) {
          setState(() {
            selectedMinute = value ?? 00;
          });
          setSelectedTime();
        },
      );

  // Update the selected time based on user choices
  void setSelectedTime() {
    final offset =
        !widget.is24HourFormat && selectedDayPeriod == DayPeriod.pm ? 12 : 0;

    widget.onChangedSelectedTime(selectedHour == null
        ? null
        : TimeOfDay(hour: selectedHour! + offset, minute: selectedMinute));
  }
}

//******************************** */
class MySpinnerNumericPicker extends StatefulWidget {
  // Add this parameter

  const MySpinnerNumericPicker({
    required this.maxValue,
    required this.height,
    required this.width,
    required this.digitHeight,
    required this.selectedTextStyle,
    required this.nonSelectedTextStyle,
    required this.onSelectedItemChanged,
    required this.spinnerBgColor,
    super.key,
    this.initValue,
    this.borderRadius,
    this.spinnerBorder,
    this.discardedValues = const [],
    this.values,
    this.showNoSelectionDots = true,
    this.isInfiniteScroll = true,
  });
  final int? initValue;
  final int maxValue;
  final double height;
  final double width;
  final double digitHeight;
  final TextStyle selectedTextStyle;
  final TextStyle nonSelectedTextStyle;
  final Color spinnerBgColor;
  final void Function(int? value) onSelectedItemChanged; // Allow null value
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? spinnerBorder;
  final List<int> discardedValues;
  final List<int>? values;
  final bool showNoSelectionDots;
  final bool isInfiniteScroll;

  @override
  State<MySpinnerNumericPicker> createState() => _MySpinnerNumericPickerState();
}

class _MySpinnerNumericPickerState extends State<MySpinnerNumericPicker> {
  late FixedExtentScrollController scrollController;
  late int? _selectedValue;
  late List<int> availableValues;
  late bool _showOnlyDots;
  late bool _showOnlyOneValue;
  int get _loopMultiplier => widget.isInfiniteScroll ? 1000 : 1;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  /// Initialize all state variables and controllers
  void _initializeState() {
    _showOnlyDots = widget.values == null;
    _showOnlyOneValue = widget.values != null &&
        widget.values!.length == 1 &&
        !widget.showNoSelectionDots;

    if (!_showOnlyDots) {
      if (widget.values!.isNotEmpty) {
        availableValues = widget.values!
            .where((value) => !widget.discardedValues.contains(value))
            .toList();
      } else {
        availableValues = List<int>.generate(widget.maxValue, (i) => i)
            .where((value) => !widget.discardedValues.contains(value))
            .toList();
      }

      _selectedValue = widget.initValue ??
          (widget.showNoSelectionDots ? null : availableValues.first);

      // Ensure selected value is valid
      if (_selectedValue != null && !availableValues.contains(_selectedValue)) {
        _selectedValue = widget.showNoSelectionDots
            ? null
            : (availableValues.isNotEmpty ? availableValues.first : null);
      }
    } else {
      availableValues = [];
      _selectedValue = null;
    }

    // Initialize the scroll controller
    final initialItemIndex = _calculateInitialItemIndex();
    scrollController =
        FixedExtentScrollController(initialItem: initialItemIndex);
  }

  /// Calculate the initial item index for the scroll controller
  int _calculateInitialItemIndex() {
    if (_showOnlyDots ||
        (_showOnlyOneValue && widget.showNoSelectionDots) ||
        (widget.showNoSelectionDots && _selectedValue == null)) {
      return 0; // Position of the dots or single value
    }

    final cycleLength =
        availableValues.length + (widget.showNoSelectionDots ? 1 : 0);
    final middleBase = _loopMultiplier ~/ 2 * cycleLength;

    if (_selectedValue != null) {
      // Find the index of the initial value in the available values
      final valueIndex = availableValues.indexOf(_selectedValue!);

      // If value is not found (e.g. it was discarded), default to dots or first item
      if (valueIndex == -1) {
        return middleBase;
      }

      return middleBase + (widget.showNoSelectionDots ? 1 : 0) + valueIndex;
    } else {
      return middleBase;
    }
  }

  @override
  void didUpdateWidget(MySpinnerNumericPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if parameters that affect the spinner have changed
    final needsRebuild = oldWidget.values != widget.values ||
        oldWidget.discardedValues != widget.discardedValues ||
        oldWidget.maxValue != widget.maxValue ||
        oldWidget.showNoSelectionDots != widget.showNoSelectionDots;

    if (needsRebuild) {
      // Dispose old scroll controller
      scrollController.dispose();

      setState(_initializeState);
    } else if (oldWidget.initValue != widget.initValue &&
        widget.initValue != null) {
      // Check if the new value is different from what we currently have selected locally
      // If it's the same, it's likely a loopback from the parent update caused by our own scroll
      if (widget.initValue == _selectedValue) {
        return;
      }

      // Only initValue changed, update selected value and scroll position
      setState(() {
        _selectedValue = widget.initValue;
      });

      // Jump to the new value if it exists in available values
      // Use addPostFrameCallback to avoid setState during build
      if (_selectedValue != null && availableValues.contains(_selectedValue)) {
        final valueIndex = availableValues.indexOf(_selectedValue!);
        final cycleLength =
            availableValues.length + (widget.showNoSelectionDots ? 1 : 0);
        final targetIndex = _loopMultiplier ~/ 2 * cycleLength +
            (widget.showNoSelectionDots ? 1 : 0) +
            valueIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            scrollController.jumpToItem(targetIndex);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.spinnerBgColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          border: widget.spinnerBorder ?? Border.all(),
        ),
        child: ListWheelScrollView.useDelegate(
          controller: scrollController,
          itemExtent: widget.digitHeight,
          physics: const FixedExtentScrollPhysics(),
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (_showOnlyDots) {
                return _buildDots();
              } else if (_showOnlyOneValue) {
                return _buildValueWidget(availableValues.first);
              }

              final cycleLength =
                  availableValues.length + (widget.showNoSelectionDots ? 1 : 0);
              final indexInCycle = index % cycleLength;

              if (widget.showNoSelectionDots && indexInCycle == 0) {
                return _buildDots();
              } else {
                final valueIndex = widget.showNoSelectionDots
                    ? indexInCycle - 1
                    : indexInCycle;
                return _buildValueWidget(availableValues[valueIndex]);
              }
            },
            childCount: _showOnlyDots
                ? 1
                : _showOnlyOneValue
                    ? 1
                    : (availableValues.length +
                            (widget.showNoSelectionDots ? 1 : 0)) *
                        _loopMultiplier,
          ),
          onSelectedItemChanged: (index) {
            if (_showOnlyDots) {
              _updateSelectedValue(null);
            } else if (_showOnlyOneValue) {
              _updateSelectedValue(availableValues.first);
            } else {
              final cycleLength =
                  availableValues.length + (widget.showNoSelectionDots ? 1 : 0);
              final indexInCycle = index % cycleLength;

              if (widget.showNoSelectionDots && indexInCycle == 0) {
                _updateSelectedValue(null);
              } else {
                final valueIndex = widget.showNoSelectionDots
                    ? indexInCycle - 1
                    : indexInCycle;
                _updateSelectedValue(availableValues[valueIndex]);
              }
            }
          },
        ),
      );

  Widget _buildDots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: _selectedValue == null ? 8 : 4),
          const SizedBox(width: 2),
          Icon(Icons.circle, size: _selectedValue == null ? 8 : 4),
        ],
      );

  Widget _buildValueWidget(int value) => Center(
        child: Text(
          value.toString().padLeft(2, '0'),
          style: value == _selectedValue
              ? widget.selectedTextStyle
              : widget.nonSelectedTextStyle,
        ),
      );

  void _updateSelectedValue(int? value) {
    setState(() {
      _selectedValue = value;
    });
    widget.onSelectedItemChanged(_selectedValue);
  }
}

/// **************** Digit TextFormField Widget ********************* ///
///
class DigitTfcWidget extends StatefulWidget {
  const DigitTfcWidget({
    required this.onInputComplete,
    super.key,
    this.digits = 0,
    this.shouldDotsOnEmptyTfc = false,
  });
  final int? digits;
  final bool shouldDotsOnEmptyTfc;
  final Function(int? newValue) onInputComplete;

  @override
  State<DigitTfcWidget> createState() => _DigitTfcWidgetState();
}

class _DigitTfcWidgetState extends State<DigitTfcWidget> {
  FocusNode myFocusNode = FocusNode();
  TextEditingController tfc = TextEditingController();
  bool? isRefreshed = false;

  @override
  void initState() {
    super.initState();

    initiateTFC();
  }

  void initiateTFC() async {
    //initiate the textformfield listener
    tfc.addListener(tfcListeners);

    //initiate the textformfield value
    tfc = TextEditingController(
        text: widget.digits == null
            ? '..'
            : widget.digits! < 10 && widget.digits! >= 0
                ? '0${widget.digits}'
                : widget.digits.toString());

    // Set the selection to position the cursor at the end of the text
    //(first, ensure the widget is built by using Future.delayed)
    Future.delayed(
      0.sec,
      () {
        if (mounted) {
          FocusScope.of(context).requestFocus(myFocusNode);
        }
      },
    );
  }

//listener for changes made in the pwd input textfield box
  void tfcListeners() {
    //first listener: listen if the textfield controller becomes blank
    if (tfc.text.isEmpty) {
      //todo:
    }

    //second listener: check when it is necessary to rebuild the TextFormField Widget
    //based on whether an input has been made or not
    if (isRefreshed != null) {
      setState(
        () => isRefreshed = null,
      );
    } else {
      setState(
        () => isRefreshed = false,
      );
    }
  }

  void _onChanged(String input) {
    //set the inputted value
    if (input == '') {
      if (widget.shouldDotsOnEmptyTfc) {
        widget.onInputComplete(null);
        return;
      }
      input = '00';
    }
    var inputInt = int.parse(input);
    if (inputInt > 59) {
      inputInt = 0;
    }

    //format the tfc
    tfc.text =
        inputInt < 10 && inputInt >= 0 ? '0$inputInt' : inputInt.toString();

    //return the inputed value to the parent widget
    widget.onInputComplete(inputInt);
  }

  @override
  void dispose() {
    //remove listeners
    tfc.removeListener(tfcListeners);
    tfc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: 90,
        width: 60,
        alignment: Alignment.centerLeft,
        padding: const Pad(left: 10, right: 3),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          maxLength: 2,
          controller: tfc,
          autofocus: true,
          focusNode: myFocusNode,
          cursorColor: Colors.blue.shade800,
          keyboardType: TextInputType.number,

          decoration: InputDecoration(
            hintText: '..',
            counterText: '',
            suffixIcon: TextFormFieldClearButton(
              onPressed: () {
                tfc.clear();
                _onChanged('');
              },
            ),
            suffixIconConstraints: BoxConstraints.loose(Size.infinite),
            border: InputBorder.none,
          ),
          //when keypad "Done" is clicked, or when ENTER is pressed on keyboard
          onFieldSubmitted: _onChanged,
          onEditingComplete: () => _onChanged(tfc.text),
          //when user clicks outside of the textfield, treat it as a submission
          onTapOutside: (event) {
            _onChanged(tfc.text);
          },
        ),
      );
}
