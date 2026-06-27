// ════════════════════════════════════════════════════════
// main.dart — 앱 진입점 및 전체 라우트 정의
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'theme/app_theme.dart';
import 'pages/main_shell.dart';
import 'pages/shop/shop_page.dart';
import 'pages/offerwall/offerwall_page.dart';
import 'pages/coupon/coupon_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/game/game_select_page.dart';
import 'pages/game/global_rank_page.dart';
import 'pages/bill/bill_page.dart';
import 'pages/fortune/fortune_page.dart';
import 'pages/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final state = AppState();
  await state.loadFromPrefs();

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const MyMingApp(),
    ),
  );
}

class MyMingApp extends StatelessWidget {
  const MyMingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '마이밍',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/login',
      // ── 전체 라우트 테이블 ────────────────────────────────
      routes: {
        '/login':       (_) => const LoginPage(),     // 로그인 (첫 진입)
        '/':            (_) => const MainShell(),     // 하단탭 쉘 (홈/카드뉴스/게임)
        '/shop':        (_) => const ShopPage(),      // 교환소
        '/offerwall':   (_) => const OfferwallPage(), // 고정비 절감 미션
        '/coupon':      (_) => const CouponPage(),    // 쿠폰함
        '/profile':     (_) => const ProfilePage(),   // 내 정보
        '/game-select': (_) => const GameSelectPage(),// 게임 선택
        '/rank':        (_) => const GlobalRankPage(),// 전체 랭킹
        '/bill':        (_) => const BillPage(),      // 고정비 관리
        '/fortune':     (_) => const FortunePage(),   // 오늘의 운세
      },
    );
  }
}
