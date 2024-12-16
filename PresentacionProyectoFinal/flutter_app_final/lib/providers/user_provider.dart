import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Nombre Desconocido';
  String _email = 'Correo Desconocido';
  String _userId = '0';
  bool _isAdmin = false;

  final Map<String, User> _users = {};

  String get name => _name;
  String get email => _email;
  String get userId => _userId;
  bool get isAdmin => _isAdmin;

  /// Método para verificar si el usuario actual es administrador
  Future<bool> checkIfUserIsAdmin() async {
    if (_isAdmin) return _isAdmin;
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
  Future<void> loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _userId = currentUser.uid;

        final nameSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('name')
            .limit(1)
            .get();

        if (nameSnapshot.docs.isNotEmpty) {
          _name =
              nameSnapshot.docs.first.data()['name'] ?? 'Nombre Desconocido';
        }

        final emailSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('email')
            .limit(1)
            .get();

        if (emailSnapshot.docs.isNotEmpty) {
          _email =
              emailSnapshot.docs.first.data()['email'] ?? 'Correo Desconocido';
        }

        print('Usuario cargado: Nombre=$_name, Correo=$_email, UID=$_userId');
      } else {
        resetUserData();
      }

      notifyListeners();
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
    }
  }

  /// Método para cargar los nombres de usuarios desde Firestore
  Future<void> loadUserNames() async {
    try {
      final usersCollection =
          await FirebaseFirestore.instance.collection('users').get();
      _users.clear();

      for (var userDoc in usersCollection.docs) {
        final userId = userDoc.id;
        final nameSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('name')
            .limit(1)
            .get();

        final userName = nameSnapshot.docs.isNotEmpty
            ? nameSnapshot.docs.first.data()['name']
            : 'Usuario desconocido';
        final emailSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('email')
            .limit(1)
            .get();

        final userEmail = emailSnapshot.docs.isNotEmpty
            ? emailSnapshot.docs.first.data()['email']
            : 'Correo desconocido';

        _users[userId] = User(
          userId: userId,
          name: userName,
          email: userEmail,
          isAdmin: userDoc.data()?['isAdmin'] == true,
        );
      }

      notifyListeners();
    } catch (e) {
      print("Error al cargar los nombres de usuario: $e");
    }
  }

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
