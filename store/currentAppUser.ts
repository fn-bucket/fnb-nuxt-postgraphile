// stores/currentAppUser.js
import { defineStore } from 'pinia'

interface CurrentAppUser {
  role: String,
  appUserId: String,
  appTenantId: String,
  permissions: [String]
}

interface AppUserState {
  currentAppUser: CurrentAppUser | null
}

export const useCurrentAppUserStore = defineStore('currentAppUser', {
  state: (): AppUserState => {
    return { 
      currentAppUser: null
    }
  },
  getters: {
    loggedIn: (state) => state.currentAppUser !== null,
  },
  actions: {
    setCurrentAppUser(user: any) {
      this.currentAppUser = user
    }
  },
  persist: true
})