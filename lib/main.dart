// ════════════════════════════════════════════════════════
// main.dart — 앱 진입점 및 전체 라우트 정의
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;

import 'config/features.dart';
import 'services/ad_service.dart';
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
import 'pages/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await MobileAds.instance.initialize();
  AdService.instance.loadRewardedAd(); // 보상형 광고 미리 로드

  final state = AppState();
  await state.loadFromPrefs();

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const MyMingApp(),
    ),
  );
}

class MyMingApp extends StatefulWidget {
  const MyMingApp({super.key});
  @override
  State<MyMingApp> createState() => _MyMingAppState();
}

class _MyMingAppState extends State<MyMingApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().startSession();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<AppState>().pauseSession();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final s = context.read<AppState>();
    if (state == AppLifecycleState.resumed) {
      s.startSession();
    } else if (state == AppLifecycleState.paused) {
      s.pauseSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '마이밍',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(overscroll: false),
      // 시스템 폰트 스케일이 커져도 레이아웃이 깨지지 않도록 최대 1.2배 제한
      builder: (ctx, child) {
        final mq = MediaQuery.of(ctx);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },
      initialRoute: '/splash',
      // ── 전체 라우트 테이블 ────────────────────────────────
      // 기능 활성화 여부는 features.dart에서 제어합니다.
      routes: {
        '/splash':   (_) => const SplashPage(),   // 스플래시 (첫 진입) — 항상 활성
        '/login':    (_) => const LoginPage(),    // 로그인 — 항상 활성
        '/':         (_) => const MainShell(),    // 하단탭 쉘 — 항상 활성
        '/profile':  (_) => const ProfilePage(),  // 내 정보 — 항상 활성

        if (Features.shop)
          '/shop':      (_) => const ShopPage(),      // 🎁 교환소
        if (Features.offerwall)
          '/offerwall': (_) => const OfferwallPage(), // 💡 고정비 절감 미션
        if (Features.coupon)
          '/coupon':    (_) => const CouponPage(),    // 🎫 쿠폰함
        if (Features.bill)
          '/bill':      (_) => const BillPage(),      // 📋 고정비 관리
        if (Features.fortune)
          '/fortune':   (_) => const FortunePage(),   // 🎁 행운 뽑기
        if (Features.game) ...{
          '/game-select': (_) => const GameSelectPage(), // 🎮 게임 선택
          if (Features.rank)
            '/rank':    (_) => const GlobalRankPage(),   // 🏆 전체 랭킹
        },
      },
    );
  }
}
