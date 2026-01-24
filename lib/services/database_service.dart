import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/workout_log.dart';
import '../models/set_data.dart';
import '../repositories/workout_repository.dart';

class DatabaseResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  DatabaseResult.success(this.data)
      : error = null,
        isSuccess = true;

  DatabaseResult.error(this.error)
      : data = null,
        isSuccess = false;
}

class DatabaseService {
  static const String _workoutLogsBox = 'workout_logs';
  static const String _setsBox = 'sets';
  static const String _settingsBox = 'settings';
  // static const String _currentWeekKey = 'current_week'; // Removed as we use WorkoutRepository now
  static const String _lastBackupKey = 'last_backup';

  static Box? get _workoutLogsBoxInstance {
    try {
      return Hive.box(_workoutLogsBox);
    } catch (e) {
      debugPrint('Error accessing workout logs box: $e');
      return null;
    }
  }

  static Box? get _setsBoxInstance {
    try {
      return Hive.box(_setsBox);
    } catch (e) {
      debugPrint('Error accessing sets box: $e');
      return null;
    }
  }

  static Box? get _settingsBoxInstance {
    try {
      return Hive.box(_settingsBox);
    } catch (e) {
      debugPrint('Error accessing settings box: $e');
      return null;
    }
  }

  static Future<DatabaseResult<void>> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox(_workoutLogsBox);
      await Hive.openBox(_setsBox);
      await Hive.openBox(_settingsBox);
      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      return DatabaseResult.error('Failed to initialize database: $e');
    }
  }

  static Future<DatabaseResult<void>> saveWorkoutLog(WorkoutLog log) async {
    try {
      final box = _workoutLogsBoxInstance;
      if (box == null) {
        return DatabaseResult.error('Database not initialized');
      }
      await box.put(log.id, log.toJson());
      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error saving workout log: $e');
      return DatabaseResult.error('Failed to save workout: $e');
    }
  }

  static DatabaseResult<List<WorkoutLog>> getAllWorkoutLogs() {
    try {
      final box = _workoutLogsBoxInstance;
      if (box == null) {
        return DatabaseResult.error('Database not initialized');
      }

      final logs = box.values
          .map((data) {
            try {
              return WorkoutLog.fromJson(Map<String, dynamic>.from(data));
            } catch (e) {
              debugPrint('Error parsing workout log: $e');
              return null;
            }
          })
          .whereType<WorkoutLog>()
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return DatabaseResult.success(logs);
    } catch (e) {
      debugPrint('Error getting workout logs: $e');
      return DatabaseResult.error('Failed to load workouts: $e');
    }
  }

  static DatabaseResult<WorkoutLog?> getWorkoutLogById(String id) {
    try {
      final box = _workoutLogsBoxInstance;
      if (box == null) {
        return DatabaseResult.error('Database not initialized');
      }

      final data = box.get(id);
      if (data == null) return DatabaseResult.success(null);

      final log = WorkoutLog.fromJson(Map<String, dynamic>.from(data));
      return DatabaseResult.success(log);
    } catch (e) {
      debugPrint('Error getting workout log by id: $e');
      return DatabaseResult.error('Failed to load workout: $e');
    }
  }

  static Future<DatabaseResult<void>> deleteWorkoutLog(String id) async {
    try {
      final box = _workoutLogsBoxInstance;
      if (box == null) {
        return DatabaseResult.error('Database not initialized');
      }
      await box.delete(id);
      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error deleting workout log: $e');
      return DatabaseResult.error('Failed to delete workout: $e');
    }
  }

  static Future<DatabaseResult<void>> saveSet(SetData set) async {
    try {
      final box = _setsBoxInstance;
      if (box == null) {
        return DatabaseResult.error('Database not initialized');
      }
      await box.put(set.id, set.toJson());
      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error saving set: $e');
      return DatabaseResult.error('Failed to save set: $e');
    }
  }

  static DatabaseResult<List<SetData>> getSetsByExercise(String exerciseId) {
    try {
      final box = _setsBoxInstance;
      if (box == null) {
        return DatabaseResult.error('Database not initialized');
      }

      final sets = box.values
          .map((data) {
            try {
              return SetData.fromJson(Map<String, dynamic>.from(data));
            } catch (e) {
              debugPrint('Error parsing set: $e');
              return null;
            }
          })
          .whereType<SetData>()
          .where((set) => set.exerciseId == exerciseId)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return DatabaseResult.success(sets);
    } catch (e) {
      debugPrint('Error getting sets by exercise: $e');
      return DatabaseResult.error('Failed to load exercise history: $e');
    }
  }

  static DatabaseResult<SetData?> getLastSetForExercise(
      String exerciseId, int setNumber) {
    try {
      final result = getSetsByExercise(exerciseId);
      if (!result.isSuccess || result.data == null) {
        return DatabaseResult.error(result.error ?? 'Unknown error');
      }

      final lastSet = result.data!
          .where((set) => set.setNumber == setNumber && !set.isWarmup)
          .firstOrNull;

      return DatabaseResult.success(lastSet);
    } catch (e) {
      debugPrint('Error getting last set: $e');
      return DatabaseResult.error('Failed to load previous set: $e');
    }
  }

  static int getCurrentWeek() {
    return WorkoutRepository.getCurrentWeek();
  }

  static Future<DatabaseResult<void>> setCurrentWeek(int weekNumber) async {
    try {
      await WorkoutRepository.setCurrentWeek(weekNumber);
      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error setting current week: $e');
      return DatabaseResult.error('Failed to update week: $e');
    }
  }

  static Future<DatabaseResult<String>> exportAllData() async {
    try {
      final logsResult = getAllWorkoutLogs();
      if (!logsResult.isSuccess) {
        return DatabaseResult.error(logsResult.error!);
      }

      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'currentWeek': getCurrentWeek(),
        'workoutLogs': logsResult.data!.map((log) => log.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      return DatabaseResult.success(jsonString);
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return DatabaseResult.error('Failed to export data: $e');
    }
  }

  static Future<DatabaseResult<void>> saveBackupToFile() async {
    try {
      final exportResult = await exportAllData();
      if (!exportResult.isSuccess) {
        return DatabaseResult.error(exportResult.error!);
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/workout_backup_$timestamp.json');
      await file.writeAsString(exportResult.data!);

      final box = _settingsBoxInstance;
      await box?.put(_lastBackupKey, DateTime.now().toIso8601String());

      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error saving backup: $e');
      return DatabaseResult.error('Failed to save backup: $e');
    }
  }

  static Future<DatabaseResult<void>> shareBackup() async {
    try {
      final exportResult = await exportAllData();
      if (!exportResult.isSuccess) {
        return DatabaseResult.error(exportResult.error!);
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/workout_backup_$timestamp.json');
      await file.writeAsString(exportResult.data!);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Workout Backup',
        text: 'Bodybuilding Program Backup',
      );

      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error sharing backup: $e');
      return DatabaseResult.error('Failed to share backup: $e');
    }
  }

  static DateTime? getLastBackupDate() {
    try {
      final box = _settingsBoxInstance;
      if (box == null) return null;
      final dateString = box.get(_lastBackupKey);
      if (dateString == null) return null;
      return DateTime.tryParse(dateString as String);
    } catch (e) {
      debugPrint('Error getting last backup date: $e');
      return null;
    }
  }

  static DatabaseResult<Map<String, dynamic>> getStatistics() {
    try {
      final logsResult = getAllWorkoutLogs();
      if (!logsResult.isSuccess) {
        return DatabaseResult.error(logsResult.error!);
      }

      final logs = logsResult.data!;

      final totalSets = logs.length;
      final totalVolume = logs.fold<double>(
        0,
        (sum, log) => sum + (log.weight * log.reps),
      );

      return DatabaseResult.success({
        'totalSets': totalSets,
        'totalVolume': totalVolume,
        'averageReps': totalSets > 0
            ? logs.fold<int>(0, (sum, log) => sum + log.reps) ~/ totalSets
            : 0,
        'averageWeight': totalSets > 0
            ? logs.fold<double>(0, (sum, log) => sum + log.weight) / totalSets
            : 0,
      });
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return DatabaseResult.error('Failed to load statistics: $e');
    }
  }

  static Future<DatabaseResult<void>> clearWorkoutLogs() async {
    try {
      await _workoutLogsBoxInstance?.clear();
      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error clearing workout logs: $e');
      return DatabaseResult.error('Failed to clear workout logs: $e');
    }
  }

  static Future<DatabaseResult<void>> clearAllData() async {
    try {
      await _workoutLogsBoxInstance?.clear();
      await _setsBoxInstance?.clear();
      await _settingsBoxInstance?.clear();
      // Also clear repository data if possible or warn user.
      // WorkoutRepository data (completion, current week) is in separate boxes.
      // We should probably clear those too if "All Data" is implied.
      // For now, leaving as is but noting it only clears DatabaseService managed boxes.
      return DatabaseResult.success(null);
    } catch (e) {
      debugPrint('Error clearing data: $e');
      return DatabaseResult.error('Failed to clear data: $e');
    }
  }
}
