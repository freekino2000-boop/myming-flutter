-- ══════════════════════════════════════════════════════════
-- 마이밍 시드 데이터 (개발용)
-- ══════════════════════════════════════════════════════════

-- 카드뉴스 샘플 (Flutter kCardNewsList 동일 데이터)
INSERT INTO card_news (id, title, summary, category, tier, rank, published_at) VALUES
  ('cn001', '금리 인상, 내 월세에 미치는 영향', '기준금리 변동이 임대차 시장에 미치는 파급 효과 분석', 'economy', 'top3', 1, CURRENT_DATE),
  ('cn002', '전세 vs 월세, 2026년 선택 기준', '현재 시장 상황에서 최적의 주거 형태 선택 가이드', 'realestate', 'top3', 2, CURRENT_DATE),
  ('cn003', '임대차 3법 최신 개정안', '2026년 임대차보호법 개정 핵심 내용 정리', 'lease', 'top3', 3, CURRENT_DATE),
  ('cn004', '통신비 절약하는 5가지 방법', '알뜰폰과 결합할인으로 매달 3만원 아끼기', 'economy', 'weekly', NULL, CURRENT_DATE - 1),
  ('cn005', '구독 서비스 정리 체크리스트', '안 쓰는 구독 해지하고 연 50만원 절약', 'economy', 'weekly', NULL, CURRENT_DATE - 2),
  ('cn006', '전기요금 누진세 피하는 법', '여름철 에어컨 사용 요금 최소화 전략', 'issue', 'weekly', NULL, CURRENT_DATE - 3),
  ('cn007', '보증금 돌려받는 확실한 방법', '임대차 분쟁 시 보증금 반환 청구 절차', 'lease', 'weekly', NULL, CURRENT_DATE - 4),
  ('cn008', '신용카드 vs 체크카드 혜택 비교', '소비 패턴별 최적 카드 선택 가이드', 'economy', 'weekly', NULL, CURRENT_DATE - 5)
ON CONFLICT (id) DO NOTHING;

-- 글로벌 랭킹 샘플 (게임별 상위 10위)
INSERT INTO game_scores (user_id, game_id, score, reward, played_at)
SELECT
  (SELECT id FROM users ORDER BY created_at LIMIT 1),
  unnested.game_id, unnested.score, unnested.reward, NOW()
FROM (VALUES
  ('brick', 1800, 180), ('brick', 1650, 165), ('brick', 1500, 150),
  ('jump',  2100, 150), ('jump',  1900, 150), ('jump',  1700, 145),
  ('catch', 1400,  93), ('catch', 1200,  80), ('catch', 1100,  73),
  ('snake',  55,  150), ('snake',  48,  144), ('snake',  42,  126)
) AS unnested(game_id, score, reward)
WHERE EXISTS (SELECT 1 FROM users LIMIT 1)
ON CONFLICT DO NOTHING;
