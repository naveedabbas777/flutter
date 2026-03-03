import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/weather_models.dart';

const String weatherApiKey = String.fromEnvironment(
  'WEATHER_API_KEY',
  defaultValue: '33650910d7574dd38a7123318260303',
);

class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherSnapshot> fetchByCity(String city) async {
    if (city.trim().isEmpty) {
      throw const WeatherException('Please enter a city name.');
    }

    if (weatherApiKey.isEmpty) {
      throw const WeatherException('Add WeatherAPI key using --dart-define.');
    }

    final uri = Uri.https('api.weatherapi.com', '/v1/forecast.json', {
      'key': weatherApiKey,
      'q': city.trim(),
      'aqi': 'yes',
      'days': '7',
    });

    try {
      final response = await _client.get(uri);
      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200) {
        String? apiMessage;
        if (decoded is Map<String, dynamic>) {
          final errorBody = decoded['error'];
          if (errorBody is Map<String, dynamic>) {
            apiMessage = errorBody['message']?.toString();
          }
        }
        throw WeatherException(apiMessage ?? 'Failed to load weather data.');
      }

      if (decoded is! Map<String, dynamic>) {
        throw const WeatherException(
          'Unexpected response from weather server.',
        );
      }

      return WeatherSnapshot.fromJson(decoded);
    } on WeatherException {
      rethrow;
    } catch (_) {
      throw const WeatherException('Network error. Please try again.');
    }
  }
}

class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}
