import 'package:sqflite/sqflite.dart' as sql;

class DbHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items 
        (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        title TEXT, description TEXT, 
        createdAt TIMESTAMP NOT NULL DEFAULT current_timestamp)
        """);
  }

  static Future<sql.Database> db() async {
    return await sql.openDatabase(
      "database.db",
      version: 1,
      onCreate: (db, version) {
        print('..creating table');
        createTables(db);
      },
    );
  }

  static Future<int> createItem(String title, String? description) async {
    final db = await DbHelper.db();

    final data = {"title": title, "description": description};
    return await db.insert("items", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DbHelper.db();
    return await db.query('items', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DbHelper.db();

    return await db.query('items', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String title, String description) async {
    final db = await DbHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };

    return await db.update('items', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteItem(int id) async {
    final db = await DbHelper.db();

    try {
      return await db.delete('items', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("somthing went wrong : $e");
      return -1;
    }
  }
}
