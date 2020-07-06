import 'dart:convert';
import 'package:weather_test_flutter/src/api/http_exception.dart';
import 'package:weather_test_flutter/src/model/weather.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

/// Wrapper around the open weather map api
/// https://openweathermap.org/current
class WeatherApiClient {
  static const baseUrl = 'http://api.openweathermap.org';
  final apiKey;
  final http.Client httpClient;

  WeatherApiClient({@required this.httpClient, this.apiKey})
      : assert(httpClient != null),
        assert(apiKey != null);

  Future<String> getCityNameFromLocation(
      {double latitude, double longitude}) async {
    final url =
        '$baseUrl/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&lang=sp';
    print('endpoint: $url');
    final res = await this.httpClient.get(url);
    if (res.statusCode != 200) {
      throw HTTPException(res.statusCode, "No se pudo obtener datos del clima");
    }
    final weatherJson = json.decode(res.body);
    return weatherJson['name'];
  }

  Future<Weather> getWeatherData(String cityName) async {
    final url = '$baseUrl/data/2.5/weather?q=$cityName&appid=$apiKey&lang=sp';
    print('endpoint: $url');
    final res = await this.httpClient.get(url);
    if (res.statusCode != 200) {
      throw HTTPException(res.statusCode, "No se pudo obtener datos del clima");
    }
    final weatherJson = json.decode(res.body);
    return Weather.fromJson(weatherJson);
  }

  Future<List<Weather>> getForecast(String cityName) async {
    final url = '$baseUrl/data/2.5/forecast?q=$cityName&appid=$apiKey&lang=sp';
    print('endpoint: $url');
    final res = await this.httpClient.get(url);
    if (res.statusCode != 200) {
      throw HTTPException(res.statusCode, "No se pudo obtener datos del clima");
    }
    final forecastJson = json.decode(res.body);
    List<Weather> weathers = Weather.fromForecastJson(forecastJson);
    return weathers;
  }
}
