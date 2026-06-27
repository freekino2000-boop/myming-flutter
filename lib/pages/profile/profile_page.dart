// ════════════════════════════════════════════════════════
// profile_page.dart — 내 정보 페이지
// 프로필 / 적립금 요약 / 설정 항목
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final wallet = state.walletAmount.floor();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('👤 내 정보', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 프로필 카드
            Container(
              decoration: AppTheme.cardDecoration,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryDim,
                    child: const Text('😊', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('마이밍 유저', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text('마이밍으로 월세를 아껴요 🏠', style: AppTheme.caption),
                    ],
                  )),
                  TextButton(
                    onPressed: () {},
                    child: const Text('편집', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 적립금 요약
            Container(
              decoration: AppTheme.cardDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💰 적립금 현황', style: AppTheme.headline2),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _StatTile(label: '총 적립금', value: '₩${_fmt(wallet)}')),
                    const SizedBox(width: 8),
                    Expanded(child: _StatTile(label: '오늘 걸음수', value: '${_fmt(state.steps)} 보')),
                    const SizedBox(width: 8),
                    Expanded(child: _StatTile(label: '월세 절감', value: '₩${_fmt(wallet)}')),
                  ]),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/shop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('📋 절감머니 내역 · 교환소', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 최근 적립 내역
            Container(
              decoration: AppTheme.cardDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📋 최근 내역', style: AppTheme.headline2),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/shop'),
                        child: const Text('전체보기 ›', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...state.ledger.take(5).map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Text(entry.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(entry.label, style: AppTheme.body.copyWith(fontSize: 13))),
                      Text(
                        entry.type == 'spend' ? '-₩${entry.amount}' : '+₩${entry.amount}',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13,
                          color: entry.type == 'spend' ? Colors.redAccent : AppColors.primary),
                      ),
                    ]),
                  )).toList(),
                  if (state.ledger.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('아직 내역이 없습니다', style: AppTheme.caption)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 설정 항목
            Container(
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  _SettingItem(icon: '🔔', title: '알림 설정',     onTap: () {}),
                  _SettingItem(icon: '🔒', title: '개인정보 처리방침', onTap: () {}),
                  _SettingItem(icon: '📄', title: '이용약관',       onTap: () {}),
                  _SettingItem(icon: '🆘', title: '고객센터',       onTap: () {}),
                  _SettingItem(icon: '📱', title: '앱 버전 1.0.0', onTap: null, trailing: '최신'),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(label, style: AppTheme.caption.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
      ]),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;
  final String? trailing;

  const _SettingItem({required this.icon, required this.title, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTheme.body)),
          Text(trailing ?? '›', style: TextStyle(fontSize: trailing != null ? 12 : 18, color: AppColors.muted, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
