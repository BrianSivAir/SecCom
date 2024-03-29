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
    "key" INTEGER NOT NULL,
    PRIMARY KEY ("id" AUTOINCREMENT)
    );""");
  }

  Future<void> insertInitialData(Database database) async {
    const name = 'poco f5';
    const lip = '192.168.1.248';
    const lport = '8372';
    const port = '7332';
    const key = 'SYIFyvXMPTsokEHqn6gZ2wUFngIdjPjM8rYX/Ccdp2g=';
    const nameb = 'airsurfer';
    const lipb = '192.168.1.163';
    const lportb = '7332';
    const portb = '8372';
    const keyb = 'SYIFyvXMPTsokEHqn6gZ2wUFngIdjPjM8rYX/Ccdp2g=';
    const port_name = 'poco f5 (portable)';
    const port_lip = '192.168.199.114';
    const port_lport = '8372';
    const port_port = '7332';
    const port_key = 'SYIFyvXMPTsokEHqn6gZ2wUFngIdjPjM8rYX/Ccdp2g=';
    const port_nameb = 'airsurfer (portable)';
    const port_lipb = '192.168.199.105';
    const port_lportb = '7332';
    const port_portb = '8372';
    const port_keyb = 'SYIFyvXMPTsokEHqn6gZ2wUFngIdjPjM8rYX/Ccdp2g=';
    await database.execute("""
    INSERT INTO $tableName 
    (
    name,
    lip,
    lport,
    port,
    key
    ) 
    VALUES 
    (
    "$name",
    "$lip",
    "$lport",
    "$port",
    "$key"
    ),
    (
    "$nameb",
    "$lipb",
    "$lportb",
    "$portb",
    "$keyb"
    ),
    (
    "$port_name",
    "$port_lip",
    "$port_lport",
    "$port_port",
    "$port_key"
    ),
    (
    "$port_nameb",
    "$port_lipb",
    "$port_lportb",
    "$port_portb",
    "$port_keyb"
    )
    ;""");
  }

  Future<List<Com>> fetchAll() async {
    final database = await DatabaseService().database;
    // await createTable(database);
    // await insertInitialData(database);
    final coms = (await database.rawQuery(
        '''SELECT * FROM $tableName'''
    ) as List<Map<String, dynamic>>);
    var res = coms.map((com) => Com.fromSqflite(com)).toList();
    return res;
  }

  Future<int> create({required Com com}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $tableName (name, lip, lport, port, key) VALUES (?, ?, ?, ?, ?)''',
      [com.name, com.lip, com.lport, com.port, com.key]
    );
  }

}