<template lang="html">
  <card
    title="Explore some Projects"
    subtitle="Try to fix some issues and be a bounty hunter !">
    <div v-for="project in projects" v-bind:key="project.name">
      <resume-project :project="project"></resume-project>
    </div>
  </card>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import Card from '@/components/Card.vue'
import { useStore } from 'vuex'
import ResumeProject from '@/components/ResumeProject.vue'

export default defineComponent({
  name: 'ExplorerProjects',
  components: { Card, ResumeProject },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const projects: any = []
    return { projects }
  },
  async mounted() {
    const userAddresses = await this.contract.methods.getAllUsers().call()
    for (const address of userAddresses) {
      const projects = await this.contract.methods.getProjectsByAddress(address).call()
      if (projects.length > 0) {
        for (const project of projects) {
          let name = project.name
          let owner = null
          if (project.ownedByUser) {
            owner = await this.contract.methods.getUserByAddress(project.owner).call()
          } else {
            owner = await this.contract.methods
              .getEnterpriseByAddress(project.owner)
              .call()
          }
          let balance = project.balance
          const contributorsAddress = project.contributorsAddress
          let contributors = []
          for (const contributorsAddressKey of contributorsAddress) {
            const contributor = await this.contract.methods
              .getUserByAddress(contributorsAddressKey)
              .call()
            contributors.push({
              address: contributorsAddressKey,
              account: {
                username: contributor.username,
                balance: contributor.balance,
                registered: contributor.registered,
              },
            })
          }
          this.projects.push({
            id: project.id,
            name: name,
            owner: {
              name: owner.name || undefined,
              username: owner.username || undefined,
              balance: owner.balance,
            },
            ownerAddress: project.owner,
            ownedByUser: project.ownedByUser,
            balance: balance,
            contributors: contributors,
          })
        }
      }
    }
  },
})
</script>
