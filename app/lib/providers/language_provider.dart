import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';

enum AppLanguage { en, de }

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final selectedLanguageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  final SharedPreferences _prefs;

  LanguageNotifier(this._prefs) : super(_loadLanguage(_prefs));

  static AppLanguage _loadLanguage(SharedPreferences prefs) {
    final lang = prefs.getString('selected_language') ?? 'en';
    return lang == 'de' ? AppLanguage.de : AppLanguage.en;
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _prefs.setString(
        'selected_language', language == AppLanguage.de ? 'de' : 'en');
  }
}

final ttsEnabledProvider =
    StateNotifierProvider<TtsEnabledNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TtsEnabledNotifier(prefs);
});

class TtsEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  TtsEnabledNotifier(this._prefs)
      : super(_prefs.getBool('tts_enabled') ?? false);

  Future<void> toggle() async {
    state = !state;
    await _prefs.setBool('tts_enabled', state);
  }
}

/// Loads the question JSON for the selected language into a lookup map.
final localizedQuestionMapProvider =
    FutureProvider<Map<String, QuestionModel>>((ref) async {
  final language = ref.watch(selectedLanguageProvider);
  final assetPath = language == AppLanguage.de
      ? 'assets/driving_theory_questions_de.json'
      : 'assets/driving_theory_questions.json';

  final jsonStr = await rootBundle.loadString(assetPath);
  final List<dynamic> jsonList = json.decode(jsonStr);

  final map = <String, QuestionModel>{};
  for (final e in jsonList) {
    final q = QuestionModel.fromJson(e as Map<String, dynamic>);
    map[q.questionId] = q;
  }
  return map;
});

/// Overlays localized text onto a base QuestionModel.
QuestionModel localizeQuestion(
    QuestionModel base, Map<String, QuestionModel>? localizedMap) {
  if (localizedMap == null) return base;
  final localized = localizedMap[base.questionId];
  if (localized == null) return base;
  return QuestionModel(
    themeNumber: base.themeNumber,
    themeName: localized.themeName,
    chapterNumber: base.chapterNumber,
    chapterName: localized.chapterName,
    questionId: base.questionId,
    questionNumber: base.questionNumber,
    points: base.points,
    questionText: localized.questionText,
    options: localized.options,
    correctAnswers: localized.correctAnswers,
    comment: localized.comment,
    imageUrls: base.imageUrls,
    localImagePaths: base.localImagePaths,
    videoUrls: base.videoUrls,
    localVideoPaths: base.localVideoPaths,
    url: base.url,
    isGrundstoff: base.isGrundstoff,
  );
}
