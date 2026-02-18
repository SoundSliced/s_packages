part of '../../reports.dart';

/// Basic structure for visibility data in reports from land stations.
class Visibility extends Group {
  Distance _visibility = Distance(null);

  Visibility(super.code);

  @override
  String toString() {
    if (_visibility.value != null) {
      return '${inKilometers!.toStringAsFixed(1)} km';
    }

    return _visibility.toString();
  }

  /// Get the visibility in meters.
  double? get inMeters => _visibility.inMeters;

  /// Get the visibility in kilometers.
  double? get inKilometers => _visibility.inKilometers;

  /// Get the visibility in sea miles.
  double? get inSeaMiles => _visibility.inSeaMiles;

  /// Get the visibility in feet.
  double? get inFeet => _visibility.inFeet;

  @override
  Map<String, Object?> asMap() {
    final map = super.asMap();
    map.addAll({
      'visibility': _visibility.asMap(),
    });
    return map;
  }
}

/// Basic structure for visibility data with a direction in reports from land stations.
class VisibilityWithDirection extends Visibility {
  Direction _direction = Direction(null);

  VisibilityWithDirection(super.code);

  @override
  String toString() {
    if (_direction.value == null) {
      return super.toString();
    }

    final direction = _direction.value == null
        ? ''
        : ' to ${_direction.cardinal} ($_direction)';

    return '${super.toString()}$direction';
  }

  /// Get the cardinal direction associated to the visibility, e.g. "NW" (north west).
  String? get cardinalDirection => _direction.cardinal;

  /// Get the visibility direction in degrees.
  double? get directionInDegrees => _direction.inDegrees;

  /// Get the visibility direction in radians.
  double? get directionInRadians => _direction.inRadians;

  /// Get the visibility direction in gradians.
  double? get directionInGradians => _direction.inGradians;

  @override
  Map<String, Object?> asMap() {
    final map = super.asMap();
    map.addAll({
      'direction': _direction.asMap(),
    });
    return map;
  }
}

/// Basic structure for minimum visibility groups in reports from land stations.
class MetarMinimumVisibility extends VisibilityWithDirection {
  MetarMinimumVisibility(super.code, RegExpMatch? match) {
    if (match != null) {
      final vis = match.namedGroup('vis');
      final dir = match.namedGroup('dir');

      if (vis != null) {
        _visibility = Distance(vis);
      }

      if (dir != null) {
        _direction = Direction.fromCardinal(dir);
      }
    }
  }
}

/// Basic structure for prevailing visibility in reports from land stations.
class MetarPrevailingVisibility extends VisibilityWithDirection {
  /// Get True if CAVOK, False if not.
  bool cavok = false;

  MetarPrevailingVisibility(String? code, RegExpMatch? match)
      : super(code?.replaceAll('_', ' ')) {
    if (match != null) {
      final vis = match.namedGroup('vis');
      final dir = match.namedGroup('dir');
      final integer = match.namedGroup('integer');
      final fraction = match.namedGroup('fraction');
      final units = match.namedGroup('units');

      if (vis != null) {
        _visibility = Distance(vis);
      }

      if (integer != null || fraction != null) {
        if (units == 'SM') {
          _fromSeaMiles(integer, fraction);
        }

        if (units == 'KM') {
          final inMeters = int.parse(integer!) * 1000;
          _visibility = Distance('$inMeters'.padLeft(4, '0'));
        }
      }

      if (dir != null) {
        _direction = Direction.fromCardinal(dir);
      }

      final cavokMatch = match.namedGroup('cavok');
      if (cavokMatch != null) {
        cavok = true;
        _visibility = Distance('9999');
      }
    }
  }

  @override
  String toString() {
    if (cavok) {
      return 'Ceiling and Visibility OK';
    }

    return super.toString();
  }

  /// Helper to handle the visibility from sea miles.
  void _fromSeaMiles(String? integer, String? fraction) {
    late final double fraction0;
    if (fraction != null) {
      final items = fraction.split('/');
      fraction0 = int.parse(items[0]) / int.parse(items[1]);
    } else {
      fraction0 = 0.0;
    }

    var vis = fraction0;

    if (integer != null) {
      final integer0 = double.parse(integer);
      vis += integer0;
    }

    _visibility = Distance('${vis * Conversions.smiToKm * Conversions.kmToM}');
  }

  @override
  Map<String, Object?> asMap() {
    final map = super.asMap();
    map.addAll({'cavok': cavok});
    return map;
  }
}

/// Mixin to add prevailing visibility attribute to the report.
mixin MetarPrevailingMixin on StringAttributeMixin {
  MetarPrevailingVisibility _prevailing = MetarPrevailingVisibility(null, null);

  void _handlePrevailing(String group) {
    final match = MetarRegExp.visibility.firstMatch(group);
    _prevailing = MetarPrevailingVisibility(group, match);

    _concatenateString(_prevailing);
  }

  /// Get the prevailing visibility data of the report.
  MetarPrevailingVisibility get prevailingVisibility => _prevailing;
}
