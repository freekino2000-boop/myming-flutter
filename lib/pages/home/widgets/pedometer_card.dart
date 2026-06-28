// ════════════════════════════════════════════════════════
// pedometer_card.dart — 만보기 카드 위젯
// 걸음수 / 월세 절감 진행바 / 만보 부스트 버튼
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';
import '../../../theme/app_theme.dart';

class PedometerCard extends StatelessWidget {
  const PedometerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final steps = state.steps;
    final wallet = state.walletAmount.floor();
    const goalSteps = 10000;
    final progress = (steps / goalSteps).clamp(0.0, 1.0);

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('걸을수록 월세가 내려가요', style: AppTheme.caption),
                  const SizedBox(height: 2),
                  Text('🏠 월세 절감 만보기', style: AppTheme.headline2),
                ],
              ),
              // 걸음수 뱃지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_fmt(steps)} 보',
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14, fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 목표 진행바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('오늘 목표', style: AppTheme.caption),
              Text('${_fmt(steps)} / ${_fmt(goalSteps)} 보', style: AppTheme.caption),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),

          const SizedBox(height: 16),

          // 적립 현황
          Row(
            children: [
              Expanded(child: _StatBox(label: '적립 금액', value: '₩${_fmt(wallet)}')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: '월세 절감', value: '₩${_fmt(wallet)}', accent: true)),
            ],
          ),

          const SizedBox(height: 14),

          // 액션 버튼 행
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/shop'),
                  icon: const Text('🚀'),
                  label: Text(
                    state.hasManhwaBoost ? '만보 부스트 보유 중 ✓' : '만보 부스트 구매',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.hasManhwaBoost ? Colors.grey.shade300 : AppColors.primary,
                    foregroundColor: state.hasManhwaBoost ? AppColors.muted : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/game-select'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: const Text('🎮 게임', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _StatBox({required this.label, required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: accent ? AppColors.primaryDim : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.caption.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(
            fontFamily: 'RobotoMono', fontSize: 15,
            fontWeight: FontWeight.w900, color: AppColors.primary,
          )),
        ],
      ),
    );
  }
}
