// This mixin separates the code that defines the graphs layout.
// It requires the graphWidth, margin, headerInnerHeight, itemInnerHeight,
// radius, and terms with nested items to be defined.

import { maxBy } from 'lodash'

export default {
  computed: {
    layout () {
      return {
        margin: this.margin,
        radius: this.radius,
        graphHeight: this.graphHeight,
        graphWidth: this.graphWidth,
        graphInnerWidth: this.graphInnerWidth,
        termOuterHeight: this.termOuterHeight,
        headerInnerHeight: this.headerInnerHeight,
        headerOuterHeight: this.headerOuterHeight,
        itemOuterHeight: this.itemOuterHeight,
        rectHeight: this.rectHeight,
        rectWidth: this.rectWidth,
        headerHeight: this.headerHeight,
        headerWidth: this.headerWidth,
        termCount: this.termCount,
        itemCount: this.itemCount,
        // scale functions
        termCenterX: this.termCenterX,
        termOriginX: this.termOriginX,
        termCellX: this.termCellX,
        termInvertX: this.termInvertX,
        itemCenterY: this.itemCenterY,
        itemOriginY: this.itemOriginY,
        itemCellY: this.itemCellY,
        itemInvertY: this.itemInvertY
      }
    },

    // Helper computed properties that are used in the layout construction.

    graphHeight () {
      return 2 * this.headerOuterHeight + this.itemCount * (this.itemOuterHeight)
    },

    graphInnerWidth () {
      return this.graphWidth + (this.margin * 2)
    },

    termOuterWidth () {
      return this.graphInnerWidth / this.termCount
    },

    termInnerWidth () {
      return Math.max(0, this.termOuterWidth - (this.margin * 2))
    },

    headerOuterHeight () {
      return this.headerHeight + (this.margin * 2)
    },

    itemOuterHeight () {
      return this.itemInnerHeight + (this.margin * 2)
    },

    rectHeight () {
      return this.itemInnerHeight
    },

    rectWidth () {
      return this.termInnerWidth
    },

    headerHeight () {
      return this.options.hideTerms ? 0 : this.headerInnerHeight
    },

    headerWidth () {
      return this.termInnerWidth
    },

    termCount () {
      return this.terms.length
    },

    longestTerm () {
      return maxBy(this.terms, t => t.items.length)
    },

    itemCount () {
      return this.longestTerm ? this.longestTerm.items.length + (this.options.edit ? 1 : 0) : 0
    }
  },

  methods: {
    // x, y functions for computing the item / term origin and cell x / y positions
    // these receive the term position `term` or item position `item`. The term and item
    // positions can be provided as a number or an object like {position: 1}.
    termCenterX (term) {
      return this.termOriginX(term) + this.termOuterWidth / 2
    },

    termInvertX (x) {
      return Math.floor(x / this.termOuterWidth)
    },

    itemCenterY (item) {
      return this.itemOriginY(item) + this.itemOuterHeight / 2 - this.radius / 2 - 8
    },

    itemInvertY (y) {
      return Math.floor((y - this.headerOuterHeight) / this.itemOuterHeight)
    },

    termOriginX (term) {
      term = typeof term === 'number' ? term : term.position
      return this.termOuterWidth * term
    },

    itemOriginY (item) {
      item = typeof item === 'number' ? item : item.position
      return this.headerOuterHeight + this.itemOuterHeight * item
    },

    termCellX (term) {
      return this.termOriginX(term) + this.margin
    },

    itemCellY (item) {
      return this.itemOriginY(item) + this.margin
    }
  }
}
