import 'package:flutter/cupertino.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../model/event.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class EventProvider extends ChangeNotifier {
  // final List<Event> _events = [];

  // List<Event> get events => _events;

  Future<List<Event>> getAllEvents() async {
    // Update database
    WidgetsFlutterBinding.ensureInitialized();

    var factory = databaseFactoryFfiWeb;
    final database = factory.openDatabase(
      join(await getDatabasesPath(), 'task_management.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE events(id INTEGER PRIMARY KEY, title TEXT, description TEXT, fromDate TEXT, toDate TEXT, backgroundColor INTEGER, isAllDay INTEGER)',
          );
        },
      ),
    );

    // Get a reference to the database.
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('events');

    return List.generate(maps.length, (i) {
      print('Testing event id: ${maps[i]['id']}');
      return Event(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String,
        fromDate: DateTime.parse(maps[i]['fromDate'] as String),
        toDate: DateTime.parse(maps[i]['toDate'] as String),
        backgroundColor: Color(maps[i]['backgroundColor'] as int),
        isAllDay: maps[i]['isAllDay'] == 1,
      );
    });
  }

  Future<bool> addEvent(Event event) async {
    // _events.add(event);

    // Update database
    WidgetsFlutterBinding.ensureInitialized();
    print('Testing adding event: $event');

    var factory = databaseFactoryFfiWeb;
    final database = factory.openDatabase(
      join(await getDatabasesPath(), 'task_management.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE events(id INTEGER PRIMARY KEY, title TEXT, description TEXT, fromDate TEXT, toDate TEXT, backgroundColor INTEGER, isAllDay INTEGER)',
          );
        },
      ),
    );

    // Get a reference to the database.
    final db = await database;

    await db.insert(
      'events',
      event.toMap(),
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
