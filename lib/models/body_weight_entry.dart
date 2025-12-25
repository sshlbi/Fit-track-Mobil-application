class BodyWeightEntry {
  final String id;
  final double weight;
  final DateTime date;
  final String? notes;

  const BodyWeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight': weight,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory BodyWeightEntry.fromJson(Map<String, dynamic> json) =>
      BodyWeightEntry(
        id: json['id'] as String,
        weight: (json['weight'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        notes: json['notes'] as String?,
      );

  BodyWeightEntry copyWith({
    String? id,
    double? weight,
    DateTime? date,
    String? notes,
  }) {
    return BodyWeightEntry(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
