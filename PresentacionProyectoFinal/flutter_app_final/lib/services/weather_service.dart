import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'ca163e9419ad5bfa0f38acd6dfde0667';

  Future<List<dynamic>> fetchCities(String city) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/find?q=$city&type=like&appid=$apiKey&units=metric&lang=es'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['list'] as List<dynamic>;
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<Map<String, dynamic>> fetchWeather(String cityId) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?id=$cityId&appid=$apiKey&units=metric&lang=es'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
