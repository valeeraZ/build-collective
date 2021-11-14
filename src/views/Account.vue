<template lang="html">
  <div class="home-wrapper" v-if="account">
    <card
      title="Your Account"
      :subtitle="`${account.username} \t\t${account.balance} Tokens`"
      :gradient="true"
    >
      <div class="explanations">
        <h2>Account Information</h2>
        <p><b>Name of Account: </b>{{ account.username }}</p>
        <p><b>Address: </b>{{ address }}</p>
        <p><b>ETH: </b>{{ balance }}</p>
        <p><b>Balance: </b>{{ account.balance }} Tokens</p>
      </div>
    </card>
    <spacer :size="24" />
    <card
      title="Your Enterprise"
      :subtitle="`${enterpriseAccount.name} \t\t${enterpriseAccount.balance} Tokens`"
      v-if="enterpriseAccount"
    >
      <div class="explanations" v-if="enterpriseAccount">
        <h2>Enterprise Information</h2>
        <p><b>Name of Enterprise: </b>{{ enterpriseAccount.name }}</p>
        <p><b>Owner: </b>{{ enterpriseAccount.owner.username }}</p>
        <p><b>Owner's Address: </b>{{ address }}</p>
        <div>
          <b>Members: </b>
          <p
            v-for="member in enterpriseMembers"
            v-bind:key="member.address"
            style="padding-left: 10px"
          >
            Account Name: {{ member.account.username }} &nbsp; Address:
            {{ member.address }}
          </p>
        </div>
        <p><b>Balance: </b>{{ enterpriseAccount.balance }} Tokens</p>
      </div>
    </card>
    <spacer :size="24" />
    <card
      title="Your Projects"
      :subtitle="`Number of Projects: ${projects.length}`"
      v-if="projects"
    >
      <div
        class="explanations"
        v-for="project in projects"
        v-bind:key="project.name"
      >
        <h2>Project Information</h2>
        <p><b>Name of Project: </b>{{ project.name }}</p>
        <p>
          <b>Owner of Project: </b>
          {{
            project.ownedByUser ? project.owner.username : project.owner.name
          }}
        </p>
        <div>
          <b>Contributors: </b>
          <p
            v-for="contributor in project.contributors"
            v-bind:key="contributor.address"
            style="padding-left: 10px"
          >
            Account Name: {{ contributor.account.username }} &nbsp; Address:
            {{ contributor.address }}
          </p>
        </div>
        <p><b>Balance of Project: </b>{{ project.balance }} Tokens</p>
      </div>
    </card>
    <spacer :size="24" />
    <div class="home">
      <card
        title="Create an enterprise"
        subtitle="With a name, members and a balance"
        :blue="true"
        v-if="!enterpriseAccount"
      >
        <router-link class="card-body" to="/signup-enterprise">
          Create your enterprise
        </router-link>
      </card>
      <card
        title="Create a project"
        subtitle="With a name, contributors and a balance"
        :blue="true"
      >
        <router-link class="card-body" to="/create-project">
          Create your project
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
  data() {
    const account = null
    const username = ''
    const userBalance = ''
    const enterpriseAccount = null
    const enterpriseMembers: any[] = []
    const projects: any[] = []
    return {
      account,
      username,
      userBalance,
      enterpriseAccount,
      enterpriseMembers,
      projects,
    }
  },
  methods: {
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.getUserByAddress(address).call()
    },
    async updateEnterpriseAccount() {
      const { address, contract } = this
      this.enterpriseAccount = await contract.methods
        .getEnterpriseByAddress(address)
        .call()
    },
    getMembersAccount(addressMember: string) {
      return this.contract.methods.getUserByAddress(addressMember).call()
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
    const account = await contract.methods.getUserByAddress(address).call()
    if (account.registered) this.account = account
    const enterpriseAccount = await contract.methods
      .getEnterpriseByAddress(address)
      .call()
    if (enterpriseAccount.name) {
      this.enterpriseAccount = enterpriseAccount
      const membersAddress = enterpriseAccount.membersAddress
      for (const membersAddressKey of membersAddress) {
        const member = await contract.methods
          .getUserByAddress(membersAddressKey)
          .call()
        this.enterpriseMembers.push({
          address: membersAddressKey,
          account: member,
        })
      }
    }
    const projects = await contract.methods.getProjectsByAddress(address).call()
    if (projects.length > 0) {
      for (const project of projects) {
        let name = project.name
        let owner = null
        if (project.ownedByUser) {
          owner = await contract.methods.getUserByAddress(project.owner).call()
        } else {
          owner = await contract.methods
            .getEnterpriseByAddress(project.owner)
            .call()
        }
        let balance = project.balance
        const contributorsAddress = project.contributorsAddress
        let contributors = []
        for (const contributorsAddressKey of contributorsAddress) {
          const contributor = await contract.methods
            .getUserByAddress(contributorsAddressKey)
            .call()
          contributors.push({
            address: contributorsAddressKey,
            account: contributor,
          })
        }
        this.projects.push({
          name: name,
          owner: owner,
          ownedByUser: project.ownedByUser,
          balance: balance,
          contributors: contributors,
        })
      }
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
