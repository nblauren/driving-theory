import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_provider.dart';

const _keyCurrentStreak = 'streak_current';
const _keyLongestStreak = 'streak_longest';
const _keyLastStudied = 'streak_last_studied';
const _keyStudyHistory = 'study_history';

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudiedDate;
  final bool studiedToday;
  final bool streakIncrementedToday;

  const StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudiedDate,
    this.studiedToday = false,
    this.streakIncrementedToday = false,
  });
}

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakData>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StreakNotifier(prefs);
});

class StreakNotifier extends StateNotifier<StreakData> {
  final SharedPreferences _prefs;

  StreakNotifier(this._prefs) : super(const StreakData()) {
    _load();
  }

  void _load() {
    final current = _prefs.getInt(_keyCurrentStreak) ?? 0;
    final longest = _prefs.getInt(_keyLongestStreak) ?? 0;
    final lastStr = _prefs.getString(_keyLastStudied);
    final lastDate = lastStr != null ? DateTime.tryParse(lastStr) : null;

    final today = _dateOnly(DateTime.now());
    final studiedToday =
        lastDate != null && _dateOnly(lastDate) == today;

    state = StreakData(
      currentStreak: current,
      longestStreak: longest,
      lastStudiedDate: lastDate,
      studiedToday: studiedToday,
    );
  }

  /// Call this each time a question is answered.
  /// Returns true if the streak was incremented (first answer of the day).
  bool recordStudyDay() {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final lastDate = state.lastStudiedDate;

    // Already studied today
    if (lastDate != null && _dateOnly(lastDate) == today) {
      // Still increment study history count
      _incrementStudyHistory(today);
      return false;
    }

    int newStreak;
    if (lastDate == null) {
      // First ever answer
      newStreak = 1;
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      if (_dateOnly(lastDate) == yesterday) {
        newStreak = state.currentStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    final newLongest =
        newStreak > state.longestStreak ? newStreak : state.longestStreak;

    _prefs.setInt(_keyCurrentStreak, newStreak);
    _prefs.setInt(_keyLongestStreak, newLongest);
    _prefs.setString(_keyLastStudied, now.toIso8601String());

    _incrementStudyHistory(today);

    state = StreakData(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastStudiedDate: now,
      studiedToday: true,
      streakIncrementedToday: true,
    );

    return true;
  }

  void _incrementStudyHistory(DateTime date) {
    final history = getStudyHistory();
    final key = _dateKey(date);
    history[key] = (history[key] ?? 0) + 1;
    _prefs.setString(_keyStudyHistory, json.encode(history));
  }

  Map<String, int> getStudyHistory() {
    final str = _prefs.getString(_keyStudyHistory);
    if (str == null) return {};
    final decoded = json.decode(str) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as int));
  }

  /// Average questions per day over the last 7 days.
  /// Returns null if fewer than 3 days of data exist.
  double? getAverageQuestionsPerDay() {
    final history = getStudyHistory();
    final now = DateTime.now();
    int daysWithData = 0;
    int totalQuestions = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      final count = history[key];
      if (count != null && count > 0) {
        daysWithData++;
        totalQuestions += count;
      }
    }

    if (daysWithData < 3) return null;
    return totalQuestions / 7.0;
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
