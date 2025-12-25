import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/body_weight_entry.dart';

final bodyWeightProvider =
    StateNotifierProvider<BodyWeightNotifier, List<BodyWeightEntry>>(
  (ref) => BodyWeightNotifier(),
);

class BodyWeightNotifier extends StateNotifier<List<BodyWeightEntry>> {
  BodyWeightNotifier() : super([]) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('body_weight_entries') ?? [];
      final entries = entriesJson.map((jsonStr) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return BodyWeightEntry.fromJson(json);
      }).toList();

      entries.sort((a, b) => b.date.compareTo(a.date));
      state = entries;
    } catch (e) {
      debugPrint('Error loading body weight entries: $e');
      state = [];
    }
  }

  Future<void> saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          state.map((entry) => jsonEncode(entry.toJson())).toList();
      await prefs.setStringList('body_weight_entries', entriesJson);
    } catch (e) {
      debugPrint('Error saving body weight entries: $e');
    }
  }

  Future<void> addEntry(BodyWeightEntry entry) async {
    state = [entry, ...state];
    await saveEntries();
  }

  Future<void> updateEntry(BodyWeightEntry entry) async {
    state = [
      for (final item in state)
        if (item.id == entry.id) entry else item,
    ];
    await saveEntries();
  }

  Future<void> deleteEntry(String entryId) async {
    state = state.where((entry) => entry.id != entryId).toList();
    await saveEntries();
  }

  BodyWeightEntry? get latestEntry {
    if (state.isEmpty) return null;
    return state.first;
  }

  double get totalWeightChange {
    if (state.length < 2) return 0.0;
    final oldest = state.last;
    final newest = state.first;
    return newest.weight - oldest.weight;
  }

  double get averageWeight {
    if (state.isEmpty) return 0.0;
    final total = state.fold<double>(0.0, (sum, entry) => sum + entry.weight);
    return total / state.length;
  }
}
