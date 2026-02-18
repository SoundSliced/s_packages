part of '../../reports.dart';

/// Basic structure for significant change periods in TAF.
class ChangeForecasted extends Forecast {
  late final Valid _valid;
  late TafChangeIndicator _changeIndicator;
  ChangeForecasted(super.code, Valid valid) {
    // Initialize valid period of the forecasts
    _valid = valid;

    // Groups
    _changeIndicator = TafChangeIndicator(null, null, valid);

    // Parse groups
    _parse();
  }

  @override
  String toString() {
    _string = '';
    _concatenateString(_changeIndicator);

    return _string;
  }

  void _handleChangeIndicator(String group) {
    final match = TafRegExp.changeIndicator.firstMatch(group);
    _changeIndicator = TafChangeIndicator(group, match, _valid);
  }

  /// Get the change indicator data of the change period.
  TafChangeIndicator get changeIndicator => _changeIndicator;

  void _handleValidPeriod(String group) {
    final match = TafRegExp.valid.firstMatch(group);
    _changeIndicator.setValidPeriod(group, match!, _valid.periodFrom);
  }

  void _parse() {
    final handlers = <GroupHandler>[
      GroupHandler(TafRegExp.changeIndicator, _handleChangeIndicator),
      GroupHandler(TafRegExp.valid, _handleValidPeriod),
      GroupHandler(TafRegExp.wind, _handleWind),
      GroupHandler(MetarRegExp.visibility, _handlePrevailing),
      GroupHandler(MetarRegExp.weather, _handleWeather),
      GroupHandler(MetarRegExp.weather, _handleWeather),
      GroupHandler(MetarRegExp.weather, _handleWeather),
      GroupHandler(MetarRegExp.cloud, _handleCloud),
      GroupHandler(MetarRegExp.cloud, _handleCloud),
      GroupHandler(MetarRegExp.cloud, _handleCloud),
      GroupHandler(MetarRegExp.cloud, _handleCloud),
    ];

    var sanitizedCode = sanitizeChangeIndicator(_code!);
    sanitizedCode = sanitizeVisibility(sanitizedCode);
    final unparsed = parseSection(handlers, sanitizedCode);
    _unparsedGroups.addAll(unparsed);
  }
}

/// Basic structure for weather change periods in TAF.
class TafChangesForecasted extends GroupList<ChangeForecasted> {
  TafChangesForecasted() : super(8);

  @override
  String toString() {
    return _list.join('\n');
  }

  /// Adds weather changes to the list.
  @override
  void add(ChangeForecasted newChange) {
    if (_list.isNotEmpty) {
      if (newChange.code!.startsWith('FM') ||
          newChange.code!.startsWith('BECMG')) {
        final tempChanges = <ChangeForecasted>[];

        var lastChange = _list.removeLast();
        while (true) {
          if (lastChange.changeIndicator.code!.startsWith('PROB') ||
              lastChange.changeIndicator.code!.startsWith('TEMPO')) {
            tempChanges.add(lastChange);
            try {
              lastChange = _list.removeLast();
            } catch (e) {
              break;
            }
          } else if (lastChange.changeIndicator.code!.startsWith('FM')) {
            lastChange.changeIndicator
                .resetUntilPeriod(newChange.changeIndicator.valid.periodFrom);
            tempChanges.add(lastChange);
            break;
          } else {
            tempChanges.add(lastChange);
            break;
          }
        }

        for (final tempChange in tempChanges.reversed) {
          super.add(tempChange);
        }
      }
    }

    super.add(newChange);
  }
}
