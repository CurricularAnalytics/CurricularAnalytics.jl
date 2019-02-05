<template>
  <g class = 'graph-term'>

    <!-- Term Header -->
    <g 
      class = 'term-header' 
      :transform = '`translate(${layout.termCellX(term)}, ${layout.margin})`'
      v-if = '!this.options.hideTerms'
    >
      <rect
        :width = 'layout.headerWidth'
        :height = 'layout.headerInnerHeight'
      ></rect>
      <text :x = 'layout.headerWidth / 2' :y = 'layout.headerInnerHeight / 2 + 1.5'>
        {{ term.header }}
      </text>

      <g 
        v-if = 'options.edit && term.isLast'
        class = 'term-remove'
        :transform = '`translate(${layout.headerWidth - 25}, 5)`'
        @click = 'term.remove'
        v-tooltip = 'termRemoveTooltip'
        :class = '{faded: term.items.length}'
      >
        <rect width = '20' height = '20'></rect>
        <path 
          transform = 'scale(0.037)'
          d = 'M464 32H48C21.5 32 0 53.5 0 80v352c0 26.5 21.5 48 48 48h416c26.5 0 48-21.5 48-48V80c0-26.5-21.5-48-48-48zm-83.6 290.5c4.8 4.8 4.8 12.6 0 17.4l-40.5 40.5c-4.8 4.8-12.6 4.8-17.4 0L256 313.3l-66.5 67.1c-4.8 4.8-12.6 4.8-17.4 0l-40.5-40.5c-4.8-4.8-4.8-12.6 0-17.4l67.1-66.5-67.1-66.5c-4.8-4.8-4.8-12.6 0-17.4l40.5-40.5c4.8-4.8 12.6-4.8 17.4 0l66.5 67.1 66.5-67.1c4.8-4.8 12.6-4.8 17.4 0l40.5 40.5c4.8 4.8 4.8 12.6 0 17.4L313.3 256l67.1 66.5z'
        ></path>
      </g>
    </g>

    <!-- Term Items -->
    <g class = 'term-items'>
      <g
        is = 'c-item'
        v-for = 'item in term.items'
        :item = 'item'
        :key = 'item.id'
        :selected = 'selectedItem === item'
        :hovered-item = 'hoveredItem'
        :selected-item = 'selectedItem'
        :dragged-item = 'draggedItem'
        :new-link = 'newLink'
        :highlight-link = 'highlightLink'
        @update:draggedItem = 'item => $emit("update:draggedItem", item)'
        @update:selectedItem = 'item => $emit("update:selectedItem", item)'
        @update:hoveredItem = 'item => $emit("update:hoveredItem", item)'
        :options = 'options'
        :layout = 'layout'
      ></g>
    </g>

    <!-- Term Footer -->
    <g 
      class = 'term-footer' 
      :transform = 'transformFooter'
      :class = '{faded: !!newLink}'
      v-if = '!this.options.hideTerms'
    >
      <rect
        :width = 'layout.headerWidth'
        :height = 'layout.headerInnerHeight'
      ></rect>
      <text 
        :x = 'layout.headerWidth / 2' 
        :y = 'layout.headerInnerHeight / 2 + 1.5'
      >
        {{ term.footer }}
      </text>
    </g>

    <!-- Add item button if in edit mode -->
    <g class = 'curriculum-grid' v-if = 'options.edit'>
      <g
        class = 'graph-item item-add'
        :class = '{faded: !!newLink}'
        @click = 'addItem'
        :transform = 'transformAddItem'
      >
        <rect
          class = 'item-cell'
          :width = 'layout.rectWidth'
          :height = 'layout.rectHeight'
        >
        </rect>
          <g 
            class = 'item-circle' 
            :transform = 'transformAddItemCircle'
          >
            <circle :r = 'layout.radius'></circle>
            <text class = 'item-value' y = '1.5'>&#xf067;</text>
            <text class = 'item-title' :y = 'layout.radius * 2'>Add Item</text>
          </g>
      </g>
    </g>
  </g>
</template>

<script>
  import CItem from './CItem'
  import { VTooltip } from 'v-tooltip'

  export default {
    directives: {
      tooltip: VTooltip
    },

    props: {
      // Term state instance
      term: {
        type: Object,
        required: true
      },

      selectedItem: {
        type: Object
      },

      hoveredItem: {
        type: Object
      },

      draggedItem: {
        type: Object
      },

      newLink: {
        type: Object
      },

      highlightLink: {
        type: Object
      },

      options: {
        type: Object
      },

      layout: {
        type: Object,
        required: true
      }
    },

    components: {
      CItem
    },

    computed: {
      // Create footer transform
      transformFooter () {
        const yPosition = this.term.lastItemPosition + (this.options.edit ? 2 : 1)
        return `translate(${this.layout.termCellX(this.term)}, ${this.layout.itemCellY(yPosition)})`
      },

      // Tooltip object for term remove button
      termRemoveTooltip () {
        return {
          content: this.term.items.length ? 'Cannot remove a term with items.' : 'Remove Term',
          classes: ['vue-curricula-tooltip']
        }
      },

      // Add item button transform
      transformAddItem () {
        const x = this.layout.termCellX(this.term)
        const y = this.layout.itemCellY(this.term.lastItemPosition + 1)
        return `translate(${x}, ${y})`
      },

      // Add item button circle transform
      transformAddItemCircle () {
        const x = this.layout.rectWidth / 2
        const y = this.layout.rectHeight / 2 - this.layout.radius / 2
        return `translate(${x}, ${y})`
      }
    },

    methods: {
      // Trigger term addItem method and select the new item unless a
      // new link is being created
      addItem () {
        if (this.newLink) return

        const newItem = this.term.addItem({name: 'New Item'})
        this.$emit('update:selectedItem', newItem)
      }
    }
  }
</script>
