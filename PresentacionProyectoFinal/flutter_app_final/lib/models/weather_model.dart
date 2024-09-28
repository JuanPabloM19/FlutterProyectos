class WeatherData {
  final String city;
  final double temperature;
  final String description;
  final String icon; // Nuevo campo para almacenar el código del ícono

  WeatherData({
    required this.city,
    required this.temperature,
    required this.description,
    required this.icon, // Inicializamos el campo del ícono
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['name'] as String,
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String, // Extraemos el ícono del JSON
    );
  }
}
