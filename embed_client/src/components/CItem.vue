<template>
  <g 
    class = 'graph-item'
    @click = 'click'
    @mouseover.prevent = 'mouseOver'
    @mouseout.prevent = 'mouseOut'
    @touchstart = 'touchStart'
    @touchend = 'touchEnd'
    :transform = 'transform'
    :class = '[!options.hideRequisiteAssociations ? item.requisiteAssociation : null, faded ? "faded" : null]'
    v-tooltip = 'tooltip'
  >
    <g class = 'item-circle'>
      <circle :r = 'layout.radius'></circle>
    </g>
    <text class = 'item-value' y = '1.5' v-if = '!showEditIcon'>{{ item.value }}</text>
    <text class = 'item-edit-icon' y = '1.5' v-if = 'showEditIcon'>&#xf044;</text>
    <text class = 'item-title' :y = 'layout.radius * 1.7'>
      <tspan>{{ item.title }}</tspan>
      <tspan :x = '0' :dy = '15'>{{ item.titleSub }}</tspan>
      <tspan :x = '0' :dy = '16'>{{ item.canonicalSub }}</tspan>
    </text>

    <g class = 'blocking item-factor' v-if = 'item.isBlocked && !options.hideBlocking'>
      <circle 
        :stroke-dasharray = 'factorDasharray'
        :r = 'factorRadius'
      ></circle>
    </g>
    <g class = 'delaying item-factor' v-if = 'item.isDelayed && !options.hideDelaying'>
      <circle 
        :stroke-dasharray = 'factorDasharray'
        :r = 'factorRadius'
      ></circle>
    </g>
  </g>
</template>

