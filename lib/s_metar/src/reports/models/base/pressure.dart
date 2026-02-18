part of '../../reports.dart';

/// Basic structure for pressure attributes.
class Pressure extends Numeric {
  Pressure(String? code) : super(null) {
    code ??= '////';

    final pressure = double.tryParse(code);
    _value = pressure;
  }

  @override
  String toString() {
    if (_value != null) {
      return '${super.toString()} hPa';
    }

    return super.toString();
  }

  /// Get the pressure in hecto pascals (hPa).
  double? get inHPa => _value;

  /// Get the pressure in mercury inches (inHg).
  double? get inInHg => converted(conversionDouble: Conversions.hpaToInhg);

  /// Get the pressure in millibars (mbar).
  double? get inMbar => converted(conversionDouble: Conversions.hpaToMbar);

  /// Get the pressure in bars (bar).
  double? get inBar => converted(conversionDouble: Conversions.hpaToBar);

  /// Get the pressure in atmospheres (atm).
  double? get inAtm => converted(conversionDouble: Conversions.hpaToAtm);

  /// Get the pressure in pascals (Pa).
  double? get inPa => converted(conversionDouble: Conversions.hpaToPa);

  /// Get the pressure in kilopascals (kPa).
  double? get inKPa => converted(conversionDouble: Conversions.hpaToKpa);

  @override
  Map<String, Object?> asMap() {
    return {'units': 'hectopascals', 'pressure': inHPa};
  }
}
