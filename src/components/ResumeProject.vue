<template lang="html">
  <div style="padding: 12px">
    <h2>Project Information</h2>
    <p><b>Name of Project: </b>{{ project.name }}</p>
    <p>
      <b>Owner of Project: </b>
      {{ project.ownedByUser ? project.owner.username : project.owner.name }}
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
    <a href="#" @click="gotoFullRecap">
      See the full summary about this project
    </a>
  </div>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import { useStore } from 'vuex'

export default defineComponent({
  name: 'ResumeProject',
  props: { project: Object },
  methods: {
    gotoFullRecap() {
      this.$router.push({
        name: 'FullRecapProject',
        params: {
          project: JSON.stringify(this.project),
        },
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
  mounted() {
    console.log(this.project)
  }
})
</script>
