<template>
  <div 
    class = 'menu'
    :class = 'menuClasses'
    v-if = 'item && !draggedItem && !newLink'
    :style = 'menuStyle'
  >
    <div class = 'menu-content-wrap'>
      <!-- Editing Menu -->
      <template v-if = 'options.edit && selectedItem'>
        <!-- Menu header for credits / name editing -->
        <div class = 'menu-header'>
          <div class = 'menu-name menu-input'>
            <div class = 'menu-label'>Name:</div>
            <input v-model = 'item.name' @focus = '$event.target.select()' v-autofocus>
          </div>
          <div class = 'menu-name menu-input'>
            <div class = 'menu-label'>Title:</div>
            <input v-model = 'item.nameSub' @focus = '$event.target.select()' v-autofocus>
          </div>
          <div class = 'menu-name menu-input'>
            <div class = 'menu-label'>Canonical Name:</div>
            <input v-model = 'item.nameCanonical' @focus = '$event.target.select()' v-autofocus>
          </div>
          <div class = 'menu-credits menu-input'>
            <div class = 'menu-label'>Credits:</div>
            <input v-model = 'item.credits' @focus = '$event.target.select()' type = 'number'>
          </div>
        </div>
        <!-- Menu content for link deletion / creation -->
        <div class = 'menu-content'>
          <template v-if = 'item.sourceLinks.length'>
            <div class = 'menu-content-title'>Requisites:</div>

            <div class = 'menu-links'>
              <div
                class = 'menu-link' 
                v-for = 'link in item.sourceLinks' 
                @mouseover = '$emit("update:highlightLink", link)'
                @mouseout = '$emit("update:highlightLink", null)'
                :key = 'link.id'
              >
                <div class = 'link-cell link-title'>{{ link.source.title }}</div>
                <div class = 'link-cell link-type'>{{ link.type }}</div>
                <div 
                  class = 'link-cell link-remove' 
                  @click = 'removeLink(link)'
                  v-tooltip.right = '{content: `Remove ${link.typeName}`, classes: ["vue-curricula-tooltip"], offset: 15}'
                ></div>
              </div>
            </div>
            <div class = 'menu-content-divider'></div>
          </template>

          <div 
            class = 'link-add-button'
            @click = 'setNewLink("prereq")' 
            v-if = 'item.newLinkOptions["prereq"].length'
          >Add Prerequisite</div>
          <div 
            class = 'link-add-button'
            @click = 'setNewLink("coreq")' 
            v-if = 'item.newLinkOptions["coreq"].length'
          >Add Corequisite</div>
          <div 
            class = 'link-add-button'
            @click = 'setNewLink("strict-coreq")' 
            v-if = 'item.newLinkOptions["strict-coreq"].length'
          >Add Strict Corequisite</div>
        </div>
      </template>
      
      <!-- Non Editing Menu -->
      <template v-else>
        <div class = 'menu-header'>
          <span class = 'menu-title'>{{ item.title }}</span>
          <span class = 'menu-title-alt'>{{ item.titleAlt }}</span>
        </div>
        <div class = 'menu-content' v-html = 'item.content'></div>
      </template>

      <!-- Menu Icons -->
      <transition name = 'menu-icons'>
        <div class = 'menu-icons' v-if = 'selectedItem'>
          <div 
            @click = '$emit("update:selectedItem", null)'
            class = 'menu-icon menu-icon-pin'
            v-if = '!options.edit'
            v-tooltip.right = '{content: "Unpin", classes: ["vue-curricula-tooltip"], offset: 10}'
          ></div>

          <div 
            @click = '$emit("update:selectedItem", null)'
            class = 'menu-icon menu-icon-confirm'
            v-if = 'options.edit'
            v-tooltip.right = '{content: "Finished", classes: ["vue-curricula-tooltip"], offset: 10}'
          ></div>
            
          <div 
            @click = 'removeItem'
            class = 'menu-icon menu-icon-remove'
            v-if = 'options.edit'
            v-tooltip.right = '{content: "Remove Item", classes: ["vue-curricula-tooltip"], offset: 10}'
          ></div>
        </div>
      </transition>
    </div>
  </div>
</template>

<script>
  import { VTooltip } from 'v-tooltip'

  export default {
    directives: {
      tooltip: VTooltip,

      autofocus: {
        inserted: function (el) {
          el.focus()
        }
      }
    },

    props: {
      // Menu Item State
      item: {
        type: Object,
        required: true
      },

      options: {
        type: Object,
        default: {}
      },

      layout: {
        type: Object,
        default: {}
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

      highlightLink: {
        type: Object
      },

      newLink: {
        type: Object
      }
    },

    computed: {
      // Left position of the menu
      menuLeft () {
        return this.layout.termCenterX(this.item.term) - this.layout.margin
      },

      // Menu style object
      menuStyle () {
        return {
          top: `${this.layout.itemCenterY(this.item) + this.layout.radius}px`,
          left: `${this.menuLeft}px`
        }
      },

      // Menu anchor position 'left' 'right' or 'middle'
      menuPosition () {
        if (this.menuLeft < this.layout.graphInnerWidth / 3) return 'right'
        else if (this.menuLeft > 2 * this.layout.graphInnerWidth / 3) return 'left'
        else return 'middle'
      },

      // Classed for the menu 'faded' / 'edit' / one of 'right' 'left' 'middle'
      menuClasses () {
        return [
          this.hoveredItem !== this.item ? 'faded-menu' : null,
          this.options.edit && !!this.selectedItem ? 'edit' : null,
          this.menuPosition,
          this.selectedItem ? 'pinned' : null
        ]
      }
    },

    methods: {
      // Remove the menu item
      removeItem () {
        this.item.remove()
        this.$emit('update:selectedItem', null)
      },

      removeLink (link) {
        link.remove()
        this.$emit('update:highlightLink', null)
      },

      // Initialize a new link with a target item and requisite type
      setNewLink (type) {
        this.$emit('update:newLink', this.item.addSourceLink(type))
      }
    }
  }
</script>
