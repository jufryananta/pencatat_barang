import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

Future<Database> openMyDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'data_barang.db');
  final database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create tables here
      DatabaseHelper.instance.database;
    },
  );
  return database;
}

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'data.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE tbarang(id INTEGER PRIMARY KEY, nama TEXT, info TEXT, harga INTEGER, level INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  // Define a function that inserts dogs into the database
  Future<void> tambahBarang(Barang barang) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'tbarang',
      barang.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Barang>> tbarang() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all the dogs.
    final List<Map<String, Object?>> barangMaps = await db.query('tbarang');

    // Convert the list of each dog's fields into a list of `Dog` objects.
    return [
      for (final {
            'id': id as int,
            'nama': nama as String,
            'info': info as String,
            'harga': harga as int,
            'level': level as int
          } in barangMaps)
        Barang(id: id, nama: nama, info: info, harga: harga, level: level),
    ];
  }

  Future<void> updateBarang(Barang barang) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'tbarang',
      barang.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [barang.id],
    );
  }

  Future<void> hapusBarang(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'tbarang',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  // Create a Dog and add it to the dogs table
  var test = Barang(
      id: 0,
      nama: 'Mie Instant Rendang',
      info: 'Rasa rendang varian baru 2024',
      harga: 3500,
      level: 1);
  await tambahBarang(test);

  // Now, use the method above to retrieve all the dogs.
  print(await tbarang()); // Prints a list that include Fido.

  // Update Fido's age and save it to the database.
  test = Barang(
      id: test.id,
      nama: test.nama,
      info: test.info,
      harga: test.harga + 500,
      level: test.level);
  await updateBarang(test);

  // Print the updated results.
  print(await tbarang()); // Prints Fido with age 42.

  // Delete Fido from the database.
  await hapusBarang(test.id);

  // Print the list of dogs (empty).
  print(await tbarang());
}

class Barang {
  final int id;
  final String nama;
  final String info;
  final int harga;
  final int level;

  Barang(
      {required this.id,
      required this.nama,
      required this.info,
      required this.harga,
      required this.level});

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'info': info,
      'harga': harga,
      'level': level
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Dog{id: $id, nama: $nama, age: $info, harga: $harga, level: $level}';
  }
}

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  ThemeMode _themeMode = ThemeMode.system;

  bool get useLightMode {
    switch (_themeMode) {
      case ThemeMode.system:
        return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Halaman(
      title: 'Barang',
      useLightMode: useLightMode,
      handleBrightnessChange: (useLightMode) => setState(() {
        _themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
      }),
    );
  }
}

class Halaman extends StatefulWidget {
  const Halaman({
    super.key,
    required this.title,
    required this.handleBrightnessChange,
    required this.useLightMode,
  });
  final String title;
  final bool useLightMode;
  final void Function(bool useLightMode) handleBrightnessChange;

  @override
  State<Halaman> createState() => _HalamanState();
}

class _HalamanState extends State<Halaman> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                    onPressed: () {},
                    label: const Text('Urut'),
                    icon: const Icon(Icons.sort_by_alpha))
              ],
            ),
            Expanded(
                child: ListView(
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading:
                      Image(image: AssetImage('assets/img/avatar_co100.png')),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayam Bawang Goreng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Variasi rendang yang baru 2024',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('200000', style: TextStyle(fontSize: 14)),
                      Text('20/01/2024', style: TextStyle(fontSize: 8))
                    ],
                  ),
                )
              ],
            ))
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
