<template>
  <div style="display: flex; gap: 1rem; background-color:powderblue;">
    <NuxtLink v-for="mi of menuItems" :to="mi.path">{{mi.label}}</NuxtLink>
  </div>
</template>

<script lang="ts" setup>
  import { useCurrentAppUserStore } from '~~/store/currentAppUser'
  const currentAppUserStore = useCurrentAppUserStore()
  const menuItems = computed(() => {
    return [
      { path: '/', label: 'Home', noAuth: true },
      { path: '/app-tenant-subscriptions', label: 'Subscriptions' },
      { path: '/app-users', label: 'App Users' },
      { path: '/app-tenants', label: 'App Tenants' },
      { path: '/license-packs', label: 'License Packs' },
      { path: '/applications', label: 'Applications' },
    ].filter(m => currentAppUserStore.loggedIn || m.noAuth === true)
  })
</script>

<style>

</style>


