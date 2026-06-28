// ════════════════════════════════════════════════════════
// features.dart — 클라이언트별 기능 ON/OFF 설정
//
// ★ 이 파일 하나만 수정하면 전체 기능 세트가 결정됩니다 ★
//
// 사용법:
//   true  → 해당 기능 활성화 (탭/섹션/라우트 포함)
//   false → 해당 기능 비활성화 (코드에서 완전 제외)
//
// 적용 범위:
//   • main.dart        — 라우트 등록 여부
//   • main_shell.dart  — 하단 탭 구성
//   • home_page.dart   — 홈 섹션 표시 여부
//   • quick_action_card.dart — 빠른 액션 버튼
//   • game_select_page.dart  — 게임 목록
// ════════════════════════════════════════════════════════

class Features {
  Features._(); // 인스턴스화 불가

  // ──────────────────────────────────────────────────────
  // 하단 탭
  // ──────────────────────────────────────────────────────
  static const bool cardNews = true;  // 📰 카드뉴스 탭
  static const bool game     = true;  // 🎮 게임 탭

  // ──────────────────────────────────────────────────────
  // 홈 화면 섹션
  // ──────────────────────────────────────────────────────
  static const bool pedometer  = true; // 👟 만보기 카드 (실기기 전용)
  static const bool bill       = true; // 📋 고정비 등록 배너 + 절감머니 내역
  static const bool offerwall  = true; // 💡 고정비 절감 미션 (홈 인라인 + 전용 페이지)
  static const bool attendance = true; // 📅 출석 체크 (빠른 액션)
  static const bool fortune    = true; // 🎁 행운 뽑기 (빠른 액션)
  static const bool adBonus    = true; // 📺 광고 보너스 (빠른 액션)

  // ──────────────────────────────────────────────────────
  // 별도 페이지 (라우트)
  // ──────────────────────────────────────────────────────
  static const bool shop   = true; // 🎁 교환소 (/shop)
  static const bool coupon = true; // 🎫 쿠폰함 (/coupon)
  static const bool rank   = true; // 🏆 전체 랭킹 (/rank)

  // ──────────────────────────────────────────────────────
  // 게임 종류 (game = true 일 때만 유효)
  // ──────────────────────────────────────────────────────
  static const bool gameBrick  = true; // 🧱 벽돌깨기
  static const bool gameJump   = true; // 🏃 러너
  static const bool gameCatch  = true; // 🎯 코인받기
  static const bool gameSnake  = true; // 🐍 뱀 게임
  static const bool gameTap    = true; // ⚡ 탭 배틀
  static const bool gameQuiz   = true; // 🃏 퀴즈왕
  static const bool gameMemory = true; // 🧩 카드매칭
  static const bool gameReflex = true; // 🎯 반응속도
}
