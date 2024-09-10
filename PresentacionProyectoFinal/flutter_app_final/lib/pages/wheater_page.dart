import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherPage extends StatelessWidget {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<WeatherProvider>(
            builder: (context, weatherProvider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter city',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        weatherProvider.searchCities(value);
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  weatherProvider.isLoading
                      ? CircularProgressIndicator()
                      : weatherProvider.cityList == null
                          ? const Text('No cities found')
                          : DropdownButton<String>(
                              hint: const Text('Select city'),
                              items: weatherProvider.cityList!.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city['id'].toString(),
                                  child: Text(
                                      '${city['name']}, ${city['sys']['country']}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  weatherProvider.getWeather(value);
                                }
                              },
                            ),
                  SizedBox(height: 16),
                  weatherProvider.isLoading
                      ? CircularProgressIndicator()
                      : weatherProvider.weatherData == null
                          ? const Text(
                              'Enter a city to get weather information')
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'City: ${weatherProvider.weatherData!.city}',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'Temperature: ${weatherProvider.weatherData!.temperature}°C',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'Weather: ${weatherProvider.weatherData!.description}',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
