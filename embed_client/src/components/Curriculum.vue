<template>
  <div
    class = 'vue-curricula'
  >
    <!-- Edit message when in the process of creating a new link. -->
    <div class = 'edit-message important' v-if = 'newLink'>
      Click on <b>{{ newLink.source ? newLink.source.name : 'one of the highlighted items' }}</b> 
      to make it a {{ newLink.typeName }} of <b>{{ newLink.target.title }}</b>.
      <button class = 'red' @click = 'clearNewLink' key = 'cancel'>
        Cancel
      </button>

      <div style = 'clear: both;'></div>
    </div>

    <!-- Default edit message and add-term button when in edit mode. -->
    <div class = 'edit-message' v-else-if = 'options.edit'>
      Click on an item to edit it, or move an item by dragging it.

      <button class = 'blue' @click = 'curriculum.addTerm' key = 'add-term'>
        Add Term
      </button>

      <div style = 'clear: both;'></div>
    </div>

    <!-- Legend component -->
    <transition name = 'legend'>
      <c-legend 
        v-if = 'showRequisiteLegend'
        :options = 'options'
      >
      </c-legend>
    </transition>

    <!-- Graph container -->
    <div ref = 'container' class = 'graph-container'>
      <!-- Curriculum SVG component -->
      <svg
        is = 'c-svg'
        :curriculum = 'curriculum'
        :selected-item = 'selectedItem'
        @update:selectedItem = 'updateSelectedItem'
        :hovered-item = 'hoveredItem'
        @update:hoveredItem = 'updateHoveredItem'
        :dragged-item.sync = 'draggedItem'
        :new-link.sync = 'newLink'
        :highlight-link = 'highlightLink'
        @update:highlightLink = 'updateHighlightLink'
        :options = 'options'
        :layout = 'layout'
      ></svg>
      
      <!-- Selected curriculum item menu component -->
      <transition name = 'menu'>
        <c-item-menu 
          v-if = 'menuItem' 
          :item = 'menuItem'
          :options = 'options'
          :layout = 'layout'
          :selected-item = 'selectedItem'
          @update:selectedItem = 'updateSelectedItem'
          :hovered-item = 'hoveredItem'
          @update:hoveredItem = 'updateHoveredItem'
          :dragged-item.sync = 'draggedItem'
          :highlight-link = 'highlightLink'
          @update:highlightLink = 'updateHighlightLink'
          :new-link.sync = 'newLink'
        ></c-item-menu>
      </transition>
    </div>
    <!-- <div class='attribution'>
      <a href='//idi.unm.edu' target='_blank'>
        Powered by <img :src='logo'/>
      </a>
    </div> -->
  </div>
</template>

