import 'dart:async';

import '../model/task.dart';
import '../model/project.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';
import 'dart:developer' as developer;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  late Database _database;
  Future<void> initializeDatabase() async {
    var factory = databaseFactory;

    _database = await factory.openDatabase(
      join(await getDatabasesPath(), 'task_management.db'),
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE tasks(id INTEGER PRIMARY KEY, projectId INTEGER, title TEXT, description TEXT, fromDate TEXT, toDate TEXT, backgroundColor INTEGER, isAllDay INTEGER, status TEXT)',
          );
          await db.execute(
            'CREATE TABLE projects(id INTEGER PRIMARY KEY, title TEXT, description TEXT, color INTEGER)',
          );
          return db.execute(
            'CREATE INDEX project_on_tasks_index ON tasks (projectId)',
          );
        },
      ),
    );
  }

  Future<Map<Project, Map<DateTime, double>>> getProjectsToTime() async {
    // Get all tasks
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDatabase();

    // final List<Map<String, dynamic>> maps = await _database.query('tasks');

    final List<Map<String, dynamic>> maps = await _database.rawQuery('''
SELECT tasks.*, projects.title as projectTitle, projects.description AS projectDescription, projects.color AS projectColor
FROM tasks
JOIN projects ON tasks.projectId = projects.id
''');
    Map<Project, Map<DateTime, double>> projectToTime = {};

    maps.forEach((task) {
      Project project = Project(
          id: task['projectId'] as int,
          title: task['projectTitle'] as String,
          description: task['projectDescription'] as String,
          color: Color(task['projectColor'] as int));
      if (!projectToTime.containsKey(project)) {
        projectToTime[project] = {};
      }
      DateTime taskFromDate = DateTime.parse(task['fromDate'] as String);
      DateTime tasktoDate = DateTime.parse(task['toDate'] as String);
      Duration duration = tasktoDate.difference(taskFromDate);
      projectToTime[project]![tasktoDate] =
          duration.inHours.toDouble() + (duration.inMinutes % 60) / 60;
    });
    return projectToTime;
  }

  Future<Project> getProject(int projectId) async {
    // Update database
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDatabase();

    final List<Map<String, dynamic>> maps = await _database
        .query('projects', where: 'id=?', whereArgs: [projectId]);
    if (maps.isEmpty) {
      developer.log('getProject in data_provider.dart: No project found');
    }
    if (maps.length > 1) {
      developer
          .log('getProject in data_provider.dart: more than 1 project found.');
    }

    return Project(
      id: maps[0]['id'] as int,
      title: maps[0]['title'] as String,
      description: maps[0]['description'] as String,
      color: Color(maps[0]['color'] as int),
    );
  }
}
