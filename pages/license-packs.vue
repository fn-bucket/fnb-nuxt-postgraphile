<template>
  <div>
    <h1>LicensePack</h1>
    <el-table
      ref="multipleTableRef"
      :data="licensePacks"
      style="width: 100%"
      stripe
    >
      <el-table-column prop="key" label="Key" align="center" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            <NuxtLink :to="`/license-pack/${scope.row.id}`">{{scope.row.key}}</NuxtLink>
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
      <el-table-column prop="availability" label="Availability" width="200">
        <template #default="scope">
          <div style="display: flex; align-items: center">
            {{scope.row.availability}}
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="licenseTypes" label="License Types" width="200">
        <template #default="scope">
          <div style="display: flex; flex-direction: column">
            <el-tag v-for="lt in scope.row.licensePackLicenseTypes.nodes">{{ lt.licenseTypeKey }}</el-tag>
          </div>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script lang="ts" setup>
  const { data } = await useAsyncGql({
    operation: 'AllLicensePacks'
  })
  const licensePacks = data.value.allLicensePacks.nodes
</script>

<style>

</style>