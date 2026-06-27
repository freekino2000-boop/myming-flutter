// ════════════════════════════════════════════════════════
// bill_model.dart — 고정비 청구서 데이터 모델
// 월세/관리비/전기/가스/인터넷/통신 등
// ════════════════════════════════════════════════════════

enum BillType { rent, manage, electric, gas, internet, mobile, water, insurance, other }

extension BillTypeExt on BillType {
  String get label {
    switch (this) {
      case BillType.rent:      return '🏠 월세';
      case BillType.manage:    return '🏢 관리비';
      case BillType.electric:  return '⚡ 전기';
      case BillType.gas:       return '🔥 가스';
      case BillType.internet:  return '📡 인터넷';
      case BillType.mobile:    return '📱 통신';
      case BillType.water:     return '💧 수도';
      case BillType.insurance: return '🛡 보험';
      case BillType.other:     return '📄 기타';
    }
  }

  String get icon {
    switch (this) {
      case BillType.rent:      return '🏠';
      case BillType.manage:    return '🏢';
      case BillType.electric:  return '⚡';
      case BillType.gas:       return '🔥';
      case BillType.internet:  return '📡';
      case BillType.mobile:    return '📱';
      case BillType.water:     return '💧';
      case BillType.insurance: return '🛡';
      case BillType.other:     return '📄';
    }
  }
}

class Bill {
  final String id;
  BillType type;
  String name;       // 사용자 지정 이름
  int amount;        // 월 납부액
  int dayOfMonth;    // 납부일 (1~28)
  bool autopay;      // 자동이체 여부
  int? savedAmount;  // 마이밍으로 절감된 금액

  Bill({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    required this.dayOfMonth,
    this.autopay = false,
    this.savedAmount,
  });

  // 납부 D-day 계산
  int get dday {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, dayOfMonth);
    final diff = target.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff >= 0 ? diff : DateTime(now.year, now.month + 1, dayOfMonth)
        .difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  String get ddayLabel {
    final d = dday;
    if (d == 0) return 'D-DAY';
    return 'D-$d';
  }
}

// 목데이터
final List<Bill> kMockBills = [
  Bill(id: 'b1', type: BillType.rent,     name: '월세',      amount: 550000, dayOfMonth: 1,  autopay: true),
  Bill(id: 'b2', type: BillType.manage,   name: '관리비',    amount: 85000,  dayOfMonth: 5,  autopay: false),
  Bill(id: 'b3', type: BillType.electric, name: '전기요금',  amount: 38000,  dayOfMonth: 15, autopay: true),
  Bill(id: 'b4', type: BillType.mobile,   name: '통신요금',  amount: 55000,  dayOfMonth: 18, autopay: true),
  Bill(id: 'b5', type: BillType.internet, name: '인터넷',    amount: 33000,  dayOfMonth: 20, autopay: true),
  Bill(id: 'b6', type: BillType.gas,      name: '가스요금',  amount: 24000,  dayOfMonth: 25, autopay: false),
];
