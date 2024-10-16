import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database5.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT,
        isAdmin INTEGER DEFAULT 0 -- Agregado campo isAdmin
      )
    ''');

    await db.execute('''
      CREATE TABLE equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nameE TEXT,
        reservedDates TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipmentId INTEGER,
        userId INTEGER,
        nameE TEXT,
        name TEXT,
        date TEXT,
        startTime TEXT,
        endTime TEXT,
        FOREIGN KEY (equipmentId) REFERENCES equipment(id),
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Inserta los equipos iniciales
    await db.insert('equipment', {'nameE': 'GPS SOUTH', 'reservedDates': ''});
    await db
        .insert('equipment', {'nameE': 'GPS HEMISPHERE', 'reservedDates': ''});
    await db.insert('equipment', {'nameE': 'GPS SANDING', 'reservedDates': ''});
    await db.insert('equipment', {'nameE': 'GPS TOPCON', 'reservedDates': ''});
    await db
        .insert('equipment', {'nameE': 'ESTACION TOTAL', 'reservedDates': ''});
    await db.insert(
        'equipment', {'nameE': 'TRIPODE DE MADERA', 'reservedDates': ''});
    await db.insert('equipment',
        {'nameE': 'TRIPODE DE ALUMNIO GRANDE', 'reservedDates': ''});
    await db.insert('equipment',
        {'nameE': 'TRIPODE DE ALUMINIO CHICO', 'reservedDates': ''});
    await db.insert(
        'equipment', {'nameE': 'BASTON DE CARBONO VERDE', 'reservedDates': ''});
    await db.insert(
        'equipment', {'nameE': 'BASTON DE CARBONO ROJO', 'reservedDates': ''});
    await db.insert('equipment',
        {'nameE': 'BASTON DE CARBONO AMARRILLO', 'reservedDates': ''});
    await db
        .insert('equipment', {'nameE': 'BASTON DE CANO', 'reservedDates': ''});

    await db.insert('users', {
      'name': 'Joaquin Riera',
      'email': 'joariera@gmail.com',
      'password': 'password1',
      'isAdmin': 1 // Asignar como administrador
    });
    await db.insert('users', {
      'name': 'Alejandro Munizaga',
      'email': 'munizagaroger@gmail.com',
      'password': 'password2',
      'isAdmin': 0
    });
    await db.insert('users', {
      'name': 'Juan Pablo Munizaga',
      'email': 'jpmuni@gmail.com',
      'password': 'password3',
      'isAdmin': 0
    });
  }

  Future<List<Map<String, dynamic>>> getAllEquipment() async {
    final db = await database;
    return await db.query('equipment');
  }

  Future<List<Map<String, dynamic>>> fetchAvailableEquipments(
      String date) async {
    final db = await database;

    // Obtener los eventos reservados para la fecha específica
    final reservedEquipments = await db.query(
      'events',
      where: 'date = ?',
      whereArgs: [date],
    );

    // Crear un conjunto de IDs de equipos reservados
    Set<int> reservedIds =
        reservedEquipments.map((event) => event['equipmentId'] as int).toSet();

    // Obtener todos los equipos
    final allEquipments = await db.query('equipment');

    // Filtrar los equipos reservados
    return allEquipments
        .where((equipment) => !reservedIds.contains(equipment['id']))
        .toList();
  }

  Future<bool> reserveEquipment(
    int equipmentId,
    String date,
    String userId,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) async {
    final db = await database;

    // Comprobar si ya hay una reserva para el equipo en la fecha y el rango de tiempo especificados
    final reservedEvents = await db.query(
      'events',
      where: 'equipmentId = ? AND date = ?',
      whereArgs: [equipmentId, date],
    );

    for (var event in reservedEvents) {
      final eventStartTime =
          TimeOfDay.fromDateTime(DateTime.parse(event['startTime'] as String));
      final eventEndTime =
          TimeOfDay.fromDateTime(DateTime.parse(event['endTime'] as String));

      // Comprobar si hay un conflicto de horario
      if ((startTime.hour < eventEndTime.hour &&
              endTime.hour > eventStartTime.hour) ||
          (startTime.hour == eventEndTime.hour &&
              startTime.minute < eventEndTime.minute) ||
          (endTime.hour == eventStartTime.hour &&
              endTime.minute > eventStartTime.minute)) {
        return false; // Ya reservado en este rango de tiempo
      }
    }

    // Si no hay conflictos, guarda la nueva reserva
    final List<Map<String, dynamic>> equipmentData = await db.query(
      'equipment',
      where: 'id = ?',
      whereArgs: [equipmentId],
    );

    if (equipmentData.isNotEmpty) {
      String reservedDates = equipmentData.first['reservedDates'] as String;
      Set<String> reservedDatesSet =
          reservedDates.isEmpty ? {} : reservedDates.split(',').toSet();

      reservedDatesSet.add('$date-$userId'); // Formato "fecha-userId"
      String updatedDates = reservedDatesSet.join(',');

      // Guardar la nueva reserva en la tabla de eventos
      await db.insert('events', {
        'equipmentId': equipmentId,
        'date': date,
        'userId': userId,
        'startTime':
            DateTime(0, 0, 0, startTime.hour, startTime.minute).toString(),
        'endTime': DateTime(0, 0, 0, endTime.hour, endTime.minute).toString(),
      });

      await db.update(
        'equipment',
        {'reservedDates': updatedDates},
        where: 'id = ?',
        whereArgs: [equipmentId],
      );
      return true;
    }
    return false;
  }

  Future<void> freeEquipment(int equipmentId, String date) async {
    final db = await database;
    final List<Map<String, dynamic>> equipmentData = await db.query(
      'equipment',
      where: 'id = ?',
      whereArgs: [equipmentId],
    );

    if (equipmentData.isNotEmpty) {
      String reservedDates = equipmentData.first['reservedDates'] as String;
      Set<String> reservedDatesSet = reservedDates.split(',').toSet();

      if (reservedDatesSet.contains(date)) {
        reservedDatesSet.remove(date);
        String updatedDates = reservedDatesSet.join(',');

        await db.update(
          'equipment',
          {'reservedDates': updatedDates},
          where: 'id = ?',
          whereArgs: [equipmentId],
        );
      }
    }
  }

  // Inserta un usuario
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  // Obtén todos los usuarios
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // Obtén un usuario por su ID
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Actualiza un usuario
  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  // Elimina un usuario
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtén un usuario por correo y contraseña
  Future<List<Map<String, dynamic>>> getUserByEmailAndPassword(
      String email, String password) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
  }

  // Obtener los detalles del equipo alquilado por ID de equipo
  Future<Map<String, dynamic>?> getEquipmentById(int equipmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'equipment',
      where: 'id = ?',
      whereArgs: [equipmentId],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Obtener todas las reservas de todos los usuarios
  Future<List<Map<String, dynamic>>> getAllReservations() async {
    final db = await database;
    return await db.query('events');
  }

  // Obtener si el usuario es administrador
  Future<bool> isAdmin(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ? AND isAdmin = 1',
      whereArgs: [userId],
    );
    return result.isNotEmpty;
  }

  // Obtener el nombre de usuario por ID
// Obtener el nombre de usuario por ID
  Future<String> getUserName(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return 'Usuario no encontrado'; // Proporcionar un valor por defecto
  }

  Future<List<Map<String, dynamic>>> fetchEventsWithUserDetails(
      String date) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT users.name AS userName, equipment.nameE AS equipmentName, events.date
    FROM events
    JOIN users ON events.userId = users.id
    JOIN equipment ON events.equipmentId = equipment.id
    WHERE events.date = ?
  ''', [date]);
    return results;
  }

  Future<List<Map<String, dynamic>>> getUserDetailsByReservationDate(
      String date) async {
    final db = await database;

    print('Buscando detalles para la fecha: $date'); // Añadir este print

    final List<Map<String, dynamic>> results = await db.rawQuery('''
  SELECT users.name, equipment.nameE, events.date, events.startTime, events.endTime
  FROM events
  JOIN users ON events.userId = users.id
  JOIN equipment ON events.equipmentId = equipment.id
  WHERE events.date = ?''', [date]);

    print('Resultados de la consulta: $results'); // Imprimir los resultados

    return results;
  }

  // Agrega este método para obtener todos los usuarios
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }
}
