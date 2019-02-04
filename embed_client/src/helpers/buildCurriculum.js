import Curriculum from '../base/Curriculum'
import Term from '../base/Term'
import Item from '../base/Item'
import Link from '../base/Link'
import { sortBy } from 'lodash'
import formatCurriculum from './formatCurriculum'

// Function used to prepare curriculum data for use by vue-curricula components.
// * Creates curriculum VM
// * Creates and sorts VM Terms
// * Creates and sorts VM Items
// * Creates and associates VM Links
// vm:curriculum: {
//   terms: [
//     vm:term: {
//       items: [
//         vm:item: {
//           sourceLinks: [
//             vm:link
//           ],
//           target: [
//             vm:link
//           ]
//         },
//         ..
//       ]
//     },
//     ..
//   ]
// }
export default function (curriculum, options = {}) {
  const components = {}

  components.Curriculum = options.Curriculum || Curriculum
  components.Term = options.Term || Term
  components.Item = options.Item || Item
  components.Link = options.Link || Link

  const originalCurriculum = curriculum
  curriculum = formatCurriculum(originalCurriculum, options.format)

  let allItems = []

  // Build Terms
  const newTerms = sortBy(curriculum.terms, 'position').map((term, termIndex) => {
    const newTerm = new components.Term({
      data: {
        id: term.id,
        name: term.name,
        position: termIndex,
        items: [],
        components,
        original: term
      }
    })

    // Build Items
    const newItems = sortBy(term.items, 'position').map((item, itemIndex) => {
      return new components.Item({
        data: {
          id: item.id,
          name: item.name,
          nameSub: item.nameSub,
          nameCanonical: item.nameCanonical,
          credits: item.credits,
          requisites: item.requisites,
          position: itemIndex,
          term: newTerm,
          original: item
        }
      })
    })

    newTerm.items = newItems

    newTerm.items.forEach(item => {
      item.term = newTerm
    })

    allItems = allItems.concat(newItems)

    return newTerm
  })

  // Build Links and associate them with Source and Target items
  allItems.forEach(target => {
    target.requisites.forEach(requisite => {
      const source = allItems.find(item => item.id === requisite.source_id)
      if (!target || !source) return

      // Link will be referenced by source / item so no need to store in variable
      new components.Link({ // eslint-disable-line no-new
        data: {
          type: requisite.type,
          source,
          target
        }
      })
    })
  })

  const newCurriculum = new components.Curriculum({
    data: {
      originalFormat: curriculum.originalFormat || 'default',
      terms: newTerms,
      components,
      original: originalCurriculum
    }
  })

  newTerms.forEach(term => {
    term.curriculum = newCurriculum
  })

  return newCurriculum
}
