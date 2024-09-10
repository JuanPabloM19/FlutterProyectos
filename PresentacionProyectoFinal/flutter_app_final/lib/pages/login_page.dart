import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/calendar_example.dart';
import 'package:flutter_app_final/pages/today_page.dart';
import 'package:flutter_app_final/pages/wheater_page.dart';
import 'package:flutter_app_final/utils/navigation_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _InputPageState();
}

class _InputPageState extends State<LoginPage> {
  final String _nombre = '';
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Iniciar Sesión',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50.0),
        children: [
          _crearEmail(),
          const Divider(
            color: Colors.white,
            height: 30.0,
          ),
          _crearPassword(),
          const SizedBox(
            height: 400.0,
          ),
          SizedBox(
            width:
                double.infinity, // Extiende el botón a todo el ancho disponible
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_circle_left_outlined),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _crearEmail() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          hintText: 'Email',
          labelText: 'Email',
          suffixIcon: const Icon(Icons.alternate_email),
          icon: const Icon(Icons.email)),
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
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          hintText: 'Password',
          labelText: 'Password',
          suffixIcon: const Icon(Icons.lock_open),
          icon: const Icon(Icons.lock)),
      onChanged: (valor) {
        setState(() {});
      },
    );
  }
}
