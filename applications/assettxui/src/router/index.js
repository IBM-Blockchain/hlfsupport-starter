import Vue from "vue";
import VueRouter from "vue-router";
import HelloView from "../views/HelloView.vue";
import GetView from "../views/GetView";
import CreateView from "../views/CreateView";
import GetAllView from '../views/GetAllView';
import ActiveTxsView from "../views/ActiveTxsView";

Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    name: "HelloView",
    component: HelloView
  },
  {
    path: "/get",
    name: "GetView",
    component: GetView,
    
  },
  {
    path: "/get/:id",
    name: "GetView",
    component: GetView,
    props:true
  },
  {
    path: "/getall",
    name: "GetAllView",
    component: GetAllView
  },
  {
    path: "/create",
    name: "CreateView",
    component: CreateView
  },
  {
    path: "/txstatus",
    name: "TxStatus",
    component: ActiveTxsView
  }
];

const router = new VueRouter({
  routes
});

export default router;