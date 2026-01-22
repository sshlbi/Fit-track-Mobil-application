import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/workout_provider.dart';
import '../utils/helpers.dart';
import '../models/workout_log.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutLogsProvider);
    final currentWeek = ref.watch(currentWeekProvider);

    final logsByWeek = <int, List<WorkoutLog>>{};
    for (var log in logs) {
      logsByWeek.putIfAbsent(log.weekNumber, () => []).add(log);
    }

    final totalSets = logs.length;
    final totalVolume = Helpers.calculateTotalVolume(logs);
    final avgRPE = logs.isEmpty ? 0.0 : Helpers.calculateAverageRPE(logs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workout logs yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start logging your workouts to track progress',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatItem(
                                label: 'Total Sets',
                                value: totalSets.toString(),
                                icon: Icons.repeat,
                              ),
                            ),
                            Expanded(
                              child: _StatItem(
                                label: 'Avg RPE',
                                value: avgRPE.toStringAsFixed(1),
                                icon: Icons.speed,
                              ),
                            ),
                            Expanded(
                              child: _StatItem(
                                label: 'Volume',
                                value:
                                    '${(totalVolume / 1000).toStringAsFixed(1)}k',
                                icon: Icons.fitness_center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Weekly Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...List.generate(12, (index) {
                  final weekNum = index + 1;
                  final weekLogs = logsByWeek[weekNum] ?? [];
                  final isCurrentWeek = weekNum == currentWeek;

                  if (weekLogs.isEmpty && weekNum > currentWeek) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isCurrentWeek
                        ? Theme.of(context).colorScheme.primary.withAlpha(25)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCurrentWeek
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Week $weekNum',
                                      style: TextStyle(
                                        color: isCurrentWeek
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isCurrentWeek) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'CURRENT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (weekLogs.isNotEmpty)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade400,
                                ),
                            ],
                          ),
                          if (weekLogs.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _WeekStat(
                                  label: 'Sets',
                                  value: weekLogs.length.toString(),
                                ),
                                const SizedBox(width: 16),
                                _WeekStat(
                                  label: 'Volume',
                                  value:
                                      '${Helpers.calculateTotalVolume(weekLogs).toStringAsFixed(0)} kg',
                                ),
                                const SizedBox(width: 16),
                                _WeekStat(
                                  label: 'Avg RPE',
                                  value: Helpers.calculateAverageRPE(weekLogs)
                                      .toStringAsFixed(1),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            Text(
                              'No workouts logged yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String label;
  final String value;

  const _WeekStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
