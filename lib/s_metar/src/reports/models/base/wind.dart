part of '../../reports.dart';

final compassDirs = <String, List<double>>{
  'NNE': [11.25, 33.75],
  'NE': [33.75, 56.25],
  'ENE': [56.25, 78.75],
  'E': [78.75, 101.25],
  'ESE': [101.25, 123.75],
  'SE': [123.75, 146.25],
  'SSE': [146.25, 168.75],
  'S': [168.75, 191.25],
  'SSW': [191.25, 213.75],
  'SW': [213.75, 236.25],
  'WSW': [236.25, 258.75],
  'W': [258.75, 281.25],
  'WNW': [281.25, 303.75],
  'NW': [303.75, 326.25],
  'NNW': [326.25, 348.75],
  'N': [348.75, 11.25],
};

/// Basic structure for directions attributes.
class Direction extends Numeric {
  late bool _variable;

  Direction(String? code) : super(null) {
    if (code == null || code == '//') {
      code = '///';
    }

    if (code.length == 2) {
      code = '${code}0';
    }

    assert(
        code.length == 3, 'wind direction code must have 3 or 2 digits length');

    double? direction;
    _variable = false;

    try {
      direction = double.parse(code);
    } catch (e) {
      if (code == 'VRB') {
        _variable = true;
      }
      direction = null;
    } finally {
      _value = direction;
    }
  }

  /// Factory constructor to create a Direction object from a cardinal
  /// direction code.
  /// Throws:
  ///     AssertionError: Raised if code is not in compassDirs keys.
  factory Direction.fromCardinal(String code) {
    if (code == 'N') {
      return Direction('360');
    }

    final keys = compassDirs.keys;
    for (var key in keys) {
      if (key == code) {
        final dirs = compassDirs[key];
        final meanDir = dirs!.reduce((a, b) => a + b) / 2;
        final strDir = '${meanDir.toInt()}'.padLeft(3, '0');
        return Direction(strDir);
      }
    }

    throw AssertionError(
        'invalid cardinal direction code, use one of the following: ${compassDirs.keys}');
  }

  @override
  String toString() {
    if (_variable) {
      return 'variable wind';
    }

    if (_value != null) {
      return '${super.toString()}°';
    }

    return super.toString();
  }

  /// Get the cardinal direction associated to the wind direction, e.g. "NW" (north west).
  String? get cardinal {
    String? cardinal;
    final value = converted(conversionDouble: 1);

    if (value != null) {
      final northDirs = compassDirs['N'];

      if (value >= northDirs![0] || value < northDirs[1]) {
        cardinal = 'N';
      }

      compassDirs.forEach((k, v) {
        if (value >= v[0] && value < v[1]) {
          cardinal = k;
          return;
        }
      });
    }

    return cardinal;
  }

  /// Get True if direction is `VRB` in the report. False otherwise.
  bool get variable => _variable;

  /// Get the direction in degrees.
  double? get inDegrees => _value;

  /// Get the direction in radians.
  double? get inRadians =>
      converted(conversionDouble: Conversions.degreesToRadians);

  /// Get the direction in gradians.
  double? get inGradians =>
      converted(conversionDouble: Conversions.degreesToGradians);

  @override
  Map<String, Object?> asMap() {
    return {
      'cardinal': cardinal,
      'variable': variable,
      'units': 'degrees',
      'direction': inDegrees,
    };
  }
}

/// Basic structure for speed attributes.
class Speed extends Numeric {
  Speed(String? code) : super(null) {
    if (code == null || code == '//') {
      code = '///';
    }

    if (code.length == 2) {
      code = '0$code';
    }

    assert(code.length >= 3, 'wind speed code must have 2 or 3 digits length');

    _value = double.tryParse(code);
  }

  @override
  String toString() {
    if (_value != null) {
      return '${super.toString()} kt';
    }

    return super.toString();
  }

  /// Get the speed in knot.
  double? get inKnot => _value;

