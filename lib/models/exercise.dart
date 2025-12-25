import 'package:flutter/material.dart';

class Exercise {
  final String id;
  final String name;
  final String videoUrl;
  final String
      warmupSets; 
  final int workingSets;
  final String repRange;
  final String technique;
  final double earlySetRPE;
  final double lastSetRPE;
  final String restTime;
  final String muscleGroup;
  final List<String> notes;
  final List<String> substitutionOptions;

  const Exercise({
    required this.id,
    required this.name,
    required this.videoUrl,
    required this.warmupSets,
    required this.workingSets,
    required this.repRange,
    required this.technique,
    required this.earlySetRPE,
    required this.lastSetRPE,
    required this.restTime,
    required this.muscleGroup,
    required this.notes,
    required this.substitutionOptions,
  });


  int getMinWarmupSets() {
    if (warmupSets.contains('-')) {
      return int.parse(warmupSets.split('-')[0]);
    }
    return int.parse(warmupSets);
  }


  int getMaxWarmupSets() {
    if (warmupSets.contains('-')) {
      return int.parse(warmupSets.split('-')[1]);
    }
    return int.parse(warmupSets);
  }


  String getEarlySetRPEDisplay() {
    if (earlySetRPE == 0) return 'N/A';
    return '~${earlySetRPE.toStringAsFixed(1)}';
  }

  String getLastSetRPEDisplay() {
    if (lastSetRPE == 0) return 'N/A';
    return '~${lastSetRPE.toStringAsFixed(1)}';
  }


  int get restTimeInSeconds {
    if (restTime.contains(':')) {
      final parts = restTime.split(':');
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return (minutes * 60) + seconds;
    }
    return int.tryParse(restTime.replaceAll(RegExp(r'[^\d]'), '')) ?? 60;
  }


  IconData get techniqueIcon {
    switch (technique.toLowerCase()) {
      case 'compound':
        return Icons.fitness_center;
      case 'isolation':
        return Icons.extension;
      case 'dropset':
        return Icons.arrow_downward;
      case 'supersets':
        return Icons.compare_arrows;
      default:
        return Icons.info;
    }
  }


  String get techniqueDisplayName {
    if (technique == 'N/A') return 'Standard';
    return technique;
  }


  Exercise copyWith({
    String? id,
    String? name,
    String? videoUrl,
    String? warmupSets,
    int? workingSets,
    String? repRange,
    String? technique,
    double? earlySetRPE,
    double? lastSetRPE,
    String? restTime,
    String? muscleGroup,
    List<String>? notes,
    List<String>? substitutionOptions,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      videoUrl: videoUrl ?? this.videoUrl,
      warmupSets: warmupSets ?? this.warmupSets,
      workingSets: workingSets ?? this.workingSets,
      repRange: repRange ?? this.repRange,
      technique: technique ?? this.technique,
      earlySetRPE: earlySetRPE ?? this.earlySetRPE,
      lastSetRPE: lastSetRPE ?? this.lastSetRPE,
      restTime: restTime ?? this.restTime,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      notes: notes ?? this.notes,
      substitutionOptions: substitutionOptions ?? this.substitutionOptions,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'videoUrl': videoUrl,
      'warmupSets': warmupSets,
      'workingSets': workingSets,
      'repRange': repRange,
      'technique': technique,
      'earlySetRPE': earlySetRPE,
      'lastSetRPE': lastSetRPE,
      'restTime': restTime,
      'muscleGroup': muscleGroup,
      'notes': notes.join('|'),
      'substitutionOptions': substitutionOptions.join('|'),
    };
  }


  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      videoUrl: map['videoUrl'] as String,
      warmupSets: map['warmupSets'] as String,
      workingSets: map['workingSets'] as int,
      repRange: map['repRange'] as String,
      technique: map['technique'] as String,
      earlySetRPE: map['earlySetRPE'] as double,
      lastSetRPE: map['lastSetRPE'] as double,
      restTime: map['restTime'] as String,
      muscleGroup: map['muscleGroup'] as String,
      notes: (map['notes'] as String).split('|'),
      substitutionOptions: (map['substitutionOptions'] as String).split('|'),
    );
  }
}
