// https://v3.nuxtjs.org/api/configuration/nuxt.config

export default defineNuxtConfig({
  ssr: true,
  components: true,
  modules: ['nuxt-graphql-client', '@pinia/nuxt'],
  // @ts-ignore
  'graphql-client': {
    codegen: false,
    tokenStorage: {
      mode: 'cookie',
      cookieOptions: {
        path: '/',
        secure: true, // defaults to `process.env.NODE_ENV === 'production'`
        httpOnly: false, // Only accessible via HTTP(S)
        maxAge: 60 * 60 * 24 * 5 // 5 days
      }
    }
  },
  runtimeConfig: {
    public: {      
      GQL_HOST: 'http://localhost:3000/api/graphql', // overwritten by process.env.GQL_HOST
      DB_CONNECTION: 'postgres://postgres:1234@0.0.0.0:5432/fnb'
    }  
  }
})
