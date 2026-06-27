// ════════════════════════════════════════════════════════
// bill_history_entry.dart — 절감머니 내역 진입 버튼
// 탭 시 교환소(ShopPage)로 이동
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';
import '../../../theme/app_theme.dart';

class BillHistoryEntry extends StatelessWidget {
  const BillHistoryEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<AppState>().walletAmount.floor();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/shop'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.cardDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📋 절감머니 내역 · 교환소',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
            Row(
              children: [
                Text('₩${wallet.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const SizedBox(width: 4),
                const Text('›', style: TextStyle(fontSize: 18, color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
