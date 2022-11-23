<template>
  <article class="current-app-user">
    <h2>Current App User</h2>
    <h3>Pulled from the store - queried in app.vue</h3>
    <div>currentAppUser: <pre>{{JSON.stringify(currentAppUser, null, 2)}}</pre></div>
  </article>
</template>

<script lang="ts" setup>
  import { computed } from 'vue'
  import { useCurrentAppUserStore } from '~~/store/currentAppUser'

  // get the currentAppUser store - it has been set elsewhere
  const currentAppUserStore = useCurrentAppUserStore()
  const currentAppUser = computed(() => {
    return currentAppUserStore.currentAppUser
  })
</script>

<style>

</style>