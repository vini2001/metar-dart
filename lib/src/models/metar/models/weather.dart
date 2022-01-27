part of models;

Map<String, String> WEATHER_INT = {
  '-': 'light',
  '+': 'heavy',
  '-VC': 'nearby light',
  '+VC': 'nearby heavy',
  'VC': 'nearby',
};

Map<String, String> WEATHER_DESC = {
  'MI': 'shallow',
  'PR': 'partial',
  'BC': 'patches of',
  'DR': 'low drifting',
  'BL': 'blowing',
  'SH': 'showers',
  'TS': 'thunderstorm',
  'FZ': 'freezing',
};

Map<String, String> WEATHER_PREC = {
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

Map<String, String> WEATHER_OBSC = {
  'BR': 'mist',
  'FG': 'fog',
  'FU': 'smoke',
  'VA': 'volcanic ash',
  'DU': 'dust',
  'SA': 'sand',
  'HZ': 'haze',
  'PY': 'spray',
};

Map<String, String> WEATHER_OTHER = {
  'PO': 'sand whirls',
  'SQ': 'squalls',
  'FC': 'funnel cloud',
  'SS': 'sandstorm',
  'DS': 'dust storm',
};

class MetarWeather extends Group {
  String? _intensity;
  String? _description;
  String? _precipitation;
  String? _obscuration;
  String? _other;

  MetarWeather(String? code, RegExpMatch? match) : super(code) {
    if (match != null) {
      _intensity = WEATHER_INT[match.namedGroup('int')];
      _description = WEATHER_DESC[match.namedGroup('desc')];
      _precipitation = WEATHER_PREC[match.namedGroup('prec')];
      _obscuration = WEATHER_OBSC[match.namedGroup('obsc')];
      _other = WEATHER_OTHER[match.namedGroup('other')];
    }
  }

  @override
  String toString() {
    var s = '$_intensity'
        ' $_description'
        ' $_precipitation'
        ' $_obscuration'
        ' $_other';
    s = s.replaceAll('null', '');
    s = s.replaceAll(RegExp(r'\s{2,}'), ' ');

    return s.trim();
  }

  /// Get the intensity of the weather.
  String? get intensity => _intensity;

  /// Get the description of the weather.
  String? get description => _description;

  // Get the precipitation type of the weather.
  String? get precipitation => _precipitation;

  /// Get the obscuration type of the weather.
  String? get obscuration => _obscuration;

  /// Get the other parameter of the weather.
  String? get other => _other;
}