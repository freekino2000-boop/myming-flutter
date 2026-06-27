// ════════════════════════════════════════════════════════
// bill_page.dart — 고정비 관리 (청구서 목록/등록/납부현황)
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/bill_model.dart';
import '../../theme/app_theme.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});
  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final List<Bill> _bills = List.from(kMockBills);
  int _tabIndex = 0; // 0=전체, 1=이번달, 2=내역

  int get _totalMonthly => _bills.fold(0, (s, b) => s + b.amount);

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<AppState>().walletAmount.floor();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.text), onPressed: () => Navigator.pop(context)),
        title: const Text('📋 고정비 관리', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppColors.primary), onPressed: () => _showAddBillSheet(context)),
        ],
      ),
      body: Column(
        children: [
          // 월간 요약 카드
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A3A6B), AppColors.primary]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('이번 달 총 고정비', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('₩${_fmt(_totalMonthly)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('마이밍 절감액', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('₩${_fmt(wallet)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    ]),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (wallet / _totalMonthly).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('절감 진행률 ${((wallet / _totalMonthly) * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  Text('목표 ₩${_fmt(_totalMonthly)}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ]),
              ],
            ),
          ),

          // 탭
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              _TabBtn(label: '전체 청구서', active: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
              const SizedBox(width: 8),
              _TabBtn(label: '이번 달 납부', active: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
              const SizedBox(width: 8),
              _TabBtn(label: '납부 내역', active: _tabIndex == 2, onTap: () => setState(() => _tabIndex = 2)),
            ]),
          ),

          const SizedBox(height: 4),

          // 청구서 목록
          Expanded(
            child: _tabIndex == 2
                ? _LedgerTab()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: _bills.length,
                    itemBuilder: (context, i) => _BillCard(
                      bill: _bills[i],
                      wallet: wallet,
                      onApply: () => _applyWallet(_bills[i]),
                      onEdit: () => _showEditSheet(context, _bills[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('청구서 추가', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _applyWallet(Bill bill) {
    final state = context.read<AppState>();
    if (state.walletAmount < bill.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('적립금이 부족합니다. 더 걷고 미션을 완료해 모아보세요! 👟')));
      return;
    }
    state.spend(bill.amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${bill.name} ₩${_fmt(bill.amount)} 납부 완료! 🎉')));
  }

  void _showAddBillSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BillFormSheet(onSave: (bill) => setState(() => _bills.add(bill))),
    );
  }

  void _showEditSheet(BuildContext context, Bill bill) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BillFormSheet(existingBill: bill, onSave: (_) => setState(() {})),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ── 청구서 카드 ───────────────────────────────────────────
class _BillCard extends StatelessWidget {
  final Bill bill;
  final int wallet;
  final VoidCallback onApply;
  final VoidCallback onEdit;

  const _BillCard({required this.bill, required this.wallet, required this.onApply, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final canPay = wallet >= bill.amount;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(bill.type.icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(bill.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text)),
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: bill.dday == 0 ? const Color(0xFFFFEBEB) : AppColors.primaryDim, borderRadius: BorderRadius.circular(6)),
                    child: Text(bill.ddayLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: bill.dday == 0 ? Colors.red : AppColors.primary))),
                  if (bill.autopay) ...[const SizedBox(width: 4), const Text('자동이체', style: TextStyle(fontSize: 9, color: AppColors.muted))],
                ]),
                const SizedBox(height: 2),
                Text('${bill.dayOfMonth}일 납부 · 월 ₩${_fmt(bill.amount)}', style: AppTheme.caption),
              ],
            )),
            Column(children: [
              TextButton(
                onPressed: onApply,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: canPay ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(canPay ? '차감 납부' : '잔액 부족',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: canPay ? Colors.white : AppColors.muted)),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('수정', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ── 납부 내역 탭 ──────────────────────────────────────────
class _LedgerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = context.watch<AppState>().ledger.where((e) => e.type == 'spend').toList();
    if (entries.isEmpty) return Center(child: Text('납부 내역이 없습니다', style: AppTheme.caption));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.cardDecoration,
          child: Row(children: [
            Text(e.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(e.time, style: AppTheme.caption),
            ])),
            Text('-₩${e.amount}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.redAccent)),
          ]),
        );
      },
    );
  }
}

// ── 청구서 추가/수정 시트 ──────────────────────────────────
class _BillFormSheet extends StatefulWidget {
  final Bill? existingBill;
  final void Function(Bill) onSave;
  const _BillFormSheet({this.existingBill, required this.onSave});
  @override
  State<_BillFormSheet> createState() => _BillFormSheetState();
}

class _BillFormSheetState extends State<_BillFormSheet> {
  late BillType _type;
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late int _day;
  late bool _auto;

  @override
  void initState() {
    super.initState();
    final b = widget.existingBill;
    _type   = b?.type ?? BillType.rent;
    _nameCtrl   = TextEditingController(text: b?.name ?? '');
    _amountCtrl = TextEditingController(text: b != null ? '${b.amount}' : '');
    _day    = b?.dayOfMonth ?? 1;
    _auto   = b?.autopay ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existingBill == null ? '청구서 추가' : '청구서 수정',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            // 종류
            Wrap(spacing: 8, children: BillType.values.map((t) => GestureDetector(
              onTap: () => setState(() { _type = t; _nameCtrl.text = t.label.replaceFirst(RegExp(r'^. '), ''); }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _type == t ? AppColors.primaryDim : AppColors.surface,
                  border: Border.all(color: _type == t ? AppColors.primary : AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(t.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _type == t ? AppColors.primary : AppColors.muted)),
              ),
            )).toList()),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: '항목명', border: OutlineInputBorder()), style: const TextStyle(fontSize: 13))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '월 납부액 (원)', border: OutlineInputBorder()), style: const TextStyle(fontSize: 13))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Text('납부일: ', style: TextStyle(fontSize: 13)),
              DropdownButton<int>(
                value: _day,
                items: List.generate(28, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}일'))),
                onChanged: (v) => setState(() => _day = v!),
              ),
              const Spacer(),
              const Text('자동이체', style: TextStyle(fontSize: 13)),
              Switch(value: _auto, onChanged: (v) => setState(() => _auto = v), activeColor: AppColors.primary),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final bill = widget.existingBill ?? Bill(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: _type, name: _nameCtrl.text,
                    amount: int.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0,
                    dayOfMonth: _day, autopay: _auto,
                  );
                  if (widget.existingBill != null) {
                    bill..type = _type ..name = _nameCtrl.text
                        ..amount = int.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0
                        ..dayOfMonth = _day ..autopay = _auto;
                  }
                  widget.onSave(bill);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(widget.existingBill == null ? '추가' : '저장', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDim : Colors.transparent,
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? AppColors.primary : AppColors.muted)),
      ),
    );
  }
}
