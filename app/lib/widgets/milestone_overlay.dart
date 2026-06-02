import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/milestone_provider.dart';

Future<void> showMilestoneOverlay(
  BuildContext context,
  Milestone milestone,
) async {
  final info = milestoneInfoMap[milestone];
  if (info == null) return;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _MilestoneDialog(info: info),
  );
}

Future<void> showMilestoneQueue(
  BuildContext context,
  List<Milestone> milestones,
) async {
  for (final m in milestones) {
    if (!context.mounted) return;
    await showMilestoneOverlay(context, m);
  }
}

class _MilestoneDialog extends StatefulWidget {
  final MilestoneInfo info;
  const _MilestoneDialog({required this.info});

  @override
  State<_MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<_MilestoneDialog> {
  late final ConfettiController _confettiController;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 40),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundCard : AppColors.lightBackgroundCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.accentPrimary),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.info.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.info.title,
                      style: AppTextStyles.statMedium(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.info.message,
                      style: AppTextStyles.body(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 30,
          maxBlastForce: 20,
          minBlastForce: 5,
          emissionFrequency: 0.05,
          gravity: 0.2,
          colors: const [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.purple,
          ],
        ),
      ],
    );
  }
}
