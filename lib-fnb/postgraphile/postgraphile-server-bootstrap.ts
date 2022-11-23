import {postgraphile} from 'postgraphile'
const DATABASE_URL = process.env.DATABASE_URL || 'postgres://postgres:1234@0.0.0.0/fnb'
const schemas = 'auth_bootstrap,app,app_fn,auth_fn'.split(',')

export default postgraphile(DATABASE_URL, schemas, {
  watchPg: true, // automatic reload when database changes
  graphiql: true, // for dev
  graphqlRoute: '/api/graphql',
  graphiqlRoute: '/api/graphiql',
  enhanceGraphiql: true,
  ignoreRBAC: false,
  disableDefaultMutations: true,
  dynamicJson: true,
  disableQueryLog: process.env.DISABLE_QUERY_LOG !== "false",
  allowExplain: true,
  jwtSecret: 'tacosaresuperyummy',
  jwtPgTypeIdentifier: 'auth_bootstrap.jwt_token_bootstrap',
  pgDefaultRole: 'app_anon'  
})
