import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/workout_log.dart';
import '../services/database_service.dart';
import '../data/program_data.dart';
import '../repositories/workout_repository.dart';

final currentWeekProvider = StateNotifierProvider<CurrentWeekNotifier, int>(
  (ref) => CurrentWeekNotifier(),
);

class CurrentWeekNotifier extends StateNotifier<int> {
  CurrentWeekNotifier() : super(1) {
    _loadCurrentWeek();
  }

  void _loadCurrentWeek() {
    state = WorkoutRepository.getCurrentWeek();
  }

  Future<void> setWeek(int week) async {
    if (week < 1 || week > 12) return;
    state = week;
    await WorkoutRepository.setCurrentWeek(week);
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
    final result = DatabaseService.getAllWorkoutLogs();
    if (result.isSuccess && result.data != null) {
      state = result.data!;
    } else {
      // Handle error or empty state
      state = [];
    }
  }

  Future<void> addLog(WorkoutLog log) async {
    final result = await DatabaseService.saveWorkoutLog(log);
    if (result.isSuccess) {
      state = [...state, log];
    } else {
      // Handle error
      debugPrint('Failed to save log: ${result.error}');
    }
  }

  Future<void> updateLog(WorkoutLog log) async {
    final result = await DatabaseService.saveWorkoutLog(log);
    if (result.isSuccess) {
      state = [
        for (final item in state)
          if (item.id == log.id) log else item,
      ];
    } else {
      debugPrint('Failed to update log: ${result.error}');
    }
  }

  Future<void> deleteLog(String logId) async {
    final result = await DatabaseService.deleteWorkoutLog(logId);
    if (result.isSuccess) {
      state = state.where((log) => log.id != logId).toList();
    } else {
      debugPrint('Failed to delete log: ${result.error}');
    }
  }

  List<WorkoutLog> getLogsForExercise(String exerciseId) {
    return state.where((log) => log.exerciseId == exerciseId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<WorkoutLog> getLogsForWeek(int weekNumber) {
    return state.where((log) => log.weekNumber == weekNumber).toList();
  }

  Future<void> clearAllLogs() async {
    final result = await DatabaseService.clearWorkoutLogs();
    if (result.isSuccess) {
      state = [];
    } else {
      debugPrint('Failed to clear logs: ${result.error}');
    }
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

  void _loadCompletion() {
    state = WorkoutRepository.getWorkoutCompletion();
  }

  Future<void> markExerciseCompleted(
      String workoutDayId, String exerciseId) async {
    await WorkoutRepository.markExerciseCompleted(workoutDayId, exerciseId);
    _loadCompletion(); // Reload state
  }

  Future<void> unmarkExercise(String workoutDayId, String exerciseId) async {
    await WorkoutRepository.unmarkExercise(workoutDayId, exerciseId);
    _loadCompletion(); // Reload state
  }

  bool isExerciseCompleted(String workoutDayId, String exerciseId) {
    return WorkoutRepository.isExerciseCompleted(workoutDayId, exerciseId);
  }

  bool isWorkoutDayCompleted(String workoutDayId, int totalExercises) {
    return WorkoutRepository.isWorkoutDayCompleted(
        workoutDayId, totalExercises);
  }

  double getWorkoutDayProgress(String workoutDayId, int totalExercises) {
    return WorkoutRepository.getWorkoutProgress(workoutDayId, totalExercises);
  }

  Future<void> clearWorkoutDay(String workoutDayId) async {
    await WorkoutRepository.clearWorkoutDay(workoutDayId);
    _loadCompletion(); // Reload state
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
