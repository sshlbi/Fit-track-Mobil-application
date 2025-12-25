class AppConstants {
  static const String programName = 'HYPERTROPHY PROGRAM';
  static const int totalWeeks = 12;

  static const String keyCurrentWeek = 'current_week';
  static const String keyWorkoutLogs = 'workout_logs';
  static const String keyDarkMode = 'dark_mode';
  static const String keyWeightUnit = 'weight_unit';

  static final Map<double, String> rpeDescriptions = {
    6.0: 'Could do 4+ more reps',
    7.0: 'Could do 3 more reps',
    8.0: 'Could do 2 more reps',
    8.5: 'Could do 1-2 more reps',
    9.0: 'Could do 1 more rep',
    9.5: 'Could maybe do 1 more rep',
    10.0: 'Could not do more reps (Failure)',
  };

  static const Map<String, String> techniqueDescriptions = {
    'N/A': 'Standard straight sets',
    'Ladder': 'Vary cable height positions across sets',
    'Failure': 'Take the set to complete muscular failure',
    'Myo-reps':
        'Activation set to near failure, rest 5 breaths, mini sets of 3-5 reps until unable',
    'LLPS Extend set':
        'After failure, perform length partials + static stretch',
    'Static Stretch 30s':
        'Hold a 30-60 second stretch in the lengthened position after the set',
    'Drop Set':
        'Perform set to failure, then reduce weight by 20-30% and continue to failure',
    'Rest-Pause':
        'Perform to failure, rest 15-20 seconds, continue to failure. Repeat 2-3 times',
    'Length Partials':
        'After failure, perform partial reps in the stretched/lengthened position',
  };

  static String getTechniqueDescription(String technique) {
    return techniqueDescriptions[technique] ?? technique;
  }

  static String getRPEDescription(double rpe) {
    if (rpe >= 10) return 'Maximum effort - Failure';
    if (rpe >= 9.5) return 'Could maybe do 1 more rep';
    if (rpe >= 9) return 'Could do 1 more rep';
    if (rpe >= 8.5) return 'Could do 1-2 more reps';
    if (rpe >= 8) return 'Could do 2 more reps';
    if (rpe >= 7) return 'Could do 3 more reps';
    if (rpe >= 6) return 'Could do 4+ more reps';
    return 'Very light';
  }
}
