part of '../../reports.dart';

Map<String, String> weatherIntensityMap = {
  '-': 'light',
  '+': 'heavy',
  '-VC': 'nearby light',
  '+VC': 'nearby heavy',
  'VC': 'nearby',
};

Map<String, String> weatherDescriptionMap = {
  'MI': 'shallow',
  'PR': 'partial',
  'BC': 'patches of',
  'DR': 'low drifting',
  'BL': 'blowing',
  'SH': 'showers',
  'TS': 'thunderstorm',
  'FZ': 'freezing',
};

Map<String, String> weatherPrecipitationMap = {
  'DZ': 'drizzle',
  'RA': 'rain',
  'SN': 'snow',
  'SG': 'snow grains',
  'IC': 'ice crystals',
  'PL': 'ice pellets',
  'GR': 'hail',
  'GS': 'snow pellets',
  'UP': 'unknown precipitation',
  '//': '',
};

Map<String, String> weatherObscurationMap = {
  'BR': 'mist',
  'FG': 'fog',
  'FU': 'smoke',
  'VA': 'volcanic ash',
  'DU': 'dust',
  'SA': 'sand',
  'HZ': 'haze',
  'PY': 'spray',
};

Map<String, String> weatherOtherMap = {
  'PO': 'sand whirls',
  'SQ': 'squalls',
  'FC': 'funnel cloud',
  'SS': 'sandstorm',
  'DS': 'dust storm',
  'NSW': 'nil significant weather',
};

class MetarWeather extends Group {
  String? _intensity;
  String? _description;
  String? _precipitation;
  String? _obscuration;
  String? _other;

  // Stores raw ICAO codes for individual precipitation types (e.g. ['RA','SN'])
  final List<String> _precipitationCodes = [];

  MetarWeather(super.code, RegExpMatch? match) {
    if (match != null) {
      _intensity = weatherIntensityMap[match.namedGroup('int')];
      _description = weatherDescriptionMap[match.namedGroup('desc')];
      _obscuration = weatherObscurationMap[match.namedGroup('obsc')];
      _other = weatherOtherMap[match.namedGroup('other')];

      // Compound precipitation: e.g. 'RASN', 'FZRASN' — split into 2-char codes
      final precRaw = match.namedGroup('prec');
      if (precRaw != null) {
        final codes = RegExp(r'DZ|RA|SN|SG|IC|PL|GR|GS|UP')
            .allMatches(precRaw)
            .map((m) => m.group(0)!)
            .toList();
        _precipitationCodes.addAll(codes);
        _precipitation =
            codes.map((c) => weatherPrecipitationMap[c] ?? c).join(' and ');
      }
    }
  }

  @override
  String toString() {
    final parts = [
      _intensity,
      _description,
      _precipitation,
      _obscuration,
      _other,
    ].whereType<String>().where((s) => s.isNotEmpty).toList();
    return parts.join(' ');
  }

  /// Get the intensity of the weather.
  String? get intensity => _intensity;

  /// Get the description of the weather.
  String? get description => _description;

  /// Get the translated precipitation string (e.g. 'rain and snow').
  String? get precipitation => _precipitation;

  /// Get the raw ICAO precipitation type codes (e.g. ['RA', 'SN']).
  List<String> get precipitationCodes => List.unmodifiable(_precipitationCodes);

  /// Get the obscuration type of the weather.
  String? get obscuration => _obscuration;

  /// Get the other parameter of the weather.
  String? get other => _other;

  @override
  Map<String, Object?> asMap() {
    final map = super.asMap();
    map.addAll({
      'intensity': intensity,
      'description': description,
      'precipitation': precipitation,
      'precipitation_codes': _precipitationCodes,
      'obscuration': obscuration,
      'other': other,
    });
    return map;
  }
}

mixin MetarWeatherMixin on StringAttributeMixin {
  final _weathers = GroupList<MetarWeather>(3);

  void _handleWeather(String group) {
    final match = MetarRegExp.weather.firstMatch(group);
    final weather = MetarWeather(group, match);
    _weathers.add(weather);

    _concatenateString(weather);
  }

  /// Get the weather data of the report if provided.
  GroupList<MetarWeather> get weathers => _weathers;
}
