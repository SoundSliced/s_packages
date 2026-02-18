part of 'utils.dart';

class Conversions {
  // Distance conversions
  static final ftToM = 0.3048;
  static final smiToKm = 1.60934; // statute miles to km
  static final kmToSmi = 1 / smiToKm;
  static final kmToM = 1000.0;
  static final mToKm = 1 / kmToM;
  static final mToSmi = mToKm * kmToSmi;
  static final mToFt = 1 / ftToM;
  static final mToDm = 10.0;
  static final mToCm = 100.0;
  static final mToIn = 39.3701;

  // Direction conversions
  static final degreesToRadians = pi / 180;
  static final degreesToGradians = 1.11111111;

  // Speed conversions
  static final knotToMps = 0.51444444;
  static final knotToMiph = 1.15078;
  static final knotToKph = 1.852;
  static final mpsToKnot = 1 / knotToMps;

  // Pressure conversions
  static final hpaToInhg = 0.02953;
  static final inhgToHpa = 1 / hpaToInhg;
  static final hpaToBar = 0.001;
  static final barToHpa = 1 / hpaToBar;
  static final mbarToHpa = barToHpa / 1000;
  static final hpaToMbar = hpaToBar * 1000;
  static final hpaToAtm = 1 / 1013.25;
  static final hpaToPa = 100.0;
  static final hpaToKpa = 0.1;

  // Temperature conversions
  static double celsiusToKelvin(double temp) {
    return temp + 273.15;
  }

  static double kelvinToCelsius(double temp) {
    return temp - 273.15;
  }

  static double celsiusToFahrenheit(double temp) {
    return temp * 9 / 5 + 32;
  }

  static double fahrenheitToCelsius(double temp) {
    return (temp - 32) * 5 / 9;
  }

  static double celsiusToRankine(double temp) {
    return temp * 9 / 5 + 491.67;
  }

  static double rankineToCelsius(double temp) {
    return (temp - 491.67) * 5 / 9;
  }
}
