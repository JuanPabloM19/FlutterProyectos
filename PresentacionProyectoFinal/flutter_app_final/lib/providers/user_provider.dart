import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Nombre Desconocido';
  String _email = 'Correo Desconocido';
  String _userId = '0'; // Inicializa el userId

  // Simulando obtener el usuario desde una base de datos o API
  void loadUserData(String name, String email, String userId) {
    _name = name;
    _email = email;
    _userId = userId; // Asigna el userId
    notifyListeners(); // Notifica a los listeners cuando los datos cambian
  }

  String get name => _name;
  String get email => _email;
  String get userId => _userId; // Getter para userId
}
