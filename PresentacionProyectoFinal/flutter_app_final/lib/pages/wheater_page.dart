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
          automaticallyImplyLeading: false,
          title: Center(child: const Text('Clima')),
          backgroundColor: Color(0xFF010618),
          foregroundColor: Colors.white,
        ),
        body: Container(
          color: Color(0xFF010618), // Fondo de la página
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
                      labelText: 'Ingrese la ciudad',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        weatherProvider.searchCities(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  weatherProvider.isLoading
                      ? const CircularProgressIndicator()
                      : weatherProvider.cityList == null
                          ? const Text(
                              'No se encontraron ciudades',
                              style: TextStyle(color: Colors.white),
                            )
                          : DropdownButton<String>(
                              hint: const Text(
                                'Seleccione la ciudad',
                                style: TextStyle(color: Colors.white),
                              ),
                              items: weatherProvider.cityList!.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city['id'].toString(),
                                  child: Text(
                                      '${city['name']}, ${city['sys']['country']}',
                                      style: TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  weatherProvider.getWeather(value);
                                }
                              },
                              dropdownColor: Color(0xFF21283F),
                            ),
                  const SizedBox(height: 16),
                  weatherProvider.isLoading
                      ? const CircularProgressIndicator()
                      : weatherProvider.weatherData == null
                          ? const Text(
                              'Introduzca una ciudad para obtener información meteorológica',
                              style: TextStyle(color: Colors.white),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Ciudad: ${weatherProvider.weatherData!.city}',
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                Text(
                                  'Temperatura: ${weatherProvider.weatherData!.temperature}°C',
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                Text(
                                  'Clima: ${weatherProvider.weatherData!.description}',
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                // Mostrar el ícono del clima
                                Image.network(
                                  'https://openweathermap.org/img/wn/${weatherProvider.weatherData!.icon}@2x.png',
                                  width: 100,
                                  height: 100,
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
