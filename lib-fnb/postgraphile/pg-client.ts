import pg from 'pg'
const Pool = pg.Pool
import loadConfig from "./config"

const userTable = 'auth.app_user'
let pool: any

const initPool = async() => {
  const config = await loadConfig()
  const connectionString = config.connectionConfig.connectionString

  if (!connectionString) throw new Error('config.connectionString required')

  pool = new Pool({
    connectionString: connectionString,
  })
}

// the begin/commit/rollback stuff
// https://node-postgres.com/features/transactions
// the code example at the bottom could be a better pattern
// previous usage was causing a warning for every game session query because the function is stable
// *** was added
const doQuery = async (sql: string, params?: string [], claims?: any) => {
  let client
  await initPool()
  try {
    client = await pool.connect()
    if (claims) {
      await client.query('begin')
      for (const key of Object.keys(claims)) {
        await client.query(`set local jwt.claims.${key} to '${claims[key]}';`)
      }
    }
    const result = await client.query(sql,params)
    if (claims) { // ***
      await client.query('commit')
    }
    return result
  } catch (e: any) {
    console.log('ERROR: PGCLIENT:', e.toString())
    await client.query('rollback')
    throw e
  } finally {
    client.release()
  }
}

const findUser = async (username: string) => {
  const result = await doQuery(`select * from ${userTable} where username = $1;`, [username]);
  return result.rows[0];
};

const becomeUser = async (username: string) => {
  const user = await findUser(username)
  await doQuery(`set jwt.claims.contact_id = '${user.contact_id}';`);
  return user
};

export {
  doQuery
  ,findUser
  ,becomeUser
}



// const { Pool } = require('pg')
// const connectionString = process.env.DB_OWNER_CONNECTION || process.env.DB_CONNECTION

// const userTable = 'app.app_user'
// let pool: any

// const initPool = async() => {
//   // const config = await loadConfig()
//   // const connectionString = config.connectionConfig.connectionString

//   if (!pool) {
//     if (!connectionString) throw new Error('config.connectionString required')

//     pool = new Pool({
//       connectionString: connectionString,
//     })
//   }
// }


// const doQuery = async (sql: string, params?: string [], asUsername?: string) => {
//   let client
//   await initPool()
//   try {
//     client = await pool.connect()
//     console.log('asUsername', asUsername)
//     if (asUsername) {
//       const user = (await client.query(`select * from ${userTable} where username = $1;`, [asUsername])).rows[0]
//       await client.query(`set jwt.claims.contact_id = '${user.contact_id}';`)
//     }
//     const result = await client.query(sql,params)
//     return result
//   } catch (e: any) {
//     console.log('ERROR: PGCLIENT:', e.toString())
//     console.log(e.stack)
//     throw e
//   } finally {
//     client.release()
//   }
// }

// const findUser = async (username: string) => {
//   const result = await doQuery(`select * from ${userTable} where username = $1;`, [username]);
//   return result.rows[0];
// };

// const becomeUser = async (username: string) => {
//   const user = await findUser(username)
//   await doQuery(`set jwt.claims.contact_id = '${user.contact_id}';`);
//   return user
// };

// export {
//   doQuery
//   ,findUser
//   ,becomeUser
// }
