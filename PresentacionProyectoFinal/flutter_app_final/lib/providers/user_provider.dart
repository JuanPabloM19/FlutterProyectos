import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/user_model.dart';
import 'package:flutter_app_final/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Nombre Desconocido';
  String _email = 'Correo Desconocido';
  String _userId = '0';
  bool _isAdmin = false;

  final Map<String, User> _users =
      {}; // Mapa para almacenar usuarios por userId

  final FirebaseServices _firebaseServices =
      FirebaseServices(); // Uso de FirebaseServices

  // Método para cargar todos los usuarios desde Firebase
  Future<void> loadAllUsers() async {
    try {
      final users = await _firebaseServices
          .getAllUsers(); // Obtiene usuarios desde Firebase

      _users.clear(); // Limpiar el mapa de usuarios antes de agregar nuevos

      for (var user in users) {
        // Convertir userId a String y agregar al mapa
        _users[user['userId'].toString()] = User(
          userId: user['userId'].toString(),
          name: user['name'],
          email: user['email'],
          isAdmin: user['isAdmin'] == 1,
        );
      }

      notifyListeners(); // Notificar a los listeners para actualizar la UI
    } catch (e) {
      print("Error al cargar usuarios: $e");
    }
  }

  // Método para obtener el nombre del usuario por ID
  String getUserNameById(String userId) {
    // Verificar si el mapa de usuarios contiene el userId
    if (_users.containsKey(userId)) {
      return _users[userId]?.name ?? "Usuario desconocido";
    } else {
      return "Usuario desconocido"; // Si no se encuentra, devuelve este valor
    }
  }

  // Método para cargar los datos de un usuario específico desde Firebase
  Future<void> loadUserData(String email, String password) async {
    try {
      final user =
          await _firebaseServices.getUserByEmailAndPassword(email, password);

      if (user != null) {
        _name = user['name'];
        _email = user['email'];
        _userId = user['userId'].toString(); // Asegúrate de convertir a String
        _isAdmin = user['isAdmin'] == 1;
        print('Admin status: $_isAdmin');
        notifyListeners();
      } else {
        _name = 'Nombre Desconocido';
        _email = 'Correo Desconocido';
        _userId = '0';
        _isAdmin = false;
        notifyListeners();
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
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

  // Método para hacer logout
  void logout() {
    _name = 'Nombre Desconocido';
    _email = 'Correo Desconocido';
    _userId = '0';
    _isAdmin = false;
    notifyListeners();
  }

  // Método para cargar los nombres de usuarios desde Firebase (actualizado para usar Firebase)
  Future<void> loadUserNames() async {
    try {
      final List<Map<String, dynamic>> userData =
          await _firebaseServices.getAllUsers(); // Uso de Firebase

      _users.clear(); // Limpiar el mapa de usuarios

      for (var user in userData) {
        // Convertir userId a String y agregar al mapa
        _users[user['userId'].toString()] = User(
          userId: user['userId'].toString(),
          name: user['name'],
          email: user['email'],
          isAdmin: user['isAdmin'] == 1,
        );
      }

      // Notificar a los listeners para actualizar la UI
      notifyListeners();
    } catch (e) {
      print("Error al cargar los nombres de usuario: $e");
    }
  }
}
