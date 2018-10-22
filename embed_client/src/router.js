import Vue from 'vue'
import Router from 'vue-router'
import Graph from './views/Graph.vue'

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'graph',
      component: Graph
    }
  ]
})
