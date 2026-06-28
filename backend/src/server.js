require('dotenv').config();
const fs  = require('fs');
const path = require('path');
const app = require('./app');
const db  = require('./config/db');

const PORT = process.env.PORT || 3000;

async function initDb() {
  const schema = path.join(__dirname, 'db', 'schema.sql');
  const seed   = path.join(__dirname, 'db', 'seed.sql');
  await db.query(fs.readFileSync(schema, 'utf8'));
  await db.query(fs.readFileSync(seed,   'utf8'));
  console.log('✅ DB 스키마 및 시드 적용 완료');
}

async function start() {
  try {
    await db.query('SELECT 1');
    console.log('✅ PostgreSQL 연결 성공');
  } catch (err) {
    console.error('❌ PostgreSQL 연결 실패:', err.message);
    process.exit(1);
  }

  // 프로덕션 첫 배포 시 스키마 자동 초기화
  if (process.env.NODE_ENV === 'production') {
    try {
      await initDb();
    } catch (err) {
      console.warn('⚠️  DB 초기화 경고 (이미 적용됐을 수 있음):', err.message);
    }
  }

  app.listen(PORT, () => {
    console.log(`🚀 마이밍 API 서버 실행 중 — http://localhost:${PORT}`);
    console.log(`   헬스체크: http://localhost:${PORT}/health`);
  });
}

start();
