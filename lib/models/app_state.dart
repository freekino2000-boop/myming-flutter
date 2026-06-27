// ════════════════════════════════════════════════════════
// app_state.dart — 전역 앱 상태 (ChangeNotifier)
// 만보기 걸음수, 지갑 잔액, 보유 아이템, 미션 진행 상태
// ════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── 원장(Ledger) 항목 모델 ────────────────────────────────
class LedgerEntry {
  final String icon;
  final String name;
  final int amount;
  final String type;   // 'earn' | 'spend'
  final String time;

  const LedgerEntry({
    required this.icon,
    required this.name,
    required this.amount,
    required this.type,
    required this.time,
  });

  String get label => name;
}

// ── 전역 상태 ─────────────────────────────────────────────
class AppState extends ChangeNotifier {
  // 만보기
  int steps = 0;

  // 지갑
  double walletAmount = 0;

  // 아이템 보유 여부
  bool hasManhwaBoost = false;   // 만보 부스트 (1.5배)
  bool hasSpeed2x     = false;   // 속도 2배
  bool hasSpeed5x     = false;   // 속도 5배
  bool hasAutoCollect = false;   // 자동 수집

  // 카드뉴스 미션
  int  cnReadCount    = 0;
  bool cnMissionDone  = false;

  // 원장 내역
  List<LedgerEntry> ledger = [];

  // 출석 체크 (오늘 완료 여부)
  String? lastAttendanceDate;

  // ── 앱 체류 시간 추적 ─────────────────────────────────────
  String?   firstAccessDate;       // 최초 접속일 (YYYY-MM-DD)
  int       totalSecondsInApp = 0; // 누적 체류 초 (SharedPrefs 저장)
  DateTime? _sessionStart;         // 현재 세션 시작 (런타임만)

  // ── 걸음수 추가 (만보 부스트 적용) ────────────────────────
  void addSteps(int count) {
    steps += count;
    final rate = hasManhwaBoost ? 0.015 : 0.01;
    walletAmount += count * rate;
    addLedger('👟', '걷기 적립', (count * rate).ceil(), 'earn');
    notifyListeners();
    saveToPrefs();
  }

  // ── 원장 추가 ────────────────────────────────────────────
  void addLedger(String icon, String name, int amount, String type) {
    final now = DateTime.now();
    ledger.insert(0, LedgerEntry(
      icon: icon, name: name, amount: amount, type: type,
      time: '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
    ));
    if (ledger.length > 100) ledger.removeLast();
  }

  // ── 보상 적립 ────────────────────────────────────────────
  void earn(String icon, String name, int amount) {
    walletAmount += amount;
    addLedger(icon, name, amount, 'earn');
    notifyListeners();
    saveToPrefs();
  }

  // ── 카드뉴스 기사 읽기 ────────────────────────────────────
  void readCNArticle() {
    if (cnMissionDone) return;
    cnReadCount++;
    walletAmount += 10;
    addLedger('📰', '기사 읽기 보상', 10, 'earn');
    if (cnReadCount >= 3) {
      walletAmount += 30;
      addLedger('🎯', '카드뉴스 미션 완료', 30, 'earn');
      cnMissionDone = true;
    }
    notifyListeners();
    saveToPrefs();
  }

  // ── 지출 (교환소 상품 구매) ──────────────────────────────
  void spend(int amount) {
    if (walletAmount < amount) return;
    walletAmount -= amount;
    addLedger('🛍', '교환소 구매', amount, 'spend');
    notifyListeners();
    saveToPrefs();
  }

  // ── 부스터 아이템 구매 ───────────────────────────────────
  void buyBooster(String effect, String name, int price) {
    if (walletAmount < price) return;
    walletAmount -= price;
    switch (effect) {
      case 'manhwaBoost': hasManhwaBoost = true; break;
      case 'speed2x':     hasSpeed2x     = true; break;
      case 'speed5x':     hasSpeed5x     = true; break;
      case 'autoCollect': hasAutoCollect = true; break;
    }
    addLedger('🛍', '$name 구매', price, 'spend');
    notifyListeners();
    saveToPrefs();
  }

  // ── 세션 시작 (앱 포그라운드 진입 시) ─────────────────────
  void startSession() {
    firstAccessDate ??= DateTime.now().toIso8601String().substring(0, 10);
    _sessionStart   ??= DateTime.now();
    saveToPrefs();
  }

  // ── 세션 일시 중단 (백그라운드 전환 시) ────────────────────
  void pauseSession() {
    if (_sessionStart != null) {
      totalSecondsInApp += DateTime.now().difference(_sessionStart!).inSeconds;
      _sessionStart = null;
      saveToPrefs();
    }
  }

  int get currentSessionSeconds =>
      _sessionStart == null ? 0 : DateTime.now().difference(_sessionStart!).inSeconds;

  int get totalSecondsWithCurrent => totalSecondsInApp + currentSessionSeconds;

  // ── 출석 체크 ────────────────────────────────────────────
  bool get canAttendToday {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastAttendanceDate != today;
  }

  void doAttendance() {
    if (!canAttendToday) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    lastAttendanceDate = today;
    earn('📅', '출석 체크', 10);
  }

  // ── SharedPreferences 영속화 ─────────────────────────────
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    steps              = prefs.getInt('steps') ?? 0;
    walletAmount       = prefs.getDouble('wallet') ?? 0;
    hasManhwaBoost     = prefs.getBool('manhwaBoost') ?? false;
    hasSpeed2x         = prefs.getBool('speed2x') ?? false;
    hasSpeed5x         = prefs.getBool('speed5x') ?? false;
    hasAutoCollect     = prefs.getBool('autoCollect') ?? false;
    cnReadCount        = prefs.getInt('cnRead') ?? 0;
    cnMissionDone      = prefs.getBool('cnMission') ?? false;
    lastAttendanceDate = prefs.getString('attendance');
    firstAccessDate    = prefs.getString('firstAccess');
    // totalSecondsInApp은 로드하지 않음 — 앱 재시작마다 0으로 초기화
    notifyListeners();
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps', steps);
    await prefs.setDouble('wallet', walletAmount);
    await prefs.setBool('manhwaBoost', hasManhwaBoost);
    await prefs.setBool('speed2x', hasSpeed2x);
    await prefs.setBool('speed5x', hasSpeed5x);
    await prefs.setBool('autoCollect', hasAutoCollect);
    await prefs.setInt('cnRead', cnReadCount);
    await prefs.setBool('cnMission', cnMissionDone);
    if (lastAttendanceDate != null) await prefs.setString('attendance', lastAttendanceDate!);
    if (firstAccessDate != null) await prefs.setString('firstAccess', firstAccessDate!);
    // totalSecondsInApp은 저장하지 않음 — 세션 한정, 앱 종료 시 초기화
  }
}
