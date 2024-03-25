import 'package:flutter/material.dart';

class Project {
  int? id;
  final String title;
  final String description;
  final Color color;

  Project({
    this.id,
    required this.title,
    required this.description,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': 'abc',
      'color': color.toString(),
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, color: $color}';
  }

  bool operator ==(Object other) => other is Project && id == other.id;

  int get hashCode => Object.hash(id, id);
}
