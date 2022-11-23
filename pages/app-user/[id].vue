<template>
  <pre>{{JSON.stringify(appUser, null, 2)}}</pre>
</template>

<script setup>
  const route = useRoute()
  const { data } = (await useAsyncGql({
    operation: 'AppUserById',
    variables: {
      appUserId: route.params.id
    }
  }))
  const appUser = data.value.appUserById

</script>

<style>
</style>