<template>
  <pre>{{JSON.stringify(licensePack, null, 2)}}</pre>
</template>

<script setup>
  const route = useRoute()
  const { data } = (await useAsyncGql({
    operation: 'LicensePackById',
    variables: {
      id: route.params.id
    }
  }))
  const licensePack = data.value.licensePackById

</script>

<style>
</style>