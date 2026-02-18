part of '../../reports.dart';

class MetarPressure extends Pressure with GroupMixin {
  MetarPressure(String? code, RegExpMatch? match) : super(null) {
    _code = code;

    if (match != null) {
      final units = match.namedGroup('units');
      final press = match.namedGroup('press');
      final unit2 = match.namedGroup('units2');

      if (press != '////') {
        var pressure = double.parse(press!);

        if (units == 'A' || unit2 == 'INS') {
          pressure = pressure / 100 * Conversions.inhgToHpa;
        } else if (<String>['Q', 'QNH'].contains(units)) {
          pressure *= 1;
        } else if (pressure > 2500.0) {
          pressure = pressure * Conversions.inhgToHpa;
        } else {
          pressure = pressure * Conversions.mbarToHpa;
        }

        _value = pressure;
      }
    }
  }
}
