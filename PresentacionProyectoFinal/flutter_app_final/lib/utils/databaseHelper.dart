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
    // Obtén la ruta de la base de datos
    String path = join(await getDatabasesPath(), 'app_database.db');

    // Abre la base de datos y crea la tabla si no existe
    return await openDatabase(
      path,
      version: 1,
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

    // Inserta los usuarios predefinidos
    await db.insert('users', {
      'name': 'Joaquin Riera',
      'email': 'joariera@gmail.com',
      'password': 'password1', // Agrega una contraseña
    });
    await db.insert('users', {
      'name': 'Alejandro Munizaga',
      'email': 'munizagaroger@gmail.com',
      'password': 'password2', // Agrega una contraseña
    });
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
