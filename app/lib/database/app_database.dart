import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Stores all question data parsed from the JSON dataset.
class Questions extends Table {
  TextColumn get questionId => text()();
  TextColumn get themeNumber => text()();
  TextColumn get themeName => text()();
  TextColumn get chapterNumber => text()();
  TextColumn get chapterName => text()();
  TextColumn get questionNumber => text()();
  IntColumn get points => integer()();
  TextColumn get questionText => text()();
  TextColumn get optionsJson => text()();
  TextColumn get correctAnswersJson => text()();
  TextColumn get comment => text().withDefault(const Constant(''))();
  TextColumn get imageUrls => text().withDefault(const Constant('[]'))();
  TextColumn get localImagePaths => text().withDefault(const Constant('[]'))();
  TextColumn get videoUrls => text().withDefault(const Constant('[]'))();
  TextColumn get localVideoPaths => text().withDefault(const Constant('[]'))();
  TextColumn get url => text().withDefault(const Constant(''))();
  BoolColumn get isGrundstoff => boolean()();

  @override
  Set<Column> get primaryKey => {questionId};
}

/// Tracks per-question SRS (spaced repetition) progress.
class QuestionProgress extends Table {
  TextColumn get questionId =>
      text().references(Questions, #questionId)();
  IntColumn get boxLevel => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewDate => dateTime()();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  IntColumn get incorrectCount => integer().withDefault(const Constant(0))();
  BoolColumn get isBookmarked =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {questionId};
}

@DriftDatabase(tables: [Questions, QuestionProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(
                questionProgress, questionProgress.isBookmarked);
          }
        },
      );

  // --- Question queries ---

  Future<List<Question>> getAllQuestions() => select(questions).get();

  Future<int> getQuestionCount() async {
    final count = countAll();
    final query = selectOnly(questions)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Get questions due for review (SRS).
  Future<List<Question>> getDueQuestions({int limit = 20}) async {
    final now = DateTime.now();
    final dueProgress = await (select(questionProgress)
          ..where((t) => t.nextReviewDate.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewDate)])
          ..limit(limit))
        .get();

    if (dueProgress.isEmpty) return [];

    final ids = dueProgress.map((p) => p.questionId).toList();
    return (select(questions)..where((t) => t.questionId.isIn(ids))).get();
  }

  /// Get unseen questions (no progress entry).
  Future<List<Question>> getUnseenQuestions({int limit = 20}) async {
    // Two-step: get all progress IDs, then exclude them
    final allProgress = await select(questionProgress).get();
    final seenIds = allProgress.map((p) => p.questionId).toSet();

    if (seenIds.isEmpty) {
      return (select(questions)..limit(limit)).get();
    }

    return (select(questions)
          ..where((t) => t.questionId.isNotIn(seenIds.toList()))
          ..limit(limit))
        .get();
  }

  /// Get questions answered incorrectly at least once.
  Future<List<Question>> getIncorrectQuestions({int limit = 50}) async {
    final incorrectProgress = await (select(questionProgress)
          ..where((t) => t.incorrectCount.isBiggerThanValue(0)))
        .get();

    if (incorrectProgress.isEmpty) return [];

    final ids = incorrectProgress.map((p) => p.questionId).toList();
    return (select(questions)..where((t) => t.questionId.isIn(ids))).get();
  }

  /// Get random questions for exam simulation.
  Future<List<Question>> getRandomQuestions({
    required bool isGrundstoff,
    required int count,
  }) async {
    final query = select(questions)
      ..where((t) => t.isGrundstoff.equals(isGrundstoff))
      ..orderBy([(t) => OrderingTerm.random()])
      ..limit(count);
    return query.get();
  }

  /// Get questions by a list of IDs, preserving the order of [ids].
  Future<List<Question>> getQuestionsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows =
        await (select(questions)..where((t) => t.questionId.isIn(ids))).get();
    final map = {for (final r in rows) r.questionId: r};
    return ids.map((id) => map[id]).whereType<Question>().toList();
  }

  // --- Progress queries ---

  Future<QuestionProgressData?> getProgress(String questionId) =>
      (select(questionProgress)
            ..where((t) => t.questionId.equals(questionId)))
          .getSingleOrNull();

  Future<void> upsertProgress(QuestionProgressCompanion entry) =>
      into(questionProgress).insertOnConflictUpdate(entry);

  Future<int> getTotalAnswered() async {
    final count = countAll();
    final query = selectOnly(questionProgress)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> getTotalCorrect() async {
    final sum = questionProgress.correctCount.sum();
    final query = selectOnly(questionProgress)..addColumns([sum]);
    final row = await query.getSingle();
    return row.read(sum) ?? 0;
  }

  Future<int> getTotalIncorrect() async {
    final sum = questionProgress.incorrectCount.sum();
    final query = selectOnly(questionProgress)..addColumns([sum]);
    final row = await query.getSingle();
    return row.read(sum) ?? 0;
  }

  /// Per-theme stats.
  Future<List<ThemeStat>> getThemeStats() async {
    final themeCol = questions.themeNumber;
    final themeNameCol = questions.themeName;
    final totalCount = countAll();

    final totalQuery = selectOnly(questions)
      ..addColumns([themeCol, themeNameCol, totalCount])
      ..groupBy([themeCol, themeNameCol]);

    final totalRows = await totalQuery.get();

    // Get all progress question IDs in one query
    final allProgress = await select(questionProgress).get();
    final progressIds = allProgress.map((p) => p.questionId).toSet();

    // Get all questions to map theme -> question IDs
    final allQuestions = await select(questions).get();
    final themeQuestionIds = <String, Set<String>>{};
    for (final q in allQuestions) {
      themeQuestionIds.putIfAbsent(q.themeNumber, () => {}).add(q.questionId);
    }

    final stats = <ThemeStat>[];
    for (final row in totalRows) {
      final theme = row.read(themeCol)!;
      final name = row.read(themeNameCol)!;
      final total = row.read(totalCount)!;

      final qIds = themeQuestionIds[theme] ?? {};
      final answered = qIds.intersection(progressIds).length;

      stats.add(ThemeStat(
        themeNumber: theme,
        themeName: name,
        totalQuestions: total,
        answeredQuestions: answered,
      ));
    }

    return stats;
  }

  /// Get bookmarked questions.
  Future<List<Question>> getBookmarkedQuestions({int limit = 1000}) async {
    final bookmarked = await (select(questionProgress)
          ..where((t) => t.isBookmarked.equals(true)))
        .get();

    if (bookmarked.isEmpty) return [];

    final ids = bookmarked.map((p) => p.questionId).toList();
    return (select(questions)
          ..where((t) => t.questionId.isIn(ids))
          ..limit(limit))
        .get();
  }

  /// Toggle bookmark state for a question.
  Future<void> toggleBookmark(String questionId) async {
    final existing = await getProgress(questionId);
    final currentlyBookmarked = existing?.isBookmarked ?? false;

    await into(questionProgress).insertOnConflictUpdate(
      QuestionProgressCompanion(
        questionId: Value(questionId),
        isBookmarked: Value(!currentlyBookmarked),
        boxLevel: Value(existing?.boxLevel ?? 0),
        nextReviewDate: Value(existing?.nextReviewDate ?? DateTime.now()),
        correctCount: Value(existing?.correctCount ?? 0),
        incorrectCount: Value(existing?.incorrectCount ?? 0),
      ),
    );
  }

  /// Check if a question is bookmarked.
  Future<bool> isQuestionBookmarked(String questionId) async {
    final progress = await getProgress(questionId);
    return progress?.isBookmarked ?? false;
  }

  /// Calculate exam readiness percentage based on SRS box levels.
  Future<double> getReadinessPercentage() async {
    final totalQuestions = await getQuestionCount();
    if (totalQuestions == 0) return 0.0;

    final allProgress = await select(questionProgress).get();
    double totalScore = 0.0;

    for (final p in allProgress) {
      totalScore += switch (p.boxLevel) {
        0 => 0.0,
        1 => 20.0,
        2 => 40.0,
        3 => 60.0,
        4 => 80.0,
        _ => 100.0,
      };
    }

    // Unseen questions (no progress entry) contribute 0%
    return totalScore / totalQuestions;
  }

  /// Bulk insert questions using batch.
  Future<void> seedQuestions(List<QuestionsCompanion> entries) async {
    await batch((b) {
      b.insertAll(questions, entries, mode: InsertMode.insertOrIgnore);
    });
  }
}

class ThemeStat {
  final String themeNumber;
  final String themeName;
  final int totalQuestions;
  final int answeredQuestions;

  ThemeStat({
    required this.themeNumber,
    required this.themeName,
    required this.totalQuestions,
    required this.answeredQuestions,
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'driving_theory.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
