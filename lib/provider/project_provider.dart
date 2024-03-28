import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../model/project.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

class ProjectProvider extends ChangeNotifier {
  late Database _database;

  /// Create tables
  void _createTableV2(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS tasks(id INTEGER PRIMARY KEY, projectId INTEGER, title TEXT, description TEXT, fromDate TEXT, toDate TEXT, backgroundColor INTEGER, isAllDay INTEGER, status TEXT)',
    );
    batch.execute(
      'CREATE TABLE IF NOT EXISTS projects(id INTEGER PRIMARY KEY, title TEXT, description TEXT, color INTEGER)',
    );
    batch.execute(
      'CREATE INDEX project_on_tasks_index ON tasks (projectId)',
    );
  }

  /// Update Company table V1 to V2
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

  Future<List<Project>> getAllProjects() async {
    // Update database
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDatabase();

    final List<Map<String, dynamic>> maps = await _database.query('projects');

    return List.generate(maps.length, (i) {
      Color projectColor = Colors.blue;
      if (maps[i]['color'] != null) {
        projectColor = Color(maps[i]['color'] as int);
      }
      return Project(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String,
        color: projectColor,
      );
    });
  }

  Future<bool> addProject(Project project) async {
    // _events.add(event);

    // Update database
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDatabase();

    try {
      // log('Testing project write ${project.toMap()}');
      int fetchRes = await _database.insert(
        'projects',
        project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      //     .then((value) {
      //   notifyListeners();
      // });
    } on DatabaseException catch (e) {
      log('Insert Error: {$e}');
    }

    notifyListeners();
    return true;
  }

  Future<bool> deleteProject(Project project) async {
    // _events.add(event);

    // Update database
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDatabase();

    try {
      // log('Testing project write ${project.toMap()}');
      int deleteRes = await _database.delete(
        'projects',
        where: 'id = ?',
        whereArgs: [project.id],
      );
      //     .then((value) {
      //   notifyListeners();
      // });
    } on DatabaseException catch (e) {
      log('Delete Error: {$e}');
    }

    notifyListeners();
    return true;
  }
}
