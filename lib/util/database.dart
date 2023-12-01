import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:caloriecalc/models/food.dart';

class DatabaseUtil {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_database.db');

    Database db = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE foods(id INTEGER PRIMARY KEY, name TEXT NOT NULL, calories INTEGER NOT NULL);',
        );

        await db.execute(
          'CREATE TABLE plans(id INTEGER PRIMARY KEY, target_calories INT, date TEXT UNIQUE NOT NULL);',
        );

        await db.execute(
          'CREATE TABLE consumed_foods(id INTEGER PRIMARY KEY, plan_id INTEGER NOT NULL, food_id INTEGER NOT NULL, FOREIGN KEY (plan_id) REFERENCES plans(id), FOREIGN KEY (food_id) REFERENCES foods(id));',
        );
        await _insertInitialFoodItems(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {},
    );

    return db;
  }

  Future<void> resetDatabase() async {
    Database db = await database;
    await db.execute(
      'DROP TABLE plans;',
    );
    await db.execute(
      'DROP TABLE consumed_foods;',
    );
    await db.execute(
      'DROP TABLE foods;',
    );
    await db.execute(
      'CREATE TABLE foods(id INTEGER PRIMARY KEY, name TEXT NOT NULL, calories INTEGER NOT NULL);',
    );

    await db.execute(
      'CREATE TABLE plans(id INTEGER PRIMARY KEY, target_calories INT, date TEXT UNIQUE NOT NULL);',
    );

    await db.execute(
      'CREATE TABLE consumed_foods(id INTEGER PRIMARY KEY, plan_id INTEGER NOT NULL, food_id INTEGER NOT NULL, FOREIGN KEY (plan_id) REFERENCES plans(id), FOREIGN KEY (food_id) REFERENCES foods(id));',
    );
    await _insertInitialFoodItems(db);
  }

  Future<void> _insertInitialFoodItems(Database db) async {
    final foodItems = [
      {'name': 'Steak', 'calories': 1000},
      {'name': 'Strawberries', 'calories': 53},
      {'name': 'Blueberries', 'calories': 84},
      {'name': 'Kiwi', 'calories': 61},
      {'name': 'Mango', 'calories': 201},
      {'name': 'Peach', 'calories': 59},
      {'name': 'Pineapple', 'calories': 82},
      {'name': 'Cherries', 'calories': 77},
      {'name': 'Pomegranate', 'calories': 234},
      {'name': 'Watermelon', 'calories': 86},
      {'name': 'Papaya', 'calories': 119},
      {'name': 'Pear', 'calories': 101},
      {'name': 'Plum', 'calories': 46},
      {'name': 'Coconut', 'calories': 354},
      {'name': 'Tofu (firm)', 'calories': 144},
      {'name': 'Lentils (cooked)', 'calories': 230},
      {'name': 'Black Beans (cooked)', 'calories': 227},
      {'name': 'Chickpeas (cooked)', 'calories': 269},
      {'name': 'Tuna (canned in water)', 'calories': 194},
      {'name': 'Turkey Breast (cooked)', 'calories': 135},
      {'name': 'Shrimp (cooked)', 'calories': 99},
      {'name': 'Cod (cooked)', 'calories': 105},
      {'name': 'Sardines (canned in oil)', 'calories': 208},
      {'name': 'Beef Steak (cooked)', 'calories': 271},
      {'name': 'Pork Chop (cooked)', 'calories': 231},
      {'name': 'Rye Bread', 'calories': 83},
      {'name': 'Granola', 'calories': 471},
      {'name': 'Walnuts', 'calories': 185},
      {'name': 'Cashews', 'calories': 157},
      {'name': 'Sunflower Seeds', 'calories': 164},
      {'name': 'Hazelnuts', 'calories': 178}
    ];

    for (final foodItem in foodItems) {
      await db.insert(
        'foods',
        foodItem,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> logFood(Food food, String date, int targetCalories) async {
    try {
      Database db = await database;

      List<Map<String, dynamic>> plans = await db.query('plans',
          where: 'date = ?', whereArgs: [date], limit: 1);
      int planId;

      if (plans.isNotEmpty) {
        planId = plans.first['id'];
      } else {
        planId = await db
            .insert('plans', {'target_calories': targetCalories, 'date': date});
      }

      await db
          .insert('consumed_foods', {'plan_id': planId, 'food_id': food.id});
    } catch (e) {
      print(e);
    }
  }

  Future<int> addFood(Food food) async {
    try {
      Database db = await database;
      return await db.insert(
        'foods',
        {
          'name': food.name,
          'calories': food.calories,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<void> updateTargetCalories(String date, int targetCalories) async {
    try {
      Database db = await database;

      List<Map<String, dynamic>> plans = await db.query('plans',
          where: 'date = ?', whereArgs: [date], limit: 1);

      if (plans.isNotEmpty) {
        await db.update(
          'plans',
          {'target_calories': targetCalories},
          where: 'date = ?',
          whereArgs: [date],
        );
      } else {
        await db
            .insert('plans', {'target_calories': targetCalories, 'date': date});
      }
    } catch (e) {
      print(e);
    }
  }

  Future<int> getTargetCalories(String date) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> result = await db.query(
        'plans',
        columns: ['target_calories'],
        where: 'date = ?',
        whereArgs: [date],
      );

      if (result.isNotEmpty) {
        return result.first['target_calories'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print(e);
      return 0; // Return 0 or some default error value
    }
  }

  Future<List<Food>> getFoods() async {
    Database db = await database;
    List<Map<String, dynamic>> foods = await db.query('foods');
    return foods.map((map) => Food.fromMap(map)).toList();
  }

  Future<List<Food>> getFoodsFromDate(String date) async {
    try {
      Database db = await database;
      String query = '''
      SELECT f.id, f.name, f.calories 
      FROM foods AS f
      INNER JOIN consumed_foods AS cf ON f.id = cf.food_id
      INNER JOIN plans AS p ON cf.plan_id = p.id
      WHERE p.date = ?
    ''';
      List<Map<String, dynamic>> result = await db.rawQuery(query, [date]);
      return result.map((map) => Food.fromMap(map)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> updateFood(Food food) async {
    Database db = await database;
    await db.update(
      'foods',
      {'name': food.name, 'calories': food.calories},
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<void> deleteFood(int id) async {
    Database db = await database;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteConsumedFood(int foodId, String date) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> plan = await db.query(
        'plans',
        columns: ['id'],
        where: 'date = ?',
        whereArgs: [date],
      );

      if (plan.isNotEmpty) {
        int planId = plan.first['id'];

        String deleteQuery = '''
        DELETE FROM consumed_foods 
        WHERE food_id = ? AND plan_id = ? 
        LIMIT 1
      ''';

        await db.rawDelete(deleteQuery, [foodId, planId]);
      }
    } catch (e) {
      print(e);
    }
  }
}
