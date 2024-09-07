import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "data_barang.db";
  static const _databaseVersion = 1;

  static const table = 'tbarang';
  static const columnId = '_id';
  static const columnNama = 'nama';
  static const columnInfo = 'info';
  static const columnHarga = 'harga';
  static const columnLevel = 'level';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion,
        onCreate: (db, version) {
      db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnNama TEXT NOT NULL,
            $columnInfo TEXT NOT NULL,
            $columnHarga INTEGER NOT NULL,
            $columnLevel INTEGER NOT NULL
          )
          ''');
    });
  }
}
