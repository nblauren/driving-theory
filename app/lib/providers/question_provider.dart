import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../models/question_model.dart';
import '../services/firebase_sync_service.dart';
import 'daily_challenge_provider.dart';
import 'database_provider.dart';
import 'language_provider.dart';
import 'streak_provider.dart';

/// Converts a Drift Question row back into our domain model.
QuestionModel questionFromRow(Question row) {
  final options = (json.decode(row.optionsJson) as List)
      .map((e) => OptionModel.fromJson(e as Map<String, dynamic>))
      .toList();
  final correctAnswers = (json.decode(row.correctAnswersJson) as List)
      .map((e) => OptionModel.fromJson(e as Map<String, dynamic>))
      .toList();

  return QuestionModel(
    themeNumber: row.themeNumber,
    themeName: row.themeName,
    chapterNumber: row.chapterNumber,
    chapterName: row.chapterName,
    questionId: row.questionId,
    questionNumber: row.questionNumber,
    points: row.points,
    questionText: row.questionText,
    options: options,
    correctAnswers: correctAnswers,
    comment: row.comment,
    imageUrls: (json.decode(row.imageUrls) as List).cast<String>(),
    localImagePaths: (json.decode(row.localImagePaths) as List).cast<String>(),
    videoUrls: (json.decode(row.videoUrls) as List).cast<String>(),
    localVideoPaths: (json.decode(row.localVideoPaths) as List).cast<String>(),
    url: row.url,
    isGrundstoff: row.isGrundstoff,
  );
}

enum QuestionFilter { all, unseen, incorrect, dueForReview, bookmarked, dailyChallenge }

/// Provides filtered question lists with localization applied.
final questionListProvider =
    FutureProvider.family<List<QuestionModel>, QuestionFilter>(
        (ref, filter) async {
  final db = ref.watch(databaseProvider);
  final localizedMap = await ref.watch(localizedQuestionMapProvider.future);
  List<Question> rows;

  switch (filter) {
    case QuestionFilter.all:
      rows = await db.getAllQuestions();
      break;
    case QuestionFilter.unseen:
      rows = await db.getUnseenQuestions(limit: 1000);
      break;
    case QuestionFilter.incorrect:
      rows = await db.getIncorrectQuestions(limit: 1000);
      break;
    case QuestionFilter.dueForReview:
      rows = await db.getDueQuestions(limit: 100);
      break;
    case QuestionFilter.bookmarked:
      rows = await db.getBookmarkedQuestions();
      break;
    case QuestionFilter.dailyChallenge:
      final challenge = ref.read(dailyChallengeProvider);
      if (challenge != null && challenge.questionIds.isNotEmpty) {
        rows = await db.getQuestionsByIds(challenge.questionIds);
      } else {
        rows = [];
      }
      break;
  }

  return rows
      .map((row) => localizeQuestion(questionFromRow(row), localizedMap))
      .toList();
});

/// SRS box intervals in days.
const Map<int, int> boxIntervals = {
  1: 1,
  2: 3,
  3: 7,
  4: 14,
};

/// Records an answer and updates SRS state.
/// Optionally syncs to Firestore if [syncService] is provided.
Future<void> recordAnswer(
  AppDatabase db,
  String questionId,
  bool isCorrect, {
  FirebaseSyncService? syncService,
}) async {
  final existing = await db.getProgress(questionId);
  final now = DateTime.now();

  int newBox;
  int correctCount;
  int incorrectCount;

  if (existing != null) {
    correctCount = existing.correctCount + (isCorrect ? 1 : 0);
    incorrectCount = existing.incorrectCount + (isCorrect ? 0 : 1);
    if (isCorrect) {
      newBox = existing.boxLevel + 1;
      if (newBox > 5) newBox = 5;
    } else {
      newBox = 1;
    }
  } else {
    correctCount = isCorrect ? 1 : 0;
    incorrectCount = isCorrect ? 0 : 1;
    newBox = isCorrect ? 2 : 1;
  }

  final intervalDays = boxIntervals[newBox] ?? 30;
  final nextReview = now.add(Duration(days: intervalDays));

  final companion = QuestionProgressCompanion(
    questionId: Value(questionId),
    boxLevel: Value(newBox),
    nextReviewDate: Value(nextReview),
    correctCount: Value(correctCount),
    incorrectCount: Value(incorrectCount),
  );

  await db.upsertProgress(companion);

  // Fire-and-forget sync to Firestore
  syncService?.syncProgress(QuestionProgressData(
    questionId: questionId,
    boxLevel: newBox,
    nextReviewDate: nextReview,
    correctCount: correctCount,
    incorrectCount: incorrectCount,
    isBookmarked: existing?.isBookmarked ?? false,
  ));
}

// --- Exam simulation ---

class ExamResult {
  final List<ExamQuestion> questions;
  final int totalPenalty;
  final int fivePointWrong;
  final bool passed;
  final bool hadEnoughQuestions;

  ExamResult({
    required this.questions,
    required this.totalPenalty,
    required this.fivePointWrong,
    required this.passed,
    this.hadEnoughQuestions = true,
  });
}

class ExamQuestion {
  final QuestionModel question;
  final Set<String> selectedAnswers;
  final bool isCorrect;

