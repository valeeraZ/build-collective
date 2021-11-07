<template lang="html">
  <div class="home-wrapper" v-if="account">
    <card
      :title="account.username"
      :subtitle="`${balance} ETH \t\t${account.balance} Tokens`"
      :gradient="true"
    >
      <div class="explanations" v-if="enterpriseAccount">
        <h2>Enterprise Information</h2>
        <p><b>Name of Enterprise: </b>{{ enterpriseAccount.name }}</p>
        <p><b>Owner: </b>{{ enterpriseAccount.owner.username }}</p>
        <p><b>Members: </b>
          <span
            v-for="member in enterpriseMembers"
            v-bind:key="member.address"
          >
            {{ member.account.username }}
          </span>
        </p>
        <p><b>Balance: </b>{{ enterpriseAccount.balance }} Tokens</p>
      </div>
    </card>
    <spacer :size="24" />
    <div class="home">
      <card
        v-for="(link, index) in links"
        :key="index"
        :title="link.title"
        :subtitle="link.subtitle"
        :blue="true"
      >
        <router-link class="card-body" :to="link.link">
          Find it here
        </router-link>
      </card>
    </div>
  </div>
  <div class="signUp" v-else>
    <form @submit.prevent="signUp">
      <card
        title="Create an user account"
        subtitle="With a name and a balance of tokens"
      >
        <input
          type="text"
          class="input-username"
          v-model="username"
          placeholder="Username"
        />
        <input
          type="number"
          class="input-username"
          v-model="userBalance"
          placeholder="Balance of tokens"
        />
        <button type="submit" class="input-username">Submit</button>
      </card>
    </form>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import Spacer from '@/components/Spacer.vue'

export default defineComponent({
  name: 'Account',
  components: { Spacer, Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  computed: {
    links() {
      return [
        {
          title: 'Create an enterprise',
          subtitle: 'With a name, members and a balance',
          link: '/signup-enterprise',
        },
        {
          title: 'Create a project',
          subtitle: 'With a name, contributors and a balance',
          link: '/',
        },
      ]
    },
  },
  data() {
    const account = null
    const username = ''
    const userBalance = ''
    const enterpriseAccount = null
    const enterpriseName = ''
    const enterpriseBalance = ''
    const enterpriseMembers: any[] = []
    return {
      account,
      username,
      userBalance,
      enterpriseName,
      enterpriseAccount,
      enterpriseBalance,
      enterpriseMembers,
    }
  },
  methods: {
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async updateEnterpriseAccount() {
      const { address, contract } = this
      this.enterpriseAccount = await contract.methods.enterprise(address).call()
    },
    getMembersAccount(addressMember: string) {
      return this.contract.methods.user(addressMember).call()
    },
    async signUp() {
      const { contract, username, userBalance } = this
      const name = username.trim().replace(/ /g, '_')
      await contract.methods.signUp(name, userBalance).send()
      await this.updateAccount()
      this.username = ''
    },
    async addTokens() {
      const { contract } = this
      await contract.methods.addBalance(200).send()
      await this.updateAccount()
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    if (account.registered) this.account = account
    const enterpriseAccount = await contract.methods.enterprise(address).call()
    this.enterpriseAccount = enterpriseAccount
    const membersAddress = enterpriseAccount.membersAddress
    for (const membersAddressKey of membersAddress) {
      const member = await contract.methods.user(membersAddressKey).call()
      console.log(member)
      this.enterpriseMembers.push({
        address: membersAddressKey,
        account: member
      })
    }
  },
})
</script>

<style lang="css" scoped>
.home-wrapper {
  margin: auto 24px auto 24px;
}
.home {
  display: grid;
  align-items: center;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  grid-gap: 24px;
}
.card-body {
  padding: 12px;
  display: block;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: inherit;
  text-align: center;
  color: inherit;
  text-decoration: none;
  font-variant: small-caps;
}
.signUp {
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
