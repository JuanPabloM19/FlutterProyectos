import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  List<dynamic>? _cityList;
  WeatherData? _weatherData;
  bool _isLoading = false;

  List<dynamic>? get cityList => _cityList;
  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;

  Future<void> searchCities(String city) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cities = await _weatherService.fetchCities(city);
      _cityList = cities;
    } catch (e) {
      print('Error fetching cities: $e');
      _cityList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getWeather(String cityId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _weatherService.fetchWeather(cityId);
      _weatherData = WeatherData.fromJson(data);
      print('Weather data: $_weatherData');
    } catch (e) {
      print('Error fetching weather: $e');
      _weatherData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
