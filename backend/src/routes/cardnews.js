const router = require('express').Router();
const { query, validationResult } = require('express-validator');
const db   = require('../config/db');
const auth = require('../middleware/auth');

const READ_REWARD   = 10;
const MISSION_COUNT = 3;
const MISSION_BONUS = 30;

// GET /api/cardnews — 카드뉴스 목록
router.get('/', auth, [
  query('category').optional().isIn(['economy', 'realty', 'issue', 'tenancy']),
  query('tier').optional().isIn(['top3', 'weekly']),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const uid  = req.user.id;
    const cat  = req.query.category;
    const tier = req.query.tier;

    const conditions = ['1=1'];
    const params = [uid];
    if (cat)  { conditions.push(`n.category = $${params.push(cat)}`); }
    if (tier) { conditions.push(`n.tier = $${params.push(tier)}`); }

    const { rows } = await db.query(
      `SELECT n.id, n.emoji, n.title, n.summary, n.category, n.tier, n.rank,
              n.keywords, n.stat, n.body, n.likes, n.scraps, n.published_at,
              (SELECT COUNT(*) FROM news_likes    WHERE news_id = n.id) AS like_count,
              (SELECT COUNT(*) FROM news_bookmarks WHERE news_id = n.id) AS bookmark_count,
              (nr.id IS NOT NULL) AS is_read,
              EXISTS(SELECT 1 FROM news_likes     WHERE news_id = n.id AND user_id = $1) AS is_liked,
              EXISTS(SELECT 1 FROM news_bookmarks WHERE news_id = n.id AND user_id = $1) AS is_bookmarked
       FROM card_news n
       LEFT JOIN news_reads nr ON nr.news_id = n.id AND nr.user_id = $1
       WHERE ${conditions.join(' AND ')}
       ORDER BY n.tier, n.rank NULLS LAST, n.published_at DESC`,
      params
    );
    res.json(rows);
  } catch (err) { next(err); }
});

// GET /api/cardnews/mission/status — 오늘 기사 미션 현황 (/:id 보다 먼저 정의)
router.get('/mission/status', auth, async (req, res, next) => {
  try {
    const today = new Date().toISOString().slice(0, 10);
    const { rows } = await db.query(
      `SELECT COUNT(*) AS cnt FROM news_reads
       WHERE user_id = $1
         AND created_at >= $2::date AND created_at < $2::date + INTERVAL '1 day'`,
      [req.user.id, today]
    );
    const cnt = Number(rows[0].cnt);
    res.json({
      read_count:   cnt,
      mission_done: cnt >= MISSION_COUNT,
      required:     MISSION_COUNT,
    });
  } catch (err) { next(err); }
});

// GET /api/cardnews/:id — 기사 상세 (좋아요·즐겨찾기 상태 포함)
router.get('/:id', auth, async (req, res, next) => {
  try {
    const uid    = req.user.id;
    const newsId = req.params.id;
    const { rows } = await db.query(
      `SELECT n.*,
              (SELECT COUNT(*) FROM news_reads    WHERE news_id = $1) AS read_count,
              (SELECT COUNT(*) FROM news_likes    WHERE news_id = $1) AS like_count,
              (SELECT COUNT(*) FROM news_bookmarks WHERE news_id = $1) AS bookmark_count,
              EXISTS(SELECT 1 FROM news_likes     WHERE news_id = $1 AND user_id = $2) AS is_liked,
              EXISTS(SELECT 1 FROM news_bookmarks WHERE news_id = $1 AND user_id = $2) AS is_bookmarked
       FROM card_news n WHERE n.id = $1`,
      [newsId, uid]
    );
    if (!rows.length) return res.status(404).json({ error: '기사를 찾을 수 없습니다.' });
    res.json(rows[0]);
  } catch (err) { next(err); }
});

