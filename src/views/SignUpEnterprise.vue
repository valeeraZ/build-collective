<template lang="html">
  <form @submit.prevent="enterpriseSignUp">
    <card
      title="Create an enterprise account"
      subtitle="With a name, some members and a balance of tokens"
    >
      <input
        type="text"
        class="input-username"
        v-model="enterpriseName"
        placeholder="Enterprise name"
      />
      <span class="input-username">Choose one or multiple members</span>
      <div
        v-for="user in users"
        v-bind:key="user.address"
        class="input-username"
      >
        <input
          type="checkbox"
          :id="user.address"
          :value="user.address"
          v-model="enterpriseMembers"
        />
        <span>{{ user.account.username }}</span>
      </div>
      <input
        type="number"
        class="input-username"
        v-model="enterpriseBalance"
        placeholder="Balance of tokens"
      />
      <button type="submit" class="input-username">Submit</button>
    </card>
  </form>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'

export default defineComponent({
  name: 'SignUpEnterprise',
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    console.log(contract)
    return { address, contract }
  },
  data() {
    // array of all users on the block chain
    // for enterprise to select members
    const users: any[] = []
    const enterpriseAccount = null
    const enterpriseName = ''
    const enterpriseBalance = ''
    const enterpriseMembers: never[] = []
    return {
      enterpriseName,
      users,
      enterpriseAccount,
      enterpriseBalance,
      enterpriseMembers,
    }
  },
  methods: {
    async updateEnterpriseAccount() {
      const { address, contract } = this
      this.enterpriseAccount = await contract.methods.enterprise(address).call()
    },
    async enterpriseSignUp() {
      const { contract, enterpriseName, enterpriseMembers, enterpriseBalance } =
        this
      const name = enterpriseName.trim().replace(/ /g, '_')
      await contract.methods.enterpriseSignUp(name, enterpriseMembers, enterpriseBalance).send()
      await this.updateEnterpriseAccount()
      await this.$router.push({ name: 'Account' })
    },
  },
  async mounted() {
    const { address, contract } = this
    this.enterpriseAccount = await contract.methods.enterprise(address).call()
    const userAddresses = await contract.methods.getAllUsers().call()
    for (const userAddressesKey of userAddresses) {
      const account = await contract.methods.user(userAddressesKey).call()
      this.users.push({ address: userAddressesKey, account: account })
    }
  },
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 100%;
  margin: auto;
}

.explanations {
  padding: 12px;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}

.select-type,
.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}
</style>
