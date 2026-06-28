-- ══════════════════════════════════════════════════════════
-- 마이밍 시드 데이터 (개발용)
-- ══════════════════════════════════════════════════════════

-- 카드뉴스 샘플 (Flutter kCardNewsList와 동일한 ID/category 값)
INSERT INTO card_news (id, title, summary, category, tier, rank, published_at) VALUES
  ('cn1',  '가계부채 1,906조 돌파… 금리 인하 신호에도 "경고등"',         '한국은행이 올 상반기 가계부채가 1,906조원을 넘어섰다고 발표했다.',    'economy', 'top3',   1, CURRENT_DATE),
  ('cn2',  '강남 3구 호가 한 달새 5%↑… 신고가 행진 재현되나',            '강남·서초·송파 아파트 단지에서 신고가 거래가 이어지고 있다.',         'realty',  'top3',   2, CURRENT_DATE),
  ('cn3',  '원·달러 환율 1,380원대 안착… 수출 기업 "한숨 돌렸다"',        '달러 약세와 외국인 증시 순매수가 맞물리며 원화 강세가 이어지고 있다.', 'economy', 'top3',   3, CURRENT_DATE),
  ('cn4',  '2030 "영끌" 귀환… 20대 아파트 매수 비중 역대 최고치',         '지난달 20대 아파트 매수 거래 비중이 12.4%로 집계됐다.',              'realty',  'weekly', NULL, CURRENT_DATE - 1),
  ('cn5',  '삼성전자, 2분기 영업익 15조 전망… AI 수주 폭증이 이끈다',      '증권가가 삼성전자의 2분기 영업이익 컨센서스를 15조원으로 상향했다.',   'economy', 'weekly', NULL, CURRENT_DATE - 1),
  ('cn6',  '전기·가스 요금 또 오르나… 하반기 인상 여부 이달 결정',         '정부가 이달 말 전기·도시가스 요금 하반기 조정 계획을 발표한다.',       'issue',   'weekly', NULL, CURRENT_DATE - 2),
  ('cn7',  'GTX-A 효과 현실화… 수서~동탄 역세권 집값 22% 뛰었다',         'GTX-A 개통 후 6개월, 역세권 아파트 시세가 평균 22% 상승했다.',       'realty',  'weekly', NULL, CURRENT_DATE - 2),
  ('cn12', '전월세 전환율 5년 만에 최저… 전세→월세 전환 비용 줄었다',      '법정 전월세 전환율이 4.9%로 조정되며 세입자 부담이 완화됐다.',        'tenancy', 'weekly', NULL, CURRENT_DATE - 3),
  ('cn13', '임대차 3법 시행 4년… 계약갱신 분쟁 3만 건 돌파, 판례는?',     '임대차 3법 시행 4년, 계약갱신청구권 분쟁이 3만 건을 넘어섰다.',      'tenancy', 'weekly', NULL, CURRENT_DATE - 4),
  ('cn14', '청년 월세 특별지원 2차 신청 시작… 월 최대 20만 원, 내가 해당될까?', '19~34세 무주택 청년이 월세 최대 20만원을 최장 12개월 받을 수 있다.', 'tenancy', 'weekly', NULL, CURRENT_DATE - 5)
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
