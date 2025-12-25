import 'exercise.dart';

enum WorkoutType {
  upper,
  lower,
  push,
  pull,
  legs,
  rest,
}

class WorkoutDay {
  final String id;
  final String name;
  final WorkoutType type;
  final String description;

  final List<Exercise> exercises;

  const WorkoutDay({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.exercises,
  });

  bool get isRestDay => type == WorkoutType.rest;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? '').toString();

    final WorkoutType parsedType = WorkoutType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => WorkoutType.rest,
    );

    final exercisesJson = (json['exercises'] as List? ?? const []);

    return WorkoutDay(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: parsedType,
      description: (json['description'] ?? '').toString(),
      exercises: exercisesJson
          .whereType<Map>()
          .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
