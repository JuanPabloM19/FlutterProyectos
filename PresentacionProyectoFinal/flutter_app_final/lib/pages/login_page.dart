import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_final/utils/navigation_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _InputPageState();
}

class _InputPageState extends State<LoginPage> {
  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Iniciar Sesión',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xFF010618),
      ),
      body: Container(
        color: const Color(0xFF010618),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50.0),
          children: [
            _crearEmail(),
            const Divider(color: Colors.transparent, height: 30.0),
            _crearPassword(),
            const SizedBox(height: 400.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _login(context);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF80B3FF)),
                  elevation: MaterialStateProperty.all<double>(10.0),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF010618)),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 15.0),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF21283F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Correo',
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: 'Correo',
        labelStyle: const TextStyle(color: Colors.white),
        suffixIcon: const Icon(Icons.alternate_email, color: Colors.white),
        icon: const Icon(Icons.email, color: Colors.white),
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
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF21283F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Contraseña',
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: 'Contraseña',
        labelStyle: const TextStyle(color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        icon: const Icon(Icons.lock, color: Colors.white),
      ),
      onChanged: (valor) {
        setState(() {
          _password = valor;
        });
      },
    );
  }

  void _login(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      String userId = userCredential.user!.uid;

      // Usar una vez que FirebaseAuth ya tenga al usuario autenticado
      Provider.of<UserProvider>(context, listen: false).loadUserData();

      Provider.of<EventProvider>(context, listen: false).setUserId(userId);
      print("UID asignado en Provider: $userId");

      // ✅ Verificar si el usuario es administrador y obtener el resultado
      bool isAdmin = await FirebaseServices().checkIfUserIsAdmin(userId);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setBool('isAdmin', isAdmin); // Guardar si el usuario es admin

      _showSuccessDialog(context, isAdmin); // Pasar "isAdmin" al dialogo
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.message ?? "Error desconocido");
    }
  }

  void _showSuccessDialog(BuildContext context, bool isAdmin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 4), () {
          Navigator.of(context).pop();

          // Redirigir dependiendo del rol
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainPage(isAdmin: isAdmin)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainPage(isAdmin: isAdmin)),
            );
          }
        });

        return const AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Éxito"),
            ],
          ),
          content: Text("Inicio de sesión exitoso. Redirigiendo..."),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text("Error"),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text(
                "Intente nuevamente",
                style: TextStyle(color: Color(0xFF010618)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
