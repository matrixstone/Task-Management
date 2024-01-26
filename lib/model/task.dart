import 'package:flutter/material.dart';

enum TaskStatus { notStarted, inProgress, completed }

class Task {
  int? id;
  int projectId;
  final String title;
  final String description;
  final DateTime fromDate;
  final DateTime toDate;
  final Color backgroundColor;
  final bool isAllDay;
  TaskStatus? status;

  Task({
    this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.fromDate,
    required this.toDate,
    this.backgroundColor = Colors.blue,
    this.isAllDay = false,
    this.status = TaskStatus.notStarted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'backgroundColor': backgroundColor.value,
      'isAllDay': isAllDay ? 1 : 0,
      'status': status?.name,
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, projectId: $projectId, title: $title, description: $description, fromDate: $fromDate, toDate: $toDate, backgroundColor: $backgroundColor, isAllDay: $isAllDay, status: $status}';
  }
}
