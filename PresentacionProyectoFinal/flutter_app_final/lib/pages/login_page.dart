import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/today_page.dart';
import 'package:flutter_app_final/pages/wheater_page.dart';
import 'package:flutter_app_final/utils/navigation_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _InputPageState();
}

class _InputPageState extends State<LoginPage> {
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Iniciar Sesión',
            style: TextStyle(color: Colors.white), // Texto blanco en el AppBar
          ),
        ),
        backgroundColor: Color(0xFF010618), // Fondo del AppBar
      ),
      body: Container(
        color: Color(0xFF010618), // Fondo de la pantalla
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50.0),
          children: [
            _crearEmail(),
            const Divider(
              color: Colors.transparent, // Cambiado a transparente
              height: 30.0,
            ),
            _crearPassword(),
            const SizedBox(
              height: 400.0,
            ),
            SizedBox(
              width: double
                  .infinity, // Extiende el botón a todo el ancho disponible
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xFF80B3FF)), // Fondo del botón
                  elevation: MaterialStateProperty.all<double>(10.0),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Color(0xFF010618)), // Color del texto
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

  Widget _crearEmail() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.white), // Texto blanco
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFF21283F), // Color de fondo del input
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Email',
        hintStyle: TextStyle(color: Colors.white54), // Color del hint
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.white), // Color de la etiqueta
        suffixIcon: const Icon(Icons.alternate_email,
            color: Colors.white), // Icono en blanco
        icon: const Icon(Icons.email, color: Colors.white), // Icono en blanco
      ),
      onChanged: (valor) {
        setState(() {
          _email = valor;
        });
      },
    );
  }

  Widget _crearPassword() {
    return TextField(
      obscureText: true,
      style: TextStyle(color: Colors.white), // Texto blanco
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFF21283F), // Color de fondo del input
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Password',
        hintStyle: TextStyle(color: Colors.white54), // Color del hint
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white), // Color de la etiqueta
        suffixIcon:
            const Icon(Icons.lock_open, color: Colors.white), // Icono en blanco
        icon: const Icon(Icons.lock, color: Colors.white), // Icono en blanco
      ),
      onChanged: (valor) {
        setState(() {});
      },
    );
  }
}
