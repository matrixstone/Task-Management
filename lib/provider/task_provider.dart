import 'package:flutter/cupertino.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:collection/collection.dart';
import '../model/task.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskProvider extends ChangeNotifier {
  late Database _database;
  Future<void> initializeDatabase() async {
    var factory = databaseFactoryFfiWeb;
    _database = await factory.openDatabase(
      join(await getDatabasesPath(), 'task_management.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE tasks(id INTEGER PRIMARY KEY, projectId INTEGER, title TEXT, description TEXT, fromDate TEXT, toDate TEXT, backgroundColor INTEGER, isAllDay INTEGER, status TEXT)',
          );
          return db.execute(
            'CREATE TABLE IF NOT EXISTS projects(id INTEGER PRIMARY KEY, title TEXT, description TEXT)',
          );
        },
      ),
    );
  }

  Future<List<Task>> getAllTasks() async {
    // Update database
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDatabase();

    final List<Map<String, dynamic>> maps = await _database.query('tasks');

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'] as int,
        projectId: maps[i]['projectId'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String,
        fromDate: DateTime.parse(maps[i]['fromDate'] as String),
        toDate: DateTime.parse(maps[i]['toDate'] as String),
        backgroundColor: Color(maps[i]['backgroundColor'] as int),
        isAllDay: maps[i]['isAllDay'] == 1,
        status: TaskStatus.values
            .firstWhereOrNull((e) => e.name == maps[i]['status']),
      );
    });
  }

  Future<bool> addTask(Task task) async {
    // _events.add(event);

    // Update database
    WidgetsFlutterBinding.ensureInitialized();
    print('Testing adding task: $task');

    await initializeDatabase();

    await _database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
    return true;
  }

  // void deleteEvent(Event event) {
  //   _events.remove(event);
  //   notifyListeners();
  // }
}
