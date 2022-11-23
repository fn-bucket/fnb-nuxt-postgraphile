<template>
  <pre>{{JSON.stringify(appTenant, null, 2)}}</pre>
</template>

<script setup>
  const route = useRoute()
  const { data } = (await useAsyncGql({
    operation: 'AppTenantById',
    variables: {
      appTenantId: route.params.id
    }
  }))
  const appTenant = data.value.appTenantById

</script>

<style>
</style>