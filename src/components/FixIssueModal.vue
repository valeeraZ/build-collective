<template lang="html">
  <transition name="modal">
    <div class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <div class="modal-header">
            <h2>Declare that you have fixed this issue and get the bounty</h2>
          </div>

          <div class="modal-body">
            <h3>By confirming that you have fixed this issue, you will get the amount of reward of ETH.</h3>
            <button class="modal-default-button" style="color: red" @click="fixIssue">
              Confirm
            </button>
          </div>

          <div class="modal-footer">
            <button class="modal-default-button" @click="this.$emit('close')">
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import { useStore } from 'vuex'

export default defineComponent({
  name: 'FixIssueModal',
  props: {
    idProject: String,
    idIssue: String,
  },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const error = false
    const balance = 0
    const amount = 100
    return { error, balance, amount }
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.getUserByAddress(address).call()
    this.balance = account.balance
  },
  methods: {
    async fixIssue() {
      const { idProject, idIssue, address } = this
      const res = await this.contract.methods.fixAnIssue(idProject, idIssue, address).send()
      console.log('res: ' + res)
      this.$emit('close')
      location.reload()
    },
  },
})
</script>

<style lang="css">
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: table;
  transition: opacity 0.3s ease;
}

.modal-wrapper {
  display: table-cell;
  vertical-align: middle;
}

.modal-container {
  width: 700px;
  margin: 0px auto;
  padding: 20px 30px;
  background-color: #fff;
  border-radius: 2px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
  transition: all 0.3s ease;
  font-family: Helvetica, Arial, sans-serif;
}

.modal-header {
  margin-top: 0;
  color: #42b983;
}

.modal-body {
  margin: 20px 0;
  color: black;
}

.modal-footer {
  margin-bottom: 40px;
}

.modal-default-button {
  float: right;
  margin-left: 10px;
}

.modal-enter {
  opacity: 0;
}

.modal-leave-active {
  opacity: 0;
}

.modal-enter .modal-container,
.modal-leave-active .modal-container {
  -webkit-transform: scale(1.1);
  transform: scale(1.1);
}

.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: #42b983;
  font-family: inherit;
  font-size: 1.3rem;
}
</style>
