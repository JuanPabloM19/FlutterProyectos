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
    String path = join(await getDatabasesPath(), 'app_database2.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nameE TEXT,
        reservedDates TEXT
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
    });
    await db.insert('users', {
      'name': 'Alejandro Munizaga',
      'email': 'munizagaroger@gmail.com',
      'password': 'password2',
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
}
