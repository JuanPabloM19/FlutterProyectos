import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/user_model.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Nombre Desconocido';
  String _email = 'Correo Desconocido';
  String _userId = '0';
  bool _isAdmin = false;

  final Map<String, User> _users = {};

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Método para cargar todos los usuarios
  Future<void> loadAllUsers() async {
    final users =
        await _dbHelper.getAllUsers(); // Asegúrate de que este método existe
    _users.clear(); // Limpia usuarios previos
    for (var user in users) {
      _users[user['id'].toString()] = User(
        // Convierte id a String
        userId: user['id'].toString(),
        name: user['name'],
        email: user['email'],
        isAdmin: user['isAdmin'] == 1,
      );
    }
    notifyListeners(); // Notifica a los listeners para actualizar la UI
  }

// Método para obtener el nombre del usuario por ID
  String getUserNameById(String userId) {
    // Verifica si el mapa de usuarios contiene el userId
    if (_users.containsKey(userId)) {
      return _users[userId]?.name ?? "Usuario desconocido";
    } else {
      return "Usuario desconocido"; // Si no se encuentra, devuelve este valor
    }
  }

  // Método para cargar datos del usuario
  Future<void> loadUserData(String email, String password) async {
    final user = await _dbHelper.getUserByEmailAndPassword(email, password);

    if (user.isNotEmpty) {
      _name = user.first['name'];
      _email = user.first['email'];
      _userId = user.first['id'].toString(); // Asegúrate de convertir a String
      _isAdmin = user.first['isAdmin'] == 1;
      notifyListeners();
    } else {
      _name = 'Nombre Desconocido';
      _email = 'Correo Desconocido';
      _userId = '0';
      _isAdmin = false;
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

  // Método para cargar los nombres de usuario desde la base de datos
  Future<void> loadUserNames() async {
    final List<Map<String, dynamic>> userData =
        await DatabaseHelper().getAllUsers();

    // Limpiar el mapa existente
    _users.clear();

    // Agregar los usuarios al mapa
    for (var user in userData) {
      _users[user['userId'].toString()] = User(
        userId: user['userId'].toString(),
        name: user['name'],
        email: user['email'],
        isAdmin: user['isAdmin'] == 1,
      );
    }

    // Notificar a los listeners para actualizar la UI
    notifyListeners();
  }
}
