part of '../../reports.dart';

/// Basic structure for trend codes in METAR.
class MetarTrendIndicator extends ChangeIndicator {
  late final Time _initPeriod;
  late final Time _endPeriod;
  late Time _from;
  late Time _until;
  Time? _at;

  MetarTrendIndicator(super.code, super.match, DateTime time) {
    // Init period and end period of forecast
    _initPeriod = Time(time: time);
    _endPeriod = Time(time: time.add(const Duration(hours: 2)));

    _from = _initPeriod;
    _until = _endPeriod;
  }

  @override
  String toString() {
    if (_at != null) {
      return '${super.toString()} at $_at';
    }

    if (_translation != null) {
      return '${super.toString()} from $_from until $_until';
    }

    return super.toString();
  }

  /// Helper to add periods of time to the change indicator.
  void addPeriod(String code, RegExpMatch match) {
    _code = '${_code!} $code';

    // The middle time between self._init_period and self._end_period
    final middleTime = _initPeriod.time.add(const Duration(hours: 1));

    final prefix = match.namedGroup('prefix');
    final hour = match.namedGroup('hour');
    final minute = match.namedGroup('min');

    final hourAsInt = int.parse(hour!);
    final minAsInt = int.parse(minute!);

    late final DateTime time;
    late final int minutes;

    if (hourAsInt == _initPeriod.hour) {
      minutes = minAsInt - _initPeriod.minute;
      time = _initPeriod.time.add(Duration(minutes: minutes));
    } else if (hourAsInt == middleTime.hour) {
      minutes = minAsInt - middleTime.minute;
      time = middleTime.add(Duration(minutes: minutes));
    } else {
      minutes = minAsInt - _endPeriod.minute;
      time = _endPeriod.time.add(Duration(minutes: minutes));
    }

    if (prefix == 'FM') {
      _from = Time(time: time);
    } else if (prefix == 'TL') {
      _until = Time(time: time);
    } else {
      _at = Time(time: time);
    }
  }

  /// Get the forcast period, i.e. the initial forecast time and the end
  /// forecast time.
  (Time, Time) get forecastPeriod => (_initPeriod, _endPeriod);

  /// Get the `from` forecast period.
  Time get periodFrom => _from;

  /// Get the `until` forecast period.
  Time get periodUntil => _until;

  /// Get the `at` forecast period.
  Time? get periodAt => _at;

  @override
  Map<String, Object?> asMap() {
    final map = <String, Object?>{
      'forecast_period': {
        'init': forecastPeriod.$1.asMap(),
        'end': forecastPeriod.$2.asMap(),
      },
      'from_': periodFrom.asMap(),
      'until': periodUntil.asMap(),
      'at': periodAt?.asMap(),
    };
    map.addAll(super.asMap());
    return map;
  }
}
