<template>
  <g 
    v-if = 'link.source && link.target' 
    :class = '["link-group", faded ? "faded" : null]'
  >
    <!-- Delaying Indicator -->
    <path
      v-if = 'link.isDelayed && !options.hideDelaying'
      class = 'delaying'
      fill = 'transparent'
      :d = 'd'
      :transform = 'delayTransform'
    />

    <!-- Blocking Indicator -->
    <path
      v-if = 'link.isBlocked && !options.hideBlocking'
      class = 'blocking'
      fill = 'transparent'
      :d = 'd'
      :transform = 'blockingTransform'
    />

    <!-- Requisite Link -->
    <path
      class = 'link'
      fill = 'transparent'
      :d = 'd'
      :class = '[link.type]'
      :marker-end = 'markerEnd'
    />
  </g>
</template>

<script>
  // Use d3-shape library horizontal link generator
  import { linkHorizontal } from 'd3-shape'

  export default {
    data () {
      return {
        // initialize horizontal link generator
        linkHorizontal: linkHorizontal(),

        // delaying / blocking indicator offset
        factorOffset: 3
      }
    },

    props: {
      // Curriculum link state instance
      link: {
        type: Object,
        required: true
      },

      hoveredItem: {
        type: Object
      },

      selectedItem: {
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

    computed: {
      // Source Item
      s () {
        return this.link.source
      },

      // Target Item
      t () {
        return this.link.target
      },

      // Source X position
      sx () {
        return this.s.dragX || this.layout.termCenterX(this.s.term)
      },

      // Source Y position
      sy () {
        return this.s.dragY || this.layout.itemCenterY(this.s)
      },

      // Target X position
      tx () {
        return this.t.dragX || this.layout.termCenterX(this.t.term)
      },

      // Target Y position
      ty () {
        return this.t.dragY || this.layout.itemCenterY(this.t)
      },

      // Link is vertical
      vertical () {
        return this.s.term === this.t.term
      },

      // Link is horizontal
      horizontal () {
        return this.sy === this.ty
      },

      // Transform for delaying indicator
      delayTransform () {
        return `translate(${[
          this.factorOffset * Math.cos(this.theta),
          this.factorOffset * Math.sin(this.theta)
        ]})`
      },

      // Transform for blocking indicator
      blockingTransform () {
        return `translate(${[
          -this.factorOffset * Math.cos(this.theta),
          -this.factorOffset * Math.sin(this.theta)
        ]})`
      },

      // Is link faded
      faded () {
        return (this.highlightLink && !this.link.isHighlighted) ||
               (this.selectedItem || this.hoveredItem) &&
               (this.options.hideDelaying || !this.link.isDelayed) &&
               (this.options.hideBlocking || !this.link.isBlocked) &&
               (this.options.hideRequisiteAssociations || !this.link.source.requisiteAssociation || !this.link.target.requisiteAssociation) &&
               !this.link.isHighlighted
      },

      // Either use linkHorizontal or alternate pathway drawing with less overlap
      d () {
        const directionX = this.sx < this.tx ? 1 : -1
        if (this.vertical || this.options.curveLinks) {
          return `M ${[this.sx, this.sy]} Q ${this.curveControl} ${[this.tx, this.ty]}`
        } else if (this.horizontal) {
          return `M ${[this.sx + directionX * this.layout.radius, this.sy]} Q ${this.curveControl} ${[this.tx - directionX * this.linkOffset, this.ty]}`
        } else {
          return this.linkHorizontal({
            source: [this.sx + directionX * this.layout.radius, this.sy],
            target: [this.tx - directionX * this.linkOffset, this.ty]
          })
        }
      },

      // Curve direction multiplier returns either 1 or -1
      curveDirection () {
        if (this.vertical) {
          return this.sx < this.tx ? 1 : -1
        } else if (this.horizontal) {
          return -1
        } else {
          return this.sy < this.ty ? -1 : 1
        }
      },

      // Link theta
      theta () {
        return Math.atan2(this.ty - this.sy, this.tx - this.sx) - Math.PI / 2
      },

      // Control point for the curve [x, y]
      curveControl () {
        const offset = this.options.curveMultiplier * Math.sqrt(this.distance) * this.curveDirection * 3

        return [
          this.midPoint[0] + offset * Math.cos(this.theta),
          this.midPoint[1] + offset * Math.sin(this.theta)
        ]
      },

      // Source -> Target distance
      distance () {
        return Math.sqrt(Math.pow(this.tx - this.sx, 2) + Math.pow(this.ty - this.sy, 2))
      },

      // Midpoint [x, y]
      midPoint () {
        return [(this.sx + this.tx) / 2, (this.sy + this.ty) / 2]
      },

      // For links generated with linkHorizontal, how much offset from the target
      // item should they have
      linkOffset () {
        return this.layout.radius + 6
      },

      // Path marker
      markerEnd () {
        return `url(${this.vertical || this.options.curveLinks ? '#TriangleOffset' : '#Triangle'})`
      }
    }
  }
</script>
