part of models;

class MetarTime extends Time implements Group {
  @override
  late final String? _code;

  MetarTime(String? code, RegExpMatch? match, {int? year, int? month})
      : super(null, null, year: year, month: month, minute: '00') {
    _code = code;

    if (match != null) {
      final _day = match.namedGroup('day');
      final _hour = match.namedGroup('hour');
      final _minute = match.namedGroup('min');

      final _month = '${_time.month}'.padLeft(2, '0');

      _time = DateTime.parse('${_time.year}$_month${_day}T$_hour${_minute}00');
    }
  }

  /// Get the length of the code of the group.
  @override
  int get length {
    if (_code == null) {
      return 0;
    }

    return _code!.length;
  }

  /// Get the code of the group.
  @override
  String? get code => _code;
}