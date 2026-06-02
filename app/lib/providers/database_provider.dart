import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../models/question_model.dart';

/// Single AppDatabase instance shared across the app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Whether the database has been seeded with questions.
final databaseSeededProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final count = await db.getQuestionCount();
  if (count > 0) return true;

  // Seed from asset
  final jsonStr =
      await rootBundle.loadString('assets/driving_theory_questions.json');
  final List<dynamic> jsonList = json.decode(jsonStr);

  final entries = jsonList.map((e) {
    final q = QuestionModel.fromJson(e as Map<String, dynamic>);
    return QuestionsCompanion.insert(
      questionId: q.questionId,
      themeNumber: q.themeNumber,
      themeName: q.themeName,
      chapterNumber: q.chapterNumber,
      chapterName: q.chapterName,
      questionNumber: q.questionNumber,
      points: q.points,
      questionText: q.questionText,
      optionsJson: json.encode(q.options.map((o) => o.toJson()).toList()),
      correctAnswersJson:
          json.encode(q.correctAnswers.map((o) => o.toJson()).toList()),
      comment: Value(q.comment),
      imageUrls: Value(json.encode(q.imageUrls)),
      localImagePaths: Value(json.encode(q.localImagePaths)),
      videoUrls: Value(json.encode(q.videoUrls)),
      localVideoPaths: Value(json.encode(q.localVideoPaths)),
      url: Value(q.url),
      isGrundstoff: q.isGrundstoff,
    );
  }).toList();

  await db.seedQuestions(entries);
  return true;
});
