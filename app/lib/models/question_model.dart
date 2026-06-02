/// Represents a single option (answer choice) for a question.
class OptionModel {
  final String letter;
  final String text;

  const OptionModel({required this.letter, required this.text});

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      letter: json['letter'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'letter': letter, 'text': text};
}

/// Represents a full question parsed from the JSON dataset.
class QuestionModel {
  final String themeNumber;
  final String themeName;
  final String chapterNumber;
  final String chapterName;
  final String questionId;
  final String questionNumber;
  final int points;
  final String questionText;
  final List<OptionModel> options;
  final List<OptionModel> correctAnswers;
  final String comment;
  final List<String> imageUrls;
  final List<String> localImagePaths;
  final List<String> videoUrls;
  final List<String> localVideoPaths;
  final String url;
  final bool isGrundstoff;

  const QuestionModel({
    required this.themeNumber,
    required this.themeName,
    required this.chapterNumber,
    required this.chapterName,
    required this.questionId,
    required this.questionNumber,
    required this.points,
    required this.questionText,
    required this.options,
    required this.correctAnswers,
    required this.comment,
    required this.imageUrls,
    required this.localImagePaths,
    required this.videoUrls,
    required this.localVideoPaths,
    required this.url,
    required this.isGrundstoff,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final questionId = json['question_id'] as String? ?? '';
    // Parse points: "4 Points" -> 4
    final pointsStr = json['points'] as String? ?? '0';
    final points = int.tryParse(pointsStr.split(' ').first) ?? 0;

    return QuestionModel(
      themeNumber: json['theme_number'] as String? ?? '',
      themeName: json['theme_name'] as String? ?? '',
      chapterNumber: json['chapter_number'] as String? ?? '',
      chapterName: json['chapter_name'] as String? ?? '',
      questionId: questionId,
      questionNumber: json['question_number'] as String? ?? '',
      points: points,
      questionText: json['question_text'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => OptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      correctAnswers: (json['correct_answers'] as List<dynamic>?)
              ?.map((e) => OptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comment: json['comment'] as String? ?? '',
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      localImagePaths: (json['local_image_paths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoUrls: (json['video_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      localVideoPaths: (json['local_video_paths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      url: json['url'] as String? ?? '',
      // Theme 1.x = Grundstoff, Theme 2.x = Zusatzstoff
      isGrundstoff: questionId.startsWith('1.'),
    );
  }
}
