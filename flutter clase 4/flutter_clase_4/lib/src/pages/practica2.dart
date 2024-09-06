import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class Practica2Page extends StatelessWidget {
  const Practica2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Practica de Componentes'),
        ),
        body: Stack(
          children: [
            Positioned(
              left: 40,
              top: 40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 40,
              top: 40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 120),
                const Center(
                  child: Text(
                    'Bienvenidos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 180),
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 60,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyApp(),
                          ),
                        );
                      },
                      child: const Text(
                        'Nueva Pagina',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 180),
                const Center(
                  child: Text('Practica Componentes'),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.arrow_circle_left_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
