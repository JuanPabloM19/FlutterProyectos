import 'package:flutter/material.dart';
//Se importa el archivo de rutas
import 'package:flutter_practico_1/src/routes/routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(   
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: '/',
//Se llama al método del archivo routes.dart para obtener el string
//con las rutas de navegación
      routes: getAplicationRoutes(),
    );
  }
}
