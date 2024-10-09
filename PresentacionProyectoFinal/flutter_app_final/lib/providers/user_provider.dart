import 'package:flutter/material.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Nombre Desconocido';
  String _email = 'Correo Desconocido';
  String _userId = '0';
  bool _isAdmin = false;

  // Instancia de DatabaseHelper
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Método para cargar los datos de usuario desde la base de datos
  Future<void> loadUserData(String email, String password) async {
    final user = await _dbHelper.getUserByEmailAndPassword(email, password);

    if (user.isNotEmpty) {
      _name = user.first['name'];
      _email = user.first['email'];
      _userId = user.first['id'].toString();
      _isAdmin = user.first['isAdmin'] ==
          1; // Esto establece el estado de isAdmin desde la base de datos
      notifyListeners();
    } else {
      // Manejo del caso donde el usuario no existe
      _name = 'Nombre Desconocido';
      _email = 'Correo Desconocido';
      _userId = '0';
      _isAdmin = false; // Asigna el valor por defecto
      notifyListeners();
    }
  }

  // Getters
  String get name => _name;
  String get email => _email;
  String get userId => _userId;
  bool get isAdmin => _isAdmin;

  bool isLoggedIn() {
    return _userId.isNotEmpty && _userId != '0';
  }

  void logout() {
    _name = 'Nombre Desconocido';
    _email = 'Correo Desconocido';
    _userId = '0';
    _isAdmin = false;
    notifyListeners();
  }
}
