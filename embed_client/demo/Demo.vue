<template>
  <div id = 'demo'>
    <div class = 'toggle-edit'>
      <label @click = 'edit = !edit'>Editing</label> 
      <toggle-button v-model = 'edit' :sync = 'true' :labels = 'true'></toggle-button>
      <a href = 'https://gitlab.com/unm-idi/vue-curricula/blob/master/README.md' target = '_blank'>
        <button><i class="fa fa-file-text-o"></i> Docs</button>
      </a>
    </div>

    <curriculum 
      :curriculum = 'curriculum'
      :edit = 'edit'
      ref = 'curriculum'
    ></curriculum>
  </div>
</template>

<script>
  import { buildCurriculum, validateCurriculum, Curriculum } from '../src/index'

  import curriculumDataBasic from './curriculumData'

  import curriculumDataInvalid from './curriculumDataInvalid'

  export default {
    data () {
      // Build the curriculum state.
      const curriculum = buildCurriculum(curriculumDataBasic)

      // Hot exports are now available.
      console.log(curriculum.exports.basic)

      // Get a validation report for a curriculum.
      console.log(validateCurriculum(curriculumDataInvalid))

      return {
        edit: false,
        curriculum: curriculum
      }
    },

    components: {
      Curriculum
    },

    mounted () {
      // Programatically set a selected (pinned) item
      this.$refs.curriculum.updateSelectedItem(this.curriculum.terms[2].items[3])
    },

    computed: {
      exports () {
        return this.curriculum.exports
      }
    },

    watch: {
      // We can also watch when the curriculum has changed by tracking its exports
      exports () {
        console.log(this.exports)
      }
    }
  }
</script>

<style>
  .toggle-edit {
    padding: 10px;
    text-align: center;
    font-size: 16px;
    background: #f2f2f2;
    margin-bottom: 20px;
    line-height: 33px;
  }

  .toggle-edit label {
    cursor: pointer;
    margin-right: 5px;
  }

  .toggle-edit a {
    float: right;
  }

  .toggle-edit button {
    transition: all 0.25s;
    padding: 5px 10px;
    font-size: 16px;
    background: none;
    border-radius: 2px;
    color: rgb(73, 184, 134);
    border: 2px solid rgb(73, 184, 134);
  }

  .toggle-edit button:hover {
    background: rgb(73, 184, 134);
    color: white;
    cursor: pointer;
  }
</style>
