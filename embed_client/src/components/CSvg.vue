<template>
  <svg :width = 'layout.graphWidth' :height = 'layout.graphHeight'>
    <!-- Triangle marker -->
    <marker
      id = 'Triangle'
      class = 'end-marker'
      viewBox = '0 -5 10 10'
      :refX = '0'
      markerWidth = '6'
      markerHeight = '6'
      orient = 'auto'
    >
      <path d = 'M 0 -5 L 10 0 L 0 5 z'></path>
    </marker>

    <!-- Triangle marker with offset -->
    <marker
      id = 'TriangleOffset'
      class = 'end-marker'
      viewBox = '0 -5 10 10'
      :refX = '35'
      markerWidth = '6'
      markerHeight = '6'
      orient = 'auto'
    >
      <path d = 'M 0 -5 L 10 0 L 0 5 z'></path>
    </marker>

    <g :transform = '`translate(${-layout.margin}, ${-layout.margin})`'>
      <!-- Curriculum Rectangle Grid -->
      <g class = 'curriculum-grid' v-if = '!options.hideGrid'>
        <g v-for = 'term in terms' :key = 'term.id'>
          <rect
            class = 'item-cell'
            v-for = 'item in term.items'
            :key = 'item.id'
            :transform = '`translate(${layout.termCellX(term)}, ${layout.itemCellY(item)})`'
            :width = 'layout.rectWidth'
            :height = 'layout.rectHeight'
          >
          </rect>
        </g>
      </g>

      <!-- Curriculum Links -->
      <g
        v-for = 'link in links'
        is = 'c-link'
        :link = 'link'
        :hovered-item = 'hoveredItem'
        :selected-item = 'selectedItem'
        :highlight-link = 'highlightLink'
        :key = 'link.id'
        :options = 'options'
        :layout = 'layout'
      ></g>

      <!-- Curriculum Term components -->
      <g class = 'curriculum-terms'>
        <g
          is = 'c-term'
          v-for = 'term in terms'
          :key = 'term.id'
          :term = 'term'
          :hovered-item = 'hoveredItem'
          :selected-item = 'selectedItem'
          :dragged-item = 'draggedItem'
          @update:draggedItem = 'item => $emit("update:draggedItem", item)'
          @update:selectedItem = 'item => $emit("update:selectedItem", item)'
          @update:hoveredItem = 'item => $emit("update:hoveredItem", item)'
          :new-link = 'newLink'
          :highlight-link = 'highlightLink'
          :options = 'options'
          :layout = 'layout'
        ></g>
      </g>
    </g>
  </svg>
</template>


<script>
  import CLink from './CLink.vue'
  import CTerm from './CTerm.vue'

  export default {
    props: {
      // Curriculum state instance usually created by the buildCurriculum helper
      curriculum: {
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
        type: Object
      }
    },

    components: {
      CTerm,
      CLink
    },

    computed: {
      // Array of curriculum term states
      terms () {
        return this.curriculum.terms
      },

      // Array of curriculum link states
      links () {
        return this.curriculum.links
      }
    }
  }
</script>