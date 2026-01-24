import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutRepository {
  static const String _workoutCompletionBox = 'workout_completion';
  static const String _currentWeekBox = 'current_week';

  static Future<void> init() async {
    try {
      await Hive.openBox<Map>(_workoutCompletionBox);
      await Hive.openBox<int>(_currentWeekBox);
    } catch (e) {
      debugPrint('Error initializing workout repository: $e');
    }
  }

  static int getCurrentWeek() {
    try {
      final box = Hive.box<int>(_currentWeekBox);
      return box.get('week', defaultValue: 1) ?? 1;
    } catch (e) {
      debugPrint('Error getting current week: $e');
      return 1;
    }
  }

  static Future<void> setCurrentWeek(int week) async {
    if (week < 1 || week > 12) return;
    try {
      final box = Hive.box<int>(_currentWeekBox);
      await box.put('week', week);
    } catch (e) {
      debugPrint('Error setting current week: $e');
    }
  }

  static Map<String, Set<String>> getWorkoutCompletion() {
    try {
      final box = Hive.box<Map>(_workoutCompletionBox);
      final data = box.get('completion', defaultValue: <String, dynamic>{});
      if (data == null) return {};

      return (data).map(
        (key, value) => MapEntry(
          key.toString(),
          Set<String>.from(value as List),
        ),
      );
    } catch (e) {
      debugPrint('Error getting workout completion: $e');
      return {};
    }
  }

  static Future<void> saveWorkoutCompletion(
    Map<String, Set<String>> completion,
  ) async {
    try {
      final box = Hive.box<Map>(_workoutCompletionBox);
      final toSave = completion.map(
        (key, value) => MapEntry(key, value.toList()),
      );
      await box.put('completion', toSave);
    } catch (e) {
      debugPrint('Error saving workout completion: $e');
    }
  }

  static Future<void> markExerciseCompleted(
    String workoutDayId,
    String exerciseId,
  ) async {
    final completion = getWorkoutCompletion();
    completion.putIfAbsent(workoutDayId, () => <String>{});
    completion[workoutDayId]!.add(exerciseId);
    await saveWorkoutCompletion(completion);
  }

  static Future<void> unmarkExercise(
    String workoutDayId,
    String exerciseId,
  ) async {
    final completion = getWorkoutCompletion();
    completion[workoutDayId]?.remove(exerciseId);
    await saveWorkoutCompletion(completion);
  }

  static bool isExerciseCompleted(String workoutDayId, String exerciseId) {
    final completion = getWorkoutCompletion();
    return completion[workoutDayId]?.contains(exerciseId) ?? false;
  }

  static bool isWorkoutDayCompleted(String workoutDayId, int totalExercises) {
    final completion = getWorkoutCompletion();
    final completed = completion[workoutDayId]?.length ?? 0;
    return totalExercises > 0 && completed == totalExercises;
  }

  static double getWorkoutProgress(String workoutDayId, int totalExercises) {
    if (totalExercises == 0) return 0.0;
    final completion = getWorkoutCompletion();
    final completed = completion[workoutDayId]?.length ?? 0;
    return completed / totalExercises;
  }

  static Future<void> clearWorkoutDay(String workoutDayId) async {
    final completion = getWorkoutCompletion();
    completion.remove(workoutDayId);
    await saveWorkoutCompletion(completion);
  }
}
