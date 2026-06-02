import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/app_database.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseSyncService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  bool get isLoggedIn => _uid != null;

  DocumentReference _progressDoc(String questionId) =>
      _firestore.collection('users').doc(_uid).collection('progress').doc(questionId);

  /// Write a single progress record to Firestore (fire-and-forget).
  void syncProgress(QuestionProgressData progress) {
    if (!isLoggedIn) return;

    _progressDoc(progress.questionId).set({
      'questionId': progress.questionId,
      'boxLevel': progress.boxLevel,
      'nextReviewDate': Timestamp.fromDate(progress.nextReviewDate),
      'correctCount': progress.correctCount,
      'incorrectCount': progress.incorrectCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((e) {
      log('Firestore write error: $e', name: 'FirebaseSyncService');
    });
  }

  /// Pull all progress from Firestore and merge with local Drift data.
  /// Merge strategy: higher boxLevel wins; ties broken by higher correctCount.
  Future<int> pullAndMerge(AppDatabase db) async {
    if (!isLoggedIn) return 0;

    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('progress')
        .get();

    int merged = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final questionId = data['questionId'] as String;
      final remoteBox = data['boxLevel'] as int;
      final remoteNextReview = (data['nextReviewDate'] as Timestamp).toDate();
      final remoteCorrect = data['correctCount'] as int;
      final remoteIncorrect = data['incorrectCount'] as int;

      final local = await db.getProgress(questionId);

      bool shouldUpdate = false;

      if (local == null) {
        shouldUpdate = true;
      } else if (remoteBox > local.boxLevel) {
        shouldUpdate = true;
      } else if (remoteBox == local.boxLevel && remoteCorrect > local.correctCount) {
        shouldUpdate = true;
      }

      if (shouldUpdate) {
        await db.upsertProgress(QuestionProgressCompanion(
          questionId: Value(questionId),
          boxLevel: Value(remoteBox),
          nextReviewDate: Value(remoteNextReview),
          correctCount: Value(remoteCorrect),
          incorrectCount: Value(remoteIncorrect),
        ));
        merged++;
      }
    }

    return merged;
  }

  /// Push all local progress to Firestore (for initial sync after login).
  Future<void> pushAllProgress(AppDatabase db) async {
    if (!isLoggedIn) return;

    final allProgress = await db.select(db.questionProgress).get();
    final batch = _firestore.batch();

    for (final p in allProgress) {
      batch.set(_progressDoc(p.questionId), {
        'questionId': p.questionId,
        'boxLevel': p.boxLevel,
        'nextReviewDate': Timestamp.fromDate(p.nextReviewDate),
        'correctCount': p.correctCount,
        'incorrectCount': p.incorrectCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (allProgress.isNotEmpty) {
      await batch.commit();
    }
  }
}
