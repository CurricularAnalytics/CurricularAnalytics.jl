using Pkg
Pkg.activate("../..")
Pkg.resolve()
Pkg.instantiate()
using CurricularAnalytics

include("CurriculumPool.jl")

################### Change the Setting ###################
# config
num_students = 10
course_passrate = 0.8

max_credits = 19
duration = 10
duration_lock = false
stopouts = true

performance_model = PassRate
enrollment_model = Enrollment

# Comment and uncomment to change the degree plan
# courses, degree_plan = Example_C1()      # refer to the curriculum in examples/Introduction/Example_C1.jl
# courses, degree_plan = Example_C2()      # refer to the curriculum in examples/Introduction/Example_C2.jl
# courses, degree_plan = UKY_EE_curric()   # refer to the curriculum in examples/UKY_EE_curric.jl

# Comment this whole section if use the courses and degree plan above
degree_plan = read_csv("Univ_of_Arizona-Aero.csv")     # change the degree plan csv file for different plan
courses = degree_plan.curriculum.courses
name = degree_plan.curriculum.name
println()
println("Degree Plan: $name")

##########################################################

students = simple_students(num_students)    # Create a cohort of students for simulation
set_passrates(courses, course_passrate)     # set pass rate for all courses

# run simulation
simulation = simulate(degree_plan,
                      students,
                      max_credits = max_credits,
                      performance_model = PassRate,
                      enrollment_model = Enrollment,
                      duration = duration,
                      duration_lock = duration_lock,
                      stopouts = stopouts)

# print
simulation_report(simulation, duration, course_passrate, max_credits)
