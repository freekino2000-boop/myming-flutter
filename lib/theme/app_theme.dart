// ════════════════════════════════════════════════════════
// app_theme.dart — 마이밍 앱 전역 컬러 / 텍스트 스타일
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 브랜드 메인
  static const primary   = Color(0xFF2C7FFF);
  static const primaryDim = Color(0x1A2C7FFF);   // 10% opacity

  // 배경
  static const bg        = Color(0xFFFFFFFF);
  static const surface   = Color(0xFFF0F5FF);
  static const card      = Color(0xFFFFFFFF);

  // 테두리
  static const border    = Color(0xFFC8DCFF);

  // 텍스트
  static const text      = Color(0xFF1A1A1A);
  static const muted     = Color(0xFF8B95A1);

  // 카테고리
  static const economy   = Color(0xFF2C7FFF);
  static const realty    = Color(0xFFE06C00);
  static const issue     = Color(0xFFD03030);
  static const tenancy   = Color(0xFF00875A);

  // 게임 카드 포인트 컬러
  static const gameBrick  = Color(0xFFFF6B35);
  static const gameJump   = Color(0xFF2C7FFF);
  static const gameCatch  = Color(0xFFF5A623);
  static const gameSnake  = Color(0xFF27AE60);
  static const gameTap    = Color(0xFF2C7FFF);
  static const gameQuiz   = Color(0xFFFF9F43);
  static const gameMemory = Color(0xFF8E44AD);
  static const gameReflex = Color(0xFF00A8B5);

  // 교환소 헤더 배경 (그라데이션)
  static const shopGradStart = Color(0xFF1A4FA8);
  static const shopGradEnd   = Color(0xFF2C7FFF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: GoogleFonts.notoSansKrTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.card,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.notoSansKr(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: AppColors.text,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),
  );

  // ── 공통 텍스트 스타일 ──────────────────────────────────────
  static TextStyle headline1 = GoogleFonts.notoSansKr(
    fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text,
  );
  static TextStyle headline2 = GoogleFonts.notoSansKr(
    fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text,
  );
  static TextStyle body = GoogleFonts.notoSansKr(
    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.text,
  );
  static TextStyle caption = GoogleFonts.notoSansKr(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.muted,
  );
  static TextStyle labelBold = GoogleFonts.notoSansKr(
    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text,
  );
  static TextStyle mono = const TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text,
  );

  // ── 공통 데코레이션 ────────────────────────────────────────
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
    ],
  );

  static BoxDecoration surfaceDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.border),
  );
}
