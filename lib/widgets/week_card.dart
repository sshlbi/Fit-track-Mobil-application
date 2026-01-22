import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/week.dart';
import '../providers/workout_provider.dart';

class WeekCard extends ConsumerWidget {
  final Week week;
  final VoidCallback onTap;

  const WeekCard({
    super.key,
    required this.week,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(workoutCompletionProvider);

    int totalWorkouts =
        week.workoutDays.where((day) => day.exercises.isNotEmpty).length;
    int completedWorkouts = 0;

    for (var day in week.workoutDays) {
      if (day.exercises.isEmpty) continue;
      final completedExercises = completion[day.id]?.length ?? 0;
      if (completedExercises == day.exercises.length) {
        completedWorkouts++;
      }
    }

    final isWeekCompleted =
        totalWorkouts > 0 && completedWorkouts == totalWorkouts;
    final completionPercentage =
        totalWorkouts > 0 ? completedWorkouts / totalWorkouts : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWeekCompleted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: isWeekCompleted
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withAlpha(25),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getBlockColor(week.block).withAlpha(51),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Week ${week.weekNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getBlockColor(week.block),
                      ),
                    ),
                  ),
                  if (week.isDeload) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'DELOAD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (isWeekCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                week.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                week.notes,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: $completedWorkouts/$totalWorkouts workouts',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(completionPercentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: completionPercentage,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isWeekCompleted
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBlockColor(ProgramBlock block) {
    switch (block) {
      case ProgramBlock.foundation:
        return Colors.blue;
      case ProgramBlock.anatomical:
        return Colors.purple;
      case ProgramBlock.ramping:
        return Colors.orange;
    }
  }
}
