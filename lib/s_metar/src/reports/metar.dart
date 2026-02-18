part of 'reports.dart';

/// Parser for METAR reports.
class Metar extends Report
    with
        ModifierMixin,
        MetarWindMixin,
        MetarPrevailingMixin,
        MetarWeatherMixin,
        MetarCloudMixin,
        FlightRulesMixin,
        ShouldBeCavokMixin {
  late final int? _year, _month;

  // Body groups
  MetarWindVariation _windVariation = MetarWindVariation(null, null);
  MetarMinimumVisibility _minimumVisibility =
      MetarMinimumVisibility(null, null);
  final _runwayRanges = GroupList<MetarRunwayRange>(3);
  MetarTemperatures _temperatures = MetarTemperatures(null, null);
  MetarPressure _pressure = MetarPressure(null, null);
  MetarRecentWeather _recentWeather = MetarRecentWeather(null, null);
  final _windshears = MetarWindshearList();
  MetarSeaState _seaState = MetarSeaState(null, null);
  MetarRunwayState _runwayState = MetarRunwayState(null, null);

  // Trend groups
  final MetarWeatherTrends _weatherTrends = MetarWeatherTrends();

  Metar(
    String code, {
    int? year,
    int? month,
    bool truncate = false,
  }) : super(code, truncate) {
    _handleSections();

    _year = year;
    _month = month;

    // Initialize Time group
    _time = Time.fromMetar(year: year, month: month);

    // Parse body groups
    _parseBody();

    // Parse trend groups
    _parseWeatherTrend();
  }

  /// Get the body part of the METAR.
  String get body => _sections[0];

  /// Get the trend part of the METAR.
  String get trend => _sections[1];

  /// Get the remark part of the METAR.
  String get remark => _sections[2];

  @override
  void _handleTime(String group) {
    final match = MetarRegExp.time.firstMatch(group)!;
    _time =
        Time.fromMetar(code: group, match: match, year: _year, month: _month);

    _concatenateString(_time);
  }

  void _handleWindVariation(String group) {
    final match = MetarRegExp.windVariation.firstMatch(group);
    _windVariation = MetarWindVariation(group, match);

    _concatenateString(_windVariation);
  }

  /// Get the wind variation directions of the METAR.
  MetarWindVariation get windVariation => _windVariation;

  void _handleMinimumVisibility(String group) {
    final match = MetarRegExp.visibility.firstMatch(group);
    _minimumVisibility = MetarMinimumVisibility(group, match);

    _concatenateString(_minimumVisibility);
  }

  /// Get the minimum visibility data of the METAR.
  MetarMinimumVisibility get minimumVisibility => _minimumVisibility;

  void _handleRunwayRange(String group) {
    final match = MetarRegExp.runwayRange.firstMatch(group);
    final range = MetarRunwayRange(group, match);
    _runwayRanges.add(range);

    _concatenateString(range);
  }

  /// Get the runway ranges data of the METAR if provided.
  GroupList<MetarRunwayRange> get runwayRanges => _runwayRanges;

  void _handleTemperatures(String group) {
    final match = MetarRegExp.temperatures.firstMatch(group);
    _temperatures = MetarTemperatures(group, match);

    _concatenateString(_temperatures);
  }

  /// Get the temperatures data of the METAR.
  MetarTemperatures get temperatures => _temperatures;

  void _handlePressure(String group) {
    final match = MetarRegExp.pressure.firstMatch(group);
    _pressure = MetarPressure(group, match);

    _concatenateString(_pressure);
  }

  /// Get the pressure of the METAR.
  MetarPressure get pressure => _pressure;

  void _handleRecentWeather(String group) {
    final match = MetarRegExp.recentWeather.firstMatch(group);
    _recentWeather = MetarRecentWeather(group, match);

    _concatenateString(_recentWeather);
  }

  /// Get the recent weather data of the METAR.
  MetarRecentWeather get recentWeather => _recentWeather;

  void _handleWindshear(String group) {
    final match = MetarRegExp.windshear.firstMatch(group);
    final windshear = MetarWindshearRunway(group, match);
    _windshears.add(windshear);

    _concatenateString(windshear);
  }

  /// Get the windshear data of the METAR.
  MetarWindshearList get windshears => _windshears;

  void _handleSeaState(String group) {
    final match = MetarRegExp.seaState.firstMatch(group);
    _seaState = MetarSeaState(group, match);

    _concatenateString(_seaState);
  }

  /// Get the sea state data of the METAR.
  MetarSeaState get seaState => _seaState;

  void _handleRunwayState(String group) {
    final match = MetarRegExp.runwayState.firstMatch(group);
    _runwayState = MetarRunwayState(group, match);

    _concatenateString(_runwayState);
  }

  /// Get the runway state data of the METAR.
  MetarRunwayState get runwayState => _runwayState;

  void _handleWeatherTrend(String code) {
    final wt = ChangePeriod(code, _time.time);
    _weatherTrends.add(wt);

    _concatenateString(wt);
  }

  /// Get the weather trends of the METAR if provided.
  MetarWeatherTrends get weatherTrends => _weatherTrends;

  /// Parse the body section.
  void _parseBody() {
    final handlers = <GroupHandler>[
      GroupHandler(MetarRegExp.type, _handleType),
      GroupHandler(MetarRegExp.station, _handleStation),
      GroupHandler(MetarRegExp.time, _handleTime),
      GroupHandler(MetarRegExp.modifier, _handleModifier),
      GroupHandler(MetarRegExp.wind, _handleWind),
      GroupHandler(MetarRegExp.windVariation, _handleWindVariation),
      GroupHandler(MetarRegExp.visibility, _handlePrevailing),
      GroupHandler(MetarRegExp.minimumVisibility, _handleMinimumVisibility),
      GroupHandler(MetarRegExp.runwayRange, _handleRunwayRange),
      GroupHandler(MetarRegExp.runwayRange, _handleRunwayRange),
      GroupHandler(MetarRegExp.runwayRange, _handleRunwayRange),
      GroupHandler(MetarRegExp.weather, _handleWeather),
      GroupHandler(MetarRegExp.weather, _handleWeather),
      GroupHandler(MetarRegExp.weather, _handleWeather),
      GroupHandler(MetarRegExp.cloud, _handleCloud),
      GroupHandler(MetarRegExp.cloud, _handleCloud),
      GroupHandler(MetarRegExp.cloud, _handleCloud),
      GroupHandler(MetarRegExp.cloud, _handleCloud),
      GroupHandler(MetarRegExp.temperatures, _handleTemperatures),
      GroupHandler(MetarRegExp.pressure, _handlePressure),
      GroupHandler(MetarRegExp.pressure, _handlePressure),
      GroupHandler(MetarRegExp.recentWeather, _handleRecentWeather),
      GroupHandler(MetarRegExp.windshear, _handleWindshear),
      GroupHandler(MetarRegExp.windshear, _handleWindshear),
      GroupHandler(MetarRegExp.windshear, _handleWindshear),
      GroupHandler(MetarRegExp.seaState, _handleSeaState),
      GroupHandler(MetarRegExp.runwayState, _handleRunwayState),
    ];

    var sanitizedBody = sanitizeVisibility(body);
    sanitizedBody = sanitizeWindshear(sanitizedBody);

    final unparsed = parseSection(handlers, sanitizedBody);
    _unparsedGroups.addAll(unparsed);
  }

  /// Parse the weather trend section.
  ///
  /// Raises:
  ///     ParserError: if self.unparser_groups has items and self._truncate is True,
  ///     raises the error.
  void _parseWeatherTrend() {
    final trends = splitSentence(trend, ['TEMPO', 'BECMG'], space: 'both');

    for (final trend in trends) {
      if (trend != '') {
        _handleWeatherTrend(trend);
      }
    }

    for (final wt in _weatherTrends.items) {
      _unparsedGroups.addAll(wt.unparsedGroups);
    }

    if (unparsedGroups.isNotEmpty && _truncate) {
      throw ParserError(
        'failed while processing ${unparsedGroups.join(" ")} from: $rawCode',
      );
    }
  }

  @override
  void _handleSections() {
    final sections = splitSentence(
      _rawCode,
      <String>[
        'NOSIG',
        'TEMPO',
        'BECMG',
        'RMK',
      ],
      space: 'left',
    );

    var trend = '';
    var remark = '';
    var body = '';
    for (final section in sections) {
      if (section.startsWith('TEMPO') ||
          section.startsWith('BECMG') ||
          section.startsWith('NOSIG')) {
        trend += '$section ';
      } else if (section.startsWith('RMK')) {
        remark = section;
      } else {
        body = section;
      }
    }

    _sections.add(body);
    _sections.add(trend.trim());
    _sections.add(remark);
  }

  @override
  Map<String, Object?> asMap() {
    final map = super.asMap();
    map.addAll({
      'modifier': modifier.asMap(),
      'wind': wind.asMap(),
      'wind_variation': windVariation.asMap(),
      'prevailing_visibility': prevailingVisibility.asMap(),
      'minimum_visibility': minimumVisibility.asMap(),
      'runway_ranges': runwayRanges.asMap(),
      'weathers': weathers.asMap(),
      'clouds': clouds.asMap(),
      'temperatures': temperatures.asMap(),
      'pressure': pressure.asMap(),
      'recent_weather': recentWeather.asMap(),
      'windshear': windshears.asMap(),
      'sea_state': seaState.asMap(),
      'runway_state': runwayState.asMap(),
      'flight_rules': flightRules,
      'weather_trends': weatherTrends.asMap(),
      'remark': remark,
    });
    return map;
  }
}
