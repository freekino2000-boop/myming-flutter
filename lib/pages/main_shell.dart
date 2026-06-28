// ════════════════════════════════════════════════════════
// main_shell.dart — 하단 탭 네비게이션 쉘
//
// 탭 구성은 features.dart에서 제어합니다.
//   Features.cardNews = true  → 카드뉴스 탭 표시
//   Features.game     = true  → 게임 탭 표시
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/features.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'home/home_page.dart';
import 'card_news/card_news_page.dart';
import 'game/game_select_page.dart';

// 탭 한 항목을 나타내는 내부 데이터 구조
class _TabItem {
  final String icon;
  final String label;
  final Widget page;
  const _TabItem({required this.icon, required this.label, required this.page});
}

// Features 플래그에 따라 활성화된 탭 목록을 반환
List<_TabItem> _buildTabs() => [
  const _TabItem(icon: '🏠', label: '홈',      page: HomePage()),
  if (Features.cardNews)
    const _TabItem(icon: '📰', label: '카드뉴스', page: CardNewsPage()),
  if (Features.game)
    const _TabItem(icon: '🎮', label: '게임',     page: GameSelectPage(isInTab: true)),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final List<_TabItem> _tabs;
  int _currentIndex = 0;
  int _prevTabTrigger = 0;

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
  }

  // 카드뉴스 탭으로 이동 요청 처리 (AppState.switchToCardNewsTab)
  void _handleCardNewsJump(int trigger) {
    if (!Features.cardNews) return;
    final cardNewsIndex = _tabs.indexWhere((t) => t.label == '카드뉴스');
    if (cardNewsIndex == -1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _currentIndex = cardNewsIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trigger = context.watch<AppState>().cardNewsTabTrigger;
    if (trigger != _prevTabTrigger) {
      _prevTabTrigger = trigger;
      _handleCardNewsJump(trigger);
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((t) => t.page).toList(),
      ),
      bottomNavigationBar: _BottomNav(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── 하단 네비게이션 바 ────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.tabs, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: tabs.asMap().entries.map((e) => _NavItem(
              icon:    e.value.icon,
              label:   e.value.label,
              index:   e.key,
              current: currentIndex,
              onTap:   onTap,
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon, required this.label,
    required this.index, required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
