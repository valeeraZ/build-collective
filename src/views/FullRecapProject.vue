<template lang="html">
  <card></card>
  <card
    title="Project Information"
    :subtitle="`${this.project.name} \t\t ${this.project.balance} Tokens`"
  >
    <div style="padding: 12px">
      <h2>Project Information</h2>
      <p><b>Name of Project: </b>{{ this.project.name }}</p>
      <p>
        <b>Owner of Project: </b>
        {{ this.project.ownedByUser ? this.project.owner.username : this.project.owner.name }}
        &nbsp;
        <b>Address: </b>
        {{ this.project.ownerAddress }}
      </p>
      <div>
        <b>Contributors: </b>
        <p
          v-for="contributor in this.project.contributors"
          v-bind:key="contributor.address"
          style="padding-left: 10px"
        >
          Account Name: {{ contributor.account.username }} &nbsp; Address:
          {{ contributor.address }}
        </p>
      </div>
      <p><b>Balance of Project: </b>{{ this.project.balance }} Tokens</p>
      <p><b>Issues: </b> {{ this.issues }}</p>
    </div>
  </card>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import Card from '@/components/Card.vue'
import { useStore } from 'vuex'

export default defineComponent({
  name: 'FullRecapProject',
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const project = JSON.parse(this.$route.params.project.toString())
    const issues: never[] = []
    return { project, issues }
  },
  async mounted() {
    const { contract, project } = this
    this.issues = await contract.methods.getIssuesByProjectId(project.id).call()
  },
})
</script>
