<template lang="html">
  <card
    title="Project Information"
    :subtitle="`${this.project.name} \t\t ${this.project.balance} Tokens`"
  >
    <div style="padding: 12px">
      <h2>Project Information</h2>
      <p><b>Name of Project: </b>{{ this.project.name }}</p>
      <p>
        <b>Owner of Project: </b>
        {{
          this.project.ownedByUser
            ? this.project.owner.username
            : this.project.owner.name
        }}
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
      <b v-if="issues.length > 0">Bounties: </b>
      <div
        v-for="issue in this.issues"
        v-bind:key="issue.id"
      >
        <resume-issue :issue="issue" :project-id="project.id"></resume-issue>
      </div>
      <p>
        <a href="#" style="color: white" @click="createIssue">
          Create a bounty with reward
        </a>
      </p>
      <p>
        <a href="#" style="color: white" @click="showModal = true">
          Sponsor this project with Tokens
        </a>
      </p>
      <sponsor-project-modal
        :id-project="this.project.id"
        :owner-address="this.project.ownerAddress"
        v-if="showModal"
        @close="showModal = false; updateProjectBalance"
      >
      </sponsor-project-modal>
    </div>
  </card>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import Card from '@/components/Card.vue'
import { useStore } from 'vuex'
import SponsorProjectModal from '@/components/SponsorProjectModal.vue'
import ResumeIssue from "@/components/ResumeIssue.vue";

export default defineComponent({
  name: 'FullRecapProject',
  components: { ResumeIssue, Card, SponsorProjectModal },
  methods: {
    async updateProjectBalance() {
      const project = await this.contract.methods
        .getProjectByIdAndAddress(this.ownerAddress, this.id)
        .call()
      this.project.balance = project.balance
    },
    async createIssue() {
      this.$router.push({
        name: 'CreateIssue',
        query: {
          id: this.project?.id,
          ownerAddress: this.project?.ownerAddress,
        }
      })
    },
  },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const showModal = false
    const id = this.$route.query.id
    const ownerAddress = this.$route.query.ownerAddress
    const project: any = {
      id: '',
      name: '',
      owner: {
        name: '',
        username: '',
        balance: 0,
      },
      ownerAddress: 'project.owner',
      ownedByUser: true,
      balance: 0,
      contributors: [],
    }
    //const project = JSON.parse(this.$route.params.project.toString())
    const issues: never[] = []
    return { showModal, id, ownerAddress, project, issues }
  },
  async mounted() {
    const { contract, id, ownerAddress } = this
    this.issues = await contract.methods.getIssuesByProjectId(id).call()
    const project = await contract.methods
      .getProjectByIdAndAddress(ownerAddress, id)
      .call()
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
        account: {
          username: contributor.username,
          balance: contributor.balance,
          registered: contributor.registered,
        },
      })
    }
    this.project = {
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
    }
  },
})
</script>