  /// Get the speed in meters per second.
  double? get inMps => converted(conversionDouble: Conversions.knotToMps);

  /// Get the speed in kilometers per hour.
  double? get inKph => converted(conversionDouble: Conversions.knotToKph);

  /// Get the speed in miles per hour.
  double? get inMiph => converted(conversionDouble: Conversions.knotToMiph);

  /// Get the [Beaufort scale](https://en.wikipedia.org/wiki/Beaufort_scale) number (0–12)
  /// representing wind speed intensity, or `null` if speed is unknown.
  int? get beaufort {
    final kt = inKnot;
    if (kt == null) return null;
    if (kt < 1) return 0;
    if (kt <= 3) return 1;
    if (kt <= 6) return 2;
    if (kt <= 10) return 3;
    if (kt <= 16) return 4;
    if (kt <= 21) return 5;
    if (kt <= 27) return 6;
    if (kt <= 33) return 7;
    if (kt <= 40) return 8;
    if (kt <= 47) return 9;
    if (kt <= 55) return 10;
    if (kt <= 63) return 11;
    return 12;
  }

  /// Get a plain-English description of the Beaufort scale number, or `null`
  /// if speed is unknown.
  String? get beaufortDescription {
    const descriptions = <String>[
      'calm',
      'light air',
      'light breeze',
      'gentle breeze',
      'moderate breeze',
      'fresh breeze',
      'strong breeze',
      'near gale',
      'gale',
      'strong gale',
      'storm',
      'violent storm',
      'hurricane force',
    ];
    final b = beaufort;
    if (b == null) return null;
    return descriptions[b];
  }

  @override
  Map<String, Object?> asMap() {
    return {
      'units': 'knot',
      'speed': inKnot,
      'beaufort': beaufort,
    };
  }
}

/// Basic structure for wind groups in report from land stations.
class Wind {
  Direction _direction = Direction(null);
  Speed _speed = Speed(null);

  Wind({String? direction, String? speed}) {
    _direction = Direction(direction);
    _speed = Speed(speed);
  }

  @override
  String toString() {
    final cardinal = cardinalDirection ?? '';

    var direction = _direction.toString();
    direction = _direction.value != null ? '($_direction)' : direction;

    var s = '$cardinal $direction $_speed';
    s = s.replaceAll(RegExp(r'\s{2,}'), ' ');
    s = s.trim();

    return s;
  }

  /// Helper to convert wind speed in meters per second to knots.
  String _mps2kt(String value) {
    var valueFloat = double.tryParse(value);

    if (valueFloat == null) {
      return '///';
    }

    valueFloat *= Conversions.mpsToKnot;
    final valueIntAsString = valueFloat.toString();

    return valueIntAsString;
  }

  /// Get the cardinal direction associated to the wind direction.
  String? get cardinalDirection => _direction.cardinal;

  /// Get if the wind direction is variable in report.
  bool get variable => _direction.variable;

  /// Get `true` if wind is calm (direction 000, speed 0 kt).
  bool get isCalm =>
      (_direction.inDegrees == 0 || _direction.inDegrees == null) &&
      (_speed.inKnot == 0);

  /// Get the wind direction in degrees.
  double? get directionInDegrees => _direction.inDegrees;

  /// Get the wind direction in radians.
  double? get directionInRadians => _direction.inRadians;

  /// Get the wind direction in gradians.
  double? get directionInGradians => _direction.inGradians;

  /// Get the wind speed in knots.
  double? get speedInKnot => _speed.inKnot;

  /// Get the wind speed in meters per second.
  double? get speedInMps => _speed.inMps;

  /// Get the wind speed in kilometers per hour.
  double? get speedInKph => _speed.inKph;

  /// Get the wind speed in miles per hour.
  double? get speedInMiph => _speed.inMiph;

  Map<String, Object?> asMap() {
    return {
      'direction': _direction.asMap(),
      'speed': _speed.asMap(),
    };
  }

  String toJSON() {
    return jsonEncode(asMap());
  }
}
