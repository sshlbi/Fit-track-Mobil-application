import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/workout_day.dart';
import '../widgets/exercise_card.dart';

class WorkoutDayScreen extends ConsumerWidget {
  final int weekNumber;
  final WorkoutDay day;

  const WorkoutDayScreen({
    super.key,
    required this.weekNumber,
    required this.day,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(day.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: day.exercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rest Day',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recover and prepare for the next workout',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getWorkoutIcon(day.type),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                day.description,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${day.exercises.length} Exercises',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...day.exercises.asMap().entries.map((entry) {
                  return ExerciseCard(
                    exercise: entry.value,
                    workoutDayId: day.id,
                    onTap: () {
                      context.push(
                        '/exercise/${entry.value.id}',
                        extra: entry.value,
                      );
                    },
                  );
                }),
              ],
            ),
    );
  }

  IconData _getWorkoutIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.upper:
        return Icons.accessibility_new;
      case WorkoutType.lower:
        return Icons.directions_run;
      case WorkoutType.push:
        return Icons.push_pin;
      case WorkoutType.pull:
        return Icons.fitness_center;
      case WorkoutType.legs:
        return Icons.directions_walk;
      case WorkoutType.rest:
        return Icons.self_improvement;
    }
  }
}
