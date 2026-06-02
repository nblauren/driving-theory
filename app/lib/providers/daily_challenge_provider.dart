import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'language_provider.dart';

const _keyChallengeDate = 'daily_challenge_date';
const _keyChallengeIds = 'daily_challenge_ids';
const _keyChallengeAnswered = 'daily_challenge_answered';

enum DailyChallengeStatus { notStarted, inProgress, complete }

class DailyChallengeData {
  final List<String> questionIds;
  final Set<String> answeredIds;
  final String date;

  DailyChallengeData({
    required this.questionIds,
    required this.answeredIds,
    required this.date,
  });

  DailyChallengeStatus get status {
    if (answeredIds.isEmpty) return DailyChallengeStatus.notStarted;
    if (answeredIds.length >= questionIds.length) {
      return DailyChallengeStatus.complete;
    }
    return DailyChallengeStatus.inProgress;
  }

  int get answeredCount => answeredIds.length;
  int get totalCount => questionIds.length;
}

final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, DailyChallengeData?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final db = ref.watch(databaseProvider);
  return DailyChallengeNotifier(prefs, db);
});

class DailyChallengeNotifier extends StateNotifier<DailyChallengeData?> {
  final SharedPreferences _prefs;
  final AppDatabase _db;

  DailyChallengeNotifier(this._prefs, this._db) : super(null) {
    _loadOrGenerate();
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadOrGenerate() async {
    final storedDate = _prefs.getString(_keyChallengeDate);

    if (storedDate == _todayKey) {
      // Load existing challenge
      final idsJson = _prefs.getString(_keyChallengeIds) ?? '[]';
      final answeredJson = _prefs.getString(_keyChallengeAnswered) ?? '[]';
      final ids = (json.decode(idsJson) as List).cast<String>();
      final answered = (json.decode(answeredJson) as List).cast<String>().toSet();

      state = DailyChallengeData(
        questionIds: ids,
        answeredIds: answered,
        date: storedDate!,
      );
    } else {
      // Generate new challenge
      await _generateChallenge();
    }
  }

  Future<void> _generateChallenge() async {
    final ids = <String>[];

    // Priority 1: Questions with highest incorrectCount, lowest boxLevel
    final allProgress = await _db.select(_db.questionProgress).get();
    final incorrectProgress = allProgress
        .where((p) => p.incorrectCount > 0)
        .toList()
      ..sort((a, b) {
        final cmp = b.incorrectCount.compareTo(a.incorrectCount);
        if (cmp != 0) return cmp;
        return a.boxLevel.compareTo(b.boxLevel);
      });

    for (final p in incorrectProgress) {
      if (ids.length >= 10) break;
      ids.add(p.questionId);
    }

    // Priority 2: Unseen questions
    if (ids.length < 10) {
      final seenIds = allProgress.map((p) => p.questionId).toSet();
      final unseen = await (_db.select(_db.questions)
            ..where((t) => seenIds.isEmpty
                ? const Constant(true)
                : t.questionId.isNotIn(seenIds.toList()))
            ..orderBy([(t) => OrderingTerm.random()])
            ..limit(10 - ids.length))
          .get();
      for (final q in unseen) {
        if (ids.length >= 10) break;
        if (!ids.contains(q.questionId)) {
          ids.add(q.questionId);
        }
      }
    }

    // Priority 3: Box 1 and 2 questions (fill remaining)
    if (ids.length < 10) {
      final lowBox = allProgress
          .where((p) =>
              (p.boxLevel == 1 || p.boxLevel == 2) &&
              !ids.contains(p.questionId))
          .toList()
        ..shuffle();
      for (final p in lowBox) {
        if (ids.length >= 10) break;
        ids.add(p.questionId);
      }
    }

    // If still not enough, add random questions
    if (ids.length < 10) {
      final random = await (_db.select(_db.questions)
            ..where((t) =>
                ids.isEmpty ? const Constant(true) : t.questionId.isNotIn(ids))
            ..orderBy([(t) => OrderingTerm.random()])
            ..limit(10 - ids.length))
          .get();
      for (final q in random) {
        ids.add(q.questionId);
      }
    }

    final today = _todayKey;
    await _prefs.setString(_keyChallengeDate, today);
    await _prefs.setString(_keyChallengeIds, json.encode(ids));
    await _prefs.setString(_keyChallengeAnswered, json.encode([]));

    state = DailyChallengeData(
      questionIds: ids,
      answeredIds: {},
      date: today,
    );
  }

  /// Mark a question as answered in the daily challenge.
  void markAnswered(String questionId) {
    if (state == null) return;
    if (!state!.questionIds.contains(questionId)) return;

    final newAnswered = {...state!.answeredIds, questionId};
    _prefs.setString(_keyChallengeAnswered, json.encode(newAnswered.toList()));

    state = DailyChallengeData(
      questionIds: state!.questionIds,
      answeredIds: newAnswered,
      date: state!.date,
    );
  }
}