// POST /api/cardnews/:id/like — 좋아요 토글
router.post('/:id/like', auth, async (req, res, next) => {
  try {
    const uid    = req.user.id;
    const newsId = req.params.id;

    const exists = await db.query(
      'SELECT id FROM news_likes WHERE user_id = $1 AND news_id = $2',
      [uid, newsId]
    );
    let liked;
    if (exists.rows.length) {
      await db.query('DELETE FROM news_likes WHERE user_id = $1 AND news_id = $2', [uid, newsId]);
      liked = false;
    } else {
      await db.query('INSERT INTO news_likes (user_id, news_id) VALUES ($1, $2)', [uid, newsId]);
      liked = true;
    }
    const { rows } = await db.query(
      'SELECT COUNT(*) AS cnt FROM news_likes WHERE news_id = $1', [newsId]
    );
    res.json({ liked, like_count: Number(rows[0].cnt) });
  } catch (err) { next(err); }
});

// POST /api/cardnews/:id/bookmark — 즐겨찾기 토글
router.post('/:id/bookmark', auth, async (req, res, next) => {
  try {
    const uid    = req.user.id;
    const newsId = req.params.id;

    const exists = await db.query(
      'SELECT id FROM news_bookmarks WHERE user_id = $1 AND news_id = $2',
      [uid, newsId]
    );
    let bookmarked;
    if (exists.rows.length) {
      await db.query('DELETE FROM news_bookmarks WHERE user_id = $1 AND news_id = $2', [uid, newsId]);
      bookmarked = false;
    } else {
      await db.query('INSERT INTO news_bookmarks (user_id, news_id) VALUES ($1, $2)', [uid, newsId]);
      bookmarked = true;
    }
    res.json({ bookmarked });
  } catch (err) { next(err); }
});

// POST /api/cardnews/:id/read — 기사 읽기 (보상 지급)
router.post('/:id/read', auth, async (req, res, next) => {
  try {
    const uid    = req.user.id;
    const newsId = req.params.id;

    const news = await db.query('SELECT id FROM card_news WHERE id = $1', [newsId]);
    if (!news.rows.length) return res.status(404).json({ error: '기사를 찾을 수 없습니다.' });

    const already = await db.query(
      'SELECT id FROM news_reads WHERE user_id = $1 AND news_id = $2',
      [uid, newsId]
    );
    if (already.rows.length) {
      return res.json({ already_read: true, reward: 0 });
    }

    await db.query('INSERT INTO news_reads (user_id, news_id) VALUES ($1, $2)', [uid, newsId]);
    await db.query(
      `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
       VALUES ($1, '📰', '기사 읽기 보상', $2, 'earn')`,
      [uid, READ_REWARD]
    );

    const today = new Date().toISOString().slice(0, 10);
    const readCount = await db.query(
      `SELECT COUNT(*) AS cnt FROM news_reads
       WHERE user_id = $1
         AND created_at >= $2::date AND created_at < $2::date + INTERVAL '1 day'`,
      [uid, today]
    );
    const cnt = Number(readCount.rows[0].cnt);
    let missionBonus = 0;
    if (cnt === MISSION_COUNT) {
      const alreadyBonus = await db.query(
        `SELECT id FROM wallet_ledger
         WHERE user_id = $1 AND name = '카드뉴스 미션 완료'
           AND created_at >= $2::date AND created_at < $2::date + INTERVAL '1 day'`,
        [uid, today]
      );
      if (!alreadyBonus.rows.length) {
        await db.query(
          `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
           VALUES ($1, '🎯', '카드뉴스 미션 완료', $2, 'earn')`,
          [uid, MISSION_BONUS]
        );
        missionBonus = MISSION_BONUS;
      }
    }

    const bal = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
    );

    res.json({
      already_read:   false,
      reward:         READ_REWARD + missionBonus,
      mission_bonus:  missionBonus > 0,
      read_count:     cnt,
      balance:        Number(bal.rows[0].balance),
    });
  } catch (err) { next(err); }
});

module.exports = router;
