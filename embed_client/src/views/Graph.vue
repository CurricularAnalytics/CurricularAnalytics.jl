<template>
  <div v-if="curriculum" class="graph">
    <div v-if="curriculum.original.name" >
    <p>{{curriculum.original.name}}</p>
    </div>
    <div v-if="curriculum.credits" >
    <p>Total Credit Hours: {{curriculum.credits}}</p>
    </div>
    <div v-if="curriculum.original.institution" >
    <p>Curricular Institution: {{curriculum.original.institution}}</p>
    </div>
    <div v-if="curriculum.complexity" >
    <p>Curricular Complexity: {{curriculum.complexity}}</p>
    </div>
    <curriculum
      :curriculum="curriculum"
      v-bind="options"
      :hide-blocking='true'
      ref="curriculum"
    ></curriculum>
  </div>
</template>

<script>
  import { Curriculum, buildCurriculum, BaseItem, BaseTerm } from '@unm-idi/vue-curricula'
  const CustomTerm = BaseTerm.extend({
    computed: {
      footer () {
        return `Credits: ${this.credits}`
      }
    }
  })

  const CustomItem = BaseItem.extend({
    computed: {
      content () {
        let output = ""
        for (var metric in this.original.metrics) {
          output += `${metric}: ${this.original.metrics[metric]}<br />`
        }
        return output
      },

      complexity () {
        if (this.original.metrics.complexity) {
          return this.original.metrics.complexity
        } else {
          return 0
        }
      },
      value () {
        return this.credits
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
        height: 0,
      }
    },

    components: {
      Curriculum
    },

    watch: {
      export: {
        handler (e) {
          if (!e) return
          window.parent.postMessage({curriculum: e}, '*');
          setTimeout(() => {
            this.height = this.$el.getBoundingClientRect().height
          }, 0)
        },
        deep: true
      },

      height (height) {
        window.parent.postMessage({height}, '*');
      }
    },

    methods: {
      receiveMessage (event) {
        const data = event.data
        if (data) {
          // Recieve Event Props
          ['options', 'format', 'exportFormat'].forEach(prop => {
            if (data[prop]) this[prop] = data[prop]
          })

          // Build Curriculum if Provided
          let curriculum = data.curriculum
          if (curriculum) this.curriculum = buildCurriculum(curriculum, {format: this.format, Item: CustomItem, Term: CustomTerm})
          window.curriculum = this.curriculum
        }
      }
    },

    computed: {
      exports () {
        return this.curriculum ? this.curriculum.exports : {}
      },

      export () {
        return this.exportFormat ? this.exports[this.exportFormat] : 
                 this.curriculum ? this.curriculum.exportOriginal :
                  {}
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