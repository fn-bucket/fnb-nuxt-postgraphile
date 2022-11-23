<template>
  <div>
    <h1>fnb-nuxt-postgraphile</h1>
    <h2>a boilerplate for graphql apps built with <a target="_blank" href="https://www.vuejs.org">vue3</a>, <a target="_blank" href="https://www.nuxt.com">nuxt3</a> and <a target="_blank" href="https://www.graphile.org/postgraphile/">postgraphile</a>.</h2>
    <!-- default config is for bootstrapping local-only no password login -->
    <BootstrapLogin></BootstrapLogin>
  </div>
</template>

<script lang="ts" setup>
import BootstrapLogin from '~~/components/_common/BootstrapLogin.vue';

</script>

<style>

</style>