<script>
  import { drag } from 'd3-drag'
  import { select, event } from 'd3-selection'
  import { VTooltip } from 'v-tooltip'

  export default {
    data () {
      return {
        dragOrigin: null,               // start drag location {x, y}
        touchStartTime: null,           // time touch event began
        termChanged: false,             // did the term change during drag
        dragger: drag()                 // setup d3 drag handler
          .clickDistance(30)
          .on('drag', this.dragging)
          .on('end', this.dragEnd)
          .on('start', this.dragStart)
      }
    },

    directives: {
      tooltip: VTooltip
    },

    props: {
      // Item state instance
      item: {
        type: Object,
        required: true
      },

      selected: {
        type: Boolean,
        default: false
      },

      hoveredItem: {
        type: Object
      },

      draggedItem: {
        type: Object
      },

      selectedItem: {
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

    // Setup dragging on mount if in edit mode
    mounted () {
      if (this.edit) select(this.$el).call(this.dragger)
    },

    // Before item component is destroyed teardown dragging events
    beforeDestroy () {
      select(this.$el).on('.drag', null)
    },

    watch: {
      // When edit mode is toggled, toggle dragging events
      edit (edit) {
        if (edit) select(this.$el).call(this.dragger)
        else select(this.$el).on('.drag', null)
      }
    },

    computed: {
      // Larger radius for complexity factor indicators
      factorRadius () {
        return this.layout.radius + 4
      },

      // Dasharray used for complexity factors
      factorDasharray () {
        return this.item.isBlocked &&
               this.item.isDelayed &&
               !this.options.hideDelaying &&
               !this.options.hideBlocking ? '8 18' : '7 6'
      },

      // Logic for when item is faded (will toggle 'faded' class)
      faded () {
        return (this.highlightLink && !this.item.isHighlighted) ||
               (this.selectedItem || this.hoveredItem) &&
               (this.options.hideDelaying || !this.item.isDelayed) &&
               (this.options.hideBlocking || !this.item.isBlocked) &&
               (this.options.hideRequisiteAssociations || !this.item.requisiteAssociation) &&
               !this.item.isHighlighted
      },

      // Item x position
      x () {
        return this.item.dragX || this.layout.termCenterX(this.item.term)
      },

      // Item y position
      y () {
        return this.item.dragY || this.layout.itemCenterY(this.item)
      },

      // Item transform
      transform () {
        return `translate(${this.x}, ${this.y})`
      },

      // Is edit mode enabled
      edit () {
        return this.options.edit
      },

      // When in edit mode, show edit icon on hover
      showEditIcon () {
        return this.options.edit && this.hoveredItem === this.item && !this.draggedItem
      },

      tooltip () {
        return {
          content: this.item.tip,
          classes: ['vue-curricula-tooltip'],
          offset: 0,
          show: this.item.tip ? null : false
        }
      }
    },

    methods: {
      // Hover start event, update hoveredItem (triggered by mouseover and touch events)
      startHover () {
        if (this.draggedItem) return
        this.$emit('update:hoveredItem', this.item)
        if (this.selectedItem) return
      },

      // Hover end event, update hoveredItem (triggered by mouseover and touch events)
      endHover () {
        if (this.draggedItem) return
        this.$emit('update:hoveredItem', null)
        if (this.selectedItem) return
      },

      // Toggle selectedItem on click
      clickToggle () {
        if (this.selectedItem === this.item) {
          this.$emit('update:selectedItem', null)
        } else {
          this.$emit('update:selectedItem', this.item)
        }
      },

      // Touch start event
      touchStart () {
        this.touchStartTime = Date.now()
        this.startHover()
      },

      // Touch stop event, if touch was longer than 300ms call clickToggle method
      touchEnd () {
        this.endHover()
        if (Date.now() - this.touchStartTime < 300) {
          this.clickToggle()
        }
      },

      // Mouseover event
      mouseOver () {
        if (this.touchStartTime) return
        this.startHover()
      },

      // Mouseout event
      mouseOut () {
        if (this.touchStartTime) return
        this.endHover()
      },

      // Click event
      click () {
        if (this.touchStartTime) return
        this.clickToggle()
      },

      // Drag start event, set drag origin
      dragStart () {
        this.dragOrigin = {x: event.x, y: event.y}
      },

      // Begin dragging item and update curriculum item interaction states
      dragBegin () {
        if (this.newLink) return

        this.termChanged = false
        this.$emit('update:selectedItem', null)
        this.$emit('update:draggedItem', this.item)
        this.$emit('update:hoveredItem', this.item)
      },

      // Drag distance from drag origin
      dragDistance () {
        if (this.dragOrigin) {
          const a = event.x - this.dragOrigin.x
          const b = event.y - this.dragOrigin.y
          return Math.sqrt(a * a + b * b)
        } else {
          return 0
        }
      },

      // Drag event, if dragged more than 10px begin drag interaction
      dragging () {
        if (this.dragDistance() > 10) {
          this.dragBegin()
        }

        if (this.draggedItem) {
          const termPosition = this.layout.termInvertX(this.dragX())
          if (this.termPosition !== this.item.term.position) this.termChanged = true
          this.item.changeTerm(termPosition)

          const itemPosition = this.layout.itemInvertY(this.dragY())
          if (this.item.position !== itemPosition) {
            this.item.position = itemPosition + (0.5 * (itemPosition > this.item.position ? 1 : -1))
            this.item.term.repositionItems()
          }

          this.item.dragX = this.dragX()
          this.item.dragY = this.dragY()
        }
      },

      // Drag end event
      dragEnd () {
        this.dragOrigin = null

        if (!this.draggedItem) return

        this.$emit('update:draggedItem', null)
        this.item.dragX = null
        this.item.dragY = null
        this.$emit('update:hoveredItem', null)
        this.touchStartTime = null

        // Dispatch global drag end event to prevent bug when moving an item to a different term
        if (this.termChanged) {
          const event = new CustomEvent('vue-curricula-drag-end')
          window.dispatchEvent(event)
        }
      },

      // Drag x position, confined by it's boundary minimum / maximum term position
      dragX () {
        const min = this.layout.termCenterX(this.item.minimumTermPosition)
        const max = this.layout.termCenterX(this.item.maximumTermPosition)
        return Math.min(Math.max(event.x, min), max)
      },

      // Drag y position, confined by it's boundary minimum / maximum item position
      dragY () {
        const min = this.layout.itemCenterY(0)
        const max = this.layout.itemCenterY(this.item.term.lastItemPosition)
        return Math.min(Math.max(event.y, min), max)
      }
    }
  }
</script>
