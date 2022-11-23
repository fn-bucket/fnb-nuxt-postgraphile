// import postgraphileServer from '../../lib-fnb/postgraphile/postgraphile-server'
import postgraphileServer from '../../lib-fnb/postgraphile/postgraphile-server-bootstrap'

export default fromNodeMiddleware(postgraphileServer)
