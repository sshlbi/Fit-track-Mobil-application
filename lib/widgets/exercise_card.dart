import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../providers/workout_provider.dart';

class ExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final String workoutDayId;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.workoutDayId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(workoutCompletionProvider);
    final isCompleted =
        completion[workoutDayId]?.contains(exercise.id) ?? false;

    return Card(
      elevation: isCompleted ? 2 : 1,
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
                      Colors.green.withAlpha(25),
                      Colors.green.withAlpha(7),
                    ],
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.muscleGroup,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCompleted ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                    onPressed: () {
                      if (isCompleted) {
                        ref
                            .read(workoutCompletionProvider.notifier)
                            .unmarkExercise(workoutDayId, exercise.id);
                      } else {
                        ref
                            .read(workoutCompletionProvider.notifier)
                            .markExerciseCompleted(workoutDayId, exercise.id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    '${exercise.workingSets} sets',
                    Icons.repeat,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    '${exercise.repRange} reps',
                    Icons.fitness_center,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    exercise.restTime,
                    Icons.timer,
                  ),
                ],
              ),
              if (exercise.technique != 'N/A') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        exercise.techniqueIcon,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exercise.technique,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
