class WeatherData {
  final String city;
  final double temperature;
  final String description;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    print('Parsing JSON: $json');
    return WeatherData(
      city: json['name'] as String,
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
    );
  }
}