  ExamQuestion({
    required this.question,
    required this.selectedAnswers,
    required this.isCorrect,
  });
}

/// Generate exam questions.
Future<ExamGenerationResult> generateExam(AppDatabase db) async {
  final grundstoff = await db.getRandomQuestions(isGrundstoff: true, count: 20);
  final zusatzstoff =
      await db.getRandomQuestions(isGrundstoff: false, count: 10);

  final hasEnough = grundstoff.length >= 20 && zusatzstoff.length >= 10;

  List<Question> examQuestions;
  if (hasEnough) {
    examQuestions = [...grundstoff, ...zusatzstoff];
  } else {
    // Fallback: random 30 from all
    final all = await db.getRandomQuestions(isGrundstoff: true, count: 15);
    final all2 = await db.getRandomQuestions(isGrundstoff: false, count: 15);
    examQuestions = [...all, ...all2];
    if (examQuestions.length > 30) {
      examQuestions = examQuestions.sublist(0, 30);
    }
  }

  return ExamGenerationResult(
    questions: examQuestions.map(questionFromRow).toList(),
    hadEnoughQuestions: hasEnough,
  );
}

class ExamGenerationResult {
  final List<QuestionModel> questions;
  final bool hadEnoughQuestions;

  ExamGenerationResult({
    required this.questions,
    required this.hadEnoughQuestions,
  });
}

/// Score an exam.
ExamResult scoreExam(
    List<QuestionModel> questions, List<Set<String>> answers, bool hadEnough) {
  int totalPenalty = 0;
  int fivePointWrong = 0;
  final examQuestions = <ExamQuestion>[];

  for (int i = 0; i < questions.length; i++) {
    final q = questions[i];
    final selected = answers[i];
    final correctLetters =
        q.correctAnswers.map((a) => a.letter).toSet();

    final isCorrect = selected.length == correctLetters.length &&
        selected.containsAll(correctLetters);

    if (!isCorrect) {
      totalPenalty += q.points;
      if (q.points == 5) fivePointWrong++;
    }

    examQuestions.add(ExamQuestion(
      question: q,
      selectedAnswers: selected,
      isCorrect: isCorrect,
    ));
  }

  final passed = totalPenalty <= 10 && fivePointWrong < 2;

  return ExamResult(
    questions: examQuestions,
    totalPenalty: totalPenalty,
    fivePointWrong: fivePointWrong,
    passed: passed,
    hadEnoughQuestions: hadEnough,
  );
}

// --- Stats ---

final statsProvider = FutureProvider<StatsData>((ref) async {
  final db = ref.watch(databaseProvider);
  final totalQ = await db.getQuestionCount();
  final answered = await db.getTotalAnswered();
  final correct = await db.getTotalCorrect();
  final incorrect = await db.getTotalIncorrect();
  final themeStats = await db.getThemeStats();

  return StatsData(
    totalQuestions: totalQ,
    totalAnswered: answered,
    totalCorrect: correct,
    totalIncorrect: incorrect,
    themeStats: themeStats,
  );
});

/// Exam readiness percentage (0–100), recalculated on invalidation.
final readinessProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getReadinessPercentage();
});

/// Predicted exam readiness date.
class PredictionData {
  final DateTime? predictedDate;
  final bool alreadyReady;
  final bool notEnoughData;
  final bool tooFarOut;

  const PredictionData({
    this.predictedDate,
    this.alreadyReady = false,
    this.notEnoughData = false,
    this.tooFarOut = false,
  });
}

final predictionProvider = FutureProvider<PredictionData>((ref) async {
  final db = ref.watch(databaseProvider);
  final streakNotifier = ref.watch(streakProvider.notifier);

  final readiness = await db.getReadinessPercentage();
  if (readiness >= 80) {
    return const PredictionData(alreadyReady: true);
  }

  final avgPerDay = streakNotifier.getAverageQuestionsPerDay();
  if (avgPerDay == null) {
    return const PredictionData(notEnoughData: true);
  }

  // Calculate deficit
  final totalQuestions = await db.getQuestionCount();
  final targetScore = 80.0 * totalQuestions; // Each question needs avg 80 points
  final allProgress = await db.select(db.questionProgress).get();
  double currentScore = 0;
  for (final p in allProgress) {
    currentScore += switch (p.boxLevel) {
      0 => 0.0,
      1 => 20.0,
      2 => 40.0,
      3 => 60.0,
      4 => 80.0,
      _ => 100.0,
    };
  }

  final deficit = targetScore - currentScore;
  if (deficit <= 0) {
    return const PredictionData(alreadyReady: true);
  }

  // Each question answered is assumed to gain ~20 points on average
  final questionsNeeded = deficit / 20.0;
  final daysRemaining = (questionsNeeded / avgPerDay).ceil();

  if (daysRemaining > 90) {
    return const PredictionData(tooFarOut: true);
  }

  final predictedDate = DateTime.now().add(Duration(days: daysRemaining));
  return PredictionData(predictedDate: predictedDate);
});

class StatsData {
  final int totalQuestions;
  final int totalAnswered;
  final int totalCorrect;
  final int totalIncorrect;
  final List<ThemeStat> themeStats;

  StatsData({
    required this.totalQuestions,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.themeStats,
  });
}
