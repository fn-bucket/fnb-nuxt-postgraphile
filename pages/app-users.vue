<template>
  <div>
    <h1>App Users</h1>
    <el-table
      ref="multipleTableRef"
      :data="appUsers"
      style="width: 100%"
      stripe
    >
    <el-table-column prop="username" label="Username" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            <NuxtLink :to="`/app-user/${scope.row.id}`">{{scope.row.username}}</NuxtLink>
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="fullName" label="Name" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            {{scope.row.contact.fullName}}
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="recoveryEmail" label="Email" width="300">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            {{scope.row.recoveryEmail}}
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="licenses" label="Licenses" width="300">
        <template #default="scope">
          <div style="display: flex; flex-direction: column">
            <el-tag v-for="l in scope.row.licenses.nodes">{{ l.licenseTypeKey }}</el-tag>
          </div>
        </template>
      </el-table-column>
    </el-table>
    <hr>
  </div>
</template>

<script lang="ts" setup>
  const { data } = (await useAsyncGql({
    operation: 'AllAppUsers'
  }))
  const appUsers = data.value.allAppUsers.nodes
</script>

<style>

</style>