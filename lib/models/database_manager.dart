import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  Database? _database;
  Future<void> open() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'your_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            phoneNumber TEXT,
            profilePhotoUrl TEXT
          )
        ''');
      },
    );
  }

  Future<void> updateUserProfile({
    required String id,
    required String name,
    required String phoneNumber,
    required String profilePhotoUrl,
  }) async {
    await _database!.update(
      'user_profile',
      {
        'name': name,
        'phoneNumber': phoneNumber,
        'profilePhotoUrl': profilePhotoUrl,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertUserProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String profilePhotoUrl,
  }) async {
    await _database!.insert(
      'user_profile',
      {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'profilePhotoUrl': profilePhotoUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final List<Map<String, dynamic>> profiles = await _database!.query(
      'user_profile',
      limit: 1,
    );

    return profiles.isNotEmpty ? profiles.first : null;
  }

  Future<void> updateProfilePhotoUrl(String newProfilePhotoUrl) async {
    await _database!.update(
      'user_profile',
      {'profilePhotoUrl': newProfilePhotoUrl},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> close() async {
    await _database!.close();
  }
}
