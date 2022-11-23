<template>
  <div>
    <TheHeader />
    <NuxtPage />
    <TheFooter />
    <TheCurrentAppUser />
  </div>
</template>

<script lang="ts" setup>
  import TheHeader from './components/_common/TheHeader.vue'
  import TheFooter from './components/_common/TheFooter.vue'
  import TheCurrentAppUser from '~~/components/_common/TheCurrentAppUser.vue';
  // import { useCurrentAppUserStore } from '~~/store/currentAppUser'

  // const currentAppUserStore = useCurrentAppUserStore()
  // const { data } = (await useAsyncGql({
  //   operation: 'CurrentAppUser'
  // }))
  // const currentAppUser = data
  // currentAppUserStore.setCurrentAppUser(currentAppUser)
</script>

<style>

</style>