// ════════════════════════════════════════════════════════
// coupon_page.dart — 쿠폰함
// 보유 쿠폰 목록 / ← 뒤로가기(홈으로)
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class CouponPage extends StatelessWidget {
  const CouponPage({super.key});

  static const List<_Coupon> _mockCoupons = [
    _Coupon(emoji: '☕', name: '스타벅스 아메리카노', expiry: '2026.07.31', code: 'SBUX-XXXX-1234', used: false),
    _Coupon(emoji: '🎬', name: 'CGV 영화 관람권',    expiry: '2026.08.15', code: 'CGV-XXXX-5678',  used: false),
    _Coupon(emoji: '🎁', name: '네이버페이 1,000원', expiry: '2026.07.10', code: 'NPY-XXXX-9012',  used: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Text('←', style: TextStyle(fontSize: 20, color: AppColors.text, fontWeight: FontWeight.w700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🎟 쿠폰함', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: _mockCoupons.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🎟', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('보유한 쿠폰이 없습니다', style: AppTheme.body.copyWith(color: AppColors.muted)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/shop'),
                  child: const Text('교환소에서 쿠폰 받기 ›', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockCoupons.length,
              itemBuilder: (context, i) => _CouponCard(coupon: _mockCoupons[i]),
            ),
    );
  }
}

class _Coupon {
  final String emoji;
  final String name;
  final String expiry;
  final String code;
  final bool used;

  const _Coupon({required this.emoji, required this.name, required this.expiry, required this.code, required this.used});
}

class _CouponCard extends StatelessWidget {
  final _Coupon coupon;
  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: coupon.used ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: coupon.used ? AppColors.border : AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            // 상단 쿠폰 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(coupon.emoji, style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coupon.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text)),
                      const SizedBox(height: 4),
                      Text('만료: ${coupon.expiry}', style: AppTheme.caption),
                    ],
                  )),
                  if (coupon.used)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      child: const Text('사용완료', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                    ),
                ],
              ),
            ),
            // 쿠폰 코드
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text('코드: ${coupon.code}', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const Spacer(),
                  if (!coupon.used)
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: coupon.code));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('쿠폰 코드가 복사되었습니다!'), duration: Duration(seconds: 2)),
                        );
                      },
                      child: const Text('복사', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
