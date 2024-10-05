import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/today_page.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:flutter_app_final/utils/navigation_bar.dart';
import 'package:provider/provider.dart';

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
            const Divider(
              color: Colors.transparent,
              height: 30.0,
            ),
            _crearPassword(),
            const SizedBox(
              height: 400.0,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _login(context); // Llama al método de login
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF21283F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Email',
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: 'Email',
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
        hintText: 'Password',
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: 'Password',
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
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> user =
        await dbHelper.getUserByEmailAndPassword(_email, _password);

    if (user.isNotEmpty) {
      // Login exitoso
      String name =
          user[0]['name']; // Asegúrate de que el nombre esté en el mapa
      String email =
          user[0]['email']; // Asegúrate de que el correo esté en el mapa

      // Cargar datos del usuario en el UserProvider
      Provider.of<UserProvider>(context, listen: false)
          .loadUserData(name, email, user[0]['id'].toString());

      _showSuccessDialog(context);
    } else {
      // Login fallido
      _showErrorDialog(context);
    }
  }

  void _showErrorDialog(BuildContext context) {
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
          content: const Text("Correo y/o contraseña incorrecta"),
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Evita que el diálogo se cierre al hacer clic fuera
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 4), () {
          Navigator.of(context)
              .pop(); // Cierra el diálogo después de 4 segundos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        });

        return const AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Éxito"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea los textos a la izquierda
            children: [
              Text("Inicio de sesión exitoso"),
              SizedBox(height: 10), // Espacio entre los textos
              Text("Por favor espere...")
            ],
          ),
        );
      },
    );
  }
}
