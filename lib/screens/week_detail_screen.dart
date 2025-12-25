import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_day_card.dart';
import '../models/week.dart';

class WeekDetailScreen extends ConsumerWidget {
  final int weekNumber;

  const WeekDetailScreen({super.key, required this.weekNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeks = ref.watch(programDataProvider);
    if (weekNumber < 1 || weekNumber > weeks.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invalid Week')),
        body: const Center(child: Text('Invalid week number')),
      );
    }
    final week = weeks[weekNumber - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('Week $weekNumber'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week $weekNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getBlockName(week.block),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    week.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (week.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              week.notes,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Workout Days',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...week.workoutDays.asMap().entries.map((entry) {
            final day = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WorkoutDayCard(
                day: day,
                onTap: () {
                  context.push(
                    '/workout-day',
                    extra: {
                      'weekNumber': weekNumber,
                      'day': day,
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getBlockName(ProgramBlock block) {
    switch (block) {
      case ProgramBlock.foundation:
        return 'Foundation Block';
      case ProgramBlock.anatomical:
        return 'Anatomical Adaptation';
      case ProgramBlock.ramping:
        return 'Ramping Phase';
    }
  }
}
