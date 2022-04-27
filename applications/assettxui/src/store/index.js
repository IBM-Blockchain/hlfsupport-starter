import Vue from "vue";
import Vuex from "vuex";

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    currentorg: 'org1',
    activeTxs:[],
    activeAsset:null
  },
  mutations: {
    setOrg(state, orgid) {
      state.currentorg = orgid;
    },
    addTx(state,tx){
      state.activeTxs.push(tx);
    },
    setActiveAsset(state,asset){
      state.activeAsset=asset;
    }
  },
  actions: {},
  getters: {
    currentOrg(state) {
      return state.currentorg;
    },
    activeTxs(state){
      return state.activeTxs;
    }
  },
});
