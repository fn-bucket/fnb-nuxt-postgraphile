import {postgraphile} from 'postgraphile'
import getUserSettings from './auth-strategy/_bootstrap/get-user-settings'
const DATABASE_URL = process.env.DATABASE_URL || 'postgres://postgres:1234@0.0.0.0/drainage'
const schemas = 'app,app_fn,auth_fn,dng'.split(',')

export default postgraphile(DATABASE_URL, schemas, {
  pgSettings: async (req: any) => {
    const userSettings = await getUserSettings(req)
    return userSettings.settings
  },
  async additionalGraphQLContextFromRequest(req, res) {
    const userSettings = await getUserSettings(req)
    return {
      user: userSettings.user,
      hostname: `${req.hostname}`,
    }
  },
  watchPg: true, // automatic reload when database changes
  graphiql: true, // for dev
  graphqlRoute: '/api/graphql',
  graphiqlRoute: '/api/graphiql',
  enhanceGraphiql: true,
  ignoreRBAC: false,
  disableDefaultMutations: true,
  dynamicJson: true,
  disableQueryLog: process.env.DISABLE_QUERY_LOG !== "false",
  allowExplain: true
})
