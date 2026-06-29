const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt    = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const db     = require('../config/db');

const signAccess   = (id) => jwt.sign({ id }, process.env.JWT_SECRET,         { expiresIn: process.env.JWT_EXPIRES_IN         || '1h'  });
const signRefresh  = (id) => jwt.sign({ id }, process.env.JWT_REFRESH_SECRET,  { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d'  });

async function saveRefreshToken(userId, token) {
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  await db.query('DELETE FROM refresh_tokens WHERE user_id = $1 AND expires_at <= NOW()', [userId]);
  await db.query(
    `INSERT INTO refresh_tokens (user_id, token, expires_at)
     VALUES ($1, $2, $3)
     ON CONFLICT (token) DO NOTHING`,
    [userId, token, expiresAt]
  );
}

// POST /api/auth/register — 이메일 회원가입
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('nickname').trim().isLength({ min: 1, max: 50 }),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { email, password, nickname } = req.body;
    const exists = await db.query('SELECT id FROM users WHERE email = $1', [email]);
    if (exists.rows.length) return res.status(409).json({ error: '이미 사용 중인 이메일입니다.' });

    const hash = await bcrypt.hash(password, 12);
    const { rows } = await db.query(
      `INSERT INTO users (email, password_hash, nickname) VALUES ($1, $2, $3) RETURNING id, email, nickname`,
      [email, hash, nickname]
    );
    const user = rows[0];
    const accessToken  = signAccess(user.id);
    const refreshToken = signRefresh(user.id);
    await saveRefreshToken(user.id, refreshToken);

    res.status(201).json({ accessToken, refreshToken, user });
  } catch (err) { next(err); }
});

// POST /api/auth/login — 이메일 로그인
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { email, password } = req.body;
    const { rows } = await db.query(
      'SELECT id, email, nickname, password_hash FROM users WHERE email = $1',
      [email]
    );
    if (!rows.length) return res.status(401).json({ error: '이메일 또는 비밀번호가 올바르지 않습니다.' });

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) return res.status(401).json({ error: '이메일 또는 비밀번호가 올바르지 않습니다.' });

    const accessToken  = signAccess(user.id);
    const refreshToken = signRefresh(user.id);
    await saveRefreshToken(user.id, refreshToken);

    const { password_hash, ...safeUser } = user;
    res.json({ accessToken, refreshToken, user: safeUser });
  } catch (err) { next(err); }
});

// POST /api/auth/social — 소셜 로그인 (카카오/구글)
// Flutter 클라이언트가 소셜 SDK로 취득한 사용자 정보를 서버에 전달
router.post('/social', [
  body('provider').isIn(['kakao', 'google', 'naver', 'apple']),
  body('socialId').notEmpty(),
  body('nickname').trim().isLength({ min: 1, max: 50 }),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { provider, socialId, nickname, email } = req.body;
    let { rows } = await db.query(
      'SELECT id, email, nickname FROM users WHERE social_provider = $1 AND social_id = $2',
      [provider, socialId]
    );

    let user;
    if (rows.length) {
      user = rows[0];
    } else {
      const ins = await db.query(
        `INSERT INTO users (email, nickname, social_provider, social_id)
         VALUES ($1, $2, $3, $4) RETURNING id, email, nickname`,
        [email || null, nickname, provider, socialId]
      );
      user = ins.rows[0];
    }

    const accessToken  = signAccess(user.id);
    const refreshToken = signRefresh(user.id);
    await saveRefreshToken(user.id, refreshToken);

    res.json({ accessToken, refreshToken, user });
  } catch (err) { next(err); }
});

// POST /api/auth/refresh — 액세스 토큰 재발급
router.post('/refresh', async (req, res, next) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(400).json({ error: 'refreshToken이 필요합니다.' });

  try {
    const payload = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    const { rows } = await db.query(
      'SELECT id FROM refresh_tokens WHERE token = $1 AND expires_at > NOW()',
      [refreshToken]
    );
    if (!rows.length) return res.status(401).json({ error: '유효하지 않은 리프레시 토큰입니다.' });

    await db.query('DELETE FROM refresh_tokens WHERE user_id = $1 AND expires_at <= NOW()', [payload.id]);

    const accessToken = signAccess(payload.id);
    res.json({ accessToken });
  } catch (err) {
    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: '리프레시 토큰이 만료됐습니다.' });
    }
    next(err);
  }
});

// POST /api/auth/logout — 리프레시 토큰 폐기
router.post('/logout', async (req, res, next) => {
  const { refreshToken } = req.body;
  if (refreshToken) {
    await db.query('DELETE FROM refresh_tokens WHERE token = $1', [refreshToken]).catch(() => {});
  }
  res.json({ message: '로그아웃 완료' });
});

module.exports = router;
