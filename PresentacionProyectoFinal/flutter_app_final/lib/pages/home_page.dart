import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/login_page.dart';

void main() => runApp(const HomePage());

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF010618), // Fondo de la página
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
          children: [
            Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.all(100.0),
              child: Image.asset('assets/image_home.png'),
            ),
            const Text(
              'TECCAPP',
              style: TextStyle(
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Letras blancas
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(
              height: 200.0,
            ),
            SizedBox(
              width: 350.0, // Ancho del botón
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFF80B3FF)), // Color de fondo del botón
                  elevation: MaterialStateProperty.all<double>(10.0),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFF010618)), // Color del texto del botón
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
