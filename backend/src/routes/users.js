const router = require('express').Router();
const { body, validationResult } = require('express-validator');
const db   = require('../config/db');
const auth = require('../middleware/auth');

// GET /api/users/me — 내 프로필
router.get('/me', auth, async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT id, email, nickname, birth_date, gender, city,
              social_provider, first_access, created_at
       FROM users WHERE id = $1`,
      [req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: '사용자를 찾을 수 없습니다.' });
    res.json(rows[0]);
  } catch (err) { next(err); }
});

// PUT /api/users/me — 프로필 수정
router.put('/me', auth, [
  body('nickname').optional().trim().isLength({ min: 1, max: 50 }),
  body('birth_date').optional().isDate(),
  body('gender').optional().isIn(['male', 'female', 'other']),
  body('city').optional().trim().isLength({ max: 50 }),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { nickname, birth_date, gender, city } = req.body;
    const { rows } = await db.query(
      `UPDATE users
       SET nickname    = COALESCE($1, nickname),
           birth_date  = COALESCE($2, birth_date),
           gender      = COALESCE($3, gender),
           city        = COALESCE($4, city),
           updated_at  = NOW()
       WHERE id = $5
       RETURNING id, email, nickname, birth_date, gender, city`,
      [nickname, birth_date, gender, city, req.user.id]
    );
    res.json(rows[0]);
  } catch (err) { next(err); }
});

// GET /api/users/summary — 앱 홈 요약 (잔액 + 걸음수 + 출석)
router.get('/summary', auth, async (req, res, next) => {
  try {
    const uid = req.user.id;
    const today = new Date().toISOString().slice(0, 10);

    const [balRes, stepsRes, attendRes] = await Promise.all([
      db.query('SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1', [uid]),
      db.query('SELECT steps FROM steps WHERE user_id = $1 AND date = $2', [uid, today]),
      db.query('SELECT date FROM attendance WHERE user_id = $1 ORDER BY date DESC LIMIT 1', [uid]),
    ]);

    res.json({
      balance:          Number(balRes.rows[0].balance),
      steps_today:      stepsRes.rows[0]?.steps ?? 0,
      last_attendance:  attendRes.rows[0]?.date ?? null,
      attended_today:   attendRes.rows[0]?.date === today,
    });
  } catch (err) { next(err); }
});

module.exports = router;
