import 'package:flutter/material.dart';
import 'package:mi_primera_app/pages/contador_page.dart'; // Importa el archivo de ContadorPage
//import 'package:mi_primera_app/pages/home_page.dart'; // Importa el archivo de HomePage


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ContadorPage(), // Muestra la página del contador
      // home: HomePage(), // Alternativamente, puedes mostrar HomePage
    );
  }
}

void main() {
  runApp(const MyApp());
}
