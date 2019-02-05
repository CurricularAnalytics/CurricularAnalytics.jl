// A renderless component to manage the state of a curriculum item

import Vue from 'vue'
import { maxBy, minBy, flatten, uniq, compact } from 'lodash'

export default Vue.extend({
  data () {
    return {
      id: null,           // Item id
      term: {},           // Term state reference
      position: null,     // Item's position in its term
      name: '',           // Item name
      credits: 0,         // Item credits
      sourceLinks: [],    // Item source links
      targetLinks: [],    // Item target links

      // attributes that are set via the curriculum interface
      dragX: null,        // Drag x position
      dragY: null,        // Drag y position
      new: false          // New item created through the interface
    }
  },

  computed: {
    // All pathway permutations from this curriculum item
    allPaths () {
      return {
        source: this.permute('source'),
        target: this.permute('target')
      }
    },
    // All requisite associations with this item
    associations () {
      return {
        'prereq': this.getRequisiteItems('prereq'),
        'coreq': this.getRequisiteItems('coreq'),
        'strict-coreq': this.getRequisiteItems('strict-coreq'),
        'pre-coreq-field': flatten(this.allPaths.source.map(path => path.items.slice(0).reverse().slice(0, -2))),
        'unblocked': flatten(this.allPaths.target.map(path => path.items.slice(1, 2))),
        'unblocked-field': flatten(this.allPaths.target.map(path => path.items.slice(0).reverse().slice(0, -2)))
      }
    },

    itemIndex () {
      return this.term.items.indexOf(this)
    },

    // Computes {items, links} that are involved in this item's delaying path
    delayingPath () {
      const itemCount = (path) => path.items.length
      const longestSource = maxBy(this.allPaths.source, itemCount) || {items: [], links: []}
      const longestTarget = maxBy(this.allPaths.target, itemCount) || {items: [], links: []}
      // const maxSource = Math.max.apply(Math, this.allPaths2.source.map(function (path) { return path.currentCost }))
      // console.log(maxSource)
      // const longestSource = this.allPaths2.source.find(function (path) { return path.currentCost === maxSource })
      // const maxTarget = Math.max.apply(Math, this.allPaths2.target.map(function (path) { return path.currentCost }))
      // console.log(maxTarget)
      // const longestTarget = this.allPaths2.target.find(function (path) { return path.currentCost === maxTarget })
      // const longestTarget = Math.max.apply(Math, this.allPaths2.target.currentCost)
      // var res = Math.max.apply(Math,array.map(function(o){return o.y;}))
      return {
        items: longestSource.items.slice(0).reverse().slice(0, -1).concat(longestTarget.items),
        links: longestSource.links.slice(0).reverse().concat(longestTarget.links)
      }
    },

    // Computes elements (items and links) that are involved in this item's delaying path
    // delayingElements () {
      // return this.delayingPath.items.concat(this.delayingPath.links)
    // },

    // Computes {items, links} that are involved in this item's blocking tree
    blockingTree () {
      const items = uniq(flatten(this.allPaths.target.map(s => s.items))).filter(item => item !== this)
      const links = uniq(flatten(this.allPaths.target.map(s => s.links)))
      return {items, links}
    },

    // Computes {items, links} that are involved in this item's previous (or reverse blocking) tree
    previousTree () {
      const items = uniq(flatten(this.allPaths.source.map(s => s.items))).filter(item => item !== this)
      const links = uniq(flatten(this.allPaths.source.map(s => s.links)))
      return {items, links}
    },

    // Computes elements (items and links) that are involved in this item's blocking tree
    blockingElements () {
      return this.blockingTree.items.concat(this.blockingTree.links)
    },

    // Computes delaying factor
    delaying () {
      return this.delayingPath.items.length
    },

    // Computes blocking factor
    blocking () {
      return this.blockingTree.items.length
    },

    // Computes complexity factor
    complexity () {
      return this.blocking + this.delaying
    },

    // Is mainItem blocking this item
    isBlocked () {
      return this.mainItem && this.mainItem.blockingTree.items.includes(this)
    },

    // Is mainItem delaying this item
    isDelayed () {
      return this.mainItem && this.mainItem.delayingPath.items.includes(this)
    },

    // Is this item highlighted
    isHighlighted () {
      return (this.newLink && (this.newLink.source === this || this.newLink.target.newLinkOptions[this.newLink.type].includes(this))) ||
             (this.highlightLink && (this.highlightLink.source === this || this.highlightLink.target === this))
    },

    // Requisite association with the mainItem
    requisiteAssociation () {
      let association = this.mainItem === this || (this.newLink && this.newLink.target === this) ? 'this-item' : null
      if (this.mainItem) {
        for (const key in this.mainItem.associations) {
          if (this.mainItem.associations.hasOwnProperty(key)) {
            this.mainItem.associations[key].forEach(item => {
              if (item === this) association = key
            })
          }
        }
      }
      return association
    },

    // Value to be used for this item's interface components
    value () {
      return this.complexity
    },

    // Title to be used for this item's interface components
    title () {
      return this.truncate(this.name)
    },

    // Sub title to be used for this item's interface components
    titleSub () {
      return this.truncate(this.nameSub)
    },

    canonicalSub () {
      if (this.nameCanonical) {
        return '(' + this.truncate(this.nameCanonical) + ')'
      }
    },

    truncateLength () {
      return 25
    },

    // Alternate title to be used for this item's interface components
    titleAlt () {
      return `Credits: ${this.credits}`
    },

    // HTML content for the interface menu
    content () {
      return `
        ${this.complexity} Complexity<br />
        ${this.blocking} Blocking Factor<br />
        ${this.delaying} Delay Factor<br />
      `
    },

    // HTML tip content for the interface menu
    tip () {
      const associations = compact([
        this.isBlocked ? 'blocking' : null,
        this.isDelayed ? 'delaying' : null
      ])

      if (!this.mainItem || this.requisiteAssociation === 'this-item' || !associations.length) return

      return `Factored into ${this.mainItem.title}'s ${associations.join(' and ')} factor${associations.length > 1 ? 's' : ''}.`
    },

    // Curriculum state computed properties
    curriculum () {
      return this.term.curriculum
    },

    // Curriculum newLink
    newLink () {
      return this.curriculum.newLink
    },

    // Curriculum highlightLink
    highlightLink () {
      return this.curriculum.highlightLink
    },

    // Curriculum mainItem
    mainItem () {
      return this.curriculum.mainItem
    },

    // Forward or backward strict coreq links
    strictCoreqLink () {
      return this.sourceLinks.concat(this.targetLinks).filter(link => link.type === 'strict-coreq')[0]
    },

    // Minimum term position that this item can be dragged to
    minimumTermPosition () {
      if (this.strictCoreqLink) return this.strictCoreqLink.source.term.position

      const closestLink = maxBy(this.sourceLinks, link => link.source.term.position)
      if (!closestLink) return 0

      const closestPosition = closestLink.source.term.position
      if (closestLink.type === 'prereq') return closestPosition + 1

      return closestPosition
    },

    // Maximum term position that this item can be dragged to
    maximumTermPosition () {
      if (this.strictCoreqLink) return this.strictCoreqLink.target.term.position

      const closestLink = minBy(this.targetLinks, link => link.target.term.position)
      if (!closestLink) return this.curriculum.lastTermPosition

      const closestPosition = closestLink.target.term.position
      if (closestLink.type === 'prereq') return closestPosition - 1

      return closestPosition
    },

    // Computes items that COULD be added as a prereq, coreq, or strict-coreq to this item
    newLinkOptions () {
      const baseItems = this.curriculum.items.filter(item => {
        return this !== item && !this.previousTree.items.includes(item)
      })

      return {
        'prereq': baseItems.filter(item => item.term.position < this.term.position),
        'coreq': baseItems.filter(item => item.term.position <= this.term.position),
        'strict-coreq': baseItems.filter(item => item.term.position === this.term.position)
      }
    }
  },

  methods: {
    // given a direction ('source' or 'target') return all path permutations
    permute (direction, item = this, items = [], links = [], paths = []) {
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
          this.permute(direction, nextItem, items.slice(0), nextLinks, paths)
        })
      // otherwise add the completed path to the paths array
      } else {
        paths.push({items, links})
      }

      return paths
    },
    truncate (str) {
      const len = this.truncateLength
      return (str || '').length > len ? str.slice(0, len) + '...' : str
    },

    // Get items form sourceLinks matching a specific type ('prereq', 'coreq', or 'strict-coreq')
    getRequisiteItems (type) {
      return this.getRequisites(type).map(link => link.source)
    },

    getRequisites (type) {
      return this.sourceLinks.filter(link => link.type === type)
    },

    remove () {
      const items = this.term.items
      this.sourceLinks.concat(this.targetLinks).forEach(link => link.remove())
      items.splice(items.indexOf(this), 1)
      this.term.repositionItems()
      this.$destroy()
    },

    // Change item to a new term by indicating the new term or the new term position
    changeTerm (newTerm) {
      const oldTerm = this.term
      if (typeof newTerm === 'number') newTerm = this.curriculum.terms.find(term => term.position === newTerm)
      if (!newTerm || oldTerm === newTerm) return

      // console.log(newTerm.position, oldTerm.position)

      oldTerm.items.splice(oldTerm.items.indexOf(this), 1)
      oldTerm.repositionItems()
      newTerm.items.push(this)
      newTerm.repositionItems()
      this.term = newTerm
    },

    // Add a source link of a certain type to this item
    addSourceLink (type, source) {
      const newLink = new this.curriculum.components.Link({
        data: {
          type,
          source,
          target: this,
          new: true
        }
      })

      return newLink
    },

    // Export item to json matching the type
    export (type) {
      const general = {
        name: this.name,
        nameSub: this.nameSub,
        nameCanonical: this.nameCanonical,
        id: this.id,
        credits: this.credits,
        complexity: this.complexity,
        delaying: this.delaying,
        blocking: this.blocking,
        position: this.position,
        new: this.new
      }

      switch (type) {
        case 'basic':
          return Object.assign(general, {
            term: this.term.position + 1,
            prerequisites: this.getRequisiteItems('prereq').filter(item => item).map(item => item.name),
            corequisites: this.getRequisiteItems('coreq').filter(item => item).map(item => item.name),
            strictcorequisites: this.getRequisiteItems('strict-coreq').filter(item => item).map(item => item.name)
          })
        case 'verbose':
          return Object.assign(general, {
            curriculum_requisites: this.sourceLinks
              .filter(l => l.target && l.source)
              .map(l => l.export())
          })
        default:
          return Object.assign(general, {
            requisites: this.sourceLinks
              .filter(l => l.target && l.source)
              .map(l => l.export())
          })
      }
    }
  }
})
