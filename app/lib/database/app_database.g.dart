// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _themeNumberMeta =
      const VerificationMeta('themeNumber');
  @override
  late final GeneratedColumn<String> themeNumber = GeneratedColumn<String>(
      'theme_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _themeNameMeta =
      const VerificationMeta('themeName');
  @override
  late final GeneratedColumn<String> themeName = GeneratedColumn<String>(
      'theme_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<String> chapterNumber = GeneratedColumn<String>(
      'chapter_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionNumberMeta =
      const VerificationMeta('questionNumber');
  @override
  late final GeneratedColumn<String> questionNumber = GeneratedColumn<String>(
      'question_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
      'points', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _questionTextMeta =
      const VerificationMeta('questionText');
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
      'question_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionsJsonMeta =
      const VerificationMeta('optionsJson');
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
      'options_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctAnswersJsonMeta =
      const VerificationMeta('correctAnswersJson');
  @override
  late final GeneratedColumn<String> correctAnswersJson =
      GeneratedColumn<String>('correct_answers_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _imageUrlsMeta =
      const VerificationMeta('imageUrls');
  @override
  late final GeneratedColumn<String> imageUrls = GeneratedColumn<String>(
      'image_urls', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _localImagePathsMeta =
      const VerificationMeta('localImagePaths');
  @override
  late final GeneratedColumn<String> localImagePaths = GeneratedColumn<String>(
      'local_image_paths', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _videoUrlsMeta =
      const VerificationMeta('videoUrls');
  @override
  late final GeneratedColumn<String> videoUrls = GeneratedColumn<String>(
      'video_urls', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _localVideoPathsMeta =
      const VerificationMeta('localVideoPaths');
  @override
  late final GeneratedColumn<String> localVideoPaths = GeneratedColumn<String>(
      'local_video_paths', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isGrundstoffMeta =
      const VerificationMeta('isGrundstoff');
  @override
  late final GeneratedColumn<bool> isGrundstoff = GeneratedColumn<bool>(
      'is_grundstoff', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_grundstoff" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        questionId,
        themeNumber,
        themeName,
        chapterNumber,
        chapterName,
        questionNumber,
        points,
        questionText,
        optionsJson,
        correctAnswersJson,
        comment,
        imageUrls,
        localImagePaths,
        videoUrls,
        localVideoPaths,
        url,
        isGrundstoff
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(Insertable<Question> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('theme_number')) {
      context.handle(
          _themeNumberMeta,
          themeNumber.isAcceptableOrUnknown(
              data['theme_number']!, _themeNumberMeta));
    } else if (isInserting) {
      context.missing(_themeNumberMeta);
    }
    if (data.containsKey('theme_name')) {
      context.handle(_themeNameMeta,
          themeName.isAcceptableOrUnknown(data['theme_name']!, _themeNameMeta));
    } else if (isInserting) {
      context.missing(_themeNameMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    } else if (isInserting) {
      context.missing(_chapterNameMeta);
    }
    if (data.containsKey('question_number')) {
      context.handle(
          _questionNumberMeta,
          questionNumber.isAcceptableOrUnknown(
              data['question_number']!, _questionNumberMeta));
    } else if (isInserting) {
      context.missing(_questionNumberMeta);
    }
    if (data.containsKey('points')) {
      context.handle(_pointsMeta,
          points.isAcceptableOrUnknown(data['points']!, _pointsMeta));
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    if (data.containsKey('question_text')) {
      context.handle(
          _questionTextMeta,
          questionText.isAcceptableOrUnknown(
              data['question_text']!, _questionTextMeta));
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
          _optionsJsonMeta,
          optionsJson.isAcceptableOrUnknown(
              data['options_json']!, _optionsJsonMeta));
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('correct_answers_json')) {
      context.handle(
          _correctAnswersJsonMeta,
          correctAnswersJson.isAcceptableOrUnknown(
              data['correct_answers_json']!, _correctAnswersJsonMeta));
    } else if (isInserting) {
      context.missing(_correctAnswersJsonMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('image_urls')) {
      context.handle(_imageUrlsMeta,
          imageUrls.isAcceptableOrUnknown(data['image_urls']!, _imageUrlsMeta));
    }
    if (data.containsKey('local_image_paths')) {
      context.handle(
          _localImagePathsMeta,
          localImagePaths.isAcceptableOrUnknown(
              data['local_image_paths']!, _localImagePathsMeta));
    }
    if (data.containsKey('video_urls')) {
      context.handle(_videoUrlsMeta,
          videoUrls.isAcceptableOrUnknown(data['video_urls']!, _videoUrlsMeta));
    }
    if (data.containsKey('local_video_paths')) {
      context.handle(
          _localVideoPathsMeta,
          localVideoPaths.isAcceptableOrUnknown(
              data['local_video_paths']!, _localVideoPathsMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('is_grundstoff')) {
      context.handle(
          _isGrundstoffMeta,
          isGrundstoff.isAcceptableOrUnknown(
              data['is_grundstoff']!, _isGrundstoffMeta));
    } else if (isInserting) {
      context.missing(_isGrundstoffMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      themeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_number'])!,
      themeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_name'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_number'])!,
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name'])!,
      questionNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}question_number'])!,
      points: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}points'])!,
      questionText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_text'])!,
      optionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options_json'])!,
      correctAnswersJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}correct_answers_json'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment'])!,
      imageUrls: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_urls'])!,
      localImagePaths: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_paths'])!,
      videoUrls: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_urls'])!,
      localVideoPaths: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_video_paths'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      isGrundstoff: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_grundstoff'])!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final String questionId;
  final String themeNumber;
  final String themeName;
  final String chapterNumber;
  final String chapterName;
  final String questionNumber;
  final int points;
  final String questionText;
  final String optionsJson;
  final String correctAnswersJson;
  final String comment;
  final String imageUrls;
  final String localImagePaths;
  final String videoUrls;
  final String localVideoPaths;
  final String url;
  final bool isGrundstoff;
  const Question(
      {required this.questionId,
      required this.themeNumber,
      required this.themeName,
      required this.chapterNumber,
      required this.chapterName,
      required this.questionNumber,
      required this.points,
      required this.questionText,
      required this.optionsJson,
      required this.correctAnswersJson,
      required this.comment,
      required this.imageUrls,
      required this.localImagePaths,
      required this.videoUrls,
      required this.localVideoPaths,
      required this.url,
      required this.isGrundstoff});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['theme_number'] = Variable<String>(themeNumber);
    map['theme_name'] = Variable<String>(themeName);
    map['chapter_number'] = Variable<String>(chapterNumber);
    map['chapter_name'] = Variable<String>(chapterName);
    map['question_number'] = Variable<String>(questionNumber);
    map['points'] = Variable<int>(points);
    map['question_text'] = Variable<String>(questionText);
    map['options_json'] = Variable<String>(optionsJson);
    map['correct_answers_json'] = Variable<String>(correctAnswersJson);
    map['comment'] = Variable<String>(comment);
    map['image_urls'] = Variable<String>(imageUrls);
    map['local_image_paths'] = Variable<String>(localImagePaths);
    map['video_urls'] = Variable<String>(videoUrls);
    map['local_video_paths'] = Variable<String>(localVideoPaths);
    map['url'] = Variable<String>(url);
    map['is_grundstoff'] = Variable<bool>(isGrundstoff);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      questionId: Value(questionId),
      themeNumber: Value(themeNumber),
      themeName: Value(themeName),
      chapterNumber: Value(chapterNumber),
      chapterName: Value(chapterName),
      questionNumber: Value(questionNumber),
      points: Value(points),
      questionText: Value(questionText),
      optionsJson: Value(optionsJson),
      correctAnswersJson: Value(correctAnswersJson),
      comment: Value(comment),
      imageUrls: Value(imageUrls),
      localImagePaths: Value(localImagePaths),
      videoUrls: Value(videoUrls),
      localVideoPaths: Value(localVideoPaths),
      url: Value(url),
      isGrundstoff: Value(isGrundstoff),
    );
  }

  factory Question.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      questionId: serializer.fromJson<String>(json['questionId']),
      themeNumber: serializer.fromJson<String>(json['themeNumber']),
      themeName: serializer.fromJson<String>(json['themeName']),
      chapterNumber: serializer.fromJson<String>(json['chapterNumber']),
      chapterName: serializer.fromJson<String>(json['chapterName']),
      questionNumber: serializer.fromJson<String>(json['questionNumber']),
      points: serializer.fromJson<int>(json['points']),
      questionText: serializer.fromJson<String>(json['questionText']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      correctAnswersJson:
          serializer.fromJson<String>(json['correctAnswersJson']),
      comment: serializer.fromJson<String>(json['comment']),
      imageUrls: serializer.fromJson<String>(json['imageUrls']),
      localImagePaths: serializer.fromJson<String>(json['localImagePaths']),
      videoUrls: serializer.fromJson<String>(json['videoUrls']),
      localVideoPaths: serializer.fromJson<String>(json['localVideoPaths']),
      url: serializer.fromJson<String>(json['url']),
      isGrundstoff: serializer.fromJson<bool>(json['isGrundstoff']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'themeNumber': serializer.toJson<String>(themeNumber),
      'themeName': serializer.toJson<String>(themeName),
      'chapterNumber': serializer.toJson<String>(chapterNumber),
      'chapterName': serializer.toJson<String>(chapterName),
      'questionNumber': serializer.toJson<String>(questionNumber),
      'points': serializer.toJson<int>(points),
      'questionText': serializer.toJson<String>(questionText),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'correctAnswersJson': serializer.toJson<String>(correctAnswersJson),
      'comment': serializer.toJson<String>(comment),
      'imageUrls': serializer.toJson<String>(imageUrls),
      'localImagePaths': serializer.toJson<String>(localImagePaths),
      'videoUrls': serializer.toJson<String>(videoUrls),
      'localVideoPaths': serializer.toJson<String>(localVideoPaths),
      'url': serializer.toJson<String>(url),
      'isGrundstoff': serializer.toJson<bool>(isGrundstoff),
    };
  }

  Question copyWith(
          {String? questionId,
          String? themeNumber,
          String? themeName,
          String? chapterNumber,
          String? chapterName,
          String? questionNumber,
          int? points,
          String? questionText,
          String? optionsJson,
          String? correctAnswersJson,
          String? comment,
          String? imageUrls,
          String? localImagePaths,
          String? videoUrls,
          String? localVideoPaths,
          String? url,
          bool? isGrundstoff}) =>
      Question(
        questionId: questionId ?? this.questionId,
        themeNumber: themeNumber ?? this.themeNumber,
        themeName: themeName ?? this.themeName,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        chapterName: chapterName ?? this.chapterName,
        questionNumber: questionNumber ?? this.questionNumber,
        points: points ?? this.points,
        questionText: questionText ?? this.questionText,
        optionsJson: optionsJson ?? this.optionsJson,
        correctAnswersJson: correctAnswersJson ?? this.correctAnswersJson,
        comment: comment ?? this.comment,
        imageUrls: imageUrls ?? this.imageUrls,
        localImagePaths: localImagePaths ?? this.localImagePaths,
        videoUrls: videoUrls ?? this.videoUrls,
        localVideoPaths: localVideoPaths ?? this.localVideoPaths,
        url: url ?? this.url,
        isGrundstoff: isGrundstoff ?? this.isGrundstoff,
      );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      themeNumber:
          data.themeNumber.present ? data.themeNumber.value : this.themeNumber,
      themeName: data.themeName.present ? data.themeName.value : this.themeName,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      questionNumber: data.questionNumber.present
          ? data.questionNumber.value
          : this.questionNumber,
      points: data.points.present ? data.points.value : this.points,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      optionsJson:
          data.optionsJson.present ? data.optionsJson.value : this.optionsJson,
      correctAnswersJson: data.correctAnswersJson.present
          ? data.correctAnswersJson.value
          : this.correctAnswersJson,
      comment: data.comment.present ? data.comment.value : this.comment,
      imageUrls: data.imageUrls.present ? data.imageUrls.value : this.imageUrls,
      localImagePaths: data.localImagePaths.present
          ? data.localImagePaths.value
          : this.localImagePaths,
      videoUrls: data.videoUrls.present ? data.videoUrls.value : this.videoUrls,
      localVideoPaths: data.localVideoPaths.present
          ? data.localVideoPaths.value
          : this.localVideoPaths,
      url: data.url.present ? data.url.value : this.url,
      isGrundstoff: data.isGrundstoff.present
          ? data.isGrundstoff.value
          : this.isGrundstoff,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('questionId: $questionId, ')
          ..write('themeNumber: $themeNumber, ')
          ..write('themeName: $themeName, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('chapterName: $chapterName, ')
          ..write('questionNumber: $questionNumber, ')
          ..write('points: $points, ')
          ..write('questionText: $questionText, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswersJson: $correctAnswersJson, ')
          ..write('comment: $comment, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('localImagePaths: $localImagePaths, ')
          ..write('videoUrls: $videoUrls, ')
          ..write('localVideoPaths: $localVideoPaths, ')
          ..write('url: $url, ')
          ..write('isGrundstoff: $isGrundstoff')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      questionId,
      themeNumber,
      themeName,
      chapterNumber,
      chapterName,
      questionNumber,
      points,
      questionText,
      optionsJson,
      correctAnswersJson,
      comment,
      imageUrls,
      localImagePaths,
      videoUrls,
      localVideoPaths,
      url,
      isGrundstoff);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.questionId == this.questionId &&
          other.themeNumber == this.themeNumber &&
          other.themeName == this.themeName &&
          other.chapterNumber == this.chapterNumber &&
          other.chapterName == this.chapterName &&
          other.questionNumber == this.questionNumber &&
          other.points == this.points &&
          other.questionText == this.questionText &&
          other.optionsJson == this.optionsJson &&
          other.correctAnswersJson == this.correctAnswersJson &&
          other.comment == this.comment &&
          other.imageUrls == this.imageUrls &&
          other.localImagePaths == this.localImagePaths &&
          other.videoUrls == this.videoUrls &&
          other.localVideoPaths == this.localVideoPaths &&
          other.url == this.url &&
          other.isGrundstoff == this.isGrundstoff);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<String> questionId;
  final Value<String> themeNumber;
  final Value<String> themeName;
  final Value<String> chapterNumber;
  final Value<String> chapterName;
  final Value<String> questionNumber;
  final Value<int> points;
  final Value<String> questionText;
  final Value<String> optionsJson;
  final Value<String> correctAnswersJson;
  final Value<String> comment;
  final Value<String> imageUrls;
  final Value<String> localImagePaths;
  final Value<String> videoUrls;
  final Value<String> localVideoPaths;
  final Value<String> url;
  final Value<bool> isGrundstoff;
  final Value<int> rowid;
  const QuestionsCompanion({
    this.questionId = const Value.absent(),
    this.themeNumber = const Value.absent(),
    this.themeName = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.questionNumber = const Value.absent(),
    this.points = const Value.absent(),
    this.questionText = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.correctAnswersJson = const Value.absent(),
    this.comment = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.localImagePaths = const Value.absent(),
    this.videoUrls = const Value.absent(),
    this.localVideoPaths = const Value.absent(),
    this.url = const Value.absent(),
    this.isGrundstoff = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionsCompanion.insert({
    required String questionId,
    required String themeNumber,
    required String themeName,
    required String chapterNumber,
    required String chapterName,
    required String questionNumber,
    required int points,
    required String questionText,
    required String optionsJson,
    required String correctAnswersJson,
    this.comment = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.localImagePaths = const Value.absent(),
    this.videoUrls = const Value.absent(),
    this.localVideoPaths = const Value.absent(),
    this.url = const Value.absent(),
    required bool isGrundstoff,
    this.rowid = const Value.absent(),
  })  : questionId = Value(questionId),
        themeNumber = Value(themeNumber),
        themeName = Value(themeName),
        chapterNumber = Value(chapterNumber),
        chapterName = Value(chapterName),
        questionNumber = Value(questionNumber),
        points = Value(points),
        questionText = Value(questionText),
        optionsJson = Value(optionsJson),
        correctAnswersJson = Value(correctAnswersJson),
        isGrundstoff = Value(isGrundstoff);
  static Insertable<Question> custom({
    Expression<String>? questionId,
    Expression<String>? themeNumber,
    Expression<String>? themeName,
    Expression<String>? chapterNumber,
    Expression<String>? chapterName,
    Expression<String>? questionNumber,
    Expression<int>? points,
    Expression<String>? questionText,
    Expression<String>? optionsJson,
    Expression<String>? correctAnswersJson,
    Expression<String>? comment,
    Expression<String>? imageUrls,
    Expression<String>? localImagePaths,
    Expression<String>? videoUrls,
    Expression<String>? localVideoPaths,
    Expression<String>? url,
    Expression<bool>? isGrundstoff,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (themeNumber != null) 'theme_number': themeNumber,
      if (themeName != null) 'theme_name': themeName,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (chapterName != null) 'chapter_name': chapterName,
      if (questionNumber != null) 'question_number': questionNumber,
      if (points != null) 'points': points,
      if (questionText != null) 'question_text': questionText,
      if (optionsJson != null) 'options_json': optionsJson,
      if (correctAnswersJson != null)
        'correct_answers_json': correctAnswersJson,
      if (comment != null) 'comment': comment,
      if (imageUrls != null) 'image_urls': imageUrls,
      if (localImagePaths != null) 'local_image_paths': localImagePaths,
      if (videoUrls != null) 'video_urls': videoUrls,
      if (localVideoPaths != null) 'local_video_paths': localVideoPaths,
      if (url != null) 'url': url,
      if (isGrundstoff != null) 'is_grundstoff': isGrundstoff,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionsCompanion copyWith(
      {Value<String>? questionId,
      Value<String>? themeNumber,
      Value<String>? themeName,
      Value<String>? chapterNumber,
      Value<String>? chapterName,
      Value<String>? questionNumber,
      Value<int>? points,
      Value<String>? questionText,
      Value<String>? optionsJson,
      Value<String>? correctAnswersJson,
      Value<String>? comment,
      Value<String>? imageUrls,
      Value<String>? localImagePaths,
      Value<String>? videoUrls,
      Value<String>? localVideoPaths,
      Value<String>? url,
      Value<bool>? isGrundstoff,
      Value<int>? rowid}) {
    return QuestionsCompanion(
      questionId: questionId ?? this.questionId,
      themeNumber: themeNumber ?? this.themeNumber,
      themeName: themeName ?? this.themeName,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      chapterName: chapterName ?? this.chapterName,
      questionNumber: questionNumber ?? this.questionNumber,
      points: points ?? this.points,
      questionText: questionText ?? this.questionText,
      optionsJson: optionsJson ?? this.optionsJson,
      correctAnswersJson: correctAnswersJson ?? this.correctAnswersJson,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      videoUrls: videoUrls ?? this.videoUrls,
      localVideoPaths: localVideoPaths ?? this.localVideoPaths,
      url: url ?? this.url,
      isGrundstoff: isGrundstoff ?? this.isGrundstoff,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (themeNumber.present) {
      map['theme_number'] = Variable<String>(themeNumber.value);
    }
    if (themeName.present) {
      map['theme_name'] = Variable<String>(themeName.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<String>(chapterNumber.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (questionNumber.present) {
      map['question_number'] = Variable<String>(questionNumber.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (correctAnswersJson.present) {
      map['correct_answers_json'] = Variable<String>(correctAnswersJson.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (imageUrls.present) {
      map['image_urls'] = Variable<String>(imageUrls.value);
    }
    if (localImagePaths.present) {
      map['local_image_paths'] = Variable<String>(localImagePaths.value);
    }
    if (videoUrls.present) {
      map['video_urls'] = Variable<String>(videoUrls.value);
    }
    if (localVideoPaths.present) {
      map['local_video_paths'] = Variable<String>(localVideoPaths.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (isGrundstoff.present) {
      map['is_grundstoff'] = Variable<bool>(isGrundstoff.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('questionId: $questionId, ')
          ..write('themeNumber: $themeNumber, ')
          ..write('themeName: $themeName, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('chapterName: $chapterName, ')
          ..write('questionNumber: $questionNumber, ')
          ..write('points: $points, ')
          ..write('questionText: $questionText, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswersJson: $correctAnswersJson, ')
          ..write('comment: $comment, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('localImagePaths: $localImagePaths, ')
          ..write('videoUrls: $videoUrls, ')
          ..write('localVideoPaths: $localVideoPaths, ')
          ..write('url: $url, ')
          ..write('isGrundstoff: $isGrundstoff, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionProgressTable extends QuestionProgress
    with TableInfo<$QuestionProgressTable, QuestionProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES questions (question_id)'));
  static const VerificationMeta _boxLevelMeta =
      const VerificationMeta('boxLevel');
  @override
  late final GeneratedColumn<int> boxLevel = GeneratedColumn<int>(
      'box_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextReviewDateMeta =
      const VerificationMeta('nextReviewDate');
  @override
  late final GeneratedColumn<DateTime> nextReviewDate =
      GeneratedColumn<DateTime>('next_review_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _correctCountMeta =
      const VerificationMeta('correctCount');
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
      'correct_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _incorrectCountMeta =
      const VerificationMeta('incorrectCount');
  @override
  late final GeneratedColumn<int> incorrectCount = GeneratedColumn<int>(
      'incorrect_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isBookmarkedMeta =
      const VerificationMeta('isBookmarked');
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
      'is_bookmarked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_bookmarked" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        questionId,
        boxLevel,
        nextReviewDate,
        correctCount,
        incorrectCount,
        isBookmarked
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_progress';
  @override
  VerificationContext validateIntegrity(
      Insertable<QuestionProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('box_level')) {
      context.handle(_boxLevelMeta,
          boxLevel.isAcceptableOrUnknown(data['box_level']!, _boxLevelMeta));
    }
    if (data.containsKey('next_review_date')) {
      context.handle(
          _nextReviewDateMeta,
          nextReviewDate.isAcceptableOrUnknown(
              data['next_review_date']!, _nextReviewDateMeta));
    } else if (isInserting) {
      context.missing(_nextReviewDateMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
          _correctCountMeta,
          correctCount.isAcceptableOrUnknown(
              data['correct_count']!, _correctCountMeta));
    }
    if (data.containsKey('incorrect_count')) {
      context.handle(
          _incorrectCountMeta,
          incorrectCount.isAcceptableOrUnknown(
              data['incorrect_count']!, _incorrectCountMeta));
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
          _isBookmarkedMeta,
          isBookmarked.isAcceptableOrUnknown(
              data['is_bookmarked']!, _isBookmarkedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  QuestionProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionProgressData(
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      boxLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}box_level'])!,
      nextReviewDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_review_date'])!,
      correctCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_count'])!,
      incorrectCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}incorrect_count'])!,
      isBookmarked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_bookmarked'])!,
    );
  }

  @override
  $QuestionProgressTable createAlias(String alias) {
    return $QuestionProgressTable(attachedDatabase, alias);
  }
}

class QuestionProgressData extends DataClass
    implements Insertable<QuestionProgressData> {
  final String questionId;
  final int boxLevel;
  final DateTime nextReviewDate;
  final int correctCount;
  final int incorrectCount;
  final bool isBookmarked;
  const QuestionProgressData(
      {required this.questionId,
      required this.boxLevel,
      required this.nextReviewDate,
      required this.correctCount,
      required this.incorrectCount,
      required this.isBookmarked});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['box_level'] = Variable<int>(boxLevel);
    map['next_review_date'] = Variable<DateTime>(nextReviewDate);
    map['correct_count'] = Variable<int>(correctCount);
    map['incorrect_count'] = Variable<int>(incorrectCount);
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    return map;
  }

  QuestionProgressCompanion toCompanion(bool nullToAbsent) {
    return QuestionProgressCompanion(
      questionId: Value(questionId),
      boxLevel: Value(boxLevel),
      nextReviewDate: Value(nextReviewDate),
      correctCount: Value(correctCount),
      incorrectCount: Value(incorrectCount),
      isBookmarked: Value(isBookmarked),
    );
  }

  factory QuestionProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionProgressData(
      questionId: serializer.fromJson<String>(json['questionId']),
      boxLevel: serializer.fromJson<int>(json['boxLevel']),
      nextReviewDate: serializer.fromJson<DateTime>(json['nextReviewDate']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      incorrectCount: serializer.fromJson<int>(json['incorrectCount']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'boxLevel': serializer.toJson<int>(boxLevel),
      'nextReviewDate': serializer.toJson<DateTime>(nextReviewDate),
      'correctCount': serializer.toJson<int>(correctCount),
      'incorrectCount': serializer.toJson<int>(incorrectCount),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
    };
  }

  QuestionProgressData copyWith(
          {String? questionId,
          int? boxLevel,
          DateTime? nextReviewDate,
          int? correctCount,
          int? incorrectCount,
          bool? isBookmarked}) =>
      QuestionProgressData(
        questionId: questionId ?? this.questionId,
        boxLevel: boxLevel ?? this.boxLevel,
        nextReviewDate: nextReviewDate ?? this.nextReviewDate,
        correctCount: correctCount ?? this.correctCount,
        incorrectCount: incorrectCount ?? this.incorrectCount,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );
  QuestionProgressData copyWithCompanion(QuestionProgressCompanion data) {
    return QuestionProgressData(
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      boxLevel: data.boxLevel.present ? data.boxLevel.value : this.boxLevel,
      nextReviewDate: data.nextReviewDate.present
          ? data.nextReviewDate.value
          : this.nextReviewDate,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      incorrectCount: data.incorrectCount.present
          ? data.incorrectCount.value
          : this.incorrectCount,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionProgressData(')
          ..write('questionId: $questionId, ')
          ..write('boxLevel: $boxLevel, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('correctCount: $correctCount, ')
          ..write('incorrectCount: $incorrectCount, ')
          ..write('isBookmarked: $isBookmarked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, boxLevel, nextReviewDate,
      correctCount, incorrectCount, isBookmarked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionProgressData &&
          other.questionId == this.questionId &&
          other.boxLevel == this.boxLevel &&
          other.nextReviewDate == this.nextReviewDate &&
          other.correctCount == this.correctCount &&
          other.incorrectCount == this.incorrectCount &&
          other.isBookmarked == this.isBookmarked);
}

class QuestionProgressCompanion extends UpdateCompanion<QuestionProgressData> {
  final Value<String> questionId;
  final Value<int> boxLevel;
  final Value<DateTime> nextReviewDate;
  final Value<int> correctCount;
  final Value<int> incorrectCount;
  final Value<bool> isBookmarked;
  final Value<int> rowid;
  const QuestionProgressCompanion({
    this.questionId = const Value.absent(),
    this.boxLevel = const Value.absent(),
    this.nextReviewDate = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.incorrectCount = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionProgressCompanion.insert({
    required String questionId,
    this.boxLevel = const Value.absent(),
    required DateTime nextReviewDate,
    this.correctCount = const Value.absent(),
    this.incorrectCount = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : questionId = Value(questionId),
        nextReviewDate = Value(nextReviewDate);
  static Insertable<QuestionProgressData> custom({
    Expression<String>? questionId,
    Expression<int>? boxLevel,
    Expression<DateTime>? nextReviewDate,
    Expression<int>? correctCount,
    Expression<int>? incorrectCount,
    Expression<bool>? isBookmarked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (boxLevel != null) 'box_level': boxLevel,
      if (nextReviewDate != null) 'next_review_date': nextReviewDate,
      if (correctCount != null) 'correct_count': correctCount,
      if (incorrectCount != null) 'incorrect_count': incorrectCount,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionProgressCompanion copyWith(
      {Value<String>? questionId,
      Value<int>? boxLevel,
      Value<DateTime>? nextReviewDate,
      Value<int>? correctCount,
      Value<int>? incorrectCount,
      Value<bool>? isBookmarked,
      Value<int>? rowid}) {
    return QuestionProgressCompanion(
      questionId: questionId ?? this.questionId,
      boxLevel: boxLevel ?? this.boxLevel,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (boxLevel.present) {
      map['box_level'] = Variable<int>(boxLevel.value);
    }
    if (nextReviewDate.present) {
      map['next_review_date'] = Variable<DateTime>(nextReviewDate.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (incorrectCount.present) {
      map['incorrect_count'] = Variable<int>(incorrectCount.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionProgressCompanion(')
          ..write('questionId: $questionId, ')
          ..write('boxLevel: $boxLevel, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('correctCount: $correctCount, ')
          ..write('incorrectCount: $incorrectCount, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $QuestionProgressTable questionProgress =
      $QuestionProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [questions, questionProgress];
}

typedef $$QuestionsTableCreateCompanionBuilder = QuestionsCompanion Function({
  required String questionId,
  required String themeNumber,
  required String themeName,
  required String chapterNumber,
  required String chapterName,
  required String questionNumber,
  required int points,
  required String questionText,
  required String optionsJson,
  required String correctAnswersJson,
  Value<String> comment,
  Value<String> imageUrls,
  Value<String> localImagePaths,
  Value<String> videoUrls,
  Value<String> localVideoPaths,
  Value<String> url,
  required bool isGrundstoff,
  Value<int> rowid,
});
typedef $$QuestionsTableUpdateCompanionBuilder = QuestionsCompanion Function({
  Value<String> questionId,
  Value<String> themeNumber,
  Value<String> themeName,
  Value<String> chapterNumber,
  Value<String> chapterName,
  Value<String> questionNumber,
  Value<int> points,
  Value<String> questionText,
  Value<String> optionsJson,
  Value<String> correctAnswersJson,
  Value<String> comment,
  Value<String> imageUrls,
  Value<String> localImagePaths,
  Value<String> videoUrls,
  Value<String> localVideoPaths,
  Value<String> url,
  Value<bool> isGrundstoff,
  Value<int> rowid,
});

final class $$QuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestionsTable, Question> {
  $$QuestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestionProgressTable, List<QuestionProgressData>>
      _questionProgressRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.questionProgress,
              aliasName: $_aliasNameGenerator(
                  db.questions.questionId, db.questionProgress.questionId));

  $$QuestionProgressTableProcessedTableManager get questionProgressRefs {
    final manager =
        $$QuestionProgressTableTableManager($_db, $_db.questionProgress).filter(
            (f) => f.questionId.questionId
                .sqlEquals($_itemColumn<String>('question_id')!));

    final cache =
        $_typedResult.readTableOrNull(_questionProgressRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeNumber => $composableBuilder(
      column: $table.themeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeName => $composableBuilder(
      column: $table.themeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionNumber => $composableBuilder(
      column: $table.questionNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctAnswersJson => $composableBuilder(
      column: $table.correctAnswersJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrls => $composableBuilder(
      column: $table.imageUrls, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePaths => $composableBuilder(
      column: $table.localImagePaths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoUrls => $composableBuilder(
      column: $table.videoUrls, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localVideoPaths => $composableBuilder(
      column: $table.localVideoPaths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGrundstoff => $composableBuilder(
      column: $table.isGrundstoff, builder: (column) => ColumnFilters(column));

  Expression<bool> questionProgressRefs(
      Expression<bool> Function($$QuestionProgressTableFilterComposer f) f) {
    final $$QuestionProgressTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questionProgress,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionProgressTableFilterComposer(
              $db: $db,
              $table: $db.questionProgress,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeNumber => $composableBuilder(
      column: $table.themeNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeName => $composableBuilder(
      column: $table.themeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionNumber => $composableBuilder(
      column: $table.questionNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionText => $composableBuilder(
      column: $table.questionText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctAnswersJson => $composableBuilder(
      column: $table.correctAnswersJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrls => $composableBuilder(
      column: $table.imageUrls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePaths => $composableBuilder(
      column: $table.localImagePaths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoUrls => $composableBuilder(
      column: $table.videoUrls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localVideoPaths => $composableBuilder(
      column: $table.localVideoPaths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGrundstoff => $composableBuilder(
      column: $table.isGrundstoff,
      builder: (column) => ColumnOrderings(column));
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<String> get themeNumber => $composableBuilder(
      column: $table.themeNumber, builder: (column) => column);

  GeneratedColumn<String> get themeName =>
      $composableBuilder(column: $table.themeName, builder: (column) => column);

  GeneratedColumn<String> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<String> get questionNumber => $composableBuilder(
      column: $table.questionNumber, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => column);

  GeneratedColumn<String> get correctAnswersJson => $composableBuilder(
      column: $table.correctAnswersJson, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get imageUrls =>
      $composableBuilder(column: $table.imageUrls, builder: (column) => column);

  GeneratedColumn<String> get localImagePaths => $composableBuilder(
      column: $table.localImagePaths, builder: (column) => column);

  GeneratedColumn<String> get videoUrls =>
      $composableBuilder(column: $table.videoUrls, builder: (column) => column);

  GeneratedColumn<String> get localVideoPaths => $composableBuilder(
      column: $table.localVideoPaths, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<bool> get isGrundstoff => $composableBuilder(
      column: $table.isGrundstoff, builder: (column) => column);

  Expression<T> questionProgressRefs<T extends Object>(
      Expression<T> Function($$QuestionProgressTableAnnotationComposer a) f) {
    final $$QuestionProgressTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questionProgress,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionProgressTableAnnotationComposer(
              $db: $db,
              $table: $db.questionProgress,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (Question, $$QuestionsTableReferences),
    Question,
    PrefetchHooks Function({bool questionProgressRefs})> {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> questionId = const Value.absent(),
            Value<String> themeNumber = const Value.absent(),
            Value<String> themeName = const Value.absent(),
            Value<String> chapterNumber = const Value.absent(),
            Value<String> chapterName = const Value.absent(),
            Value<String> questionNumber = const Value.absent(),
            Value<int> points = const Value.absent(),
            Value<String> questionText = const Value.absent(),
            Value<String> optionsJson = const Value.absent(),
            Value<String> correctAnswersJson = const Value.absent(),
            Value<String> comment = const Value.absent(),
            Value<String> imageUrls = const Value.absent(),
            Value<String> localImagePaths = const Value.absent(),
            Value<String> videoUrls = const Value.absent(),
            Value<String> localVideoPaths = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<bool> isGrundstoff = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionsCompanion(
            questionId: questionId,
            themeNumber: themeNumber,
            themeName: themeName,
            chapterNumber: chapterNumber,
            chapterName: chapterName,
            questionNumber: questionNumber,
            points: points,
            questionText: questionText,
            optionsJson: optionsJson,
            correctAnswersJson: correctAnswersJson,
            comment: comment,
            imageUrls: imageUrls,
            localImagePaths: localImagePaths,
            videoUrls: videoUrls,
            localVideoPaths: localVideoPaths,
            url: url,
            isGrundstoff: isGrundstoff,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String questionId,
            required String themeNumber,
            required String themeName,
            required String chapterNumber,
            required String chapterName,
            required String questionNumber,
            required int points,
            required String questionText,
            required String optionsJson,
            required String correctAnswersJson,
            Value<String> comment = const Value.absent(),
            Value<String> imageUrls = const Value.absent(),
            Value<String> localImagePaths = const Value.absent(),
            Value<String> videoUrls = const Value.absent(),
            Value<String> localVideoPaths = const Value.absent(),
            Value<String> url = const Value.absent(),
            required bool isGrundstoff,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionsCompanion.insert(
            questionId: questionId,
            themeNumber: themeNumber,
            themeName: themeName,
            chapterNumber: chapterNumber,
            chapterName: chapterName,
            questionNumber: questionNumber,
            points: points,
            questionText: questionText,
            optionsJson: optionsJson,
            correctAnswersJson: correctAnswersJson,
            comment: comment,
            imageUrls: imageUrls,
            localImagePaths: localImagePaths,
            videoUrls: videoUrls,
            localVideoPaths: localVideoPaths,
            url: url,
            isGrundstoff: isGrundstoff,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuestionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({questionProgressRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (questionProgressRefs) db.questionProgress
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questionProgressRefs)
                    await $_getPrefetchedData<Question, $QuestionsTable,
                            QuestionProgressData>(
                        currentTable: table,
                        referencedTable: $$QuestionsTableReferences
                            ._questionProgressRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$QuestionsTableReferences(db, table, p0)
                                .questionProgressRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.questionId == item.questionId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$QuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (Question, $$QuestionsTableReferences),
    Question,
    PrefetchHooks Function({bool questionProgressRefs})>;
typedef $$QuestionProgressTableCreateCompanionBuilder
    = QuestionProgressCompanion Function({
  required String questionId,
  Value<int> boxLevel,
  required DateTime nextReviewDate,
  Value<int> correctCount,
  Value<int> incorrectCount,
  Value<bool> isBookmarked,
  Value<int> rowid,
});
typedef $$QuestionProgressTableUpdateCompanionBuilder
    = QuestionProgressCompanion Function({
  Value<String> questionId,
  Value<int> boxLevel,
  Value<DateTime> nextReviewDate,
  Value<int> correctCount,
  Value<int> incorrectCount,
  Value<bool> isBookmarked,
  Value<int> rowid,
});

final class $$QuestionProgressTableReferences extends BaseReferences<
    _$AppDatabase, $QuestionProgressTable, QuestionProgressData> {
  $$QuestionProgressTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias($_aliasNameGenerator(
          db.questionProgress.questionId, db.questions.questionId));

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<String>('question_id')!;

    final manager = $$QuestionsTableTableManager($_db, $_db.questions)
        .filter((f) => f.questionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$QuestionProgressTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionProgressTable> {
  $$QuestionProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get boxLevel => $composableBuilder(
      column: $table.boxLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReviewDate => $composableBuilder(
      column: $table.nextReviewDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get incorrectCount => $composableBuilder(
      column: $table.incorrectCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => ColumnFilters(column));

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableFilterComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuestionProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionProgressTable> {
  $$QuestionProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get boxLevel => $composableBuilder(
      column: $table.boxLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReviewDate => $composableBuilder(
      column: $table.nextReviewDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctCount => $composableBuilder(
      column: $table.correctCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get incorrectCount => $composableBuilder(
      column: $table.incorrectCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked,
      builder: (column) => ColumnOrderings(column));

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableOrderingComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuestionProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionProgressTable> {
  $$QuestionProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get boxLevel =>
      $composableBuilder(column: $table.boxLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewDate => $composableBuilder(
      column: $table.nextReviewDate, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => column);

  GeneratedColumn<int> get incorrectCount => $composableBuilder(
      column: $table.incorrectCount, builder: (column) => column);

  GeneratedColumn<bool> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => column);

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuestionProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionProgressTable,
    QuestionProgressData,
    $$QuestionProgressTableFilterComposer,
    $$QuestionProgressTableOrderingComposer,
    $$QuestionProgressTableAnnotationComposer,
    $$QuestionProgressTableCreateCompanionBuilder,
    $$QuestionProgressTableUpdateCompanionBuilder,
    (QuestionProgressData, $$QuestionProgressTableReferences),
    QuestionProgressData,
    PrefetchHooks Function({bool questionId})> {
  $$QuestionProgressTableTableManager(
      _$AppDatabase db, $QuestionProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> questionId = const Value.absent(),
            Value<int> boxLevel = const Value.absent(),
            Value<DateTime> nextReviewDate = const Value.absent(),
            Value<int> correctCount = const Value.absent(),
            Value<int> incorrectCount = const Value.absent(),
            Value<bool> isBookmarked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionProgressCompanion(
            questionId: questionId,
            boxLevel: boxLevel,
            nextReviewDate: nextReviewDate,
            correctCount: correctCount,
            incorrectCount: incorrectCount,
            isBookmarked: isBookmarked,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String questionId,
            Value<int> boxLevel = const Value.absent(),
            required DateTime nextReviewDate,
            Value<int> correctCount = const Value.absent(),
            Value<int> incorrectCount = const Value.absent(),
            Value<bool> isBookmarked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionProgressCompanion.insert(
            questionId: questionId,
            boxLevel: boxLevel,
            nextReviewDate: nextReviewDate,
            correctCount: correctCount,
            incorrectCount: incorrectCount,
            isBookmarked: isBookmarked,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuestionProgressTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (questionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.questionId,
                    referencedTable:
                        $$QuestionProgressTableReferences._questionIdTable(db),
                    referencedColumn: $$QuestionProgressTableReferences
                        ._questionIdTable(db)
                        .questionId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$QuestionProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestionProgressTable,
    QuestionProgressData,
    $$QuestionProgressTableFilterComposer,
    $$QuestionProgressTableOrderingComposer,
    $$QuestionProgressTableAnnotationComposer,
    $$QuestionProgressTableCreateCompanionBuilder,
    $$QuestionProgressTableUpdateCompanionBuilder,
    (QuestionProgressData, $$QuestionProgressTableReferences),
    QuestionProgressData,
    PrefetchHooks Function({bool questionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$QuestionProgressTableTableManager get questionProgress =>
      $$QuestionProgressTableTableManager(_db, _db.questionProgress);
}
