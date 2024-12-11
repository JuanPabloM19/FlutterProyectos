import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/listAdmin_page.dart';
import 'package:flutter_app_final/utils/navigation_bar.dart';
import '../services/firebase_services.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Nombre Desconocido';
  String _email = 'Correo Desconocido';
  String _userId = '0';
  bool _isAdmin = false;

  final Map<String, User> _users = {};
  final FirebaseServices _firebaseServices = FirebaseServices();

  /// Método para verificar si el usuario actual es administrador
  Future<bool> checkIfUserIsAdmin() async {
    if (_isAdmin) return _isAdmin; // Evitar múltiples solicitudes innecesarias
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        var doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (doc.exists) {
          _isAdmin = doc.data()?['isAdmin'] == true;
        }
      }
      notifyListeners();
      return _isAdmin;
    } catch (e) {
      print("Error al verificar el estado de admin: $e");
      return false;
    }
  }

  /// Método para obtener el nombre de usuario por ID
  String getUserNameById(String userId) {
    if (_users.containsKey(userId)) {
      return _users[userId]?.name ?? "Usuario desconocido";
    } else {
      return "Usuario desconocido";
    }
  }

  /// Método para cargar los datos de un usuario específico desde Firebase
  Future<void> loadUserData(
      String email, String password, BuildContext context) async {
    try {
      final user =
          await _firebaseServices.getUserByEmailAndPassword(email, password);

      if (user != null) {
        _name = user['name'];
        _email = user['email'];
        _userId = user['userId'].toString();
        _isAdmin = user['isAdmin'] == 1;
        print('Admin status: $_isAdmin');

        // Redireccionar basado en el estado de admin
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainPage(isAdmin: _isAdmin),
            ),
          );
        }
      } else {
        resetUserData();
      }
      notifyListeners();
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
    }
  }

  /// Método para obtener el estado de administrador
  bool get isAdmin => _isAdmin;

  /// Método para verificar si hay un usuario logueado
  bool isLoggedIn() {
    return _userId.isNotEmpty && _userId != '0';
  }

  /// Método para cerrar sesión
  void logout() {
    resetUserData();
    notifyListeners();
  }

  /// Método para reiniciar los datos de usuario
  void resetUserData() {
    _name = 'Nombre Desconocido';
    _email = 'Correo Desconocido';
    _userId = '0';
    _isAdmin = false;
  }

  /// Método para cargar los nombres de usuarios desde Firebase
  Future<void> loadUserNames() async {
    try {
      final List<Map<String, dynamic>> userData =
          await _firebaseServices.getAllUsers();
      _users.clear();
      for (var user in userData) {
        _users[user['userId'].toString()] = User(
          userId: user['userId'].toString(),
          name: user['name'],
          email: user['email'],
          isAdmin: user['isAdmin'] == 1,
        );
      }
      notifyListeners();
    } catch (e) {
      print("Error al cargar los nombres de usuario: $e");
    }
  }

  /// Verifica si el usuario actual es administrador

  // Getters de los datos del usuario actual
  String get name => _name;
  String get email => _email;
  String get userId => _userId;
}

class User {
  final String userId;
  final String name;
  final String email;
  final bool isAdmin;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.isAdmin,
  });
}
