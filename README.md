# CurricularAnalytics.jl (Simulation)

## Installation
- Clone the repo to the local machine

## Run Simulation Examples
- ``` bash
  cd CurricularAnalytics.jl/example/Simulations
  ```
- ``` bash
  julia runSimulation.jl
  ```

## Set Course Pass Rate for a Specific Course
- To access all courses in the curriculum:
  - If the degree plan is stored in the variable `degreePlan`
  - ``` julia
    courses = degreePlan.curriculum.courses
    ```
  - First Course:
    ``` julia
    courses[1]
    ```
  - Change the pass rate of the first course to 0.5:
    ``` julia
    courses[1].passrate = 0.5
    ```

**Note:** Change the simulation configurations and degree plans by adjusting **config** section
