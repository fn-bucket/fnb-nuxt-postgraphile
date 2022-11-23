import { ID_INJECTION_KEY } from "element-plus";
import element from 'element-plus'
// import 'element-plus/es/components/table/style/css'
// import 'element-plus/es/components/select/style/css'

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.use(element)
  nuxtApp.vueApp.provide(ID_INJECTION_KEY, {
    prefix: Math.floor(Math.random() * 10000),
    current: 0,
  });
})