<script>
  import curriculumLayout from '../mixins/curriculumLayout'
  import CSvg from './CSvg.vue'
  import CLegend from './CLegend.vue'
  import CItemMenu from './CItemMenu.vue'
  import { VTooltip } from 'v-tooltip'
  import logo from '../helpers/logo'

  export default {
    mixins: [curriculumLayout],

    data () {
      return {
        // Selected item (usually by clicking)
        selectedItem: null,

        // Item being hovered
        hoveredItem: null,

        // Item being dragged
        draggedItem: null,

        // New link placeholder while creating a new item requisite
        newLink: null,

        // Link to be highlighted (usually by hovering). Factored into the
        // isHighlighted attribute for the link and source / target items
        highlightLink: null,

        // Indicator that an item was recently hovered
        recentlyHovered: false,

        // Timeout used to set recently hovered
        legendTimeout: null,

        // Graph width
        graphWidth: 0,

        // IDI logo
        logo: logo
      }
    },

    directives: {
      tooltip: VTooltip,

      autofocus: {
        inserted: function (el) {
          el.focus()
        }
      }
    },

    watch: {
      hoveredItem (newItem, oldItem) {
        clearTimeout(this.legendTimeout)
        if (newItem) this.recentlyHovered = true
        else {
          this.legendTimeout = setTimeout(() => {
            this.recentlyHovered = false
          }, 750)
        }

        this.curriculum.hoveredItem = newItem
      },

      selectedItem (newItem, oldItem) {
        this.curriculum.selectedItem = newItem
      },

      draggedItem (newItem) {
        this.curriculum.draggedItem = newItem
      },

      newLink (link) {
        this.curriculum.newLink = link
      },

      highlightLink (link) {
        this.curriculum.highlightLink = link
      }
    },

    props: {
      // Curriculum state instance usually created by the buildCurriculum helper
      curriculum: {
        type: Object,
        required: true
      },

      // Hide term info (e.g. header / footer)
      hideTerms: {
        type: Boolean,
        default: false
      },

      // Hide grid rectangles
      hideGrid: {
        type: Boolean,
        default: false
      },

      // Hide requisite colors (e.g. prereq, coreq, unblocked, etc..)
      hideRequisiteAssociations: {
        type: Boolean,
        default: false
      },

      // Hide blocking markers on items and links
      hideBlocking: {
        type: Boolean,
        default: false
      },

      // Hide delaying markers on items and links
      hideDelaying: {
        type: Boolean,
        default: false
      },

      // Hide legend
      hideLegend: {
        type: Boolean,
        default: false
      },

      // Different type of link drawing with less link / node overlap
      curveLinks: {
        type: Boolean,
        default: false
      },

      // Link offset multiplier for curved links
      curveMultiplier: {
        type: Number,
        default: 1
      },

      // Edit mode true / false
      edit: {
        type: Boolean,
        default: false
      },

      // Grid inner margin size (px)
      gridInnerMargin: {
        type: Number,
        default: 3
      },

      // Header and footer height for terms (px)
      termHeaderFooterHeight: {
        type: Number,
        default: 29
      },

      // Item grid height (px)
      itemGridHeight: {
        type: Number,
        default: 100
      },

      // Item circle radius (px)
      itemCircleRadius: {
        type: Number,
        default: 15
      }
    },

    components: {
      CLegend,
      CSvg,
      CItemMenu
    },

    computed: {
      // Compiled list of options to pass to children components
      options () {
        return {
          hideTerms: this.hideTerms,
          hideRequisiteAssociations: this.hideRequisiteAssociations,
          hideGrid: this.hideGrid,
          hideBlocking: this.hideBlocking,
          hideDelaying: this.hideDelaying,
          hideLegend: this.hideLegend,
          curveLinks: this.curveLinks,
          curveMultiplier: this.curveMultiplier,
          edit: this.edit
        }
      },

      // Show requisite legend of option dictates and item has been recently hovered
      showRequisiteLegend () {
        return this.recentlyHovered && !this.options.hideLegend
      },

      // Curriculum terms state instances
      terms () {
        return this.curriculum.terms
      },

      // Item to show in menu, preference selectedItem then hoveredItem
      menuItem () {
        return this.selectedItem || this.hoveredItem
      },

      margin () {
        return this.gridInnerMargin
      },

      headerInnerHeight () {
        return this.termHeaderFooterHeight
      },

      itemInnerHeight () {
        return this.itemGridHeight
      },

      radius () {
        return this.itemCircleRadius
      }
    },

    methods: {
      // Update graph width based on container bounding client rectangle
      updateWidths () {
        this.graphWidth = this.$refs.container.getBoundingClientRect().width
      },

      // When finished dragging clear all interface item states
      resetDrag () {
        this.draggedItem = null
        this.hoveredItem = null
        this.selectedItem = null
      },

      // When enter or escape keys are used clear the newLink and selectedItem
      submitSelected (event) {
        if ([13, 27].includes(event.keyCode)) {
          this.clearNewLink()
          this.selectedItem = null
        }
      },

      // Clear newLink and clean it up via it's remove method
      clearNewLink () {
        if (this.newLink) {
          this.newLink.remove()
          this.newLink = null
        }
      },

      // Update hoveredItem unless newLink is being created
      updateHoveredItem (item) {
        if (this.newLink) {
          // If newLink is already being created and the hovered item is
          // a possible source to the newLink set the item as its source
          if (!item || this.newLink.target.newLinkOptions[this.newLink.type].includes(item)) {
            this.newLink.source = item
          }
        } else {
          this.hoveredItem = item
        }
      },

      // Update selectedItem item unless newLink is being created
      updateSelectedItem (item) {
        if (this.newLink) {
          // If newLink is being created and already has it's source defined
          // with the updateHoverItem method finish the newLink creation
          if (item && this.newLink.source) {
            this.newLink = null
            // this.curriculum.transitiveReduction()
          }
        } else {
          this.selectedItem = item
        }
      },

      // Update highlightLink
      updateHighlightLink (link) {
        this.highlightLink = link
      }
    },

    // Setup listeners on mounted
    mounted () {
      // this.curriculum.transitiveReduction()
      this.updateWidths()
      window.addEventListener('resize', this.updateWidths)

      // Add custom global event for a drag end event. This fixes a bug when
      // moving an item to a different term.
      window.addEventListener('vue-curricula-drag-end', this.resetDrag)
      window.addEventListener('keyup', this.submitSelected)
    },

    // Teardown listners before destroy
    beforeDestroy () {
      window.removeEventListener('resize', this.updateWidths)
      window.removeEventListener('vue-curricula-drag-end', this.resetDrag)
      window.removeEventListener('keyup', this.submitSelected)
    }
  }
</script>
