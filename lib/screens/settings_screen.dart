import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../providers/workout_provider.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final currentWeek = ref.watch(currentWeekProvider);

    ref.listen<int>(currentWeekProvider, (previous, next) {
      debugPrint('Week changed from $previous to $next');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.palette_outlined),
                  title: Text('Appearance'),
                  subtitle: Text('Theme settings'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary:
                      Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark/light theme'),
                  value: isDarkMode,
                  onChanged: (_) =>
                      ref.read(darkModeProvider.notifier).toggle(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.straighten),
                  title: Text('Units'),
                  subtitle: Text('Measurement preferences'),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  secondary: const Icon(Icons.fitness_center),
                  title: const Text('Kilograms (kg)'),
                  value: 'kg',
                  groupValue: weightUnit,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(weightUnitProvider.notifier).setUnit(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  secondary: const Icon(Icons.fitness_center),
                  title: const Text('Pounds (lbs)'),
                  value: 'lbs',
                  groupValue: weightUnit,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(weightUnitProvider.notifier).setUnit(value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Program'),
                  subtitle: Text('Manage your training program'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Reset Current Week'),
                  subtitle: Text('Currently on Week $currentWeek'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    debugPrint('Reset button tapped!');
                    _showResetWeekDialog(context, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Clear All Logs'),
                  subtitle: const Text('Delete all workout history'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    debugPrint('Clear logs button tapped!');
                    _showClearLogsDialog(context, ref);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  subtitle: Text('App information'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.app_settings_alt),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Developer'),
                  subtitle: Text('Built with Flutter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetWeekDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Week?'),
        content: const Text(
          'This will reset your current week to Week 1 and clear all exercise completion marks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              debugPrint('Resetting week to 1...');
              await ref.read(currentWeekProvider.notifier).setWeek(1);

              final weeks = ref.read(programDataProvider);
              final week1 = weeks[0];
              for (var workoutDay in week1.workoutDays) {
                await ref
                    .read(workoutCompletionProvider.notifier)
                    .clearWorkoutDay(workoutDay.id);
              }

              debugPrint('Week reset complete and exercises cleared!');

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Week reset to 1 and exercises cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showClearLogsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Logs?'),
        content: const Text(
          'This will permanently delete all your workout history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              debugPrint('Clearing all logs...');
              await ref.read(workoutLogsProvider.notifier).clearAllLogs();
              debugPrint('Logs cleared!');

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All logs cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
