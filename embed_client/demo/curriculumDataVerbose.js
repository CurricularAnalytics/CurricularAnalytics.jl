export default {
  curriculum_terms: [
    // Term 1
    {
      id: 1,
      name: 'Term 1',
      curriculum_items: [
        {
          id: 1,
          name: 'ECE 101',
          credits: 3,
          curriculum_requisites: []
        },
        {
          id: 2,
          name: 'ECE 102',
          credits: 3,
          curriculum_requisites: []
        },
        {
          id: 3,
          name: 'ECE 103',
          credits: 3,
          curriculum_requisites: []
        },
        {
          id: 13,
          name: 'TEST 101',
          credits: 3,
          curriculum_requisites: []
        }
      ]
    },

    // Term 2
    {
      id: 2,
      name: 'Term 2',
      curriculum_items: [
        {
          id: 4,
          name: 'ECE 201',
          credits: 3,
          curriculum_requisites: [
            {
              source_id: 1,
              target_id: 4,
              type: 'CurriculumPrerequisite'
            },

            {
              source_id: 3,
              target_id: 4,
              type: 'CurriculumCorequisite'
            }
          ]
        },
        {
          id: 5,
          name: 'ECE 202',
          credits: 6,
          curriculum_requisites: []
        }
      ]
    },

    // Term 3
    {
      id: 3,
      name: 'Term 3',
      curriculum_items: [
        {
          id: 6,
          name: 'ECE 301',
          credits: 3,
          curriculum_requisites: []
        },
        {
          id: 7,
          name: 'ECE 302',
          credits: 2,
          curriculum_requisites: [
            {
              source_id: 6,
              target_id: 7,
              type: 'CurriculumStrictCorequisite'
            },

            {
              source_id: 5,
              target_id: 7,
              type: 'CurriculumPrerequisite'
            },

            {
              source_id: 2,
              target_id: 7,
              type: 'CurriculumPrerequisite'
            }
          ]
        },
        {
          id: 8,
          name: 'ECE 303',
          credits: 3,
          curriculum_requisites: [
            {
              source_id: 3,
              target_id: 8,
              type: 'CurriculumPrerequisite'
            }
          ]
        },
        {
          id: 9,
          name: 'ECE 305',
          credits: 1,
          curriculum_requisites: [
            {
              source_id: 6,
              target_id: 9,
              type: 'CurriculumStrictCorequisite'
            },

            {
              source_id: 4,
              target_id: 9,
              type: 'CurriculumPrerequisite'
            }
          ]
        }
      ]
    },

    // Term 4
    {
      id: 4,
      name: 'Term 4',
      curriculum_items: [
        {
          id: 10,
          name: 'ECE 401',
          credits: 2,
          curriculum_requisites: [
            {
              source_id: 12,
              target_id: 10,
              type: 'CurriculumCorequisite'
            }
          ]
        },
        {
          id: 11,
          name: 'ECE 402',
          credits: 3,
          curriculum_requisites: [
            {
              source_id: 5,
              target_id: 11,
              type: 'CurriculumPrerequisite'
            },

            {
              source_id: 10,
              target_id: 11,
              type: 'CurriculumStrictCorequisite'
            }
          ]
        },
        {
          id: 12,
          name: 'ECE 403',
          credits: 3,
          curriculum_requisites: [
            {
              source_id: 3,
              target_id: 12,
              type: 'CurriculumPrerequisite'
            }
          ]
        }
      ]
    }
  ]
}
