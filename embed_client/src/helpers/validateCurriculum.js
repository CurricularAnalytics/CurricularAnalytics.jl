import { some, flatten } from 'lodash'
import buildCurriculum from './buildCurriculum'

// This exposed function will return an object with {errors: [], warnings: []}. If there were no errors or warnings then the curriculum is determined to be valid.
export default function (curriculum, format) {
  const errors = []
  const warnings = []

  try {
    curriculum = buildCurriculum(curriculum, {format})

    if (!curriculum.terms.length) errors.push({description: 'Curriculum must have terms.', code: 'terms-empty'})
    if (!curriculum.items.length) errors.push({description: 'Curriculum must have items.', code: 'items-empty'})

    validateCycles(curriculum, errors, warnings)
    validateRequisiteDirections(curriculum, errors, warnings)
    validateForwardEdges(curriculum, errors, warnings)
  } catch (error) {
    console.log(error)
    errors.push({description: 'Curriculum is not valid.', code: 'error'})
  }

  return {errors, warnings}
}

// Add an error for any item within a requisite cycle
function validateCycles (curriculum, errors, warnings) {
  curriculum.items.forEach(item => {
    if (withinCycle(item)) errors.push({description: `Circular requisite pattern found involving ${item.name}.`, code: 'cycle-found'})
  })
}

// Check a root item to see if it is involved in a requisite cycle
function withinCycle (root, item = root, visited = []) {
  visited.push(item)
  return some(item.sourceLinks, link => {
    if (root === link.source) return true
    else if (visited.includes(link.source)) return false
    else return withinCycle(root, link.source, visited.slice())
  })
}

// Add an error for any requisites that does not follow its item-term constraints
function validateRequisiteDirections (curriculum, errors, warnings) {
  curriculum.items.forEach(item => {
    item.sourceLinks.forEach(link => {
      switch (link.type) {
        case 'prereq':
          if (link.source.term.position >= link.target.term.position) {
            errors.push({
              description: `${link.target.name} has a prerequisite of ${link.source.name}, therefore ${link.source.name} must occur in an earlier term than ${link.target.name}.`, code: 'prereq-invalid'
            })
          }
          break
        case 'coreq':
          if (link.source.term.position > link.target.term.position) {
            errors.push({
              description: `${link.target.name} has a corequisite of ${link.source.name}, therefore ${link.source.name} must occur in the same or an earlier term than ${link.target.name}.`, code: 'coreq-invalid'
            })
          }
          break
        case 'strict-coreq':
          if (link.source.term !== link.target.term) {
            errors.push({
              description: `${link.target.name} has a strict-corequisite of ${link.source.name}, therefore ${link.source.name} must occur in the same term as ${link.target.name}.`, code: 'strict-coreq-invalid'
            })
          }
          break
      }
    })
  })
}

function validateForwardEdges (curriculum, errors, warnings) {
  curriculum.items.forEach(item => {
    const backwardItems = flatten(item.allPaths.source.map(t => t.items.slice(2)))

    item.sourceLinks.forEach(link => {
      // If the item's immediate source nodes occur more than once in the item's tree then the link is redundant
      if (backwardItems.includes(link.source)) {
        warnings.push({
          description: `${link.target.name} has a ${link.typeName} of ${link.source.name}, this ${link.typeName} is redundant and is achieved through other requisites.`, code: 'forward-edge'
        })
      }
    })
  })
}
