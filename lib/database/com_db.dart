import 'package:sec_com/model/com.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class ComDB {
  final tableName = 'coms';

  Future<void> createTable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER,
    "name" STRING NOT NULL,
    "lip" STRING NOT NULL,
    "lport" INTEGER NOT NULL,
    "port" INTEGER NOT NULL,
    PRIMARY KEY ("id" AUTOINCREMENT)
    );""");
  }

  Future<void> insertInitialData(Database database) async {
    const name = 'tomahawk';
    const lip = '192.168.1.162';
    const lport = '8372';
    const port = '7332';
    await database.execute("""
    INSERT INTO $tableName 
    (
    name,
    lip,
    lport,
    port
    ) 
    VALUES 
    (
    "$name",
    "$lip",
    "$lport",
    "$port"
    )
    ;""");
  }

  Future<List<Com>> fetchAll() async {

    final database = await DatabaseService().database;
    final coms = (await database.rawQuery(
        '''SELECT * FROM $tableName'''
    ) as List<Map<String, dynamic>>);
    var res = coms.map((com) => Com.fromSqflite(com)).toList();
    return res;
  }

}