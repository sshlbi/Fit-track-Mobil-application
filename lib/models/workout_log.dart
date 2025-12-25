class WorkoutLog {
  final String id;

  final String exerciseId;
  final String exerciseName;

  final int weekNumber;
  final DateTime date;

  final int setNumber;
  final double weight;
  final int reps;
  final double rpe;

  final String? notes;

  const WorkoutLog({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.weekNumber,
    required this.date,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.rpe,
    this.notes,
  });

  double get volume => weight * reps;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'weekNumber': weekNumber,
      'date': date.toIso8601String(),
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'notes': notes,
    };
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: (json['id'] ?? '').toString(),
      exerciseId: (json['exerciseId'] ?? '').toString(),
      exerciseName: (json['exerciseName'] ?? '').toString(),
      weekNumber: (json['weekNumber'] as num?)?.toInt() ?? 0,
      date: DateTime.tryParse((json['date'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      setNumber: (json['setNumber'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      rpe: (json['rpe'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
    );
  }

  WorkoutLog copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    int? weekNumber,
    DateTime? date,
    int? setNumber,
    double? weight,
    int? reps,
    double? rpe,
    String? notes,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      weekNumber: weekNumber ?? this.weekNumber,
      date: date ?? this.date,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'WorkoutLog($exerciseName - ${weight}kg × $reps @ RPE ${rpe.toStringAsFixed(1)})';
  }
}
