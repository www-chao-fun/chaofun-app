import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'model/userDB.dart';

class AddJoinHelper {
  static final AddJoinHelper _instance = AddJoinHelper.internal();
  factory AddJoinHelper() => _instance;
  final String tableName = "table_addjoin";
  final String columnId = "id";
  final String userId = "userId";
  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  AddJoinHelper.internal();

  initDb() async {
    // if (_database != null) return _database;

    // try {
    //   var databasePath = await getDatabasesPath();
    //   String _path = path.join(databasePath, 'notes.db');
    //   _database = await sql.openDatabase(_path, version: 1, onCreate: onCreate);
    //   return _database;
    // } catch (e) {
    //   print(e);
    // }
    try {
      var databasesPath = await getDatabasesPath();
      // Directory path = await getApplicationDocumentsDirectory();
      String path = join(databasesPath, 'test_batch.db');

      var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
      return ourDb;
    } catch (e) {}
  }

  //创建数据库表
  // void _onCreate(Database db, int version) async {
  //   print('开始创建table_addjoin表');
  //   await db.execute(
  //       "create table $tableName(id integer primary key, addForum,focusUser)");
  //   print("Table table_addjoin is created");
  // }
  //创建数据库表
  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE All_page (id INTEGER PRIMARY KEY, article,articleType,canDeleted,chooseOption,circuseeCount,comments,cover,coverHeight,coverWidth,downs,forum,forumId,gmtCreate,gmtModified,height,hot,imageName,imageNums,images,link,optionSize,optionVoteCount,options,postId,save,sourcePost,sourcePostId,title,type,ups,userInfo,video,videoType,vote,voteHasEnded,voteTtl,width)');
    await db.execute(
        "create table table_addjoin(id integer primary key, addForum,focusUser)");
    await db.execute(
        "create table table_user(id integer primary key, userId,userName,icon,ups,followers,desc,phone,gmtCreate,gmtModified )");
    // batch.execute(
    //     'CREATE TABLE page_key (id INTEGER PRIMARY KEY, pageName,page_key,marker)');

    await db.execute("create table table_tag(id, name)");
    await db.execute(
        "create table table_forum(id,desc,followers,imageName,name,posts,tag,joined)");
  }

//插入
  Future<int> saveItem(addForum, focusUser) async {
    var dbClient = await db;
    int res = await dbClient
        .insert("$tableName", {'addForum': addForum, 'focusUser': focusUser});

    return res;
  }

  //查询
  Future<List> getTotalList() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ");

    return result.toList();
  }

  //查询总数
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

//按照id查询
  // Future<userDB> getItem(int id) async {
  //   var dbClient = await db;
  //   var result =
  //       await dbClient.rawQuery("SELECT * FROM $tableName WHERE id = $id");
  //   if (result.length == 0) return null;
  //   return User.fromMap(result.first);
  // }

  //清空数据
  Future<int> clear() async {
    var dbClient = await db;
    return await dbClient.delete(tableName);
  }

  //根据id删除
  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: "$columnId = ?", whereArgs: [id]);
  }

  //修改
  Future<int> updateItem(userDB user) async {
    var dbClient = await db;
    return await dbClient.update("$tableName", user.toMap(),
        where: "$columnId = ?", whereArgs: [user.userId]);
  }

  //关闭
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
