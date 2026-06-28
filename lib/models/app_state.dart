// ════════════════════════════════════════════════════════
// app_state.dart — 전역 앱 상태 (ChangeNotifier)
// 로컬 낙관적 업데이트 → 백그라운드 API 동기화
// ════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/wallet_service.dart';
import '../services/steps_service.dart';
import '../services/attendance_service.dart';
import '../services/cardnews_service.dart';

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
  // API 모드 (로그인 완료 후 true)
  bool _apiEnabled = false;
  bool get apiEnabled => _apiEnabled;

  // 만보기
  int steps = 0;

  // 지갑
  double walletAmount = 0;

  // 아이템 보유 여부
  bool hasManhwaBoost = false;
  bool hasSpeed2x     = false;
  bool hasSpeed5x     = false;
  bool hasAutoCollect = false;

  // 카드뉴스 미션
  int  cnReadCount   = 0;
  bool cnMissionDone = false;

  // 탭 전환 트리거
  int cardNewsTabTrigger = 0;
  void switchToCardNewsTab() { cardNewsTabTrigger++; notifyListeners(); }

  // 원장 내역
  List<LedgerEntry> ledger = [];

  // 출석 체크
  String?       lastAttendanceDate;
  List<String>  attendanceDates = [];

  // 앱 체류 시간
  String?   firstAccessDate;
  int       totalSecondsInApp = 0;
  DateTime? _sessionStart;

  // ── API 모드 활성화 (로그인 성공 시 호출) ─────────────────
  Future<void> enableApi() async {
    _apiEnabled = true;
    await _syncFromApi();
  }

  // API에서 최신 상태 풀링 (잔액·출석·카드뉴스 미션)
  Future<void> _syncFromApi() async {
    await Future.wait([
      _syncBalance(),
      _syncAttendance(),
      _syncCNMission(),
    ]);
    notifyListeners();
  }

  Future<void> _syncBalance() async {
    try {
      walletAmount = await WalletService.instance.getBalance();
    } catch (_) {}
  }

  Future<void> _syncAttendance() async {
    try {
      final res = await AttendanceService.instance.getMonth();
      attendanceDates = res.dates;
      if (res.dates.isNotEmpty) lastAttendanceDate = res.dates.last;
    } catch (_) {}
  }

  Future<void> _syncCNMission() async {
    try {
      final res = await CardNewsService.instance.getMissionStatus();
      cnReadCount   = res.readCount;
      cnMissionDone = res.missionDone;
    } catch (_) {}
  }

  // ── 걸음수 (만보 부스트 + API 동기화) ─────────────────────
  void addSteps(int count) {
    steps += count;
    if (!_apiEnabled) {
      final rate = hasManhwaBoost ? 0.015 : 0.01;
      walletAmount += count * rate;
      addLedger('👟', '걷기 적립', (count * rate).ceil(), 'earn');
    }
    notifyListeners();
    saveToPrefs();
    if (_apiEnabled) _syncSteps();
  }

  Future<void> _syncSteps() async {
    try {
      final res = await StepsService.instance.sync(steps);
      walletAmount = res.balance;
      notifyListeners();
    } catch (_) {}
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

  // ── 보상 적립 (낙관적 업데이트 → API 백그라운드) ───────────
  void earn(String icon, String name, int amount) {
    walletAmount += amount;
    addLedger(icon, name, amount, 'earn');
    notifyListeners();
    saveToPrefs();
    if (_apiEnabled) {
      WalletService.instance.earn(icon, name, amount).then((balance) {
        walletAmount = balance;
        notifyListeners();
      }).catchError((_) {});
    }
  }

  // ── 카드뉴스 기사 읽기 ────────────────────────────────────
  void readCNArticle([String? newsId]) {
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
    if (_apiEnabled && newsId != null) {
      CardNewsService.instance.read(newsId).then((res) {
        walletAmount   = res.balance;
        cnReadCount    = res.readCount;
        cnMissionDone  = res.readCount >= 3;
        notifyListeners();
      }).catchError((_) {});
    }
  }

  // ── 지출 ─────────────────────────────────────────────────
  void spend(int amount) {
    if (walletAmount < amount) return;
    walletAmount -= amount;
    addLedger('🛍', '교환소 구매', amount, 'spend');
    notifyListeners();
    saveToPrefs();
    if (_apiEnabled) {
      WalletService.instance.spend('교환소 구매', amount).then((balance) {
        walletAmount = balance;
        notifyListeners();
      }).catchError((_) {});
    }
  }

  // ── 부스터 구매 ──────────────────────────────────────────
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
    if (_apiEnabled) {
      WalletService.instance.spend(name, price).then((balance) {
        walletAmount = balance;
        notifyListeners();
      }).catchError((_) {});
    }
  }

  // ── 세션 ────────────────────────────────────────────────
  void startSession() {
    firstAccessDate ??= DateTime.now().toIso8601String().substring(0, 10);
    _sessionStart   ??= DateTime.now();
    saveToPrefs();
  }

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

  // ── 출석 체크 (낙관적 업데이트 → API) ─────────────────────
  bool get canAttendToday {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastAttendanceDate != today;
  }

  void doAttendance() {
    if (!canAttendToday) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    lastAttendanceDate = today;
    if (!attendanceDates.contains(today)) attendanceDates.add(today);
    earn('📅', '출석 체크', 10);
    saveToPrefs();
    if (_apiEnabled) {
      AttendanceService.instance.check().then((res) {
        walletAmount = res.balance;
        notifyListeners();
      }).catchError((_) {});
    }
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
    attendanceDates    = prefs.getStringList('attendanceDates') ?? [];
    firstAccessDate    = prefs.getString('firstAccess');
    totalSecondsInApp  = prefs.getInt('totalSeconds') ?? 0;
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
    await prefs.setStringList('attendanceDates', attendanceDates);
    if (firstAccessDate != null) await prefs.setString('firstAccess', firstAccessDate!);
    await prefs.setInt('totalSeconds', totalSecondsInApp);
  }
}
