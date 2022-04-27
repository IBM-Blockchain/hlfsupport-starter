<template>
  <div id="app">
    <div class="section">

      <div class="section">

        <div class="level">
          <div class="level-item">
            <a v-bind:class="{ 'is-focused' : currentOrg==='org1'}" @click="useOrg1" class="button is-primary is-outlined is-large">Organization 1</a>
          </div>
          <div class="level-item">
            <a  v-bind:class="{ 'is-focused' : currentOrg==='org2'}"  @click="useOrg2"  class="button is-primary is-outlined is-large">Organization 2</a>
          </div>
          </div>
        </div>

      <div class="container">
        <MainView/>
      </div>

      <div class="section">
        <router-view/>
      </div>
    </div>
  </div>
</template>

<script>
import MainView from '@/views/MainView'
export default {
  name: 'App',
  components: {
    MainView
  },
  methods: {
    useOrg1(){
      console.log('org1')
      this.$store.commit('setOrg','org1')
    },
    useOrg2(){
      console.log('org2')
      this.$store.commit('setOrg','org2')
    }
  },
  computed:{
    currentOrg() {
      return this.$store.state.currentorg;
    }
  }
}
</script>

<style>
/* #app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
} */
</style>
