part of '../../reports.dart';

Map<String, String> skyCover = {
  'SKC': 'clear',
  'CLR': 'clear',
  'NSC': 'clear',
  'NCD': 'clear',
  'FEW': 'a few',
  'SCT': 'scattered',
  'BKN': 'broken',
  'OVC': 'overcast',
  '///': 'undefined',
  'VV': 'indefinite ceiling',
};

Map<String, String> cloudTypeMap = {
  'AC': 'altocumulus',
  'ACC': 'altocumulus castellanus',
  'ACSL': 'standing lenticulas altocumulus',
  'AS': 'altostratus',
  'CB': 'cumulonimbus',
  'CBMAM': 'cumulonimbus mammatus',
  'CCSL': 'standing lenticular cirrocumulus',
  'CC': 'cirrocumulus',
  'CI': 'cirrus',
  'CS': 'cirrostratus',
  'CU': 'cumulus',
  'NS': 'nimbostratus',
  'SC': 'stratocumulus',
  'ST': 'stratus',
  'SCSL': 'standing lenticular stratocumulus',
  'TCU': 'towering cumulus'
};

class Cloud extends Group {
  String? _cover;
  String? _coverCode;
  String? _type;
  String? _typeCode;
  String? _oktas;
  late Distance _height;

  Cloud(Map<String, String?> data) : super(data['code']) {
    _cover = data['cover'];
    _coverCode = data['coverCode'];
    _type = data['type'];
    _typeCode = data['typeCode'];
    _oktas = data['oktas'];
    _height = Distance(data['height']);
  }

  factory Cloud.fromMetar(String? code, RegExpMatch? match) {
    String? resultCode;
    String? cover;
    String? coverCode;
    String? type;
    String? typeCode;
    String? oktas;
    String? height;

    if (match != null) {
      resultCode = code;
      coverCode = match.namedGroup('cover');
      typeCode = match.namedGroup('type');

      cover = skyCover[coverCode];
      oktas = Cloud._setOktas(coverCode!);
      type = cloudTypeMap[typeCode];

      var heightStr = match.namedGroup('height');
      if (heightStr == null || heightStr == '///') {
        height = '////';
      } else {
        heightStr = '${heightStr}00';
        var heightAsDouble = double.parse(heightStr);
        heightAsDouble = heightAsDouble * Conversions.ftToM;
        height = heightAsDouble.toStringAsFixed(10);
      }
    }

    return Cloud({
      'code': resultCode,
      'cover': cover,
      'coverCode': coverCode,
      'type': type,
      'typeCode': typeCode,
      'oktas': oktas,
      'height': height,
    });
  }

  @override
  String toString() {
    if (_type != null && _height.value != null) {
      return '$_cover at ${heightInFeet!.toStringAsFixed(1)} feet of $_type';
    }

    if (_height.value != null) {
      return '$_cover at ${heightInFeet!.toStringAsFixed(1)} feet';
    }

    final undefinedCovers =
        <String>['NSC', 'NCD', '///'].map((el) => skyCover[el]).toList();
    if (undefinedCovers.contains(_cover)) {
      return '$_cover';
    }

    if (_cover == skyCover['VV']) {
      if (_height.value != null) {
        return '$_cover at ${heightInFeet!.toStringAsFixed(1)} feet';
      }
      return '$_cover';
    }

    return '$_cover at undefined height';
  }

  static String _setOktas(String cover) {
    if (<String>['NSC', 'NCD'].contains(cover)) {
      return 'not specified';
    }

    if (<String>['///', 'VV'].contains(cover)) {
      return 'undefined';
    }

    switch (cover) {
      case 'FEW':
        return '1-2';
      case 'SCT':
        return '3-4';
      case 'BKN':
        return '5-7';
      case 'OVC':
        return '8';
    }

    return '';
  }

  /// Get the cover description of the cloud layer.
  String? get cover => _cover;

  /// Get the raw ICAO sky-cover code (e.g. 'BKN', 'OVC', 'FEW').
  String? get coverCode => _coverCode;

  /// Get the type of cloud translation of the cloud layer.
  String? get cloudType => _type;

  /// Get the raw ICAO cloud-type code (e.g. 'CB', 'TCU').
  String? get cloudTypeCode => _typeCode;

  /// Get the oktas amount of the cloud layer.
  String? get oktas => _oktas;

  /// Get the height of the cloud base in meters.
  double? get heightInMeters => _height.inMeters;

  /// Get the height of the cloud base in kilometers.
  double? get heightInKilometers => _height.inKilometers;

  /// Get the height of the cloud base in sea miles.
  double? get heightInSeaMiles => _height.inSeaMiles;

  /// Get the height of the cloud base in feet.
  double? get heightInFeet => _height.inFeet;

  @override
  Map<String, Object?> asMap() {
    final map = {
      'cover': cover,
      'cover_code': coverCode,
      'oktas': oktas,
      'height_units': 'meters',
      'height': heightInMeters,
      'type': cloudType,
      'type_code': cloudTypeCode,
    };
    map.addAll(super.asMap());
    return map;
  }
}

class CloudList extends GroupList<Cloud> {
  CloudList() : super(4);

  /// Get `true` if there is ceiling, `false` if not.
  ///
  /// If the cover of someone of the cloud layers is broken (BKN) or
  /// overcast (OVC) and its height is less than or equal to 1500.0 feet,
  /// there is ceiling; there isn't otherwise.
  bool get ceiling {
    for (var group in _list) {
      final oktas = group.oktas;
      final height = group.heightInFeet;
      if (<String>['5-7', '8'].contains(oktas)) {
        if (height != null && height <= 1500.0) {
          return true;
        }
      }
    }
    return false;
  }
}
