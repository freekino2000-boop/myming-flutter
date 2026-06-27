// ════════════════════════════════════════════════════════
// quick_action_card.dart — 홈 빠른 액션 섹션
// 출석체크 / 행운뽑기 / 광고보너스
// ════════════════════════════════════════════════════════
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';
import '../../../theme/app_theme.dart';

class QuickActionSection extends StatelessWidget {
  const QuickActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionCard(
          icon: '📅', title: '출석 체크', sub: '+₩10',
          color: AppColors.primary,
          onTap: () => _doAttendance(context),
        )),
        const SizedBox(width: 8),
        Expanded(child: _ActionCard(
          icon: '🎁', title: '행운 뽑기', sub: '최대+₩100',
          color: const Color(0xFFFF6B35),
          onTap: () => _doLuckyBox(context),
        )),
        const SizedBox(width: 8),
        Expanded(child: _ActionCard(
          icon: '📺', title: '광고 보너스', sub: '+₩10',
          color: AppColors.primary,
          onTap: () => _doAdBonus(context),
        )),
      ],
    );
  }

  // ── 출석 체크: 오늘 여부 확인 후 달력 팝업 ──────────────
  void _doAttendance(BuildContext context) {
    final state = context.read<AppState>();
    if (state.canAttendToday) {
      state.doAttendance();
      _showSnack(context, '출석 체크 완료! ₩10 적립 🎉');
    } else {
      _showSnack(context, '오늘 출석 체크를 이미 완료했습니다 ✅');
    }
    _showAttendanceDialog(context, state);
  }

  void _showAttendanceDialog(BuildContext context, AppState state) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // 일=0
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final checkedDays = state.attendanceDates
        .where((d) => d.startsWith('$year-${month.toString().padLeft(2, '0')}'))
        .map((d) => int.parse(d.substring(8, 10)))
        .toSet();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('📅 출석 체크', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$year년 ${month}월 · 총 ${checkedDays.length}일 출석',
                style: AppTheme.caption, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            // 요일 헤더
            Row(children: ['일','월','화','수','목','금','토']
                .map((d) => Expanded(child: Text(d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted))))
                .toList()),
            const SizedBox(height: 6),
            // 날짜 그리드
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 1),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (_, i) {
                if (i < firstWeekday) return const SizedBox.shrink();
                final day = i - firstWeekday + 1;
                final isToday = day == now.day;
                final isChecked = checkedDays.contains(day);
                return Container(
                  decoration: BoxDecoration(
                    color: isChecked ? AppColors.primaryDim : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('$day', style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: isChecked ? AppColors.primary : AppColors.muted)),
                    if (isChecked) const Text('✅', style: TextStyle(fontSize: 9)),
                  ]),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // ── 행운 뽑기: 10~100원 랜덤 보상 ───────────────────────
  void _doLuckyBox(BuildContext context) {
    final luck = Random().nextInt(91) + 10; // 10~100원
    context.read<AppState>().earn('🎁', '행운 뽑기', luck);
    _showSnack(context, '행운 뽑기! ₩$luck 적립 🎲');
  }

  // ── 광고 보너스: +₩10 적립 후 카드뉴스 탭 이동 ───────────
  void _doAdBonus(BuildContext context) {
    final state = context.read<AppState>();
    state.earn('📺', '광고 시청 적립', 10);
    state.switchToCardNewsTab();
    _showSnack(context, '광고 보너스! ₩10 적립 📺');
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.sub,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFC8DCFF)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 3),
            Text(sub, style: AppTheme.caption),
          ],
        ),
      ),
    );
  }
}
