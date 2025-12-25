import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_log.dart';
import '../data/program_data.dart';

final currentWeekProvider = StateNotifierProvider<CurrentWeekNotifier, int>(
  (ref) => CurrentWeekNotifier(),
);

class CurrentWeekNotifier extends StateNotifier<int> {
  CurrentWeekNotifier() : super(1) {
    _loadCurrentWeek();
  }

  Future<void> _loadCurrentWeek() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('currentWeek') ?? 1;
  }

  Future<void> setWeek(int week) async {
    if (week < 1 || week > 12) return;
    state = week;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentWeek', week);
  }

  void nextWeek() {
    if (state < 12) setWeek(state + 1);
  }

  void previousWeek() {
    if (state > 1) setWeek(state - 1);
  }
}

final workoutLogsProvider =
    StateNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>(
  (ref) => WorkoutLogsNotifier(),
);

class WorkoutLogsNotifier extends StateNotifier<List<WorkoutLog>> {
  WorkoutLogsNotifier() : super([]) {
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList('workout_logs') ?? [];
      final logs = logsJson.map((jsonStr) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return WorkoutLog.fromJson(json);
      }).toList();
      state = logs;
    } catch (e) {
      debugPrint('Error loading logs: $e');
      state = [];
    }
  }

  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = state.map((log) => jsonEncode(log.toJson())).toList();
      await prefs.setStringList('workout_logs', logsJson);
    } catch (e) {
      debugPrint('Error saving logs: $e');
    }
  }

  Future<void> addLog(WorkoutLog log) async {
    state = [...state, log];
    await _saveLogs();
  }

  Future<void> updateLog(WorkoutLog log) async {
    state = [
      for (final item in state)
        if (item.id == log.id) log else item,
    ];
    await _saveLogs();
  }

  Future<void> deleteLog(String logId) async {
    state = state.where((log) => log.id != logId).toList();
    await _saveLogs();
  }

  List<WorkoutLog> getLogsForExercise(String exerciseId) {
    return state.where((log) => log.exerciseId == exerciseId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<WorkoutLog> getLogsForWeek(int weekNumber) {
    return state.where((log) => log.weekNumber == weekNumber).toList();
  }

  Future<void> clearAllLogs() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workout_logs');
  }
}

final workoutCompletionProvider =
    StateNotifierProvider<WorkoutCompletionNotifier, Map<String, Set<String>>>(
  (ref) => WorkoutCompletionNotifier(),
);

class WorkoutCompletionNotifier
    extends StateNotifier<Map<String, Set<String>>> {
  WorkoutCompletionNotifier() : super({}) {
    _loadCompletion();
  }

  Future<void> _loadCompletion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completionJson = prefs.getString('workout_completion');
      if (completionJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(completionJson);
        state = decoded.map((key, value) => MapEntry(
              key,
              Set<String>.from(value as List),
            ));
      }
    } catch (e) {
      debugPrint('Error loading completion: $e');
      state = {};
    }
  }

  Future<void> _saveCompletion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final toSave = state.map((key, value) => MapEntry(key, value.toList()));
      await prefs.setString('workout_completion', jsonEncode(toSave));
    } catch (e) {
      debugPrint('Error saving completion: $e');
    }
  }

  Future<void> markExerciseCompleted(
      String workoutDayId, String exerciseId) async {
    final newState = Map<String, Set<String>>.from(state);
    if (!newState.containsKey(workoutDayId)) {
      newState[workoutDayId] = <String>{};
    }
    newState[workoutDayId]!.add(exerciseId);
    state = newState;
    await _saveCompletion();
  }

  Future<void> unmarkExercise(String workoutDayId, String exerciseId) async {
    final newState = Map<String, Set<String>>.from(state);
    if (newState.containsKey(workoutDayId)) {
      newState[workoutDayId]!.remove(exerciseId);
    }
    state = newState;
    await _saveCompletion();
  }

  bool isExerciseCompleted(String workoutDayId, String exerciseId) {
    return state[workoutDayId]?.contains(exerciseId) ?? false;
  }

  bool isWorkoutDayCompleted(String workoutDayId, int totalExercises) {
    final completed = state[workoutDayId]?.length ?? 0;
    return totalExercises > 0 && completed == totalExercises;
  }

  double getWorkoutDayProgress(String workoutDayId, int totalExercises) {
    if (totalExercises == 0) return 0.0;
    final completed = state[workoutDayId]?.length ?? 0;
    return completed / totalExercises;
  }

  Future<void> clearWorkoutDay(String workoutDayId) async {
    final newState = Map<String, Set<String>>.from(state);
    newState.remove(workoutDayId);
    state = newState;
    await _saveCompletion();
  }
}

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, WorkoutLog?>((ref) {
  return ActiveWorkoutNotifier();
});

class ActiveWorkoutNotifier extends StateNotifier<WorkoutLog?> {
  ActiveWorkoutNotifier() : super(null);

  void startWorkout(WorkoutLog workout) {
    state = workout;
  }

  void endWorkout() {
    state = null;
  }

  void clearActiveWorkout() {
    state = null;
  }
}

final programDataProvider = Provider((ref) => ProgramData.getAllWeeks());

final currentWeekDataProvider = Provider((ref) {
  final currentWeek = ref.watch(currentWeekProvider);
  final weeks = ref.watch(programDataProvider);
  return weeks[currentWeek - 1];
});
