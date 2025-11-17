import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/hike.dart';
import '../models/observation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('m_hike.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create hikes table
    await db.execute('''
      CREATE TABLE hikes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        date TEXT NOT NULL,
        parkingAvailable TEXT NOT NULL,
        length REAL NOT NULL,
        difficulty TEXT NOT NULL,
        description TEXT,
        weatherCondition TEXT,
        estimatedDuration TEXT
      )
    ''');

    // Create observations table
    await db.execute('''
      CREATE TABLE observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hikeId INTEGER NOT NULL,
        observation TEXT NOT NULL,
        time TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'General',
        location TEXT NOT NULL DEFAULT 'Unknown location',
        additionalComments TEXT,
        photoPath TEXT,
        FOREIGN KEY (hikeId) REFERENCES hikes (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add photoPath column to observations table
      await db.execute('ALTER TABLE observations ADD COLUMN photoPath TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE observations ADD COLUMN category TEXT NOT NULL DEFAULT 'General'",
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE observations ADD COLUMN location TEXT NOT NULL DEFAULT 'Unknown location'",
      );
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
    await db.delete('observations'); // Delete all observations first
    return await db.delete('hikes');
  }

  // ========== OBSERVATION OPERATIONS ==========

  Future<int> insertObservation(Observation observation) async {
    final db = await database;
    return await db.insert('observations', observation.toMap());
  }

  Future<List<Observation>> getObservationsByHikeId(int hikeId) async {
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
    double? minLength,
    double? maxLength,
    DateTime? startDate,
    DateTime? endDate,
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

    if (minLength != null) {
      whereClauses.add('length >= ?');
      whereArgs.add(minLength);
    }

    if (maxLength != null) {
      whereClauses.add('length <= ?');
      whereArgs.add(maxLength);
    }

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final where = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final result = await db.query(
      'hikes',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );

    return result.map((map) => Hike.fromMap(map)).toList();
  }

  // Reset database (delete all data)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('observations');
    await db.delete('hikes');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
