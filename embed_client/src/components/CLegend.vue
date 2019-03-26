<template>
  <div class = 'legend'>
    <div 
      class = 'factor-item' 
      v-for = 'item in factorItems'
      :key = 'item.key'
      v-if = '!options[`hide${capitalize(item.key)}`]'
    >
      <svg :class = 'item.key' class = 'legend-icon'>
        <circle 
          :r = 'radius'
          :cx = 'radius + 2'
          :cy = 'radius + 2'
        ></circle>
      </svg>
      <span class = 'legend-text'>{{ item.label }}</span>
    </div>

    <div 
      class = 'requisite-item' 
      v-for = 'item in items'
      :key = 'item.label'
      v-if = '!options.hideRequisiteAssociations'
    >
      <span 
        class = 'legend-icon'
        v-for = 'icon in item.icons'
        :key = 'icon'
        :class = 'icon' 
      ></span>
      <span class = 'legend-text'>{{ item.label }}</span>
    </div>
  </div>
</template>

<script>
  export default {
    data () {
      return {
        // Legend icon radius
        radius: 8,

        // Legend items for complexity factors
        factorItems: [
          { label: 'Blocking', key: 'blocking' },
          { label: 'Longest Path', key: 'delaying' }
        ],

        // Legend items for requisite associations
        // items: ['strict-coreq', 'coreq', 'prereq', 'pre-coreq-field', 'unblocked', 'unblocked-field']
        items: [
          { label: 'Strict Corequisite', icons: ['strict-coreq'] },
          { label: 'Corequisite', icons: ['coreq'] },
          { label: 'Prerequisite', icons: ['prereq'] },
          { label: 'Pre Corequisite Field', icons: ['coreq', 'strict-coreq', 'pre-coreq-field', 'prereq'] },
          { label: 'Unblocked', icons: ['unblocked'] },
          { label: 'Unblocked Field', icons: ['unblocked-field', 'unblocked'] }
        ]
      }
    },

    props: {
      options: {
        type: Object
      }
    },

    methods: {
      capitalize (str) {
        return str.charAt(0).toUpperCase() + str.substr(1)
      }
    }
  }
</script>
