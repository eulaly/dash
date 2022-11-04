import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dash/models/car.dart';
import 'package:dash/models/txn.dart';

//https://suragch.medium.com/simple-sqflite-database-example-in-flutter-e56a5aaa3f91
// class dbWrapper {
//   if (Platform.isWindows or Platform.isLinux or ) {
//     print('build does not support sqlite')
//   }
// }

class DbHelperSqlite {
  final _dbName = "cars_sqlite.db";
  final _dbVersion = 1;

  // make singleton class
  DbHelperSqlite._privateConstructor();
  static final DbHelperSqlite instance = DbHelperSqlite._privateConstructor();
  static Database? _database;

  Future<Database?> get database async {
    _database = await _initDatabase();
    return _database!;
  }

  // open db and create if not exists
  _initDatabase() async {
    print('initializing db');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, _dbName);
    return await openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    //docs say to avoid autoincrement
    //looks like this may be a null issue?
    await db.execute('''
      CREATE TABLE ${Car.tblCars} (
        ${Car.colId} INTEGER PRIMARY KEY,
        ${Car.colVin} TEXT UNIQUE,
        ${Car.colNickname} TEXT,
        ${Car.colMileage} INTEGER,
        ${Car.colPlate} TEXT);
      CREATE TABLE ${Txn.tblTxns} (
        ${Txn.colId} INTEGER PRIMARY KEY,
        ${Txn.colType} TEXT,
        ${Txn.colDatetime} INTEGER,
        ${Txn.colCost} REAL,
        ${Txn.colMileage} INTEGER,
        ${Txn.colNote} TEXT,
        FOREIGN KEY(${Txn.colCarId}) REFERENCES ${Car.tblCars}(${Car.colId}),
        )''');
  }

  Future<int> insertCar(Car car) async {
    Database db = await instance.database as Database;
    return await db.insert(Car.tblCars, car.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Car>> fetchCars() async {
    Database db = await database as Database;
    List<Map<String, dynamic>> cars = await db.query(Car.tblCars);
    if (cars.isEmpty) {
      return [];
    } else {
      return cars.map((car) => Car.fromMap(car)).toList();
    }
  }

  Future<int> updateCar(Car car) async {
    Database db = await instance.database as Database;
    print('car id to update: ${car.id}');
    return await db.update(Car.tblCars, car.toMap(),
        where: '${Car.colId}=?', whereArgs: [car.id]);
  }

  Future<int> deleteCar(Car car) async {
    Database db = await instance.database as Database;
    print('car id to delete: ${car.id}');
    return await db
        .delete(Car.tblCars, where: '${Car.colId}=?', whereArgs: [car.id]);
  }

  Future<int> deleteAll() async {
    Database db = await instance.database as Database;
    return await db.rawDelete("DELETE FROM ${Car.tblCars}");
  }
}

// flutter ex: https://docs.flutter.dev/cookbook/persistence/sqlite
/*   Future<void> insertCar(Car car) async {
    final db = await database;
    await db.insert(
      'cars',
      car.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  } */

/*   Future<void> insertTestCar(Car car) async {
    final db = await database;
    await db.insert('cars', car.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }


  Future<int> deleteCar(String vin) async {
    Database db = await instance.database;
    return await db.delete(tableCars, where: '$colVin=?', whereArgs: [vin]);
  }

  Future<List<Map<String, dynamic>>> queryAllCars() async {
    Database db = await instance.database;
    return await db.query(tableCars);
  }
} */
