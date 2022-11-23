<template>
  <pre>{{JSON.stringify(appTenantSubscription, null, 2)}}</pre>
</template>

<script setup>
  const route = useRoute()
  const { data } = (await useAsyncGql({
    operation: 'AppTenantSubscriptionById',
    variables: {
      appTenantSubscriptionId: route.params.id
    }
  }))
  const appTenantSubscription = data.value.appTenantSubscriptionById

</script>

<style>
</style>