part of '../../reports.dart';

/// Basic structure for distance attributes.
class Distance extends Numeric {
  bool _isMaximum = false;

  Distance(String? code) : super(null) {
    code ??= '////';

    if (code == '9999') {
      _isMaximum = true;
      code = '10000';
    }

    final distance = double.tryParse(code);
    _value = distance;
  }

  @override
  String toString() {
    if (_value != null) {
      return '${super} m';
    }

    return super.toString();
  }

  /// Returns `true` if the original value was `9999` (10 km or more — maximum reportable visibility).
  bool get isMaximum => _isMaximum;

  /// Get the distance in meters.
  double? get inMeters => _value;

  /// Get the distance in kilometers.
  double? get inKilometers => converted(conversionDouble: Conversions.mToKm);

  /// Get the distance in sea miles.
  double? get inSeaMiles => converted(conversionDouble: Conversions.mToSmi);

  /// Get the distance in feet.
  double? get inFeet => converted(conversionDouble: Conversions.mToFt);

  @override
  Map<String, Object?> asMap() {
    return {
      'units': 'meters',
      'distance': inMeters,
      'is_maximum': isMaximum,
    };
  }
}
