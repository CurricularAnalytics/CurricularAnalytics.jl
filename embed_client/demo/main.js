import 'babel-polyfill'

// This file will build the demo
import Vue from 'vue'
import Demo from './Demo'

// toggle for demo purposes
import ToggleButton from 'vue-js-toggle-button'
Vue.use(ToggleButton)

Vue.config.productionTip = false

window.Vue = Vue
/* eslint-disable no-new */
new Vue({
  el: '#app',
  template: '<Demo/>',
  components: { Demo }
})
