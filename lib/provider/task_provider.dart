import 'package:flutter/cupertino.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:collection/collection.dart';
import '../model/task.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class TaskProvider extends ChangeNotifier {
  late Database _database;

  /// Create tables
  void _createTableV2(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS projects'
      '(id INTEGER PRIMARY KEY, title TEXT, description TEXT, color INTEGER)',
    );
    batch.execute(
      'CREATE TABLE IF NOT EXISTS tasks'
      '(id INTEGER PRIMARY KEY AUTOINCREMENT, projectId INTEGER, '
      'title TEXT, description TEXT, fromDate TEXT, '
      'toDate TEXT, backgroundColor INTEGER, '
      'isAllDay INTEGER, status TEXT, '
      'FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE NO ACTION ON UPDATE NO ACTION)',
    );
    batch.execute(
      'CREATE INDEX project_on_tasks_index ON tasks (projectId)',
    );
  }

  /// Update project table V1 to V2
  void _updateProjectTableV1toV2(Batch batch) {
    batch.execute('ALTER TABLE projects ADD color INTEGER');
  }

  Future<void> initializeDatabase() async {
    var factory = databaseFactory;

    _database = await factory.openDatabase(
      join(await getDatabasesPath(), 'task_management.db'),
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          var batch = db.batch();
          _createTableV2(batch);
          await batch.commit();
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          var batch = db.batch();
          if (oldVersion == 1) {
            // We update project table with new column
            _updateProjectTableV1toV2(batch);
          }
          await batch.commit();
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

    await initializeDatabase();

    await _database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
    return true;
  }

  Future<bool> updateTaskTime(
      int? task_id, DateTime fromTime, DateTime toTime) async {
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDatabase();

    int updateCount = await _database.rawUpdate('''
    UPDATE tasks 
    SET fromDate = ?, toDate = ? 
    WHERE id = ?
    ''', [fromTime.toIso8601String(), toTime.toIso8601String(), task_id]);

    notifyListeners();
    return true;
  }

  // void deleteEvent(Event event) {
  //   _events.remove(event);
  //   notifyListeners();
  // }
}
