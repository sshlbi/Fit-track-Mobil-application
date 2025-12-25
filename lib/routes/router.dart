import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/week_detail_screen.dart';
import '../screens/workout_day_screen.dart';
import '../screens/exercise_detail_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/settings_screen.dart';
import '../models/exercise.dart';

final routerProvider = Provider((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/week/:weekNumber',
        name: 'week-detail',
        pageBuilder: (context, state) {
          final weekNumber = int.parse(state.pathParameters['weekNumber']!);
          return MaterialPage(
            key: state.pageKey,
            child: WeekDetailScreen(weekNumber: weekNumber),
          );
        },
      ),
      GoRoute(
        path: '/workout-day',
        name: 'workout-day',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MaterialPage(
            key: state.pageKey,
            child: WorkoutDayScreen(
              weekNumber: extra['weekNumber'],
              day: extra['day'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/exercise/:exerciseId',
        name: 'exercise-detail',
        pageBuilder: (context, state) {
          final exercise = state.extra as Exercise;
          return MaterialPage(
            key: state.pageKey,
            child: ExerciseDetailScreen(exercise: exercise),
          );
        },
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProgressScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
    ],
  );
});
