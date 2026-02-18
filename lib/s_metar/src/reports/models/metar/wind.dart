part of '../../reports.dart';

class MetarWind extends Wind with GroupMixin {
  Speed _gust = Speed(null);

  MetarWind(String? code, RegExpMatch? match)
      : super(
          direction: null,
          speed: null,
        ) {
    if (match == null) {
      _code = null;
    } else {
      final dir = match.namedGroup('dir');
      var spd = match.namedGroup('speed');
      var gst = match.namedGroup('gust');
      final unt = match.namedGroup('units');

      spd ??= '///';
      gst ??= '///';

      if (unt == 'MPS') {
        spd = _mps2kt(spd);
        gst = _mps2kt(gst);
      }

      _direction = Direction(dir);
      _speed = Speed(spd);
      _gust = Speed(gst);
      _code = code;
    }
  }

  @override
  String toString() {
    final gust = _gust.value != null ? ' gust of $_gust' : '';

    return super.toString() + gust;
  }

  /// Get the wind gusts in knots.
  double? get gustInKnot => _gust.inKnot;

  /// Get the wind gusts in meters per second.
  double? get gustInMps => _gust.inMps;

  /// Get the wind gusts in kilometers per hour.
  double? get gustInKph => _gust.inKph;

  // Get the wind gusts in miles per hour.
  double? get gustInMiph => _gust.inMiph;

  @override
  Map<String, Object?> asMap() {
    final map = super.asMap().cast<String, Object?>();
    map.addAll({
      'code': _code,
      'gust': _gust.asMap(),
    });
    return map;
  }
}

/// Mixin to add a METAR wind group attribute to the report.
mixin MetarWindMixin on StringAttributeMixin {
  MetarWind _wind = MetarWind(null, null);

  void _handleWind(String group) {
    final match = MetarRegExp.wind.firstMatch(group);
    _wind = MetarWind(group, match);

    _concatenateString(_wind);
  }

  /// Get the wind data of the report.
  MetarWind get wind => _wind;
}
