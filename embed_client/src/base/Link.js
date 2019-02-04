// A renderless component to manage the state of a curriculum link

import Vue from 'vue'
import { maxBy } from 'lodash'

export default Vue.extend({
  data () {
    return {
      // Requisite type ('prereq', 'coreq', or 'strict-coreq')
      type: null,

      // Source item reference (may occasionally be null, if it is a new link still being created)
      source: null,

      // Target item reference (should always be defined)
      target: null,

      // New link created through the interface
      new: false
    }
  },

  created () {
    if (this.source) this.source.targetLinks.push(this)
    if (this.target) this.target.sourceLinks.push(this)
  },

  watch: {
    // When the source is changed make sure the link is removed from the targetLinks
    // of the oldSource and added to the targetLinks of the newSource
    source (newSource, oldSource) {
      if (oldSource) {
        const targetLinks = oldSource.targetLinks
        targetLinks.splice(targetLinks.indexOf(this), 1)
      }
      if (newSource && !newSource.targetLinks.includes(this)) newSource.targetLinks.push(this)
    },

    // When the target is changed make sure the link is removed from the sourceLinks
    // of the oldTarget and added to the sourceLinks of the newTarget
    target (newTarget, oldTarget) {
      if (oldTarget) {
        const sourceLinks = oldTarget.sourceLinks
        sourceLinks.splice(sourceLinks.indexOf(this), 1)
      }
      if (newTarget && !newTarget.sourceLinks.includes(this)) newTarget.sourceLinks.push(this)
    }
  },

  computed: {
    // ID of the link is the concatenated source and target ids
    id () {
      if (this.source && this.target) return `${this.source.id},${this.target.id}`
    },
    allPaths_link () {
      return {
        source: this.permute_link('source'),
        target: this.permute_link('target')
      }
    },
    delayingPath_link () {
      const itemCount = (path) => path.items.length
      const longestSource = maxBy(this.allPaths_link.source, itemCount) || {items: [], links: []}
      const longestTarget = maxBy(this.allPaths_link.target, itemCount) || {items: [], links: []}
      return {
        items: longestSource.items.slice(0).reverse().slice(0, -1).concat(longestTarget.items),
        links: longestSource.links.slice(0).reverse().concat(longestTarget.links)
      }
    },
    // Link type name (e.g. 'prerequisite', 'corequisite', 'strict-corequisite')
    typeName () {
      return this.type + 'uisite'
    },

    // Get the curriculum main item reference from the target
    mainItem () {
      return this.target.mainItem
    },

    // Get the curriculum newLink reference from the target
    newLink () {
      return this.target.newLink
    },

    // Get the curriculum highlightLink reference from the target
    highlightLink () {
      return this.target.highlightLink
    },

    // Is mainItem blocking this link
    isBlocked () {
      return (this.source === this.mainItem || this.source.isBlocked) && this.target.isBlocked
    },

    // Is this link highlighted
    isHighlighted () {
      return this.newLink === this || this.highlightLink === this
    },

    // Is mainItem delaying this link
    isDelayed () {
      return this.source.isDelayed && this.target.isDelayed && this.delayingPath_link.links.includes(this)
    }
  },

  methods: {
    permute_link (direction, item = this.mainItem, items = [], links = [], paths = []) {
      const nextLinks = item[`${direction}Links`]

      // sanity check to not encounter loops
      if (items.includes(item)) return
      else items.push(item)

      // if there are more links to track continue down the tree
      // alert(nextLinks.length)
      if (nextLinks.length) {
        nextLinks.forEach(link => {
          if (!link[direction]) return
          const nextItem = link[direction]
          const nextLinks = links.slice(0)
          nextLinks.push(link)
          this.permute_link(direction, nextItem, items.slice(0), nextLinks, paths)
        })
      // otherwise add the completed path to the paths array
      } else {
        paths.push({items, links})
      }

      return paths
    },
    // Remove the link and any references to it by the source and target
    remove () {
      if (this.source) {
        const targetLinks = this.source.targetLinks
        targetLinks.splice(targetLinks.indexOf(this), 1)
      }

      if (this.target) {
        const sourceLinks = this.target.sourceLinks
        sourceLinks.splice(sourceLinks.indexOf(this), 1)
      }

      this.$destroy()
    },

    // Export link to json
    export () {
      return {
        source_id: this.source.id,
        target_id: this.target.id,
        type: this.type
      }
    }
  }
})
