<template>
  <div>
    <h1>Subscriptions</h1>
    <el-table
      ref="multipleTableRef"
      :data="appTenantSubscriptions"
      style="width: 100%"
      stripe
    >
      <el-table-column prop="key" label="Key" align="center" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            <NuxtLink :to="`/app-tenant-subscription/${scope.row.id}`">{{scope.row.licensePack.key}}</NuxtLink>
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="appTenant" label="App Tenant" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            <NuxtLink :to="`/app-tenant/${scope.row.appTenant.id}`">{{scope.row.appTenant.name}}</NuxtLink>
          </div>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script lang="ts" setup>
  const { data } = await useAsyncGql({
    operation: 'AllAppTenantSubscriptions'
  })
  const appTenantSubscriptions = data.value.allAppTenantSubscriptions.nodes
</script>

<style>

</style>