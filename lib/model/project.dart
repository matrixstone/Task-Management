class Project {
  int? id;
  final String title;
  final String description;

  Project({
    this.id,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': 'abc',
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, }';
  }

  bool operator ==(Object other) => other is Project && id == other.id;

  int get hashCode => Object.hash(id, id);
}
