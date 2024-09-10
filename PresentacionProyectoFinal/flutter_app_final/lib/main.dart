import 'package:flutter/material.dart';
import 'package:flutter_app_final/routes/routes.dart';
import 'package:flutter_app_final/providers/weather_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: '/', // Cambia esta línea
        routes: getAplicationRoutes(),
      ),
    );
  }
}
