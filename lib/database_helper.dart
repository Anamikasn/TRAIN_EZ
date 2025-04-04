import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'user_images';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'profile_images.db');
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $tableName (id TEXT PRIMARY KEY, imagePath TEXT)",
        );
      },
    );
  }

  Future<void> saveImagePath(String userId, String imagePath) async {
    final db = await database;
    await db.insert(
      tableName,
      {'id': userId, 'imagePath': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteImagePath(String userId) async {
  final db = await database;
  await db.delete(
    'user_images', // Replace with the actual table name storing the image path
    where: 'id = ?', // Replace 'id' with the actual column name for user ID
    whereArgs: [userId],
  );
}


  Future<String?> getImagePath(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "id = ?",
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return maps.first['imagePath'] as String;
    }
    return null; // No image found
  }
}
