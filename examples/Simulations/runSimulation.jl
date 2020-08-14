using Pkg
Pkg.activate("../..")
Pkg.resolve()
Pkg.instantiate()
using CurricularAnalytics

include("CurriculumPool.jl")

################### Configuration ###################

########## Basic configuration ##########
num_students = 10
course_passrate = 0.5

max_credits = 19
duration = 10
duration_lock = false
stopouts = true

performance_model = PassRate
enrollment_model = Enrollment

########## Define a degree plan ##########
# Comment and uncomment to change the degree plan
# courses, degree_plan = Example_C1()      # refer to the curriculum in examples/Introduction/Example_C1.jl
# courses, degree_plan = Example_C2()      # refer to the curriculum in examples/Introduction/Example_C2.jl
# courses, degree_plan = UKY_EE_curric()   # refer to the curriculum in examples/UKY_EE_curric.jl

# Comment this whole section if use the courses and degree plan above
degree_plan = read_csv("Univ_of_Arizona-Aero.csv")     # change the degree plan csv file for different plan
courses = degree_plan.curriculum.courses
println("\n $(degree_plan.curriculum.name), $(degree_plan.name)")

########## Set the course passrates ##########
# set_passrates(courses, course_passrate)     # set pass rate for all courses

# Compute the pass rate using UA student grade records from Spring 2017 to Fall 2019
csv_path = "/Users/jiachengzhang/Desktop/CurricularAnalytics.jl/examples/Simulations/Student_Grades_sp17_to_fall19.csv"
set_passrates_from_csv(courses, csv_path, course_passrate)

########## Define students ##########
students = simple_students(num_students)    # Create a cohort of students for simulation

##########################################################

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
