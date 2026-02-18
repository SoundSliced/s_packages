part of '../../reports.dart';

/// Basic structure for temperatures in reports from land stations.
class MetarTemperatures extends Group {
  Temperature _temperature = Temperature(null);
  Temperature _dewpoint = Temperature(null);

  MetarTemperatures(super.code, RegExpMatch? match) {
    if (match != null) {
      final tsign = match.namedGroup('tsign');
      final temp = match.namedGroup('temp');
      final dsign = match.namedGroup('dsign');
      final dewpt = match.namedGroup('dewpt');

      _temperature = _setTemperature(temp, tsign);
      _dewpoint = _setTemperature(dewpt, dsign);
    }
  }

  @override
  String toString() {
    if (_temperature.value == null && _dewpoint.value == null) {
      return '';
    } else if (_temperature.value == null && _dewpoint.value != null) {
      return 'no temperature | dewpoint: $_dewpoint';
    } else if (_temperature.value != null && _dewpoint.value == null) {
      return 'temperature: $_temperature | no dewpoint';
    } else {
      return 'temperature: $_temperature | dewpoint: $_dewpoint';
    }
  }

  /// Handler to set the temperature value.
  Temperature _setTemperature(String? code, String? sign) {
    if (<String>['M', '-'].contains(sign)) {
      return Temperature('-$code');
    }

    return Temperature('$code');
  }

  /// Get the temperature in °Celsius.
  double? get temperatureInCelsius => _temperature.inCelsius;

  /// Get the temperature in °Kelvin.
  double? get temperatureInKelvin => _temperature.inKelvin;

  /// Get the temperature in °Fahrenheit.
  double? get temperatureInFahrenheit => _temperature.inFahrenheit;

  /// Get the temperature in Rankine.
  double? get temperatureInRankine => _temperature.inRankine;

  /// Get the dewpoint in °Celsius.
  double? get dewpointInCelsius => _dewpoint.inCelsius;

  /// Get the dewpoint in °Kelvin.
  double? get dewpointInKelvin => _dewpoint.inKelvin;

  /// Get the dewpoint in °Fahrenheit.
  double? get dewpointInFahrenheit => _dewpoint.inFahrenheit;

  /// Get the dewpoint in Rankine.
  double? get dewpointInRankine => _dewpoint.inRankine;

  /// Get the dewpoint spread (temperature − dewpoint) in °Celsius.
  ///
  /// A spread less than 3 °C is associated with a high likelihood of fog or
  /// low cloud formation. Returns `null` if either value is unavailable.
  double? get dewpointSpread {
    final t = temperatureInCelsius;
    final dp = dewpointInCelsius;
    if (t == null || dp == null) return null;
    return t - dp;
  }

  /// Get the relative humidity as a percentage (0–100) using the
  /// Magnus-Tetens approximation, or `null` if either value is unavailable.
  double? get relativeHumidity {
    final t = temperatureInCelsius;
    final dp = dewpointInCelsius;
    if (t == null || dp == null) return null;
    // Magnus formula
    const a = 17.625;
    const b = 243.04;
    final gamma = (a * dp) / (b + dp);
    final gammaTa = (a * t) / (b + t);
    return 100.0 * exp(gamma) / exp(gammaTa);
  }

  /// Get the NOAA heat index in °Celsius, or `null` if conditions are
  /// outside the valid range (temperature ≥ 27 °C, RH ≥ 40 %).
  ///
  /// Reference: Rothfusz (1990) NWS Technical Attachment SR90-23.
  double? get heatIndex {
    final tC = temperatureInCelsius;
    final rh = relativeHumidity;
    if (tC == null || rh == null) return null;
    if (tC < 27.0 || rh < 40.0) return null;
    final tF = tC * 9 / 5 + 32;
    // Rothfusz regression in °F
    final hi = -42.379 +
        2.04901523 * tF +
        10.14333127 * rh -
        0.22475541 * tF * rh -
        0.00683783 * tF * tF -
        0.05481717 * rh * rh +
        0.00122874 * tF * tF * rh +
        0.00085282 * tF * rh * rh -
        0.00000199 * tF * tF * rh * rh;
    return (hi - 32) * 5 / 9;
  }

  /// Get the wind chill temperature in °Celsius, or `null` if conditions are
  /// outside the valid range (temperature ≤ 10 °C, wind speed ≥ 4.8 km/h).
  ///
  /// [windSpeedKph] is the 10-m wind speed in km/h (use `speedInKph` from
  /// the METAR wind group).
  ///
  /// Reference: Environment Canada / NWS formula (2001).
  double? windChill(double? windSpeedKph) {
    final t = temperatureInCelsius;
    if (t == null || windSpeedKph == null) return null;
    if (t > 10.0 || windSpeedKph < 4.8) return null;
    final v016 = pow(windSpeedKph, 0.16);
    return 13.12 + 0.6215 * t - 11.37 * v016 + 0.3965 * t * v016;
  }

  @override
  Map<String, Object?> asMap() {
    final map = super.asMap();
    map.addAll({
      'temperature': _temperature.asMap(),
      'dewpoint': _dewpoint.asMap(),
      'dewpoint_spread': dewpointSpread,
      'relative_humidity': relativeHumidity,
      'heat_index': heatIndex,
    });
    return map;
  }
}
