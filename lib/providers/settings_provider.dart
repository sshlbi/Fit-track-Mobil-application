import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>(
  (ref) => DarkModeNotifier(),
);

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(false) {
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('darkMode') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', state);
  }
}

final weightUnitProvider = StateNotifierProvider<WeightUnitNotifier, String>(
  (ref) => WeightUnitNotifier(),
);

class WeightUnitNotifier extends StateNotifier<String> {
  WeightUnitNotifier() : super('kg') {
    _loadWeightUnit();
  }

  Future<void> _loadWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('weightUnit') ?? 'kg';
  }

  Future<void> setUnit(String unit) async {
    if (unit != 'kg' && unit != 'lbs') return;
    state = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weightUnit', unit);
  }
}
