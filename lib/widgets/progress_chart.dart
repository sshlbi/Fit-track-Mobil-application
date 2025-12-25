import 'package:flutter/material.dart';
import '../models/workout_log.dart';

class ProgressChart extends StatelessWidget {
  final List<WorkoutLog> logs;
  final String exerciseId;

  const ProgressChart({
    super.key,
    required this.logs,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = logs
        .where((log) => log.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (exerciseLogs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No progress data yet.\nComplete workouts to see your progress!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exerciseLogs.length,
      itemBuilder: (context, index) {
        final log = exerciseLogs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${log.weight} kg × ${log.reps} reps',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'RPE ${log.rpe} • ${_formatDate(log.date)}',
            ),
            trailing: log.notes != null && log.notes!.isNotEmpty
                ? Icon(
                    Icons.note,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                : null,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
