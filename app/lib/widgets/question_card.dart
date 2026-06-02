import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/question_model.dart';

/// Key German traffic terms to highlight.
const _highlightTerms = [
  'Vorfahrt',
  'Gefährdung',
  'Überholverbot',
  'Geschwindigkeit',
  'Bremsweg',
  'Sicherheitsabstand',
  'Gegenverkehr',
  'Rechtsfahrgebot',
  'Schrittgeschwindigkeit',
  'Autobahn',
  'Rettungsgasse',
  'Warnblinklicht',
  'Fahrstreifen',
  'Überholen',
  'Abbiegevorgang',
  'Vorrang',
];

class QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final Set<String> selectedAnswers;
  final bool submitted;
  final bool isNumericAnswer;
  final void Function(String)? onAnswerToggle;
  final void Function(String)? onNumericSubmit;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;
  final bool isTtsPlaying;
  final VoidCallback? onTtsToggle;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswers,
    required this.submitted,
    this.isNumericAnswer = false,
    this.onAnswerToggle,
    this.onNumericSubmit,
    this.isBookmarked = false,
    this.onBookmarkToggle,
    this.isTtsPlaying = false,
    this.onTtsToggle,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _videoWatched = false;
  bool _showQuestion = false;

  bool get _isVideoQuestion => widget.question.localVideoPaths.isNotEmpty;
  bool get _contentRevealed => !_isVideoQuestion || _showQuestion;

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.questionId != widget.question.questionId) {
      _videoWatched = false;
      _showQuestion = false;
    }
  }

  void _onFirstPlayComplete() {
    if (!_videoWatched) {
      setState(() => _videoWatched = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = widget.question;
    final correctLetters =
        question.correctAnswers.map((a) => a.letter).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category tag + action buttons
        Row(
          children: [
            // Category pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGlow,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.borderAccent),
              ),
              child: Text(
                '${question.themeNumber} ${question.themeName}'.toUpperCase(),
                style: AppTextStyles.labelSmall(color: AppColors.accentLight),
              ),
            ),
            const Spacer(),
            if (widget.onTtsToggle != null)
              GestureDetector(
                onTap: widget.onTtsToggle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isTtsPlaying ? Icons.stop : Icons.volume_up,
                      size: 16,
                      color: AppColors.accentLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isTtsPlaying ? 'Stop' : 'Read aloud',
                      style: AppTextStyles.labelSmall(color: AppColors.accentLight),
                    ),
                  ],
                ),
              ),
            if (widget.onBookmarkToggle != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onBookmarkToggle,
                child: Icon(
                  widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: widget.isBookmarked ? AppColors.warning : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        // Points + type badges
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _pointsColor(question.points).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${question.points} ${question.points == 1 ? "Point" : "Points"}',
                style: AppTextStyles.labelSmall(
                  color: _pointsColor(question.points),
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (question.isGrundstoff
                        ? AppColors.accentPrimary
                        : AppColors.warning)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.isGrundstoff ? 'Grundstoff' : 'Zusatzstoff B',
                style: AppTextStyles.labelSmall(
                  color: question.isGrundstoff
                      ? AppColors.accentLight
                      : AppColors.warning,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Text(
              question.questionId,
              style: AppTextStyles.labelSmall(
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Videos (shown until user clicks "Show the Question")
        if (_isVideoQuestion && !_showQuestion) ...[
          ...question.localVideoPaths.map((vidPath) => Padding(
                key: ValueKey('${question.questionId}_$vidPath'),
                padding: const EdgeInsets.only(bottom: 12),
                child: _AssetVideoPlayer(
                  assetPath: 'assets/$vidPath',
                  onFirstPlayComplete: _onFirstPlayComplete,
                ),
              )),
          if (!_videoWatched)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundElevated : AppColors.lightBackgroundElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility_off,
                      size: 20,
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Watch the video to reveal the question and answers.',
                      style: AppTextStyles.bodySmall(
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => setState(() => _showQuestion = true),
                icon: const Icon(Icons.visibility),
                label: const Text('Show the Question'),
              ),
            ),
          const SizedBox(height: 12),
        ],
        // Content revealed after video watched (or immediately for non-video questions)
        if (_contentRevealed) ...[
          // Images
          if (question.localImagePaths.isNotEmpty)
            ...question.localImagePaths.map((imgPath) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: InteractiveViewer(
                      maxScale: 4.0,
                      child: Image.asset(
                        'assets/$imgPath',
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                )),
          // Question text with highlighted terms
          _buildQuestionText(context),
          const SizedBox(height: 20),
          // Answer options
          if (widget.isNumericAnswer)
            _NumericAnswerField(
              submitted: widget.submitted,
              selectedValue: widget.selectedAnswers.isNotEmpty
                  ? widget.selectedAnswers.first
                  : '',
              correctValue: question.correctAnswers.isNotEmpty
                  ? question.correctAnswers.first.letter
                  : '',
              onSubmit: widget.onNumericSubmit,
            )
          else
            ...question.options.map((option) {
              final isSelected =
                  widget.selectedAnswers.contains(option.letter);
              final isCorrect = correctLetters.contains(option.letter);

              Color tileColor;
              Color borderColor;
              if (widget.submitted) {
                if (isCorrect) {
                  tileColor = AppColors.successSubtle;
                  borderColor = AppColors.success;
                } else if (isSelected && !isCorrect) {
                  tileColor = AppColors.errorSubtle;
                  borderColor = AppColors.error;
                } else {
                  tileColor = isDark ? AppColors.backgroundSubtle : AppColors.lightBackgroundSubtle;
                  borderColor = isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle;
                }
              } else if (isSelected) {
                tileColor = AppColors.accentGlow;
                borderColor = AppColors.borderAccent;
              } else {
                tileColor = isDark ? AppColors.backgroundSubtle : AppColors.lightBackgroundSubtle;
                borderColor = isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle;
              }

              final bool showCorrectPop = widget.submitted && isCorrect;
              final bool showWrongShake = widget.submitted && isSelected && !isCorrect;

              return _AnimatedAnswerOption(
                key: ValueKey('${widget.question.questionId}_${option.letter}'),
                tileColor: tileColor,
                borderColor: borderColor,
                showCorrectPop: showCorrectPop,
                showWrongShake: showWrongShake,
                onTap: widget.onAnswerToggle != null
                    ? () => widget.onAnswerToggle!(option.letter)
                    : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circle indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? (widget.submitted
                                ? (isCorrect ? AppColors.success : AppColors.error)
                                : AppColors.accentPrimary)
                            : (widget.submitted && isCorrect
                                ? AppColors.success
                                : (isDark ? AppColors.backgroundElevated : AppColors.lightBackgroundElevated)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option.letter.replaceAll('.', ''),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: (isSelected || (widget.submitted && isCorrect))
                              ? Colors.white
                              : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.text,
                        style: AppTextStyles.body(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    if (widget.submitted && isCorrect)
                      const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    if (widget.submitted && isSelected && !isCorrect)
                      const Icon(Icons.cancel, color: AppColors.error, size: 20),
                  ],
                ),
              );
            }),
          // Comment after submission
          if (widget.submitted && question.comment.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundElevated : AppColors.lightBackgroundElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explanation',
                    style: AppTextStyles.label(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.comment,
                    style: AppTextStyles.bodySmall(
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildQuestionText(BuildContext context) {
    final text = widget.question.questionText;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final spans = <TextSpan>[];
    int lastEnd = 0;

    final matches = <_TermMatch>[];
    for (final term in _highlightTerms) {
      int start = 0;
      while (true) {
        final idx = text.indexOf(term, start);
        if (idx == -1) break;
        matches.add(_TermMatch(idx, idx + term.length));
        start = idx + term.length;
      }
    }
    matches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in matches) {
      if (match.start < lastEnd) continue;
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.accentLight,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: AppTextStyles.body(
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
        ).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          height: 1.65,
        ),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }

  Color _pointsColor(int points) {
    switch (points) {
      case 5:
        return AppColors.error;
      case 4:
        return AppColors.warning;
      case 3:
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }
}

/// Animated wrapper for answer option cards.
class _AnimatedAnswerOption extends StatefulWidget {
  final Color tileColor;
  final Color borderColor;
  final bool showCorrectPop;
  final bool showWrongShake;
  final VoidCallback? onTap;
  final Widget child;

  const _AnimatedAnswerOption({
    super.key,
    required this.tileColor,
    required this.borderColor,
    required this.showCorrectPop,
    required this.showWrongShake,
    this.onTap,
    required this.child,
  });

  @override
  State<_AnimatedAnswerOption> createState() => _AnimatedAnswerOptionState();
}

class _AnimatedAnswerOptionState extends State<_AnimatedAnswerOption>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<Offset> _shakeAnimation;
  double _tapScale = 1.0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(0.03, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(0.03, 0), end: const Offset(-0.03, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(-0.03, 0), end: const Offset(0.02, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.02, 0), end: const Offset(-0.02, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(-0.02, 0), end: const Offset(0.01, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.01, 0), end: Offset.zero),
          weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void didUpdateWidget(covariant _AnimatedAnswerOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showWrongShake && !oldWidget.showWrongShake) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: widget.onTap != null
            ? (_) => setState(() => _tapScale = 0.97)
            : null,
        onTapUp: widget.onTap != null
            ? (_) {
                setState(() => _tapScale = 1.0);
                widget.onTap!();
              }
            : null,
        onTapCancel: widget.onTap != null
            ? () => setState(() => _tapScale = 1.0)
            : null,
        child: AnimatedScale(
          scale: _tapScale,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.tileColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.borderColor,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    // Correct answer pop animation
    if (widget.showCorrectPop) {
      card = TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.08, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: card,
      );
    }

    // Wrong answer shake animation
    if (widget.showWrongShake) {
      card = AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) => FractionalTranslation(
          translation: _shakeAnimation.value,
          child: child,
        ),
        child: card,
      );
    }

    return card;
  }
}

class _TermMatch {
  final int start;
  final int end;
  _TermMatch(this.start, this.end);
}

// --- Video player for asset videos ---

class _AssetVideoPlayer extends StatefulWidget {
  final String assetPath;
  final VoidCallback? onFirstPlayComplete;

  const _AssetVideoPlayer({
    required this.assetPath,
    this.onFirstPlayComplete,
  });

  @override
  State<_AssetVideoPlayer> createState() => _AssetVideoPlayerState();
}

class _AssetVideoPlayerState extends State<_AssetVideoPlayer> {
  VideoPlayerController? _controller;
  bool _loading = true;
  bool _error = false;

  static const int _maxPlays = 5;
  int _playCount = 0;
  bool _hasNotifiedFirstComplete = false;
  Duration _lastPosition = Duration.zero;

  bool get _replayLimitReached => _playCount >= _maxPlays;
  int get _replaysRemaining => (_maxPlays - _playCount).clamp(0, _maxPlays);

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final byteData = await rootBundle.load(widget.assetPath);
      final tempDir = await getTemporaryDirectory();
      final fileName = p.basename(widget.assetPath);
      final tempFile = File(p.join(tempDir.path, 'dt_videos', fileName));

      if (!await tempFile.exists()) {
        await tempFile.parent.create(recursive: true);
        await tempFile.writeAsBytes(
          byteData.buffer.asUint8List(),
          flush: true,
        );
      }

      final controller = VideoPlayerController.file(tempFile);
      await controller.initialize();
      controller.setLooping(true);
      controller.addListener(_onVideoStateChanged);

      if (mounted) {
        setState(() {
          _controller = controller;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  void _onVideoStateChanged() {
    if (!mounted || _controller == null) return;
    final ctrl = _controller!;
    if (!ctrl.value.isInitialized || ctrl.value.duration <= Duration.zero) {
      return;
    }

    final pos = ctrl.value.position;

    if (pos < _lastPosition - const Duration(milliseconds: 500) &&
        ctrl.value.isPlaying) {
      ctrl.pause();
      ctrl.seekTo(Duration.zero);
      if (mounted) setState(() {});

      if (!_hasNotifiedFirstComplete && _playCount == 1) {
        _hasNotifiedFirstComplete = true;
        widget.onFirstPlayComplete?.call();
      }

      if (_playCount >= _maxPlays) {
        if (mounted) setState(() {});
      }
    }

    _lastPosition = pos;
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundElevated : AppColors.lightBackgroundElevated,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final controller = _controller!;
    final bool canPlay = !_replayLimitReached;
    final bool isPaused = !controller.value.isPlaying;
    final bool showPlayButton = isPaused || _replayLimitReached;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
                GestureDetector(
                  onTap: () {
                    if (_replayLimitReached) return;
                    if (controller.value.isPlaying) {
                      controller.pause();
                      setState(() {});
                    } else {
                      final atStart = controller.value.position <
                          const Duration(milliseconds: 300);
                      if (atStart) {
                        _playCount++;
                        if (_replayLimitReached) {
                          setState(() {});
                          return;
                        }
                      }
                      controller.play();
                      setState(() {});
                    }
                  },
                  child: AnimatedOpacity(
                    opacity: showPlayButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: canPlay
                            ? AppColors.backgroundPrimary.withValues(alpha: 0.6)
                            : AppColors.backgroundPrimary.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        canPlay ? Icons.play_arrow : Icons.block,
                        color: canPlay ? Colors.white : AppColors.error,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: canPlay,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.accentPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(
                Icons.replay,
                size: 16,
                color: canPlay
                    ? (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)
                    : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                canPlay
                    ? 'Replays remaining: $_replaysRemaining'
                    : 'No replays remaining',
                style: AppTextStyles.labelSmall(
                  color: canPlay
                      ? (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)
                      : AppColors.error,
                ).copyWith(
                  fontWeight: canPlay ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Numeric answer field ---

class _NumericAnswerField extends StatefulWidget {
  final bool submitted;
  final String selectedValue;
  final String correctValue;
  final void Function(String)? onSubmit;

  const _NumericAnswerField({
    required this.submitted,
    required this.selectedValue,
    required this.correctValue,
    this.onSubmit,
  });

  @override
  State<_NumericAnswerField> createState() => _NumericAnswerFieldState();
}

class _NumericAnswerFieldState extends State<_NumericAnswerField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.submitted) {
      final isCorrect = widget.selectedValue == widget.correctValue;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your answer: ${widget.selectedValue}',
            style: AppTextStyles.body(
              color: isCorrect ? AppColors.success : AppColors.error,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          if (!isCorrect)
            Text(
              'Correct answer: ${widget.correctValue}',
              style: AppTextStyles.body(color: AppColors.success)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
        ],
      );
    }

    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Enter your answer',
        suffixIcon: IconButton(
          icon: const Icon(Icons.check, color: AppColors.accentLight),
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSubmit?.call(_controller.text.trim());
            }
          },
        ),
      ),
      onSubmitted: (v) {
        if (v.isNotEmpty) widget.onSubmit?.call(v.trim());
      },
    );
  }
}
