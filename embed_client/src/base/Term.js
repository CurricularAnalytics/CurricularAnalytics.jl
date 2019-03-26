// A renderless component to manage the state of a curriculum term

import Vue from 'vue'
import { sumBy, sortBy } from 'lodash'

export default Vue.extend({
  data () {
    return {
      // Term id
      id: null,

      // Term Items
      items: [],

      // Term Position
      position: null,

      // Term Name
      name: '',

      // New term created through the interface
      new: false,

      // Parent curriculum reference
      curriculum: {}
    }
  },

  computed: {

    // Compute the term complexity as a sum of the items' complexity
    complexity () {
      return sumBy(this.items, 'complexity')
    },

    // Compute term blocking as a sum of the items' blocking
    blocking () {
      return sumBy(this.items, 'blocking')
    },

    // Compute term delaying as a sum of the items' delaying
    delaying () {
      return sumBy(this.items, 'delaying')
    },

    // Compute term credits as a sum of the items' credits
    credits () {
      return sumBy(this.items, 'credits')
    },

    // Term header to be displayed in the interface
    header () {
      return this.name
    },

    // Term footer to be displayed in the interface
    footer () {
      return `Complexity: ${this.complexity}`
    },

    // Is this the last term in the curriculum
    isLast () {
      return this.curriculum.lastTerm === this
    },

    // Last item in the items array
    lastItem () {
      return this.items[this.items.length - 1]
    },

    // Position of the last item or -1 if items is empty
    lastItemPosition () {
      return this.lastItem ? this.lastItem.position : -1
    }
  },

  methods: {

    // Add an item to the term by using the curriculum.components.Item as the base vue instance
    addItem (item = {}) {
      const newItem = new this.curriculum.components.Item({
        data: Object.assign({
          id: Math.random().toString(36).substring(7),
          new: true,
          name: '',
          nameSub: '',
          nameCanonical: '',
          position: this.lastItemPosition + 1,
          term: this
        }, item)
      })

      this.items.push(newItem)
      return newItem
    },

    // Order items by their position and reset their position as their respective index
    repositionItems () {
      this.items = sortBy(this.items.slice(0), 'position')
      this.items.forEach((item, index) => {
        item.position = index
      })
    },

    // Remove the term from the curriculum only if items is empty
    remove () {
      if (this.items.length) return

      const terms = this.curriculum.terms
      terms.splice(terms.indexOf(this), 1)
      this.$destroy()
    },

    // Export term to json matching the type
    export (type) {
      const general = {
        name: this.name,
        id: this.id,
        position: this.position,
        credits: this.credits,
        complexity: this.complexity,
        delaying: this.delaying,
        blocking: this.blocking,
        new: this.new
      }

      switch (type) {
        case 'verbose':
          return Object.assign(general, {
            curriculum_items: this.items.map(i => i.export(type))
          })
        default:
          return Object.assign(general, {
            items: this.items.map(i => i.export(type))
          })
      }
    }
  }
})
