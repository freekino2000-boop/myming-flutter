-- ══════════════════════════════════════════════════════════
-- 마이밍 PostgreSQL 스키마
-- ══════════════════════════════════════════════════════════

-- 확장
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── 사용자 ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255),
  nickname      VARCHAR(50)  NOT NULL DEFAULT '마이밍유저',
  birth_date    DATE,
  gender        VARCHAR(10),
  city          VARCHAR(50),
  social_provider VARCHAR(20),  -- 'kakao' | 'google' | null(이메일)
  social_id     VARCHAR(255),
  first_access  DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_social
  ON users(social_provider, social_id)
  WHERE social_provider IS NOT NULL;

-- ── 걸음수 ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS steps (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date       DATE NOT NULL DEFAULT CURRENT_DATE,
  steps      INT  NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_steps_user_date ON steps(user_id, date);

-- ── 지갑 원장 ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wallet_ledger (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  icon       VARCHAR(10)  NOT NULL DEFAULT '💰',
  name       VARCHAR(100) NOT NULL,
  amount     INT          NOT NULL,          -- 양수:적립, 음수:지출
  type       VARCHAR(10)  NOT NULL CHECK (type IN ('earn','spend')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ledger_user ON wallet_ledger(user_id, created_at DESC);

-- 지갑 잔액은 ledger 합산으로 계산 (뷰)
CREATE OR REPLACE VIEW wallet_balance AS
  SELECT user_id, COALESCE(SUM(amount), 0) AS balance
  FROM wallet_ledger
  GROUP BY user_id;

-- ── 출석 체크 ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS attendance (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date       DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_attendance_user ON attendance(user_id, date DESC);

-- ── 카드뉴스 ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS card_news (
  id         VARCHAR(20)  PRIMARY KEY,
  emoji      VARCHAR(10),
  title      TEXT         NOT NULL,
  summary    TEXT,
  category   VARCHAR(20)  NOT NULL DEFAULT 'economy',  -- economy|realty|issue|tenancy
  tier       VARCHAR(10)  NOT NULL DEFAULT 'weekly',   -- top3|weekly
  rank       INT,
  img_url    TEXT,
  body       TEXT,
  keywords   TEXT[],
  stat       TEXT,
  likes      INT          NOT NULL DEFAULT 0,
  scraps     INT          NOT NULL DEFAULT 0,
  published_at DATE       NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 기존 테이블에 컬럼 누락 시 추가 (멱등)
ALTER TABLE card_news ADD COLUMN IF NOT EXISTS emoji    VARCHAR(10);
ALTER TABLE card_news ADD COLUMN IF NOT EXISTS keywords TEXT[];
ALTER TABLE card_news ADD COLUMN IF NOT EXISTS stat     TEXT;

-- ── 기사 읽기 기록 ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS news_reads (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  news_id     VARCHAR(20) NOT NULL REFERENCES card_news(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, news_id)
);

-- ── 기사 좋아요 ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS news_likes (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  news_id    VARCHAR(20) NOT NULL REFERENCES card_news(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, news_id)
);

CREATE INDEX IF NOT EXISTS idx_likes_news ON news_likes(news_id);

-- ── 기사 즐겨찾기 ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS news_bookmarks (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  news_id    VARCHAR(20) NOT NULL REFERENCES card_news(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, news_id)
);

CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON news_bookmarks(user_id, created_at DESC);

-- ── 게임 점수 ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_scores (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  game_id    VARCHAR(10) NOT NULL,  -- 'brick'|'jump'|'catch'|'snake'
  score      INT         NOT NULL DEFAULT 0,
  reward     INT         NOT NULL DEFAULT 0,
  played_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_scores_game ON game_scores(game_id, score DESC);
CREATE INDEX IF NOT EXISTS idx_scores_user ON game_scores(user_id, played_at DESC);

-- ── 오퍼월 미션 완료 ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS offer_completions (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  offer_id    VARCHAR(50) NOT NULL,
  reward      INT         NOT NULL DEFAULT 0,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, offer_id)
);

-- ── 리프레시 토큰 ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      TEXT        NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── updated_at 자동 갱신 트리거 ────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
