import 'package:flutter/material.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/routes/routes.dart';
import 'package:flutter_app_final/providers/weather_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importar esta biblioteca

void main() {
  initializeDateFormatting().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                EventProvider()), // Añade tu EventProvider aquí
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: '/',
        routes: getAplicationRoutes(),
      ),
    );
  }
}
