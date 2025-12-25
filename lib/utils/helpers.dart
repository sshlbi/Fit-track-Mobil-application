import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static double kgToLbs(double kg) {
    return kg * 2.20462;
  }

  static double lbsToKg(double lbs) {
    return lbs / 2.20462;
  }

  static String formatWeight(double weight, String unit) {
    if (unit == 'lbs') {
      return '${kgToLbs(weight).toStringAsFixed(1)} lbs';
    }
    return '${weight.toStringAsFixed(1)} kg';
  }

  static double calculateTotalVolume(List<dynamic> logs) {
    return logs.fold(0.0, (sum, log) => sum + (log.weight * log.reps));
  }

  static double calculateAverageRPE(List<dynamic> logs) {
    if (logs.isEmpty) return 0;
    final totalRPE = logs.fold(0.0, (sum, log) => sum + log.rpe);
    return totalRPE / logs.length;
  }

  static String getWeekPhase(int weekNumber) {
    if (weekNumber == 1) return 'Foundation/Intro Week';
    if (weekNumber <= 5) return 'Anatomical Adaptation';
    return 'Ramping Phase';
  }

  static bool isDeloadWeek(int weekNumber) {
    return weekNumber == 5;
  }
}
