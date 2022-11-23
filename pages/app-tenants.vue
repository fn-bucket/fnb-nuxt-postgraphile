<template>
  <div>
    <h1>App Tenants</h1>
    <el-table
      ref="multipleTableRef"
      :data="appTenants"
      style="width: 100%"
      stripe
    >
    <el-table-column prop="name" label="Name" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            <NuxtLink :to="`/app-tenant/${scope.row.id}`">{{scope.row.name}}</NuxtLink>
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="type" label="Type" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            {{scope.row.type}}
          </div>
        </template>
      </el-table-column>
    </el-table>
    <hr>
  </div>
</template>

<script lang="ts" setup>
  // https://nuxt-graphql-client.web.app/getting-started/gql-functions
  const { data } = (await useAsyncGql({
    operation: 'AllAppTenants'
  }))
  const appTenants = data.value.allAppTenants.nodes
</script>

<style>

</style>