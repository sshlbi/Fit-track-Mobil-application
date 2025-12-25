import 'workout_day.dart';

enum ProgramBlock {
  foundation,
  anatomical,
  ramping,
}

class Week {
  final int weekNumber;
  final ProgramBlock block;
  final bool isDeload;

  final String description;
  final String notes;

  final List<WorkoutDay> workoutDays;

  const Week({
    required this.weekNumber,
    required this.block,
    this.isDeload = false,
    required this.description,
    required this.notes,
    required this.workoutDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'weekNumber': weekNumber,
      'block': block.name,
      'isDeload': isDeload,
      'description': description,
      'notes': notes,
      'workoutDays': workoutDays.map((d) => d.toJson()).toList(),
    };
  }

  factory Week.fromJson(Map<String, dynamic> json) {
    final blockStr = (json['block'] ?? '').toString();
    final ProgramBlock parsedBlock = ProgramBlock.values.firstWhere(
      (b) => b.name == blockStr,
      orElse: () => ProgramBlock.foundation,
    );

    final daysJson = (json['workoutDays'] as List? ?? const []);

    return Week(
      weekNumber: (json['weekNumber'] as num?)?.toInt() ?? 0,
      block: parsedBlock,
      isDeload: (json['isDeload'] as bool?) ?? false,
      description: (json['description'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      workoutDays: daysJson
          .whereType<Map>()
          .map((e) => WorkoutDay.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
