import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard dark surface card.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundCard : AppColors.lightBackgroundCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle,
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) return card;

    return _TapScaleWrapper(
      onTap: onTap!,
      child: card,
    );
  }
}

/// Card with accent glow gradient — for readiness indicator and featured items.
class AccentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AccentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentGlow,
            isDark ? Colors.transparent : AppColors.lightBackgroundCard,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderAccent),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) return card;

    return _TapScaleWrapper(
      onTap: onTap!,
      child: card,
    );
  }
}

/// For secondary items, answer options (default state).
class SubtleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const SubtleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? AppColors.backgroundSubtle : AppColors.lightBackgroundSubtle),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor ??
              (isDark ? AppColors.borderSubtle : AppColors.lightBorderSubtle),
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) return card;

    return _TapScaleWrapper(
      onTap: onTap!,
      child: card,
    );
  }
}

/// Wraps a child with scale(0.97) on press with 80ms animation.
class _TapScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapScaleWrapper({required this.child, required this.onTap});

  @override
  State<_TapScaleWrapper> createState() => _TapScaleWrapperState();
}

class _TapScaleWrapperState extends State<_TapScaleWrapper> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
