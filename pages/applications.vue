<template>
  <div>
    <h1>Application</h1>
    <el-table
      ref="multipleTableRef"
      :data="applications"
      style="width: 100%"
      stripe
    >
      <el-table-column prop="key" label="Key" align="center" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            <NuxtLink :to="`/application/${scope.row.key}`">{{scope.row.key}}</NuxtLink>
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="name" label="Name" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            {{scope.row.name}}
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="licenseTypes" label="License Types" width="200">
        <template #default="scope">
          <div style="display: flex; flex-direction: column">
            <el-tag v-for="lt in scope.row.licenseTypes.nodes">{{ lt.key }}</el-tag>
          </div>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script lang="ts" setup>
  const { data } = await useAsyncGql({
    operation: 'AllApplications'
  })
  const applications = data.value.allApplications.nodes
</script>

<style>

</style>