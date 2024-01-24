import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../model/project.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProjectProvider extends ChangeNotifier {
  Future<List<Project>> getAllProjects() async {
    // Update database
    WidgetsFlutterBinding.ensureInitialized();

    var factory = databaseFactoryFfiWeb;
    final database = factory.openDatabase(
      join(await getDatabasesPath(), 'task_management.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE tasks(id INTEGER PRIMARY KEY, projectId INTEGER, title TEXT, description TEXT, fromDate TEXT, toDate TEXT, backgroundColor INTEGER, isAllDay INTEGER)',
          );
          return db.execute(
            'CREATE TABLE IF NOT EXISTS projects(id INTEGER PRIMARY KEY, title TEXT, description TEXT)',
          );
        },
      ),
    );

    // Get a reference to the database.
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('projects');
    log('Testing all projects: {$maps}');

    return List.generate(maps.length, (i) {
      return Project(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String,
      );
    });
  }

  Future<bool> addProject(Project project) async {
    // _events.add(event);

    // Update database
    WidgetsFlutterBinding.ensureInitialized();
    log('Testing project to add: {$project}');

    var factory = databaseFactoryFfiWeb;
    final database = factory.openDatabase(
      join(await getDatabasesPath(), 'task_management.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE tasks(id INTEGER PRIMARY KEY, projectId INTEGER, title TEXT, description TEXT, fromDate TEXT, toDate TEXT, backgroundColor INTEGER, isAllDay INTEGER)',
          );
          return db.execute(
            'CREATE TABLE IF NOT EXISTS projects(id INTEGER PRIMARY KEY, title TEXT, description TEXT)',
          );
        },
      ),
    );

    // Get a reference to the database.
    final db = await database;

    log('Testing 2222');

    // try {
    int fetchRes = await db.insert(
      'projects',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('Testing project to add after insert $fetchRes');
    //     .then((value) {
    //   log('Testing notifyListeners');
    //   notifyListeners();
    // });
    // } on DatabaseException catch (e) {
    //   log('Error: {$e}');
    // }

    notifyListeners();
    return true;
  }
}
