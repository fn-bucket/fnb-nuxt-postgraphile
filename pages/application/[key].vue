<template>
  <pre>{{JSON.stringify(application, null, 2)}}</pre>
</template>

<script setup>
  const route = useRoute()
  const { data } = (await useAsyncGql({
    operation: 'ApplicationByKey',
    variables: {
      key: route.params.key
    }
  }))
  const application = data.value.applicationByKey

</script>

<style>
</style>