// ════════════════════════════════════════════════════════
// home_page.dart — 홈 화면
// 만보기 카드 / 빠른 액션 / 절감머니내역
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pedometer/pedometer.dart';

import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import 'widgets/pedometer_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/bill_history_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<StepCount> _stepCountStream;
  int _initialSteps = 0;
  bool _pedometerStarted = false;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  void _initPedometer() {
    // pedometer 패키지: 실기기에서만 동작
    // Info.plist (iOS): NSMotionUsageDescription 필요
    // AndroidManifest (Android): ACTIVITY_RECOGNITION 권한 필요
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen((StepCount event) {
      final state = context.read<AppState>();
      if (!_pedometerStarted) {
        _initialSteps = event.steps;
        _pedometerStarted = true;
      }
      final todaySteps = event.steps - _initialSteps;
      state.steps = todaySteps;
      state.notifyListeners();
    }).onError((error) {
      debugPrint('Pedometer error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── 앱바 ────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              title: Row(
                children: [
                  Text('마이밍', style: AppTheme.headline2.copyWith(color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Text('만보기 리워드', style: AppTheme.caption),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryDim,
                    child: Text('👤', style: TextStyle(fontSize: 14)),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/shop'),
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🎁', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── 만보기 카드 ──────────────────────────
                  const PedometerCard(),
                  const SizedBox(height: 12),

                  // ── 절감머니 내역 진입 버튼 ──────────────
                  const BillHistoryEntry(),
                  const SizedBox(height: 12),

                  // ── 빠른 액션 (출석/행운뽑기/광고보너스) ──
                  const QuickActionSection(),
                  const SizedBox(height: 12),

                  // ── 오늘의 고정비 절감 미션 요약 ──────────
                  _MissionSummaryCard(),
                  const SizedBox(height: 12),

                  // ── 빠른 메뉴 그리드 ────────────────────
                  _QuickMenuGrid(),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 미션 요약 카드 (홈 하단) ─────────────────────────────
class _MissionSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🎯 오늘의 미션', style: AppTheme.headline2),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/offerwall'),
                child: Text('전체보기 ›', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MissionItem(icon: '👟', title: '만보 달성 (10,000보)', reward: 100, done: false),
          const SizedBox(height: 8),
          _MissionItem(icon: '📰', title: '카드뉴스 3건 읽기', reward: 30, done: false),
          const SizedBox(height: 8),
          _MissionItem(icon: '📅', title: '출석 체크', reward: 10, done: false),
        ],
      ),
    );
  }
}

// ── 빠른 메뉴 그리드 ─────────────────────────────────────
class _QuickMenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuEntry('📋', '고정비 관리', '/bill'),
      _MenuEntry('🔮', '오늘의 운세', '/fortune'),
      _MenuEntry('🎯', '절감 미션',   '/offerwall'),
      _MenuEntry('🎟', '쿠폰함',      '/coupon'),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: menus.map((m) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, m.route),
        child: Container(
          decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(m.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(m.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary), textAlign: TextAlign.center),
          ]),
        ),
      )).toList(),
    );
  }
}

class _MenuEntry {
  final String icon, label, route;
  const _MenuEntry(this.icon, this.label, this.route);
}

class _MissionItem extends StatelessWidget {
  final String icon;
  final String title;
  final int reward;
  final bool done;

  const _MissionItem({required this.icon, required this.title, required this.reward, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: AppTheme.body.copyWith(
          decoration: done ? TextDecoration.lineThrough : null,
          color: done ? AppColors.muted : AppColors.text,
        ))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: done ? Colors.grey.shade100 : AppColors.primaryDim,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            done ? '완료' : '+₩$reward',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: done ? AppColors.muted : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
