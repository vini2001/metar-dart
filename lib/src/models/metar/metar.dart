part of models;

/// Parser for METAR reports.
class Metar extends Report
    with
        ModifierMixin,
        MetarWindMixin,
        MetarPrevailingMixin,
        MetarWeatherMixin,
        MetarCloudMixin {
  late MetarTime _time;
  late final int? _year, _month;

  // Body groups
  MetarWindVariation _windVariation = MetarWindVariation(null, null);
  MetarMinimumVisibility _minimumVisibility =
      MetarMinimumVisibility(null, null);
  final _runwayRanges = GroupList<MetarRunwayRange>(3);
  MetarTemperatures _temperatures = MetarTemperatures(null, null);
  MetarPressure _pressure = MetarPressure(null, null);
  MetarRecentWeather _recentWeather = MetarRecentWeather(null, null);
  final _windshear = MetarWindshearList();
  MetarSeaState _seaState = MetarSeaState(null, null);
  MetarRunwayState _runwayState = MetarRunwayState(null, null);

  // Trend groups
  late MetarTrend _trend;
  MetarWind _trendWind = MetarWind(null, null);
  MetarPrevailingVisibility _trendPrevailing =
      MetarPrevailingVisibility(null, null);

  Metar(
    String code, {
    int? year,
    int? month,
    bool truncate = false,
  }) : super(code, truncate) {
    _handleSections();

    _year = year;
    _month = month;

    // Parse body groups
    _parseBody();

    // Initialize trend group
    _trend = MetarTrend(null, null, _time.time);

    // Parse trend groups
    _parseTrend();
  }

  /// Get the body part of the METAR.
  String get body => _sections[0];

  /// Get the trend part of the METAR.
  String get trendForecast => _sections[1];

  /// Get the remark part of the METAR.
  String get remark => _sections[2];

  @override
  void _handleTime(String group) {
    final match = MetarRegExp.TIME.firstMatch(group);
    _time = MetarTime(group, match, year: _year, month: _month);

    _concatenateString(_time);
  }

  /// Get the time of the group.
  MetarTime get time => _time;

  void _handleWindVariation(String group) {
    final match = MetarRegExp.WIND_VARIATION.firstMatch(group);
    _windVariation = MetarWindVariation(group, match);

    _concatenateString(_windVariation);
  }

  /// Get the wind variation directions of the METAR.
  MetarWindVariation get windVariation => _windVariation;

  void _handleMinimumVisibility(String group) {
    final match = MetarRegExp.VISIBILITY.firstMatch(group);
    _minimumVisibility = MetarMinimumVisibility(group, match);

    _concatenateString(_minimumVisibility);
  }

  /// Get the minimum visibility data of the METAR.
  MetarMinimumVisibility get minimumVisibility => _minimumVisibility;

  void _handleRunwayRange(String group) {
    final match = MetarRegExp.RUNWAY_RANGE.firstMatch(group);
    final range = MetarRunwayRange(group, match);
    _runwayRanges.add(range);

    _concatenateString(range);
  }

  /// Get the runway ranges data of the METAR if provided.
  GroupList<MetarRunwayRange> get runwayRanges => _runwayRanges;

  void _handleTemperatures(String group) {
    final match = MetarRegExp.TEMPERATURES.firstMatch(group);
    _temperatures = MetarTemperatures(group, match);

    _concatenateString(_temperatures);
  }

  /// Get the temperatures data of the METAR.
  MetarTemperatures get temperatures => _temperatures;

  void _handlePressure(String group) {
    final match = MetarRegExp.PRESSURE.firstMatch(group);
    _pressure = MetarPressure(group, match);

    _concatenateString(_pressure);
  }

  /// Get the pressure of the METAR.
  MetarPressure get pressure => _pressure;

  void _handleRecentWeather(String group) {
    final match = MetarRegExp.RECENT_WEATHER.firstMatch(group);
    _recentWeather = MetarRecentWeather(group, match);

    _concatenateString(_recentWeather);
  }

  /// Get the recent weather data of the METAR.
  MetarRecentWeather get recentWeather => _recentWeather;

  void _handleWindshear(String group) {
    final match = MetarRegExp.WINDSHEAR.firstMatch(group);
    final windshear = MetarWindshearRunway(group, match);
    _windshear.add(windshear);

    _concatenateString(windshear);
  }

  /// Get the windshear data of the METAR.
  MetarWindshearList get windshear => _windshear;

  void _handleSeaState(String group) {
    final match = MetarRegExp.SEA_STATE.firstMatch(group);
    _seaState = MetarSeaState(group, match);

    _concatenateString(_seaState);
  }

  /// Get the sea state data of the METAR.
  MetarSeaState get seaState => _seaState;

  void _handleRunwayState(String group) {
    final match = MetarRegExp.RUNWAY_STATE.firstMatch(group);
    _runwayState = MetarRunwayState(group, match);

    _concatenateString(_runwayState);
  }

  /// Get the runway state data of the METAR.
  MetarRunwayState get runwayState => _runwayState;

  void _handleTrend(String group) {
    final match = MetarRegExp.TREND.firstMatch(group);
    _trend = MetarTrend(group, match, _time.time);

    _concatenateString(_trend);
  }

  /// Get the trend data of the METAR.
  MetarTrend get trend => _trend;

  void _handleTrendTimePeriod(String group) {
    final match = MetarRegExp.TREND_TIME_PERIOD.firstMatch(group);
    final oldTrendAsString = _trend.toString();
    _trend.addPeriod(group, match!);
    final newTrendAsString = _trend.toString();

    _string = _string.replaceFirst(oldTrendAsString, newTrendAsString);
  }

  void _handleTrendWind(String group) {
    final match = MetarRegExp.WIND.firstMatch(group);
    _trendWind = MetarWind(group, match);

    _concatenateString(_trendWind);
  }

  /// Get the trend wind data of the METAR.
  MetarWind get trendWind => _trendWind;

  void _handleTrendPrevailing(String group) {
    final match = MetarRegExp.VISIBILITY.firstMatch(group);
    _trendPrevailing = MetarPrevailingVisibility(group, match);

    _concatenateString(_trendPrevailing);
  }

  /// Get the trend prevailing visibility data of the METAR.
  MetarPrevailingVisibility get trendPrevailingVisibility => _trendPrevailing;

  void _parseBody() {
    final handlers = <GroupHandler>[
      GroupHandler(MetarRegExp.TYPE, _handleType),
      GroupHandler(MetarRegExp.STATION, _handleStation),
      GroupHandler(MetarRegExp.TIME, _handleTime),
      GroupHandler(MetarRegExp.MODIFIER, _handleModifier),
      GroupHandler(MetarRegExp.WIND, _handleWind),
      GroupHandler(MetarRegExp.WIND_VARIATION, _handleWindVariation),
      GroupHandler(MetarRegExp.VISIBILITY, _handlePrevailing),
      GroupHandler(MetarRegExp.VISIBILITY, _handleMinimumVisibility),
      GroupHandler(MetarRegExp.RUNWAY_RANGE, _handleRunwayRange),
      GroupHandler(MetarRegExp.RUNWAY_RANGE, _handleRunwayRange),
      GroupHandler(MetarRegExp.RUNWAY_RANGE, _handleRunwayRange),
      GroupHandler(MetarRegExp.WEATHER, _handleWeather),
      GroupHandler(MetarRegExp.WEATHER, _handleWeather),
      GroupHandler(MetarRegExp.WEATHER, _handleWeather),
      GroupHandler(MetarRegExp.CLOUD, _handleCloud),
      GroupHandler(MetarRegExp.CLOUD, _handleCloud),
      GroupHandler(MetarRegExp.CLOUD, _handleCloud),
      GroupHandler(MetarRegExp.CLOUD, _handleCloud),
      GroupHandler(MetarRegExp.TEMPERATURES, _handleTemperatures),
      GroupHandler(MetarRegExp.PRESSURE, _handlePressure),
      GroupHandler(MetarRegExp.RECENT_WEATHER, _handleRecentWeather),
      GroupHandler(MetarRegExp.WINDSHEAR, _handleWindshear),
      GroupHandler(MetarRegExp.WINDSHEAR, _handleWindshear),
      GroupHandler(MetarRegExp.WINDSHEAR, _handleWindshear),
      GroupHandler(MetarRegExp.SEA_STATE, _handleSeaState),
      GroupHandler(MetarRegExp.RUNWAY_STATE, _handleRunwayState),
    ];

    _parse(handlers, body);
  }

  void _parseTrend() {
    final handlers = <GroupHandler>[
      GroupHandler(MetarRegExp.TREND, _handleTrend),
      GroupHandler(MetarRegExp.TREND_TIME_PERIOD, _handleTrendTimePeriod),
      GroupHandler(MetarRegExp.TREND_TIME_PERIOD, _handleTrendTimePeriod),
      GroupHandler(MetarRegExp.WIND, _handleTrendWind),
      GroupHandler(MetarRegExp.VISIBILITY, _handleTrendPrevailing),
    ];

    _parse(handlers, trendForecast, sectionType: 'trend');
  }

  @override
  void _parse(List<GroupHandler> handlers, String section,
      {String sectionType = 'body'}) {
    var index = 0;

    section = sanitizeVisibility(section);
    if (sectionType == 'body' || sectionType == 'trend') {
      section = sanitizeWindshear(section);
    }
    section.split(' ').forEach((group) {
      unparsedGroups.add(group);

      for (var i = index; i < handlers.length; i++) {
        var handler = handlers[i];

        index++;

        if (handler.regexp.hasMatch(group)) {
          handler.handler(group);
          unparsedGroups.remove(group);
          break;
        }
      }
    });

    if (unparsedGroups.isNotEmpty && _truncate) {
      throw ParserError(
        'failed while processing ${unparsedGroups.join(" ")} from: $rawCode',
      );
    }
  }

  @override
  void _handleSections() {
    final trendRe = RegExp(MetarRegExp.TREND.pattern
        .replaceFirst(
          RegExp(r'\^'),
          '',
        )
        .replaceFirst(
          RegExp(r'\$'),
          '',
        ));

    final remarkRe = RegExp(MetarRegExp.REMARK.pattern
        .replaceFirst(
          RegExp(r'\^'),
          '',
        )
        .replaceFirst(
          RegExp(r'\$'),
          '',
        ));

    int? trendPos, remarkPos;

    trendPos = trendRe.firstMatch(_rawCode)?.start;
    remarkPos = remarkRe.firstMatch(_rawCode)?.start;

    var body = '';
    var trend = '';
    var remark = '';

    if (trendPos == null && remarkPos != null) {
      body = _rawCode.substring(0, remarkPos - 1);
      remark = _rawCode.substring(remarkPos);
    } else if (trendPos != null && remarkPos == null) {
      body = _rawCode.substring(0, trendPos - 1);
      trend = _rawCode.substring(trendPos);
    } else if (trendPos == null && remarkPos == null) {
      body = _rawCode;
    } else {
      if (trendPos! > remarkPos!) {
        body = _rawCode.substring(0, remarkPos - 1);
        remark = _rawCode.substring(remarkPos, trendPos - 1);
        trend = _rawCode.substring(trendPos);
      } else {
        body = _rawCode.substring(0, trendPos - 1);
        trend = _rawCode.substring(trendPos, remarkPos - 1);
        remark = _rawCode.substring(remarkPos);
      }
    }

    _sections.add(body);
    _sections.add(trend);
    _sections.add(remark);
  }
}
