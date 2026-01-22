import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_day.dart';
import '../providers/workout_provider.dart';

class WorkoutDayCard extends ConsumerWidget {
  final WorkoutDay day;
  final VoidCallback onTap;

  const WorkoutDayCard({
    super.key,
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(workoutCompletionProvider);

    final isRestDay = day.exercises.isEmpty;
    final completedExercises = completion[day.id]?.length ?? 0;
    final totalExercises = day.exercises.length;
    final isCompleted = !isRestDay &&
        completedExercises == totalExercises &&
        totalExercises > 0;
    final progress =
        totalExercises > 0 ? completedExercises / totalExercises : 0.0;

    return Card(
      elevation: isCompleted ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCompleted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: isCompleted
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withAlpha(38),
                      Colors.green.withAlpha(12),
                    ],
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getWorkoutIcon(day.type),
                    color: _getWorkoutColor(day.type),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isRestDay) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$totalExercises exercises',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    ),
                ],
              ),
              if (!isRestDay) ...[
                const SizedBox(height: 12),
                Text(
                  day.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completedExercises/$totalExercises completed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isCompleted ? Colors.green : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted
                              ? Colors.green
                              : _getWorkoutColor(day.type),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWorkoutIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.upper:
        return Icons.fitness_center;
      case WorkoutType.lower:
        return Icons.directions_run;
      case WorkoutType.push:
        return Icons.open_in_full;
      case WorkoutType.pull:
        return Icons.close_fullscreen;
      case WorkoutType.legs:
        return Icons.directions_walk;
      case WorkoutType.rest:
        return Icons.hotel;
    }
  }

  Color _getWorkoutColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.upper:
        return Colors.blue;
      case WorkoutType.lower:
        return Colors.green;
      case WorkoutType.push:
        return Colors.orange;
      case WorkoutType.pull:
        return Colors.purple;
      case WorkoutType.legs:
        return Colors.teal;
      case WorkoutType.rest:
        return Colors.grey;
    }
  }
}
