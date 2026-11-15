import oracledb from 'oracledb';
import 'dotenv/config';

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;

let pool;

export async function initPool() {
  pool = await oracledb.createPool({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    connectString: process.env.DB_CONNECT_STRING,
    poolMin: 1,
    poolMax: 5,
  });
  console.log('Connected to Oracle at', process.env.DB_CONNECT_STRING);
}

export async function closePool() {
  if (pool) await pool.close(5);
}

function lowerKeys(row) {
  const out = {};
  for (const [k, v] of Object.entries(row)) out[k.toLowerCase()] = v;
  return out;
}

export async function query(sql, binds = {}) {
  const conn = await pool.getConnection();
  try {
    const result = await conn.execute(sql, binds);
    return result.rows.map(lowerKeys);
  } finally {
    await conn.close();
  }
}

export async function transaction(work) {
  const conn = await pool.getConnection();
  try {
    const result = await work(conn);
    await conn.commit();
    return result;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    await conn.close();
  }
}

export { oracledb };
