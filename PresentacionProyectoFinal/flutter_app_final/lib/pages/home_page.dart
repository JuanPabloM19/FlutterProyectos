import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/login_page.dart';

void main() => runApp(const HomePage());

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
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
                color: Colors.black,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(
              height: 200.0,
            ),
            SizedBox(
              width: 350.0, // Extiende el botón a todo el ancho disponible
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                  elevation: WidgetStateProperty.all<double>(10.0),
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  foregroundColor: WidgetStateProperty.all<Color>(
                      Colors.black), // Cambia el color del texto a negro
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
