import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/hike.dart';
import '../models/observation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hikes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath;

    // Use different path providers for mobile vs desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final directory = await getApplicationDocumentsDirectory();
      dbPath = join(directory.path, filePath);
    } else {
      dbPath = join(await getDatabasesPath(), filePath);
    }

    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const dateType = 'TEXT NOT NULL';
    const realTypeNullable = 'REAL';

    // Create hikes table
    await db.execute('''
      CREATE TABLE hikes (
        id $idType,
        name $textType,
        location $textType,
        date $dateType,
        parkingAvailable $textType,
        length $textType,
        difficulty $textType,
        description $textTypeNullable,
        weatherConditions $textTypeNullable,
        estimatedDuration $textTypeNullable,
        photoPath $textTypeNullable,
        latitude $realTypeNullable,
        longitude $realTypeNullable
      )
    ''');

    // Create observations table
    await db.execute('''
      CREATE TABLE observations (
        id $idType,
        hikeId $intType,
        observation $textType,
        time $dateType,
        comments $textTypeNullable,
        photoPath $textTypeNullable,
        FOREIGN KEY (hikeId) REFERENCES hikes (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for enhancements
      try {
        await db.execute('ALTER TABLE hikes ADD COLUMN photoPath TEXT');
        await db.execute('ALTER TABLE hikes ADD COLUMN latitude REAL');
        await db.execute('ALTER TABLE hikes ADD COLUMN longitude REAL');
        await db.execute('ALTER TABLE observations ADD COLUMN photoPath TEXT');
      } catch (e) {
        // Columns might already exist, ignore error
      }
    }
  }

  // ========== HIKE OPERATIONS ==========

  Future<int> insertHike(Hike hike) async {
    final db = await database;
    return await db.insert('hikes', hike.toMap());
  }

  Future<List<Hike>> getAllHikes() async {
    final db = await database;
    final result = await db.query('hikes', orderBy: 'date DESC');
    return result.map((map) => Hike.fromMap(map)).toList();
  }

  Future<Hike?> getHike(int id) async {
    final db = await database;
    final result = await db.query('hikes', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Hike.fromMap(result.first);
  }

  Future<int> updateHike(Hike hike) async {
    final db = await database;
    return await db.update(
      'hikes',
      hike.toMap(),
      where: 'id = ?',
      whereArgs: [hike.id],
    );
  }

  Future<int> deleteHike(int id) async {
    final db = await database;
    // Delete observations first (CASCADE should handle this, but being explicit)
    await db.delete('observations', where: 'hikeId = ?', whereArgs: [id]);
    return await db.delete('hikes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllHikes() async {
    final db = await database;
    // Delete all observations first
    await db.delete('observations');
    return await db.delete('hikes');
  }

  // ========== OBSERVATION OPERATIONS ==========

  Future<int> insertObservation(Observation observation) async {
    final db = await database;
    return await db.insert('observations', observation.toMap());
  }

  Future<List<Observation>> getObservationsForHike(int hikeId) async {
    final db = await database;
    final result = await db.query(
      'observations',
      where: 'hikeId = ?',
      whereArgs: [hikeId],
      orderBy: 'time DESC',
    );
    return result.map((map) => Observation.fromMap(map)).toList();
  }

  Future<Observation?> getObservation(int id) async {
    final db = await database;
    final result = await db.query(
      'observations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Observation.fromMap(result.first);
  }

  Future<int> updateObservation(Observation observation) async {
    final db = await database;
    return await db.update(
      'observations',
      observation.toMap(),
      where: 'id = ?',
      whereArgs: [observation.id],
    );
  }

  Future<int> deleteObservation(int id) async {
    final db = await database;
    return await db.delete('observations', where: 'id = ?', whereArgs: [id]);
  }

  // ========== SEARCH OPERATIONS ==========

  Future<List<Hike>> searchHikesByName(String query) async {
    final db = await database;
    final result = await db.query(
      'hikes',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => Hike.fromMap(map)).toList();
  }

  Future<List<Hike>> advancedSearch({
    String? name,
    String? location,
    String? length,
    DateTime? date,
  }) async {
    final db = await database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (name != null && name.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      whereArgs.add('%$name%');
    }

    if (location != null && location.isNotEmpty) {
      whereClauses.add('location LIKE ?');
      whereArgs.add('%$location%');
    }

    if (length != null && length.isNotEmpty) {
      whereClauses.add('length LIKE ?');
      whereArgs.add('%$length%');
    }

    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      whereClauses.add('date LIKE ?');
      whereArgs.add('$dateStr%');
    }

    if (whereClauses.isEmpty) {
      return getAllHikes();
    }

    final where = whereClauses.join(' AND ');
    final result = await db.query(
      'hikes',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((map) => Hike.fromMap(map)).toList();
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
