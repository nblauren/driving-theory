import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display ──────────────────────────────────────────────────
  static TextStyle display({Color color = AppColors.textPrimary}) =>
      GoogleFonts.urbanist(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.56, // -0.02em
        color: color,
      );

  // ── Heading ──────────────────────────────────────────────────
  static TextStyle heading1({Color color = AppColors.textPrimary}) =>
      GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4, // -0.02em
        color: color,
      );

  static TextStyle heading2({Color color = AppColors.textPrimary}) =>
      GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // ── Body ─────────────────────────────────────────────────────
  static TextStyle body({Color color = AppColors.textPrimary}) =>
      GoogleFonts.figtree(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.65,
        color: color,
      );

  static TextStyle bodySmall({Color color = AppColors.textSecondary}) =>
      GoogleFonts.figtree(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.65,
        color: color,
      );

  // ── Label ────────────────────────────────────────────────────
  static TextStyle label({Color color = AppColors.textTertiary}) =>
      GoogleFonts.figtree(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.66, // 0.06em
        color: color,
      );

  static TextStyle labelSmall({Color color = AppColors.textTertiary}) =>
      GoogleFonts.figtree(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6, // 0.06em
        color: color,
      );

  // ── Numbers / Stats ──────────────────────────────────────────
  static TextStyle statLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.urbanist(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64, // -0.02em
        color: color,
      );

  static TextStyle statMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.urbanist(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.44, // -0.02em
        color: color,
      );

  static TextStyle statSmall({Color color = AppColors.textPrimary}) =>
      GoogleFonts.urbanist(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // ── Button ───────────────────────────────────────────────────
  static TextStyle button({Color color = AppColors.textPrimary}) =>
      GoogleFonts.figtree(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
