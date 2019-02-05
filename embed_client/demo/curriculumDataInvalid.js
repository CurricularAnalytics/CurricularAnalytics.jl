// This data set represents the data structure that the exposed
// buildCurriculum function is expecting.

export default {
  terms: [
    // Term 1
    {
      id: 1,
      name: 'Term 1',
      items: [
        {
          id: 1,
          name: 'ECE 101',
          credits: 3,
          requisites: [
            // Wrong direction and creates cycle
            {
              source_id: 4,
              target_id: 1,
              type: 'prereq'
            }
          ]
        },
        {
          id: 2,
          name: 'ECE 102',
          credits: 3,
          requisites: []
        },
        {
          id: 3,
          name: 'ECE 103',
          credits: 3,
          requisites: []
        }
      ]
    },

    // Term 2
    {
      id: 2,
      name: 'Term 2',
      items: [
        {
          id: 4,
          name: 'ECE 201',
          credits: 3,
          requisites: [
            {
              source_id: 1,
              target_id: 4,
              type: 'prereq'
            },
            // Wrong direction
            {
              source_id: 6,
              target_id: 4,
              type: 'coreq'
            }
          ]
        },
        {
          id: 5,
          name: 'ECE 202',
          credits: 6,
          requisites: []
        }
      ]
    },

    // Term 3
    {
      id: 3,
      name: 'Term 3',
      items: [
        {
          id: 6,
          name: 'ECE 301',
          credits: 3,
          requisites: []
        },
        {
          id: 7,
          name: 'ECE 302',
          credits: 2,
          requisites: [
            // Wrong direction
            {
              source_id: 10,
              target_id: 7,
              type: 'strict-coreq'
            },

            {
              source_id: 5,
              target_id: 7,
              type: 'prereq'
            },

            {
              source_id: 2,
              target_id: 7,
              type: 'prereq'
            }
          ]
        },
        {
          id: 8,
          name: 'ECE 303',
          credits: 3,
          requisites: [
            {
              source_id: 3,
              target_id: 8,
              type: 'prereq'
            }
          ]
        },
        {
          id: 9,
          name: 'ECE 305',
          credits: 1,
          requisites: [
            // Redundant
            {
              source_id: 6,
              target_id: 9,
              type: 'strict-coreq'
            },
            {
              source_id: 4,
              target_id: 9,
              type: 'prereq'
            }
          ]
        }
      ]
    },

    // Term 4
    {
      id: 4,
      name: 'Term 4',
      items: [
        {
          id: 10,
          name: 'ECE 401',
          credits: 2,
          requisites: [
            {
              source_id: 12,
              target_id: 10,
              type: 'coreq'
            }
          ]
        },
        {
          id: 11,
          name: 'ECE 402',
          credits: 3,
          requisites: [
            {
              source_id: 5,
              target_id: 11,
              type: 'prereq'
            },

            {
              source_id: 10,
              target_id: 11,
              type: 'strict-coreq'
            }
          ]
        },
        {
          id: 12,
          name: 'ECE 403',
          credits: 3,
          requisites: [
            // Redundant
            {
              source_id: 3,
              target_id: 12,
              type: 'prereq'
            },
            {
              source_id: 8,
              target_id: 12,
              type: 'prereq'
            }
          ]
        }
      ]
    }
  ]
}
