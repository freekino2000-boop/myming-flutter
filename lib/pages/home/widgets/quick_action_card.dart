// ════════════════════════════════════════════════════════
// quick_action_card.dart — 홈 빠른 액션 섹션
// 출석체크 / 행운뽑기 / 광고보너스
// ════════════════════════════════════════════════════════
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/features.dart';
import '../../../models/app_state.dart';
import '../../../theme/app_theme.dart';

class QuickActionSection extends StatelessWidget {
  const QuickActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 활성화된 버튼만 리스트로 구성 (Features 기준)
    final cards = <Widget>[
      if (Features.attendance)
        Expanded(child: _ActionCard(
          icon: '📅', title: '출석 체크', sub: '+₩10',
          color: AppColors.primary,
          onTap: () => _doAttendance(context),
        )),
      if (Features.attendance && (Features.fortune || Features.adBonus))
        const SizedBox(width: 8),
      if (Features.fortune)
        Expanded(child: _ActionCard(
          icon: '🎁', title: '행운 뽑기', sub: '최대+₩50',
          color: const Color(0xFFFF6B35),
          onTap: () => _doLuckyBox(context),
        )),
      if (Features.fortune && Features.adBonus)
        const SizedBox(width: 8),
      if (Features.adBonus)
        Expanded(child: _ActionCard(
          icon: '📺', title: '광고 보너스', sub: '+₩10',
          color: AppColors.primary,
          onTap: () => _doAdBonus(context),
        )),
    ];
    if (cards.isEmpty) return const SizedBox.shrink();
    return Row(children: cards);
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
            Text('$year년 $month월 · 총 ${checkedDays.length}일 출석',
                style: AppTheme.caption, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            // 요일 헤더
            Row(children: ['일','월','화','수','목','금','토']
                .map((d) => Expanded(child: Text(d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted))))
                .toList()),
            const SizedBox(height: 6),
            // 날짜 그리드 (Table로 intrinsic height 문제 회피)
            _buildCalendarTable(firstWeekday, daysInMonth, checkedDays, now.day),
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
  // 달력 그리드를 Table로 구성 (AlertDialog 내 GridView intrinsic height 문제 회피)
  Widget _buildCalendarTable(int firstWeekday, int daysInMonth, Set<int> checkedDays, int today) {
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    return Table(
      children: List.generate(rows, (row) {
        return TableRow(
          children: List.generate(7, (col) {
            final idx = row * 7 + col;
            if (idx < firstWeekday || idx >= firstWeekday + daysInMonth) {
              return const SizedBox(height: 34);
            }
            final day = idx - firstWeekday + 1;
            final isToday = day == today;
            final isChecked = checkedDays.contains(day);
            return Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                height: 32,
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
                  if (isChecked) const Text('✅', style: TextStyle(fontSize: 8)),
                ]),
              ),
            );
          }),
        );
      }),
    );
  }

  void _doLuckyBox(BuildContext context) {
    final luck = Random().nextInt(41) + 10; // 10~50원 (HTML 기준)
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
