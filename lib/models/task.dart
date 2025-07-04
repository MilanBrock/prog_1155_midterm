class Task {
  int? id;
  final String name;
  final String dueDate;
  final int priority;

  final String? locationName;
  final double? latitude;
  final double? longitude;

  Task({
    this.id,
    required this.name,
    required this.dueDate,
    required this.priority,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'name': name,
      'dueDate': dueDate,
      'priority': priority,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
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
          : int.tryParse(map['priority'].toString()) ?? 3,
      locationName: map['locationName']?.toString(),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
    );
  }
}
