import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// delete the db, create the folder and returnes its path
Future<String> initDeleteDb(String dbName) async {
  final databasePath = await getDatabasesPath();
  // print(databasePath);
  final path = join(databasePath, dbName);

  // make sure the folder exists
  // ignore: avoid_slow_async_io
  if (await Directory(dirname(path)).exists()) {
    print('删除原数据库');
    // await deleteDatabase(path);
  } else {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (e) {
      print(e);
    }
  }
  return path;
}

Future<bool> isTableExits(Database database, String tableName) async {
  //内建表sqlite_master
  var sql =
      "SELECT * FROM sqlite_master WHERE TYPE = 'table' AND NAME = '$tableName'";
  var res = await database.rawQuery(sql);
  var returnRes = res != null && res.length > 0;
  return returnRes;
}
