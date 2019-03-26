// A renderless component to manage the state of a curriculum

import Vue from 'vue'
import { sumBy, flatten } from 'lodash'

export default Vue.extend({
  data () {
    return {
      // Curriculum Terms
      terms: [],

      // Components used to manage the curriculum state (e.g. 'base/'{Curriculum, Term, Item, Link})
      components: null,

      // Keep track of original curriculum format
      originalFormat: 'default',

      // Interface states will be set by the curriculum interface
      selectedItem: null,   // instance of the selected curriculum-item
      hoveredItem: null,    // instance of the hovered curriculum-item
      draggedItem: null,    // instance of the dragged curriculum-item
      newLink: null,        // link placeholder when creating a new link
      highlightLink: null   // link being highlighted
    }
  },

  computed: {

    // Compute the curriculum complexity as a sum of the terms' complexity
    complexity () {
      return sumBy(this.terms, 'complexity')
    },

    // Compute curriculum blocking as a sum of the terms' blocking
    blocking () {
      return sumBy(this.terms, 'blocking')
    },

    // Compute curriculum delaying as a sum of the terms' delaying
    delaying () {
      return sumBy(this.terms, 'delaying')
    },

    // Compute curriculum credits as a sum of the terms' credits
    credits () {
      return sumBy(this.terms, 'credits')
    },

    // Last term in the terms array
    lastTerm () {
      return this.terms[this.terms.length - 1]
    },

    // Position of last term or -1 if terms is empty
    lastTermPosition () {
      return this.lastTerm ? this.lastTerm.position : -1
    },

    // Compiled array of term items
    items () {
      return flatten(this.terms.map(term => term.items))
    },

    // Compiled array of item sourceLinks
    links () {
      return flatten(this.items.map(item => item.sourceLinks))
    },

    // Main item to display blocking / delaying / requisite associations for
    mainItem () {
      // If newLink is initialized or highlightLink is set don't return a main item
      if (this.newLink || this.highlightLink) return null
      else return this.selectedItem || this.hoveredItem
    },

    // Computed exports store to make it easier to watch for deep export changes
    exports () {
      return {
        basic: this.export('basic'),
        verbose: this.export('verbose'),
        default: this.export('default')
      }
    },

    exportOriginal () {
      return this.export()
    }
  },

  methods: {

    // Add a term to the curriculum by using the components.Term as the base vue instance
    addTerm (term = {}) {
      const newTerm = new this.components.Term({
        data: Object.assign({
          id: Math.random().toString(36).substring(7),
          new: true,
          name: `Term ${this.lastTermPosition + 2}`,
          position: this.lastTermPosition + 1,
          curriculum: this,
          components: this.components
        }, term)
      })

      this.terms.push(newTerm)
      return newTerm
    },

    // Export curriculum to json matching the type
    export (type = this.originalFormat) {
      const general = {
        credits: this.credits,
        complexity: this.complexity,
        delaying: this.delaying,
        blocking: this.blocking
      }

      switch (type) {
        case 'basic':
          return Object.assign(general, {
            courses: this.items.map(i => i.export(type))
          })
        case 'verbose':
          return Object.assign(general, {
            curriculum_terms: this.terms.map(t => t.export(type))
          })
        default:
          return Object.assign(general, {
            terms: this.terms.map(t => t.export(type))
          })
      }
    },

    // Transitive reduction to remove redundant forward edges
    transitiveReduction () {
      this.items.forEach(item => {
        const backwardItems = flatten(item.allPaths.source.map(t => t.items.slice(2)))

        item.sourceLinks.forEach(link => {
          if (backwardItems.includes(link.source)) link.remove()
        })
      })
    }
  }
})
