import 'package:cashflow/models/caisse.dart';
import 'package:cashflow/models/objectif.dart';
import 'package:cashflow/models/utilisateur.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ma_caisse.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE utilisateurs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT,
        email TEXT UNIQUE,
        motDePasse TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE caisse(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        montant REAL,
        date TEXT,
        utilisateurId INTEGER,
        FOREIGN KEY (utilisateurId) REFERENCES utilisateurs(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE objectif(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        montantCible REAL,
        dateLimite TEXT,
        description TEXT,
        montantEconomise REAL,
        utilisateurId INTEGER,
        estPrincipal INTEGER,
        FOREIGN KEY (utilisateurId) REFERENCES utilisateurs(id)
      )
    ''');
  }

  Future<void> insertUtilisateur(Utilisateur utilisateur) async {
    final db = await database;
    await db.insert('utilisateurs', utilisateur.toMap());
  }

  Future<Utilisateur?> getUtilisateurByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'utilisateurs',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return Utilisateur.fromMap(maps.first);
    }
    return null;
  }

  Future<Utilisateur?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'utilisateurs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Utilisateur.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertCaisse(Caisse caisse) async {
    final db = await database;
    await db.insert('caisse', caisse.toMap());
  }

  Future<List<Caisse>> getCaisseByUtilisateur(int utilisateurId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'caisse',
      where: 'utilisateurId = ?',
      whereArgs: [utilisateurId],
      // orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Caisse.fromMap(maps[i]));
  }

  Future<void> insertObjectif(Objectif objectif) async {
    final db = await database;
    try {
      await db.insert('objectif', objectif.toMap());
    } catch (e) {
      print('Erreur lors de l\'insertion de l\'objectif : $e');
    }
  }

  Future<List<Objectif>> getObjectifsByUtilisateur(int utilisateurId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'objectif',
      where: 'utilisateurId = ?',
      whereArgs: [utilisateurId],
      // orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Objectif.fromMap(maps[i]));
  }

  Future<void> updateCaisse(Caisse caisse) async {
    final db = await database;
    await db.update(
      'caisse',
      caisse.toMap(),
      where: 'id = ?',
      whereArgs: [caisse.id],
    );
  }

  Future<void> updateObjectif(Objectif objectif) async {
    final db = await database;
    await db.update(
      'objectif',
      objectif.toMap(),
      where: 'id = ?',
      whereArgs: [objectif.id],
    );
  }

  Future<void> deleteCaisse(int id) async {
    final db = await database;
    await db.delete(
      'caisse',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteObjectif(int id) async {
    final db = await database;
    await db.delete(
      'objectif',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePassword(int utilisateurId, String newPassword) async {
    final db = await database;
    await db.update(
      'utilisateurs',
      {'motDePasse': newPassword},
      where: 'id = ?',
      whereArgs: [utilisateurId],
    );
  }
}
