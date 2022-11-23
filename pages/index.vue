<template>
  <div>
    <h1>fnb-nuxt-postgraphile</h1>
    <h2>a boilerplate for graphql apps built with <a target="_blank" href="https://www.vuejs.org">vue3</a>, <a target="_blank" href="https://www.nuxt.com">nuxt3</a> and <a target="_blank" href="https://www.graphile.org/postgraphile/">postgraphile</a>.</h2>
    <!-- default config is for bootstrapping local-only no password login -->
    <select 
      name="appUser" 
      id="appUser" 
      @input="handleAppUserSelected"
      v-model="selectedAppUser"
    >
      <option value="" disabled>Select user</option>
      <option
        v-for="bsu in bsUsers"
        :value="bsu.username"
        :label="bsu.username"
      >{{bsu.username}}</option>
    </select> 
    {{selectedAppUser}}
    <button @click="handleLogin">Login</button>
    <button @click="handleLogout">Logout</button>
  </div>
</template>

<script lang="ts" setup>
  import { useCurrentAppUserStore } from '~~/store/currentAppUser'
  import { ref } from 'vue'
  const selectedAppUser = ref('')
  
  async function afterLogin () {
    const currentAppUserStore = useCurrentAppUserStore()
    const { data } = (await useAsyncGql({
      operation: 'CurrentAppUser'
    }))
    currentAppUserStore.setCurrentAppUser(data.value.currentAppUser)
  }
  
  async function handleLogin() {
    const { authenticateBootstrap } = await GqlAuthenticateBootstrap({ username: selectedAppUser.value })
    const authToken = authenticateBootstrap
    useGqlToken(authToken)
    await afterLogin()
  }

  async function handleLogout() {
    const currentAppUserStore = useCurrentAppUserStore()
    currentAppUserStore.setCurrentAppUser(null)
    useGqlToken(null)
  }

  async function getBsUsers(): any[] {
    const { data } = (await useAsyncGql({
      operation: 'BsUsers'
    }))
    return data.value.bsUsers.nodes
  }
  const bsUsers = await getBsUsers()

  async function handleAppUserSelected () {
    var e: any = document.getElementById("appUser");
  }

</script>

<style>

</style>