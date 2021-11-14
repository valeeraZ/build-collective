import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import store from '@/store'
import SignIn from '@/views/SignIn.vue'
import Account from '@/views/Account.vue'
import SignUpEnterprise from '@/views/SignUpEnterprise.vue'
import CreateProject from '@/views/CreateProject.vue';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'SignIn',
    component: SignIn,
  },
  {
    path: '/signup-enterprise',
    name: 'SignUpEnterprise',
    component: SignUpEnterprise,
  },
  {
    path: '/account',
    name: 'Account',
    component: Account,
  },
  {
    path: '/create-project',
    name: 'createProject',
    component: CreateProject,
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
})

router.beforeEach((to, _from, next) => {
  if (to.name !== 'SignIn' && !store.state.account.address) {
    next({ name: 'SignIn' })
  } else {
    next()
  }
})

export default router
