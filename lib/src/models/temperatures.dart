import 'package:metar_dart/src/models/descriptors.dart';
import 'package:metar_dart/src/utils/utils.dart'
    show handleTemperature, Conversions;

String? setTemperature(String? sign, String? temp) {
  if (sign == 'M' || sign == '-') {
    return '-$temp';
  }

  return temp;
}

class Temperature {
  double? _temperature;

  Temperature(String? code) {
    if (code == null) {
      _temperature = null;
    } else {
      _temperature = double.tryParse(code);
    }
  }

  @override
  String toString() {
    return _temperature.toString();
  }

  double? get temperature => _temperature;
}

class Temperatures extends Group {
  Temperature _temperature = Temperature(null);
  Temperature _dewpoint = Temperature(null);

  Temperatures(String? code, RegExpMatch? match) : super(code) {
    if (match != null) {
      final tsign = match.namedGroup('tsign');
      final dsign = match.namedGroup('dsign');

      final temp = setTemperature(tsign, match.namedGroup('temp'));
      final dewpt = setTemperature(dsign, match.namedGroup('dewpt'));

      _temperature = Temperature(temp);
      _dewpoint = Temperature(dewpt);
    }
  }

  @override
  String toString() {
    final temperature = _temperature.temperature;
    final dewpoint = _dewpoint.temperature;

    if (temperature == null && dewpoint != null) {
      return 'no temperature | dewpoint $dewpointInCelsius°';
    } else if (temperature != null && dewpoint == null) {
      return 'temperature $temperatureInCelsius° | no dewpoint';
    } else if (temperature == null && dewpoint == null) {
      return '';
    } else {
      return 'temperature $temperatureInCelsius°'
          ' | '
          'dewpoint $dewpointInCelsius°';
    }
  }

  double? get temperatureInCelsius =>
      handleTemperature(_temperature.temperature, Conversions.sameValue);
  double? get temperatureInFahrenheit => handleTemperature(
      _temperature.temperature, Conversions.celsiusToFahrenheit);
  double? get temperatureInKelvin =>
      handleTemperature(_temperature.temperature, Conversions.celsiusToKelvin);
  double? get temperatureInRankine =>
      handleTemperature(_temperature.temperature, Conversions.celsiusToRankine);

  double? get dewpointInCelsius =>
      handleTemperature(_dewpoint.temperature, Conversions.sameValue);
  double? get dewpointInFahrenheit =>
      handleTemperature(_dewpoint.temperature, Conversions.celsiusToFahrenheit);
  double? get dewpointInKelvin =>
      handleTemperature(_dewpoint.temperature, Conversions.celsiusToKelvin);
  double? get dewpointInRankine =>
      handleTemperature(_dewpoint.temperature, Conversions.celsiusToRankine);
}
