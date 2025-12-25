import '../models/week.dart';
import 'weeks/week_1_data.dart';
import 'weeks/week_2_data.dart';
import 'weeks/week_3_data.dart';
import 'weeks/week_4_data.dart';
import 'weeks/week_5_data.dart';
import 'weeks/week_6_data.dart';
import 'weeks/week_7_data.dart';
import 'weeks/week_8_data.dart';
import 'weeks/week_9_data.dart';
import 'weeks/week_10_data.dart';
import 'weeks/week_11_data.dart';
import 'weeks/week_12_data.dart';

class ProgramData {
  static List<Week> getAllWeeks() {
    return [
      getWeek1Data(),
      getWeek2Data(),
      getWeek3Data(),
      getWeek4Data(),
      getWeek5Data(),
      getWeek6Data(),
      getWeek7Data(),
      getWeek8Data(),
      getWeek9Data(),
      getWeek10Data(),
      getWeek11Data(),
      getWeek12Data(),
    ];
  }

  static Week getWeekData(int weekNumber) {
    if (weekNumber < 1 || weekNumber > 12) {
      throw ArgumentError('Week number must be between 1 and 12');
    }
    return getAllWeeks()[weekNumber - 1];
  }

  static String getProgramName() {
    return 'HYPERTROPHY PROGRAM';
  }

  static String getProgramDescription() {
    return 'A 12-week science-based muscle building program designed for progressive hypertrophy. '
        'This program combines different training techniques and block periodization to optimize muscle growth. '
        'Follow the prescribed exercises, rep ranges, and RPE guidelines for best results.';
  }

  static Map<String, dynamic> getProgramStats() {
    return {
      'weeks': 12,
      'blocks': 3,
      'exercises_per_week': 16,
      'estimated_sessions': 48,
    };
  }
}
