class Task {
  int? id;
  final String name;
  final String dueDate;
  final int priority; // Store as int

  Task({
    this.id,
    required this.name,
    required this.dueDate,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'name': name,
      'dueDate': dueDate,
      'priority': priority, // as int
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'].toString(),
      dueDate: map['dueDate'].toString(),
      priority: map['priority'] is int
          ? map['priority']
          : int.tryParse(map['priority'].toString()) ?? 3, // default to Low
    );
  }
}
