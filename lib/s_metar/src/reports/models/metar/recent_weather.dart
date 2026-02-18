part of '../../reports.dart';

/// Basic structure for recent weather groups in METAR.
class MetarRecentWeather extends Group {
  late final String? _description;
  late final String? _obscuration;
  late final String? _other;
  late final String? _precipitation;

  MetarRecentWeather(super.code, RegExpMatch? match) {
    if (match == null) {
      _description = null;
      _obscuration = null;
      _other = null;
      _precipitation = null;
    } else {
      _description = weatherDescriptionMap[match.namedGroup('desc')];
      _obscuration = weatherObscurationMap[match.namedGroup('obsc')];
      _other = weatherOtherMap[match.namedGroup('other')];
      _precipitation = weatherPrecipitationMap[match.namedGroup('prec')];
    }
  }

  @override
  String toString() {
    var s = '$_description' ' $_precipitation' ' $_obscuration' ' $_other';
    s = s.replaceAll('null', '');
    s = s.replaceAll(RegExp(r'\s{2,}'), ' ');

    return s.trim();
  }

  /// Get the description of recent weather in METAR.
  String? get description => _description;

  /// Get the obscuration of recent weather in METAR.
  String? get obscuration => _obscuration;

  /// Get the other item of recent weather in METAR.
  String? get other => _other;

  /// Get the precipitation of recent weather in METAR.
  String? get precipitation => _precipitation;

  @override
  Map<String, String?> asMap() {
    final map = super.asMap();
    map.addAll({
      'description': description,
      'obscuration': obscuration,
      'other': other,
      'precipitation': precipitation,
    });
    return map.cast<String, String?>();
  }
}
