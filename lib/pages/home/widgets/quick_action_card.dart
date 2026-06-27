// ════════════════════════════════════════════════════════
// quick_action_card.dart — 홈 빠른 액션 섹션
// 출석체크 / 행운뽑기 / 광고보너스
// ════════════════════════════════════════════════════════
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
          onTap: () => _doAttendance(context),
        )),
        const SizedBox(width: 8),
        Expanded(child: _ActionCard(
          icon: '🎁', title: '행운 뽑기', sub: '최대+₩50',
          onTap: () => _doLuckyBox(context),
        )),
        const SizedBox(width: 8),
        Expanded(child: _ActionCard(
          icon: '📺', title: '광고 보너스', sub: '+₩10',
          onTap: () => _doAdBonus(context),
        )),
      ],
    );
  }

  void _doAttendance(BuildContext context) {
    final state = context.read<AppState>();
    if (!state.canAttendToday) {
      _showSnack(context, '오늘 출석 체크를 이미 완료했습니다 ✅');
      return;
    }
    state.doAttendance();
    _showSnack(context, '출석 체크 완료! ₩10 적립 🎉');
  }

  void _doLuckyBox(BuildContext context) {
    // TODO: 광고 시청 후 랜덤 보상 (₩10~₩50)
    final state = context.read<AppState>();
    state.earn('🎁', '행운 뽑기', 20);
    _showSnack(context, '행운 뽑기! ₩20 적립 🎲');
  }

  void _doAdBonus(BuildContext context) {
    // TODO: 광고 SDK 연동 후 콜백에서 earn() 호출
    final state = context.read<AppState>();
    state.earn('📺', '광고 시청 적립', 10);
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
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 3),
            Text(sub, style: AppTheme.caption),
          ],
        ),
      ),
    );
  }
}
