import 'package:flutter/material.dart';

class Event {
  int? id;
  final String title;
  final String description;
  final DateTime fromDate;
  final DateTime toDate;
  final Color backgroundColor;
  final bool isAllDay;

  Event({
    id,
    required this.title,
    required this.description,
    required this.fromDate,
    required this.toDate,
    this.backgroundColor = Colors.blue,
    this.isAllDay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'backgroundColor': backgroundColor.value,
      'isAllDay': isAllDay ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Event{id: $id, title: $title, description: $description, fromDate: $fromDate, toDate: $toDate, backgroundColor: $backgroundColor, isAllDay: $isAllDay}';
  }
}
