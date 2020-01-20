<template>
<div id="block_container">
  <div v-if="curriculum" class="graph">
    <div v-if="curriculum.original.institution" >
    Institution: {{curriculum.original.institution}}
    </div>
    <div v-if="curriculum.original.name" >
    Curriculum: {{curriculum.original.name}}
    </div>
    <div v-if="curriculum.original.dp_name" >
    Degree Plan: {{curriculum.original.dp_name}}
    </div>
    <div v-if="curriculum.credits" >
    Total Credit Hours: {{curriculum.credits}}
    </div>
    <div v-if="curriculum.complexity" >
    Curricular Complexity: {{curriculum.complexity.toFixed(1)}}
    </div>
    <curriculum
      :curriculum="curriculum"
      v-bind="options"
      :name="name"
      :hide-blocking='true'
      ref="curriculum"
    ></curriculum>
  </div>
<!-- <button class="btn btn-close" @click="refresh">Save Changes</button>! -->
</div>
</template>

<script>
import { Curriculum, buildCurriculum, BaseItem, BaseTerm } from '@damoursystems/curricular-visualization'
const CustomTerm = BaseTerm.extend({
  computed: {
    footer () {
      if (this.complexity) {
        return `Complexity: ${this.complexity.toFixed(1)}`
      } else {
        return `Credits: ${this.credits}`
      }
    }
  }
})
const CustomItem = BaseItem.extend({
  computed: {
    content () {
      if (this.original) {
        let output = ''
        for (var metric in this.original.metrics) {
          output += `${metric}: ${this.original.metrics[metric]}<br />`
        }
        return output
      } else {
        return 0
      }
    },
    complexity () {
      if (this.original && this.original.metrics.complexity) {
        return this.original.metrics.complexity
      } else {
        return 0
      }
    },
    value () {
      if (this.complexity) {
        return this.complexity
      } else {
        return this.credits
      }
    }
  }
})
export default {
  data () {
    return {
      curriculum: null,
      options: {},
      format: null,
      exportFormat: null,
      height: 0
    }
  },
  components: {
    Curriculum
  },
  watch: {
    export: {
      handler (e) {
        if (!e) return
        window.parent.postMessage({ curriculum: e }, '*')
        setTimeout(() => {
          this.height = this.$el.getBoundingClientRect().height
        }, 0)
      },
      deep: true
    },
    height (height) {
      window.parent.postMessage({ height }, '*')
    }
  },
  methods: {
    refresh () {
      window.parent.postMessage({ curriculum: this.export }, '*')
    },

    receiveMessage (event) {
      const data = event.data
      if (data) {
        // Recieve Event Props
        ['options', 'format', 'exportFormat'].forEach(prop => {
          if (data[prop]) this[prop] = data[prop]
        })
        // Build Curriculum if Provided
        let curriculum = data.curriculum
        if (curriculum) this.curriculum = buildCurriculum(curriculum, { format: this.format, Item: CustomItem, Term: CustomTerm })
        window.curriculum = this.curriculum
      }
    }
  },
  computed: {
    exports () {
      return this.curriculum ? this.curriculum.exports : {}
    },
    export () {
      return this.exportFormat ? this.exports[this.exportFormat]
        : this.curriculum ? this.curriculum.exportOriginal
          : {}
    }
  },
  created () {
    window.addEventListener('message', this.receiveMessage, false)
  },
  beforeDestroy () {
    window.removeEventListener('message', this.receiveMessage)
  }
}
</script>
