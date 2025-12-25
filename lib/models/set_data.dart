class SetData {
  final String id;
  final String exerciseId;
  final int setNumber;

  final double weight;
  final int reps;
  final double rpe;

  final bool isWarmup;
  final DateTime timestamp;

  final String? notes;

  const SetData({
    required this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.rpe,
    this.isWarmup = false,
    required this.timestamp,
    this.notes,
  });

  SetData copyWith({
    String? id,
    String? exerciseId,
    int? setNumber,
    double? weight,
    int? reps,
    double? rpe,
    bool? isWarmup,
    DateTime? timestamp,
    String? notes,
  }) {
    return SetData(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'isWarmup': isWarmup,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory SetData.fromJson(Map<String, dynamic> json) {
    return SetData(
      id: (json['id'] ?? '').toString(),
      exerciseId: (json['exerciseId'] ?? '').toString(),
      setNumber: (json['setNumber'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      rpe: (json['rpe'] as num?)?.toDouble() ?? 0.0,
      isWarmup: (json['isWarmup'] as bool?) ?? false,
      timestamp: DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      notes: json['notes']?.toString(),
    );
  }

  double get volume => weight * reps;

  @override
  String toString() {
    return '${weight}kg × $reps reps @ RPE ${rpe.toStringAsFixed(1)}';
  }
}
