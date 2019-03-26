import detectFormat from './detectFormat'
import { groupBy, uniqueId } from 'lodash'

export default function (curriculum, format = null) {
  format = format || detectFormat(curriculum)

  switch (format) {
    case 'basic':
      return formatBasic(curriculum)
    case 'verbose':
      return formatVerbose(curriculum)
    default:
      return curriculum
  }
}

function formatBasic (curriculum) {
  // This will be the final version of curriculum once formatted.
  const formattedCurriculum = { terms: [], originalFormat: 'basic' }

  // Create an object for all courses name and their ID
  const courseIds = {}

  // Assign a unique ID to each course in the curriculum
  curriculum.courses.forEach(course => {
    courseIds[course.name] = course.id = +uniqueId()
  })

  // Group all of the courses together by term
  curriculum = groupBy(curriculum.courses, 'term')

  // Parse out the prerequisites, corequisites, and strictcorequisites from each course and store
  // them in the new format via their IDs.
  parseRequisites(curriculum, courseIds)

  // For each term in the original curriculum, create an object for the new format
  for (const term in curriculum) {
    formattedCurriculum.terms.push({
      id: term,
      name: `Term ${term}`,
      items: gatherCoursesFromTerm(curriculum, term)
    })
  }
  return formattedCurriculum
}

function formatVerbose (curriculum) {
  // This will be the final version of curriculum once formatted.
  const formattedCurriculum = { terms: [], originalFormat: 'verbose' }

  // For each term...
  curriculum.curriculum_terms.forEach(term => {
    // For each item...
    term.curriculum_items.forEach(item => {
      // For each requisite...
      item.curriculum_requisites.forEach(requisite => {
        if (requisite.type === 'CurriculumPrerequisite') {
          requisite.type = 'prereq'
        } else if (requisite.type === 'CurriculumCorequisite') {
          requisite.type = 'coreq'
        } else if (requisite.type === 'CurriculumStrictCorequisite') {
          requisite.type = 'strict-coreq'
        }
      })
      // Rename curriculum_requisites to requisites
      item.requisites = item.curriculum_requisites
      delete item.curriculum_requisites
    })
    // Rename curriculum_item to items
    term.items = term.curriculum_items
    delete term.curriculum_items
  })
  // Rename curriculum_terms to terms
  formattedCurriculum.terms = curriculum.curriculum_terms
  delete curriculum.curriculum_terms

  return formattedCurriculum
}

function parseRequisites (curriculum, courseIds) {
  // Loop through each term in the curriculum...
  for (const array in curriculum) {
    // For each course in that term...
    curriculum[array].forEach(course => {
      // Create requisites object that contains all prereqs, coreqs, and strict-coreqs
      const requisites = (course.prerequisites || []).map(r => [r, 'prereq'])
                   .concat((course.corequisites || []).map(r => [r, 'coreq']))
                   .concat((course.strictcorequisites || []).map(r => [r, 'strict-coreq']))

      // Map requisites object to the actual course
      course.requisites = requisites.map(requisite => {
        return {
          // requisite[0] being the course name
          source_id: courseIds[requisite[0]],
          target_id: course.id,
          // requisite[1] being the type of req
          type: requisite[1]
        }
      })
    })
  }
  return curriculum
}

function gatherCoursesFromTerm (curriculum, term) {
  const result = []
  curriculum[term].forEach(course => {
    result.push(course)
  })
  return result
}
