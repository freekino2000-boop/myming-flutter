require('dotenv').config();
const app = require('./app');
const db  = require('./config/db');

const PORT = process.env.PORT || 3000;

async function start() {
  // DB 연결 확인
  try {
    await db.query('SELECT 1');
    console.log('✅ PostgreSQL 연결 성공');
  } catch (err) {
    console.error('❌ PostgreSQL 연결 실패:', err.message);
    console.error('   DATABASE_URL을 .env에 설정하고 PostgreSQL이 실행 중인지 확인하세요.');
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`🚀 마이밍 API 서버 실행 중 — http://localhost:${PORT}`);
    console.log(`   헬스체크: http://localhost:${PORT}/health`);
  });
}

start();
