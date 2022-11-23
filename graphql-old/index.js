import Vue from 'vue'
import VueApollo from 'vue-apollo'
import ApolloClient from 'apollo-client'
import { HttpLink } from 'apollo-link-http'
import { onError } from 'apollo-link-error'
import { InMemoryCache } from 'apollo-cache-inmemory'
import { setContext } from 'apollo-link-context'
// import { getInstance } from '@/auth/authWrapper'
import store from '@/store'

Vue.use(VueApollo)
// let loading

// https://community.auth0.com/t/auth0-client-is-null-in-vue-spa-component-on-page-refresh/38147/6
const getAuth = async () => {
  const token = store.state.user.userToken
  // const token = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlJGTzJBYy1aMDA3SDB1SlIyZEc4ViJ9.eyJodHRwOi8vd3d3Lm91cnZpc3VhbGJyYWluLmNvbS9vdmJVc2VyIjp7ImFwcFJvbGUiOiJhcHBfc3BfYWRtIiwiaW5hY3RpdmUiOmZhbHNlLCJ1c2VybmFtZSI6ImFwcHN1cGVyYWRtaW4iLCJob21lUGF0aCI6IkFwcFRlbmFudE1hbmFnZXIiLCJsYXN0TmFtZSI6IkFkbWluIiwiZmlyc3ROYW1lIjoiS2V2aW4iLCJhcHBVc2VySWQiOiIwMUYxRFE2QkpHSERORkYxWjBDUDJERzFNTSIsInBlcm1pc3Npb25zIjpbInA6c3VwZXItYWRtaW4iLCJtOmFkbWluIiwicDphcHAtdGVuYW50LXNjb3BlIiwibDpvdmItcHJpdmF0ZSIsInA6bW9kYWxpdHkiLCJsOm92Yi1wcml2YXRlIiwibDp2aXNpb24iLCJsOm9jY3VwYXRpb25hbCIsImw6c2lsdmVyIiwibDp1bmJvdW5kIl0sImFwcFRlbmFudElkIjoiMDFGUjlQMzdGMjY3SDhCQTk3NkVXQUdZRjciLCJwZXJtaXNzaW9uS2V5IjoiU3VwZXJBZG1pbiIsInJlY292ZXJ5RW1haWwiOiJzdGxidWNrZXRAZ21haWwuY29tIiwiYXBwVGVuYW50TmFtZSI6IkFuY2hvciBUZW5hbnQiLCJwcmVmZXJyZWRUaW1lem9uZSI6IlBTVDhQRFQifSwiaXNzIjoiaHR0cHM6Ly9kZXYtb3ZiLnVzLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2MDE3M2NhNTQ0MWZkNjAwNzA4MmJiOTIiLCJhdWQiOlsiaHR0cHM6Ly9kZXYtb3ZiLnVzLmF1dGgwLmNvbS9hcGkvdjIvIiwiaHR0cHM6Ly9kZXYtb3ZiLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2NDIxOTU4ODksImV4cCI6MTY0MjI4MjI4OSwiYXpwIjoibUhMNzkwT2lQYVdPSHJWandFb0VPTkFseEFFTldBdUgiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIn0.DLFWbvUYKLr-wlDJlyrST47iPcgjXhcHy0XinHkWkbocoV0fJZozjWAjuu5373nt-L7ahc9958vefWuUWOcNySlIlVyXgG1jeeFtw2qdcKPEASlwKOTDxz4P9gi5fzy8w065ldSqlGOHodADEgrYbu_Dp12NrOyLHPGPjNbZ2_PjUFhUGfdoPS1wAsqUCGPF85777vXT_U2-kPCqMphIy_nQfvmbyDNMdayoVgzF3SifEKWR6Sm8ALMoDFnvHqmaJqrafsUl4NoZz5--9SBLPl29DFV0nQZ-bu97mvbaoq1zlK7xXgq1DnqRUF6pKgdaO2kg6QTVllvTG-_QSQ2YIA'
  return token ? `Bearer ${token}` : ''
}

const buildScopeHeader = () => {
  if (store.state.user.scopeAppTenant) {
    // const str = JSON.stringify(store.state.user.scopeAppTenant)
    const str = JSON.stringify(
      {
        id: store.state.user.scopeAppTenant.id,
        parentAppTenantId: store.state.user.scopeAppTenant.parentAppTenantId
      }
    )
    const encoded = btoa(unescape(encodeURIComponent(str)))
    return {
      fnbs: encoded
    }
  } else {
    return {}
  }
}

const buildImpersonationHeader = () => {
  if (store.state.user.actualAppUserInfo) {
    const str = JSON.stringify(store.state.user.userInfo)
    const encoded = btoa(unescape(encodeURIComponent(str)))
    return {
      fnbi: encoded
    }
  } else {
    return {}
  }
}

const errorLink = onError(({ graphQLErrors, operation, networkError }) => {
  // console.log('TACOS', graphQLErrors, operation, networkError)
  if (graphQLErrors) {
    // alert(JSON.stringify(graphQLErrors, null, 2))
    store
      .dispatch('recordException', graphQLErrors
        .map(e => {
          return {
            ...e,
            operationName: operation.operationName,
            variables: operation.variables
          }
        })
      )
  }
  // maybe do these later
  // if (networkError) {
  //   store.dispatch('recordException', [networkError.map(ne => {
  //     return {
  //       message: ne.toString()
  //     }
  //   })])
  // }
})

const authLink = setContext((_, { headers }) => {
  return getAuth()
    .then(authorization => {
      const authorizationHeader = authorization ? { authorization } : {}
      const scopeHeader = buildScopeHeader()
      const impersonationHeader = buildImpersonationHeader()
      const timeZoneHeader = { timezone: Intl.DateTimeFormat().resolvedOptions().timeZone }

      return {
        headers: {
          ...headers,
          ...authorizationHeader,
          ...scopeHeader,
          ...impersonationHeader,
          ...timeZoneHeader
        }
      }
    })
})

// All the graphql requests will be made at yourdomain.com/graphql
const httpLink = new HttpLink({
  uri: '/graphql'
})

// Cache implementation
const cache = new InMemoryCache()

// We give this to the graphql client
const apolloClient = new ApolloClient({
  link: authLink.concat(errorLink).concat(httpLink),
  cache
})

// And we reference this client needed by vue-apollo
export default new VueApollo({
  defaultClient: apolloClient,
  // Default 'apollo' definition
  defaultOptions: {
    // See 'apollo' definition
    // For example: default query options
    $query: {
      loadingKey: 'loading',
      fetchPolicy: 'cache-and-network'
    }
  },
  // Watch loading state for all queries
  // See 'Smart Query > options > watchLoading' for detail
  // watchLoading (isLoading, countModifier) {
  //   loading += countModifier
  //   // console.log('Global loading', loading, countModifier)
  // },
  // Global error handler for all smart queries and subscriptions
  errorHandler (error) {
    console.log('Global error handler')
    console.error(error)
  },
  // Globally turn off prefetch ssr
  prefetch: false
})
