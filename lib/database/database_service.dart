import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sec_com/database/com_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'seccom.db';
    var path = '';
    if (Platform.isAndroid) {
      path = await getDatabasesPath();
    } else {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      path = join(appDocumentsDir.path, "SecCom", "data");
    }
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    if (Platform.isWindows || Platform.isLinux) {
      return await databaseFactory.openDatabase(path,
          options: OpenDatabaseOptions(version: 1, onCreate: create));
    } else {
      return await openDatabase(
        path,
        version: 1,
        onCreate: create,
        singleInstance: true
      );
    }
    //var database = await openDatabase(
    //    path,
    //    version: 1,
    //    onCreate: create,
    //    singleInstance: true
    //);
    //return db;
  }

  Future<void> create(Database database, int version) async => {
        await ComDB().createTable(database),
        // await ComDB().insertInitialData(database),
      };
}
